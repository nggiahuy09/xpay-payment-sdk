import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nfc_manager/nfc_manager.dart';

import '../../../../api/xpay_log_event.dart';
import '../../../../base/domain/domain.dart';
import '../../../../base/extensions/extensions.dart';
import '../../../../di/di.dart';
import '../../../../shared/helpers/helper_nfc.dart';
import '../../../../shared/business_logger/xp_business_logger.dart';
import '../../domain/entities/chip_tap_cryptogram_entity.dart';
import '../../domain/entities/chip_tap_cryptogram_failure_reason_enum.dart';
import '../../domain/entities/chip_tap_prepare_entity.dart';
import '../../domain/entities/chip_tap_prepare_failure_reason_enum.dart';
import '../../domain/entities/chip_tap_verification_enum.dart';
import '../../domain/repositories/chip_tap_repo.dart';
import '../../domain/usecases/prepare_chip_tap_uc.dart';
import '../../domain/usecases/sign_chip_tap_uc.dart';
import '../../domain/usecases/verify_chip_tap_card_uc.dart';

part 'card_nfc_event.dart';

part 'card_nfc_state.dart';

final class CardNfcBloc extends Bloc<CardNfcEvent, CardNfcState> {
  CardNfcBloc() : super(const CardNfcInitState()) {
    on<CardNfcCheckEnablingEvent>(_checkEnablingEventHandler);
    on<CardNfcAttemptRetryEvent>(_attemptRetryEventHandler);
    on<CardNfcTagDetectedEvent>(_tagDetectedEventHandler);
    on<_CardNfcCardVerifyEvent>(_cardVerifyEventHandler);
    on<_CardNfcCounterAdvanceEvent>(_counterAdvanceEventHandler);

    add(const CardNfcCheckEnablingEvent());
  }

  final _logger = getIt.get<XPBusinessLogger>();
  final _verifyChipTapCard = const VerifyChipTapCardUseCase();
  final _prepareChipTap = PrepareChipTapUseCase(getIt.get<ChipTapRepository>());
  final _signChipTap = SignChipTapUseCase(getIt.get<ChipTapRepository>());

  void _logBusiness({required Map<String, dynamic> input, XPayLogCategory category = XPayLogCategory.api, XPException? exception, required String action, String? reason}) {
    _logger.logBusiness(input: input, category: category, exception: exception, action: action, feature: 'card_nfc', reason: reason);
  }

  /// Guards against a second tap starting while one is still in flight.
  ///
  /// Covers the whole sequence, not just the prepare call: the broker hands out live key material per call, so overlapping taps would fetch two bundles for one
  /// payment, and two handlers reaching [XPHelperNfc.incrementCounter] would advance the same chip twice while only one value gets signed.
  bool _isTapping = false;

  Future<void> _checkEnablingEventHandler(CardNfcCheckEnablingEvent event, Emitter<CardNfcState> emit) async {
    emit(CardNfcEnableChangedState(await XPHelperNfc.isEnabled()));
  }

  void _attemptRetryEventHandler(CardNfcAttemptRetryEvent event, Emitter<CardNfcState> emit) {
    emit(CardNfcRetryingState(state.isEnabled));
    emit(CardNfcRetryEligibleState(state.isEnabled));
  }

  Future<void> _tagDetectedEventHandler(CardNfcTagDetectedEvent event, Emitter<CardNfcState> emit) async {
    if (_isTapping) return;

    final isEnabled = state.isEnabled;
    if (event.isMifareClassic == false) {
      emit(CardNfcUnsupportedTagState(isEnabled, event.chipUid));
      return;
    }

    _isTapping = true;
    emit(CardNfcPrepareLoadingState(isEnabled, event.chipUid));

    final input = PrepareChipTapInput(event.chipUid);
    final result = await _prepareChipTap.execute(input);
    if (isClosed) return;

    result.fold(
      (failure) {
        _logBusiness(input: input.toLog(), exception: failure, action: 'prepare');
        _isTapping = false;
        emit(CardNfcPrepareLoadErrorState(isEnabled, failure));
      },
      (prepare) => maybeAdd(_CardNfcCardVerifyEvent(tag: event.tag, prepare: prepare)),
    );
  }

