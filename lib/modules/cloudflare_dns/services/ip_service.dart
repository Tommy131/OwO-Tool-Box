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

import 'package:http/http.dart' as http;
import '../../../core/utils/logger.dart';

class IPService {
  static const List<String> _ipServices = [
    'https://api.ipify.org',
    'https://ifconfig.me/ip',
    'https://icanhazip.com',
    'https://api64.ipify.org',
  ];

  Future<String?> getPublicIP() async {
    for (final url in _ipServices) {
      try {
        final response = await http
            .get(Uri.parse(url))
            .timeout(const Duration(seconds: 5));
        if (response.statusCode == 200) {
          final ip = response.body.trim();
          if (_isValidIP(ip)) {
            return ip;
          }
        }
      } catch (e) {
        AppLogger.debug('Failed to get IP from $url: $e');
      }
    }
    return null;
  }

  bool _isValidIP(String ip) {
    // Simple regex for IPv4
    final ipv4Regex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
    // Simple regex for IPv6
    final ipv6Regex = RegExp(r'^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$');
    return ipv4Regex.hasMatch(ip) || ipv6Regex.hasMatch(ip);
  }
}
