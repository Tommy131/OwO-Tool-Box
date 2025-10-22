/*
 *        _____   _          __  _____   _____   _       _____   _____
 *      /  _  \ | |        / / /  _  \ |  _  \ | |     /  _  \ /  ___|
 *      | | | | | |  __   / /  | | | | | |_| | | |     | | | | | |
 *      | | | | | | /  | / /   | | | | |  _  { | |     | | | | | |   _
 *      | |_| | | |/   |/ /    | |_| | | |_| | | |___  | |_| | | |_| |
 *      \_____/ |___/|___/     \_____/ |_____/ |_____| \_____/ \_____/
 *
 *  Copyright (c) 2023 by OwOTeam-DGMT (OwOBlog).
 * @Date         : 2025-10-18
 * @Author       : HanskiJay
 * @LastEditors  : HanskiJay
 * @LastEditTime : 2025-10-18
 * @E-Mail       : support@owoblog.com
 * @Telegram     : https://t.me/HanskiJay
 * @GitHub       : https://github.com/Tommy131
 */

// lib/providers/screen_provider.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/utils/logger.dart';
import '../my_models/host_model.dart';
import '../my_models/host_monitor_settings_model.dart';
import '../my_models/metrics_history_model.dart';
import '../my_models/system_info_model.dart';
import '../my_services/alert_service.dart';
import '../my_services/host_service.dart';
import '../my_services/storage_service.dart';

// ==================== 连接状态枚举 ====================
/// 主机连接状态
enum ConnectionState {
  disconnected, // 未连接
  connecting, // 连接中
  connected, // 已连接
  error, // 连接错误
}

// ==================== 屏幕状态提供者 ====================
/// 统一管理所有服务实例和应用状态
///
/// 核心功能:
/// - 主机连接管理
/// - 系统信息监控
/// - 指标历史记录
/// - 告警管理
/// - 设置持久化
///
/// 使用方式:
/// 在 main.dart 中注册
/// ChangeNotifierProvider(create: (_) => HostMonitorProvider()..initialize())
///
/// 在页面中使用
/// final provider = context.watch<HostMonitorProvider>();
class HostMonitorProvider with ChangeNotifier {
  // ==================== 服务实例 ====================

  /// 存储服务（用于持久化配置和主机列表）
  StorageService? _storageService;

  /// 告警服务（监控告警和通知）
  final AlertService _alertService = AlertService();

  // ==================== 状态变量 ====================

  /// 当前连接的主机
  HostModel? _currentHost;

  /// 连接状态
  ConnectionState _connectionState = ConnectionState.disconnected;

  /// 错误消息
  String? _errorMessage;

  /// 当前系统信息
  SystemInfoModel? _systemInfo;

  /// 监控设置
  late HostMonitorSettingsModel _settings;

  /// 指标历史记录
  final MetricsHistoryModel _metricsHistory = MetricsHistoryModel();

  // ==================== 定时器 ====================

  /// 自动刷新定时器
  Timer? _autoRefreshTimer;

  /// 连接检测定时器
  Timer? _connectionCheckTimer;

  /// 响应流订阅
  StreamSubscription<String>? _responseSubscription;

  /// 最后接收数据时间
  DateTime? _lastDataReceived;

  /// 是否正在检查连接
  bool _isCheckingConnection = false;

  // ==================== 公共 Getter ====================

  /// 获取当前主机
  HostModel? get currentHost => _currentHost;

  /// 获取连接状态
  ConnectionState get connectionState => _connectionState;

  /// 获取错误消息
  String? get errorMessage => _errorMessage;

  /// 获取系统信息
  SystemInfoModel? get systemInfo => _systemInfo;

  /// 获取监控设置
  HostMonitorSettingsModel get settings => _settings;

  /// 获取指标历史
  MetricsHistoryModel get metricsHistory => _metricsHistory;

  /// 获取告警服务
  AlertService get alertService => _alertService;

  // 获取存储服务
  StorageService? get storageService => _storageService;

  /// 是否已连接
  bool get isConnected => _connectionState == ConnectionState.connected;

  /// 是否正在连接
  bool get isConnecting => _connectionState == ConnectionState.connecting;

  // ==================== 新增：数据去重和节流控制相关变量 ====================

  /// 上次处理的系统信息哈希值（用于去重）
  String? _lastProcessedHash;

  /// 节流定时器
  Timer? _throttleTimer;

  /// 节流间隔（毫秒）
  static const int _throttleInterval = 500;

  /// 待处理的系统信息
  SystemInfoModel? _pendingSystemInfo;

