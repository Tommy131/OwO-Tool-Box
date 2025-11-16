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
// 设置页面 - 主入口（带子页面导航）
// ============================================================================

import 'package:flutter/material.dart';

import '../../core/layouts/responsive_break_points.dart';
import '../../core/i18n/app_localization.dart';
import '../../core/i18n/localization_keys.dart';

import 'theme_settings_screen.dart';
import 'language_settings_screen.dart';
// Host Monitor
import '../../host_monitor/screens/host_monitor_settings_screen.dart';

// 定义设置页面类型枚举
enum SettingsPageType {
  main,
  theme,
  language,
  hostMonitor,
}

// 设置页面配置类
class SettingsPageConfig {
  final SettingsPageType type;
  final String Function(AppLocalization) title;
  final String Function(AppLocalization) subtitle;
  final IconData icon;
  final Widget Function(VoidCallback onBack) builder;

  const SettingsPageConfig({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.builder,
  });
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  SettingsPageType _currentPage = SettingsPageType.main;

  // 集中管理所有子页面配置
  static final List<SettingsPageConfig> _settingsPages = [
    SettingsPageConfig(
      type: SettingsPageType.theme,
      title: (localizations) => localizations.translate(L18nKeys.themeSettings),
      subtitle: (localizations) =>
          localizations.translate(L18nKeys.adjustTheme),
      icon: Icons.palette_rounded,
      builder: (onBack) => ThemeSettingsScreen(onBack: onBack),
    ),
    SettingsPageConfig(
      type: SettingsPageType.language,
      title: (localizations) =>
          localizations.translate(L18nKeys.languageSettings),
      subtitle: (localizations) =>
          localizations.translate(L18nKeys.selectAppLanguage),
      icon: Icons.g_translate_rounded,
      builder: (onBack) => LanguageSettingsScreen(onBack: onBack),
    ),
    SettingsPageConfig(
      type: SettingsPageType.hostMonitor,
      title: (localizations) =>
          localizations.translate(L18nKeys.hostMonitorSettings),
      subtitle: (localizations) =>
          localizations.translate(L18nKeys.configureHostMonitor),
      icon: Icons.monitor_heart_rounded,
      builder: (onBack) => HostMonitorSettingsScreen(onBack: onBack),
    ),
  ];

  void _navigateToPage(SettingsPageType page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _navigateBack() {
    setState(() {
      _currentPage = SettingsPageType.main;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalization.of(context);
    final isMobile = ResponsiveBreakpoints(context).isMobile();

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              leading: _currentPage != SettingsPageType.main
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _navigateBack,
                    )
                  : null,
              title: Text(_getPageTitle(localizations)),
            )
          : null,
      body: _buildPageContent(),
    );
  }

  String _getPageTitle(AppLocalization localizations) {
    if (_currentPage == SettingsPageType.main) {
      return localizations.translate(L18nKeys.settings);
    }

    // 从配置列表中查找对应页面的标题
    final config = _settingsPages.firstWhere(
      (page) => page.type == _currentPage,
      orElse: () => _settingsPages.first,
    );
    return config.title(localizations);
  }

  Widget _buildPageContent() {
    if (_currentPage == SettingsPageType.main) {
      return _buildMainSettings();
    }

    // 从配置列表中查找并构建对应页面
    final config = _settingsPages.firstWhere(
      (page) => page.type == _currentPage,
      orElse: () => _settingsPages.first,
    );
    return config.builder(_navigateBack);
  }

  Widget _buildMainSettings() {
    final localizations = AppLocalization.of(context);
    final responsiveBreakpoints = ResponsiveBreakpoints(context);
    final isMobile = responsiveBreakpoints.isMobile();
    final isDesktop = responsiveBreakpoints.isDesktop();
    final isTablet = responsiveBreakpoints.isTablet();

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop
            ? 48
            : isTablet
                ? 32
                : 16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
              /* maxWidth: isDesktop
                ? 800
                : isTablet
                    ? 600
                    : double.infinity, */
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
              // 遍历配置列表生成设置卡片
              ..._settingsPages.map((config) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildSettingCard(
                      context,
                      title: config.title(localizations),
                      subtitle: config.subtitle(localizations),
                      icon: config.icon,
                      onTap: () => _navigateToPage(config.type),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
