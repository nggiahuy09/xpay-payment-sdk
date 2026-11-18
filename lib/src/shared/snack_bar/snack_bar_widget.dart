part of 'snack_bar_manager.dart';

class _XPSnackBarWidget extends StatelessWidget {
  const _XPSnackBarWidget({super.key, required this.level, required this.title, this.body, this.titleMaxLines = 2, this.bodyMaxLines, this.onTapContent, this.onTapClose});

  final XPSnackBarMessageLevel level;
  final String title;
  final String? body;
  final int titleMaxLines;
  final int? bodyMaxLines;
  final void Function()? onTapContent;
  final void Function()? onTapClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: onTapContent,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: XPColorBorder.inversed),
            borderRadius: const BorderRadius.all(Radius.circular(XPBorderRadius.rounded16)),
            color: level.surfaceColor,
            boxShadow: [
              const BoxShadow(color: XPColorShadow.reversedTheme10, blurRadius: 40, offset: Offset(0.0, 2.0)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            child: Row(
              spacing: 12.0,
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: XPColorOverlay.theme60,
                    border: Border.all(color: XPColorOverlay.theme40),
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Icon(level.icon, size: 32.0, color: level.iconColor),
                  ),
                ),
                Expanded(
                  child: Column(
                    spacing: 4.0,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      XPTextHighlightWidget.medium(title, color: XPColorText.defaultColor, maxLines: titleMaxLines),
                      if (body != null && body!.isNotEmpty) XPTextBodyWidget.small(body!, color: XPColorText.defaultColor, maxLines: bodyMaxLines),
                    ],
                  ),
                ),
                InkWell(
                  onTap: onTapClose,
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(Remix.close_line, size: 24.0, color: XPColorIcon.defaultColor),
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
