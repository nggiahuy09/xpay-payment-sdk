import 'package:flutter/material.dart';

import '../../../../base/define/constant/constant.dart';

final class QrScannerOverlayWidget extends StatelessWidget {
  const QrScannerOverlayWidget({super.key, required this.animation, required this.frameDimension, this.verticalOffset = 0.0});

  final Animation<double> animation;
  final double frameDimension;
  final double verticalOffset;

  static const Color _frameColor = XPColorBorder.primary;
  static const double _frameRadius = XPBorderRadius.rounded24;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final frameRect = Rect.fromCenter(center: Offset(constraints.maxWidth / 2, constraints.maxHeight / 2 + verticalOffset), width: frameDimension, height: frameDimension);
        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _ScannerHoleOverlayPainter(frameRect: frameRect, radius: _frameRadius),
              ),
            ),
            Positioned.fromRect(
              rect: frameRect,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(_frameRadius)),
                child: Stack(
                  children: [
                    const _ScanFrameCornerWidget(alignment: Alignment.topLeft),
                    const _ScanFrameCornerWidget(alignment: Alignment.topRight),
                    const _ScanFrameCornerWidget(alignment: Alignment.bottomLeft),
                    const _ScanFrameCornerWidget(alignment: Alignment.bottomRight),
                    AnimatedBuilder(
                      animation: animation,
                      builder: (_, child) => Positioned(left: 8.0, right: 8.0, top: 8.0 + animation.value * (frameDimension - 16.0), child: child!),
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Colors.transparent, _frameColor, Colors.transparent]),
                          boxShadow: [BoxShadow(color: _frameColor, blurRadius: 14.0, spreadRadius: 2.0)],
                        ),
                        child: SizedBox(height: 2.0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

final class _ScannerHoleOverlayPainter extends CustomPainter {
  const _ScannerHoleOverlayPainter({required this.frameRect, required this.radius});

  static const Color _overlayColor = XPColorOverlay.reverseTheme60;

  final Rect frameRect;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPath = Path()..addRect(Offset.zero & size);
    final holePath = Path()..addRRect(RRect.fromRectAndRadius(frameRect, Radius.circular(radius)));

    canvas.drawPath(
      Path.combine(PathOperation.difference, overlayPath, holePath),
      Paint()..color = _overlayColor,
    );
  }

  @override
  bool shouldRepaint(_ScannerHoleOverlayPainter oldDelegate) => oldDelegate.frameRect != frameRect || oldDelegate.radius != radius;
}

final class _ScanFrameCornerWidget extends StatelessWidget {
  const _ScanFrameCornerWidget({required this.alignment});

  static const Color _cornerColor = XPColorBorder.primary;
  static const double _cornerDimension = 34.0;
  static const double _strokeWidth = 4.0;

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final isTop = alignment.y < 0;
    final isLeft = alignment.x < 0;

    return Positioned(
      top: isTop ? 12.0 : null,
      bottom: isTop ? null : 12.0,
      left: isLeft ? 12.0 : null,
      right: isLeft ? null : 12.0,
      child: SizedBox.square(
        dimension: _cornerDimension,
        child: CustomPaint(
          painter: _CornerPainter(isTop: isTop, isLeft: isLeft, color: _cornerColor, strokeWidth: _strokeWidth),
        ),
      ),
    );
  }
}

final class _CornerPainter extends CustomPainter {
  const _CornerPainter({required this.isTop, required this.isLeft, required this.color, required this.strokeWidth});

  final bool isTop;
  final bool isLeft;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final half = strokeWidth / 2;
    final r = XPBorderRadius.rounded12;
    final path = Path();

    if (isTop && isLeft) {
      path.moveTo(half, size.height);
      path.lineTo(half, half + r);
      path.quadraticBezierTo(half, half, half + r, half);
      path.lineTo(size.width, half);
    } else if (isTop && !isLeft) {
      path.moveTo(0, half);
      path.lineTo(size.width - half - r, half);
      path.quadraticBezierTo(size.width - half, half, size.width - half, half + r);
      path.lineTo(size.width - half, size.height);
    } else if (!isTop && isLeft) {
      path.moveTo(half, 0);
      path.lineTo(half, size.height - half - r);
      path.quadraticBezierTo(half, size.height - half, half + r, size.height - half);
      path.lineTo(size.width, size.height - half);
    } else {
      path.moveTo(size.width - half, 0);
      path.lineTo(size.width - half, size.height - half - r);
      path.quadraticBezierTo(size.width - half, size.height - half, size.width - half - r, size.height - half);
      path.lineTo(0, size.height - half);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CornerPainter oldDelegate) =>
      oldDelegate.isTop != isTop || oldDelegate.isLeft != isLeft || oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}
