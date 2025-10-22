/*
 *        _____   _          __  _____   _____   _       _____   _____
 *      /  _  \ | |        / / /  _  \ |  _  \ | |     /  _  \ /  ___|
 *      | | | | | |  __   / /  | | | | | |_| | | |     | | | | | |
 *      | | | | | | /  | / /   | | | | |  _  { | |     | | | | | |   _
 *      | |_| | | |/   |/ /    | |_| | | |_| | | |___  | |_| | | |_| |
 *      \_____/ |___/|___/     \_____/ |_____/ |_____| \_____/ \_____/
 *
 *  Copyright (c) 2023 by OwOTeam-DGMT (OwOBlog).
 * @Date         : 2025-10-18 15:45:00
 * @Author       : HanskiJay
 * @LastEditors  : HanskiJay
 * @LastEditTime : 2025-10-18 16:30:00
 * @E-Mail       : support@owoblog.com
 * @Telegram     : https://t.me/HanskiJay
 * @GitHub       : https://github.com/Tommy131
 */
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../core/utils/logger.dart';
import '../my_models/host_model.dart';

/// 主机连接信息类
class _HostConnection {
  final Socket socket;
  final StreamController<String> responseController;
  final HostModel host;

  _HostConnection({
    required this.socket,
    required this.responseController,
    required this.host,
  });

  Stream<String> get responseStream => responseController.stream;

  void dispose() {
    socket.close();
    responseController.close();
  }
}

/// 主机服务类 - 统一管理主机连接、状态检测和命令发送
///
/// 功能特性:
/// - TCP 连接管理
/// - 主机状态检测（在线/离线/认证失败）
/// - Token 验证
/// - 命令发送
/// - 批量主机检测
class HostService {
  // 私有构造函数，防止实例化
  HostService._();

  // ==================== 连接池管理 ====================

  /// 主机连接池（用于管理多个活跃连接）
  static final Map<String, _HostConnection> _connectionPool = {};

  // ==================== TCP 连接管理 ====================

