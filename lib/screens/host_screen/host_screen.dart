/*
 *        _____   _          __  _____   _____   _       _____   _____
 *      /  _  \ | |        / / /  _  \ |  _  \ | |     /  _  \ /  ___|
 *      | | | | | |  __   / /  | | | | | |_| | | |     | | | | | |
 *      | | | | | | /  | / /   | | | | |  _  { | |     | | | | | |   _
 *      | |_| | | |/   |/ /    | |_| | | |_| | | |___  | |_| | | |_| |
 *      \_____/ |___/|___/     \_____/ |_____/ |_____| \_____/ \_____/
 *
 *  Copyright (c) 2023 by OwOTeam-DGMT (OwOBlog).
 * @Date         : 2025-10-12 19:11:52
 * @Author       : HanskiJay
 * @LastEditors  : HanskiJay
 * @LastEditTime : 2025-10-13 15:53:41
 * @E-Mail       : support@owoblog.com
 * @Telegram     : https://t.me/HanskiJay
 * @GitHub       : https://github.com/Tommy131
 */
import 'dart:async';
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:owo_system_tools/utils/logger.dart';
import 'package:provider/provider.dart';

import '../../models/app_settings.dart';
import '../../models/host_config.dart';
import '../../providers/system_provider.dart';
import '../../services/host_check_service.dart';
import '../../services/storage_service.dart';

import '../../utils/i18n/app_localization.dart';
import '../../utils/i18n/localization_keys.dart';
import 'alert_history_screen.dart';
import 'host_list_screen.dart';
import 'host_theme.dart';
import 'widgets/connection_dialog.dart';
import 'widgets/animated_background.dart';
import 'widgets/custom_app_bar.dart';
import 'widgets/dialogs.dart';
import 'widgets/states.dart';
import 'home_host_manager.dart';

class HostScreen extends StatefulWidget {
  const HostScreen({super.key});

  @override
  State<HostScreen> createState() => _HostScreenState();
}

