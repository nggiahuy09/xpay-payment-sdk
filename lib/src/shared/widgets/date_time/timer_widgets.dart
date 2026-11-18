import 'dart:async';

import 'package:flutter/material.dart';

import '../../../base/extensions/duration_extension.dart';

export '../../../base/extensions/duration_extension.dart' show XPDurationFormat;

class XPCountdownWidget extends StatefulWidget {
  const XPCountdownWidget({
    super.key,
    this.format = XPDurationFormat.hourMinuteSecond,
    this.color,
    this.deadline,
    this.duration,
    this.interval = const Duration(seconds: 1),
    this.style,
    this.onFinished,
  }) : assert(interval > Duration.zero, 'interval must be greater than zero'),
       assert(deadline != null || duration != null, 'Must have a deadline or a total duration for the countdown to start.');

  final XPDurationFormat format;
  final Color? color;

  /// Time at deadline.
  final DateTime? deadline;

  /// Total countdown length. Will be prioritized over [deadline].
  final Duration? duration;

  /// How often the widget updates (default 1 second).
  final Duration interval;
  final TextStyle? style;
  final void Function()? onFinished;

  @override
  State<XPCountdownWidget> createState() => _XPCountdownWidgetState();
}

class _XPCountdownWidgetState extends State<XPCountdownWidget> {
  /// Recomputed on every [start] rather than cached, so a rebuild carrying a new deadline counts down to that one instead of the deadline this widget first saw.
  Duration get _duration => widget.duration ?? widget.deadline!.difference(DateTime.now());

  /// Initialized with [duration].
  late Duration _remaining;

  Timer? _timer;
  DateTime? _endTime;

  void start() {
    stop();
    _endTime = DateTime.now().add(_duration);
    // Use periodic timer but compute remaining from endTime to avoid drift
    _timer = Timer.periodic(widget.interval, (_) {
      final remaining = _endTime!.difference(DateTime.now());
      if (remaining <= Duration.zero) {
        stop();
        setState(() => _remaining = Duration.zero);
        widget.onFinished?.call();
      } else {
        setState(() => _remaining = remaining);
      }
    });

    // update immediately so UI doesn't wait first tick
    final initial = _endTime!.difference(DateTime.now());
    setState(() => _remaining = initial.isNegative ? Duration.zero : initial);
    if (_remaining == Duration.zero) {
      stop();
      // Deferred to after the frame: [start] runs from initState and didUpdateWidget, where notifying the parent synchronously would mean dispatching state changes
      // or navigating mid-build. A listener that reacts by rebuilding this subtree would otherwise assert.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onFinished?.call();
      });
    }
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _endTime = null;
  }

  @override
  void initState() {
    super.initState();
    _remaining = _duration;
    start();
  }

  /// Restarts against a deadline the parent replaced.
  ///
  /// Without this the countdown would keep running to the deadline captured in [initState] — for a code whose validity window the server extended, that means
  /// firing [XPCountdownWidget.onFinished] while the window is in fact still open.
  @override
  void didUpdateWidget(XPCountdownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.deadline != widget.deadline || oldWidget.duration != widget.duration) start();
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = _remaining.displayText(format: widget.format);
    final effectiveStyle = widget.style?.copyWith(color: widget.color) ?? TextStyle(color: widget.color);
    return Text(text, style: effectiveStyle);
  }
}