  /// 是否有待处理的更新
  bool _hasPendingUpdate = false;

  /// 数据缓冲区（改为实例变量）
  String _dataBuffer = '';

  // ==================== 初始化方法 ====================

  /// 初始化 Provider
  ///
  /// 加载存储服务、设置和告警服务
  Future<void> initialize() async {
    AppLogger.debug('[HostMonitorProvider] 开始初始化...');

    try {
      // 初始化存储服务
      _storageService = await StorageService.create();

      // 加载设置
      _settings = await _storageService!.getSettings();

      // 初始化告警服务
      await _alertService.initialize();

      // 监听告警服务变化
      _alertService.addListener(_onAlertServiceChanged);

      AppLogger.debug('[HostMonitorProvider] 初始化完成');
      notifyListeners();
    } catch (e) {
      AppLogger.error('[HostMonitorProvider] 初始化失败', e);
    }
  }

  /// 告警服务变化回调
  void _onAlertServiceChanged() {
    notifyListeners();
  }

  // ==================== 设置管理 ====================

  /// 更新监控设置
  ///
  /// 参数:
  /// - settings: 新的设置对象
  Future<void> updateSettings(HostMonitorSettingsModel settings) async {
    try {
      _settings = settings;
      await _storageService?.saveSettings(settings);
      await _alertService.updateSettings(settings);

      // 如果已连接，重启自动刷新定时器
      if (isConnected) {
        _stopAutoRefresh();
        _startAutoRefresh();
      }

      AppLogger.debug('[HostMonitorProvider] 设置已更新');
      notifyListeners();
    } catch (e) {
      AppLogger.error('[HostMonitorProvider] 更新设置失败', e);
    }
  }

  // ==================== 主机管理 ====================

  /// 获取保存的主机列表
  ///
  /// 返回值: Future<List<HostModel>> - 主机列表
  Future<List<HostModel>> getSavedHosts() async {
    if (_storageService == null) {
      await initialize();
    }
    return await _storageService!.getHosts();
  }

  /// 更新当前主机（不触发连接）
  ///
  /// 参数:
  /// - host: 主机对象
  void updateCurrentHost(HostModel host) {
    _currentHost = host;
    notifyListeners();
  }

  // ==================== 连接管理 ====================

  /// 连接到主机
  ///
  /// 参数:
  /// - host: 主机对象
  ///
  /// 返回值: Future<bool> - 连接是否成功
  Future<bool> connect(HostModel host) async {
    AppLogger.debug('[HostMonitorProvider] 开始连接主机: ${host.name}');

    // 更新状态为连接中
    _connectionState = ConnectionState.connecting;
    _errorMessage = null;
    _currentHost = host;
    _lastDataReceived = DateTime.now();
    _dataBuffer = ''; // ← 重置缓冲区
    _lastProcessedHash = null; // ← 重置哈希值
    notifyListeners();

    try {
      // 使用 HostService 连接
      final connected = await HostService.connect(
        host,
        timeout: Duration(seconds: _settings.hostCheckTimeout),
      );

      if (!connected) {
        throw Exception('无法连接到服务器');
      }

      // 监听响应流
      _subscribeToHostResponse(host.id);

      // 发送认证
      await Future.delayed(const Duration(milliseconds: 500));
      final authenticated = await HostService.authenticate(host.id);

      if (!authenticated) {
        throw Exception('认证失败');
      }

      // 等待认证响应
      await Future.delayed(const Duration(seconds: 2));

      // 检查连接状态
      if (_connectionState == ConnectionState.connecting) {
        throw Exception('认证超时');
      }

      return true;
    } catch (e) {
      AppLogger.error('[HostMonitorProvider] 连接失败', e);
      _connectionState = ConnectionState.error;
      _errorMessage = '连接失败: ${e.toString()}';
      disconnect();
      notifyListeners();
      return false;
    }
  }

  /// 订阅主机响应流
  ///
  /// 参数:
  /// - hostId: 主机 ID
  void _subscribeToHostResponse(String hostId) {
    final responseStream = HostService.getResponseStream(hostId);

    if (responseStream == null) {
      AppLogger.warning('[HostMonitorProvider] 无法获取响应流');
      return;
    }

    bool isAuthenticated = false;

    _responseSubscription = responseStream.listen(
      (data) {
        _lastDataReceived = DateTime.now();
        _dataBuffer += data;

        // 处理认证失败
        if (!isAuthenticated && _dataBuffer.contains('错误: 令牌验证失败')) {
          _connectionState = ConnectionState.error;
          _errorMessage = 'TOKEN_VERIFICATION_FAILED';
          disconnect();
          notifyListeners();
          return;
        }

        // 处理认证成功
        if (!isAuthenticated && _dataBuffer.contains('验证成功')) {
          isAuthenticated = true;
          _onConnectionEstablished();
          return;
        }

        // 处理系统信息数据（使用优化后的方法）
        if (isAuthenticated) {
          _processSystemInfoBuffer(); // ← 这里改用优化方法
        }
      },
      onError: (error) {
        AppLogger.error('[HostMonitorProvider] 响应流错误', error);
        _handleDisconnection();
      },
      onDone: () {
        if (isConnected) {
          _handleDisconnection();
        }
      },
      cancelOnError: false,
    );
  }

