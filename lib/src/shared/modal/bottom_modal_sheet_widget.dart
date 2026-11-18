part of 'modal_manager.dart';

class _XPBottomModalSheetWidget extends StatefulWidget {
  const _XPBottomModalSheetWidget({
    super.key,
    required this.iosSafeAreaConfig,
    required this.androidSafeAreaConfig,
    this.title,
    required this.blurIntensity,
    required this.topPadding,
    required this.titleBottomPadding,
    this.leftContentPadding = 20.0,
    this.topContentPadding = 16.0,
    this.rightContentPadding = 20.0,
    required this.topBorderRadius,
    required this.unfocusOnTap,
    required this.autoWrap,
    required this.showThumb,
    required this.overscrollToClose,
    required this.preventPop,
    required this.topRightCloseButton,
    required this.child,
  });

  final XPPlatformSafeAreaConfig iosSafeAreaConfig;
  final XPPlatformSafeAreaConfig androidSafeAreaConfig;
  final String? title;
  final double blurIntensity;
  final double topPadding;
  final double titleBottomPadding;
  final double leftContentPadding;
  final double topContentPadding;
  final double rightContentPadding;
  final double topBorderRadius;
  final bool unfocusOnTap;
  final bool autoWrap;
  final bool showThumb;
  final bool overscrollToClose;
  final bool preventPop;
  final bool topRightCloseButton;
  final Widget child;

  @override
  State<_XPBottomModalSheetWidget> createState() => _XPBottomModalSheetWidgetState();
}

class _XPBottomModalSheetWidgetState extends State<_XPBottomModalSheetWidget> {
  final double _focusedBottomPadding = XPLayoutConstant.kFocusedModalBottomPadding;
  final double _unfocusedBottomPadding = XPLayoutConstant.kUnfocusedModalBottomPadding;
  final ScrollController _scrollController = ScrollController();

  late double _bottomPadding;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    _bottomPadding = _unfocusedBottomPadding;
  }

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
    final focusChild = PopScope(
      canPop: widget.preventPop == false,
      child: Focus(
        onFocusChange: (hasFocus) => setState(() => _bottomPadding = hasFocus ? _focusedBottomPadding : _unfocusedBottomPadding),
        child: AnimatedPadding(
          padding: EdgeInsets.fromLTRB(widget.leftContentPadding, widget.topContentPadding, widget.rightContentPadding, _bottomPadding),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: XPKeyboardDismissOnTap(
            child: XPPlatformSafeAreaView(
              iOSConfig: widget.iosSafeAreaConfig,
              androidConfig: widget.androidSafeAreaConfig,
              child: widget.overscrollToClose ? PrimaryScrollController(controller: _scrollController, child: widget.child) : widget.child,
            ),
          ),
        ),
      ),
    );

    final size = MediaQuery.sizeOf(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (widget.unfocusOnTap) FocusScope.of(context).unfocus();
      },
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: widget.blurIntensity, sigmaY: widget.blurIntensity),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: XPColorSurface.defaultColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(widget.topBorderRadius)),
          ),
          child: NotificationListener<ScrollNotification>(
            onNotification: _handleScrollNotification,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: size.width, // Allow full screen width
                maxHeight: size.height - widget.topPadding,
                minHeight: widget.autoWrap == true ? 0.0 : size.height - widget.topPadding,
              ),
              // color: Colors.yellow,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: widget.autoWrap == true ? MainAxisSize.min : MainAxisSize.max,
                children: [
                  if (widget.showThumb)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Center(
                        child: SizedBox(
                          width: 64.0,
                          height: 6.0,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: XPColorBorder.secondary,
                              borderRadius: BorderRadius.all(Radius.circular(XPBorderRadius.rounded06)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (widget.title?.isNotEmpty ?? false)
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        widget.leftContentPadding,
                        widget.showThumb ? 0 : widget.topContentPadding,
                        widget.rightContentPadding,
                        widget.titleBottomPadding,
                      ),
                      child: Row(
                        children: [
                          Expanded(child: XPTextHighlightWidget.large(widget.title!, color: XPColorText.defaultColor, maxLines: 1)),
                          if (widget.topRightCloseButton) XPButtonIcon.noOutline(icon: Remix.close_line, iconSize: 24.0, onPressed: () => Navigator.of(context).pop()),
                        ],
                      ),
                    ),
                  widget.autoWrap == true ? Flexible(child: focusChild) : Expanded(child: focusChild),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
