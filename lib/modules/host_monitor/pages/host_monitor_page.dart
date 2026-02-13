/*
 *        _____   _          __  _____   _____   _       _____   _____
 *      /  _  \ | |        / / /  _  \ |  _  \ | |     /  _  \ /  ___|
 *      | | | | | |  __   / /  | | | | | |_| | | |     | | | | | |
 *      | | | | | | /  | / /   | | | | |  _  { | |     | | | | | |   _
 *      | |_| | | |/   |/ /    | |_| | | |_| | | |___  | |_| | | |_| |
 *      \_____/ |___/|___/     \_____/ |_____/ |_____| \_____/ \_____/
 *
 *  Copyright (c) 2023 by OwOTeam-DGMT (OwOBlog).
 * @Date         : 2025-10-12 23:25:59
 * @Author       : HanskiJay
 * @LastEditors  : HanskiJay
 * @LastEditTime : 2025-10-12 23:25:59
 * @E-Mail       : support@owoblog.com
 * @Telegram     : https://t.me/HanskiJay
 * @GitHub       : https://github.com/Tommy131
 */
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:provider/provider.dart';

import '../../../core/theme/theme_provider.dart';
import '../../../core/utils/logger.dart';
import '../../../core/localization/localization_keys.dart' as core_l10n;
import '../../../core/services/localization_service.dart';
import '../../../core/widgets/common/dialog.dart';
import '../localization/localization_keys.dart' as host_l10n;
import '../models/host_model.dart';
import '../providers/host_monitor_provider.dart';
import '../services/host_service.dart';
import '../services/geoip_service.dart';
import '../widgets/animated_background.dart';
import '../widgets/custom_snack_bar.dart';
import '../widgets/host_monitor/host_cards.dart';
import 'alert_history_page.dart';
import 'host_details_page.dart';
import 'host_edit_page.dart';

/// 主机列表页面
class HostMonitorPage extends StatefulWidget {
  const HostMonitorPage({super.key});

  @override
  State<HostMonitorPage> createState() => _HostMonitorPageState();
}

class _HostMonitorPageState extends State<HostMonitorPage> {
  late List<HostModel> _hosts;
  late Map<String, GeoIPInfo?> _geoInfoMap;
  late HostMonitorProvider _provider;

  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _isLoadingGeoInfo = false;
  String? _errorMessage;

  bool _isConnecting = false;
  bool _isConnected = false;

  // 国际化翻译简化方法
  String _tr(String key) => LocalizationService().translate(key);

