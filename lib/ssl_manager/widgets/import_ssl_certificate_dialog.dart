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

class ImportSSLCertificateDialog extends StatefulWidget {
  const ImportSSLCertificateDialog({super.key});

  @override
  State<ImportSSLCertificateDialog> createState() =>
      _ImportSSLCertificateDialogState();
}

class _ImportSSLCertificateDialogState
    extends State<ImportSSLCertificateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _certPathController = TextEditingController();
  final _keyPathController = TextEditingController();
  final _chainPathController = TextEditingController();
  final _passwordController = TextEditingController();

  final _opensslService = OpenSSLService();
  final _uuid = const Uuid();

  bool _isLoading = false;
  bool _hasPrivateKey = true;
  bool _hasChain = false;
  bool _isEncrypted = false;
  bool _certValidated = false;
  bool _keyValidated = false;
  bool _chainValidated = false;
  Map<String, dynamic>? _certInfo;
  int? _chainLength;

  String _tr(String key) {
    return AppLocalization.of(context).translate(key);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _certPathController.dispose();
    _keyPathController.dispose();
    _chainPathController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _selectCertFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pem', 'crt', 'cer', 'cert'],
      dialogTitle: _tr(L18nKeys.selectSslCertificateFile),
    );

    if (result != null && result.files.isNotEmpty) {
      _certPathController.text = result.files.first.path!;
      await _validateCertificate();
    }
  }

  Future<void> _selectKeyFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pem', 'key'],
      dialogTitle: _tr(L18nKeys.selectPrivateKeyFile),
    );

    if (result != null && result.files.isNotEmpty) {
      _keyPathController.text = result.files.first.path!;
      _keyValidated = false;
      setState(() {});
    }
  }

  Future<void> _selectChainFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pem', 'crt', 'cer'],
      dialogTitle: _tr(L18nKeys.selectCertificateChainFile),
    );

    if (result != null && result.files.isNotEmpty) {
      _chainPathController.text = result.files.first.path!;
      _chainValidated = false;
      setState(() {});
    }
  }

  Future<void> _validateCertificate() async {
    if (_certPathController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _certValidated = false;
    });

    try {
      final isValid =
          await _opensslService.validateCertificate(_certPathController.text);

      if (!isValid) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_tr(L18nKeys.invalidCertificateFile)),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      _certInfo =
          await _opensslService.parseCertificateInfo(_certPathController.text);

      // 检查是否为SSL证书（非CA证书）
      final isCA =
          await _opensslService.isCACertificate(_certPathController.text);

      if (isCA) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_tr(L18nKeys.caCertificateWarning)),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // 自动填充名称
      if (_nameController.text.isEmpty && _certInfo != null) {
        final subject = _certInfo!['subject'] as Map<String, String>?;
        _nameController.text =
            subject?['CN'] ?? _tr(L18nKeys.importedSslCertificate);
      }

      _certValidated = true;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_tr(L18nKeys.sslCertificateValidatedSuccessfully)),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_tr(L18nKeys.validationError)}: ${e.toString()}'),
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

  Future<void> _validatePrivateKey() async {
    if (_keyPathController.text.isEmpty || !_hasPrivateKey) return;

    setState(() {
      _isLoading = true;
      _keyValidated = false;
    });

    try {
      final isValid = await _opensslService.validatePrivateKey(
        _keyPathController.text,
        password: _isEncrypted ? _passwordController.text : null,
      );

      if (!isValid) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_tr(L18nKeys.invalidPrivateKeyOrPassword)),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (_certValidated) {
        final matches = await _opensslService.verifyCertKeyMatch(
          _certPathController.text,
          _keyPathController.text,
          keyPassword: _isEncrypted ? _passwordController.text : null,
        );

        if (!matches) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_tr(L18nKeys.certificateKeyMismatch)),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }
      }

      _keyValidated = true;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_tr(L18nKeys.privateKeyValidatedSuccessfully)),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_tr(L18nKeys.validationError)}: ${e.toString()}'),
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

  Future<void> _validateChain() async {
    if (_chainPathController.text.isEmpty || !_hasChain) return;

    setState(() {
      _isLoading = true;
      _chainValidated = false;
    });

    try {
      // 分析证书链
      final certs = await _opensslService
          .splitCertificateChain(_chainPathController.text);
      _chainLength = certs.length;

      if (_chainLength == 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_tr(L18nKeys.noCertificatesFoundInChain)),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      _chainValidated = true;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${_tr(L18nKeys.certificateChainValidated)}: $_chainLength ${_tr(L18nKeys.certificates)}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('${_tr(L18nKeys.chainValidationError)}: ${e.toString()}'),
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

  Future<void> _importCertificate() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_certValidated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_tr(L18nKeys.pleaseValidateCertificateFirst)),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_hasPrivateKey && !_keyValidated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_tr(L18nKeys.pleaseValidatePrivateKeyFirst)),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_hasChain && !_chainValidated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_tr(L18nKeys.pleaseValidateChainFirst)),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final settingsProvider = context.read<SSLSettingsProvider>();
      final certificateProvider = context.read<CertificateProvider>();
      final settings = settingsProvider.settings!;

      // 使用 SSL 分类路径
      final outputPath = settings.getCertificatePathByType('SSL');

      // 确保目录存在
      await Directory(outputPath).create(recursive: true);

      // 导入SSL证书及其链
      final importResult = await _opensslService.importSSLCertificateWithChain(
        certPath: _certPathController.text,
        outputDir: outputPath, // 使用分类后的输出路径
        baseName: _nameController.text,
        keyPath: _hasPrivateKey ? _keyPathController.text : null,
        keyPassword: _isEncrypted ? _passwordController.text : null,
        chainPath: _hasChain ? _chainPathController.text : null,
      );

      // 创建证书对象
      final subject = _certInfo!['subject'] as Map<String, String>;
      final issuer = _certInfo!['issuer'] as Map<String, String>;

      final certificate = Certificate(
        id: _uuid.v4(),
        name: _nameController.text,
        type: 'SSL',
        filePath: importResult['certPath']!,
        issueDate: _certInfo!['notBefore'] as DateTime,
        expiryDate: _certInfo!['notAfter'] as DateTime,
        isEncrypted: _isEncrypted && _hasPrivateKey,
        password:
            _isEncrypted && _hasPrivateKey ? _passwordController.text : null,
        details: {
          if (importResult['keyPath'] != null)
            'keyPath': importResult['keyPath']!,
          if (importResult['chainPath'] != null)
            'chainPath': importResult['chainPath']!,
          if (importResult['fullChainPath'] != null)
            'fullChainPath': importResult['fullChainPath']!,
          'commonName': subject['CN'] ?? '',
          'organization': subject['O'] ?? '',
          'organizationalUnit': subject['OU'] ?? '',
          'country': subject['C'] ?? '',
          'state': subject['ST'] ?? '',
          'city': subject['L'] ?? '',
          'email': subject['emailAddress'] ?? '',
          'issuerCN': issuer['CN'] ?? '',
          'issuerO': issuer['O'] ?? '',
          'serial': _certInfo!['serial'] as String? ?? '',
          'imported': 'true',
          'importedFrom': 'SSL Certificate',
          if (_chainLength != null) 'chainLength': _chainLength.toString(),
        },
      );

      await certificateProvider.addCertificate(certificate);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_tr(L18nKeys.sslCertificateImportedSuccessfully)),
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
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(_tr(L18nKeys.importSslCertificate)),
      content: SizedBox(
        width: 600,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 说明文本
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: theme.colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _tr(L18nKeys.importSslCertificateDescription),
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // SSL证书文件
                TextFormField(
                  controller: _certPathController,
                  decoration: InputDecoration(
                    labelText: _tr(L18nKeys.sslCertificateFileRequired),
                    hintText: _tr(L18nKeys.selectPemCrtCerFile),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_certValidated)
                          const Icon(Icons.check_circle, color: Colors.green),
                        IconButton(
                          icon: const Icon(Icons.folder_open),
                          onPressed: _selectCertFile,
                        ),
                      ],
                    ),
                  ),
                  readOnly: true,
                  validator: (value) =>
                      value?.isEmpty == true ? _tr(L18nKeys.required) : null,
                ),
                const SizedBox(height: 8),
                if (_certPathController.text.isNotEmpty && !_certValidated)
                  CustomButton(
                    text: _tr(L18nKeys.validateCertificate),
                    icon: Icons.verified_user,
                    onPressed: _validateCertificate,
                    isLoading: _isLoading,
                  ),

                const SizedBox(height: 16),

                // 显示证书信息
                if (_certValidated && _certInfo != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          theme.colorScheme.secondaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.verified_user,
                                color: theme.colorScheme.secondary),
                            const SizedBox(width: 8),
                            Text(
                              _tr(L18nKeys.sslCertificate),
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        _buildInfoRow(
                            'CN',
                            (_certInfo!['subject']
                                    as Map<String, String>)['CN'] ??
                                'N/A'),
                        _buildInfoRow(
                            _tr(L18nKeys.issuer),
                            (_certInfo!['issuer']
                                    as Map<String, String>)['CN'] ??
                                'N/A'),
                        _buildInfoRow(
                            _tr(L18nKeys.expiry),
                            _formatDateTime(
                                _certInfo!['notAfter'] as DateTime)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 证书名称
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

                // 私钥选项
                CheckboxListTile(
                  value: _hasPrivateKey,
                  onChanged: (value) {
                    setState(() {
                      _hasPrivateKey = value ?? false;
                      if (!_hasPrivateKey) {
                        _keyPathController.clear();
                        _passwordController.clear();
                        _isEncrypted = false;
                        _keyValidated = false;
                      }
                    });
                  },
                  title: Text(_tr(L18nKeys.includePrivateKey)),
                  contentPadding: EdgeInsets.zero,
                ),

                if (_hasPrivateKey) ...[
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _keyPathController,
                    decoration: InputDecoration(
                      labelText: _tr(L18nKeys.privateKeyFileRequired),
                      hintText: _tr(L18nKeys.selectPemKeyFile),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_keyValidated)
                            const Icon(Icons.check_circle, color: Colors.green),
                          IconButton(
                            icon: const Icon(Icons.folder_open),
                            onPressed: _selectKeyFile,
                          ),
                        ],
                      ),
                    ),
                    readOnly: true,
                    validator: (value) =>
                        _hasPrivateKey && value?.isEmpty == true
                            ? _tr(L18nKeys.required)
                            : null,
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    value: _isEncrypted,
                    onChanged: (value) {
                      setState(() {
                        _isEncrypted = value ?? false;
                        if (!_isEncrypted) {
                          _passwordController.clear();
                        }
                      });
                    },
                    title: Text(_tr(L18nKeys.privateKeyIsEncrypted)),
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (_isEncrypted) ...[
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: _tr(L18nKeys.privateKeyPasswordRequired),
                      ),
                      obscureText: true,
                      validator: (value) =>
                          _isEncrypted && value?.isEmpty == true
                              ? _tr(L18nKeys.required)
                              : null,
                    ),
                  ],
                  const SizedBox(height: 8),
                  if (_keyPathController.text.isNotEmpty && !_keyValidated)
                    CustomButton(
                      text: _tr(L18nKeys.validatePrivateKey),
                      icon: Icons.vpn_key,
                      onPressed: _validatePrivateKey,
                      isLoading: _isLoading,
                    ),
                ],

                const SizedBox(height: 16),

                // 证书链选项
                CheckboxListTile(
                  value: _hasChain,
                  onChanged: (value) {
                    setState(() {
                      _hasChain = value ?? false;
                      if (!_hasChain) {
                        _chainPathController.clear();
                        _chainValidated = false;
                        _chainLength = null;
                      }
                    });
                  },
                  title: Text(_tr(L18nKeys.includeCertificateChain)),
                  subtitle: Text(_tr(L18nKeys.intermediateRootCaCertificates)),
                  contentPadding: EdgeInsets.zero,
                ),

                if (_hasChain) ...[
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _chainPathController,
                    decoration: InputDecoration(
                      labelText: _tr(L18nKeys.certificateChainFile),
                      hintText: _tr(L18nKeys.selectChainPemFile),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_chainValidated)
                            const Icon(Icons.check_circle, color: Colors.green),
                          IconButton(
                            icon: const Icon(Icons.folder_open),
                            onPressed: _selectChainFile,
                          ),
                        ],
                      ),
                    ),
                    readOnly: true,
                  ),
                  const SizedBox(height: 8),
                  if (_chainPathController.text.isNotEmpty && !_chainValidated)
                    CustomButton(
                      text: _tr(L18nKeys.validateChain),
                      icon: Icons.link,
                      onPressed: _validateChain,
                      isLoading: _isLoading,
                    ),
                  if (_chainValidated && _chainLength != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${_tr(L18nKeys.chainContains)} $_chainLength ${_tr(L18nKeys.certificates)}',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ],
            ),
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
          onPressed: _importCertificate,
          isLoading: _isLoading,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }
}
