/*
 *        _____   _          __  _____   _____   _       _____   _____
 *      /  _  \ | |        / / /  _  \ |  _  \ | |     /  _  \ /  ___|
 *      | | | | | |  __   / /  | | | | | |_| | | |     | | | | | |
 *      | | | | | | /  | / /   | | | | |  _  { | |     | | | | | |   _
 *      | |_| | | |/   |/ /    | |_| | | |_| | | |___  | |_| | | |_| |
 *      \_____/ |___/|___/     \_____/ |_____/ |_____| \_____/ \_____/
 *
 *  Copyright (c) 2023 by OwOTeam-DGMT (OwOBlog).
 * @Date         : 2025-10-13 00:28:32
 * @Author       : HanskiJay
 * @LastEditors  : HanskiJay
 * @LastEditTime : 2025-10-13 00:51:38
 * @E-Mail       : support@owoblog.com
 * @Telegram     : https://t.me/HanskiJay
 * @GitHub       : https://github.com/Tommy131
 */
// lib/services/host_check_service.dart
import 'dart:io';
import 'dart:async';
import 'dart:convert';

import '../models/host_config.dart';

class HostCheckService {
  // 检测单个主机是否在线(支持自定义超时)
  static Future<bool> checkHostOnline(
    String host,
    int port, {
    int timeoutSeconds = 3,
  }) async {
    try {
      final socket = await Socket.connect(
        host,
        port,
        timeout: Duration(seconds: timeoutSeconds),
      );

      await socket.close();
      return true;
    } catch (e) {
      return false;
    }
  }

  // 完整检测主机状态(支持自定义超时)
  static Future<HostStatus> checkHostStatus(
    HostConfig host, {
    int timeoutSeconds = 3,
  }) async {
    Socket? socket;

    try {
      socket = await Socket.connect(
        host.host,
        host.port,
        timeout: Duration(seconds: timeoutSeconds),
      );

      try {
        return await _verifyToken(socket, host.token,
            timeoutSeconds: timeoutSeconds);
      } catch (e) {
        return HostStatus.authFailed;
      }
    } catch (e) {
      return HostStatus.offline;
    } finally {
      try {
        await socket?.close();
      } catch (e) {
        // 忽略关闭错误
      }
    }
  }

  // 验证Token(支持自定义超时)
  static Future<HostStatus> _verifyToken(
    Socket socket,
    String token, {
    int timeoutSeconds = 5,
  }) async {
    final completer = Completer<HostStatus>();
    String buffer = '';
    StreamSubscription? subscription;
    Timer? timeoutTimer;

    try {
      subscription = socket.listen(
        (data) {
          buffer += utf8.decode(data);

          if (buffer.contains('错误: 令牌验证失败')) {
            if (!completer.isCompleted) {
              completer.complete(HostStatus.authFailed);
            }
          } else if (buffer.contains('验证成功')) {
            if (!completer.isCompleted) {
              completer.complete(HostStatus.online);
            }
          }
        },
        onError: (error) {
          if (!completer.isCompleted) {
            completer.complete(HostStatus.authFailed);
          }
        },
        onDone: () {
          if (!completer.isCompleted) {
            completer.complete(HostStatus.authFailed);
          }
        },
        cancelOnError: true,
      );

      timeoutTimer = Timer(Duration(seconds: timeoutSeconds), () {
        if (!completer.isCompleted) {
          completer.complete(HostStatus.authFailed);
        }
      });

      await Future.delayed(const Duration(milliseconds: 500));
      socket.write('TOKEN:$token\n');
      await socket.flush();

      final result = await completer.future;
      return result;
    } finally {
      timeoutTimer?.cancel();
      await subscription?.cancel();
    }
  }

  // 批量检测多个主机(支持自定义超时)
  static Future<Map<String, HostStatus>> checkMultipleHostsWithAuth(
    List<HostConfig> hosts, {
    int timeoutSeconds = 3,
  }) async {
    final results = <String, HostStatus>{};
    const batchSize = 5;

    for (int i = 0; i < hosts.length; i += batchSize) {
      final batch = hosts.skip(i).take(batchSize).toList();

      final futures = batch.map((host) async {
        try {
          final status =
              await checkHostStatus(host, timeoutSeconds: timeoutSeconds);
          return MapEntry(host.id, status);
        } catch (e) {
          return MapEntry(host.id, HostStatus.unknown);
        }
      });

      final entries = await Future.wait(futures);

      for (final entry in entries) {
        results[entry.key] = entry.value;
      }
    }

    return results;
  }

  // 为主机配置列表添加状态(支持自定义超时)
  static Future<List<HostConfig>> updateHostsStatus(
    List<HostConfig> hosts, {
    int timeoutSeconds = 3,
  }) async {
    final statusMap =
        await checkMultipleHostsWithAuth(hosts, timeoutSeconds: timeoutSeconds);

    return hosts.map((host) {
      final status = statusMap[host.id] ?? HostStatus.unknown;
      return host.copyWith(status: status);
    }).toList();
  }
}