  /// 连接建立完成回调
  void _onConnectionEstablished() {
    _connectionState = ConnectionState.connected;

    // 更新主机最后连接时间
    if (_currentHost != null) {
      _currentHost = _currentHost!.copyWith(
        lastConnected: DateTime.now(),
      );
      _storageService?.updateHost(_currentHost!);
    }

    AppLogger.debug('[HostMonitorProvider] 连接已建立');

    // 启动自动刷新和连接监控
    _startAutoRefresh();
    _startConnectionMonitoring();

    notifyListeners();
  }

  /// 处理系统信息缓冲区
  ///
  /// 参数:
  /// - buffer: 数据缓冲区
  /// 优化的系统信息缓冲区处理（带去重和节流）
  void _processSystemInfoBuffer() {
    while (_dataBuffer.contains('{') && _dataBuffer.contains('}')) {
      final startIndex = _dataBuffer.indexOf('{');
      final endIndex = _findMatchingBrace(_dataBuffer, startIndex);

      if (endIndex == -1) break;

      final jsonStr = _dataBuffer.substring(startIndex, endIndex + 1);

      try {
        // 计算数据哈希值
        final currentHash = jsonStr.hashCode.toString();

        // 去重检查：如果与上次处理的数据相同，跳过
        if (_lastProcessedHash == currentHash) {
          AppLogger.debug('[HostMonitorProvider] 跳过重复数据');
          _dataBuffer = _dataBuffer.substring(endIndex + 1);
          continue;
        }

        final jsonData = json.decode(jsonStr);
        final newSystemInfo = SystemInfoModel.fromJson(jsonData);

        // 更新哈希值
        _lastProcessedHash = currentHash;

        // 使用节流机制更新UI
        _throttledUpdate(newSystemInfo);
      } catch (e) {
        AppLogger.debug('[HostMonitorProvider] JSON 解析失败: $e');
      }

      _dataBuffer = _dataBuffer.substring(endIndex + 1);
    }
  }

  /// 节流更新UI
  ///
  /// 在指定时间间隔内只执行一次更新，避免频繁刷新
  void _throttledUpdate(SystemInfoModel newSystemInfo) {
    _pendingSystemInfo = newSystemInfo;
    _hasPendingUpdate = true;

    // 如果已有节流定时器在运行，等待它完成
    if (_throttleTimer?.isActive ?? false) {
      return;
    }

    // 立即执行第一次更新
    _applyUpdate();

    // 启动节流定时器
    _throttleTimer = Timer(
      const Duration(milliseconds: _throttleInterval),
      () {
        if (_hasPendingUpdate) {
          _applyUpdate();
        }
      },
    );
  }

  /// 应用更新到UI
  void _applyUpdate() {
    if (_pendingSystemInfo == null) return;

    _systemInfo = _pendingSystemInfo;
    _hasPendingUpdate = false;

    // 添加指标数据点
    _metricsHistory.addDataPoint(
      _systemInfo!.cpuUsagePercent,
      _systemInfo!.memoryUsagePercent,
      _systemInfo!.diskAvgUsagePercent,
      _systemInfo!.totalUploadSpeed / 1024,
      _systemInfo!.totalDownloadSpeed / 1024,
      _systemInfo!.loadAverage.load1min,
      _systemInfo!.loadAverage.load5min,
      _systemInfo!.loadAverage.load15min,
    );

    // 检查告警
    _checkAlerts();

    // 通知UI更新
    notifyListeners();
  }

  /// 停止节流定时器
  void _stopThrottleTimer() {
    _throttleTimer?.cancel();
    _throttleTimer = null;
  }

  /// 查找匹配的右括号
  ///
  /// 参数:
  /// - str: 字符串
  /// - startIndex: 起始索引
  ///
  /// 返回值: int - 匹配括号的索引，-1 表示未找到
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

