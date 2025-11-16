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
// 平板端布局 - 使用侧边导航栏 + 滚动支持
// ============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/navigation_provider.dart';
import '../i18n/app_localization.dart';
import '../i18n/localization_keys.dart';
import '../widgets/bars/custom_title_bar.dart';

class TabletLayout extends StatelessWidget {
  final List<Widget> pages;
  final List<NavigationRailDestination> destinations;
  const TabletLayout({
    super.key,
    required this.pages,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalization.of(context);
    final navigationProvider = Provider.of<NavigationProvider>(context);

    // 计算可用高度
    final hasCustomTitleBar =
        Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    final availableHeight = MediaQuery.of(context).size.height -
        (hasCustomTitleBar ? kToolbarHeight : 0);

    return Scaffold(
      body: Column(
        children: [
          if (hasCustomTitleBar)
            CustomTitleBar(title: localizations.translate(L18nKeys.appTitle)),
          Expanded(
            child: Row(
              children: [
                // 添加滚动支持的 NavigationRail
                SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: availableHeight + 15,
                    ),
                    child: IntrinsicHeight(
                      child: NavigationRail(
                        selectedIndex: navigationProvider.selectedIndex,
                        onDestinationSelected: (index) {
                          navigationProvider.setIndex(index);
                        },
                        labelType: NavigationRailLabelType.all,
                        leading: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Icon(
                            Icons.rocket_launch_rounded,
                            size: 40,
                            color: Theme.of(context).colorScheme.primary,
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
