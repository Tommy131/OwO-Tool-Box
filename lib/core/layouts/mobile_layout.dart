// ============================================================================
// 手机端布局 - 使用底部导航栏
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/navigation_provider.dart';

class MobileLayout extends StatelessWidget {
  final List<Widget?> pages;
  final List<NavigationDestination> destinations;
  const MobileLayout({
    super.key,
    required this.pages,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);

    return Scaffold(
      body: pages[navigationProvider.selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationProvider.selectedIndex,
        onDestinationSelected: (index) {
          navigationProvider.setIndex(index);
        },
        destinations: destinations,
      ),
    );
  }
}
