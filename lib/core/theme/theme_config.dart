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
// 主题配置管理
// ============================================================================

import 'package:flutter/material.dart';

import 'theme_presets/cyberpunk_theme.dart';
import 'theme_presets/default_theme.dart';
import 'theme_presets/tech_theme.dart';
import 'theme_presets/nature_theme.dart';
import 'theme_presets/sunset_theme.dart';
import 'theme_presets/ocean_theme.dart';

/// 主题类型枚举
enum ThemeType {
  defaultTheme,
  cyberpunk,
  tech,
  nature,
  sunset,
  ocean,
}

/// 主题配置类
class ThemeConfig {
  /// 所有可用的主题类型
  static const List<ThemeType> availableThemes = [
    ThemeType.defaultTheme,
    ThemeType.cyberpunk,
    ThemeType.tech,
    ThemeType.nature,
    ThemeType.sunset,
    ThemeType.ocean,
  ];

  /// 主题显示名称映射
  static const Map<ThemeType, String> themeNames = {
    ThemeType.defaultTheme: 'default_theme',
    ThemeType.cyberpunk: 'cyberpunk_theme',
    ThemeType.tech: 'tech_theme',
    ThemeType.nature: 'nature_theme',
    ThemeType.sunset: 'sunset_theme',
    ThemeType.ocean: 'ocean_theme',
  };

  /// 主题图标映射
  static const Map<ThemeType, IconData> themeIcons = {
    ThemeType.defaultTheme: Icons.palette_outlined,
    ThemeType.cyberpunk: Icons.memory_outlined,
    ThemeType.tech: Icons.computer_outlined,
    ThemeType.nature: Icons.nature_outlined,
    ThemeType.sunset: Icons.wb_twilight_outlined,
    ThemeType.ocean: Icons.water_outlined,
  };

  /// 获取浅色主题
  static ThemeData getLightTheme(ThemeType type) {
    switch (type) {
      case ThemeType.defaultTheme:
        return DefaultTheme.lightTheme;
      case ThemeType.cyberpunk:
        return CyberpunkTheme.lightTheme;
      case ThemeType.tech:
        return TechTheme.lightTheme;
      case ThemeType.nature:
        return NatureTheme.lightTheme;
      case ThemeType.sunset:
        return SunsetTheme.lightTheme;
      case ThemeType.ocean:
        return OceanTheme.lightTheme;
    }
  }

  /// 获取深色主题
  static ThemeData getDarkTheme(ThemeType type) {
    switch (type) {
      case ThemeType.defaultTheme:
        return DefaultTheme.darkTheme;
      case ThemeType.cyberpunk:
        return CyberpunkTheme.darkTheme;
      case ThemeType.tech:
        return TechTheme.darkTheme;
      case ThemeType.nature:
        return NatureTheme.darkTheme;
      case ThemeType.sunset:
        return SunsetTheme.darkTheme;
      case ThemeType.ocean:
        return OceanTheme.darkTheme;
    }
  }

  /// 从字符串解析主题类型
  static ThemeType parseThemeType(String value) {
    switch (value) {
      case 'cyberpunk':
        return ThemeType.cyberpunk;
      case 'tech':
        return ThemeType.tech;
      case 'nature':
        return ThemeType.nature;
      case 'sunset':
        return ThemeType.sunset;
      case 'ocean':
        return ThemeType.ocean;
      default:
        return ThemeType.defaultTheme;
    }
  }

  /// 获取主题类型的字符串表示
  static String getThemeTypeString(ThemeType type) {
    return type.toString().split('.').last;
  }
}
