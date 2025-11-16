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
// 国际化核心类
// ============================================================================

import 'package:flutter/material.dart';
import 'language_config.dart';

class AppLocalization {
  final Locale locale;

  AppLocalization(this.locale);

  static AppLocalization of(BuildContext context) {
    return Localizations.of<AppLocalization>(context, AppLocalization)!;
  }

  /// 翻译指定的键
  String translate(String key) {
    // 使用完整的 Locale 對象獲取翻譯
    final translations = LanguageConfig.getTranslations(locale);
    return translations[key] ?? key;
  }

  /// 获取当前语言的所有翻译
  Map<String, String> get currentTranslations {
    return LanguageConfig.getTranslations(locale);
  }

  /// 從 Locale 獲取對應的語言代碼（用於內部處理）
  static String getLanguageCodeFromLocale(Locale locale) {
    // 處理中文的特殊情況
    if (locale.languageCode == 'zh') {
      if (locale.countryCode == 'HK') {
        return 'hk'; // 香港繁體
      }
      return 'zh'; // 簡體中文（默認）
    }

    // 其他語言直接返回 languageCode
    return locale.languageCode;
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<AppLocalization> {
  const AppLocalizationDelegate();

  @override
  bool isSupported(Locale locale) {
    // 檢查是否在支援的語言列表中
    return LanguageConfig.supportedLocales.any(
      (supportedLocale) =>
          supportedLocale.languageCode == locale.languageCode &&
          (supportedLocale.countryCode == locale.countryCode ||
              locale.countryCode == null),
    );
  }

  @override
  Future<AppLocalization> load(Locale locale) async {
    return AppLocalization(locale);
  }

  @override
  bool shouldReload(AppLocalizationDelegate old) => false;
}
