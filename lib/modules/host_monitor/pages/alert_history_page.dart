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
// lib/screens/alert_history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme_provider.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/localization/localization_keys.dart' as core_l10n;
import '../localization/localization_keys.dart' as host_l10n;
import '../providers/host_monitor_provider.dart';
import '../services/alert_service.dart';
import '../widgets/animated_background.dart';

class AlertHistoryPage extends StatelessWidget {
  const AlertHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: Consumer<HostMonitorProvider>(
                    builder: (context, provider, child) {
                      final alerts = provider.alertService.alertHistory;

                      if (alerts.isEmpty) {
                        return _buildEmptyState(context);
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: alerts.length,
                        itemBuilder: (context, index) {
                          return _buildAlertCard(context, alerts[index]);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.3),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              _tr(context, host_l10n.LocalizationKeys.alertHistory),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.white),
            onPressed: () => _showClearDialog(context),
            tooltip: _tr(context, host_l10n.LocalizationKeys.clearHistory),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: const Icon(
              Icons.notifications_none,
              size: 100,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _tr(context, host_l10n.LocalizationKeys.noAlertRecords),
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, AlertRecord alert) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getAlertBorderColor(alert.type),
          width: alert.acknowledged ? 1 : 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getAlertColor(alert.type).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getAlertIcon(alert.type),
                  color: _getAlertColor(alert.type),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.hostName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDateTime(alert.timestamp),
                      style: const TextStyle(
                        // color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (!alert.acknowledged)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            alert.message,
            style: const TextStyle(
              // color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          if (!alert.acknowledged) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  // 确认告警
                  await context
                      .read<HostMonitorProvider>()
                      .alertService
                      .acknowledgeAlert(alert.id);

                  // 显示提示
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _tr(
                            context,
                            host_l10n.LocalizationKeys.alertAcknowledged,
                          ),
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: theme.colorScheme.primary.withValues(alpha: 0.5),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _tr(context, host_l10n.LocalizationKeys.acknowledge),
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getAlertColor(AlertType type) {
    switch (type) {
      case AlertType.cpuHigh:
      case AlertType.memoryHigh:
      case AlertType.diskHigh:
        return Colors.red;
      case AlertType.networkUploadHigh:
      case AlertType.networkDownloadHigh:
        return Colors.orange;
      case AlertType.disconnected:
        return Colors.grey;
    }
  }

  Color _getAlertBorderColor(AlertType type) {
    return _getAlertColor(type).withValues(alpha: 0.3);
  }

  IconData _getAlertIcon(AlertType type) {
    switch (type) {
      case AlertType.cpuHigh:
        return Icons.speed;
      case AlertType.memoryHigh:
        return Icons.memory;
      case AlertType.diskHigh:
        return Icons.storage;
      case AlertType.networkUploadHigh:
        return Icons.upload;
      case AlertType.networkDownloadHigh:
        return Icons.download;
      case AlertType.disconnected:
        return Icons.cloud_off;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _showClearDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(_tr(context, host_l10n.LocalizationKeys.clearHistory)),
        content: Text(
          _tr(context, host_l10n.LocalizationKeys.confirmClearAlertHistory),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(_tr(context, core_l10n.LocalizationKeys.cancel)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: context
                  .read<ThemeProvider>()
                  .currentTheme
                  .accentColor,
            ),
            child: Text(_tr(context, host_l10n.LocalizationKeys.clear)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<HostMonitorProvider>().alertService.clearHistory();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _tr(context, host_l10n.LocalizationKeys.historyCleared),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _tr(BuildContext context, String key) {
    return LocalizationService().translate(key);
  }
}
