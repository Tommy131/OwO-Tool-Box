import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../models/app_settings.dart';

class SettingsService {
  static const String _settingsKey = 'app_settings';
  static const String _defaultConfigContent = '''
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
x509_extensions = v3_ca

[ dn ]
C = DE
ST = Bayern
L = Munich
O = DefaultTeam
OU = Issue Unit
CN = example.com

[ v3_ca ]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true
keyUsage = critical, digitalSignature, cRLSign, keyCertSign

[ v3_req ]
subjectKeyIdentifier = hash
basicConstraints = CA:FALSE
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth, clientAuth
''';

  Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final String? settingsJson = prefs.getString(_settingsKey);

    if (settingsJson == null) {
      return await _createDefaultSettings();
    }

    return AppSettings.fromJson(jsonDecode(settingsJson));
  }

  Future<AppSettings> _createDefaultSettings() async {
    final directory = await getApplicationDocumentsDirectory();
    final certPath = '${directory.path}/ssl_certificates';
    final configPath = '${directory.path}/ssl_certificates/openssl.cnf';

    // 创建目录结构
    await _createDirectoryStructure(certPath);

    // 创建默认配置文件
    await File(configPath).writeAsString(_defaultConfigContent);

    final settings =
        AppSettings(certificatePath: certPath, opensslConfigPath: configPath);

    await saveSettings(settings);
    return settings;
  }

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));

    // 确保目录结构存在
    await _createDirectoryStructure(settings.certificatePath);
  }

  // 创建目录结构
  Future<void> _createDirectoryStructure(String basePath) async {
    final baseDir = Directory(basePath);
    if (!await baseDir.exists()) {
      await baseDir.create(recursive: true);
    }

    final caDir = Directory('$basePath/CA');
    final sslDir = Directory('$basePath/SSL');

    if (!await caDir.exists()) {
      await caDir.create(recursive: true);
    }
    if (!await sslDir.exists()) {
      await sslDir.create(recursive: true);
    }
  }

  Future<String> getConfigContent() async {
    final settings = await loadSettings();
    final file = File(settings.opensslConfigPath);

    if (!await file.exists()) {
      await file.create(recursive: true);
      await file.writeAsString(_defaultConfigContent);
      return _defaultConfigContent;
    }

    return await file.readAsString();
  }

  Future<void> saveConfigContent(String content) async {
    final settings = await loadSettings();
    final file = File(settings.opensslConfigPath);
    await file.create(recursive: true);
    await file.writeAsString(content);
  }

  // 验证配置文件路径
  Future<bool> validateConfigPath(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        final content = await file.readAsString();
        // 简单验证是否包含基本的OpenSSL配置段
        return content.contains('[req]') || content.contains('[ca]');
      }
      return true; // 新文件也是有效的
    } catch (e) {
      return false;
    }
  }

  /// 迁移现有证书到分类目录（基于存储列表，不验证证书）
  Future<Map<String, dynamic>> migrateCertificatesToOrganizedStructure(
    String basePath,
    List<dynamic> certificates,
  ) async {
    final results = <String, dynamic>{
      'success': 0,
      'failed': 0,
      'skipped': 0,
      'errors': <String>[],
      'encrypted': <Map<String, String>>[],
    };

    try {
      final baseDir = Directory(basePath);
      if (!await baseDir.exists()) {
        (results['errors'] as List<String>)
            .add('Base directory does not exist');
        return results;
      }

      // 创建分类目录
      final caDir = Directory('$basePath/CA');
      final sslDir = Directory('$basePath/SSL');

      await caDir.create(recursive: true);
      await sslDir.create(recursive: true);

      // 遍历证书列表
      for (var certData in certificates) {
        try {
          final type = certData['type'] as String;
          final filePath = certData['filePath'] as String;
          final certName = certData['name'] as String;
          final isEncrypted = certData['isEncrypted'] as bool? ?? false;

          // 确定目标目录
          final targetDir = type == 'CA' ? caDir : sslDir;

          // 检查文件是否已在正确的目录中
          if (filePath.startsWith(targetDir.path)) {
            results['skipped'] = (results['skipped'] as int) + 1;
            continue;
          }

          // 记录加密证书（警告用户但仍然移动）
          if (isEncrypted) {
            (results['encrypted'] as List<Map<String, String>>).add({
              'name': certName,
              'type': type,
            });
          }

          bool migrationSuccess = true;

          // 移动证书文件
          final certFile = File(filePath);
          if (await certFile.exists()) {
            final fileName = path.basename(filePath);
            final newCertPath = '${targetDir.path}/$fileName';

            if (await File(newCertPath).exists()) {
              (results['errors'] as List<String>)
                  .add('$certName: Target certificate file already exists');
              results['failed'] = (results['failed'] as int) + 1;
              continue;
            }

            try {
              await certFile.rename(newCertPath);
              certData['filePath'] = newCertPath;
            } catch (e) {
              (results['errors'] as List<String>)
                  .add('$certName: Failed to move certificate - $e');
              migrationSuccess = false;
            }
          } else {
            (results['errors'] as List<String>)
                .add('$certName: Certificate file not found at $filePath');
            results['failed'] = (results['failed'] as int) + 1;
            continue;
          }

          // 移动相关文件（基于 details 中的路径）
          if (certData['details'] != null) {
            final details = certData['details'] as Map<String, dynamic>;

            // 移动私钥文件
            if (details['keyPath'] != null) {
              final moved = await _moveFileToTarget(
                details['keyPath'],
                targetDir.path,
                certName,
                'private key',
                results,
              );
              if (moved != null) {
                details['keyPath'] = moved;
              } else {
                migrationSuccess = false;
              }
            }

            // 移动 CSR 文件
            if (details['csrPath'] != null) {
              final moved = await _moveFileToTarget(
                details['csrPath'],
                targetDir.path,
                certName,
                'CSR',
                results,
              );
              if (moved != null) {
                details['csrPath'] = moved;
              }
            }

            // 移动证书链文件
            if (details['chainPath'] != null) {
              final moved = await _moveFileToTarget(
                details['chainPath'],
                targetDir.path,
                certName,
                'chain',
                results,
              );
              if (moved != null) {
                details['chainPath'] = moved;
              }
            }

            // 移动完整链文件
            if (details['fullChainPath'] != null) {
              final moved = await _moveFileToTarget(
                details['fullChainPath'],
                targetDir.path,
                certName,
                'fullchain',
                results,
              );
              if (moved != null) {
                details['fullChainPath'] = moved;
              }
            }
          }

          if (migrationSuccess) {
            results['success'] = (results['success'] as int) + 1;
          } else {
            results['failed'] = (results['failed'] as int) + 1;
          }
        } catch (e) {
          results['failed'] = (results['failed'] as int) + 1;
          (results['errors'] as List<String>)
              .add('Error migrating certificate: $e');
        }
      }

      return results;
    } catch (e) {
      (results['errors'] as List<String>).add('Migration failed: $e');
      return results;
    }
  }

  /// 移动单个文件到目标目录
  Future<String?> _moveFileToTarget(
    String filePath,
    String targetDir,
    String certName,
    String fileType,
    Map<String, dynamic> results,
  ) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        // 文件不存在，只记录警告，不算错误
        return null;
      }

      final fileName = path.basename(filePath);
      final newPath = '$targetDir/$fileName';

      // 检查目标文件是否已存在
      if (await File(newPath).exists()) {
        (results['errors'] as List<String>)
            .add('$certName: Target $fileType file already exists');
        return null;
      }

      // 移动文件
      await file.rename(newPath);
      return newPath;
    } catch (e) {
      (results['errors'] as List<String>)
          .add('$certName: Failed to move $fileType - $e');
      return null;
    }
  }
}
