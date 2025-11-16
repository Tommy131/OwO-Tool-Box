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
        // background: Color(0xFFF5F5F5),
        surface: Colors.white,
        cardBackground: Colors.white,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
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
