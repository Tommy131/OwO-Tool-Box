// lib/screens/home_screen/home_host_manager.dart
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:provider/provider.dart';
import '../../models/host_config.dart';
import '../../providers/system_provider.dart';
import 'host_theme.dart';

class HomeHostManager {
  // 连接到主机
  static Future<void> connectToHost({
    required BuildContext context,
    required HostConfig host,
    required VoidCallback onSuccess,
    required VoidCallback onTimeout,
    required VoidCallback onTokenError,
  }) async {
    final provider = context.read<SystemProvider>();

    await provider.connect(
      host.host,
      host.port,
      host.token,
      hostConfig: host,
    );

    if (context.mounted) {
      if (provider.errorMessage != null &&
          provider.errorMessage!.contains('超时')) {
        onTimeout();
        return;
      }

      if (provider.errorMessage == 'TOKEN_VERIFICATION_FAILED') {
        onTokenError();
        return;
      }

      if (provider.connectionState == ConnectionState.connected) {
        onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('连接成功'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? '连接失败'),
            backgroundColor: HostTheme.accentColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // 重新连接到主机
  static Future<void> reconnectToHost({
    required BuildContext context,
    required HostConfig host,
    required VoidCallback onSuccess,
    required VoidCallback onTimeout,
    required VoidCallback onTokenError,
  }) async {
    final provider = context.read<SystemProvider>();

    provider.disconnect();
    await Future.delayed(const Duration(milliseconds: 500));

    await provider.connect(
      host.host,
      host.port,
      host.token,
      hostConfig: host,
    );

    if (context.mounted) {
      if (provider.errorMessage != null &&
          provider.errorMessage!.contains('超时')) {
        onTimeout();
        return;
      }

      if (provider.errorMessage == 'TOKEN_VERIFICATION_FAILED') {
        onTokenError();
        return;
      }

      if (provider.connectionState == ConnectionState.connected) {
        onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('已重新连接到 ${host.name}'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(provider.errorMessage ?? '重新连接失败'),
                ),
              ],
            ),
            backgroundColor: HostTheme.accentColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }
}
