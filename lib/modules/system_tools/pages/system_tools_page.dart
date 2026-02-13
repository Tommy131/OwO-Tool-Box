/*
 *        _____   _          __  _____   _____   _       _____   _____
 *      /  _  \ | |        / / /  _  \ |  _  \ | |     /  _  \ /  ___|
 *      | | | | | |  __   / /  | | | | | |_| | | |     | | | | | |
 *      | | | | | | /  | / /   | | | | |  _  { | |     | | | | | |   _
 *      | |_| | | |/   |/ /    | |_| | | |_| | | |___  | |_| | | |_| |
 *      \_____/ |___/|___/     \_____/ |_____/ |_____| \_____/ \_____/
 *
 *  Copyright (c) 2023 by OwOTeam-DGMT (OwOBlog).
 * @Date         : 2026-01-25 21:40:00
 * @Author       : HanskiJay
 * @LastEditors  : HanskiJay
 * @LastEditTime : 2026-01-25 21:40:00
 * @E-Mail       : support@owoblog.com
 * @Telegram     : https://t.me/HanskiJay
 * @GitHub       : https://github.com/Tommy131
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/localization_service.dart';

import '../localization/localization_keys.dart';
import '../providers/system_tools_provider.dart';
import 'shutdown_tab.dart';
import 'power_management_tab.dart';

/// 系统工具主页面
class SystemToolsPage extends StatefulWidget {
  const SystemToolsPage({super.key});

  @override
  State<SystemToolsPage> createState() => _SystemToolsPageState();
}

class _SystemToolsPageState extends State<SystemToolsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // 初始化 provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SystemToolsProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 检查是否为 Windows 系统
    if (!Platform.isWindows) {
      return Scaffold(
        appBar: _buildAppBar(theme),
        body: _buildUnsupportedPlatform(theme),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(theme),
      body: TabBarView(
        controller: _tabController,
        children: const [ShutdownTab(), PowerManagementTab()],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      elevation: 0,
      title: Platform.isWindows
          ? TabBar(
              controller: _tabController,
              indicatorWeight: 3,
              tabs: [
                Tab(
                  icon: const Icon(Icons.power_settings_new),
                  text: LocalizationKeys.shutdownTimer.tr(context),
                ),
                Tab(
                  icon: const Icon(Icons.battery_charging_full),
                  text: LocalizationKeys.powerManagement.tr(context),
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildUnsupportedPlatform(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 80,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            LocalizationKeys.platformNotSupported.tr(context),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            LocalizationKeys.platformNotSupportedMessage.tr(context),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
