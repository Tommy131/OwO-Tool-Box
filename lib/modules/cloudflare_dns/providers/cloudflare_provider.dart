/*
 *        _____   _          __  _____   _____   _       _____   _____
 *      /  _  \ | |        / / /  _  \ |  _  \ | |     /  _  \ /  ___|
 *      | | | | | |  __   / /  | | | | | |_| | | |     | | | | | |
 *      | | | | | | /  | / /   | | | | |  _  { | |     | | | | | |   _
 *      | |_| | | |/   |/ /    | |_| | | |_| | | |___  | |_| | | |_| |
 *      \_____/ |___/|___/     \_____/ |_____/ |_____| \_____/ \_____/
 *
 *  Copyright (c) 2023 by OwOTeam-DGMT (OwOBlog).
 * @Date         : 2026-01-30
 * @Author       : HanskiJay
 * @LastEditors  : HanskiJay
 * @LastEditTime : 2025-10-22
 * @E-Mail       : support@owoblog.com
 * @Telegram     : https://t.me/HanskiJay
 * @GitHub       : https://github.com/Tommy131
 */

import 'dart:async';
import 'package:flutter/material.dart';
import '../models/cloudflare_config.dart';
import '../models/cloudflare_zone.dart';
import '../models/cloudflare_dns_record.dart';
import '../services/cloudflare_api_service.dart';
import '../services/cloudflare_storage_service.dart';
import '../services/ip_service.dart';
import '../../../core/utils/logger.dart';

class CloudflareProvider with ChangeNotifier {
  final CloudflareApiService _apiService = CloudflareApiService();
  final IPService _ipService = IPService();

  CloudflareConfig? _config;
  final List<CloudflareZone> _zones = [];
  final Map<String, List<CloudflareDNSRecord>> _dnsRecordsMap = {};
  List<DdnsConfig> _ddnsConfigs = [];
  bool _isLoading = false;
  bool? _isTokenValid;
  DateTime? _tokenExpiresAt;
  String? _publicIp;
  Timer? _ddnsTimer;

  CloudflareConfig? get config => _config;
  List<CloudflareZone> get zones => _zones;
  List<DdnsConfig> get ddnsConfigs => _ddnsConfigs;
  bool get isLoading => _isLoading;
  bool? get isTokenValid => _isTokenValid;
  DateTime? get tokenExpiresAt => _tokenExpiresAt;
  String? get publicIp => _publicIp;

  bool get isConfigured => _config != null && _config!.isValid;
  bool get canRunDdnsSync =>
      !_isLoading &&
      isConfigured &&
      _isTokenValid == true &&
      _ddnsConfigs.isNotEmpty;

  Future<void> initialize() async {
    _config = await CloudflareStorageService.getConfig();
    _ddnsConfigs = await CloudflareStorageService.getDdnsConfigs();
    notifyListeners();
    await refreshPublicIp();

    if (isConfigured) {
      await verifyAndSetStatus(_config!);
      await refreshData();
      if (_isTokenValid == true) {
        startDdnsTask();
      }
    }
  }

  Future<void> setConfig(CloudflareConfig config) async {
    _config = config;
    await CloudflareStorageService.saveConfig(config);
    await verifyAndSetStatus(config);
    notifyListeners();
    if (isConfigured) {
      await refreshData();
      if (_isTokenValid == true) {
        startDdnsTask();
      } else {
        _ddnsTimer?.cancel();
      }
    }
  }

  Future<void> verifyAndSetStatus(CloudflareConfig config) async {
    final result = await _apiService.verifyTokenDetails(config);
    if (result != null) {
      _isTokenValid = true;
      if (result['expires_on'] != null) {
        _tokenExpiresAt = DateTime.parse(result['expires_on']);
      } else {
        _tokenExpiresAt = null;
      }
    } else {
      _isTokenValid = false;
      _tokenExpiresAt = null;
    }
    notifyListeners();
  }

  Future<bool> verifyToken(CloudflareConfig config) async {
    return await _apiService.verifyToken(config);
  }