  @override
  void initState() {
    super.initState();
    _provider = context.read<HostMonitorProvider>();

    _hosts = [];
    _geoInfoMap = {};
    _loadHosts();
    _checkConnection();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.addListener(_onProviderStateChanged);
    });
  }

  // Provider 状态变化回调
  void _onProviderStateChanged() {
    // 检测到断开连接
    if (!_provider.isConnected && !_provider.isConnecting && _isConnected) {
      AppLogger.debug('[HostMonitorPage] 检测到连接断开,返回主机列表');

      _updateState(() {
        _isConnecting = false;
        _isConnected = false;
      });

      // 显示断开提示
      if (mounted && _provider.errorMessage != null) {
        CustomSnackBar(
          context,
          message: _provider.errorMessage!,
          backgroundColor: Colors.red.shade700,
          icon: Icons.error_outline,
          duration: const Duration(seconds: 3),
        ).showModern();
      }
    }
    // 同步连接状态
    else if (_provider.isConnected != _isConnected ||
        _provider.isConnecting != _isConnecting) {
      _updateState(() {
        _isConnecting = _provider.isConnecting;
        _isConnected = _provider.isConnected;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _provider = context.read<HostMonitorProvider>();
  }

  @override
  void dispose() {
    _provider.removeListener(_onProviderStateChanged);

    super.dispose();
  }

  /// 加载主机列表
  Future<void> _loadHosts() async {
    _updateState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final hosts = await _provider.getSavedHosts();

      _updateState(() {
        _hosts = hosts;
        _isLoading = false;
      });

      _loadGeoInfo();
      _refreshHostsStatus();
    } catch (e) {
      _handleError('${_tr(host_l10n.LocalizationKeys.loadHostListFailed)}: $e');
    }
  }

  /// 加载地理位置信息
  Future<void> _loadGeoInfo() async {
    if (_isLoadingGeoInfo || _hosts.isEmpty) return;

    _updateState(() => _isLoadingGeoInfo = true);

    try {
      final ipsToFetch = _hosts
          .map((h) => h.address)
          .where((ip) => !_geoInfoMap.containsKey(ip))
          .toList();

      if (ipsToFetch.isEmpty) {
        _updateState(() => _isLoadingGeoInfo = false);
        return;
      }

      final geoInfos = await _provider.geoIPService.batchGetGeoInfo(ipsToFetch);
      _updateState(() {
        _geoInfoMap.addAll(geoInfos);
        _isLoadingGeoInfo = false;
      });
    } catch (e) {
      debugPrint('${_tr(host_l10n.LocalizationKeys.loadGeoInfoFailed)}: $e');
      _updateState(() => _isLoadingGeoInfo = false);
    }
  }

  /// 刷新主机状态
  Future<void> _refreshHostsStatus() async {
    if (_isRefreshing || _hosts.isEmpty) return;

    _updateState(() {
      _isRefreshing = true;
      _errorMessage = null;
    });

    try {
      final updatedHosts = await HostService.updateHostsStatus(
        _hosts,
        timeoutSeconds: 3,
        batchSize: 5,
      );

      _updateState(() {
        _hosts = updatedHosts;
        _isRefreshing = false;
      });

      if (mounted) {
        CustomSnackBar(
          context,
          message: _tr(host_l10n.LocalizationKeys.hostStatusRefreshed),
          backgroundColor: Colors.green.shade700,
          icon: Icons.check_circle_outline,
        ).showModern();
      }
    } catch (e) {
      _handleError('${_tr(host_l10n.LocalizationKeys.refreshFailed)}: $e');
    }
  }

  /// 检查连接缓存
  void _checkConnection() {
    if (_provider.currentHost != null) {
      _updateState(() {
        _isConnecting = _provider.isConnecting;
        _isConnected = _provider.isConnected;
      });
    }
  }

  /// 处理错误
  void _handleError(String error) {
    _updateState(() {
      _isRefreshing = false;
      _errorMessage = error;
    });
    CustomSnackBar(
      context,
      message: error,
      backgroundColor: Colors.red.shade700,
      icon: Icons.error_outline,
      duration: const Duration(seconds: 3),
    ).showModern();
  }

  /// 安全更新状态
  void _updateState(VoidCallback callback) {
    if (mounted) {
      setState(callback);
    }
  }

  /// 导航并刷新
  Future<void> _navigateAndRefresh(Widget screen) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
    if (result == true) _loadHosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Stack(children: [const AnimatedBackground(), _buildBody()]),
      floatingActionButton: (!_isConnected)
          ? FloatingActionButton.extended(
              onPressed: () => _navigateAndRefresh(const HostEditPage()),
              tooltip: _tr(host_l10n.LocalizationKeys.addHost),
              icon: const Icon(Icons.add_rounded),
              label: Text(_tr(host_l10n.LocalizationKeys.addHost)),
              elevation: 4,
            )
          : null,
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final hostName = _provider.currentHost != null
        ? _provider.currentHost!.name
        : _tr(host_l10n.LocalizationKeys.hostMonitor);

    return AppBar(
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.dns, size: 20),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              hostName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      actions: [
        _buildAlertButton(),
        if (!_provider.isConnecting && !_provider.isConnected) ...[
          _buildIconButton(
            icon: _isRefreshing
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  )
                : const Icon(Icons.refresh_rounded),
            onPressed: _isRefreshing ? null : _refreshHostsStatus,
            tooltip: _tr(host_l10n.LocalizationKeys.refreshHostStatus),
            loading: _isRefreshing,
          ),
        ] else ...[
          _buildExitButton(),
        ],
        const SizedBox(width: 6),
      ],
    );
  }

  Widget _buildIconButton({
    required Widget icon,
    required VoidCallback? onPressed,
    required String tooltip,
    bool loading = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: loading
          ? BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      child: IconButton(icon: icon, onPressed: onPressed, tooltip: tooltip),
    );
  }

  Widget _buildAlertButton() {
    return Container(
      margin: const EdgeInsets.only(left: 4, right: 8),
      child: Consumer<HostMonitorProvider>(
        builder: (context, provider, _) {
          final count = _provider.alertService.unacknowledgedCount;
          return Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AlertHistoryPage()),
                ),
                tooltip: _tr(host_l10n.LocalizationKeys.alertHistory),
              ),
              if (count > 0)
                Positioned(right: 6, top: 6, child: _buildBadge(count)),
            ],
          );
        },
      ),
    );
  }

  /// 断开主机连接按钮
  Widget _buildExitButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: IconButton(
        icon: const Icon(Icons.exit_to_app_outlined),
        onPressed: _onDisconnect,
        tooltip: _tr(host_l10n.LocalizationKeys.disconnect),
      ),
    );
  }

  Widget _buildBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red.shade600,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.4),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return _buildLoadingState();
    if (_isConnecting) return _buildConnectingState();
    if (_hosts.isEmpty) return _buildEmptyState();
    if (_isConnected) {
      return HostDetailPage(onDisconnect: _onDisconnect);
    }

    return Column(
      children: [
        if (_errorMessage != null)
          _buildBanner(
            message: _errorMessage!,
            icon: Icons.error_outline_rounded,
            color: Colors.red,
            onClose: () => _updateState(() => _errorMessage = null),
          ),
        if (_isLoadingGeoInfo)
          _buildBanner(
            message: _tr(host_l10n.LocalizationKeys.loadingGeoInfo),
            icon: Icons.info_outline_rounded,
            color: Colors.blue,
            isLoading: true,
          ),
        _buildStatsBar(),
        Expanded(child: _buildHostList()),
      ],
    );
  }

  Widget _buildLoadingState() {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            _tr(host_l10n.LocalizationKeys.loadingHostList),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            _tr(host_l10n.LocalizationKeys.connecting),
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            _tr(host_l10n.LocalizationKeys.pleaseWait),
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);

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
              Icons.computer_outlined,
              size: 80,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _tr(host_l10n.LocalizationKeys.noSavedHosts),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _tr(host_l10n.LocalizationKeys.clickToAddFirstHost),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: () => _navigateAndRefresh(const HostEditPage()),
            icon: const Icon(Icons.add_rounded),
            label: Text(_tr(host_l10n.LocalizationKeys.addNow)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner({
    required String message,
    required IconData icon,
    required Color color,
    bool isLoading = false,
    VoidCallback? onClose,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        children: [
          isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                )
              : Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(color: color),
            ),
          ),
          if (onClose != null)
            IconButton(
              icon: Icon(Icons.close_rounded, size: 20, color: color),
              onPressed: onClose,
              constraints: const BoxConstraints(maxWidth: 24, maxHeight: 24),
              padding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(children: _buildStatItems()),
    );
  }

  List<Widget> _buildStatItems() {
    final theme = Theme.of(context);

    final stats = {
      'total': _hosts.length,
      'online': _hosts.where((h) => h.status == HostStatus.online).length,
      'offline': _hosts.where((h) => h.status == HostStatus.offline).length,
      'error': _hosts
          .where(
            (h) =>
                h.status == HostStatus.authFailed ||
                h.status == HostStatus.unknown,
          )
          .length,
    };

    final items = [
      (
        _tr(host_l10n.LocalizationKeys.total),
        stats['total']!,
        Icons.dns_rounded,
        Colors.blue,
      ),
      (
        _tr(host_l10n.LocalizationKeys.online),
        stats['online']!,
        Icons.check_circle_rounded,
        Colors.green,
      ),
      (
        _tr(host_l10n.LocalizationKeys.offline),
        stats['offline']!,
        Icons.cancel_rounded,
        Colors.grey,
      ),
      if (stats['error']! > 0)
        (
          _tr(host_l10n.LocalizationKeys.error),
          stats['error']!,
          Icons.warning_rounded,
          Colors.red,
        ),
    ];

    final widgets = <Widget>[];

    for (var i = 0; i < items.length; i++) {
      widgets.add(
        Expanded(
          child: _buildStatItem(
            label: items[i].$1,
            value: items[i].$2.toString(),
            icon: items[i].$3,
            color: items[i].$4,
          ),
        ),
      );

      // 添加分隔线（除了最后一项）
      if (i < items.length - 1) {
        widgets.add(Container(width: 1, height: 40, color: theme.dividerColor));
      }
    }

    return widgets;
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildHostList() {
    return RefreshIndicator(
      onRefresh: _refreshHostsStatus,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: _hosts.length,
        itemBuilder: (_, index) => HostCards(
          host: _hosts[index],
          geoInfo: _geoInfoMap[_hosts[index].address],
          onTap: () async {
            _updateState(() {
              _isConnecting = true;
            });
            await _connectToHost(_hosts[index]);
          },
          onEdit: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HostEditPage(
                  host: _hosts[index],
                  callback: () async {
                    await _loadHosts();
                  },
                ),
              ),
            );
          },
          onDelete: () async {
            final host = _hosts[index];
            final confirm = await showAdvancedConfirmDialog(
              context: context,
              style: ConfirmDialogStyle.material,
              title: _tr(host_l10n.LocalizationKeys.confirmDelete),
              content:
                  '${_tr(host_l10n.LocalizationKeys.confirmDeleteHostPart1)} "${host.name}" ${_tr(host_l10n.LocalizationKeys.confirmDeleteHostPart2)}',
              icon: Icons.warning_amber_rounded,
              confirmColor: Theme.of(context).colorScheme.error,
              confirmText: _tr(host_l10n.LocalizationKeys.delete),
              cancelText: _tr(core_l10n.LocalizationKeys.cancel),
            );

            if (confirm != true) return;

            try {
              if (mounted) {
                await context
                    .read<HostMonitorProvider>()
                    .storageService!
                    .deleteHost(host.id);
              }
              AppLogger.debug(
                '[HostEditPage] ${_tr(host_l10n.LocalizationKeys.hostDeleted)}: ${host.name}',
              );

              if (mounted) {
                CustomSnackBar(
                  context,
                  message: _tr(host_l10n.LocalizationKeys.hostDeleted),
                  backgroundColor: Colors.green,
                ).showModern();
                _updateState(() {
                  _hosts.removeWhere((h) => h.id == host.id);
                });
              }
            } catch (e) {
              AppLogger.error(
                '[HostEditPage] ${_tr(host_l10n.LocalizationKeys.deleteFailed)}',
                e,
              );
              if (mounted) {
                CustomSnackBar(
                  context,
                  message:
                      '${_tr(host_l10n.LocalizationKeys.deleteFailed)}: $e',
                  backgroundColor: context
                      .read<ThemeProvider>()
                      .currentTheme
                      .accentColor,
                ).showModern();
              }
            }
          },
        ),
      ),
    );
  }

  Future<bool> _connectToHost(HostModel host) async {
    host = _provider.currentHost ?? host;
    final result = await _provider.connect(host);

    if (mounted) {
      if (_provider.errorMessage != null &&
          _provider.errorMessage!.contains(
            _tr(host_l10n.LocalizationKeys.timeout),
          )) {
        await showAdvancedConfirmDialog(
          context: context,
          style: ConfirmDialogStyle.material,
          title: _tr(host_l10n.LocalizationKeys.connectionTimeout),
          content: _tr(
            host_l10n.LocalizationKeys.connectionTimeoutMessage,
          ).replaceAll('{hostName}', host.name),
          icon: Icons.access_time,
          confirmColor: Colors.orange,
          confirmText: _tr(core_l10n.LocalizationKeys.confirm),
          cancelText: '',
        );
      } else if (_provider.errorMessage == 'TOKEN_VERIFICATION_FAILED') {
        await showAdvancedConfirmDialog(
          context: context,
          style: ConfirmDialogStyle.material,
          title: _tr(host_l10n.LocalizationKeys.tokenValidationFailed),
          content: _tr(
            host_l10n.LocalizationKeys.tokenValidationFailedMessage,
          ).replaceAll('{hostName}', host.name),
          icon: Icons.lock_outline,
          confirmColor: Theme.of(context).colorScheme.error,
          confirmText: _tr(core_l10n.LocalizationKeys.confirm),
          cancelText: '',
        );
      } else if (_provider.connectionState == ConnectionState.connected) {
        _updateState(() {
          _isConnecting = false;
          _isConnected = _provider.isConnected;
        });
        CustomSnackBar(
          context,
          message: _tr(host_l10n.LocalizationKeys.connectionSuccess),
          backgroundColor: Colors.green,
        ).showModern();
      } else {
        await showAdvancedConfirmDialog(
          context: context,
          style: ConfirmDialogStyle.material,
          title: _tr(host_l10n.LocalizationKeys.error),
          content:
              _provider.errorMessage ??
              _tr(host_l10n.LocalizationKeys.connectionFailed),
          icon: Icons.error_outline,
          confirmColor: Theme.of(context).colorScheme.error,
          confirmText: _tr(core_l10n.LocalizationKeys.confirm),
          cancelText: '',
        );
      }
    }

    if (!result) {
      // 清除连接状态
      _provider.disconnect();
    }
    return result;
  }

  void _onDisconnect() {
    if (_provider.isConnected || _provider.isConnecting) {
      _updateState(() {
        _isConnecting = false;
        _isConnected = false;
      });

      if (_provider.currentHost != null &&
          _provider.currentHost!.lastConnected != null &&
          DateTime.now()
                  .difference(_provider.currentHost!.lastConnected!)
                  .inSeconds <=
              5) {
        CustomSnackBar(
          context,
          message: _tr(host_l10n.LocalizationKeys.forceDisconnectMessage),
          backgroundColor: Colors.deepOrangeAccent,
          icon: Icons.warning_amber_outlined,
        ).showModern();
      } else {
        CustomSnackBar(
          context,
          message: _tr(host_l10n.LocalizationKeys.safeDisconnectMessage),
          backgroundColor: Colors.green,
          icon: Icons.exit_to_app_outlined,
        ).showModern();
      }

      _provider.disconnect();
    }
  }
}
