// ============================================================================
// 海洋主题配置 - 深海蓝色
// ============================================================================

import 'package:flutter/material.dart';
import 'base_theme.dart';

class OceanTheme extends BaseTheme {
  static const Color _seaFoam = Color(0xFF00B4D8);
  static const Color _oceanBlue = Color(0xFF30638E);
  static const Color _deepOcean = Color(0xFF003D5B);

  @override
  ThemeColors get lightColors => const ThemeColors(
        primary: _seaFoam,
        secondary: _oceanBlue,
        tertiary: _deepOcean,
      );

  @override
  ThemeColors get darkColors => const ThemeColors(
        primary: _seaFoam,
        secondary: _oceanBlue,
        tertiary: _deepOcean,
        background: Color(0xFF001219),
        cardBackground: Color(0xFF003D5B),
      );

  @override
  ThemeStyles get themeStyles => const ThemeStyles.modern();

  static ThemeData get lightTheme => OceanTheme().buildLightTheme();
  static ThemeData get darkTheme => OceanTheme().buildDarkTheme();
}