class _HostScreenState extends State<HostScreen> with WidgetsBindingObserver {
  List<HostConfig> _savedHosts = [];
  bool _isLoadingHosts = true;
  bool _isCheckingHosts = false;
  bool _isConnected = false;
  late AppSettings _lastSettings;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SystemProvider>().initialize();
      _loadSavedHosts();
    });

    final provider = context.read<SystemProvider>();
    provider.addListener(_onProviderChanged);
    _lastSettings = provider.settings;
    _createTimer();
  }

  void _createTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(
      Duration(seconds: _lastSettings.hostCheckInterval),
      (_) => _checkAllHostsStatus(),
    );
  }

  void _onProviderChanged() {
    if (!mounted) return;
    AppLogger.debug("已收到处理器更新通知");
    final provider = context.read<SystemProvider>();
    final newSettings = provider.settings;

    if ((_lastSettings.hostCheckInterval != newSettings.hostCheckInterval)) {
      _createTimer();
    }

    setState(() {
      _isConnected = provider.connectionState == ConnectionState.connected &&
          provider.currentHost != null;
    });

    _lastSettings = newSettings;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadSavedHosts();
    }
  }

  Future<void> _loadSavedHosts() async {
    setState(() {
      _isLoadingHosts = true;
    });

    final storage = await StorageService.create();
    final hosts = await storage.getHosts();

    if (mounted) {
      setState(() {
        _savedHosts = hosts;
        _isLoadingHosts = false;
      });
    }
  }

  Future<void> _checkAllHostsStatus() async {
    if (_isCheckingHosts || _savedHosts.isEmpty) return;

    setState(() {
      _isCheckingHosts = true;
    });

    try {
      final provider = context.read<SystemProvider>();
      final settings = provider.settings;

      final updatedHosts = await HostCheckService.updateHostsStatus(
        _savedHosts,
        timeoutSeconds: settings.hostCheckTimeout,
      );

      if (mounted) {
        final storage = await StorageService.create();
        await storage.saveHosts(updatedHosts);

        setState(() {
          _savedHosts = updatedHosts;
          _isCheckingHosts = false;
        });

        /* final onlineCount =
            updatedHosts.where((h) => h.status == HostStatus.online).length;
        final offlineCount =
            updatedHosts.where((h) => h.status == HostStatus.offline).length;
        final authFailedCount =
            updatedHosts.where((h) => h.status == HostStatus.authFailed).length;

        String message = '检测完成：$onlineCount 在线';
        if (authFailedCount > 0) {
          message += ' / $authFailedCount Token错误';
        }
        if (offlineCount > 0) {
          message += ' / $offlineCount 离线';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: authFailedCount > 0 ? Colors.orange : Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        ); */
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingHosts = false;
        });

        /* ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('检测失败: $e'),
            backgroundColor: HostTheme.accentColor,
            behavior: SnackBarBehavior.floating,
          ),
        ); */
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalization.of(context);
    final provider = context.read<SystemProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final states = States(context, provider, isDark);
    states.cardColor = HostTheme.cardColor.withOpacity(isDark ? 1 : 0.55);
    final currentHost = provider.currentHost;

    return Scaffold(
      appBar: CustomAppBar(
        title: _buildAppBarTitle(localizations, provider, currentHost),
        actions: _buildAppBarActions(context),
      ),
      body: Stack(
        children: [
          const AnimatedBackground(),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Consumer<SystemProvider>(
                    builder: (context, provider, child) =>
                        _buildBody(provider, states),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  /// 构建 AppBar 标题
  String _buildAppBarTitle(
    AppLocalization localizations,
    SystemProvider provider,
    HostConfig? currentHost,
  ) {
    if (provider.connectionState == ConnectionState.disconnected) {
      return localizations.translate(L18nKeys.systemMonitorPage);
    }
    return (_isConnected && currentHost != null)
        ? '${localizations.translate(L18nKeys.systemMonitoring)}: ${currentHost.host}:${currentHost.port} (${currentHost.name})'
        : '等待数据中...';
  }

  /// 构建 AppBar 操作按钮列表
  List<Widget> _buildAppBarActions(BuildContext context) {
    return [
      _buildRefreshHostsButton(),
      const SizedBox(width: 5),
      _buildAlertHistoryButton(context),
      const SizedBox(width: 5),
      if (_isConnected) ...[
        _buildExitButton(),
        const SizedBox(width: 5),
      ] else ...[
        _buildHostListButton(context),
        const SizedBox(width: 5),
      ]
    ];
  }

  /// 构建刷新主机按钮
  Widget _buildRefreshHostsButton() {
    return Consumer<SystemProvider>(
      builder: (context, provider, child) {
        if (provider.connectionState == ConnectionState.disconnected &&
            _savedHosts.isNotEmpty) {
          return _buildActionButton(
            child: _isCheckingHosts
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.refresh, color: Colors.white),
            onPressed: _isCheckingHosts ? null : _checkAllHostsStatus,
            tooltip: '检测主机状态',
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  /// 构建告警历史按钮
  Widget _buildAlertHistoryButton(BuildContext context) {
    return Consumer<SystemProvider>(
      builder: (context, provider, child) {
        final unreadCount = provider.alertManager.unacknowledgedCount;
        return Stack(
          children: [
            _buildActionButton(
              child: const Icon(Icons.notifications, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AlertHistoryScreen(),
                  ),
                );
              },
              tooltip: '告警历史',
            ),
            if (unreadCount > 0) _buildBadge(unreadCount),
          ],
        );
      },
    );
  }

  /// 构建主机列表按钮
  Widget _buildHostListButton(BuildContext context) {
    return _buildActionButton(
      child: const Icon(Icons.storage, color: Colors.white),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HostListScreen()),
        ).then((_) => _loadSavedHosts());
      },
      tooltip: '主机列表',
    );
  }

  /// 构建退出按钮
  Widget _buildExitButton() {
    return _buildActionButton(
      child: const Icon(Icons.exit_to_app, color: Colors.white),
      onPressed: () => context.read<SystemProvider>().disconnect(),
      tooltip: '退出',
    );
  }

  /// 通用的操作按钮构建方法
  Widget _buildActionButton({
    required Widget child,
    required VoidCallback? onPressed,
    String? tooltip,
  }) {
    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: child,
      ),
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }

  /// 构建未读消息角标
  Widget _buildBadge(int count) {
    return Positioned(
      right: 8,
      top: 8,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
        constraints: const BoxConstraints(
          minWidth: 16,
          minHeight: 16,
        ),
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// 构建主体内容
  Widget _buildBody(SystemProvider provider, States states) {
    switch (provider.connectionState) {
      case ConnectionState.disconnected:
        return states.buildDisconnectedState(
          isLoadingHosts: _isLoadingHosts,
          savedHosts: _savedHosts,
          onShowConnectionDialog: _showConnectionDialog,
          onConnectToHost: _connectToHost,
        );
      case ConnectionState.connecting:
        return states.buildConnectingState();
      case ConnectionState.error:
        return states.buildErrorState(
          onReconnect: _reconnectToHost,
          onEditHost: _editHost,
        );
      default:
        return states.buildConnectedState();
    }
  }

  /// 构建悬浮操作按钮
  Widget _buildFloatingActionButton(BuildContext context) {
    return Consumer<SystemProvider>(
      builder: (context, provider, child) {
        if (provider.connectionState == ConnectionState.disconnected) {
          return FloatingActionButton(
            onPressed: _showConnectionDialog,
            backgroundColor: HostTheme.primaryColor,
            child: const Icon(Icons.add),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Future<void> _connectToHost(HostConfig host) async {
    await HomeHostManager.connectToHost(
      context: context,
      host: host,
      onSuccess: () => _loadSavedHosts(),
      onTimeout: () => Dialogs.showTimeoutDialog(
        context: context,
        host: host,
        onRetry: () => _connectToHost(host),
      ),
      onTokenError: () => Dialogs.showTokenErrorDialog(
        context: context,
        host: host,
        onEdit: () => _editHost(host),
      ),
    );
  }

  Future<void> _reconnectToHost(HostConfig host) async {
    await HomeHostManager.reconnectToHost(
      context: context,
      host: host,
      onSuccess: () => _loadSavedHosts(),
      onTimeout: () => Dialogs.showTimeoutDialog(
        context: context,
        host: host,
        onRetry: () => _reconnectToHost(host),
      ),
      onTokenError: () => Dialogs.showTokenErrorDialog(
        context: context,
        host: host,
        onEdit: () => _editHost(host),
      ),
    );
  }

  void _editHost(HostConfig host) {
    showDialog(
      context: context,
      builder: (context) => ConnectionDialog(initialConfig: host),
    ).then((_) => _loadSavedHosts());
  }

  void _showConnectionDialog() {
    showDialog(
      context: context,
      builder: (context) => const ConnectionDialog(),
    ).then((_) => _loadSavedHosts());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
}
