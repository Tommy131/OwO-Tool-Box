/*
 *        _____   _          __  _____   _____   _       _____   _____
 *      /  _  \ | |        / / /  _  \ |  _  \ | |     /  _  \ /  ___|
 *      | | | | | |  __   / /  | | | | | |_| | | |     | | | | | |
 *      | | | | | | /  | / /   | | | | |  _  { | |     | | | | | |   _
 *      | |_| | | |/   |/ /    | |_| | | |_| | | |___  | |_| | | |_| |
 *      \_____/ |___/|___/     \_____/ |_____/ |_____| \_____/ \_____/
 *
 *  Copyright (c) 2023 by OwOTeam-DGMT (OwOBlog).
 * @Date         : 2025-10-10 21:48:40
 * @Author       : HanskiJay
 * @LastEditors  : HanskiJay
 * @LastEditTime : 2025-10-13 14:55:21
 * @E-Mail       : support@owoblog.com
 * @Telegram     : https://t.me/HanskiJay
 * @GitHub       : https://github.com/Tommy131
 */
// lib/providers/system_provider.dart
import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../services/tcp_service.dart';
import '../services/storage_service.dart';
import '../services/managers/alert_manager.dart';
import '../models/system_info.dart';
import '../models/host_config.dart';
import '../models/app_settings.dart';
import '../models/metrics_history.dart';

enum ConnectionState { disconnected, connecting, connected, error }

class SystemProvider with ChangeNotifier {
  TCPService? _tcpService;
  SystemInfo? _systemInfo;
  ConnectionState _connectionState = ConnectionState.disconnected;
  String? _errorMessage;
  Timer? _autoRefreshTimer;
  Timer? _connectionCheckTimer;
  StreamSubscription? _responseSubscription;
  bool _isCheckingConnection = false;
  DateTime? _lastDataReceived;

  // models
  AppSettings _settings = const AppSettings();
  HostConfig? _currentHost;
  final MetricsHistory _metricsHistory = MetricsHistory();

  // services
  late StorageService _storageService;
  final AlertManager _alertManager = AlertManager();

  // public getter
  SystemInfo? get systemInfo => _systemInfo;
  ConnectionState get connectionState => _connectionState;
  String? get errorMessage => _errorMessage;

  // models getter
  AppSettings get settings => _settings;
  HostConfig? get currentHost => _currentHost;
  MetricsHistory get metricsHistory => _metricsHistory;

  // services getter
  AlertManager get alertManager => _alertManager;

  Future<void> initialize() async {
    _storageService = await StorageService.create();
    _settings = await _storageService.getSettings();
    await _alertManager.initialize();

    _alertManager.addListener(() {
      notifyListeners();
    });

    notifyListeners();
  }

  Future<void> updateSettings(AppSettings settings) async {
    _settings = settings;
    await _storageService.saveSettings(settings);

    if (_connectionState == ConnectionState.connected) {
      stopAutoRefresh();
      startAutoRefresh(settings.refreshInterval);
    }

    notifyListeners();
  }

  void updateCurrentHost(HostConfig hostConfig) {
    _currentHost = hostConfig;
    notifyListeners();
  }

  Future<void> connect(String host, int port, String token,
      {HostConfig? hostConfig}) async {
    _connectionState = ConnectionState.connecting;
    _errorMessage = null;
    _currentHost = hostConfig;
    _lastDataReceived = DateTime.now();
    notifyListeners();

    try {
      _tcpService = TCPService(host: host, port: port);

      final connected = await _tcpService!.connect().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('连接服务器超时，请检查网络连接和服务器地址');
        },
      );

      if (!connected) {
        throw Exception('无法连接到服务器，请检查服务器是否运行');
      }

      String buffer = '';
      bool isAuthenticated = false;

      _responseSubscription = _tcpService!.responseStream.listen(
        (data) {
          _lastDataReceived = DateTime.now();
          buffer += data;

          if (!isAuthenticated && buffer.contains('错误: 令牌验证失败')) {
            _connectionState = ConnectionState.error;
            _errorMessage = 'TOKEN_VERIFICATION_FAILED';
            disconnect();
            notifyListeners();
            return;
          }

          if (!isAuthenticated && buffer.contains('验证成功')) {
            isAuthenticated = true;
            _connectionState = ConnectionState.connected;

            if (_currentHost != null) {
              _currentHost = _currentHost!.copyWith(
                lastConnected: DateTime.now(),
              );
              _storageService.updateHost(_currentHost!);
            }

            notifyListeners();
            startAutoRefresh(_settings.refreshInterval);
            startConnectionMonitoring();
            return;
          }

          if (isAuthenticated) {
            while (buffer.contains('{') && buffer.contains('}')) {
              final startIndex = buffer.indexOf('{');
              final endIndex = _findMatchingBrace(buffer, startIndex);

              if (endIndex == -1) {
                break;
              }

              final jsonStr = buffer.substring(startIndex, endIndex + 1);

              try {
                final jsonData = json.decode(jsonStr);
                _systemInfo = SystemInfo.fromJson(jsonData);

                _metricsHistory.addDataPoint(
                  _systemInfo!.cpuPercent,
                  _systemInfo!.memoryUsage,
                  _systemInfo!.diskUsage,
                  _systemInfo!.totalUploadSpeed / 1024,
                  _systemInfo!.totalDownloadSpeed / 1024,
                  _systemInfo!.loadAverage.load1,
                  _systemInfo!.loadAverage.load5,
                  _systemInfo!.loadAverage.load15,
                );

                _checkAlerts();
                notifyListeners();

                buffer = buffer.substring(endIndex + 1);
              } catch (e) {
                buffer = buffer.substring(endIndex + 1);
              }
            }
          }
        },
        onError: (error) {
          _connectionState = ConnectionState.error;
          _errorMessage = '连接错误: ${error.toString()}';
          _handleHostDisconnected();
          notifyListeners();
        },
        onDone: () {
          if (_connectionState == ConnectionState.connected) {
            _handleHostDisconnected();
          }
        },
        cancelOnError: false,
      );

