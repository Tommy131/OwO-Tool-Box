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
