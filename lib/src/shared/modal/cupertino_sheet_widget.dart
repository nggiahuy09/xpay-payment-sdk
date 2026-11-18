part of 'modal_manager.dart';

class _XPCupertinoSheetWidget extends StatefulWidget {
  const _XPCupertinoSheetWidget({
    super.key,
    required this.trailingAction,
    required this.androidSafeAreaConfig,
    required this.iosSafeAreaConfig,
    required this.title,
    required this.overscrollToClose,
    required this.showCloseButton,
    required this.child,
  });

  final Widget? trailingAction;
  final XPPlatformSafeAreaConfig androidSafeAreaConfig;
  final XPPlatformSafeAreaConfig iosSafeAreaConfig;
  final String? title;
  final bool overscrollToClose;
  final bool showCloseButton;
  final Widget child;

  @override
  State<_XPCupertinoSheetWidget> createState() => _XPCupertinoSheetWidgetState();
}

class _XPCupertinoSheetWidgetState extends State<_XPCupertinoSheetWidget> {
  final ScrollController _scrollController = ScrollController();
  bool _isClosing = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (!widget.overscrollToClose || _isClosing) return false;
    if (notification is ScrollUpdateNotification) {
      final metrics = notification.metrics;

      if (metrics.pixels <= 0 && metrics.pixels < 0) {
        if (metrics.pixels.abs() > 200) {
          _isClosing = true;
          if (mounted) Navigator.of(context).maybePop();
          return true;
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return XPKeyboardDismissOnTap(
      child: XPPlatformSafeAreaView(
        iOSConfig: widget.iosSafeAreaConfig,
        androidConfig: widget.androidSafeAreaConfig,
        builder: (s) => Material(
          color: XPColorSurface.defaultColor,
          child: NotificationListener<ScrollNotification>(
            onNotification: _handleScrollNotification,
            child: Column(
              children: [
                if (widget.title != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: XPTextHighlightWidget.large(widget.title!, color: XPColorText.defaultColor, maxLines: 1, overflow: TextOverflow.clip),
                        ),
                        if (widget.trailingAction != null) ...[
                          const SizedBox(width: 8.0),
                          widget.trailingAction!,
                        ],
                        if (widget.showCloseButton) ...[
                          const SizedBox(width: 8.0),
                          InkWell(
                            onTap: () => Navigator.of(context).maybePop(),
                            child: const Icon(Remix.close_line, size: 24.0, color: XPColorIcon.defaultColor),
                          ),
                        ],
                      ],
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 16.0),
                    child: widget.overscrollToClose ? PrimaryScrollController(controller: _scrollController, child: widget.child) : widget.child,
                  ),
                ),
                SizedBox(height: s.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
