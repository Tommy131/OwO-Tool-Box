// ============================================================================
// 默认主题配置
// ============================================================================

import 'package:flutter/material.dart';
import 'base_theme.dart';

class DefaultTheme extends BaseTheme {
  @override
  ThemeColors get lightColors => const ThemeColors(
        primary: Colors.blue,
        secondary: Colors.blueAccent,
        tertiary: Colors.lightBlue,
        // background: Color(0xFFF5F5F5),
        surface: Colors.white,
        cardBackground: Colors.white,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
      );

  @override
  ThemeColors get darkColors => const ThemeColors(
        primary: Colors.blue,
        secondary: Colors.blueAccent,
        tertiary: Colors.lightBlue,
      );

  // 静态方法，使用实例方法构建
  static ThemeData get lightTheme => DefaultTheme().buildLightTheme();
  static ThemeData get darkTheme => DefaultTheme().buildDarkTheme();
}