  /// Emits the verdict [VerifyChipTapCardUseCase] reaches for the chip, and hands a genuine card on to the counter write.
  ///
  /// Nothing has been written at this point, so every non-matching verdict simply abandons the tap and leaves the card as it was.
  Future<void> _cardVerifyEventHandler(_CardNfcCardVerifyEvent event, Emitter<CardNfcState> emit) async {
    final isEnabled = state.isEnabled;
    final prepare = event.prepare;

    final verification = await _verifyChipTapCard.execute(VerifyChipTapCardInput(tag: event.tag, prepare: prepare));
    if (isClosed) return;
    // XPLogger.info('Chip token sector verified: verification=${verification.name}', name: 'CardNfcBloc');

    if (verification.isMatched == false) {
      _isTapping = false;
      emit(CardNfcCardRejectedState(isEnabled, verification));
      return;
    }

    emit(CardNfcCardVerifiedState(isEnabled, prepare));

    maybeAdd(_CardNfcCounterAdvanceEvent(tag: event.tag, prepare: prepare));
  }

  /// Advances the on-card counter, then has the broker sign the value that was read back.
  ///
  /// Order is load-bearing: the card is written first and the server is told second. If the signing call never lands, the card is left one ahead of the server,
  /// which the next tap resolves harmlessly. Signing first and writing second would leave the card *behind*, and the next tap would present a counter the server
  /// has already verified — a replay, which revokes the credential.
  Future<void> _counterAdvanceEventHandler(_CardNfcCounterAdvanceEvent event, Emitter<CardNfcState> emit) async {
    final isEnabled = state.isEnabled;
    final prepare = event.prepare;
    final layout = prepare.layout;
    final keyB = XPHelperNfc.hexToBytes(prepare.counterKeyB);
    final counterSector = layout?.counterSector;
    final counterBlock = layout?.counterBlock;
    final chipUid = prepare.chipUid;
    if (keyB == null || counterSector == null || counterBlock == null || chipUid == null || chipUid.isEmpty) {
      _logBusiness(input: {'chip_uid': prepare.chipUid}, category: XPayLogCategory.error, action: 'advance_counter', reason: 'incomplete_prepare_data');
      _isTapping = false;
      emit(CardNfcCounterFailedState(isEnabled));
      return;
    }

    int? counter;
    try {
      counter = await XPHelperNfc.incrementCounter(tag: event.tag, keyB: keyB, sector: counterSector, block: counterBlock);
    } catch (e) {
      // Whether the write landed is unknown here, and deliberately not guessed at: an unconfirmed increment only ever leaves the card ahead of the server.
      // XPLogger.error(error: e, message: 'Failed to advance chip counter on block $counterBlock');
    }
    if (isClosed) return;
    if (counter == null) {
      _logBusiness(
        input: {'chip_uid': chipUid, 'counter_sector': counterSector, 'counter_block': counterBlock},
        category: XPayLogCategory.error,
        action: 'advance_counter',
        reason: 'nfc_write_failed',
      );
      _isTapping = false;
      emit(CardNfcCounterFailedState(isEnabled));
      return;
    }

    // XPLogger.info('Chip counter advanced: counter=$counter', name: 'CardNfcBloc');
    emit(CardNfcSigningState(isEnabled, counter));

    final input = SignChipTapInput(chipUid: chipUid, counter: counter);
    final result = await _signChipTap.execute(input);
    if (isClosed) return;

    _isTapping = false;
    result.fold(
      (failure) {
        _logBusiness(input: input.toLog(), exception: failure, action: 'sign');
        emit(CardNfcSignErrorState(isEnabled, failure));
      },
      (cryptogram) {
        // The cryptogram and nonce are omitted: they authorize a payment on their own, so they do not belong in a log.
        // XPLogger.info('Chip tap signed: counter=${cryptogram.counter}, keyVersion=${cryptogram.keyVersion}, isAuthorizable=${cryptogram.isAuthorizable}', name: 'CardNfcBloc');
        emit(CardNfcTapSignedState(isEnabled, cryptogram));
      },
    );
  }
}
