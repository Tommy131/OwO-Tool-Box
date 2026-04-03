import 'dart:convert';
import 'dart:io';

import '../../../core/utils/logger.dart';
import '../models/ssl_command_result.dart';
import '../models/ssl_config.dart';

class SslCommandService {
  Process? _ocspProcess;
  final StringBuffer _ocspLogs = StringBuffer();

  bool get isOcspRunning => _ocspProcess != null;

  String get ocspLogs => _ocspLogs.toString();

  Future<SslCommandResult> issueCertificate(SslConfig config) async {
    final configReadyResult = await _validateConfigFiles(config);
    if (configReadyResult != null) {
      return configReadyResult;
    }
    final logs = <String>[];

    final rootKeyExists = await File(config.caKeyPath).exists();
    if (!rootKeyExists) {
      logs.add('[INFO] 正在生成根证书密钥...');
      final args = <String>[
        'genrsa',
        '-des3',
        '-traditional',
        '-out',
        config.caKeyPath,
        '2048',
      ];
      if (config.caKeyPassword.isNotEmpty) {
        args.addAll(['-passout', 'pass:${config.caKeyPassword}']);
      }

      final result = await _runCommand(
        'openssl',
        args,
        workingDirectory: config.baseDir,
        config: config,
      );
      if (!result.success) {
        return _mergeStepResult('生成根证书密钥失败', logs, result);
      }
      logs.add('[SUCCESS] 已生成根证书密钥');
    } else {
      logs.add('[INFO] 已存在根证书密钥, 跳过此步骤');
    }

    final rootCertExists = await File(config.caCertPath).exists();
    if (!rootCertExists) {
      logs.add('[INFO] 正在自签根CA证书...');
      final args = <String>[
        'req',
        '-new',
        '-x509',
        '-days',
        config.days.toString(),
        '-key',
        config.caKeyPath,
        '-out',
        config.caCertPath,
        '-config',
        config.userConfigPath,
      ];
      if (config.caKeyPassword.isNotEmpty) {
        args.addAll(['-passin', 'pass:${config.caKeyPassword}']);
      }

      final result = await _runCommand(
        'openssl',
        args,
        workingDirectory: config.baseDir,
        config: config,
      );
      if (!result.success) {
        return _mergeStepResult('自签根CA证书失败', logs, result);
      }
      logs.add('[SUCCESS] 自签根CA证书成功');
    } else {
      logs.add('[INFO] 根CA证书已存在, 跳过此步骤');
    }

    final userKeyExists = await File(config.userKeyPath).exists();
    if (userKeyExists) {
      return SslCommandResult.error(
        "已存在域名 '${config.domain}' 的私钥，请先删除后再签发",
        stderr: logs.join('\n'),
      );
    }

    logs.add('[INFO] 正在生成证书密钥...');
    final userKeyResult = await _runCommand(
      'openssl',
      ['genrsa', '-out', config.userKeyPath, '2048'],
      workingDirectory: config.baseDir,
      config: config,
    );
    if (!userKeyResult.success) {
      return _mergeStepResult('生成证书密钥失败', logs, userKeyResult);
    }
    logs.add('[SUCCESS] 证书密钥生成完成');

    final csrExists = await File(config.csrFilePath).exists();
    if (!csrExists) {
      logs.add('[INFO] 正在生成CSR...');
      final csrResult = await _runCommand(
        'openssl',
        [
          'req',
          '-new',
          '-newkey',
          'rsa:2048',
          '-nodes',
          '-key',
          config.userKeyPath,
          '-out',
          config.csrFilePath,
          '-config',
          config.userConfigPath,
        ],
        workingDirectory: config.baseDir,
        config: config,
      );
      if (!csrResult.success) {
        return _mergeStepResult('生成CSR失败', logs, csrResult);
      }
      logs.add('[SUCCESS] CSR生成完成');
    } else {
      logs.add('[INFO] CSR文件已存在, 跳过此步骤');
    }

    logs.add('[INFO] 正在签发证书...');
    final issueArgs = <String>[
      'ca',
      '-in',
      config.csrFilePath,
      '-out',
      config.userCertPath,
      '-extensions',
      'v3_req',
      '-days',
      config.days.toString(),
      '-config',
      config.userConfigPath,
    ];
    if (config.caKeyPassword.isNotEmpty) {
      issueArgs.addAll(['-passin', 'pass:${config.caKeyPassword}']);
    }
    final issueResult = await _runCommand(
      'openssl',
      issueArgs,
      workingDirectory: config.baseDir,
      config: config,
    );
    if (!issueResult.success) {
      return _mergeStepResult('签发证书失败', logs, issueResult);
    }
    logs.add('[SUCCESS] 证书签发完成');

    final userCertExists = await File(config.userCertPath).exists();
    if (!userCertExists) {
      return SslCommandResult.error(
        '签发完成但未找到证书文件: ${config.userCertPath}',
        stderr: logs.join('\n'),
      );
    }

    logs.add('[INFO] 正在打包PFX...');
    final pfxResult = await _runCommand(
      'openssl',
      [
        'pkcs12',
        '-export',
        '-inkey',
        config.userKeyPath,
        '-in',
        config.userCertPath,
        '-out',
        config.pfxFilePath,
        '-passout',
        'pass:${config.pfxPassword}',
      ],
      workingDirectory: config.baseDir,
      config: config,
    );
    if (!pfxResult.success) {
      return _mergeStepResult('打包PFX失败', logs, pfxResult);
    }
    logs.add('[SUCCESS] 已完成签发与打包');

    return SslCommandResult(
      success: true,
      exitCode: 0,
      stdout: logs.join('\n'),
      stderr: '',
      summary: '签发流程完成',
    );
  }

