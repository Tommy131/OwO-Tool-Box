/*
 *        _____   _          __  _____   _____   _       _____   _____
 *      /  _  \ | |        / / /  _  \ |  _  \ | |     /  _  \ /  ___|
 *      | | | | | |  __   / /  | | | | | |_| | | |     | | | | | |
 *      | | | | | | /  | / /   | | | | |  _  { | |     | | | | | |   _
 *      | |_| | | |/   |/ /    | |_| | | |_| | | |___  | |_| | | |_| |
 *      \_____/ |___/|___/     \_____/ |_____/ |_____| \_____/ \_____/
 *
 *  Copyright (c) 2023 by OwOTeam-DGMT (OwOBlog).
 * @Date         : 2026-01-30
 * @Author       : HanskiJay
 * @LastEditors  : HanskiJay
 * @LastEditTime : 2026-01-30
 * @E-Mail       : support@owoblog.com
 * @Telegram     : https://t.me/HanskiJay
 * @GitHub       : https://github.com/Tommy131
 */
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../localization/localization_keys.dart';
import '../../../../core/services/localization_service.dart';
import 'dashboard_controller.dart';
import 'widgets/animated_dashboard_background.dart';
import 'widgets/dashboard_device_details_card.dart';
import 'widgets/dashboard_hardware_info_card.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/dashboard_loading_state.dart';
import 'widgets/dashboard_stats_grid.dart';
import 'widgets/dashboard_system_info_card.dart';

/// 设备信息仪表板页面
/// 显示当前设备的详细信息，包括CPU、内存、系统等
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final DashboardController _controller;

  Future<void> _loadDeviceInfo() async {
    await _controller.refresh();
  }

  @override
  void initState() {
    super.initState();
    _controller = DashboardController();
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _tr(BuildContext context, String key) => key.tr(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AnimatedDashboardBackground(),
          ChangeNotifierProvider<DashboardController>.value(
            value: _controller,
            child: Consumer2<DashboardController, ThemeProvider>(
              builder: (context, controller, themeProvider, _) {
                final state = controller.state;
                final primaryColor = themeProvider.currentTheme.primaryColor;
                final platformLabel =
                    state.deviceData['platform'] ??
                    _tr(context, LocalizationKeys.unknownPlatform);

                return SafeArea(
                  child: state.isLoading
                      ? DashboardLoadingState(primaryColor: primaryColor)
                      : RefreshIndicator(
                          onRefresh: _loadDeviceInfo,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DashboardHeader(
                                  primaryColor: primaryColor,
                                  platformLabel: platformLabel,
                                  onRefresh: _loadDeviceInfo,
                                ),
                                const SizedBox(height: 24),
                                DashboardStatsGrid(
                                  deviceData: state.deviceData,
                                  systemData: state.systemData,
                                  primaryColor: primaryColor,
                                ),
                                const SizedBox(height: 24),
                                DashboardSystemInfoCard(
                                  deviceData: state.deviceData,
                                  systemData: state.systemData,
                                  primaryColor: primaryColor,
                                ),
                                const SizedBox(height: 24),
                                DashboardDeviceDetailsCard(
                                  deviceData: state.deviceData,
                                ),
                                if (state.systemData.isNotEmpty) ...[
                                  const SizedBox(height: 24),
                                  DashboardHardwareInfoCard(
                                    systemData: state.systemData,
                                  ),
                                ],
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
