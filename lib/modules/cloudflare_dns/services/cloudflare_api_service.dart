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

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cloudflare_config.dart';
import '../models/cloudflare_zone.dart';
import '../models/cloudflare_dns_record.dart';
import '../../../core/utils/logger.dart';

class CloudflareApiService {
  static const String _baseUrl = 'https://api.cloudflare.com/client/v4';

  Map<String, String> _getHeaders(CloudflareConfig config) {
    if (config.isEmailKeyMode) {
      return {
        'X-Auth-Email': config.email!,
        'X-Auth-Key': config.apiKey!,
        'Content-Type': 'application/json',
      };
    } else {
      return {
        'Authorization': 'Bearer ${config.apiToken}',
        'Content-Type': 'application/json',
      };
    }
  }

  Future<bool> verifyToken(CloudflareConfig config) async {
    final result = await verifyTokenDetails(config);
    return result != null;
  }

  Future<Map<String, dynamic>?> verifyTokenDetails(
    CloudflareConfig config,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user/tokens/verify'),
        headers: _getHeaders(config),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['result'];
        }
      }
      return null;
    } catch (e) {
      AppLogger.debug('Cloudflare verification details failed: $e');
      return null;
    }
  }

  Future<List<CloudflareZone>> getZones(CloudflareConfig config) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/zones'),
        headers: _getHeaders(config),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return (data['result'] as List)
              .map((z) => CloudflareZone.fromJson(z))
              .toList();
        }
      }
      return [];
    } catch (e) {
      AppLogger.debug('Failed to get zones: $e');
      return [];
    }
  }

  Future<List<CloudflareDNSRecord>> getDNSRecords(
    CloudflareConfig config,
    String zoneId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/zones/$zoneId/dns_records'),
        headers: _getHeaders(config),
      );

      AppLogger.debug(
        'Get DNSRecords for $zoneId: status=${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List result = data['result'] ?? [];
          return result
              .map((r) => CloudflareDNSRecord.fromJson(r, zoneId))
              .toList();
        } else {
          AppLogger.debug('Cloudflare API error: ${data['errors']}');
        }
      } else {
        AppLogger.debug('Failed to get DNS records: ${response.body}');
      }
      return [];
    } catch (e, stack) {
      AppLogger.error('Exception getting DNS records', e, stack);
      return [];
    }
  }

  Future<bool> updateDNSRecord(
    CloudflareConfig config,
    CloudflareDNSRecord record,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/zones/${record.zoneId}/dns_records/${record.id}'),
        headers: _getHeaders(config),
        body: json.encode(record.toJson()),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      AppLogger.debug('Failed to update DNS record: $e');
      return false;
    }
  }

  Future<bool> patchDNSRecordContent(
    CloudflareConfig config,
    String zoneId,
    String recordId,
    String content,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/zones/$zoneId/dns_records/$recordId'),
        headers: _getHeaders(config),
        body: json.encode({'content': content}),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      AppLogger.debug('Failed to patch DNS record: $e');
      return false;
    }
  }
}
