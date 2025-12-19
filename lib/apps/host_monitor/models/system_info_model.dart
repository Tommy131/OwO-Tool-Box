/*
 *        _____   _          __  _____   _____   _       _____   _____
 *      /  _  \ | |        / / /  _  \ |  _  \ | |     /  _  \ /  ___|
 *      | | | | | |  __   / /  | | | | | |_| | | |     | | | | | |
 *      | | | | | | /  | / /   | | | | |  _  { | |     | | | | | |   _
 *      | |_| | | |/   |/ /    | |_| | | |_| | | |___  | |_| | | |_| |
 *      \_____/ |___/|___/     \_____/ |_____/ |_____| \_____/ \_____/
 *
 *  Copyright (c) 2023 by OwOTeam-DGMT (OwOBlog).
 * @Date         : 2025-10-18 00:00:00
 * @Author       : HanskiJay
 * @LastEditors  : HanskiJay
 * @LastEditTime : 2025-10-18 00:00:00
 * @E-Mail       : support@owoblog.com
 * @Telegram     : https://t.me/HanskiJay
 * @GitHub       : https://github.com/Tommy131
 */
/// 系统信息主模型
class SystemInfoModel {
  /// CPU 信息
  final CpuInfo cpu;

  /// 内存信息
  final MemoryInfo memory;

  /// 主板/系统信息
  final SystemBaseInfo system;

  /// 磁盘信息列表
  final List<DiskInfo> disks;

  /// 网络接口信息列表
  final List<NetworkInfo> networks;

  /// 系统负载信息
  final LoadAverageInfo loadAverage;

  /// 进程数量
  final int processCount;

  /// 数据采集时间戳
  final DateTime timestamp;

  SystemInfoModel({
    required this.cpu,
    required this.memory,
    required this.system,
    required this.disks,
    required this.networks,
    required this.loadAverage,
    required this.processCount,
    required this.timestamp,
  });

  // ==================== CPU 相关便捷访问器 ====================

  /// CPU 平均使用率 (%)
  double get cpuUsagePercent => cpu.avgUsage;

  /// CPU 核心数
  int get cpuCoreCount => cpu.cores;

  /// CPU 型号
  String get cpuModel => cpu.modelName;

  // ==================== 内存相关便捷访问器 ====================

  /// 内存总量 (MB)
  int get memoryTotal => memory.total;

  /// 已使用内存 (MB)
  int get memoryUsed => memory.used;

  /// 可用内存 (MB)
  int get memoryAvailable => memory.available;

  /// 内存使用率 (%)
  double get memoryUsagePercent => memory.usageRate;

  // ==================== 磁盘相关便捷访问器 ====================

  /// 所有磁盘总容量 (GB)
  int get diskTotalSpace => disks.fold(0, (sum, disk) => sum + disk.total);

  /// 所有磁盘已使用空间 (GB)
  int get diskUsedSpace => disks.fold(0, (sum, disk) => sum + disk.used);

  /// 所有磁盘可用空间 (GB)
  int get diskFreeSpace => disks.fold(0, (sum, disk) => sum + disk.free);

  /// 平均磁盘使用率 (%)
  double get diskAvgUsagePercent {
    if (disks.isEmpty) return 0.0;
    final totalUsage = disks.fold(0.0, (sum, disk) => sum + disk.usageRate);
    return totalUsage / disks.length;
  }

  // ==================== 网络相关便捷访问器 ====================

  /// 总上传速度 (字节/秒)
  double get totalUploadSpeed =>
      networks.fold(0.0, (sum, net) => sum + net.uploadSpeed);

  /// 总下载速度 (字节/秒)
  double get totalDownloadSpeed =>
      networks.fold(0.0, (sum, net) => sum + net.downloadSpeed);

  /// 总发送字节数
  int get totalBytesSent => networks.fold(0, (sum, net) => sum + net.bytesSent);

  /// 总接收字节数
  int get totalBytesReceived =>
      networks.fold(0, (sum, net) => sum + net.bytesReceived);

  // ==================== 系统相关便捷访问器 ====================

  /// 操作系统名称
  String get osName => system.platform;

  /// 系统版本
  String get osVersion => system.platformVersion;

  /// 主机名
  String get hostname => system.hostname;

  /// 系统运行时间
  Duration get uptime => Duration(seconds: system.uptimeSeconds);

  /// 内核版本
  String get kernelVersion => system.kernelVersion;

  /// 系统架构
  String get architecture => system.kernelArch;

  // ==================== JSON 序列化 ====================