  Future<void> refreshData() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (isConfigured && _isTokenValid == true) {
        final zones = await _apiService.getZones(_config!);
        _zones.clear();
        _zones.addAll(zones);
      }
      await refreshPublicIp(notify: false);
    } catch (e) {
      AppLogger.debug('Refresh Cloudflare data failed: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<CloudflareDNSRecord>> getDNSRecords(
    String zoneId, {
    bool forceRefresh = false,
  }) async {
    if (!isConfigured) return [];
    if (!forceRefresh && _dnsRecordsMap.containsKey(zoneId)) {
      return _dnsRecordsMap[zoneId]!;
    }

    final records = await _apiService.getDNSRecords(_config!, zoneId);
    _dnsRecordsMap[zoneId] = records;
    notifyListeners();
    return records;
  }

  Future<void> refreshDNSRecords(String zoneId) async {
    if (!isConfigured) return;
    final records = await _apiService.getDNSRecords(_config!, zoneId);
    _dnsRecordsMap[zoneId] = records;
    notifyListeners();
  }

  List<CloudflareDNSRecord>? cachedRecords(String zoneId) =>
      _dnsRecordsMap[zoneId];

  // DDNS Logic
  void startDdnsTask() {
    if (!canRunDdnsSync) {
      _ddnsTimer?.cancel();
      return;
    }
    _ddnsTimer?.cancel();
    _ddnsTimer = Timer.periodic(const Duration(minutes: 10), (timer) {
      runDdnsSync();
    });
    // Run once immediately
    runDdnsSync();
  }

  Future<void> runDdnsSync() async {
    if (!canRunDdnsSync) return;

    final currentIp = await _ipService.getPublicIP();
    if (currentIp == null) return;
    _publicIp = currentIp;

    bool changed = false;
    for (int i = 0; i < _ddnsConfigs.length; i++) {
      final ddns = _ddnsConfigs[i];
      if (!ddns.enabled) continue;

      if (ddns.lastIp != currentIp) {
        AppLogger.debug(
          'IP changed for ${ddns.domainName}: ${ddns.lastIp} -> $currentIp',
        );
        final success = await _apiService.patchDNSRecordContent(
          _config!,
          ddns.zoneId,
          ddns.recordId,
          currentIp,
        );
        if (success) {
          _ddnsConfigs[i] = DdnsConfig(
            zoneId: ddns.zoneId,
            recordId: ddns.recordId,
            domainName: ddns.domainName,
            enabled: true,
            lastSync: DateTime.now(),
            lastIp: currentIp,
          );
          changed = true;
        }
      }
    }

    if (changed) {
      await CloudflareStorageService.saveDdnsConfigs(_ddnsConfigs);
      notifyListeners();
    }
  }

  Future<void> refreshPublicIp({bool notify = true}) async {
    final currentIp = await _ipService.getPublicIP();
    if (currentIp == null || currentIp == _publicIp) {
      return;
    }
    _publicIp = currentIp;
    if (notify) {
      notifyListeners();
    }
  }

  Future<void> addDdnsConfig(DdnsConfig config) async {
    _ddnsConfigs.add(config);
    await CloudflareStorageService.saveDdnsConfigs(_ddnsConfigs);
    notifyListeners();
    runDdnsSync();
  }

  Future<void> removeDdnsConfig(String recordId) async {
    _ddnsConfigs.removeWhere((c) => c.recordId == recordId);
    await CloudflareStorageService.saveDdnsConfigs(_ddnsConfigs);
    notifyListeners();
  }

  Future<void> toggleDdns(String recordId, bool enabled) async {
    final index = _ddnsConfigs.indexWhere((c) => c.recordId == recordId);
    if (index != -1) {
      final old = _ddnsConfigs[index];
      _ddnsConfigs[index] = DdnsConfig(
        zoneId: old.zoneId,
        recordId: old.recordId,
        domainName: old.domainName,
        enabled: enabled,
        lastSync: old.lastSync,
        lastIp: old.lastIp,
      );
      await CloudflareStorageService.saveDdnsConfigs(_ddnsConfigs);
      notifyListeners();
      if (enabled) runDdnsSync();
    }
  }

  @override
  void dispose() {
    _ddnsTimer?.cancel();
    super.dispose();
  }
}
