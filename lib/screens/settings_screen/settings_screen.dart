// ============================================================================
// 设置页面内容
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../layouts/responsive_break_points.dart';
import '../../models/app_settings.dart';
import '../../models/system_monitor_settings.dart';
import '../../providers/locale_provider.dart';
import '../../providers/matrix_rain_provider.dart';
import '../../providers/system_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/theme_config.dart';
import '../../utils/i18n/app_localization.dart';
import '../../utils/i18n/language_config.dart';
import '../../utils/i18n/localization_keys.dart';
import 'system_monitor_settings_section.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  SystemMonitorSettings? _pendingMonitorSettings;
  bool _hasChanges = false;

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
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop
              ? 48
              : isTablet
                  ? 32
                  : 16),
          child: Center(
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
                  Text(
                    localizations.translate(L18nKeys.commonSettings),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildThemeModeSection(context),
                  const SizedBox(height: 16),
                  _buildThemeColorSection(context),
                  const SizedBox(height: 16),
                  _buildEffectsSection(context),
                  const SizedBox(height: 16),
                  _buildLanguageSection(context),
                  const SizedBox(height: 30),
                  Text(
                    localizations.translate(L18nKeys.hostMonitoringSettings),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSystemMonitorSection(context),
                  const SizedBox(height: 16),
                  if (_hasChanges) _buildSaveButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSystemMonitorSection(BuildContext context) {
    final systemProvider = Provider.of<SystemProvider>(context, listen: false);
    final settings = systemProvider.settings;
    final alertConfig = systemProvider.alertManager.config;

    final initialSettings = SystemMonitorSettings(
      refreshInterval: settings.refreshInterval,
      hostCheckTimeout: settings.hostCheckTimeout,
      hostCheckInterval: settings.hostCheckInterval,
      alertConfig: alertConfig,
    );

    return SystemMonitorSettingsSection(
      initialSettings: initialSettings,
      onSettingsChanged: (newSettings) {
        setState(() {
          _pendingMonitorSettings = newSettings;
          _hasChanges = true;
        });
      },
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    final localizations = AppLocalization.of(context);
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: _hasChanges
              ? LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [Colors.grey.shade700, Colors.grey.shade700],
                ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ElevatedButton(
          onPressed: _hasChanges ? _saveSettings : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            localizations.translate(L18nKeys.saveSettings),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Future<void> _saveSettings() async {
    if (_pendingMonitorSettings == null) return;

    final localizations = AppLocalization.of(context);
    final theme = Theme.of(context);
    final settings = _pendingMonitorSettings!;

    if (settings.refreshInterval < 1) {
      _showSnackBar(
        localizations.translate(L18nKeys.invalidRefreshInterval),
        theme.colorScheme.error,
      );
      return;
    }

    if (settings.hostCheckTimeout < 1 || settings.hostCheckTimeout > 60) {
      _showSnackBar(
        localizations.translate(L18nKeys.invalidHostCheckTimeout),
        theme.colorScheme.error,
      );
      return;
    }

    if (settings.hostCheckInterval < 1 || settings.hostCheckInterval > 1440) {
      _showSnackBar(
        localizations.translate(L18nKeys.invalidHostCheckInterval),
        theme.colorScheme.error,
      );
      return;
    }

    if (settings.refreshInterval > 60) {
      final confirmed = await _showConfirmDialog(
        localizations.translate(L18nKeys.longRefreshTitle),
        localizations
            .translate(L18nKeys.longRefreshContent)
            .replaceAll('{seconds}', settings.refreshInterval.toString()),
      );
      if (!confirmed) return;
    }

    final newAppSettings = AppSettings(
      refreshInterval: settings.refreshInterval,
      hostCheckTimeout: settings.hostCheckTimeout,
      hostCheckInterval: settings.hostCheckInterval,
    );

    if (mounted) {
      await context.read<SystemProvider>().updateSettings(newAppSettings);
      await context
          .read<SystemProvider>()
          .alertManager
          .updateConfig(settings.alertConfig);

      setState(() {
        _hasChanges = false;
        _pendingMonitorSettings = null;
      });

      _showSnackBar(
        localizations.translate(L18nKeys.settingsSaved),
        Colors.green,
      );
    }
  }

  Future<bool> _showConfirmDialog(String title, String content) async {
    final localizations = AppLocalization.of(context);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(localizations.translate(L18nKeys.cancel)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(localizations.translate(L18nKeys.ok)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

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
    final localizations = AppLocalization.of(context);
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
                '${localizations.translate(L18nKeys.themeColorSettings)}...'),
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
                  ],
                ),
              ),
            ],
          ],
        ),
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
                LanguageConfig.languageNames[locale.languageCode] ?? '',
                LanguageConfig.languageFlags[locale.languageCode] ?? '🌐',
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
    final isSelected = provider.locale?.languageCode == locale.languageCode;

    return ListTile(
      leading: Text(
        flag,
        style: const TextStyle(fontSize: 24),
      ),
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
                '${localizations.translate(L18nKeys.languageSettings)}...'),
            duration: const Duration(milliseconds: 500),
          ),
        );
        await provider.setLocale(locale);
      },
    );
  }
}
