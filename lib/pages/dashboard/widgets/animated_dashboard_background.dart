import 'dart:math';
import 'package:flutter/material.dart';

/// 动画背景组件
/// 为仪表板页面提供动态背景效果
class AnimatedDashboardBackground extends StatefulWidget {
  const AnimatedDashboardBackground({super.key});

  @override
  State<AnimatedDashboardBackground> createState() =>
      _AnimatedDashboardBackgroundState();
}

class _AnimatedDashboardBackgroundState
    extends State<AnimatedDashboardBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _BackgroundPainter(
            animation: _controller.value,
            isDark: isDark,
            primaryColor: theme.colorScheme.primary,
          ),
          child: Container(),
        );
      },
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final double animation;
  final bool isDark;
  final Color primaryColor;

  _BackgroundPainter({
    required this.animation,
    required this.isDark,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    // 背景渐变
    final bgGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [const Color(0xFF0A0E27), const Color(0xFF1A1F3A)]
          : [const Color(0xFFF5F7FA), const Color(0xFFE8EBF0)],
    );

    final bgRect = Rect.fromLTWH(0, 0, size.width, size.height);
    paint.shader = bgGradient.createShader(bgRect);
    canvas.drawRect(bgRect, paint);

    // 绘制动画圆圈
    _drawAnimatedCircles(canvas, size, paint);

    // 绘制网格线
    _drawGridLines(canvas, size, paint);
  }

  void _drawAnimatedCircles(Canvas canvas, Size size, Paint paint) {
    final circles = [
      {
        'x': 0.2,
        'y': 0.3,
        'radius': 150.0,
        'speed': 1.0,
        'color': primaryColor.withValues(alpha: isDark ? 0.05 : 0.03),
      },
      {
        'x': 0.8,
        'y': 0.7,
        'radius': 200.0,
        'speed': 0.7,
        'color': primaryColor.withValues(alpha: isDark ? 0.04 : 0.02),
      },
      {
        'x': 0.5,
        'y': 0.5,
        'radius': 120.0,
        'speed': 1.3,
        'color': primaryColor.withValues(alpha: isDark ? 0.06 : 0.04),
      },
    ];

    for (final circle in circles) {
      final x = size.width * (circle['x'] as double);
      final y = size.height * (circle['y'] as double);
      final radius = circle['radius'] as double;
      final speed = circle['speed'] as double;
      final color = circle['color'] as Color;

      final animatedRadius = radius + sin(animation * 2 * pi * speed) * 20;

      paint.shader = RadialGradient(colors: [color, color.withValues(alpha: 0)])
          .createShader(
            Rect.fromCircle(center: Offset(x, y), radius: animatedRadius),
          );

      canvas.drawCircle(Offset(x, y), animatedRadius, paint);
    }
  }

  void _drawGridLines(Canvas canvas, Size size, Paint paint) {
    paint.shader = null;
    paint.color = isDark
        ? Colors.white.withValues(alpha: 0.02)
        : Colors.black.withValues(alpha: 0.02);
    paint.strokeWidth = 1;

    const gridSpacing = 50.0;

    // 垂直线
    for (double x = 0; x < size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // 水平线
    for (double y = 0; y < size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_BackgroundPainter oldDelegate) {
    return oldDelegate.animation != animation ||
        oldDelegate.isDark != isDark ||
        oldDelegate.primaryColor != primaryColor;
  }
}
