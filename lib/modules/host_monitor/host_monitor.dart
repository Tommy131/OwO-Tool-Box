import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/module_registry/module_registrar.dart';
import '../../core/module_registry/module_registry.dart';
import '../../core/module_registry/navigation/navigation_item.dart';
import '../../core/services/localization_service.dart';

// localization
import 'localization/translations.dart';
import 'localization/localization_keys.dart';

import 'wizard/host_monitor_wizard_step.dart';

// providers
import 'providers/host_monitor_provider.dart';

// pages
import 'pages/host_monitor_page.dart';
import 'pages/host_monitor_settings_pages.dart';

class HostMonitor implements ModuleRegistrar {
  @override
  String get moduleName => 'host_monitor';

  @override
  void register() {
    final registry = ModuleRegistry();

    // 1. 注册国际化翻译
    LocalizationService().registerModuleTranslations(translations);

    // 2. 注册导航页面
    registry.navigation.register(
      (context) => NavigationItem(
        id: 'host_monitor',
        title: LocalizationKeys.navMonitor.tr(context),
        icon: Icons.monitor_outlined,
        activeIcon: Icons.monitor,
        page: const HostMonitorPage(),
        priority: 2,
      ),
    );

    // 3. 注册 HostMonitor 提供器
    registry.providers.register(
      ChangeNotifierProvider(create: (_) => HostMonitorProvider()),
    );

    // 4. 注册向导步骤
    registry.wizardSteps.register(
      'host_monitor_step',
      () => HostMonitorWizardStep(),
    );

    // 5. 注册设置页面
    registry.settingsPages.register(
      'host_monitor_settings',
      () => HostMonitorSettingsPage(),
    );
  }
}
