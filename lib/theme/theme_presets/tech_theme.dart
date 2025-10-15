// ============================================================================
// 科技主题配置 - 赛博朋克风格
// ============================================================================

import 'package:flutter/material.dart';
import 'base_theme.dart';

class TechTheme extends BaseTheme {
  static const Color _techCyan = Color(0xFF00E5FF);
  static const Color _techPurple = Color(0xFFB400FF);
  static const Color _neonGreen = Color(0xFF39FF14);
  static const Color _darkBg = Color(0xFF0A0E27);
  static const Color _cardBg = Color(0xFF131829);

  @override
  ThemeColors get lightColors => const ThemeColors(
        primary: _techCyan,
        secondary: _techPurple,
        tertiary: Color(0xFFFF0080),
        onPrimary: Colors.black,
        onSecondary: Colors.white,
      );

  @override
  ThemeColors get darkColors => const ThemeColors(
        primary: _techCyan,
        secondary: _techPurple,
        tertiary: _neonGreen,
        background: _darkBg,
        surface: _darkBg,
        cardBackground: _cardBg,
        onPrimary: Colors.black, // ✅ 青色按钮上用黑色文字
        onSecondary: Colors.black,
      );

  @override
  ThemeStyles get themeStyles => const ThemeStyles.tech();

  static ThemeData get lightTheme => TechTheme().buildLightTheme();
  static ThemeData get darkTheme => TechTheme().buildDarkTheme();
}