  /// 连接到主机
  ///
  /// 参数:
  /// - host: 主机模型
  /// - timeout: 连接超时时间(Duration)，默认 10 秒
  ///
  /// 返回值: Future<bool> - 连接是否成功
  static Future<bool> connect(
    HostModel host, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      // 如果已经存在连接，先断开
      if (_connectionPool.containsKey(host.id)) {
        disconnect(host.id);
      }

      final socket = await Socket.connect(
        host.address,
        host.port,
        timeout: timeout,
      );

      final responseController = StreamController<String>.broadcast();

      socket.listen(
        (data) {
          if (!responseController.isClosed) {
            final response = utf8.decode(data);
            responseController.add(response);
          }
        },
        onError: (error) {
          AppLogger.debug('主机连接错误 [${host.name}]: $error');
          responseController.addError(error);
        },
        onDone: () {
          disconnect(host.id);
        },
      );

      _connectionPool[host.id] = _HostConnection(
        socket: socket,
        responseController: responseController,
        host: host,
      );

      return true;
    } catch (e) {
      AppLogger.debug('连接主机失败 [${host.name}]: $e');
      return false;
    }
  }

  /// 检查主机是否已连接
  ///
  /// 参数:
  /// - hostId: 主机 ID
  ///
  /// 返回值: bool - 是否已连接
  static bool isConnected(String hostId) {
    return _connectionPool.containsKey(hostId);
  }

  /// 获取主机的响应流
  ///
  /// 参数:
  /// - hostId: 主机 ID
  ///
  /// 返回值: Stream<String>? - 响应数据流，未连接返回 null
  static Stream<String>? getResponseStream(String hostId) {
    return _connectionPool[hostId]?.responseStream;
  }

  /// 使用 Token 认证
  ///
  /// 参数:
  /// - hostId: 主机 ID
  /// - token: 认证令牌（可选，默认使用主机配置中的 token）
  ///
  /// 返回值: Future<bool> - 操作是否成功
  static Future<bool> authenticate(String hostId, {String? token}) async {
    final connection = _connectionPool[hostId];
    if (connection == null) {
      AppLogger.debug('主机未连接，无法认证 [$hostId]');
      return false;
    }

    try {
      final authToken = token ?? connection.host.token;
      connection.socket.write('TOKEN:$authToken\n');
      await connection.socket.flush();
      return true;
    } catch (e) {
      AppLogger.debug('认证失败 [${connection.host.name}]: $e');
      return false;
    }
  }

  /// 发送命令
  ///
  /// 参数:
  /// - hostId: 主机 ID
  /// - command: 要发送的命令
  ///
  /// 返回值: Future<bool> - 操作是否成功
  static Future<bool> sendCommand(String hostId, String command) async {
    final connection = _connectionPool[hostId];
    if (connection == null) {
      AppLogger.debug('主机未连接，无法发送命令 [$hostId]');
      return false;
    }

    try {
      connection.socket.write('$command\n');
      await connection.socket.flush();
      return true;
    } catch (e) {
      AppLogger.debug('发送命令失败 [${connection.host.name}]: $e');
      return false;
    }
  }

  /// 断开指定主机的连接
  ///
  /// 参数:
  /// - hostId: 主机 ID
  static void disconnect(String hostId) {
    final connection = _connectionPool.remove(hostId);
    connection?.dispose();
  }

  /// 断开所有连接
  static void disconnectAll() {
    for (final connection in _connectionPool.values) {
      connection.dispose();
    }
    _connectionPool.clear();
  }

  /// 获取当前活跃连接数
  static int get activeConnectionCount => _connectionPool.length;

  /// 获取所有活跃连接的主机 ID
  static List<String> get activeHostIds => _connectionPool.keys.toList();

  /// 获取指定主机的连接信息
  ///
  /// 参数:
  /// - hostId: 主机 ID
  ///
  /// 返回值: HostModel? - 主机模型，未连接返回 null
  static HostModel? getConnectedHost(String hostId) {
    return _connectionPool[hostId]?.host;
  }

  /// 获取所有已连接的主机
  ///
  /// 返回值: List<HostModel> - 已连接的主机列表
  static List<HostModel> getAllConnectedHosts() {
    return _connectionPool.values.map((conn) => conn.host).toList();
  }

  // ==================== 主机状态检测 ====================

  /// 快速检测主机是否在线（仅端口检测）
  ///
  /// 参数:
  /// - host: 主机地址
  /// - port: 端口号
  /// - timeoutSeconds: 超时时间(秒)，默认 3
  ///
  /// 返回值: Future<bool> - 主机是否在线
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

  /// 完整检测主机状态（包含 Token 验证）
  ///
  /// 参数:
  /// - host: 主机模型
  /// - timeoutSeconds: 超时时间(秒)，默认 3
  ///
  /// 返回值: Future<HostStatus> - 主机状态
  static Future<HostStatus> checkHostStatus(
    HostModel host, {
    int timeoutSeconds = 3,
  }) async {
    Socket? socket;

    try {
      socket = await Socket.connect(
        host.address,
        host.port,
        timeout: Duration(seconds: timeoutSeconds),
      );

      try {
        return await _verifyToken(
          socket,
          host.token,
          timeoutSeconds: timeoutSeconds,
        );
      } catch (e) {
        AppLogger.debug('Token 验证失败 [${host.name}]: $e');
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

  /// 验证 Token
  ///
  /// 参数:
  /// - socket: Socket 连接
  /// - token: 认证令牌
  /// - timeoutSeconds: 超时时间(秒)，默认 5
  ///
  /// 返回值: Future<HostStatus> - 验证结果状态
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

  /// 批量检测多个主机状态
  ///
  /// 参数:
  /// - hosts: 主机列表
  /// - timeoutSeconds: 超时时间(秒)，默认 3
  /// - batchSize: 批处理大小，默认 5
  ///
  /// 返回值: Future<Map<String, HostStatus>> - 主机 ID 到状态的映射
  static Future<Map<String, HostStatus>> checkMultipleHosts(
    List<HostModel> hosts, {
    int timeoutSeconds = 3,
    int batchSize = 5,
  }) async {
    final results = <String, HostStatus>{};

    for (int i = 0; i < hosts.length; i += batchSize) {
      final batch = hosts.skip(i).take(batchSize).toList();

      final futures = batch.map((host) async {
        try {
          final status = await checkHostStatus(
            host,
            timeoutSeconds: timeoutSeconds,
          );
          return MapEntry(host.id, status);
        } catch (e) {
          AppLogger.debug('检测主机失败 [${host.name}]: $e');
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

  /// 更新主机列表的状态
  ///
  /// 批量检测并更新每个主机的状态
  ///
  /// 参数:
  /// - hosts: 主机列表
  /// - timeoutSeconds: 超时时间(秒)，默认 3
  /// - batchSize: 批处理大小，默认 5
  ///
  /// 返回值: Future<List<HostModel>> - 更新后的主机列表
  static Future<List<HostModel>> updateHostsStatus(
    List<HostModel> hosts, {
    int timeoutSeconds = 3,
    int batchSize = 5,
  }) async {
    final statusMap = await checkMultipleHosts(
      hosts,
      timeoutSeconds: timeoutSeconds,
      batchSize: batchSize,
    );

    return hosts.map((host) {
      final status = statusMap[host.id] ?? HostStatus.unknown;
      return host.copyWith(status: status);
    }).toList();
  }

  /// 检测单个主机并返回更新后的 HostModel
  ///
  /// 参数:
  /// - host: 主机模型
  /// - timeoutSeconds: 超时时间(秒)，默认 3
  ///
  /// 返回值: Future<HostModel> - 更新状态后的主机模型
  static Future<HostModel> updateHostStatus(
    HostModel host, {
    int timeoutSeconds = 3,
  }) async {
    final status = await checkHostStatus(host, timeoutSeconds: timeoutSeconds);
    return host.copyWith(status: status);
  }

  // ==================== 高级连接功能 ====================

  /// 连接并认证主机（一步完成）
  ///
  /// 参数:
  /// - host: 主机模型
  /// - timeout: 连接超时时间
  /// - token: 认证令牌（可选）
  ///
  /// 返回值: Future<bool> - 操作是否成功
  static Future<bool> connectAndAuthenticate(
    HostModel host, {
    Duration timeout = const Duration(seconds: 10),
    String? token,
  }) async {
    final connected = await connect(host, timeout: timeout);
    if (!connected) {
      return false;
    }

    return await authenticate(host.id, token: token);
  }

  /// 重新连接主机
  ///
  /// 参数:
  /// - hostId: 主机 ID
  /// - timeout: 连接超时时间
  ///
  /// 返回值: Future<bool> - 操作是否成功
  static Future<bool> reconnect(
    String hostId, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final connection = _connectionPool[hostId];
    if (connection == null) {
      AppLogger.debug('主机不存在于连接池 [$hostId]');
      return false;
    }

    final host = connection.host;
    disconnect(hostId);

    return await connect(host, timeout: timeout);
  }
}
