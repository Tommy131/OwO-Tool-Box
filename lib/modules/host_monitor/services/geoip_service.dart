/*
 *        _____   _          __  _____   _____   _       _____   _____
 *      /  _  \ | |        / / /  _  \ |  _  \ | |     /  _  \ /  ___|
 *      | | | | | |  __   / /  | | | | | |_| | | |     | | | | | |
 *      | | | | | | /  | / /   | | | | |  _  { | |     | | | | | |   _
 *      | |_| | | |/   |/ /    | |_| | | |_| | | |___  | |_| | | |_| |
 *      \_____/ |___/|___/     \_____/ |_____/ |_____| \_____/ \_____/
 *
 *  Copyright (c) 2023 by OwOTeam-DGMT (OwOBlog).
 * @Date         : 2025-10-20
 * @Author       : HanskiJay
 * @LastEditors  : HanskiJay
 * @LastEditTime : 2025-10-23
 * @E-Mail       : support@owoblog.com
 * @Telegram     : https://t.me/HanskiJay
 * @GitHub       : https://github.com/Tommy131
 */
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart' show debugPrint;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import '../../../core/services/bootstrap_service.dart';
import '../../../core/services/persistence_service.dart';

/// IP地理位置信息
class GeoIPInfo {
  final String countryCode;
  final String countryName;
  final String? regionName;
  final String? city;
  final double? latitude;
  final double? longitude;
  final DateTime cachedAt; // 缓存时间

  GeoIPInfo({
    required this.countryCode,
    required this.countryName,
    this.regionName,
    this.city,
    this.latitude,
    this.longitude,
    DateTime? cachedAt,
  }) : cachedAt = cachedAt ?? DateTime.now();

  factory GeoIPInfo.fromJson(Map<String, dynamic> json) {
    return GeoIPInfo(
      countryCode: json['countryCode'] ?? 'UN',
      countryName: json['country'] ?? 'Unknown',
      regionName: json['regionName'],
      city: json['city'],
      latitude: json['lat']?.toDouble(),
      longitude: json['lon']?.toDouble(),
      cachedAt: json['cachedAt'] != null
          ? DateTime.parse(json['cachedAt'])
          : DateTime.now(),
    );
  }

  /// 转换为JSON Map
  Map<String, dynamic> toJson() {
    return {
      'countryCode': countryCode,
      'country': countryName,
      'regionName': regionName,
      'city': city,
      'lat': latitude,
      'lon': longitude,
      'cachedAt': cachedAt.toIso8601String(),
    };
  }

  /// 获取完整位置描述
  String get fullLocation {
    final parts = <String>[];
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (regionName != null && regionName!.isNotEmpty) parts.add(regionName!);
    parts.add(countryName);
    return parts.join(', ');
  }

  /// 检查缓存是否过期
  bool isExpired({Duration maxAge = const Duration(days: 30)}) {
    return DateTime.now().difference(cachedAt) > maxAge;
  }
}

/// GeoIP服务类
class GeoIPService {
  static final GeoIPService _instance = GeoIPService._internal();
  factory GeoIPService() => _instance;
  GeoIPService._internal();

  static const String _cacheFileName = 'geoip_cache.json';

