// ============================================================================
// 语言配置管理
// ============================================================================

import 'package:flutter/material.dart';
import 'languages/es_ES.dart';
import 'languages/fr_FR.dart';
import 'languages/zh_CN.dart';
import 'languages/en_US.dart';
import 'languages/de_DE.dart';
import 'languages/ja_JP.dart';

class LanguageConfig {
  // 支持的语言列表
  static const List<String> supportedLanguages = [
    'zh',
    'en',
    'de',
    'ja',
    'fr',
    'es',
  ];

  // 支持的Locale列表
  static const List<Locale> supportedLocales = [
    Locale('zh', 'CN'),
    Locale('en', 'US'),
    Locale('de', 'DE'),
    Locale('ja', 'JP'),
    Locale('fr', 'FR'),
    Locale('es', 'ES'),
  ];

  // 语言显示名称映射
  static const Map<String, String> languageNames = {
    'zh': '简体中文',
    'en': 'English',
    'de': 'Deutsch',
    'ja': '日本語',
    'fr': 'Français',
    'es': 'Español',
  };

  // 获取指定语言的翻译
  static Map<String, String> getTranslations(String languageCode) {
    switch (languageCode) {
      case 'zh':
        return ZhCN.translations;
      case 'en':
        return EnUS.translations;
      case 'de':
        return DeDE.translations;
      case 'ja':
        return JaJP.translations;
      case 'fr':
        return FrFR.translations;
      case 'es':
        return EsES.translations;
      default:
        return ZhCN.translations; // 默认返回中文
    }
  }

  // 根据语言代码获取Locale
  static Locale getLocaleFromLanguageCode(String languageCode) {
    switch (languageCode) {
      case 'zh':
        return const Locale('zh', 'CN');
      case 'en':
        return const Locale('en', 'US');
      case 'de':
        return const Locale('de', 'DE');
      case 'ja':
        return const Locale('ja', 'JP');
      case 'fr':
        return const Locale('fr', 'FR');
      case 'es':
        return const Locale('es', 'ES');
      default:
        return const Locale('zh', 'CN');
    }
  }

  // 获取语言显示名称
  static String getLanguageName(String languageCode) {
    return languageNames[languageCode] ?? languageCode;
  }

  // 获取语言的本地化显示名称（用于语言选择器）
  static String getLocalizedLanguageName(String languageCode) {
    final translations = getTranslations(languageCode);
    switch (languageCode) {
      case 'zh':
        return translations['chinese'] ?? '简体中文';
      case 'en':
        return translations['english'] ?? 'English';
      case 'de':
        return 'Deutsch';
      case 'ja':
        return '日本語';
      case 'fr':
        return 'Français';
      case 'es':
        return 'Español';
      default:
        return languageCode;
    }
  }

  // 语言旗帜映射
  static const Map<String, String> languageFlags = {
    'zh': '🇨🇳',
    'en': '🇺🇸',
    'de': '🇩🇪',
    'ja': '🇯🇵',
    'fr': '🇫🇷',
    'es': '🇪🇸',
    'ru': '🇷🇺',
    'ko': '🇰🇷',
    'it': '🇮🇹',
    'pt': '🇵🇹',
    'ar': '🇸🇦',
    'hi': '🇮🇳',
  };

  // 获取语言旗帜
  static String getLanguageFlag(String languageCode) {
    return languageFlags[languageCode] ?? '🌐';
  }
}
