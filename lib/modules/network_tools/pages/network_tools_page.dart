import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/localization_service.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/navigation/module_side_nav.dart';

import '../localization/localization_keys.dart';
import 'tabs/ping_tab.dart';
import 'tabs/perf_test_tab.dart';
import 'tabs/site_test_tab.dart';
import 'tabs/port_scan_tab.dart';

class NetworkToolsPage extends StatefulWidget {
  const NetworkToolsPage({super.key});

  @override
  State<NetworkToolsPage> createState() => _NetworkToolsPageState();
}

class _NetworkToolsPageState extends State<NetworkToolsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isNavExpanded = false;
  static const double _compactNavWidth = 68;
  static const double _expandedNavWidth = 200;
  static const double _navHeaderHeight = 60;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final useCompactNav = screenWidth < 1100;

    final content = TabBarView(
      controller: _tabController,
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        PingTab(),
        PerfTestTab(),
        SiteTestTab(),
        PortScanTab(),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ResponsiveSidebarShell(
        isCompact: useCompactNav,
        isExpanded: _isNavExpanded,
        compactWidth: _compactNavWidth,
        expandedWidth: _expandedNavWidth,
        content: content,
        onCollapse: () => setState(() => _isNavExpanded = false),
        buildPanel:
            ({
              required bool useCompactNav,
              required bool showLabel,
              required bool isFloating,
            }) => _buildNavPanel(
              useCompactNav: useCompactNav,
              showLabel: showLabel,
              isFloating: isFloating,
            ),
      ),
    );
  }

  Widget _buildNavPanel({
    required bool useCompactNav,
    required bool showLabel,
    bool isFloating = false,
  }) {
    final primaryColor = context
        .watch<ThemeProvider>()
        .currentTheme
        .primaryColor;
    final width = showLabel ? _expandedNavWidth : _compactNavWidth;
    return SidebarPanelContainer(
      width: width,
      isFloating: isFloating,
      onBlankTap: isFloating
          ? () => setState(() => _isNavExpanded = false)
          : null,
      topSlot: !showLabel
          ? _buildNavToggle(showLabel: showLabel, useCompactNav: useCompactNav)
          : (isFloating
                ? const SizedBox(height: _navHeaderHeight)
                : const SizedBox(height: 8)),
      children: [
        SidebarNavItemTile(
          icon: Icons.speed_rounded,
          label: LocalizationKeys.networkPing.tr(context),
          isSelected: _tabController.index == 0,
          primaryColor: primaryColor,
          showLabel: showLabel,
          onTap: () => _onNavSelect(0, useCompactNav, showLabel),
        ),
        SidebarNavItemTile(
          icon: Icons.bolt_rounded,
          label: LocalizationKeys.networkPerformanceTest.tr(context),
          isSelected: _tabController.index == 1,
          primaryColor: primaryColor,
          showLabel: showLabel,
          onTap: () => _onNavSelect(1, useCompactNav, showLabel),
        ),
        SidebarNavItemTile(
          icon: Icons.security_rounded,
          label: LocalizationKeys.networkSiteTest.tr(context),
          isSelected: _tabController.index == 2,
          primaryColor: primaryColor,
          showLabel: showLabel,
          onTap: () => _onNavSelect(2, useCompactNav, showLabel),
        ),
        SidebarNavItemTile(
          icon: Icons.lan_rounded,
          label: LocalizationKeys.networkPortScan.tr(context),
          isSelected: _tabController.index == 3,
          primaryColor: primaryColor,
          showLabel: showLabel,
          onTap: () => _onNavSelect(3, useCompactNav, showLabel),
        ),
      ],
    );
  }

  void _onNavSelect(int index, bool useCompactNav, bool showLabel) {
    setState(() => _tabController.index = index);
    if (useCompactNav && showLabel) {
      setState(() => _isNavExpanded = false);
    }
  }

  Widget _buildNavToggle({
    required bool showLabel,
    required bool useCompactNav,
  }) {
    return SidebarToggleButton(
      showLabel: showLabel,
      enabled: useCompactNav,
      isExpanded: _isNavExpanded,
      onPressed: () => setState(() => _isNavExpanded = !_isNavExpanded),
    );
  }
}
