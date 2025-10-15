// ============================================================================
// 主题管理Provider
// ============================================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/logger.dart';
import '../theme/theme_config.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeType _themeType = ThemeType.defaultTheme;
  SharedPreferences? _prefs;

  ThemeMode get themeMode => _themeMode;
  ThemeType get themeType => _themeType;

  /// 获取当前浅色主题
  ThemeData get lightTheme => ThemeConfig.getLightTheme(_themeType);

  /// 获取当前深色主题
  ThemeData get darkTheme => ThemeConfig.getDarkTheme(_themeType);

  ThemeProvider() {
    _loadTheme();
  }

  /// 从本地存储加载主题设置
  Future<void> _loadTheme() async {
    try {
      _prefs = await SharedPreferences.getInstance();

      // 加载主题模式（浅色/深色/系统）
      final themeModeString = _prefs?.getString('themeMode') ?? 'system';
      _themeMode = _parseThemeMode(themeModeString);

      // 加载主题类型（默认/科技/自然等）
      final themeTypeString = _prefs?.getString('themeType') ?? 'defaultTheme';
      _themeType = ThemeConfig.parseThemeType(themeTypeString);

      notifyListeners();
      AppLogger.info('主题加载成功: $_themeMode, $_themeType');
    } catch (e, stackTrace) {
      AppLogger.error('加载主题失败', e, stackTrace);
    }
  }

  /// 设置主题模式（浅色/深色/系统）
  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      _themeMode = mode;
      await _prefs?.setString('themeMode', mode.toString().split('.').last);
      notifyListeners();
      AppLogger.info('主题模式切换成功: $mode');
    } catch (e, stackTrace) {
      AppLogger.error('设置主题模式失败', e, stackTrace);
    }
  }

  /// 设置主题类型（默认/科技/自然等）
  Future<void> setThemeType(ThemeType type) async {
    try {
      _themeType = type;
      await _prefs?.setString(
          'themeType', ThemeConfig.getThemeTypeString(type));
      notifyListeners();
      AppLogger.info('主题类型切换成功: $type');
    } catch (e, stackTrace) {
      AppLogger.error('设置主题类型失败', e, stackTrace);
    }
  }

  ThemeMode _parseThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
