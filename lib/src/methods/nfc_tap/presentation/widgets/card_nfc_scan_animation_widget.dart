import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../base/define/constant/constant.dart';

final class NfcScanAnimationWidget extends StatefulWidget {
  const NfcScanAnimationWidget({super.key});

  @override
  State<NfcScanAnimationWidget> createState() => _NfcScanAnimationWidgetState();
}

final class _NfcScanAnimationWidgetState extends State<NfcScanAnimationWidget> with TickerProviderStateMixin {
  static const double _canvasWidth = 220.0;
  static const double _canvasHeight = 240.0;

  static const double _phoneWidth = 90.0;
  static const double _phoneHeight = 160.0;

  static const double _cardWidth = 104.0;
  static const double _cardHeight = 68.0;
  static const double _cardBorderRadius = 8.0;

  static const double _cardOffscreenX = 140.0;
  static const double _cardStartY = -40.0;
  static const double _cardEndY = 52.0;

  static const double _ringSize = 200.0;

  late final AnimationController _cardController;
  late final AnimationController _ringController;

  late final Animation<double> _cardTranslateX;
  late final Animation<double> _cardTranslateY;
  late final Listenable _cardListenable;

  late final Animation<double> _ringScale;
  late final Animation<double> _ringOpacity;

  final _phonePainter = const _PhonePainter();
  final _cardPainter = const _CardPainter(borderRadius: _cardBorderRadius);

  @override
  void initState() {
    super.initState();

    _cardController = AnimationController(vsync: this, duration: const Duration(milliseconds: 7500))..repeat();

    _ringController = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000))..repeat();

    _cardTranslateX = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: _cardOffscreenX, end: 0.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 16,
      ),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 60),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: _cardOffscreenX).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 24,
      ),
    ]).animate(_cardController);

    _cardTranslateY = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(_cardStartY), weight: 16),
      TweenSequenceItem(
        tween: Tween(begin: _cardStartY, end: _cardEndY).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
      TweenSequenceItem(tween: ConstantTween(_cardEndY), weight: 20),
      TweenSequenceItem(
        tween: Tween(begin: _cardEndY, end: _cardStartY).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 24,
      ),
    ]).animate(_cardController);

    _cardListenable = Listenable.merge([_cardTranslateX, _cardTranslateY]);

    _ringScale = Tween(begin: 0.4, end: 1.9).chain(CurveTween(curve: Curves.easeOut)).animate(_ringController);

    _ringOpacity = Tween(begin: 0.5, end: 0.0).chain(CurveTween(curve: Curves.easeOut)).animate(_ringController);
  }

  @override
  void dispose() {
    _cardController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _canvasWidth,
      height: _canvasHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Center(
              child: AnimatedBuilder(
                animation: _ringController,
                builder: (_, _) => CustomPaint(
                  size: const Size.square(_ringSize),
                  painter: _PulseRingPainter(scale: _ringScale.value, opacity: _ringOpacity.value),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _cardListenable,
              builder: (_, _) => Transform.translate(
                offset: Offset(_cardTranslateX.value, _cardTranslateY.value),
                child: Center(
                  child: SizedBox(
                    width: _cardWidth,
                    height: _cardHeight,
                    child: CustomPaint(painter: _cardPainter),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Center(
              child: SizedBox(
                width: _phoneWidth,
                height: _phoneHeight,
                child: CustomPaint(painter: _phonePainter),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final class _PulseRingPainter extends CustomPainter {
  const _PulseRingPainter({required this.scale, required this.opacity});

  final double scale;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 * scale;
    final paint = Paint()
      ..color = XPColorAction.primary.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_PulseRingPainter oldDelegate) => scale != oldDelegate.scale || opacity != oldDelegate.opacity;
}

final class _PhonePainter extends CustomPainter {
  const _PhonePainter();

  static const _bodyColor = Color(0xFF2A2A2E);
  static const _borderColor = Color(0xFF3E3E42);
  static const _notchColor = Color(0xFF3E3E42);
  static const _nfcColor = Color(0xFF2A9D8F);

  @override
  void paint(Canvas canvas, Size size) {
    const radius = 16.0;
    final bodyRect = RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(radius));

    canvas.drawRRect(bodyRect, Paint()..color = _bodyColor);
    canvas.drawRRect(
      bodyRect,
      Paint()
        ..color = _borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    const notchWidth = 32.0;
    const notchHeight = 6.0;
    final notchRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(size.width / 2, 12.0), width: notchWidth, height: notchHeight),
      const Radius.circular(3.0),
    );
    canvas.drawRRect(notchRect, Paint()..color = _notchColor);

    final cx = size.width / 2;
    final cy = size.height / 2 + 8.0;

    canvas.drawCircle(Offset(cx, cy), 3.0, Paint()..color = _nfcColor);

    final wavePaint = Paint()
      ..color = _nfcColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    for (var i = 1; i <= 3; i++) {
      final r = 6.0 + 5.5 * i;
      canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r), -math.pi * 0.25, math.pi * 0.5, false, wavePaint);
      canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r), math.pi * 0.75, math.pi * 0.5, false, wavePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

final class _CardPainter extends CustomPainter {
  const _CardPainter({required this.borderRadius});

  final double borderRadius;

  static const _bodyColor = Color(0xFF353538);
  static const _borderColor = Color(0xFF4A4A4E);
  static const _chipColor = Color(0xFFD4A843);
  static const _chipHighlight = Color(0xFFE8C868);
  static const _waveColor = Color(0x88FFFFFF);

  @override
  void paint(Canvas canvas, Size size) {
    final bodyRect = RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), Radius.circular(borderRadius));
    canvas.drawRRect(bodyRect, Paint()..color = _bodyColor);
    canvas.drawRRect(
      bodyRect,
      Paint()
        ..color = _borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    const chipW = 20.0;
    const chipH = 15.0;
    const chipLeft = 14.0;
    final chipTop = size.height / 2 - chipH / 2;
    final chipRect = RRect.fromRectAndRadius(Rect.fromLTWH(chipLeft, chipTop, chipW, chipH), const Radius.circular(2.5));
    canvas.drawRRect(chipRect, Paint()..color = _chipColor);

    final highlightRect = RRect.fromRectAndRadius(Rect.fromLTWH(chipLeft + 1.5, chipTop + 1.5, chipW - 3, chipH / 2 - 1.5), const Radius.circular(1.5));
    canvas.drawRRect(
      highlightRect,
      Paint()
        ..color = _chipHighlight
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    final barPaint = Paint()..color = const Color(0x44FFFFFF);
    const barW = 16.0;
    const barH = 3.0;
    const barGap = 5.0;
    const barCount = 4;
    const totalW = barCount * barW + (barCount - 1) * barGap;
    final barStartX = (size.width - totalW) / 2;
    final barY = size.height - 14.0;
    for (var i = 0; i < barCount; i++) {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(barStartX + i * (barW + barGap), barY, barW, barH), const Radius.circular(1.5)), barPaint);
    }

    final wavePaint = Paint()
      ..color = _waveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    final waveX = size.width - 22.0;
    const waveY = 18.0;
    for (var i = 1; i <= 3; i++) {
      canvas.drawArc(Rect.fromCircle(center: Offset(waveX, waveY), radius: 3.5 * i), -math.pi * 0.35, math.pi * 0.7, false, wavePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
