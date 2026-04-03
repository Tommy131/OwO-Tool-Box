import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../core/utils/logger.dart';
import '../models/ssl_command_result.dart';
import '../models/ssl_config.dart';
import '../services/ssl_command_service.dart';
import '../services/ssl_storage_service.dart';

/// SSL 模块状态管理中心。
/// 负责配置持久化、命令串行执行以及输出汇总。
class SslCertificateManagerProvider extends ChangeNotifier {
  final SslStorageService _storageService = SslStorageService();
  final SslCommandService _commandService = SslCommandService();

  SslConfig _config = SslConfig.defaults(baseDir: '');
  bool _initialized = false;
  bool _isRunning = false;
  String? _activeAction;
  String _lastOutput = '';

  SslConfig get config => _config;
  bool get initialized => _initialized;
  bool get isRunning => _isRunning;
  String? get activeAction => _activeAction;
  String get lastOutput => _lastOutput;
  bool get isOcspRunning => _commandService.isOcspRunning;
  String get ocspLogs => _commandService.ocspLogs;
  bool get hasValidRootDir {
    final path = _config.baseDir.trim();
    if (path.isEmpty) {
      return false;
    }
    return Directory(path).existsSync();
  }

  bool get hasValidUserConfig => File(_config.userConfigPath).existsSync();
  bool get hasValidOpenSslConfig =>
      File(_config.opensslConfigPath).existsSync();
  bool get canRunActions =>
      hasValidRootDir && hasValidUserConfig && hasValidOpenSslConfig;

  /// 加载持久化配置，仅首次执行。
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _config = await _storageService.loadConfig();
    await saveConfig();
    _initialized = true;
    notifyListeners();
  }

  Future<void> saveConfig() async {
    await _storageService.saveConfig(_config);
  }

  Future<void> saveConfigAndSyncTemplate() async {
    await _storageService.ensureDefaultFiles(_config);
    await _storageService.saveConfig(_config);
    await _storageService.syncUserConfigFromTemplate(_config);
    notifyListeners();
  }

  Future<void> updateConfig(SslConfig config) async {
    _config = config;
    notifyListeners();
  }

  Future<void> initializeStorage() async {
    await _storageService.ensureDefaultFiles(_config);
    await _storageService.syncUserConfigFromTemplate(_config);
    notifyListeners();
  }

  Future<String> loadOpenSslTemplateContent() async {
    return _storageService.readOpenSslTemplate(_config);
  }

  Future<void> saveOpenSslTemplateContent(String content) async {
    await _storageService.writeOpenSslTemplate(_config, content);
    await _storageService.syncUserConfigFromTemplate(_config);
    notifyListeners();
  }

  Future<SslCommandResult> fetchRootCrl() async {
    return _runAction(
      actionName: 'fetch_root_crl',
      action: () async => _commandService.fetchRootCrl(_config),
    );
  }

  Future<SslCommandResult> issueCertificate() async {
    return _runAction(
      actionName: 'issue_certificate',
      action: () async => _commandService.issueCertificate(_config),
    );
  }

  Future<SslCommandResult> startOcspServer() async {
    return _runAction(
      actionName: 'start_ocsp_server',
      action: () async => _commandService.startOcspServer(_config),
    );
  }

  Future<SslCommandResult> stopOcspServer() async {
    return _runAction(
      actionName: 'stop_ocsp_server',
      action: () async => _commandService.stopOcspServer(),
    );
  }

  Future<SslCommandResult> ocspClientVerify() async {
    return _runAction(
      actionName: 'ocsp_client_verify',
      action: () async => _commandService.ocspClientVerify(_config),
    );
  }

  Future<SslCommandResult> ocspStaplingVerify() async {
    return _runAction(
      actionName: 'ocsp_stapling_verify',
      action: () async => _commandService.ocspStaplingVerify(_config),
    );
  }

  Future<SslCommandResult> verifyUrl() async {
    return _runAction(
      actionName: 'verify_url',
      action: () async => _commandService.verifyUrl(_config),
    );
  }

  Future<SslCommandResult> registerToRdpTcp() async {
    return _runAction(
      actionName: 'register_to_rdp_tcp',
      action: () async => _commandService.registerToRdpTcp(_config),
    );
  }

  Future<SslCommandResult> generateCrl() async {
    return _runAction(
      actionName: 'generate_crl',
      action: () async => _commandService.generateCrl(_config),
    );
  }

  Future<SslCommandResult> revokeCertificate() async {
    return _runAction(
      actionName: 'revoke_certificate',
      action: () async => _commandService.revokeCertificate(_config),
    );
  }

  Future<SslCommandResult> _runAction({
    required String actionName,
    required Future<SslCommandResult> Function() action,
  }) async {
    if (!canRunActions) {
      final result = SslCommandResult.error('请先完成SSL根目录与配置文件初始化后再执行功能操作');
      _lastOutput = _buildOutput(result);
      notifyListeners();
      return result;
    }
    if (_isRunning) {
      return SslCommandResult.error('已有命令正在执行，请稍后再试');
    }
    _isRunning = true;
    _activeAction = actionName;
    notifyListeners();

    try {
      final result = await action();
      _lastOutput = _buildOutput(result);
      await saveConfig();

      if (result.success) {
        AppLogger.info('[SslCertificateManager] action=$actionName success');
      } else {
        AppLogger.warning(
          '[SslCertificateManager] action=$actionName failed: ${result.summary}',
        );
      }

      return result;
    } catch (e, stack) {
      AppLogger.error(
        '[SslCertificateManager] action=$actionName error',
        e,
        stack,
      );
      final result = SslCommandResult.error('执行失败', stderr: e.toString());
      _lastOutput = _buildOutput(result);
      return result;
    } finally {
      _isRunning = false;
      _activeAction = null;
      notifyListeners();
    }
  }

  String _buildOutput(SslCommandResult result) {
    final buffer = StringBuffer();
    buffer.writeln(
      '[${result.success ? 'SUCCESS' : 'ERROR'}] ${result.summary}',
    );
    if (result.stdout.trim().isNotEmpty) {
      buffer.writeln(result.stdout.trim());
    }
    if (result.stderr.trim().isNotEmpty) {
      buffer.writeln(result.stderr.trim());
    }
    return buffer.toString().trim();
  }
}