  factory SystemInfoModel.fromJson(Map<String, dynamic> json) {
    return SystemInfoModel(
      cpu: CpuInfo.fromJson(json['cpu'] ?? {}),
      memory: MemoryInfo.fromJson(json['memory'] ?? {}),
      system: SystemBaseInfo.fromJson(json['mainboard'] ?? {}),
      disks: (json['disks'] as List<dynamic>?)
              ?.map((disk) => DiskInfo.fromJson(disk as Map<String, dynamic>))
              .toList() ??
          [],
      networks: (json['network'] as List<dynamic>?)
              ?.map((net) => NetworkInfo.fromJson(net as Map<String, dynamic>))
              .toList() ??
          [],
      loadAverage: LoadAverageInfo.fromJson(json['load_average'] ?? {}),
      processCount: json['process_count'] as int? ?? 0,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cpu': cpu.toJson(),
      'memory': memory.toJson(),
      'mainboard': system.toJson(),
      'disks': disks.map((disk) => disk.toJson()).toList(),
      'network': networks.map((net) => net.toJson()).toList(),
      'load_average': loadAverage.toJson(),
      'process_count': processCount,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// 创建副本
  SystemInfoModel copyWith({
    CpuInfo? cpu,
    MemoryInfo? memory,
    SystemBaseInfo? system,
    List<DiskInfo>? disks,
    List<NetworkInfo>? networks,
    LoadAverageInfo? loadAverage,
    int? processCount,
    DateTime? timestamp,
  }) {
    return SystemInfoModel(
      cpu: cpu ?? this.cpu,
      memory: memory ?? this.memory,
      system: system ?? this.system,
      disks: disks ?? this.disks,
      networks: networks ?? this.networks,
      loadAverage: loadAverage ?? this.loadAverage,
      processCount: processCount ?? this.processCount,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

// ==================== CPU 信息模型 ====================

class CpuInfo {
  /// CPU 型号名称
  final String modelName;

  /// CPU 核心数
  final int cores;

  /// CPU 频率 (MHz)
  final double frequencyMhz;

  /// 每个核心的使用率 (%)
  final List<double> perCoreUsage;

  /// 平均使用率 (%)
  final double avgUsage;

  CpuInfo({
    required this.modelName,
    required this.cores,
    required this.frequencyMhz,
    required this.perCoreUsage,
    required this.avgUsage,
  });

  factory CpuInfo.fromJson(Map<String, dynamic> json) {
    return CpuInfo(
      modelName: json['model_name'] as String? ?? 'Unknown',
      cores: json['cores'] as int? ?? 0,
      frequencyMhz: (json['frequency_mhz'] as num?)?.toDouble() ?? 0.0,
      perCoreUsage: (json['usage_rate_percent'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      avgUsage: (json['avg_usage_percent'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'model_name': modelName,
      'cores': cores,
      'frequency_mhz': frequencyMhz,
      'usage_rate_percent': perCoreUsage,
      'avg_usage_percent': avgUsage,
    };
  }
}

// ==================== 内存信息模型 ====================

class MemoryInfo {
  /// 总内存 (MB)
  final int total;

  /// 已使用内存 (MB)
  final int used;

  /// 可用内存 (MB)
  final int available;

  /// 使用率 (%)
  final double usageRate;

  MemoryInfo({
    required this.total,
    required this.used,
    required this.available,
    required this.usageRate,
  });

  factory MemoryInfo.fromJson(Map<String, dynamic> json) {
    return MemoryInfo(
      total: json['total_mb'] as int? ?? 0,
      used: json['used_mb'] as int? ?? 0,
      available: json['available_mb'] as int? ?? 0,
      usageRate: (json['usage_rate_percent'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_mb': total,
      'used_mb': used,
      'available_mb': available,
      'usage_rate_percent': usageRate,
    };
  }
}

// ==================== 系统基础信息模型 ====================

class SystemBaseInfo {
  /// 主机名
  final String hostname;

  /// 操作系统平台
  final String platform;

  /// 平台版本
  final String platformVersion;

  /// 内核版本
  final String kernelVersion;

  /// 内核架构
  final String kernelArch;

  /// 系统运行时间 (秒)
  final int uptimeSeconds;

  SystemBaseInfo({
    required this.hostname,
    required this.platform,
    required this.platformVersion,
    required this.kernelVersion,
    required this.kernelArch,
    required this.uptimeSeconds,
  });

  factory SystemBaseInfo.fromJson(Map<String, dynamic> json) {
    return SystemBaseInfo(
      hostname: json['hostname'] as String? ?? 'Unknown',
      platform: json['platform'] as String? ?? 'Unknown',
      platformVersion: json['platform_version'] as String? ?? 'Unknown',
      kernelVersion: json['kernel_version'] as String? ?? 'Unknown',
      kernelArch: json['kernel_arch'] as String? ?? 'Unknown',
      uptimeSeconds: json['uptime_seconds'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hostname': hostname,
      'platform': platform,
      'platform_version': platformVersion,
      'kernel_version': kernelVersion,
      'kernel_arch': kernelArch,
      'uptime_seconds': uptimeSeconds,
    };
  }
}

// ==================== 磁盘信息模型 ====================

class DiskInfo {
  /// 设备名称
  final String device;

  /// 挂载点
  final String mountPoint;

  /// 总容量 (GB)
  final int total;

  /// 已使用空间 (GB)
  final int used;

  /// 可用空间 (GB)
  final int free;

  /// 使用率 (%)
  final double usageRate;

  /// 磁盘卷标
  final String label;

  /// 序列号
  final String serialNumber;

  DiskInfo({
    required this.device,
    required this.mountPoint,
    required this.total,
    required this.used,
    required this.free,
    required this.usageRate,
    this.label = '',
    this.serialNumber = '',
  });

  factory DiskInfo.fromJson(Map<String, dynamic> json) {
    return DiskInfo(
      device: json['device'] as String? ?? 'Unknown',
      mountPoint: json['mount_point'] as String? ?? 'Unknown',
      total: json['total_gb'] as int? ?? 0,
      used: json['used_gb'] as int? ?? 0,
      free: json['free_gb'] as int? ?? 0,
      usageRate: (json['usage_rate_percent'] as num?)?.toDouble() ?? 0.0,
      label: json['label'] as String? ?? '',
      serialNumber: json['serial_no'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device': device,
      'mount_point': mountPoint,
      'total_gb': total,
      'used_gb': used,
      'free_gb': free,
      'usage_rate_percent': usageRate,
      'label': label,
      'serial_no': serialNumber,
    };
  }
}

// ==================== 网络信息模型 ====================

class NetworkInfo {
  /// 网络接口名称
  final String interface;

  /// 发送的字节数
  final int bytesSent;

  /// 接收的字节数
  final int bytesReceived;

  /// 发送的数据包数
  final int packetsSent;

  /// 接收的数据包数
  final int packetsReceived;

  /// 接收错误数
  final int errorsIn;

  /// 发送错误数
  final int errorsOut;

  /// 接收丢包数
  final int dropsIn;

  /// 发送丢包数
  final int dropsOut;

  /// 上传速度 (字节/秒)
  final double uploadSpeed;

  /// 下载速度 (字节/秒)
  final double downloadSpeed;

  NetworkInfo({
    required this.interface,
    required this.bytesSent,
    required this.bytesReceived,
    required this.packetsSent,
    required this.packetsReceived,
    required this.errorsIn,
    required this.errorsOut,
    required this.dropsIn,
    required this.dropsOut,
    required this.uploadSpeed,
    required this.downloadSpeed,
  });

  factory NetworkInfo.fromJson(Map<String, dynamic> json) {
    return NetworkInfo(
      interface: json['interface'] as String? ?? 'Unknown',
      bytesSent: json['bytes_sent'] as int? ?? 0,
      bytesReceived: json['bytes_recv'] as int? ?? 0,
      packetsSent: json['packets_sent'] as int? ?? 0,
      packetsReceived: json['packets_recv'] as int? ?? 0,
      errorsIn: json['err_in'] as int? ?? 0,
      errorsOut: json['err_out'] as int? ?? 0,
      dropsIn: json['drop_in'] as int? ?? 0,
      dropsOut: json['drop_out'] as int? ?? 0,
      uploadSpeed: (json['upload_speed'] as num?)?.toDouble() ?? 0.0,
      downloadSpeed: (json['download_speed'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'interface': interface,
      'bytes_sent': bytesSent,
      'bytes_recv': bytesReceived,
      'packets_sent': packetsSent,
      'packets_recv': packetsReceived,
      'err_in': errorsIn,
      'err_out': errorsOut,
      'drop_in': dropsIn,
      'drop_out': dropsOut,
      'upload_speed': uploadSpeed,
      'download_speed': downloadSpeed,
    };
  }
}

// ==================== 系统负载信息模型 ====================

class LoadAverageInfo {
  /// 1分钟平均负载
  final double load1min;

  /// 5分钟平均负载
  final double load5min;

  /// 15分钟平均负载
  final double load15min;

  LoadAverageInfo({
    required this.load1min,
    required this.load5min,
    required this.load15min,
  });

  factory LoadAverageInfo.fromJson(Map<String, dynamic> json) {
    return LoadAverageInfo(
      load1min: (json['load1'] as num?)?.toDouble() ?? 0.0,
      load5min: (json['load5'] as num?)?.toDouble() ?? 0.0,
      load15min: (json['load15'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'load1': load1min,
      'load5': load5min,
      'load15': load15min,
    };
  }
}
