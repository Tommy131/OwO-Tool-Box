import 'package:flutter/material.dart';

import 'my_models/host_model.dart';

/// 格式化工具类
class FormatUtils {
  /// 格式化网络速度
  static String formatNetworkSpeed(double bytesPerSecond) {
    if (bytesPerSecond < 1024) {
      return '${bytesPerSecond.toStringAsFixed(1)} B/s';
    } else if (bytesPerSecond < 1024 * 1024) {
      return '${(bytesPerSecond / 1024).toStringAsFixed(1)} KB/s';
    } else if (bytesPerSecond < 1024 * 1024 * 1024) {
      return '${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(2)} MB/s';
    } else {
      return '${(bytesPerSecond / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB/s';
    }
  }

  /// 格式化字节大小
  static String formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else if (bytes < 1024 * 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024 * 1024)).toStringAsFixed(2)} TB';
    }
  }

  /// 验证IPv4地址格式
  static bool isValidIPv4(String host) {
    final ipv4Regex = RegExp(
        r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$');
    return ipv4Regex.hasMatch(host);
  }

  /// 验证域名格式
  static bool isValidDomain(String host) {
    final domainRegex = RegExp(
        r'^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$');
    return domainRegex.hasMatch(host);
  }

  /// 验证主机地址（支持IPv4、域名、localhost）
  static bool isValidHost(String host) {
    if (host == 'localhost') return true;
    return isValidIPv4(host) || isValidDomain(host);
  }

  /// 验证端口号
  static bool isValidPort(int port) {
    return port >= 1 && port <= 65535;
  }

  /// 格式化运行时间
  static String formatUptime(Duration uptime) {
    final days = uptime.inDays;
    final hours = uptime.inHours % 24;
    final minutes = uptime.inMinutes % 60;

    if (days > 0) return '$days天 $hours小时';
    if (hours > 0) return '$hours小时 $minutes分钟';
    return '$minutes分钟';
  }

  /// 根据使用率获取颜色
  static Color getColorForUsage(double usage) {
    if (usage < 50) return Colors.green;
    if (usage < 80) return Colors.orange;
    return Colors.red;
  }

  /// 获取状态颜色
  static Color getStatusColor(HostStatus status) {
    switch (status) {
      case HostStatus.online:
        return Colors.green;
      case HostStatus.offline:
        return Colors.grey;
      case HostStatus.authFailed:
        return Colors.red;
      case HostStatus.unknown:
        return Colors.white24;
    }
  }

  /// 获取状态文字
  static String getStatusText(HostStatus status) {
    switch (status) {
      case HostStatus.online:
        return '在线';
      case HostStatus.offline:
        return '离线';
      case HostStatus.authFailed:
        return 'Token验证失败';
      case HostStatus.unknown:
        return '未检测';
    }
  }

  /// 获取状态图标
  static IconData getStatusIcon(HostStatus status) {
    switch (status) {
      case HostStatus.online:
        return Icons.check_circle;
      case HostStatus.offline:
        return Icons.cancel;
      case HostStatus.authFailed:
        return Icons.lock_outline;
      case HostStatus.unknown:
        return Icons.help_outline;
    }
  }

  /// 获取日期格式
  static String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    }
  }
}
