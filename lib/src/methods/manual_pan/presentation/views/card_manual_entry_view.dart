import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../base/define/constant/constant.dart';
import '../../../../base/localization/localization.dart';
import '../../../../shared/helpers/helpers.dart';
import '../../../../shared/views/views.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/card_manual_pan_status_enum.dart';
import '../blocs/card_manual_entry_bloc.dart';
import '../widgets/card_manual_amount_summary_widget.dart';

/// Renders the manual card-entry form and hands the raw PAN (digits only) to [onSubmitted]. Real-time PAN/expiry validation lives in
/// [CardManualEntryBloc]; the controllers stay here because they are UI lifecycle state.
final class CardManualEntryView extends StatefulWidget {
  const CardManualEntryView({super.key, required this.amount, required this.onSubmitted});

  final double amount;
  final void Function(String pan) onSubmitted;

  @override
  State<CardManualEntryView> createState() => _CardManualEntryViewState();
}

final class _CardManualEntryViewState extends State<CardManualEntryView> {
  // final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _panController = TextEditingController();
  // final FocusNode _expiryFocusNode = FocusNode();
  final FocusNode _panFocusNode = FocusNode();

  String get _panDigits => XPHelperCardManualPanValidator.onlyDigits(_panController.text);

  void _handleSubmit() {
    FocusManager.instance.primaryFocus?.unfocus();
    widget.onSubmitted.call(_panDigits);
  }

  @override
  void dispose() {
    // _expiryController.dispose();
    _panController.dispose();
    // _expiryFocusNode.dispose();
    _panFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = XPLocalization.instance.locale;
    final viewLocale = locale.payment.create;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: XPColorSurface.defaultColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: XPAppBarWidget(
          titleWidget: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              XPTextHeadingWidget.large(viewLocale.manualEntryTitle),
              XPTextBodyWidget.extraSmall(viewLocale.manualEntrySubtitle, color: XPColorText.subtle),
            ],
          ),
        ),
      ),
      body: XPPlatformSafeAreaView(
        child: XPKeyboardDismissOnTap(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CardManualAmountSummaryWidget(amount: widget.amount),
                      const SizedBox(height: 24.0),
                      XPTextFieldOutlined(
                        controller: _panController,
                        focusNode: _panFocusNode,
                        textInputType: TextInputType.number,
                        inputFormatters: const [XPHelperCardPanInputFormatter(maxDigits: XPHelperCardManualPanValidator.maxDigits)],
                        customLabel: XPTextHighlightWidget.medium(viewLocale.manualEntryPanLabel, color: XPColorText.defaultColor),
                        hintText: viewLocale.manualEntryPanHint,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.0),
                          child: Icon(Remix.bank_card_line, size: 20.0, color: XPColorIcon.defaultColor),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 16.0),
                        onChanged: (value) => context.read<CardManualEntryBloc>().add(CardManualEntryPanChangedEvent(value)),
                      ),
                      const _PanValidationMessage(),
                      // const SizedBox(height: 16.0),
                      // XPTextFieldOutlined(
                      //   controller: _expiryController,
                      //   focusNode: _expiryFocusNode,
                      //   textInputType: TextInputType.number,
                      //   inputFormatters: const [XPHelperCardExpiryInputFormatter()],
                      //   customLabel: XPTextHighlightWidget.medium(viewLocale.manualEntryExpiryLabel, color: XPColorText.defaultColor),
                      //   hintText: viewLocale.manualEntryExpiryHint,
                      //   contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                      //   onChanged: (value) => context.read<CardManualEntryBloc>().add(CardManualEntryExpiryChangedEvent(value, DateTime.now())),
                      // ),
                      const SizedBox(height: 16.0),
                      XPInlineMessageWidget.safe(title: viewLocale.manualEntryEncryptedNote),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: BlocSelector<CardManualEntryBloc, CardManualEntryState, bool>(
                  selector: (state) => state.canSubmit,
                  builder: (_, canSubmit) => XPButtonFilled.medium(label: viewLocale.manualEntrySubmitButton, enabled: canSubmit, onPressed: canSubmit ? _handleSubmit : null),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _PanValidationMessage extends StatelessWidget {
  const _PanValidationMessage();

  @override
  Widget build(BuildContext context) {
    final locale = XPLocalization.instance.locale;

    return BlocSelector<CardManualEntryBloc, CardManualEntryState, CardManualPanStatus>(
      selector: (state) => state.panStatus,
      builder: (_, status) => status.isEmpty
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Row(
                spacing: 4.0,
                children: [
                  Icon(status.icon, size: 16.0, color: status.color),
                  Flexible(child: XPTextBodyWidget.small(status.getMessage(locale)!, color: status.color)),
                ],
              ),
            ),
    );
  }
}
