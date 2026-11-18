import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/widgets/widgets.dart';
import '../blocs/verification_bloc.dart';

/// Watches the session's hard deadline and ends the flow when it passes, rendering nothing.
///
/// Separate from the visible countdown, which shows whichever moment matters for the method at hand and so is not always this one. Only this deadline is terminal; without it, a
/// merchant who resends and then waits would sit past `verification_deadline` on a screen still offering to verify, and only find out the sale was gone when they submitted.
final class VerificationDeadlineWatcherWidget extends StatelessWidget {
  const VerificationDeadlineWatcherWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<VerificationBloc, VerificationState, DateTime?>(
      selector: (state) => state.verification.verificationDeadline,
      builder: (_, deadline) {
        if (deadline == null || !deadline.isAfter(DateTime.now())) return const SizedBox.shrink();

        return Offstage(
          child: XPCountdownWidget(
            // deadline: DateTime.now().add(const Duration(seconds: 5)),
            deadline: deadline,
            onFinished: () => context.read<VerificationBloc>().add(const VerificationDeadlinePassedEvent()),
          ),
        );
      },
    );
  }
}
