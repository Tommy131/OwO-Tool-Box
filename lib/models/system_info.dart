/*
 *        _____   _          __  _____   _____   _       _____   _____
 *      /  _  \ | |        / / /  _  \ |  _  \ | |     /  _  \ /  ___|
 *      | | | | | |  __   / /  | | | | | |_| | | |     | | | | | |
 *      | | | | | | /  | / /   | | | | |  _  { | |     | | | | | |   _
 *      | |_| | | |/   |/ /    | |_| | | |_| | | |___  | |_| | | |_| |
 *      \_____/ |___/|___/     \_____/ |_____/ |_____| \_____/ \_____/
 *
 *  Copyright (c) 2023 by OwOTeam-DGMT (OwOBlog).
 * @Date         : 2025-10-10 21:48:15
 * @Author       : HanskiJay
 * @LastEditors  : HanskiJay
 * @LastEditTime : 2025-10-13 01:08:39
 * @E-Mail       : support@owoblog.com
 * @Telegram     : https://t.me/HanskiJay
 * @GitHub       : https://github.com/Tommy131
 */
// lib/models/system_info.dart
class SystemInfo {
  final CPUInfo cpu;
  final MemoryInfo memory;
  final MainboardInfo mainboard;
  final List<DiskInfo> disks;
  final List<NetworkInfo> network;
  final LoadAverageInfo loadAverage;
  final int processCount;
  final String timestamp;

  SystemInfo({
    required this.cpu,
    required this.memory,
    required this.mainboard,
    required this.disks,
    required this.network,
    required this.loadAverage,
    required this.processCount,
    required this.timestamp,
  });

  // 计算属性
  double get cpuPercent => cpu.avgUsage;
  int get memoryTotal => memory.total;
  int get memoryUsed => memory.used;
  int get memoryAvailable => memory.available;
  double get memoryUsage => memory.usageRate;

  int get diskTotal => disks.fold(0, (sum, disk) => sum + disk.total);
  int get diskUsed => disks.fold(0, (sum, disk) => sum + disk.used);
  double get diskUsage {
    if (disks.isEmpty) return 0.0;
    return disks.map((d) => d.usageRate).reduce((a, b) => a + b) / disks.length;
  }

  // 网络总速率
  double get totalUploadSpeed =>
      network.fold(0.0, (sum, net) => sum + net.uploadSpeed);
  double get totalDownloadSpeed =>
      network.fold(0.0, (sum, net) => sum + net.downloadSpeed);

  String get osName => mainboard.platform;
  String get hostname => mainboard.hostname;
  int get processorCount => cpu.cores;
  Duration get uptime => Duration(seconds: mainboard.uptime.toInt());

  factory SystemInfo.fromJson(Map<String, dynamic> json) {
    return SystemInfo(
      cpu: CPUInfo.fromJson(json['cpu'] ?? {}),
      memory: MemoryInfo.fromJson(json['memory'] ?? {}),
      mainboard: MainboardInfo.fromJson(json['mainboard'] ?? {}),
      disks: ((json['disks'] as List?) ?? [])
          .map((disk) => DiskInfo.fromJson(disk))
          .toList(),
      network: ((json['network'] as List?) ?? [])
          .map((net) => NetworkInfo.fromJson(net))
          .toList(),
      loadAverage: LoadAverageInfo.fromJson(json['load_average'] ?? {}),
      processCount: json['process_count'] ?? 0,
      timestamp: json['timestamp'] ?? DateTime.now().toIso8601String(),
    );
  }
}

// 网络信息类
class NetworkInfo {
  final String interface;
  final int bytesSent;
  final int bytesRecv;
  final int packetsSent;
  final int packetsRecv;
  final int errIn;
  final int errOut;
  final int dropIn;
  final int dropOut;
  final double uploadSpeed; // 字节/秒
  final double downloadSpeed; // 字节/秒

  NetworkInfo({
    required this.interface,
    required this.bytesSent,
    required this.bytesRecv,
    required this.packetsSent,
    required this.packetsRecv,
    required this.errIn,
    required this.errOut,
    required this.dropIn,
    required this.dropOut,
    required this.uploadSpeed,
    required this.downloadSpeed,
  });

