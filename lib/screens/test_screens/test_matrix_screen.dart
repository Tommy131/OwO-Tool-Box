// ============================================================================
// Flutter 应用框架 - 主入口文件
// 版本: 2.4.0
// 说明: 支持 Matrix Rain 特效
// ============================================================================

import 'package:flutter/material.dart';

import '../../widgets/effects/matrix_rain.dart';

class TestMatrixScreen extends StatefulWidget {
  const TestMatrixScreen({super.key});

  @override
  State<TestMatrixScreen> createState() => _TestMatrixScreenState();
}

class _TestMatrixScreenState extends State<TestMatrixScreen> {
  bool _enableGlow = true;
  bool _enableScanning = true;
  bool _enableGlitch = true;
  double _opacity = 0.4;
  int _columns = 35;

  @override
  Widget build(BuildContext context) {
    return MatrixRain(
      config: MatrixRainConfig(
        columns: _columns,
        speed: 80,
        primaryColor: const Color(0xFF00F0FF),
        secondaryColor: const Color(0xFF7B2FFF),
        opacity: _opacity,
        enableGlow: _enableGlow,
        enableScanning: _enableScanning,
        enableGlitch: _enableGlitch,
      ),
      child: SafeArea(
        child: Column(
          children: [
            // 头部标题
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(
                    Icons.electric_bolt_rounded,
                    size: 80,
                    color: Color(0xFF00F0FF),
                    shadows: [
                      Shadow(
                        color: Color(0xFF00F0FF),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'CYBERPUNK MATRIX',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF00F0FF),
                      letterSpacing: 4,
                      shadows: [
                        Shadow(
                          color: const Color(0xFF00F0FF).withOpacity(0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '赛博朋克增强版代码雨特效',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // 控制面板
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Card(
                  color: const Color(0xFF1A1F3A).withOpacity(0.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(
                      color: Color(0xFF00F0FF),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitle('特效控制'),
                        const SizedBox(height: 16),
                        _buildSwitch(
                          '发光效果',
                          '头部字符霓虹发光',
                          _enableGlow,
                          (v) => setState(() => _enableGlow = v),
                        ),
                        _buildSwitch(
                          '扫描线',
                          '赛博朋克扫描动画',
                          _enableScanning,
                          (v) => setState(() => _enableScanning = v),
                        ),
                        _buildSwitch(
                          '故障效果',
                          '随机像素抖动',
                          _enableGlitch,
                          (v) => setState(() => _enableGlitch = v),
                        ),
                        const Divider(color: Color(0xFF00F0FF), height: 32),
                        _buildTitle('参数调整'),
                        const SizedBox(height: 16),
                        _buildSlider(
                          '不透明度',
                          _opacity,
                          0.1,
                          0.6,
                          '${(_opacity * 100).toInt()}%',
                          (v) => setState(() => _opacity = v),
                        ),
                        _buildSlider(
                          '列数',
                          _columns.toDouble(),
                          15,
                          50,
                          '$_columns',
                          (v) => setState(() => _columns = v.toInt()),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF00F0FF),
      ),
    );
  }

  Widget _buildSwitch(
      String title, String subtitle, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
      ),
      value: value,
      activeColor: const Color(0xFF00F0FF),
      onChanged: onChanged,
    );
  }

  Widget _buildSlider(
    String title,
    double value,
    double min,
    double max,
    String display,
    Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              display,
              style: const TextStyle(
                color: Color(0xFF00F0FF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: const Color(0xFF00F0FF),
          inactiveColor: const Color(0xFF00F0FF).withOpacity(0.3),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
