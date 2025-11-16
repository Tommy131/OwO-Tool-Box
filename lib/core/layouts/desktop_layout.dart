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
// 桌面端布局 - 使用扩展的侧边导航栏 + 窗口控制 + 滚动支持
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/navigation_provider.dart';
import '../i18n/app_localization.dart';
import '../i18n/localization_keys.dart';
import '../widgets/bars/custom_title_bar.dart';

class DesktopLayout extends StatelessWidget {
  final List<Widget> pages;
  final List<NavigationRailDestination> destinations;
  const DesktopLayout({
    super.key,
    required this.pages,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalization.of(context);
    final navigationProvider = Provider.of<NavigationProvider>(context);

    return Scaffold(
      body: Column(
        children: [
          CustomTitleBar(title: localizations.translate(L18nKeys.appTitle)),
          Expanded(
            child: Row(
              children: [
                // 添加滚动支持的 NavigationRail
                SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height -
                          kToolbarHeight + // 减去标题栏高度
                          15, // 加上减去之后的空白占位 = 15 pixels
                    ),
                    child: IntrinsicHeight(
                      child: NavigationRail(
                        extended: true,
                        selectedIndex: navigationProvider.selectedIndex,
                        onDestinationSelected: (index) {
                          navigationProvider.setIndex(index);
                        },
                        leading: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Column(
                            children: [
                              Icon(
                                Icons.rocket_launch_rounded,
                                size: 48,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                localizations.translate(L18nKeys.appTitle),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                        destinations: destinations,
                      ),
                    ),
                  ),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: pages[navigationProvider.selectedIndex],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