  factory NetworkInfo.fromJson(Map<String, dynamic> json) {
    return NetworkInfo(
      interface: json['interface'] ?? 'Unknown',
      bytesSent: json['bytes_sent'] ?? 0,
      bytesRecv: json['bytes_recv'] ?? 0,
      packetsSent: json['packets_sent'] ?? 0,
      packetsRecv: json['packets_recv'] ?? 0,
      errIn: json['err_in'] ?? 0,
      errOut: json['err_out'] ?? 0,
      dropIn: json['drop_in'] ?? 0,
      dropOut: json['drop_out'] ?? 0,
      uploadSpeed: (json['upload_speed'] ?? 0).toDouble(),
      downloadSpeed: (json['download_speed'] ?? 0).toDouble(),
    );
  }
}

class CPUInfo {
  final String modelName;
  final int cores;
  final double frequency;
  final List<double> usageRate;
  final double avgUsage;

  CPUInfo({
    required this.modelName,
    required this.cores,
    required this.frequency,
    required this.usageRate,
    required this.avgUsage,
  });

  factory CPUInfo.fromJson(Map<String, dynamic> json) {
    return CPUInfo(
      modelName: json['model_name'] ?? 'Unknown',
      cores: json['cores'] ?? 0,
      frequency: (json['frequency_mhz'] ?? 0).toDouble(),
      usageRate: ((json['usage_rate_percent'] as List?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          []),
      avgUsage: (json['avg_usage_percent'] ?? 0).toDouble(),
    );
  }
}

class MemoryInfo {
  final int total;
  final int used;
  final int available;
  final double usageRate;

  MemoryInfo({
    required this.total,
    required this.used,
    required this.available,
    required this.usageRate,
  });

  factory MemoryInfo.fromJson(Map<String, dynamic> json) {
    return MemoryInfo(
      total: json['total_mb'] ?? 0,
      used: json['used_mb'] ?? 0,
      available: json['available_mb'] ?? 0,
      usageRate: (json['usage_rate_percent'] ?? 0).toDouble(),
    );
  }
}

class MainboardInfo {
  final String hostname;
  final String platform;
  final String platformVersion;
  final String kernelVersion;
  final String kernelArch;
  final int uptime;

  MainboardInfo({
    required this.hostname,
    required this.platform,
    required this.platformVersion,
    required this.kernelVersion,
    required this.kernelArch,
    required this.uptime,
  });

  factory MainboardInfo.fromJson(Map<String, dynamic> json) {
    return MainboardInfo(
      hostname: json['hostname'] ?? 'Unknown',
      platform: json['platform'] ?? 'Unknown',
      platformVersion: json['platform_version'] ?? 'Unknown',
      kernelVersion: json['kernel_version'] ?? 'Unknown',
      kernelArch: json['kernel_arch'] ?? 'Unknown',
      uptime: json['uptime_seconds'] ?? 0,
    );
  }
}

class DiskInfo {
  final String device;
  final String mountPoint;
  final int total;
  final int used;
  final int free;
  final double usageRate;
  final String label; // 磁盘卷标/名称
  final String serialNo; // 序列号

  DiskInfo({
    required this.device,
    required this.mountPoint,
    required this.total,
    required this.used,
    required this.free,
    required this.usageRate,
    required this.label,
    required this.serialNo,
  });

  factory DiskInfo.fromJson(Map<String, dynamic> json) {
    return DiskInfo(
      device: json['device'] ?? 'Unknown',
      mountPoint: json['mount_point'] ?? 'Unknown',
      total: json['total_gb'] ?? 0,
      used: json['used_gb'] ?? 0,
      free: json['free_gb'] ?? 0,
      usageRate: (json['usage_rate_percent'] ?? 0).toDouble(),
      label: json['label'] ?? '',
      serialNo: json['serial_no'] ?? '',
    );
  }
}

// 系统负载信息类
class LoadAverageInfo {
  final double load1; // 1分钟负载
  final double load5; // 5分钟负载
  final double load15; // 15分钟负载

  LoadAverageInfo({
    required this.load1,
    required this.load5,
    required this.load15,
  });

  factory LoadAverageInfo.fromJson(Map<String, dynamic> json) {
    return LoadAverageInfo(
      load1: (json['load1'] ?? 0.0).toDouble(),
      load5: (json['load5'] ?? 0.0).toDouble(),
      load15: (json['load15'] ?? 0.0).toDouble(),
    );
  }
}
