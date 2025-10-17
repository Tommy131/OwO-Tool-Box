// ============================================================================
// 设置页面内容
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../layouts/responsive_break_points.dart';
import '../providers/locale_provider.dart';
import '../providers/matrix_rain_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/theme_config.dart';
import '../i18n/app_localization.dart';
import '../i18n/language_config.dart';
import '../i18n/localization_keys.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalization.of(context);
    final isMobile = ResponsiveBreakpoints.isMobile(context);
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);
    final isTablet = ResponsiveBreakpoints.isTablet(context);

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: Text(localizations.translate(L18nKeys.settings)),
            )
          : null,
      body: SafeArea(
        child: Center(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMobile) ...[
                    Text(
                      localizations.translate(L18nKeys.settings),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 24),
                  ],
                  _buildThemeModeSection(context),
                  const SizedBox(height: 16),
                  _buildThemeColorSection(context),
                  const SizedBox(height: 16),
                  _buildEffectsSection(context), // ✅ 新增特效设置
                  const SizedBox(height: 16),
                  _buildLanguageSection(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 主题模式选择区域（浅色/深色/系统）
  Widget _buildThemeModeSection(BuildContext context) {
    final localizations = AppLocalization.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.brightness_6_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  localizations.translate(L18nKeys.themeSettings),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildThemeModeOption(
              context,
              ThemeMode.light,
              localizations.translate(L18nKeys.lightTheme),
              Icons.light_mode_rounded,
              themeProvider,
            ),
            _buildThemeModeOption(
              context,
              ThemeMode.dark,
              localizations.translate(L18nKeys.darkTheme),
              Icons.dark_mode_rounded,
              themeProvider,
            ),
            _buildThemeModeOption(
              context,
              ThemeMode.system,
              localizations.translate(L18nKeys.systemTheme),
              Icons.brightness_auto_rounded,
              themeProvider,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeModeOption(
    BuildContext context,
    ThemeMode mode,
    String title,
    IconData icon,
    ThemeProvider provider,
  ) {
    final isSelected = provider.themeMode == mode;

    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: isSelected
          ? Icon(
              Icons.check_circle_rounded,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
      onTap: () => provider.setThemeMode(mode),
    );
  }

  /// 主题配色选择区域（默认/科技/自然等）
  Widget _buildThemeColorSection(BuildContext context) {
    final localizations = AppLocalization.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.color_lens_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  localizations.translate(L18nKeys.themeColorSettings),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...ThemeConfig.availableThemes.map((type) {
              final themeKey = ThemeConfig.themeNames[type] ?? 'default_theme';
              return _buildThemeColorOption(
                context,
                type,
                localizations.translate(themeKey),
                ThemeConfig.themeIcons[type] ?? Icons.palette_outlined,
                themeProvider,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeColorOption(
    BuildContext context,
    ThemeType type,
    String title,
    IconData icon,
    ThemeProvider provider,
  ) {
    final isSelected = provider.themeType == type;

    return ListTile(
      leading: Icon(icon),
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
                '${AppLocalization.of(context).translate(L18nKeys.themeColorSettings)}...'),
            duration: const Duration(milliseconds: 500),
          ),
        );
        await provider.setThemeType(type);
      },
    );
  }

  Widget _buildEffectsSection(BuildContext context) {
    final localizations = AppLocalization.of(context);
    final matrixRainProvider = Provider.of<MatrixRainProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isCyberpunk = themeProvider.themeType == ThemeType.cyberpunk;
    final showMatrixRainOption = isCyberpunk && isDark;

    if (!showMatrixRainOption) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  localizations.translate(L18nKeys.visualEffects),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              localizations.translate(L18nKeys.visualEffectsDescription),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                  ),
            ),
            const SizedBox(height: 16),

            // 主开关
            SwitchListTile(
              secondary: Icon(
                Icons.water_drop_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(localizations.translate(L18nKeys.matrixRainEffect)),
              subtitle: Text(
                localizations.translate(L18nKeys.matrixRainDescription),
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                ),
              ),
              value: matrixRainProvider.isEnabled,
              onChanged: (value) async {
                await matrixRainProvider.setMatrixRain(value);
              },
            ),

            // 子选项（仅在启用时显示）
            if (matrixRainProvider.isEnabled) ...[
              const Divider(height: 24),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: Icon(
                        Icons.lightbulb_outline_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      title: Text(
                        localizations.translate(L18nKeys.glowEffect),
                        style: const TextStyle(fontSize: 14),
                      ),
                      subtitle: Text(
                        localizations.translate(L18nKeys.glowEffectDescription),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? Colors.grey.shade500
                              : Colors.grey.shade600,
                        ),
                      ),
                      value: matrixRainProvider.enableGlow,
                      onChanged: (value) => matrixRainProvider.setGlow(value),
                      dense: true,
                    ),
                    SwitchListTile(
                      secondary: Icon(
                        Icons.horizontal_rule_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      title: Text(
                        localizations.translate(L18nKeys.scanningLine),
                        style: const TextStyle(fontSize: 14),
                      ),
                      subtitle: Text(
                        localizations
                            .translate(L18nKeys.scanningLineDescription),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? Colors.grey.shade500
                              : Colors.grey.shade600,
                        ),
                      ),
                      value: matrixRainProvider.enableScanning,
                      onChanged: (value) =>
                          matrixRainProvider.setScanning(value),
                      dense: true,
                    ),
                    SwitchListTile(
                      secondary: Icon(
                        Icons.bubble_chart_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      title: Text(
                        localizations.translate(L18nKeys.glitchEffect),
                        style: const TextStyle(fontSize: 14),
                      ),
                      subtitle: Text(
                        localizations
                            .translate(L18nKeys.glitchEffectDescription),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? Colors.grey.shade500
                              : Colors.grey.shade600,
                        ),
                      ),
                      value: matrixRainProvider.enableGlitch,
                      onChanged: (value) => matrixRainProvider.setGlitch(value),
                      dense: true,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 语言选择区域
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
                  localizations.translate(L18nKeys.languageSettings),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...LanguageConfig.supportedLocales.map((locale) {
              return _buildLanguageOption(
                context,
                locale,
                LanguageConfig.getLanguageName(locale.languageCode),
                LanguageConfig.getLanguageFlag(locale.languageCode),
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
    final currentLanguageCode = provider.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;
    final isSelected = currentLanguageCode == locale.languageCode;

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
                '${AppLocalization.of(context).translate(L18nKeys.languageSettings)}...'),
            duration: const Duration(milliseconds: 500),
          ),
        );
        await provider.setLocale(locale);
      },
    );
  }
}
