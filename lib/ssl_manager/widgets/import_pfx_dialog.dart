import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/certificate_provider.dart';
import '../providers/ssl_settings_provider.dart';
import '../services/openssl_service.dart';
import '../models/certificate.dart';
import 'custom_button.dart';
import 'package:uuid/uuid.dart';
import '../../core/i18n/app_localization.dart';
import '../../core/i18n/localization_keys.dart';

class ImportPFXDialog extends StatefulWidget {
  const ImportPFXDialog({super.key});

  @override
  State<ImportPFXDialog> createState() => _ImportPFXDialogState();
}

class _ImportPFXDialogState extends State<ImportPFXDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _pfxPathController = TextEditingController();
  final _passwordController = TextEditingController();

  final _opensslService = OpenSSLService();
  final _uuid = const Uuid();

  bool _isLoading = false;

  String _tr(String key) {
    return AppLocalization.of(context).translate(key);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pfxPathController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _selectPFXFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pfx', 'p12'],
      dialogTitle: _tr(L18nKeys.selectPfxFile),
    );

    if (result != null && result.files.isNotEmpty) {
      _pfxPathController.text = result.files.first.path!;

      // 自动填充名称
      if (_nameController.text.isEmpty) {
        final fileName = result.files.first.name;
        _nameController.text = fileName.replaceAll(RegExp(r'\.(pfx|p12)$'), '');
      }
    }
  }

  Future<void> _importPFX() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final settingsProvider = context.read<SSLSettingsProvider>();
      final certificateProvider = context.read<CertificateProvider>();
      final settings = settingsProvider.settings!;

      // 首先提取到临时位置以检测类型
      final tempDir = Directory.systemTemp.createTempSync('ssl_import_');

      // 从PFX提取证书和私钥到临时目录
      final tempExtractedFiles = await _opensslService.importFromPFX(
        pfxPath: _pfxPathController.text,
        pfxPassword: _passwordController.text,
        outputDir: tempDir.path,
        baseName: 'temp',
      );

      // 解析证书信息以确定类型
      final certInfo = await _opensslService
          .parseCertificateInfo(tempExtractedFiles['certPath']!);
      final isCA = await _opensslService
          .isCACertificate(tempExtractedFiles['certPath']!);
      final certType = isCA ? 'CA' : 'SSL';

      // 使用分类路径
      final outputPath = settings.getCertificatePathByType(certType);

      // 确保目录存在
      await Directory(outputPath).create(recursive: true);

      // 移动文件到正确的分类目录
      final certPath = '$outputPath/${_nameController.text}-cert.pem';
      final keyPath = '$outputPath/${_nameController.text}-key.pem';

      await File(tempExtractedFiles['certPath']!).copy(certPath);
      await File(tempExtractedFiles['keyPath']!).copy(keyPath);

      // 如果有CA链，也复制过去
      String? caChainPath;
      if (tempExtractedFiles['caPath'] != null) {
        final caFile = File(tempExtractedFiles['caPath']!);
        if (await caFile.exists() && await caFile.length() > 0) {
          caChainPath = '$outputPath/${_nameController.text}-ca.pem';
          await caFile.copy(caChainPath);
        }
      }

      // 清理临时文件
      try {
        await tempDir.delete(recursive: true);
      } catch (e) {
        // 忽略临时文件清理错误
      }

      // ========== 提取證書詳細信息 ==========
      Map<String, String> extractedDetails = {};
      try {
        extractedDetails =
            await _opensslService.extractCertificateDetails(certPath);
        debugPrint('Extracted certificate details from PFX: $extractedDetails');
      } catch (e) {
        debugPrint(
            'Warning: Failed to extract detailed certificate info from PFX: $e');
        // 繼續執行，即使提取詳細信息失敗
      }
      // ========== 添加結束 ==========

      // 创建证书对象
      final subject = certInfo['subject'] as Map<String, String>;
      final certificate = Certificate(
        id: _uuid.v4(),
        name: _nameController.text,
        type: certType,
        filePath: certPath,
        issueDate: certInfo['notBefore'] as DateTime,
        expiryDate: certInfo['notAfter'] as DateTime,
        isEncrypted: false, // PFX导入后密钥已解密
        details: {
          'keyPath': keyPath,
          if (caChainPath != null) 'chainPath': caChainPath,
          'commonName': subject['CN'] ?? '',
          'organization': subject['O'] ?? '',
          'organizationalUnit': subject['OU'] ?? '',
          'country': subject['C'] ?? '',
          'state': subject['ST'] ?? '',
          'city': subject['L'] ?? '',
          'email': subject['emailAddress'] ?? '',
          'serial': certInfo['serial'] as String? ?? '',
          'imported': 'true',
          'importedFrom': 'PFX', // ========== 添加提取的詳細信息 ==========
        },
      );

      await certificateProvider.addCertificate(certificate);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${_tr(L18nKeys.pfxImportedSuccessfullyTo)} $certType/ ${_tr(L18nKeys.folder)}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_tr(L18nKeys.importError)}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_tr(L18nKeys.importFromPfx)),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _pfxPathController,
                decoration: InputDecoration(
                  labelText: _tr(L18nKeys.pfxFileRequired),
                  hintText: _tr(L18nKeys.selectPfxOrP12File),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.folder_open),
                    onPressed: _selectPFXFile,
                  ),
                ),
                readOnly: true,
                validator: (value) =>
                    value?.isEmpty == true ? _tr(L18nKeys.required) : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: _tr(L18nKeys.certificateNameRequired),
                  hintText: _tr(L18nKeys.enterFriendlyName),
                ),
                validator: (value) =>
                    value?.isEmpty == true ? _tr(L18nKeys.required) : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: _tr(L18nKeys.pfxPasswordRequired),
                ),
                obscureText: true,
                validator: (value) =>
                    value?.isEmpty == true ? _tr(L18nKeys.required) : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(_tr(L18nKeys.cancel)),
        ),
        CustomButton(
          text: _tr(L18nKeys.import),
          onPressed: _importPFX,
          isLoading: _isLoading,
        ),
      ],
    );
  }
}
