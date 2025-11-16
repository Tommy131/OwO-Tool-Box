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
// ============================================================================
// Matrix Rain 特效组件 - 赛博朋克增强版（修复版）
// ============================================================================

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class MatrixRainConfig {
  final int columns;
  final double speed;
  final Color primaryColor;
  final Color secondaryColor;
  final double opacity;
  final bool enableGlow;
  final bool enableScanning;
  final bool enableGlitch;

  const MatrixRainConfig({
    this.columns = 30,
    this.speed = 80.0,
    this.primaryColor = const Color(0xFF00F0FF),
    this.secondaryColor = const Color(0xFF7B2FFF),
    this.opacity = 0.4,
    this.enableGlow = true,
    this.enableScanning = true,
    this.enableGlitch = true,
  });
}

class MatrixRain extends StatefulWidget {
  final Widget child;
  final MatrixRainConfig config;

  const MatrixRain({
    super.key,
    required this.child,
    this.config = const MatrixRainConfig(),
  });

  @override
  State<MatrixRain> createState() => _MatrixRainState();
}

class _MatrixRainState extends State<MatrixRain>
    with SingleTickerProviderStateMixin {
  final Random _random = Random();
  late List<RainDrop> drops;
  Timer? _timer;
  late AnimationController _scanController;
  double _scanPosition = 0;
  Timer? _glitchTimer;
  bool _isGlitching = false;

  @override
  void initState() {
    super.initState();
    _initDrops();
    _startAnimation();

    if (widget.config.enableScanning) {
      _scanController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 3),
      )..repeat();
      _scanController.addListener(() {
        if (mounted) {
          setState(() {
            _scanPosition = _scanController.value;
          });
        }
      });
    }

    if (widget.config.enableGlitch) {
      _startGlitchTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _glitchTimer?.cancel();
    if (widget.config.enableScanning) {
      _scanController.dispose();
    }
    super.dispose();
  }

  void _initDrops() {
    drops = List.generate(
      widget.config.columns,
      (i) => RainDrop(
        x: i.toDouble(),
        y: _random.nextDouble() * -50,
        speed: 0.8 + _random.nextDouble() * 2.2,
        length: 8 + _random.nextInt(15),
        intensity: 0.5 + _random.nextDouble() * 0.5,
        useSecondaryColor: _random.nextDouble() > 0.7,
      ),
    );
  }

  void _startAnimation() {
    _timer = Timer.periodic(
      Duration(milliseconds: widget.config.speed.toInt()),
      (_) {
        if (mounted) {
          setState(() {
            for (var drop in drops) {
              drop.y += drop.speed;

              if (drop.y > 110 + drop.length * 2) {
                drop.y = -10 - _random.nextDouble() * 30;
                drop.speed = 0.8 + _random.nextDouble() * 2.2;
                drop.length = 8 + _random.nextInt(15);
                drop.intensity = 0.5 + _random.nextDouble() * 0.5;
                drop.useSecondaryColor = _random.nextDouble() > 0.7;
              }

              if (_random.nextDouble() < 0.05) {
                drop.charOffset = _random.nextInt(100);
              }
            }
          });
        }
      },
    );
  }

  void _startGlitchTimer() {
    _glitchTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) {
        if (mounted && _random.nextDouble() < 0.3) {
          setState(() {
            _isGlitching = true;
          });

          Timer(const Duration(milliseconds: 200), () {
            if (mounted) {
              setState(() {
                _isGlitching = false;
              });
            }
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: CyberpunkMatrixPainter(
                drops: drops,
                config: widget.config,
                random: _random,
                scanPosition: _scanPosition,
                isGlitching: _isGlitching,
              ),
              child: Container(),
            ),
          ),
        ),
        if (widget.config.enableScanning)
          Positioned.fill(
            child: CustomPaint(
              painter: ScanLinePainter(
                position: _scanPosition,
                color: widget.config.primaryColor,
              ),
            ),
          ),
        widget.child,
      ],
    );
  }
}

class RainDrop {
  double x;
  double y;
  double speed;
  int length;
  double intensity;
  bool useSecondaryColor;
  int charOffset;

  RainDrop({
    required this.x,
    required this.y,
    required this.speed,
    required this.length,
    required this.intensity,
    required this.useSecondaryColor,
    this.charOffset = 0,
  });
}