  Future<SslCommandResult> startOcspServer(SslConfig config) async {
    final configReadyResult = await _validateConfigFiles(config);
    if (configReadyResult != null) {
      return configReadyResult;
    }
    if (_ocspProcess != null) {
      return SslCommandResult.error('OCSP服务已在运行');
    }

    try {
      _ocspLogs.clear();
      final process = await Process.start(
        'openssl',
        [
          'ocsp',
          '-index',
          config.ocspIndexPath,
          '-CA',
          config.caCertPath,
          '-port',
          '8080',
          '-text',
          '-rsigner',
          config.userCertPath,
          '-rkey',
          config.userKeyPath,
          '-timeout',
          '60',
          '-ignore_err',
          '-resp_no_certs',
        ],
        runInShell: true,
        workingDirectory: config.baseDir,
        environment: _buildOpenSslEnvironment(config),
      );
      _ocspProcess = process;
      process.stdout.transform(utf8.decoder).listen((event) {
        _ocspLogs.write(event);
      });
      process.stderr.transform(utf8.decoder).listen((event) {
        _ocspLogs.write(event);
      });
      process.exitCode.then((_) {
        _ocspProcess = null;
      });

      return SslCommandResult(
        success: true,
        exitCode: 0,
        stdout: 'OCSP监听服务已启动(PID=${process.pid})，端口:8080',
        stderr: '',
        summary: 'OCSP服务已启动',
      );
    } catch (e) {
      AppLogger.error('[SslCommandService] Failed to start OCSP service', e);
      return SslCommandResult.error('启动OCSP服务失败', stderr: e.toString());
    }
  }

  Future<SslCommandResult> stopOcspServer() async {
    final process = _ocspProcess;
    if (process == null) {
      return SslCommandResult.error('OCSP服务未运行');
    }
    process.kill(ProcessSignal.sigterm);
    _ocspProcess = null;
    return const SslCommandResult(
      success: true,
      exitCode: 0,
      stdout: 'OCSP服务已停止',
      stderr: '',
      summary: 'OCSP服务已停止',
    );
  }

  Future<SslCommandResult> verifyUrl(SslConfig config) {
    return _runCommand('certutil', ['-url', config.userCertPath]);
  }

  Future<SslCommandResult> registerToRdpTcp(SslConfig config) async {
    final sha1Result = await _readCertificateSha1(config.userCertPath);
    if (!sha1Result.success) {
      return sha1Result;
    }
    final sha1Hash = sha1Result.stdout.trim();
    return _runCommand('wmic', [
      r'/namespace:\\root\cimv2\TerminalServices',
      'PATH',
      'Win32_TSGeneralSetting',
      'Set',
      'SSLCertificateSHA1Hash="$sha1Hash"',
    ]);
  }

  Future<SslCommandResult> ocspClientVerify(SslConfig config) async {
    final serialResult = await _readCertificateSerial(config.serialFilePath);
    if (!serialResult.success) {
      return serialResult;
    }
    return _runCommand(
      'openssl',
      [
        'ocsp',
        '-issuer',
        config.caCertPath,
        '-url',
        config.ocspServerUrl,
        '-serial',
        serialResult.stdout.trim(),
        '-VAfile',
        config.userCertPath,
      ],
      workingDirectory: config.baseDir,
      config: config,
    );
  }

  Future<SslCommandResult> ocspStaplingVerify(SslConfig config) {
    return _runCommand(
      'openssl',
      [
        's_client',
        '-connect',
        config.ip,
        '-servername',
        config.domain,
        '-status',
        '-tlsextdebug',
      ],
      workingDirectory: config.baseDir,
      config: config,
    );
  }

  Future<SslCommandResult> generateCrl(SslConfig config) {
    final args = <String>[
      'ca',
      '-gencrl',
      '-out',
      config.crlPath,
      '-cert',
      config.caCertPath,
      '-keyfile',
      config.caKeyPath,
      '-config',
      config.userConfigPath,
    ];
    if (config.caKeyPassword.isNotEmpty) {
      args.addAll(['-passin', 'pass:${config.caKeyPassword}']);
    }
    return _runCommand(
      'openssl',
      args,
      workingDirectory: config.baseDir,
      config: config,
    );
  }

