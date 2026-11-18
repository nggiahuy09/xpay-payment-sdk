import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../base/define/constant/constant.dart';
import '../../../../base/extensions/extensions.dart';
import '../../../../base/localization/localization.dart';
import '../../../../shared/helpers/helpers.dart';
import '../../../../shared/modal/modal_manager.dart';
import '../../../../shared/views/platform_safe_area_view.dart';
import '../../../../shared/widgets/widgets.dart';
import '../blocs/card_nfc_bloc.dart';
import '../widgets/card_nfc_invalid_widget.dart';
import '../widgets/card_nfc_not_enabled_widget.dart';
import '../widgets/card_nfc_not_supported_widget.dart';
import '../widgets/card_nfc_scan_animation_widget.dart';

final class CardNfcView extends StatefulWidget {
  const CardNfcView({super.key, required this.amount});

  final double amount;

  @override
  State<CardNfcView> createState() => _CardNfcViewState();
}

final class _CardNfcViewState extends State<CardNfcView> with WidgetsBindingObserver {
  void _startNfcRead(BuildContext context) {
    final bloc = context.read<CardNfcBloc>();

    XPHelperNfc.start(
      onDetected: (tag) async {
        final chipUid = XPHelperNfc.readUid(tag);
        final isMifareClassic = XPHelperNfc.isMifareClassic(tag);
        // The UID is omitted: it is the card's persistent identifier, and logging it on every tap would make taps correlatable per physical card.
        // XPLogger.info('Nfc tag detected: mifareClassic=$isMifareClassic, hasUid=${chipUid != null}', name: 'CardNfcView');

        if (chipUid == null || chipUid.isEmpty || bloc.isClosed) {
          await XPHelperNfc.stop();
          return;
        }

        // The session stays open: the handler reads the token sector off this tag, which is only valid while the session that discovered it lives. It is closed
        // once the read has resolved, either here or by the state listener.
        bloc.add(CardNfcTagDetectedEvent(tag: tag, chipUid: chipUid, isMifareClassic: isMifareClassic));
      },
      onError: (_) => XPModalManager.showBottomSheet(
        context: context,
        autoWrap: true,
        barrierDismissible: false,
        enableDrag: true,
        showThumb: false,
        child: CardNfcInvalidWidget(onBack: () => context.read<CardNfcBloc>().add(const CardNfcAttemptRetryEvent())),
      ),
    );
  }

  /// Shows [CardNfcInvalidWidget] with copy resolved from the failure.
  ///
  /// Nothing has touched the chip at this point, so dismissing simply abandons the tap. The scanner is only re-armed for a retryable failure — the named
  /// credential failures would fail identically on another tap of the same card, so re-arming would invite the operator to keep tapping a card that can never work.
  void _showPrepareError(BuildContext context, XPLocaleBase locale, CardNfcPrepareLoadErrorState state) {
    final viewLocale = locale.payment.xpay;
    XPModalManager.showBottomSheet(
      context: context,
      autoWrap: true,
      barrierDismissible: false,
      enableDrag: true,
      showThumb: false,
      child: CardNfcInvalidWidget(
        title: state.reason.getTitle(locale, state.failure.getTitle(viewLocale.nfcReadFailedTitle)),
        body: state.reason.getBody(locale, () => state.failure.getBody(viewLocale.nfcReadFailedBody)),
        onBack: () => context.read<CardNfcBloc>().add(const CardNfcAttemptRetryEvent()),
      ),
    );
  }

  /// The handset read a tag it cannot drive with Crypto1 — the sheet names the device rather than the card.
  ///
  /// Still re-arms the scanner on dismiss: the verdict is about the tag that was presented, not the handset's NFC stack as a whole, so a different card may well
  /// work. Leaving it un-armed would strand the operator on a live tap screen whose session has already been stopped.
  void _showUnsupportedTag(BuildContext context) => XPModalManager.showBottomSheet(
    context: context,
    autoWrap: true,
    showThumb: false,
    child: CardNfcNotSupportedWidget(onBack: () => context.read<CardNfcBloc>().add(const CardNfcAttemptRetryEvent())),
  );

  /// The counter could not be advanced, or the advance could not be confirmed.
  ///
  /// Re-arms the scanner: a fresh tap re-reads the counter off the card, which is the only correct recovery. An unconfirmed write can only have left the card
  /// ahead of the server, so the next tap still presents a value above the server's high-water mark.
  void _showCounterFailed(BuildContext context, XPLocaleBase locale) {
    final viewLocale = locale.payment.xpay;
    XPModalManager.showBottomSheet(
      context: context,
      autoWrap: true,
      barrierDismissible: false,
      enableDrag: true,
      showThumb: false,
      child: CardNfcInvalidWidget(
        title: viewLocale.nfcReadFailedTitle,
        body: viewLocale.nfcReadRetryBody,
        onBack: () => context.read<CardNfcBloc>().add(const CardNfcAttemptRetryEvent()),
      ),
    );
  }

