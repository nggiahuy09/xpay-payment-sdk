import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../base/define/constant/constant.dart';
import '../widgets/text/text_widgets.dart';

class XPCupertinoLoadingWidget extends StatelessWidget {
  const XPCupertinoLoadingWidget({super.key, this.radius = 10.0});

  final double radius;

  @override
  Widget build(BuildContext context) => Center(child: CupertinoActivityIndicator(radius: radius));
}

/// Shared discrete-circle loading indicator used across the app.
///
/// Wraps `LoadingAnimationWidget.discreteCircle` with the standard XPAY ring
/// colors so every spinner reads consistently. Only [size] is configurable.
class XPDiscreteCircleLoadingWidget extends StatelessWidget {
  const XPDiscreteCircleLoadingWidget({super.key, this.size = 32.0});

  final double size;

  @override
  Widget build(BuildContext context) {
    return LoadingAnimationWidget.discreteCircle(color: XPColorIcon.primary, secondRingColor: XPColorIcon.accent, thirdRingColor: XPColorIcon.primary, size: size);
  }
}

class XPDelayedHintLoadingWidget extends StatefulWidget {
  /// A loading spinner that reveals a hint message after [delay] elapses.
  ///
  /// Shows a [CupertinoActivityIndicator] immediately. After [delay] (default 3s),
  /// reveals [title] and [body] above the spinner to reassure the user the operation is still in progress.
  const XPDelayedHintLoadingWidget({super.key, this.delay = const Duration(seconds: 5), required this.title, required this.body, this.radius = 10.0});

  final Duration delay;
  final String title;
  final String body;
  final double radius;

  @override
  State<XPDelayedHintLoadingWidget> createState() => _XPDelayedHintLoadingWidgetState();
}

class _XPDelayedHintLoadingWidgetState extends State<XPDelayedHintLoadingWidget> {
  Timer? _timer;
  bool _showInstructions = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.delay, () => setState(() => _showInstructions = true));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget widget = CupertinoActivityIndicator(radius: this.widget.radius);
    if (_showInstructions) {
      widget = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          XPTextHighlightWidget.medium(this.widget.title, maxLines: 3, textAlign: TextAlign.center),
          const SizedBox(height: 8.0),
          XPTextBodyWidget.small(this.widget.body, maxLines: 3, color: XPColorText.subtle, textAlign: TextAlign.center),
          const SizedBox(height: 16.0),
          widget,
        ],
      );
    }
    return Center(child: widget);
  }
}
