import 'package:flutter/material.dart';
import '../models/host_config.dart';
import 'storage_service.dart';
import 'host_check_service.dart';

/// 主机管理服务
class HostManager {
  final StorageService _storage;

  HostManager(this._storage);

  /// 加载所有主机
  Future<List<HostConfig>> loadHosts() async {
    return await _storage.getHosts();
  }

  /// 保存主机
  Future<void> saveHost(HostConfig host) async {
    await _storage.addHost(host);
  }

  /// 删除主机
  Future<void> deleteHost(String hostId) async {
    await _storage.deleteHost(hostId);
  }

  /// 检查所有主机状态
  Future<List<HostConfig>> checkAllHostsStatus(
    List<HostConfig> hosts, {
    required int timeoutSeconds,
  }) async {
    if (hosts.isEmpty) return hosts;

    final updatedHosts = await HostCheckService.updateHostsStatus(
      hosts,
      timeoutSeconds: timeoutSeconds,
    );

    // 保存更新后的状态
    await _storage.saveHosts(updatedHosts);

    return updatedHosts;
  }

  /// 获取状态统计
  HostStatusStats getStatusStats(List<HostConfig> hosts) {
    return HostStatusStats(
      total: hosts.length,
      online: hosts.where((h) => h.status == HostStatus.online).length,
      offline: hosts.where((h) => h.status == HostStatus.offline).length,
      authFailed: hosts.where((h) => h.status == HostStatus.authFailed).length,
    );
  }
}

/// 主机状态统计
class HostStatusStats {
  final int total;
  final int online;
  final int offline;
  final int authFailed;

  HostStatusStats({
    required this.total,
    required this.online,
    required this.offline,
    required this.authFailed,
  });

  String get message {
    String msg = '检测完成：$online 在线';
    if (authFailed > 0) msg += ' / $authFailed Token错误';
    if (offline > 0) msg += ' / $offline 离线';
    return msg;
  }

  Color get statusColor {
    if (authFailed > 0) return Colors.orange;
    return Colors.green;
  }
}
