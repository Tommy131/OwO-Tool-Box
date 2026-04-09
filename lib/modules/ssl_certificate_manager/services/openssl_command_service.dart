import 'dart:async';
import 'dart:io';

import '../../../core/utils/logger.dart';
import '../models/ssl_models.dart';

class SslIssueExecutionResult {
  const SslIssueExecutionResult({
    required this.success,
    required this.message,
    this.record,
  });

  final bool success;
  final String message;
  final SslCertificateRecord? record;
}

class IssuedCertificateMeta {
  const IssuedCertificateMeta({
    required this.issuedAt,
    required this.expiresAt,
    required this.serialNumber,
    required this.issuer,
  });

  final DateTime issuedAt;
  final DateTime expiresAt;
  final String serialNumber;
  final String issuer;
}

class RootCaValidationResult {
  const RootCaValidationResult._({
    required this.isValid,
    required this.message,
    required this.details,
  });

  final bool isValid;
  final String message;
  final Map<String, String> details;

  factory RootCaValidationResult.valid(Map<String, String> details) {
    return RootCaValidationResult._(
      isValid: true,
      message: '校验成功',
      details: details,
    );
  }

  factory RootCaValidationResult.invalid(String message) {
    return RootCaValidationResult._(
      isValid: false,
      message: message,
      details: const <String, String>{},
    );
  }
}

class PrivateKeyPasswordCheckResult {
  const PrivateKeyPasswordCheckResult._({
    required this.isValid,
    required this.isEncrypted,
    required this.message,
  });

  final bool isValid;
  final bool isEncrypted;
  final String message;

  factory PrivateKeyPasswordCheckResult.valid({required bool isEncrypted}) {
    return PrivateKeyPasswordCheckResult._(
      isValid: true,
      isEncrypted: isEncrypted,
      message: '校验成功',
    );
  }

  factory PrivateKeyPasswordCheckResult.invalid(String message) {
    return PrivateKeyPasswordCheckResult._(
      isValid: false,
      isEncrypted: false,
      message: message,
    );
  }
}

class OpenSslCommandService {
  OpenSslCommandService._();

  static Future<ProcessResult?> runOpenSsl(
    List<String> args, {
    String? workingDirectory,
    Duration timeout = const Duration(seconds: 8),
  }) async {
    try {
      final result = await Process.run(
        'openssl',
        args,
        workingDirectory: workingDirectory,
      ).timeout(timeout);
      return result;
    } on TimeoutException {
      AppLogger.error(
        '[SSL] openssl command timeout: openssl ${_sanitizeOpenSslArgs(args)}',
      );
      return null;
    } catch (e, st) {
      AppLogger.error(
        '[SSL] openssl command failed: openssl ${_sanitizeOpenSslArgs(args)}',
        e,
        st,
      );
      return null;
    }
  }

  static Future<ProcessResult> runOpenSslOrThrow(
    List<String> args, {
    required String action,
    String? workingDirectory,
    Duration timeout = const Duration(seconds: 8),
  }) async {
    final result = await runOpenSsl(
      args,
      workingDirectory: workingDirectory,
      timeout: timeout,
    );
    if (result == null) {
      throw Exception('$action失败：无法调用 openssl，请确认已安装且可在 PATH 中找到。');
    }
    if (result.exitCode != 0) {
      throw Exception('$action失败：${_extractOpenSslFailure(result)}');
    }
    return result;
  }

  static Future<void> ensureOpenSslAvailable() async {
    final result = await runOpenSsl(['version']);
    if (result == null || result.exitCode != 0) {
      throw Exception('未检测到可用的 openssl，请先安装并确保命令行可直接执行 openssl。');
    }
  }

  static Future<Map<String, String>?> readCertificateMetaByOpenSsl(
    String certPath,
  ) async {
    try {
      final result = await runOpenSsl([
        'x509',
        '-in',
        certPath,
        '-noout',
        '-subject',
        '-issuer',
        '-serial',
        '-startdate',
        '-enddate',
        '-fingerprint',
        '-sha256',
      ]);
      if (result == null || result.exitCode != 0) {
        return null;
      }

      final details = <String, String>{};
      final lines = result.stdout.toString().split('\n');
      for (final raw in lines) {
        final line = raw.trim();
        if (line.isEmpty) continue;
        if (line.startsWith('subject=')) {
          details['Subject'] = line.substring('subject='.length).trim();
        } else if (line.startsWith('issuer=')) {
          details['Issuer'] = line.substring('issuer='.length).trim();
        } else if (line.startsWith('serial=')) {
          details['Serial'] = line.substring('serial='.length).trim();
        } else if (line.startsWith('notBefore=')) {
          details['Not Before'] = line.substring('notBefore='.length).trim();
        } else if (line.startsWith('notAfter=')) {
          details['Not After'] = line.substring('notAfter='.length).trim();
        } else if (line.startsWith('sha256 Fingerprint=')) {
          details['SHA256 Fingerprint'] = line
              .substring('sha256 Fingerprint='.length)
              .trim();
        }
      }

      if (!details.containsKey('Subject') ||
          !details.containsKey('Not After')) {
        return null;
      }
      return details;
    } catch (e, st) {
      AppLogger.error('[SSL] read cert metadata failed', e, st);
      return null;
    }
  }

