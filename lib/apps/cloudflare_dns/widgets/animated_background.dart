/*
 *        _____   _          __  _____   _____   _       _____   _____
 *      /  _  \ | |        / / /  _  \ |  _  \ | |     /  _  \ /  ___|
 *      | | | | | |  __   / /  | | | | | |_| | | |     | | | | | |
 *      | | | | | | /  | / /   | | | | |  _  { | |     | | | | | |   _
 *      | |_| | | |/   |/ /    | |_| | | |_| | | |___  | |_| | | |_| |
 *      \_____/ |___/|___/     \_____/ |_____/ |_____| \_____/ \_____/
 *
 *  Copyright (c) 2023 by OwOTeam-DGMT (OwOBlog).
 * @Date         : 2025-10-22
 * @Author       : HanskiJay
 * @LastEditors  : HanskiJay
 * @LastEditTime : 2025-10-22
 * @E-Mail       : support@owoblog.com
 * @Telegram     : https://t.me/HanskiJay
 * @GitHub       : https://github.com/Tommy131
 */
import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: BackgroundPainter(
            _controller.value,
            Theme.of(context).brightness,
          ),
          child: Container(),
        );
      },
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final double animationValue;
  final Brightness brightness;

  BackgroundPainter(this.animationValue, this.brightness);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final gradient = brightness == Brightness.dark
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0E27), Color(0xFF151932), Color(0xFF0A0E27)],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE2E2E2), Color(0xFFF5F5F5), Color(0xFFDBDBDB)],
          );

    paint.shader = gradient.createShader(
      Rect.fromLTWH(0, 0, size.width, size.height),
    );
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    _drawAnimatedCircles(canvas, size);
  }

  void _drawAnimatedCircles(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final circles = brightness == Brightness.dark
        ? [
            {'x': 0.2, 'y': 0.3, 'r': 150.0, 'color': const Color(0xFF00F5FF)},
            {'x': 0.8, 'y': 0.7, 'r': 200.0, 'color': const Color(0xFF7B2FFF)},
            {'x': 0.5, 'y': 0.5, 'r': 100.0, 'color': const Color(0xFFFF006E)},
          ]
        : [
            {'x': 0.2, 'y': 0.3, 'r': 150.0, 'color': const Color(0xFF0091FF)},
            {'x': 0.8, 'y': 0.7, 'r': 200.0, 'color': const Color(0xFF6B5BFF)},
            {'x': 0.5, 'y': 0.5, 'r': 100.0, 'color': const Color(0xFFFF4081)},
          ];

    for (var circle in circles) {
      final x =
          size.width * (circle['x'] as double) +
          math.sin(animationValue * 2 * math.pi) * 50;
      final y =
          size.height * (circle['y'] as double) +
          math.cos(animationValue * 2 * math.pi) * 50;
      final r = circle['r'] as double;
      final color = circle['color'] as Color;

      paint.shader = RadialGradient(
        colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromCircle(center: Offset(x, y), radius: r));

      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(BackgroundPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue ||
      oldDelegate.brightness != brightness;
}
