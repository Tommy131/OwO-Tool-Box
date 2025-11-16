/*
 *        _____   _          __  _____   _____   _       _____   _____
 *      /  _  \ | |        / / /  _  \ |  _  \ | |     /  _  \ /  ___|
 *      | | | | | |  __   / /  | | | | | |_| | | |     | | | | | |
 *      | | | | | | /  | / /   | | | | |  _  { | |     | | | | | |   _
 *      | |_| | | |/   |/ /    | |_| | | |_| | | |___  | |_| | | |_| |
 *      \_____/ |___/|___/     \_____/ |_____/ |_____| \_____/ \_____/
 *
 *  Copyright (c) 2023 by OwOTeam-DGMT (OwOBlog).
 * @Date         : 2025-10-22
 * @Author       : HanskiJay
 * @LastEditors  : HanskiJay
 * @LastEditTime : 2025-10-22
 * @E-Mail       : support@owoblog.com
 * @Telegram     : https://t.me/HanskiJay
 * @GitHub       : https://github.com/Tommy131
 */
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../providers/certificate_provider.dart';
import '../providers/ssl_settings_provider.dart';
import '../services/openssl_service.dart';
import '../models/certificate.dart';
import 'custom_button.dart';
import 'package:uuid/uuid.dart';
import '../../core/i18n/app_localization.dart';
import '../../core/i18n/localization_keys.dart';

class ImportCertificateDialog extends StatefulWidget {
  const ImportCertificateDialog({super.key});

  @override
  State<ImportCertificateDialog> createState() =>
      _ImportCertificateDialogState();
}