  /// The broker refused to sign the counter presented.
  ///
  /// Always re-arms: recovery is re-reading the counter from the card, never re-sending the value that was refused. Forwarding a refused counter to `authorize`
  /// is what revokes the credential.
  void _showSignError(BuildContext context, XPLocaleBase locale, CardNfcSignErrorState state) {
    final viewLocale = locale.payment.xpay;
    XPModalManager.showBottomSheet(
      context: context,
      autoWrap: true,
      barrierDismissible: false,
      enableDrag: true,
      showThumb: false,
      child: CardNfcInvalidWidget(
        title: state.reason.getTitle(locale, state.failure.getTitle(viewLocale.nfcReadFailedTitle)),
        body: state.reason.getBody(locale, () => state.failure.getBody(viewLocale.nfcReadFailedBody)),
        onBack: state.reason.requiresRetap ? () => context.read<CardNfcBloc>().add(const CardNfcAttemptRetryEvent()) : null,
      ),
    );
  }

  /// The chip did not match the issuer's record. Nothing was written, so the card is untouched and the tap is simply abandoned.
  void _showCardRejected(BuildContext context, XPLocaleBase locale, CardNfcCardRejectedState state) => XPModalManager.showBottomSheet(
    context: context,
    autoWrap: true,
    barrierDismissible: false,
    enableDrag: true,
    showThumb: false,
    child: CardNfcInvalidWidget(
      title: state.verification.getTitle(locale),
      body: state.verification.getBody(locale),
      onBack: state.verification.isRetryable ? () => context.read<CardNfcBloc>().add(const CardNfcAttemptRetryEvent()) : null,
    ),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        context.read<CardNfcBloc>().add(const CardNfcCheckEnablingEvent());
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    XPHelperNfc.stop();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = XPLocalization.instance.locale;
    final xpayLocale = locale.payment.xpay;

    return MultiBlocListener(
      listeners: [
        BlocListener<CardNfcBloc, CardNfcState>(
          listenWhen: (prev, next) => prev.isEnabled != next.isEnabled,
          listener: (_, state) {
            if (state.isEnabled) _startNfcRead(context);
          },
        ),
        BlocListener<CardNfcBloc, CardNfcState>(
          listenWhen: (_, next) => next is CardNfcRetryEligibleState,
          listener: (_, state) {
            if (state.isEnabled) _startNfcRead(context);
          },
        ),
        // Releases the tag once the chip is genuinely finished with. Notably NOT on CardNfcCardVerifiedState — the counter write comes after it, and closing the
        // session there would invalidate the tag mid-sequence. Signing onwards needs no NFC, so the counter read-back is the last thing the card is needed for.
        BlocListener<CardNfcBloc, CardNfcState>(
          listenWhen: (_, next) => next is CardNfcSigningState || next is CardNfcFailureState,
          listener: (_, state) => XPHelperNfc.stop(),
        ),
        // The tap is signed, so this screen is done — hand the cryptogram back and let the payment flow authorize it, exactly as the QR and manual-entry screens
        // hand back their card token. Authorizing here instead would duplicate the verification, decline, and success routing the caller already owns.
        BlocListener<CardNfcBloc, CardNfcState>(
          listenWhen: (_, next) => next is CardNfcTapSignedState,
          listener: (_, state) {
            if (state case final CardNfcTapSignedState signedState) Navigator.of(context).pop(signedState.cryptogram);
          },
        ),
        BlocListener<CardNfcBloc, CardNfcState>(
          listenWhen: (_, next) => next is CardNfcFailureState,
          listener: (_, state) {
            if (state is! CardNfcFailureState) return;
            switch (state) {
              case final CardNfcPrepareLoadErrorState errorState:
                _showPrepareError(context, locale, errorState);
                break;
              case final CardNfcCardRejectedState rejectedState:
                _showCardRejected(context, locale, rejectedState);
                break;
              case final CardNfcSignErrorState signErrorState:
                _showSignError(context, locale, signErrorState);
                break;
              case CardNfcCounterFailedState _:
                _showCounterFailed(context, locale);
                break;
              case CardNfcUnsupportedTagState _:
                _showUnsupportedTag(context);
                break;
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: XPColorSurface.reverse,
        body: XPPlatformSafeAreaView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              spacing: 16.0,
              children: [
                SizedBox(height: MediaQuery.paddingOf(context).top),
                Row(
                  spacing: 16.0,
                  children: [
                    DecoratedBox(
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: XPColorOverlay.theme15),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Icon(Remix.close_line, size: 20.0, color: XPColorIcon.inversed),
                        ),
                      ),
                    ),
                    XPTextHighlightWidget.medium(xpayLocale.nfcTitle, color: XPColorText.inversed),
                  ],
                ),
                Expanded(
                  child: Center(
                    child: BlocBuilder<CardNfcBloc, CardNfcState>(
                      builder: (_, state) {
                        if (state.isEnabled == false) return const CardNfcNotEnabledWidget();

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              spacing: 4.0,
                              children: [
                                XPTextHeadingWidget.doubleExtraLarge(XPHelperCurrencyFormat.format(widget.amount), color: XPColorText.inversed),
                                XPTextBodyWidget.small(xpayLocale.amountToChargeLabel, color: XPColorText.inversed),
                              ],
                            ),
                            const SizedBox(height: 48.0),
                            const NfcScanAnimationWidget(),
                            const SizedBox(height: 48.0),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Column(
                                spacing: 8.0,
                                children: [
                                  XPTextHighlightWidget.medium(xpayLocale.nfcHintTitle, color: XPColorText.inversed, textAlign: TextAlign.center),
                                  XPTextBodyWidget.small(xpayLocale.nfcHintBody, color: XPColorText.inversed, textAlign: TextAlign.center),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