class CyberpunkMatrixPainter extends CustomPainter {
  final List<RainDrop> drops;
  final MatrixRainConfig config;
  final Random random;
  final double scanPosition;
  final bool isGlitching;

  static const chars =
      '01ｦｱｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const specialChars = '▓▒░█▄▀■◆◇●◎☆★◢◣◤◥';

  CyberpunkMatrixPainter({
    required this.drops,
    required this.config,
    required this.random,
    required this.scanPosition,
    required this.isGlitching,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width == 0 || size.height == 0) return;

    final colWidth = size.width / drops.length;
    const charHeight = 22.0;

    for (var drop in drops) {
      final baseX = drop.x * colWidth + colWidth / 2;
      final baseColor =
          drop.useSecondaryColor ? config.secondaryColor : config.primaryColor;

      final glitchOffset = isGlitching ? (random.nextDouble() - 0.5) * 10 : 0.0;
      final x = baseX + glitchOffset;

      for (int i = 0; i < drop.length; i++) {
        final y = (drop.y / 100) * size.height + i * charHeight;

        if (y < -charHeight || y > size.height + charHeight) continue;

        final charIndex =
            (drop.charOffset + i * 3 + random.nextInt(5)) % chars.length;
        final char = random.nextDouble() < 0.02
            ? specialChars[random.nextInt(specialChars.length)]
            : chars[charIndex];

        final isHead = i == 0;
        final tailFactor = 1.0 - (i / drop.length);
        var alpha = config.opacity * tailFactor * drop.intensity;

        if (config.enableScanning) {
          final distanceToScan = ((y / size.height) - scanPosition).abs();
          if (distanceToScan < 0.05) {
            alpha *= 1.5;
          }
        }

        if (isHead) {
          alpha = config.opacity * 1.2;
        }

        if (config.enableGlow && isHead) {
          _drawGlow(canvas, x, y, baseColor, alpha);
        }

        final textPainter = TextPainter(
          text: TextSpan(
            text: char,
            style: TextStyle(
              color: baseColor.withOpacity(alpha),
              fontSize: isHead ? 18 : 16,
              fontWeight: isHead ? FontWeight.bold : FontWeight.normal,
              fontFamily: 'monospace',
              shadows: isHead && config.enableGlow
                  ? [
                      Shadow(
                        color: baseColor.withOpacity(0.8),
                        blurRadius: 8,
                      ),
                      Shadow(
                        color: baseColor.withOpacity(0.4),
                        blurRadius: 16,
                      ),
                    ]
                  : null,
            ),
          ),
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();
        textPainter.paint(canvas, Offset(x - textPainter.width / 2, y));

        if (random.nextDouble() < 0.01) {
          _drawPixelNoise(canvas, x, y, baseColor, alpha);
        }
      }
    }
  }

  void _drawGlow(Canvas canvas, double x, double y, Color color, double alpha) {
    final paint = Paint()
      ..color = color.withOpacity(alpha * 0.3)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 12);

    canvas.drawCircle(Offset(x, y + 8), 10, paint);
  }

  void _drawPixelNoise(
      Canvas canvas, double x, double y, Color color, double alpha) {
    final paint = Paint()..color = color.withOpacity(alpha * 0.5);

    for (int i = 0; i < 3; i++) {
      final offsetX = x + (random.nextDouble() - 0.5) * 4;
      final offsetY = y + (random.nextDouble() - 0.5) * 4;
      canvas.drawRect(
        Rect.fromLTWH(offsetX, offsetY, 2, 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CyberpunkMatrixPainter old) => true;
}

class ScanLinePainter extends CustomPainter {
  final double position;
  final Color color;

  ScanLinePainter({
    required this.position,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * position;

    // 主扫描线
    final paint = Paint()
      ..color = color.withOpacity(0.15)
      ..strokeWidth = 2
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 4);

    canvas.drawLine(
      Offset(0, y),
      Offset(size.width, y),
      paint,
    );

    // ✅ 修复：确保至少有2个颜色
    final glowPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, y - 20),
        Offset(0, y + 20),
        [
          color.withOpacity(0),
          color.withOpacity(0.05),
          color.withOpacity(0),
        ],
        [0.0, 0.5, 1.0], // ✅ 添加 stops 参数
      );

    canvas.drawRect(
      Rect.fromLTWH(0, y - 20, size.width, 40),
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(ScanLinePainter old) => position != old.position;
}
