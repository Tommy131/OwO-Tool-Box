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
