import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../../../core/utils/logger.dart';
import '../../../core/widgets/common/dialog.dart';
import '../models/ssl_models.dart';
import '../services/openssl_command_service.dart';
import 'ssl_provider_base.dart';

/// Revocation, CRL generation, batch operations, and certificate deletion.
mixin SslRevocationMixin on SslProviderBase {
  // ────────────────── revocation ──────────────────

  Future<void> revokeCertificate(String certificateId) async {
    if (!await ensureStorageAvailableOrRecover()) {
      notifyListeners();
      return;
    }
    isLoading = true;
    notifyListeners();
    AppLogger.info('[SSL] revokeCertificate start, id=$certificateId');
    try {
      final index = certificateRecords.indexWhere((e) => e.id == certificateId);
      if (index < 0) return;

      final reason = revokeReasonController.text.trim().isEmpty
          ? '用户手动撤销'
          : revokeReasonController.text.trim();
      final revokedAt = DateTime.now();
      certificateRecords[index] = certificateRecords[index].copyWith(
        status: SslCertStatus.revoked,
        revokeReason: reason,
        revokedAt: revokedAt,
      );
      final revokeLog = File(p.join(configData.storagePath, 'revoke.log'));
      await revokeLog.writeAsString(
        '[${revokedAt.toIso8601String()}] revoke serial=${certificateRecords[index].serialNumber}, reason=$reason\n',
        mode: FileMode.append,
      );
      infoMessage = '证书已撤销。';
      addAuditEntry(
        AuditAction.revoke,
        '撤销: ${certificateRecords[index].domain} (SN: ${certificateRecords[index].serialNumber})',
      );
      AppLogger.info('[SSL] revokeCertificate success, id=$certificateId');
      await persistAll();
      // Auto-generate CRL after revocation (best-effort, don't block)
      try {
        await generateCrl(force: true);
      } catch (e) {
        AppLogger.warning('[SSL] auto CRL generation after revoke failed: $e');
      }
    } catch (e) {
      infoMessage = '撤销失败: $e';
      AppLogger.error('[SSL] revokeCertificate failed', e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ────────────────── deletion ──────────────────

  Future<void> deleteCertificate(String certificateId) async {
    if (!await ensureStorageAvailableOrRecover()) {
      notifyListeners();
      return;
    }
    AppLogger.info('[SSL] deleteCertificate start, id=$certificateId');
    final index = certificateRecords.indexWhere((e) => e.id == certificateId);
    if (index < 0) return;

    final item = certificateRecords[index];
    certificateRecords.removeAt(index);
    if (selectedCertId == certificateId) {
      selectedCertId = null;
    }
    infoMessage = '证书记录已删除。';
    addAuditEntry(
      AuditAction.delete,
      '删除: ${item.domain} (SN: ${item.serialNumber})',
    );

    await _deleteIfExists(item.configFilePath);
    await _deleteIfExists(item.certFilePath);
    await _deleteIfExists(item.keyFilePath);
    await _deleteIfExists(item.csrFilePath);
    await persistAll();
    AppLogger.info('[SSL] deleteCertificate success, id=$certificateId');
    notifyListeners();
  }

  // ────────────────── CRL generation ──────────────────

  Future<bool> requestGenerateCrlWithPrompt(
    BuildContext context, {
    int? crlDays,
  }) async {
    final existingValid = await _findFirstValidUnexpiredCrlPath([
      p.join(configData.storagePath, '_files', 'root.crl'),
      p.join(configData.storagePath, '_files', 'crl.pem'),
      crlStateInternal.crlFilePath ?? '',
    ]);
    if (existingValid != null) {
      infoMessage = '当前 CRL 尚未过期（$existingValid），按规则不允许重复生成。';
      notifyListeners();
      await showAdvancedConfirmDialog(
        context: context,
        title: 'CRL 生成提示',
        content: infoMessage,
        icon: Icons.info_outline,
        confirmText: '确定',
        cancelText: '',
      );
      return false;
    }
    return generateCrl(crlDays: crlDays, force: true);
  }

  Future<bool> generateCrl({int? crlDays, bool force = false}) async {
    if (!isInitialized) return false;
    if (!await ensureStorageAvailableOrRecover()) {
      notifyListeners();
      return false;
    }
    isLoading = true;
    notifyListeners();
    AppLogger.info('[SSL] generateCrl start');
    try {
      await OpenSslCommandService.ensureOpenSslAvailable();
      final days = crlDays ?? crlStateInternal.crlDays;
      final crlOutputPath = p.join(configData.storagePath, '_files', 'root.crl');
      final legacyCrlPath = p.join(configData.storagePath, '_files', 'crl.pem');
      final rootCertPath = rootCACertPathController.text.trim();
      final rootKeyPath = rootCAKeyPathController.text.trim();
      final cnfPath = configData.defaultCnfPath;
      final indexPath = p.join(configData.storagePath, '_files', 'index.txt');

      if (rootCertPath.isEmpty || rootKeyPath.isEmpty) {
        throw Exception('未找到可用的根证书或根私钥，请检查存储配置。');
      }
      if (!await File(rootCertPath).exists()) {
        throw Exception('根证书文件不存在: $rootCertPath');
      }
      if (!await File(rootKeyPath).exists()) {
        throw Exception('根私钥文件不存在: $rootKeyPath');
      }
      if (cnfPath.trim().isEmpty || !await File(cnfPath).exists()) {
        throw Exception('未找到 OpenSSL 配置文件: $cnfPath');
      }

      if (!force) {
        final existingValid = await _findFirstValidUnexpiredCrlPath([
          crlOutputPath,
          legacyCrlPath,
          crlStateInternal.crlFilePath ?? '',
        ]);
        if (existingValid != null) {
          infoMessage = '当前 CRL 尚未过期（$existingValid），按规则不允许重复生成。';
          AppLogger.info('[SSL] generateCrl skipped: $infoMessage');
          return false;
        }
      }

      // Build index.txt for openssl ca. CRL only needs revoked entries.
      final indexLines = <String>[];
      final revokedCerts = certificateRecords.where(
        (c) => c.status == SslCertStatus.revoked,
      );
      for (final cert in revokedCerts) {
        final serial = _normalizeOpenSslIndexSerial(cert.serialNumber);
        if (serial.isEmpty) {
          AppLogger.warning(
            '[SSL] skip revoked cert with invalid serial for CRL index: ${cert.serialNumber}',
          );
          continue;
        }
        final notAfter = _formatOpenSslDateCompact(cert.expiresAt);
        final revokeDate = _formatOpenSslDateCompact(
          cert.revokedAt ?? DateTime.now(),
        );
        final commonName = cert.commonName.trim().isEmpty
            ? cert.domain
            : cert.commonName;
        indexLines.add(
          'R\t$notAfter\t$revokeDate\t$serial\tunknown\t/CN=${_escapeOpenSslDnValue(commonName)}',
        );
      }
      final revokedCount = revokedCerts.length;
      if (revokedCount > 0 && indexLines.isEmpty) {
        throw Exception('存在已吊销证书，但序列号无效，无法生成 CRL。');
      }
      // OpenSSL text DB cannot contain a standalone blank line.
      final indexContent = indexLines.isEmpty
          ? ''
          : '${indexLines.join('\n')}\n';
      await File(indexPath).writeAsString(indexContent);

      final args = <String>[
        'ca',
        '-gencrl',
        '-config',
        cnfPath,
        '-keyfile',
        rootKeyPath,
        '-cert',
        rootCertPath,
        '-out',
        crlOutputPath,
        '-crldays',
        '$days',
      ];
      if (rootCAPasswordController.text.isNotEmpty) {
        args.addAll(['-passin', 'pass:${rootCAPasswordController.text}']);
      }

      await OpenSslCommandService.runOpenSslOrThrow(
        args,
        action: '生成 CRL',
        workingDirectory: configData.storagePath,
        timeout: const Duration(seconds: 15),
      );
      if (crlOutputPath != legacyCrlPath) {
        await File(crlOutputPath).copy(legacyCrlPath);
      }
      final generatedNextUpdate = await _readCrlNextUpdate(crlOutputPath);
      if (generatedNextUpdate == null) {
        throw Exception('CRL 已生成，但无法解析有效期，请检查 CRL 内容。');
      }
      if (!generatedNextUpdate.toUtc().isAfter(DateTime.now().toUtc())) {
        throw Exception('CRL 已生成，但已处于过期状态，请检查 crlDays 配置。');
      }

      crlStateInternal = crlStateInternal.copyWith(
        crlFilePath: crlOutputPath,
        lastGeneratedAt: DateTime.now(),
        crlDays: days,
      );
      infoMessage =
          'CRL 吊销列表已生成（有效至 ${generatedNextUpdate.toLocal().toString().split('.').first}）。';
      addAuditEntry(AuditAction.crl, '生成 CRL: $crlOutputPath');
      AppLogger.info('[SSL] generateCrl success, path=$crlOutputPath');
      await persistAll();
      return true;
    } catch (e) {
      infoMessage = 'CRL 生成失败: $e';
      AppLogger.error('[SSL] generateCrl failed', e);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ────────────────── batch operations ──────────────────

  void toggleBatchMode() {
    batchModeInternal = !batchModeInternal;
    if (!batchModeInternal) batchSelectedIdsInternal.clear();
    notifyListeners();
  }

  void toggleBatchSelect(String certId) {
    if (batchSelectedIdsInternal.contains(certId)) {
      batchSelectedIdsInternal.remove(certId);
    } else {
      batchSelectedIdsInternal.add(certId);
    }
    notifyListeners();
  }

  void batchSelectAll() {
    batchSelectedIdsInternal.clear();
    for (final cert in filteredCertificates) {
      batchSelectedIdsInternal.add(cert.id);
    }
    notifyListeners();
  }

  void batchDeselectAll() {
    batchSelectedIdsInternal.clear();
    notifyListeners();
  }

  Future<int> batchRevoke(String reason) async {
    int count = 0;
    for (final certId in [...batchSelectedIdsInternal]) {
      final index = certificateRecords.indexWhere((e) => e.id == certId);
      if (index < 0 || certificateRecords[index].status == SslCertStatus.revoked) {
        continue;
      }
      certificateRecords[index] = certificateRecords[index].copyWith(
        status: SslCertStatus.revoked,
        revokeReason: reason.isEmpty ? '批量撤销' : reason,
        revokedAt: DateTime.now(),
      );
      count++;
    }
    if (count > 0) {
      addAuditEntry(AuditAction.revoke, '批量撤销 $count 张证书');
      batchSelectedIdsInternal.clear();
      batchModeInternal = false;
      await persistAll();
      try {
        await generateCrl(force: true);
      } catch (_) {}
    }
    notifyListeners();
    return count;
  }

  Future<int> batchDelete() async {
    int count = 0;
    for (final certId in [...batchSelectedIdsInternal]) {
      final index = certificateRecords.indexWhere((e) => e.id == certId);
      if (index < 0) continue;
      final item = certificateRecords.removeAt(index);
      await _deleteIfExists(item.configFilePath);
      await _deleteIfExists(item.certFilePath);
      await _deleteIfExists(item.keyFilePath);
      await _deleteIfExists(item.csrFilePath);
      count++;
    }
    if (count > 0) {
      addAuditEntry(AuditAction.delete, '批量删除 $count 张证书');
      batchSelectedIdsInternal.clear();
      batchModeInternal = false;
      if (selectedCertId != null &&
          !certificateRecords.any((c) => c.id == selectedCertId)) {
        selectedCertId = null;
      }
      await persistAll();
    }
    notifyListeners();
    return count;
  }

  // ────────────────── private helpers ──────────────────

  String _formatOpenSslDateCompact(DateTime dt) {
    final utc = dt.toUtc();
    return '${(utc.year % 100).toString().padLeft(2, '0')}'
        '${utc.month.toString().padLeft(2, '0')}'
        '${utc.day.toString().padLeft(2, '0')}'
        '${utc.hour.toString().padLeft(2, '0')}'
        '${utc.minute.toString().padLeft(2, '0')}'
        '${utc.second.toString().padLeft(2, '0')}Z';
  }

  String _normalizeOpenSslIndexSerial(String rawSerial) {
    final normalized = rawSerial.trim().toUpperCase().replaceAll(
      RegExp(r'[^0-9A-F]'),
      '',
    );
    if (normalized.isEmpty) {
      return '';
    }
    return normalized.length.isOdd ? '0$normalized' : normalized;
  }

  String _escapeOpenSslDnValue(String raw) {
    return raw
        .replaceAll(r'\', r'\\')
        .replaceAll('/', r'\/')
        .replaceAll('\t', ' ')
        .replaceAll('\r', ' ')
        .replaceAll('\n', ' ');
  }

  Future<String?> _findFirstValidUnexpiredCrlPath(
    List<String> candidatePaths,
  ) async {
    final unique = <String>{};
    for (final rawPath in candidatePaths) {
      final path = rawPath.trim();
      if (path.isEmpty || !unique.add(path)) {
        continue;
      }
      final file = File(path);
      if (!await file.exists()) {
        continue;
      }
      final nextUpdate = await _readCrlNextUpdate(path);
      if (nextUpdate == null) {
        continue;
      }
      if (nextUpdate.toUtc().isAfter(DateTime.now().toUtc())) {
        return path;
      }
    }
    return null;
  }

  Future<DateTime?> _readCrlNextUpdate(String crlPath) async {
    final result = await OpenSslCommandService.runOpenSsl([
      'crl',
      '-in',
      crlPath,
      '-noout',
      '-nextupdate',
    ], timeout: const Duration(seconds: 8));
    if (result == null || result.exitCode != 0) {
      return null;
    }
    final line = result.stdout
        .toString()
        .split('\n')
        .map((e) => e.trim())
        .firstWhere((e) => e.startsWith('nextUpdate='), orElse: () => '');
    if (line.isEmpty) {
      return null;
    }
    return OpenSslCommandService.parseOpenSslDate(
      line.substring('nextUpdate='.length).trim(),
    );
  }

  Future<void> _deleteIfExists(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