  Future<SslCommandResult> revokeCertificate(SslConfig config) async {
    final certFile = File(config.revocationCertPath);
    if (!await certFile.exists()) {
      return SslCommandResult.error('证书不存在: ${config.revocationCertPath}');
    }

    final args = <String>[
      'ca',
      '-revoke',
      config.revocationCertPath,
      '-cert',
      config.caCertPath,
      '-keyfile',
      config.caKeyPath,
      '-config',
      config.userConfigPath,
    ];
    if (config.caKeyPassword.isNotEmpty) {
      args.addAll(['-passin', 'pass:${config.caKeyPassword}']);
    }
    return _runCommand(
      'openssl',
      args,
      workingDirectory: config.baseDir,
      config: config,
    );
  }

  Future<SslCommandResult> fetchRootCrl(SslConfig config) {
    return _runCommand('certutil', [
      '-urlcache',
      '-split',
      '-f',
      config.crlUrl,
      config.crlPath,
    ], workingDirectory: config.baseDir);
  }

  Future<SslCommandResult> _runCommand(
    String executable,
    List<String> args, {
    String? workingDirectory,
    SslConfig? config,
  }) async {
    try {
      final result = await Process.run(
        executable,
        args,
        runInShell: true,
        workingDirectory: workingDirectory,
        environment: executable == 'openssl' && config != null
            ? _buildOpenSslEnvironment(config)
            : null,
      );
      final success = result.exitCode == 0;
      return SslCommandResult(
        success: success,
        exitCode: result.exitCode,
        stdout: result.stdout.toString(),
        stderr: result.stderr.toString(),
        summary: success ? '执行成功' : '执行失败(ExitCode=${result.exitCode})',
      );
    } catch (e) {
      AppLogger.error('[SslCommandService] Command failed: $executable', e);
      return SslCommandResult.error(
        '执行命令失败: $executable',
        stderr: e.toString(),
      );
    }
  }

  Future<SslCommandResult?> _validateConfigFiles(SslConfig config) async {
    final rootExists = await Directory(config.baseDir).exists();
    if (!rootExists) {
      return SslCommandResult.error('SSL根目录不存在: ${config.baseDir}');
    }
    final userConfigExists = await File(config.userConfigPath).exists();
    if (!userConfigExists) {
      return SslCommandResult.error('用户配置文件不存在: ${config.userConfigPath}');
    }
    final opensslConfigExists = await File(config.opensslConfigPath).exists();
    if (!opensslConfigExists) {
      return SslCommandResult.error(
        'OpenSSL配置文件不存在: ${config.opensslConfigPath}',
      );
    }
    return null;
  }

  Map<String, String> _buildOpenSslEnvironment(SslConfig config) {
    return {'OPENSSL_CONF': config.opensslConfigPath};
  }

  Future<SslCommandResult> _readCertificateSerial(String serialFilePath) async {
    final serialFile = File(serialFilePath);
    if (!await serialFile.exists()) {
      return SslCommandResult.error('序列号文件不存在: $serialFilePath');
    }
    final content = await serialFile.readAsString();
    final serial = content.trim();
    if (serial.isEmpty) {
      return SslCommandResult.error('序列号文件为空: $serialFilePath');
    }
    return SslCommandResult(
      success: true,
      exitCode: 0,
      stdout: serial,
      stderr: '',
      summary: '读取证书序列号成功',
    );
  }

  Future<SslCommandResult> _readCertificateSha1(String certPath) async {
    final certExists = await File(certPath).exists();
    if (!certExists) {
      return SslCommandResult.error('证书文件不存在: $certPath');
    }
    final result = await _runCommand('openssl', [
      'x509',
      '-in',
      certPath,
      '-noout',
      '-fingerprint',
      '-sha1',
    ]);
    if (!result.success) {
      return result;
    }
    final line = result.stdout
        .split('\n')
        .map((e) => e.trim())
        .firstWhere((e) => e.contains('='), orElse: () => '');
    if (line.isEmpty) {
      return SslCommandResult.error('无法解析证书SHA1指纹');
    }
    final hash = line.split('=').last.replaceAll(':', '').trim();
    if (hash.isEmpty) {
      return SslCommandResult.error('证书SHA1指纹为空');
    }
    return SslCommandResult(
      success: true,
      exitCode: 0,
      stdout: hash,
      stderr: '',
      summary: '读取证书SHA1指纹成功',
    );
  }

  SslCommandResult _mergeStepResult(
    String summary,
    List<String> logs,
    SslCommandResult result,
  ) {
    final output = StringBuffer();
    if (logs.isNotEmpty) {
      output.writeln(logs.join('\n'));
    }
    if (result.stdout.isNotEmpty) {
      output.writeln(result.stdout);
    }
    return SslCommandResult(
      success: false,
      exitCode: result.exitCode,
      stdout: output.toString().trim(),
      stderr: result.stderr,
      summary: summary,
    );
  }
}
