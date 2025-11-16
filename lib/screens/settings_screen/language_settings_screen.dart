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
// 语言设置页面
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/layouts/responsive_break_points.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/i18n/app_localization.dart';
import '../../core/i18n/language_config.dart';
import '../../core/i18n/localization_keys.dart';

class LanguageSettingsScreen extends StatelessWidget {
  final VoidCallback? onBack;

  const LanguageSettingsScreen({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalization.of(context);
    final responsiveBreakpoints = ResponsiveBreakpoints(context);
    final isMobile = responsiveBreakpoints.isMobile();
    final isDesktop = responsiveBreakpoints.isDesktop();
    final isTablet = responsiveBreakpoints.isTablet();

    return SafeArea(
      child: Column(
        children: [
          // 非移动端显示返回按钮
          if (!isMobile)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 48 : 32,
                vertical: 16,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: onBack,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    localizations.translate(L18nKeys.languageSettings),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isDesktop
                  ? 48
                  : isTablet
                      ? 32
                      : 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isDesktop
                      ? 800
                      : isTablet
                          ? 600
                          : double.infinity,
                ),
                child: _buildLanguageSection(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSection(BuildContext context) {
    final localizations = AppLocalization.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.language_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  localizations.translate(L18nKeys.selectLanguage),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...LanguageConfig.supportedLocales.map((locale) {
              return _buildLanguageOption(
                context,
                locale,
                LanguageConfig.getLanguageName(locale),
                LanguageConfig.getLanguageFlag(locale),
                localeProvider,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    Locale locale,
    String title,
    String flag,
    LocaleProvider provider,
  ) {
    final localizations = AppLocalization.of(context);
    final currentLocal = provider.locale ?? Localizations.localeOf(context);
    final isSelected = currentLocal == locale;

    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(title),
      trailing: isSelected
          ? Icon(
              Icons.check_circle_rounded,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
      onTap: () async {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${localizations.translate(L18nKeys.changingLanguage)}...'),
            duration: const Duration(milliseconds: 500),
          ),
        );
        await provider.setLocale(locale);
      },
    );
  }
}