  final Map<String, GeoIPInfo> _memoryCache = {};
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    await _loadCacheFromFile();
    _isInitialized = true;
    await clearExpiredCache();
  }

  Future<void> _loadCacheFromFile() async {
    final file = await _getCacheFile();
    if (!await file.exists()) {
      return;
    }

    final content = await file.readAsString();
    if (content.isEmpty) {
      return;
    }

    final data = jsonDecode(content);
    if (data is! Map) {
      await file.delete();
      return;
    }

    final entries = data.cast<String, dynamic>();
    debugPrint('从持久化存储加载 ${entries.length} 条地理位置缓存');

    for (final entry in entries.entries) {
      final ip = entry.key;
      final value = entry.value;
      if (value is Map<String, dynamic>) {
        try {
          final geoInfo = GeoIPInfo.fromJson(value);
          if (!geoInfo.isExpired()) {
            _memoryCache[ip] = geoInfo;
          }
        } catch (e) {
          debugPrint('加载缓存失败 ($ip): $e');
        }
      }
    }
    await _saveCacheFile();
  }

  /// 确保已初始化
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  Future<void> _saveToCache(String ip, GeoIPInfo info) async {
    await _ensureInitialized();

    try {
      _memoryCache[ip] = info;
      await _saveCacheFile();
      debugPrint('已缓存IP地理位置: $ip -> ${info.fullLocation}');
    } catch (e) {
      debugPrint('保存缓存失败 ($ip): $e');
    }
  }

  Future<void> _removeFromCache(String ip) async {
    try {
      _memoryCache.remove(ip);
      await _saveCacheFile();
    } catch (e) {
      debugPrint('删除缓存失败 ($ip): $e');
    }
  }

  /// 判断是否为内网IP
  static bool isPrivateIP(String ip) {
    if (ip == 'localhost') return true;

    final parts = ip.split('.');
    if (parts.length != 4) return false;

    try {
      final first = int.parse(parts[0]);
      final second = int.parse(parts[1]);

      // 127.0.0.0/8 - 本地回环
      if (first == 127) return true;

      // 10.0.0.0/8 - 私有网络
      if (first == 10) return true;

      // 172.16.0.0/12 - 私有网络
      if (first == 172 && second >= 16 && second <= 31) return true;

      // 192.168.0.0/16 - 私有网络
      if (first == 192 && second == 168) return true;

      // 169.254.0.0/16 - 链路本地
      if (first == 169 && second == 254) return true;

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Ping 主机检测可达性
  Future<bool> _pingHost(
    String ip, {
    Duration timeout = const Duration(seconds: 3),
  }) async {
    try {
      // 使用 Socket 连接测试主机可达性
      final socket = await Socket.connect(
        ip,
        80, // 尝试连接80端口
        timeout: timeout,
      );
      socket.destroy();
      return true;
    } catch (e) {
      // 如果80端口失败,尝试443端口
      try {
        final socket = await Socket.connect(ip, 443, timeout: timeout);
        socket.destroy();
        return true;
      } catch (e) {
        debugPrint('主机 $ip 无法访问: $e');
        return false;
      }
    }
  }

  /// 从缓存或在线API获取IP地理位置
  Future<GeoIPInfo?> getGeoInfo(String ip, {bool forceRefresh = false}) async {
    await _ensureInitialized();

    // 检查是否为内网IP
    if (isPrivateIP(ip)) {
      return GeoIPInfo(countryCode: 'LOCAL', countryName: 'Local Network');
    }

    // 如果不强制刷新,优先从内存缓存获取
    if (!forceRefresh && _memoryCache.containsKey(ip)) {
      final cachedInfo = _memoryCache[ip]!;

      // 检查缓存是否过期
      if (!cachedInfo.isExpired()) {
        debugPrint('从内存缓存获取: $ip -> ${cachedInfo.fullLocation}');
        return cachedInfo;
      } else {
        // 缓存过期,删除
        debugPrint('缓存已过期: $ip');
        _memoryCache.remove(ip);
        await _removeFromCache(ip);
      }
    }

    // Ping检测主机可达性
    debugPrint('正在检测主机 $ip 可达性...');
    final isReachable = await _pingHost(ip);

    if (!isReachable) {
      debugPrint('主机 $ip 无法访问,跳过地理位置查询');
      return null;
    }

    debugPrint('主机 $ip 可达,继续查询地理位置信息');

    // 从API获取
    try {
      final info = await _fetchGeoInfo(ip);
      if (info != null) {
        // 保存到内存和持久化缓存
        _memoryCache[ip] = info;
        await _saveToCache(ip, info);
      }
      return info;
    } catch (e) {
      debugPrint('获取IP地理位置失败 ($ip): $e');
      return null;
    }
  }

  /// 从在线API获取IP地理位置
  Future<GeoIPInfo?> _fetchGeoInfo(String ip) async {
    try {
      // 使用 ip-api.com 的免费API
      // 限制: 每分钟45次请求
      final response = await http
          .get(
            Uri.parse(
              'http://ip-api.com/json/$ip?fields=status,message,country,countryCode,regionName,city,lat,lon',
            ),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success') {
          return GeoIPInfo.fromJson(data);
        } else {
          debugPrint('IP查询失败: ${data['message']}');
          return null;
        }
      } else {
        debugPrint('HTTP错误: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('网络请求异常: $e');
      return null;
    }
  }

  /// 批量获取多个IP的地理位置(带延迟以避免API限制)
  Future<Map<String, GeoIPInfo?>> batchGetGeoInfo(
    List<String> ips, {
    Duration delay = const Duration(milliseconds: 1500),
    bool forceRefresh = false,
  }) async {
    final result = <String, GeoIPInfo?>{};

    for (final ip in ips) {
      result[ip] = await getGeoInfo(ip, forceRefresh: forceRefresh);

      // 添加延迟以避免超过API限制
      if (ips.indexOf(ip) < ips.length - 1) {
        await Future.delayed(delay);
      }
    }

    return result;
  }

  /// 清除所有缓存(内存+持久化)
  Future<void> clearCache() async {
    await _ensureInitialized();

    _memoryCache.clear();
    final file = await _getCacheFile();
    if (await file.exists()) {
      await file.delete();
    }

    debugPrint('已清除所有地理位置缓存');
  }

  /// 清除过期缓存
  Future<void> clearExpiredCache() async {
    await _ensureInitialized();

    final expiredKeys = <String>[];

    for (final ip in _memoryCache.keys.toList()) {
      final cachedInfo = _memoryCache[ip];
      if (cachedInfo != null && cachedInfo.isExpired()) {
        expiredKeys.add(ip);
        await _removeFromCache(ip);
      }
    }

    if (expiredKeys.isNotEmpty) {
      debugPrint('已清除 ${expiredKeys.length} 条过期缓存');
    }
  }

  /// 获取内存缓存大小
  int get memoryCacheSize => _memoryCache.length;

  /// 获取持久化缓存大小
  Future<int> get persistentCacheSize async {
    await _ensureInitialized();
    return _memoryCache.length;
  }

  Future<void> _saveCacheFile() async {
    final file = await _getCacheFile();
    final data = <String, dynamic>{};
    for (final entry in _memoryCache.entries) {
      data[entry.key] = entry.value.toJson();
    }
    await file.writeAsString(jsonEncode(data));
  }

  Future<File> _getCacheFile() async {
    final dir = await _ensureCacheDir();
    return File(p.join(dir.path, _cacheFileName));
  }

  Future<Directory> _ensureCacheDir() async {
    final rootPath = await _resolveRootPath();
    final dir = Directory(p.join(rootPath, 'cache'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<String> _resolveRootPath() async {
    final persistence = PersistenceService();
    if (!persistence.isInitialized || persistence.rootPath == null) {
      final bootstrap = BootstrapService();
      if (!bootstrap.isInitialized) {
        await bootstrap.init();
      }
      final customPath = bootstrap.getDataPath();
      await persistence.init(customPath: customPath);
    }
    return persistence.rootPath ?? PersistenceService.getAppCacheRootPath();
  }
}
