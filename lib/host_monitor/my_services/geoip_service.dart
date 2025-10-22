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
 * @LastEditTime : 2025-10-22
 * @E-Mail       : support@owoblog.com
 * @Telegram     : https://t.me/HanskiJay
 * @GitHub       : https://github.com/Tommy131
 */

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart' show debugPrint;
import 'package:http/http.dart' as http;

/// IP地理位置信息
class GeoIPInfo {
  final String countryCode;
  final String countryName;
  final String? regionName;
  final String? city;
  final double? latitude;
  final double? longitude;

  GeoIPInfo({
    required this.countryCode,
    required this.countryName,
    this.regionName,
    this.city,
    this.latitude,
    this.longitude,
  });

  factory GeoIPInfo.fromJson(Map<String, dynamic> json) {
    return GeoIPInfo(
      countryCode: json['countryCode'] ?? 'UN',
      countryName: json['country'] ?? 'Unknown',
      regionName: json['regionName'],
      city: json['city'],
      latitude: json['lat']?.toDouble(),
      longitude: json['lon']?.toDouble(),
    );
  }

  /// 获取完整位置描述
  String get fullLocation {
    final parts = <String>[];
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (regionName != null && regionName!.isNotEmpty) parts.add(regionName!);
    parts.add(countryName);
    return parts.join(', ');
  }
}

/// GeoIP服务类
class GeoIPService {
  static final GeoIPService _instance = GeoIPService._internal();
  factory GeoIPService() => _instance;
  GeoIPService._internal();

  // 缓存IP地理位置信息,避免重复查询
  final Map<String, GeoIPInfo> _cache = {};

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
  Future<bool> _pingHost(String ip,
      {Duration timeout = const Duration(seconds: 3)}) async {
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
        final socket = await Socket.connect(
          ip,
          443,
          timeout: timeout,
        );
        socket.destroy();
        return true;
      } catch (e) {
        debugPrint('主机 $ip 无法访问: $e');
        return false;
      }
    }
  }

  /// 从缓存或在线API获取IP地理位置
  Future<GeoIPInfo?> getGeoInfo(String ip) async {
    // 检查是否为内网IP
    if (isPrivateIP(ip)) {
      return GeoIPInfo(
        countryCode: 'LOCAL',
        countryName: 'Local Network',
      );
    }

    // 检查缓存
    if (_cache.containsKey(ip)) {
      return _cache[ip];
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
        _cache[ip] = info;
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
                'http://ip-api.com/json/$ip?fields=status,message,country,countryCode,regionName,city,lat,lon'),
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
  }) async {
    final result = <String, GeoIPInfo?>{};

    for (final ip in ips) {
      result[ip] = await getGeoInfo(ip);

      // 添加延迟以避免超过API限制
      if (ips.indexOf(ip) < ips.length - 1) {
        await Future.delayed(delay);
      }
    }

    return result;
  }

  /// 清除缓存
  void clearCache() {
    _cache.clear();
  }

  /// 获取缓存大小
  int get cacheSize => _cache.length;
}