class _ImportCertificateDialogState extends State<ImportCertificateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _certPathController = TextEditingController();
  final _keyPathController = TextEditingController();
  final _passwordController = TextEditingController();

  final _opensslService = OpenSSLService();
  final _uuid = const Uuid();

  bool _isLoading = false;
  bool _hasPrivateKey = true;
  bool _isEncrypted = false;
  bool _certValidated = false;
  bool _keyValidated = false;
  String? _certType;
  Map<String, dynamic>? _certInfo;

  String _tr(String key) {
    return AppLocalization.of(context).translate(key);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _certPathController.dispose();
    _keyPathController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _selectCertFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pem', 'crt', 'cer', 'cert'],
      dialogTitle: _tr(L18nKeys.selectCertificateFile),
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

      debugPrint('Certificate Info: $_certInfo');
      debugPrint('Not Before: ${_certInfo!['notBefore']}');
      debugPrint('Not After: ${_certInfo!['notAfter']}');

      final isCA =
          await _opensslService.isCACertificate(_certPathController.text);
      _certType = isCA ? 'CA' : 'SSL';

      if (_nameController.text.isEmpty && _certInfo != null) {
        final subject = _certInfo!['subject'] as Map<String, String>?;
        _nameController.text =
            subject?['CN'] ?? _tr(L18nKeys.importedCertificate);
      }

      _certValidated = true;

      final notAfter = _certInfo!['notAfter'] as DateTime;
      final isExpired = DateTime.now().isAfter(notAfter);
      final daysUntilExpiry = notAfter.difference(DateTime.now()).inDays;

      String message = '${_tr(L18nKeys.certificateValidated)}: $_certType';
      Color backgroundColor = Colors.green;

      if (isExpired) {
        message += ' (${_tr(L18nKeys.expired)})';
        backgroundColor = Colors.red;
      } else if (daysUntilExpiry <= 30) {
        message +=
            ' (${_tr(L18nKeys.expiresIn)} $daysUntilExpiry ${_tr(L18nKeys.days)})';
        backgroundColor = Colors.orange;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: backgroundColor,
          ),
        );
      }
    } catch (e) {
      debugPrint('Validation error: $e');
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

    setState(() {
      _isLoading = true;
    });

    try {
      final settingsProvider = context.read<SSLSettingsProvider>();
      final certificateProvider = context.read<CertificateProvider>();
      final settings = settingsProvider.settings!;

      final outputPath = settings.getCertificatePathByType(_certType!);

      await Directory(outputPath).create(recursive: true);

      final certFile = File(_certPathController.text);
      final newCertPath = '$outputPath/${_nameController.text}-cert.pem';
      await certFile.copy(newCertPath);

      String? newKeyPath;
      if (_hasPrivateKey && _keyPathController.text.isNotEmpty) {
        final keyFile = File(_keyPathController.text);
        newKeyPath = '$outputPath/${_nameController.text}-key.pem';
        await keyFile.copy(newKeyPath);
      }

      // ========== 提取證書詳細信息 ==========
      Map<String, String> extractedDetails = {};
      try {
        extractedDetails =
            await _opensslService.extractCertificateDetails(newCertPath);
        debugPrint('Extracted certificate details: $extractedDetails');
      } catch (e) {
        debugPrint('Warning: Failed to extract detailed certificate info: $e');
        // 繼續執行，即使提取詳細信息失敗
      }
      // ========== 添加結束 ==========

      final subject = _certInfo!['subject'] as Map<String, String>;
      final certificate = Certificate(
        id: _uuid.v4(),
        name: _nameController.text,
        type: _certType!,
        filePath: newCertPath,
        issueDate: _certInfo!['notBefore'] as DateTime,
        expiryDate: _certInfo!['notAfter'] as DateTime,
        isEncrypted: _isEncrypted && _hasPrivateKey,
        password:
            _isEncrypted && _hasPrivateKey ? _passwordController.text : null,
        details: {
          if (newKeyPath != null) 'keyPath': newKeyPath,
          'commonName': subject['CN'] ?? '',
          'organization': subject['O'] ?? '',
          'organizationalUnit': subject['OU'] ?? '',
          'country': subject['C'] ?? '',
          'state': subject['ST'] ?? '',
          'city': subject['L'] ?? '',
          'email': subject['emailAddress'] ?? '',
          'serial': _certInfo!['serial'] as String? ?? '',
          'imported': 'true',
          ...extractedDetails,
        },
      );

      await certificateProvider.addCertificate(certificate);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${_tr(L18nKeys.certificateImportedSuccessfullyTo)} $_certType/ ${_tr(L18nKeys.folder)}'),
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
      title: Text(_tr(L18nKeys.importCertificate)),
      content: SizedBox(
        width: 600,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _certPathController,
                  decoration: InputDecoration(
                    labelText: _tr(L18nKeys.certificateFileRequired),
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
                if (_certValidated && _certInfo != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          theme.colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _certType == 'CA'
                                  ? Icons.security
                                  : Icons.verified_user,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_tr(L18nKeys.type)}: $_certType ${_tr(L18nKeys.certificate)}',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        _buildInfoRow(
                            _tr(L18nKeys.commonName),
                            (_certInfo!['subject']
                                    as Map<String, String>)['CN'] ??
                                'N/A'),
                        _buildInfoRow(
                            _tr(L18nKeys.organization),
                            (_certInfo!['subject']
                                    as Map<String, String>)['O'] ??
                                'N/A'),
                        _buildInfoRow(
                            _tr(L18nKeys.issueDate),
                            _formatDateTime(
                                _certInfo!['notBefore'] as DateTime)),
                        _buildInfoRow(
                            _tr(L18nKeys.expiryDate),
                            _formatDateTime(
                                _certInfo!['notAfter'] as DateTime)),
                        _buildInfoRow(
                            _tr(L18nKeys.daysUntilExpiry),
                            _getDaysUntilExpiry(
                                _certInfo!['notAfter'] as DateTime)),
                        if (DateTime.now()
                            .isAfter(_certInfo!['notAfter'] as DateTime))
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.red),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error,
                                      color: Colors.red, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _tr(L18nKeys.thisCertificateHasExpired),
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else if ((_certInfo!['notAfter'] as DateTime)
                                .difference(DateTime.now())
                                .inDays <=
                            30)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.orange),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.warning,
                                      color: Colors.orange, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${_tr(L18nKeys.thisCertificateWillExpireIn)} ${(_certInfo!['notAfter'] as DateTime).difference(DateTime.now()).inDays} ${_tr(L18nKeys.days)}',
                                      style: const TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
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
            width: 110,
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
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getDaysUntilExpiry(DateTime expiryDate) {
    final days = expiryDate.difference(DateTime.now()).inDays;
    if (days < 0) {
      return '${_tr(L18nKeys.expired)} ${-days} ${_tr(L18nKeys.daysAgo)}';
    }
    return '$days ${_tr(L18nKeys.days)}';
  }
}
