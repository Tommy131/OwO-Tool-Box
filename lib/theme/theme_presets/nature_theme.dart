// ============================================================================
// 自然主题配置 - 森林绿色
// ============================================================================

import 'package:flutter/material.dart';
import 'base_theme.dart';

class NatureTheme extends BaseTheme {
  static const Color _mossGreen = Color(0xFF8BC34A);
  static const Color _forestGreen = Color(0xFF2D5016);
  static const Color _earthBrown = Color(0xFF8D6E63);

  @override
  ThemeColors get lightColors => const ThemeColors(
        primary: _mossGreen,
        secondary: _earthBrown,
        tertiary: _forestGreen,
      );

  @override
  ThemeColors get darkColors => const ThemeColors(
        primary: _mossGreen,
        secondary: _earthBrown,
        tertiary: _forestGreen,
        background: Color(0xFF1B1B1B),
      );

  @override
  ThemeStyles get themeStyles => const ThemeStyles.modern();

  static ThemeData get lightTheme => NatureTheme().buildLightTheme();
  static ThemeData get darkTheme => NatureTheme().buildDarkTheme();
}
