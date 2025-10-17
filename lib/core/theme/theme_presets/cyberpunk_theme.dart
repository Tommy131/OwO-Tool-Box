// ============================================================================
// 赛博朋克主题配置 - 基于SSH Terminal的配色方案
// ============================================================================

import 'package:flutter/material.dart';
import 'base_theme.dart';

class CyberpunkTheme extends BaseTheme {
  static const Color _neonCyan = Color(0xFF00F0FF); // 霓虹青色
  static const Color _purpleGlow = Color(0xFF7B2FFF); // 紫色光晕
  static const Color _acidGreen = Color(0xFF00FF88); // 酸性绿
  static const Color _darkVoid = Color(0xFF0A0E27); // 深邃虚空
  static const Color _surfaceGlow = Color(0xFF1A1F3A); // 表面光泽
// 午夜蓝

  @override
  ThemeColors get lightColors => const ThemeColors(
        primary: _neonCyan,
        secondary: _purpleGlow,
        tertiary: _acidGreen,
        background: Color(0xFFF5F5F5),
        surface: Colors.white,
        cardBackground: Colors.white,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
      );

  @override
  ThemeColors get darkColors => const ThemeColors(
        primary: _neonCyan,
        secondary: _purpleGlow,
        tertiary: _acidGreen,
        background: _darkVoid,
        surface: _surfaceGlow,
        cardBackground: _surfaceGlow,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
      );

  @override
  ThemeStyles get themeStyles => const ThemeStyles.tech();

  static ThemeData get lightTheme => CyberpunkTheme().buildLightTheme();
  static ThemeData get darkTheme => CyberpunkTheme().buildDarkTheme();
}