      await Future.delayed(const Duration(milliseconds: 500));
      await _tcpService!.authenticate(token);
      await Future.delayed(const Duration(milliseconds: 2000));

      if (_connectionState == ConnectionState.connecting) {
        _connectionState = ConnectionState.error;
        _errorMessage = '认证超时，可能是令牌错误或服务器无响应';
        disconnect();
        notifyListeners();
      }
    } on TimeoutException catch (e) {
      _connectionState = ConnectionState.error;
      _errorMessage = e.message ?? '连接超时';
      disconnect();
      notifyListeners();
    } catch (e) {
      _connectionState = ConnectionState.error;
      _errorMessage = '连接失败: ${e.toString()}';
      disconnect();
      notifyListeners();
    }
  }

  int _findMatchingBrace(String str, int startIndex) {
    if (startIndex >= str.length || str[startIndex] != '{') {
      return -1;
    }

    int braceCount = 0;
    for (int i = startIndex; i < str.length; i++) {
      if (str[i] == '{') {
        braceCount++;
      } else if (str[i] == '}') {
        braceCount--;
        if (braceCount == 0) {
          return i;
        }
      }
    }

    return -1;
  }

  void _checkAlerts() {
    if (_systemInfo == null || _currentHost == null) return;

    _alertManager.checkAlerts(
      systemInfo: _systemInfo!,
      hostName: _currentHost!.name,
    );
  }

  void startConnectionMonitoring() {
    _connectionCheckTimer?.cancel();

    _connectionCheckTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _checkConnectionStatus(),
    );
  }

  void stopConnectionMonitoring() {
    _connectionCheckTimer?.cancel();
    _connectionCheckTimer = null;
  }

  Future<void> _checkConnectionStatus() async {
    if (_isCheckingConnection ||
        _connectionState != ConnectionState.connected ||
        _currentHost == null ||
        _lastDataReceived == null) {
      return;
    }

    _isCheckingConnection = true;

    try {
      final timeSinceLastData = DateTime.now().difference(_lastDataReceived!);

      if (timeSinceLastData.inSeconds > settings.hostCheckTimeout) {
        _handleHostDisconnected();
        return;
      }
    } catch (e) {
      // 忽略检测异常
    } finally {
      _isCheckingConnection = false;
    }
  }

  void _handleHostDisconnected() {
    if (_connectionState != ConnectionState.connected) return;

    final hostName = _currentHost?.name ?? '未知主机';

    _connectionState = ConnectionState.error;
    _errorMessage = '主机连接已断开';

    _alertManager.notifyDisconnect(hostName);

    stopAutoRefresh();
    stopConnectionMonitoring();
    _responseSubscription?.cancel();
    _responseSubscription = null;
    _tcpService?.disconnect();
    _tcpService = null;
    _systemInfo = null;
    _metricsHistory.clear();

    notifyListeners();
  }

  Future<void> refreshSystemInfo() async {
    if (_tcpService == null || _connectionState != ConnectionState.connected) {
      return;
    }

    try {
      await _tcpService!.sendCommand('info');
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void startAutoRefresh(int? interval) {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(
      Duration(
        seconds: interval ?? _settings.refreshInterval,
      ),
      (_) => refreshSystemInfo(),
    );
  }

  void stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }

  void disconnect() {
    if (_currentHost != null && _connectionState == ConnectionState.connected) {
      _alertManager.notifyDisconnect(_currentHost!.name);
    }

    stopAutoRefresh();
    stopConnectionMonitoring();
    _responseSubscription?.cancel();
    _responseSubscription = null;
    _tcpService?.disconnect();
    _tcpService = null;
    _connectionState = ConnectionState.disconnected;
    _systemInfo = null;
    _currentHost = null;
    _metricsHistory.clear();
    _lastDataReceived = null;
    notifyListeners();
  }

  /// 获取保存的主机列表
  Future<List<HostConfig>> getSavedHosts() async {
    return await _storageService.getHosts();
  }

  @override
  void dispose() {
    stopAutoRefresh();
    stopConnectionMonitoring();
    _responseSubscription?.cancel();
    _tcpService?.dispose();
    _alertManager.removeListener(() {});
    super.dispose();
  }
}
