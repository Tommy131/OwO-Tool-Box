import 'dart:io';

import 'package:path/path.dart' as p;

import '../../../core/services/persistence_service.dart';
import '../models/ssl_config.dart';

class SslStorageService {
  static const String _moduleName = 'ssl_certificate_manager';
  static const String _configKey = 'config';
  static const String _defaultTemplateSourcePath =
      r'd:\Workspace\ssl\openssl_config\local.owoserver.com.cnf';

  final PersistenceService _persistenceService = PersistenceService();

  Future<SslConfig> loadConfig() async {
    await _persistenceService.ensureReady();
    final defaultBaseDir = await _resolveDefaultBaseDir();
    final raw = _persistenceService.getModuleData<Map<String, dynamic>>(
      _moduleName,
      _configKey,
    );
    final config = raw == null
        ? SslConfig.defaults(baseDir: defaultBaseDir)
        : SslConfig.fromMap(raw, baseDir: defaultBaseDir);
    final normalized = config.copyWith(
      baseDir: config.baseDir.trim().isEmpty ? defaultBaseDir : config.baseDir,
    );
    return normalized;
  }

  Future<void> saveConfig(SslConfig config) async {
    await _persistenceService.ensureReady();
    await _persistenceService.setModuleData(
      _moduleName,
      _configKey,
      config.toMap(),
    );
  }

  Future<String> readOpenSslTemplate(SslConfig config) async {
    final file = File(config.opensslConfigPath);
    if (!await file.exists()) {
      return _loadDefaultOpenSslTemplate();
    }
    return file.readAsString();
  }

  Future<void> writeOpenSslTemplate(SslConfig config, String content) async {
    final file = File(config.opensslConfigPath);
    final parent = file.parent;
    if (!await parent.exists()) {
      await parent.create(recursive: true);
    }
    await file.writeAsString(content);
  }

  Future<void> syncUserConfigFromTemplate(SslConfig config) async {
    final template = await readOpenSslTemplate(config);
    final rendered = _renderUserConfig(template, config);
    final file = File(config.userConfigPath);
    final parent = file.parent;
    if (!await parent.exists()) {
      await parent.create(recursive: true);
    }
    await file.writeAsString(rendered);
  }

  Future<String> _resolveDefaultBaseDir() async {
    final currentRoot = _persistenceService.rootPath;
    if (currentRoot != null && currentRoot.trim().isNotEmpty) {
      return p.join(currentRoot, 'ssl');
    }
    final fallbackRoot = await PersistenceService.getDefaultRootPath();
    return p.join(fallbackRoot, 'ssl');
  }

  Future<void> ensureDefaultFiles(SslConfig config) async {
    final baseDir = Directory(config.baseDir);
    if (!await baseDir.exists()) {
      await baseDir.create(recursive: true);
    }

    final directories = <String>[
      config.caCertDir,
      config.certDir,
      config.csrDir,
      config.filesDir,
      config.keyDir,
      config.opensslConfigDir,
      config.pfxDir,
      p.join(config.filesDir, 'crl'),
    ];
    for (final path in directories) {
      final dir = Directory(path);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    }

    final indexFile = File(config.ocspIndexPath);
    if (!await indexFile.exists()) {
      await indexFile.writeAsString('');
    }

    final serialFile = File(config.serialFilePath);
    if (!await serialFile.exists()) {
      await serialFile.writeAsString('1000\n');
    }

    final crlNumberFile = File(p.join(config.filesDir, 'crlnumber'));
    if (!await crlNumberFile.exists()) {
      await crlNumberFile.writeAsString('1000\n');
    }

    final opensslConfigFile = File(config.opensslConfigPath);
    if (!await opensslConfigFile.exists()) {
      await opensslConfigFile.writeAsString(
        await _loadDefaultOpenSslTemplate(),
      );
    }

    final userConfigFile = File(config.userConfigPath);
    if (!await userConfigFile.exists()) {
      await syncUserConfigFromTemplate(config);
    }
  }

  Future<String> _loadDefaultOpenSslTemplate() async {
    final sourceFile = File(_defaultTemplateSourcePath);
    if (await sourceFile.exists()) {
      return sourceFile.readAsString();
    }
    return "";
  }

  String _renderUserConfig(String template, SslConfig config) {
    final ocspUrl = config.ocspServerUrl.trim();
    final crlUrl = config.crlUrl.trim();
    final ocspHost = Uri.tryParse(ocspUrl)?.host;

    var rendered = template;
    final placeholders = <String, String>{
      '{{DOMAIN}}': config.domain,
      '{{CERT_NAME}}': config.certName,
      '{{ROOT_CA_NAME}}': config.rootCaName,
      '{{IP}}': config.ip.split(':').first.trim(),
      '{{OCSP_URL}}': ocspUrl,
      '{{CRL_URL}}': crlUrl,
      '{{OCSP_HOST}}': ocspHost ?? '',
      '{{DAYS}}': config.days.toString(),
      '{{CA_KEY_PASSWORD}}': config.caKeyPassword,
      '{{PFX_PASSWORD}}': config.pfxPassword,
    };
    placeholders.forEach((key, value) {
      rendered = rendered.replaceAll(key, value);
    });

    rendered = _setConfigValue(
      rendered,
      'owo_commonName',
      '"${config.domain}"',
    );
    rendered = _setConfigValue(
      rendered,
      'owo_rootCAFileName',
      config.rootCaName,
    );
    if (ocspHost != null && ocspHost.isNotEmpty) {
      rendered = _setConfigValue(rendered, 'owo_OCSP_Domain', ocspHost);
    }
    rendered = _setConfigValue(rendered, 'DNS.1', config.domain);
    rendered = _setConfigValue(
      rendered,
      'IP.1',
      config.ip.split(':').first.trim(),
    );
    rendered = _setConfigValue(
      rendered,
      'OCSP;URI.0',
      ocspUrl.isEmpty ? 'http://ssl.owoserver.com/ocsp' : ocspUrl,
    );
    rendered = _setConfigValue(
      rendered,
      'URI.0',
      crlUrl.isEmpty ? 'http://ssl.owoserver.com/rootca.crl' : crlUrl,
    );
    rendered = _setConfigValue(
      rendered,
      'default_days',
      config.days.toString(),
    );

    return rendered;
  }

  String _setConfigValue(String content, String key, String value) {
    final escapedKey = RegExp.escape(key);
    final pattern = RegExp('^(\\s*$escapedKey\\s*=\\s*).*\$', multiLine: true);
    if (pattern.hasMatch(content)) {
      return content.replaceFirst(pattern, '\$1$value');
    }
    return content;
  }
}