  /// 断开连接
  void disconnect() {
    AppLogger.debug('[HostMonitorProvider] 断开连接');

    // 通知告警服务
    if (_currentHost != null && isConnected) {
      _alertService.notifyDisconnect(_currentHost!.name);
    }

    // 停止定时器
    _stopAutoRefresh();
    _stopConnectionMonitoring();

    // 取消订阅
    _responseSubscription?.cancel();
    _responseSubscription = null;

    // 断开主机服务连接
    if (_currentHost != null) {
      HostService.disconnect(_currentHost!.id);
    }

    // 重置状态
    _connectionState = ConnectionState.disconnected;
    _systemInfo = null;
    _currentHost = null;
    _metricsHistory.clear();
    _lastDataReceived = null;
    _dataBuffer = ''; // ← 清空缓冲区
    _lastProcessedHash = null; // ← 重置哈希值
    _pendingSystemInfo = null; // ← 清空待处理数据
    _hasPendingUpdate = false; // ← 重置更新标志

    notifyListeners();
  }

  /// 处理断开连接
  void _handleDisconnection() {
    if (!isConnected) return;

    final hostName = _currentHost?.name ?? '未知主机';
    AppLogger.debug('[HostMonitorProvider] 主机断开连接: $hostName');

    _connectionState = ConnectionState.error;
    _errorMessage = '主机连接已断开';

    _alertService.notifyDisconnect(hostName);

    disconnect();
  }

  // ==================== 告警检测 ====================

  /// 检查告警
  void _checkAlerts() {
    if (_systemInfo == null || _currentHost == null) return;

    _alertService.checkAlerts(
      systemInfo: _systemInfo!,
      hostName: _currentHost!.name,
    );
  }

  // ==================== 数据刷新 ====================

  /// 刷新系统信息
  ///
  /// 通过发送 'info' 命令请求最新数据
  Future<void> refreshSystemInfo() async {
    if (_currentHost == null || !isConnected) {
      return;
    }

    try {
      await HostService.sendCommand(_currentHost!.id, 'info');
    } catch (e) {
      AppLogger.error('[HostMonitorProvider] 刷新系统信息失败', e);
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// 启动自动刷新
  void _startAutoRefresh() {
    _stopAutoRefresh();

    final interval = Duration(seconds: _settings.refreshInterval);
    _autoRefreshTimer = Timer.periodic(interval, (_) => refreshSystemInfo());

    AppLogger.debug(
        '[HostMonitorProvider] 自动刷新已启动 (间隔: ${_settings.refreshInterval}s)');
  }

  /// 停止自动刷新
  void _stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }

  // ==================== 连接监控 ====================

  /// 启动连接监控
  void _startConnectionMonitoring() {
    _stopConnectionMonitoring();

    _connectionCheckTimer = Timer.periodic(
      Duration(seconds: _settings.hostCheckTimeout),
      (_) => _checkConnectionStatus(),
    );

    AppLogger.debug('[HostMonitorProvider] 连接监控已启动');
  }

  /// 停止连接监控
  void _stopConnectionMonitoring() {
    _connectionCheckTimer?.cancel();
    _connectionCheckTimer = null;
  }

  /// 检查连接状态
  Future<void> _checkConnectionStatus() async {
    if (_isCheckingConnection ||
        !isConnected ||
        _currentHost == null ||
        _lastDataReceived == null) {
      return;
    }

    _isCheckingConnection = true;

    try {
      final timeSinceLastData = DateTime.now().difference(_lastDataReceived!);

      // 超过指定时间未接收数据，视为断开
      if (timeSinceLastData.inSeconds > _settings.hostCheckTimeout * 2) {
        AppLogger.warning(
            '[HostMonitorProvider] 连接超时，最后数据时间: $_lastDataReceived');
        _handleDisconnection();
      }
    } catch (e) {
      AppLogger.error('[HostMonitorProvider] 检查连接状态失败', e);
    } finally {
      _isCheckingConnection = false;
    }
  }

  // ==================== 资源清理 ====================

  @override
  void dispose() {
    AppLogger.debug('[HostMonitorProvider] 开始清理资源...');

    // 停止所有定时器
    _stopAutoRefresh();
    _stopConnectionMonitoring();
    _stopThrottleTimer(); // ← 清理节流定时器

    // 取消订阅
    _responseSubscription?.cancel();

    // 断开所有连接
    HostService.disconnectAll();

    // 移除监听器
    _alertService.removeListener(_onAlertServiceChanged);

    super.dispose();

    AppLogger.debug('[HostMonitorProvider] 资源清理完成');
  }
}
