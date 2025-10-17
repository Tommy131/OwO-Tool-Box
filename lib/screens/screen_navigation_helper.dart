// ============================================================================
// 屏幕导航助手
// ============================================================================

import 'package:flutter/material.dart' hide Localizations;
import 'package:owo_system_tools/screens/host_screen/host_screen.dart';

import '../utils/i18n/app_localization.dart';
import '../utils/i18n/localization_keys.dart';

import 'about_screen/about_screen.dart';
import 'settings_screen/settings_screen.dart';
import 'home_screen.dart';
// import 'test_screens/components_demo_screen.dart';
// import 'test_screens/test_matrix_screen.dart';

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
          /* NavigationItem(
            icon: Icons.extension_outlined,
            selectedIcon: Icons.extension,
            labelKey: 'components_demo_page',
            page: const ComponentsDemoScreen(),
          ),
          NavigationItem(
            icon: Icons.grid_view_outlined,
            selectedIcon: Icons.grid_view,
            labelKey: 'test_matrix_page',
            page: const TestMatrixScreen(),
          ), */
          // --- START SCREEN NAVIGATION AREA ---
          NavigationItem(
            icon: Icons.computer_outlined,
            selectedIcon: Icons.computer,
            labelKey: L18nKeys.monitor,
            page: const HostScreen(),
          ),
          // --- END SCREEN NAVIGATION AREA ---
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