  static Future<IssuedCertificateMeta?> readIssuedCertificateMeta(
    String certPath,
  ) async {
    final details = await readCertificateMetaByOpenSsl(certPath);
    if (details == null || details.isEmpty) {
      return null;
    }

    final issuedAt = parseOpenSslDate(details['Not Before']);
    final expiresAt = parseOpenSslDate(details['Not After']);
    final serialNumber = (details['Serial'] ?? '').trim();
    if (issuedAt == null || expiresAt == null || serialNumber.isEmpty) {
      return null;
    }

    final issuerLine = (details['Issuer'] ?? '').trim();
    return IssuedCertificateMeta(
      issuedAt: issuedAt,
      expiresAt: expiresAt,
      serialNumber: serialNumber,
      issuer: extractCommonName(issuerLine) ?? issuerLine,
    );
  }

  static Future<PrivateKeyPasswordCheckResult> verifyImportedPrivateKeyPassword(
    String keyPath,
    String password,
  ) async {
    try {
      // 使用空密码参数避免 openssl 进入交互阻塞。
      final plainRead = await runOpenSsl([
        'pkey',
        '-in',
        keyPath,
        '-noout',
        '-passin',
        'pass:',
      ]);
      if (plainRead != null && plainRead.exitCode == 0) {
        AppLogger.debug('[SSL] private key can be read without password');
        return PrivateKeyPasswordCheckResult.valid(isEncrypted: false);
      }

      if (password.trim().isEmpty) {
        return PrivateKeyPasswordCheckResult.invalid('私钥疑似已加密，请填写正确的私钥密码后再继续。');
      }

      final passRead = await runOpenSsl([
        'pkey',
        '-in',
        keyPath,
        '-noout',
        '-passin',
        'pass:$password',
      ]);
      if (passRead == null || passRead.exitCode != 0) {
        AppLogger.warning('[SSL] private key password incorrect');
        return PrivateKeyPasswordCheckResult.invalid('私钥密码错误，无法解锁该私钥。');
      }
      AppLogger.debug('[SSL] private key unlocked by provided password');
      return PrivateKeyPasswordCheckResult.valid(isEncrypted: true);
    } catch (e, st) {
      AppLogger.error(
        '[SSL] openssl unavailable when verifying private key',
        e,
        st,
      );
      return PrivateKeyPasswordCheckResult.invalid(
        '无法调用 openssl 校验私钥密码，请确认 openssl 已正确安装。',
      );
    }
  }

  static Future<bool?> verifyCertificateKeyMatch({
    required String certPath,
    required String keyPath,
    required bool usePassword,
    required String password,
  }) async {
    try {
      final certPub = await runOpenSsl([
        'x509',
        '-in',
        certPath,
        '-pubkey',
        '-noout',
      ]);
      if (certPub == null || certPub.exitCode != 0) {
        return null;
      }

      final keyArgs = <String>['pkey', '-in', keyPath, '-pubout'];
      if (usePassword) {
        keyArgs.addAll(['-passin', 'pass:$password']);
      } else {
        // 非交互模式读取，防止 openssl 等待终端输入导致界面无响应。
        keyArgs.addAll(['-passin', 'pass:']);
      }
      final keyPub = await runOpenSsl(keyArgs);
      if (keyPub == null || keyPub.exitCode != 0) {
        return null;
      }

      final certNormalized = certPub.stdout.toString().replaceAll(
        RegExp(r'\s+'),
        '',
      );
      final keyNormalized = keyPub.stdout.toString().replaceAll(
        RegExp(r'\s+'),
        '',
      );
      if (certNormalized.isEmpty || keyNormalized.isEmpty) {
        return null;
      }
      return certNormalized == keyNormalized;
    } catch (e, st) {
      AppLogger.error('[SSL] verify cert-key match failed', e, st);
      return null;
    }
  }

  static DateTime? parseOpenSslDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    final normalized = raw.trim();
    final match = RegExp(
      r'^([A-Za-z]{3})\s+(\d{1,2})\s+(\d\d):(\d\d):(\d\d)\s+(\d{4})\s+GMT$',
    ).firstMatch(normalized);
    if (match == null) {
      return DateTime.tryParse(normalized)?.toLocal();
    }

    const months = <String, int>{
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'May': 5,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12,
    };
    final month = months[match.group(1)];
    if (month == null) {
      return null;
    }
    return DateTime.utc(
      int.parse(match.group(6)!),
      month,
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
      int.parse(match.group(4)!),
      int.parse(match.group(5)!),
    ).toLocal();
  }

  static String? extractCommonName(String issuerText) {
    final compact = issuerText.trim();
    final slashMatch = RegExp(r'(?:^|/)CN\s*=\s*([^/]+)').firstMatch(compact);
    if (slashMatch != null) {
      return slashMatch.group(1)?.trim();
    }
    final commaMatch = RegExp(r'CN\s*=\s*([^,]+)').firstMatch(compact);
    return commaMatch?.group(1)?.trim();
  }

  static String _extractOpenSslFailure(ProcessResult result) {
    final stderrText = result.stderr.toString().trim();
    final stdoutText = result.stdout.toString().trim();
    final message = stderrText.isNotEmpty ? stderrText : stdoutText;
    if (message.isEmpty) {
      return 'openssl 退出码 ${result.exitCode}';
    }
    return message
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .join(' | ');
  }

  static String _sanitizeOpenSslArgs(List<String> args) {
    final sanitized = <String>[];
    for (int i = 0; i < args.length; i++) {
      final current = args[i];
      sanitized.add(current);
      if ((current == '-passin' ||
              current == '-passout' ||
              current == '-pass') &&
          i + 1 < args.length) {
        sanitized.add('***');
        i++;
      }
    }
    return sanitized.join(' ');
  }
}
