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

import '../../core/i18n/app_localization.dart';
import '../providers/host_monitor_provider.dart';
import '../services/alert_service.dart';
import '../screen_theme.dart';
import '../widgets/animated_background.dart';

class AlertHistoryScreen extends StatelessWidget {
  const AlertHistoryScreen({super.key});

  // 国际化翻译简化方法
  String _tr(BuildContext context, String key) =>
      AppLocalization.of(context).translate(key);

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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ScreenTheme.primaryColor.withOpacity(0.3),
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
            shaderCallback: (bounds) =>
                ScreenTheme.primaryGradient.createShader(bounds),
            child: Text(
              _tr(context, 'alert_history'),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.white),
            onPressed: () => _showClearDialog(context),
            tooltip: _tr(context, 'clear_history'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShaderMask(
            shaderCallback: (bounds) =>
                ScreenTheme.primaryGradient.createShader(bounds),
            child: const Icon(
              Icons.notifications_none,
              size: 100,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _tr(context, 'no_alert_records'),
            style: const TextStyle(
              fontSize: 18,
            ),
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
                  color: _getAlertColor(alert.type).withOpacity(0.2),
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
                        content: Text(_tr(context, 'alert_acknowledged')),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      color: ScreenTheme.primaryColor.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _tr(context, 'acknowledge'),
                  style: const TextStyle(color: ScreenTheme.primaryColor),
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
    return _getAlertColor(type).withOpacity(0.3);
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(_tr(context, 'clear_history')),
        content: Text(_tr(context, 'confirm_clear_alert_history')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(_tr(context, 'cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style:
                TextButton.styleFrom(foregroundColor: ScreenTheme.accentColor),
            child: Text(_tr(context, 'clear')),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<HostMonitorProvider>().alertService.clearHistory();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_tr(context, 'history_cleared')),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
