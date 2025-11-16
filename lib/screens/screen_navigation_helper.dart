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
// 屏幕导航助手
// ============================================================================

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart' hide Localizations;

import '../core/i18n/app_localization.dart';
import '../core/i18n/localization_keys.dart';
import '../core/test_screens/components_demo_screen.dart';
import '../core/test_screens/notification_demo_page.dart';
import '../core/test_screens/test_matrix_screen.dart';
import 'home_screen.dart';
import 'about_screen/about_screen.dart';
import 'settings_screen/settings_screen.dart';

import '../host_monitor/screens/host_monitor_screen.dart';
import '../ssl_manager/screens/ssl_home_screen.dart';

class NavigationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String labelKey;
  final Widget page;

  NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.labelKey,
    required this.page,
  });
}

class ScreenNavigationHelper {
  final List<NavigationItem> _navigationItems;
  final AppLocalization localizations;

  ScreenNavigationHelper({required this.localizations})
      : _navigationItems = [
          NavigationItem(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home,
            labelKey: L18nKeys.home,
            page: const HomeScreen(),
          ),
          // **Host Monitor
          NavigationItem(
            icon: Icons.monitor_outlined,
            selectedIcon: Icons.monitor,
            labelKey: L18nKeys.monitor,
            page: const HostMonitorScreen(),
          ),
          // **SSL Manager
          NavigationItem(
            icon: Icons.security_outlined,
            selectedIcon: Icons.security,
            labelKey: L18nKeys.ssl,
            page: const SSLHomeScreen(),
          ),
          NavigationItem(
            icon: Icons.info_outlined,
            selectedIcon: Icons.info,
            labelKey: L18nKeys.about,
            page: const AboutScreen(),
          ),
          NavigationItem(
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings,
            labelKey: L18nKeys.settings,
            page: const SettingsScreen(),
          ),
          // ------ TEST PAGE START ------
          if (kDebugMode) ...[
            NavigationItem(
              icon: Icons.extension_outlined,
              selectedIcon: Icons.extension,
              labelKey: 'components_demo',
              page: const ComponentsDemoScreen(),
            ),
            NavigationItem(
              icon: Icons.grid_view_outlined,
              selectedIcon: Icons.grid_view,
              labelKey: 'test_matrix',
              page: const TestMatrixScreen(),
            ),
            NavigationItem(
              icon: Icons.notifications_outlined,
              selectedIcon: Icons.notifications,
              labelKey: 'notification_demo',
              page: const NotificationDemoPage(),
            ),
          ],
          // ------ TEST PAGE END ------
        ];

  List<NavigationRailDestination> getRailDestinations() {
    return _navigationItems.map((item) {
      return NavigationRailDestination(
        icon: Icon(item.icon),
        selectedIcon: Icon(item.selectedIcon),
        label: Text(localizations.translate(item.labelKey)),
      );
    }).toList();
  }

  List<NavigationDestination> getDestinations() {
    return _navigationItems.map((item) {
      return NavigationDestination(
        icon: Icon(item.icon),
        selectedIcon: Icon(item.selectedIcon),
        label: localizations.translate(item.labelKey),
      );
    }).toList();
  }

  List<Widget> getPages() {
    return _navigationItems.map((item) => item.page).toList();
  }
}
