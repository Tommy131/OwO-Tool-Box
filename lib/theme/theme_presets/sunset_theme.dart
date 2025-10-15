// ============================================================================
// 日落主题配置 - 温暖橙红色
// ============================================================================

import 'package:flutter/material.dart';
import 'base_theme.dart';

class SunsetTheme extends BaseTheme {
  static const Color _sunsetOrange = Color(0xFFFF6B35);
  static const Color _sunsetPink = Color(0xFFFF8C94);
  static const Color _sunsetPurple = Color(0xFF9B5DE5);

  @override
  ThemeColors get lightColors => const ThemeColors(
        primary: _sunsetOrange,
        secondary: _sunsetPink,
        tertiary: _sunsetPurple,
      );

  @override
  ThemeColors get darkColors => const ThemeColors(
        primary: _sunsetOrange,
        secondary: _sunsetPink,
        tertiary: _sunsetPurple,
        background: Color(0xFF1A1423),
        cardBackground: Color(0xFF2A1F3D),
      );

  @override
  ThemeStyles get themeStyles => const ThemeStyles.modern();

  static ThemeData get lightTheme => SunsetTheme().buildLightTheme();
  static ThemeData get darkTheme => SunsetTheme().buildDarkTheme();
}
