import 'dart:async';

import 'package:flutter/material.dart';

final class VerificationCooldownBuilderWidget extends StatefulWidget {
  const VerificationCooldownBuilderWidget({super.key, this.deadline, this.onFinished, required this.builder});

  final DateTime? deadline;
  final void Function()? onFinished;
  final Widget Function(BuildContext context, int remainingSeconds) builder;

  @override
  State<VerificationCooldownBuilderWidget> createState() => _VerificationCooldownBuilderWidgetState();
}

final class _VerificationCooldownBuilderWidgetState extends State<VerificationCooldownBuilderWidget> {
  Timer? _timer;
  int _remainingSeconds = 0;

  static int _secondsUntil(DateTime deadline) {
    final milliseconds = deadline.difference(DateTime.now()).inMilliseconds;
    return milliseconds <= 0 ? 0 : (milliseconds / Duration.millisecondsPerSecond).ceil();
  }

  void _start() {
    _timer?.cancel();
    _timer = null;

    final deadline = widget.deadline;
    _remainingSeconds = deadline == null ? 0 : _secondsUntil(deadline);
    if (deadline == null) return;

    if (_remainingSeconds == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) => mounted ? widget.onFinished?.call() : null);
      return;
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick(deadline));
  }

  void _tick(DateTime deadline) {
    final remainingSeconds = _secondsUntil(deadline);
    setState(() => _remainingSeconds = remainingSeconds);
    if (remainingSeconds > 0) return;

    _timer?.cancel();
    _timer = null;
    widget.onFinished?.call();
  }

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(covariant VerificationCooldownBuilderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.deadline != widget.deadline) _start();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _remainingSeconds);
}
