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
        // background: Color(0xFFF5F5F5),
        surface: Colors.white,
        cardBackground: Colors.white,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
      );

  @override
  ThemeColors get darkColors => const ThemeColors(
        primary: _seaFoam,
        secondary: _oceanBlue,
        tertiary: _deepOcean,
        background: Color(0xFF002533),
        cardBackground: Color(0xFF003D5B),
      );

  @override
  ThemeStyles get themeStyles => const ThemeStyles.modern();

  static ThemeData get lightTheme => OceanTheme().buildLightTheme();
  static ThemeData get darkTheme => OceanTheme().buildDarkTheme();
}
