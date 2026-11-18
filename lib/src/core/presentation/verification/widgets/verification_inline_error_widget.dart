import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../base/localization/localization.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../domain/entities/verification_rejection_entity.dart';
import '../blocs/verification_bloc.dart';

/// Renders the retryable rejection below the code input, so the reason stays readable while the merchant re-enters the code instead of vanishing with a snackbar.
///
/// Occupies no space until a rejection lands. It survives the input being emptied — the bloc keeps the message while the field is blank — and disappears once real
/// digits arrive, since the message describes the code that was already submitted.
final class VerificationInlineErrorWidget extends StatelessWidget {
  const VerificationInlineErrorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = XPLocalization.instance.locale;

    return BlocSelector<VerificationBloc, VerificationState, VerificationRejectionEntity?>(
      selector: (state) => state.rejection,
      builder: (_, rejection) => switch (rejection) {
        final VerificationRejectionEntity value => XPInlineMessageWidget.danger(title: value.getMessageTitle(locale), body: value.getMessageBody(locale)),
        _ => const SizedBox.shrink(),
      },
    );
  }
}
