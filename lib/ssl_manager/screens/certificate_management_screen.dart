import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import '../../core/i18n/app_localization.dart';
import '../../core/i18n/localization_keys.dart';
import '../models/certificate_purpose.dart';
import '../providers/certificate_provider.dart';
import '../providers/ssl_settings_provider.dart';
import '../services/openssl_service.dart';
import '../widgets/certificate_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/import_certificate_dialog.dart';
import '../widgets/import_pfx_dialog.dart';
import '../widgets/import_ssl_certificate_dialog.dart';
import '../models/certificate.dart';

class CertificateManagementScreen extends StatefulWidget {
  const CertificateManagementScreen({super.key});

  @override
  State<CertificateManagementScreen> createState() =>
      _CertificateManagementScreenState();
}

class _CertificateManagementScreenState
    extends State<CertificateManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  // 添加翻译辅助方法
  String _tr(String key) {
    return AppLocalization.of(context).translate(key);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final certificateProvider = context.watch<CertificateProvider>();
    final allCerts = _filterCertificates(certificateProvider.certificates);
    final caCerts = _filterCertificates(certificateProvider.caCertificates);
    final sslCerts = _filterCertificates(certificateProvider.sslCertificates);

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: '${_tr(L18nKeys.certTabAll)} (${allCerts.length})'),
            Tab(text: '${_tr(L18nKeys.certTabCA)} (${caCerts.length})'),
            Tab(text: '${_tr(L18nKeys.certTabSSL)} (${sslCerts.length})'),
          ],
        ),
        _buildActionBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildCertificateList(allCerts),
              _buildCertificateList(caCerts),
              _buildCertificateList(sslCerts),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: _tr(L18nKeys.certSearchPlaceholder),
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(width: 16),
          CustomButton(
            text: _tr(L18nKeys.certImport),
            icon: Icons.file_upload,
            onPressed: _showImportOptions,
            isOutlined: true,
          ),
          const SizedBox(width: 8),
          CustomButton(
            text: _tr(L18nKeys.certGenerateCA),
            icon: Icons.add,
            onPressed: () => _showCertDialog(true),
          ),
          const SizedBox(width: 8),
          CustomButton(
            text: _tr(L18nKeys.certGenerateSSL),
            icon: Icons.add,
            onPressed: () => _showCertDialog(false),
            isOutlined: true,
          ),
        ],
      ),
    );
  }

  List<Certificate> _filterCertificates(List<Certificate> certs) {
    if (_searchQuery.isEmpty) return certs;
    return certs.where((cert) {
      final name = cert.name.toLowerCase();
      final cn = cert.details['commonName']?.toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || cn.contains(query);
    }).toList();
  }

  Widget _buildCertificateList(List<Certificate> certs) {
    if (certs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _tr(L18nKeys.certNoFound),
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: certs.length,
      itemBuilder: (context, index) => CertificateCard(
        certificate: certs[index],
        onTap: () => _showCertDetails(certs[index]),
        onDelete: () => _deleteCertificate(certs[index]),
        onExport: () => _exportCertificate(certs[index]),
      ),
    );
  }

  void _showCertDetails(Certificate cert) {
    /* final details = [
      ('Type', cert.type),
      ('Common Name', cert.details['commonName'] ?? 'N/A'),
      ('Organization', cert.details['organization'] ?? 'N/A'),
      ('Country', cert.details['country'] ?? 'N/A'),
      ('State', cert.details['state'] ?? 'N/A'),
      ('City', cert.details['city'] ?? 'N/A'),
      ('Issuer CN', cert.details['issuerCN'] ?? 'N/A'),
      ('Issuer Org', cert.details['issuerO'] ?? 'N/A'),
      ('Issue Date', cert.issueDate.toString()),
      ('Expiry Date', cert.expiryDate.toString()),
      ('Days Until Expiry', '${cert.daysUntilExpiry}'),
      ('Encrypted', cert.isEncrypted ? 'Yes' : 'No'),
      ('Serial', cert.details['serial'] ?? 'N/A'),
      ('File Path', cert.filePath),
      if (cert.details['keyPath'] != null)
        ('Key Path', cert.details['keyPath']!),
      if (cert.details['chainPath'] != null)
        ('Chain Path', cert.details['chainPath']!),
      if (cert.details['fullChainPath'] != null)
        ('Full Chain Path', cert.details['fullChainPath']!),
      if (cert.details['chainLength'] != null)
        ('Chain Length', '${cert.details['chainLength']} certificate(s)'),
      if (cert.details['imported'] == 'true')
        ('Imported From', cert.details['importedFrom'] ?? 'External'),
      if (cert.purposes.isNotEmpty)
        (
          'Purpose',
          cert.purposes
              .map((id) => CertificatePurposes.getById(id)?.name ?? id)
              .join(', ')
        ),
      if (cert.details['purposeName'] != null)
        ('Purpose Name', cert.details['purposeName']!),
    ]; */

    final details = [
      (_tr(L18nKeys.certDetailType), cert.type),
      (
        _tr(L18nKeys.certDetailCommonName),
        cert.details['commonName'] ?? _tr(L18nKeys.certNA)
      ),
      (
        _tr(L18nKeys.certDetailOrganization),
        cert.details['organization'] ?? _tr(L18nKeys.certNA)
      ),
      (
        _tr(L18nKeys.certDetailCountry),
        cert.details['country'] ?? _tr(L18nKeys.certNA)
      ),
      (
        _tr(L18nKeys.certDetailState),
        cert.details['state'] ?? _tr(L18nKeys.certNA)
      ),
      (
        _tr(L18nKeys.certDetailCity),
        cert.details['city'] ?? _tr(L18nKeys.certNA)
      ),
      (
        _tr(L18nKeys.certDetailIssuerCN),
        cert.details['issuerCN'] ?? _tr(L18nKeys.certNA)
      ),
      (
        _tr(L18nKeys.certDetailIssuerOrg),
        cert.details['issuerO'] ?? _tr(L18nKeys.certNA)
      ),
      (_tr(L18nKeys.certDetailIssueDate), cert.issueDate.toString()),
      (_tr(L18nKeys.certDetailExpiryDate), cert.expiryDate.toString()),
      (_tr(L18nKeys.certDetailDaysUntilExpiry), '${cert.daysUntilExpiry}'),
      (
        _tr(L18nKeys.certDetailEncrypted),
        cert.isEncrypted ? _tr(L18nKeys.certYes) : _tr(L18nKeys.certNo)
      ),
      (
        _tr(L18nKeys.certDetailSerial),
        cert.details['serial'] ?? _tr(L18nKeys.certNA)
      ),
      (_tr(L18nKeys.certDetailFilePath), cert.filePath),
      if (cert.details['keyPath'] != null)
        (_tr(L18nKeys.certDetailKeyPath), cert.details['keyPath']!),
      if (cert.details['chainPath'] != null)
        (_tr(L18nKeys.certDetailChainPath), cert.details['chainPath']!),
      if (cert.details['fullChainPath'] != null)
        (_tr(L18nKeys.certDetailFullChainPath), cert.details['fullChainPath']!),
      if (cert.details['chainLength'] != null)
        (
          _tr(L18nKeys.certDetailChainLength),
          '${cert.details['chainLength']} ${_tr(L18nKeys.certCertificates)}'
        ),
      if (cert.details['imported'] == 'true')
        (
          _tr(L18nKeys.certDetailImportedFrom),
          cert.details['importedFrom'] ?? _tr(L18nKeys.certExternal)
        ),
      if (cert.purposes.isNotEmpty)
        (
          _tr(L18nKeys.certDetailPurpose),
          cert.purposes
              .map((id) => CertificatePurposes.getById(id)?.name ?? id)
              .join(', ')
        ),
      if (cert.details['purposeName'] != null)
        (_tr(L18nKeys.certDetailPurposeName), cert.details['purposeName']!),
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(cert.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: details.map((d) => _DetailRow(d.$1, d.$2)).toList(),
          ),
        ),
        actions: [
          if (cert.details['fullChainPath'] != null)
            TextButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        '${_tr(L18nKeys.certPath)}: ${cert.details['fullChainPath']}')),
              ),
              icon: const Icon(Icons.copy),
              label: Text(_tr(L18nKeys.certCopyFullChainPath)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_tr(L18nKeys.certClose)),
          ),
        ],
      ),
    );
  }

  void _deleteCertificate(Certificate cert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_tr(L18nKeys.certDeleteTitle)),
        content: Text(_tr(L18nKeys.certDeleteConfirm)
            .replaceAll('{name}', '"${cert.name}"')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_tr(L18nKeys.certCancel)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context
                  .read<CertificateProvider>()
                  .removeCertificate(cert.id);
              try {
                await File(cert.filePath).delete();
                if (cert.details['keyPath'] != null) {
                  await File(cert.details['keyPath']!).delete();
                }
              } catch (_) {}
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(_tr(L18nKeys.certDeleteSuccess))),
                );
              }
            },
            child: Text(_tr(L18nKeys.certDelete),
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _exportCertificate(Certificate cert) {
    showDialog(
      context: context,
      builder: (context) => _ExportPFXDialog(
        certificate: cert,
        opensslService: OpenSSLService(),
      ),
    );
  }

  void _showImportOptions() {
    final options = [
      (
        Icons.verified_user,
        _tr(L18nKeys.certImportSSLTitle),
        _tr(L18nKeys.certImportSSLDesc),
        () => const ImportSSLCertificateDialog()
      ),
      (
        Icons.description,
        _tr(L18nKeys.certImportCATitle),
        _tr(L18nKeys.certImportCADesc),
        () => const ImportCertificateDialog()
      ),
      (
        Icons.lock,
        _tr(L18nKeys.certImportPFXTitle),
        _tr(L18nKeys.certImportPFXDesc),
        () => const ImportPFXDialog()
      ),
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_tr(L18nKeys.certImportCertificate)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options
              .map((opt) => ListTile(
                    leading: Icon(opt.$1),
                    title: Text(opt.$2),
                    subtitle: Text(opt.$3),
                    onTap: () {
                      Navigator.pop(context);
                      showDialog(
                          context: context, builder: (context) => opt.$4());
                    },
                  ))
              .expand((widget) => [widget, const Divider()])
              .toList()
            ..removeLast(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_tr(L18nKeys.certCancel)),
          ),
        ],
      ),
    );
  }

  void _showCertDialog(bool isCA) {
    showDialog(
      context: context,
      builder: (context) => _GenerateCertDialog(isCA: isCA),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text('$label:',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

// 通用证书生成对话框
class _GenerateCertDialog extends StatefulWidget {
  final bool isCA;

  const _GenerateCertDialog({required this.isCA});

  @override
  State<_GenerateCertDialog> createState() => _GenerateCertDialogState();
}

class _GenerateCertDialogState extends State<_GenerateCertDialog> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _controllers;

  CertificatePurpose? _selectedPurpose;
  final _customKeyUsageController = TextEditingController();
  final _customExtKeyUsageController = TextEditingController();
  bool _showCustomPurpose = false;

  Certificate? _selectedCA;
  bool _encrypt = false;
  bool _isLoading = false;
  bool _useCustomConfig = false;
  Map<String, String> _configDefaults = {};

  // 添加翻译辅助方法
  String _tr(String key) {
    return AppLocalization.of(context).translate(key);
  }

  @override
  void initState() {
    super.initState();
    _controllers = {
      'name': TextEditingController(),
      'country': TextEditingController(text: 'US'),
      'state': TextEditingController(),
      'city': TextEditingController(),
      'organization': TextEditingController(),
      'orgUnit': TextEditingController(),
      'commonName': TextEditingController(),
      'email': TextEditingController(),
      'validity': TextEditingController(text: widget.isCA ? '3650' : '365'),
      'password': TextEditingController(),
      'caPassword': TextEditingController(),
      'san': TextEditingController(),
    };
    _loadConfig();

    _selectedPurpose = widget.isCA
        ? CertificatePurposes.rootCA
        : CertificatePurposes.tlsServer;
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    _customKeyUsageController.dispose();
    _customExtKeyUsageController.dispose();
    super.dispose();
  }

  bool get isCA => widget.isCA;

  Future<void> _loadConfig() async {
    try {
      final content =
          await context.read<SSLSettingsProvider>().getConfigContent();
      _parseConfigDefaults(content);
    } catch (_) {}
  }

  void _parseConfigDefaults(String content) {
    final lines = content.split('\n');
    bool inDn = false;
    final defaults = <String, String>{};

    for (var line in lines) {
      line = line.trim();
      if (line == '[ dn ]' ||
          line == '[dn]' ||
          line == '[ req_distinguished_name ]' ||
          line == '[req_distinguished_name]') {
        inDn = true;
        continue;
      }
      if (line.startsWith('[') && inDn) break;
      if (inDn && line.contains('=') && !line.startsWith('#')) {
        final parts = line.split('=');
        if (parts.length >= 2) {
          defaults[parts[0].trim()] = parts.sublist(1).join('=').trim();
        }
      }
    }
    _configDefaults = defaults;
  }

  void _applyConfigDefaults() {
    if (_configDefaults.isEmpty) return;
    setState(() {
      final mapping = {
        'C': 'country',
        'ST': 'state',
        'L': 'city',
        'O': 'organization',
        'OU': 'orgUnit',
        'CN': 'commonName',
        'emailAddress': 'email',
      };
      mapping.forEach((k, v) {
        if (_configDefaults[k]?.isNotEmpty == true) {
          _controllers[v]!.text = _configDefaults[k]!;
        }
      });
    });
  }

  void _clearDefaults() {
    setState(() {
      _controllers['country']!.text = 'US';
      for (var k in [
        'state',
        'city',
        'organization',
        'orgUnit',
        'commonName',
        'email'
      ]) {
        _controllers[k]!.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<SSLSettingsProvider>().settings;
    final configPath = settings?.opensslConfigPath ?? '';

    return Dialog(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 750,
        constraints: const BoxConstraints(maxHeight: 700),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.colorScheme.surface,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题栏
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primaryContainer,
                    theme.colorScheme.primaryContainer.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiary.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCA ? Icons.security : Icons.verified_user,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_tr(L18nKeys.certGenTitle)} ${isCA ? _tr(L18nKeys.certTabCA) : _tr(L18nKeys.certTabSSL)}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _tr(L18nKeys.certGenSubtitle),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    tooltip: _tr(L18nKeys.certGenClose),
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ],
              ),
            ),

            // 内容区域
            Expanded(
              child: Container(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildConfigSection(theme, configPath),
                        const SizedBox(height: 16),
                        _buildPurposeSection(theme),
                        const SizedBox(height: 16),
                        if (!isCA) ...[
                          _buildCASelector(theme),
                          const SizedBox(height: 16),
                        ],

                        // 表单填写区域标题
                        _buildSectionHeader(
                          theme,
                          _tr(L18nKeys.certGenInfoTitle),
                          Icons.article,
                        ),
                        const SizedBox(height: 12),

                        ..._buildFormFields(),

                        const SizedBox(height: 16),
                        _buildSectionHeader(
                          theme,
                          _tr(L18nKeys.certGenSecurityTitle),
                          Icons.lock,
                        ),
                        const SizedBox(height: 12),

                        _buildEncryptionSection(theme),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 底部按钮栏
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 进度提示
                  if (_isLoading)
                    Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _tr(L18nKeys.certGenGenerating),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    )
                  else
                    const SizedBox.shrink(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed:
                            _isLoading ? null : () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child: Text(_tr(L18nKeys.certGenCancel)),
                      ),
                      const SizedBox(width: 12),
                      CustomButton(
                        text: _tr(L18nKeys.certGenGenerate),
                        icon: Icons.add_circle,
                        onPressed: _generateCertificate,
                        isLoading: _isLoading,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// 区块标题 - 不需要修改,因为title参数已经是翻译后的字符串
  Widget _buildSectionHeader(ThemeData theme, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

// 配置区域
  Widget _buildConfigSection(ThemeData theme, String configPath) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.settings_applications,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _tr(L18nKeys.certGenConfigTitle),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            value: _useCustomConfig,
            onChanged: (v) => setState(() {
              _useCustomConfig = v ?? false;
              _useCustomConfig ? _applyConfigDefaults() : _clearDefaults();
            }),
            title: Text(_tr(L18nKeys.certGenUseCustomConfig)),
            subtitle: Text(
              _useCustomConfig
                  ? '${_tr(L18nKeys.certGenUsingConfig)}$configPath'
                  : _tr(L18nKeys.certGenUsingDefault),
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            dense: true,
          ),
          if (_useCustomConfig && _configDefaults.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.green.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 14,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _tr(L18nKeys.certGenConfigApplied),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _configDefaults.entries
                        .map((e) => '${e.key}=${e.value}')
                        .join(', '),
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

// 用途选择区域
  Widget _buildPurposeSection(ThemeData theme) {
    final purposes =
        isCA ? CertificatePurposes.caPurposes : CertificatePurposes.sslPurposes;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.security,
                  size: 18,
                  color: theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _tr(L18nKeys.certGenPurposeTitle),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<CertificatePurpose>(
            value: _selectedPurpose,
            decoration: InputDecoration(
              labelText: _tr(L18nKeys.certGenSelectPurpose),
              helperText: _tr(L18nKeys.certGenPurposeHelper),
              helperStyle: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            isExpanded: true,
            items: purposes.map((p) {
              return DropdownMenuItem(
                value: p,
                child: Text(
                  p.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedPurpose = value;
                _showCustomPurpose = value?.id == 'custom';
                if (!_showCustomPurpose) {
                  _customKeyUsageController.clear();
                  _customExtKeyUsageController.clear();
                }
              });
            },
            validator: (v) => v == null ? _tr(L18nKeys.certGenRequired) : null,
          ),
          if (_selectedPurpose != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedPurpose!.description,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  if (_selectedPurpose!.id != 'custom') ...[
                    const SizedBox(height: 8),
                    if (_selectedPurpose!.keyUsage.isNotEmpty) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 110,
                            child: Text(
                              _tr(L18nKeys.certGenKeyUsage),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.7),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              _selectedPurpose!.keyUsage.join(', '),
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (_selectedPurpose!.extendedKeyUsage.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 110,
                            child: Text(
                              _tr(L18nKeys.certGenExtendedUsage),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.7),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              _selectedPurpose!.extendedKeyUsage.join(', '),
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
          if (_showCustomPurpose) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: _customKeyUsageController,
              decoration: InputDecoration(
                labelText: _tr(L18nKeys.certGenCustomKeyUsage),
                hintText: _tr(L18nKeys.certGenCustomKeyUsageHint),
                helperText: _tr(L18nKeys.certGenCommaSeparated),
                helperStyle: const TextStyle(fontSize: 10),
              ),
              maxLines: 2,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _customExtKeyUsageController,
              decoration: InputDecoration(
                labelText: _tr(L18nKeys.certGenCustomExtKeyUsage),
                hintText: _tr(L18nKeys.certGenCustomExtKeyUsageHint),
                helperText: _tr(L18nKeys.certGenCommaSeparated),
                helperStyle: const TextStyle(fontSize: 10),
              ),
              maxLines: 2,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 14,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _tr(L18nKeys.certGenCommonKeyUsage),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'digitalSignature, keyEncipherment, keyAgreement, keyCertSign, cRLSign',
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 14,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _tr(L18nKeys.certGenCommonExtKeyUsage),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'serverAuth, clientAuth, codeSigning, emailProtection, timeStamping, OCSPSigning',
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

// CA 选择器
  Widget _buildCASelector(ThemeData theme) {
    final caCerts = context.watch<CertificateProvider>().caCertificates;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.admin_panel_settings,
                  size: 18,
                  color: theme.colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _tr(L18nKeys.certGenCATitle),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<Certificate>(
            value: _selectedCA,
            decoration: InputDecoration(
              labelText: _tr(L18nKeys.certGenSelectCA),
              helperText: _tr(L18nKeys.certGenSelectCAHelper),
              helperStyle: const TextStyle(fontSize: 11),
            ),
            isExpanded: true,
            items: caCerts
                .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                .toList(),
            onChanged: (v) => setState(() => _selectedCA = v),
            validator: (v) =>
                v == null ? _tr(L18nKeys.certGenPleaseSelectCA) : null,
          ),
          if (_selectedCA?.isEncrypted == true) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: _controllers['caPassword'],
              decoration: InputDecoration(
                labelText: _tr(L18nKeys.certGenCAPassword),
                prefixIcon: const Icon(Icons.lock),
              ),
              obscureText: true,
              validator: (v) =>
                  v?.isEmpty == true ? _tr(L18nKeys.certGenRequired) : null,
            ),
          ],
        ],
      ),
    );
  }

// 加密选项
  Widget _buildEncryptionSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          CheckboxListTile(
            value: _encrypt,
            onChanged: (v) => setState(() => _encrypt = v ?? false),
            title: Text(_tr(L18nKeys.certGenEncryptKey)),
            subtitle: Text(
              _tr(L18nKeys.certGenEncryptKeyDesc),
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          if (_encrypt) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: _controllers['password'],
              decoration: InputDecoration(
                labelText: _tr(L18nKeys.certGenPassword),
                prefixIcon: const Icon(Icons.lock),
                helperText: _tr(L18nKeys.certGenPasswordHelper),
                helperStyle: const TextStyle(fontSize: 11),
              ),
              obscureText: true,
              validator: (v) => _encrypt && v?.isEmpty == true
                  ? _tr(L18nKeys.certGenRequired)
                  : null,
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildFormFields() {
    // 修正：使用命名字段而不是位置索引
    /* final fields = [
      FieldConfig(
          'name', 'Certificate Name *', isCA ? 'MyRootCA' : 'example.com'),
      FieldConfig('country', 'Country Code *', 'US', isRow: true),
      FieldConfig('state', 'State/Province *', null, isRow: true),
      FieldConfig('city', 'City *', null),
      FieldConfig('organization', 'Organization *', null),
      FieldConfig('orgUnit', 'Organizational Unit *', null),
      FieldConfig(
          'commonName', 'Common Name *', isCA ? 'My Root CA' : 'example.com'),
      FieldConfig('email', 'Email', 'admin@example.com'),
      if (!isCA)
        FieldConfig('san', 'Subject Alternative Names',
            'www.example.com,mail.example.com'),
      FieldConfig('validity', 'Validity (days) *', null),
    ]; */
    final fields = [
      FieldConfig(
          'name',
          _tr(L18nKeys.certFieldName),
          isCA
              ? _tr(L18nKeys.certFieldNameHintCA)
              : _tr(L18nKeys.certFieldNameHintSSL)),
      FieldConfig('country', _tr(L18nKeys.certFieldCountry), 'US', isRow: true),
      FieldConfig('state', _tr(L18nKeys.certFieldState), null, isRow: true),
      FieldConfig('city', _tr(L18nKeys.certFieldCity), null),
      FieldConfig('organization', _tr(L18nKeys.certFieldOrganization), null),
      FieldConfig('orgUnit', _tr(L18nKeys.certFieldOrgUnit), null),
      FieldConfig(
          'commonName',
          _tr(L18nKeys.certFieldCommonName),
          isCA
              ? _tr(L18nKeys.certFieldCommonNameHintCA)
              : _tr(L18nKeys.certFieldCommonNameHintSSL)),
      FieldConfig('email', _tr(L18nKeys.certFieldEmail),
          _tr(L18nKeys.certFieldEmailHint)),
      if (!isCA)
        FieldConfig(
            'san', _tr(L18nKeys.certFieldSAN), _tr(L18nKeys.certFieldSANHint)),
      FieldConfig('validity', _tr(L18nKeys.certFieldValidity), null),
    ];

    return fields.expand((f) {
      final key = f.key;
      final label = f.label;
      final hint = f.hint;
      final configKeyMap = {
        'country': 'C',
        'state': 'ST',
        'city': 'L',
        'organization': 'O',
        'orgUnit': 'OU',
        'commonName': 'CN',
        'email': 'emailAddress',
      };
      final hasHelper = _useCustomConfig &&
          configKeyMap.containsKey(key) &&
          _configDefaults.containsKey(configKeyMap[key]);

      Widget field;
      if (key == 'country' || key == 'state') {
        final isCountry = key == 'country';
        field = Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _controllers[key],
                decoration: InputDecoration(
                  labelText: label,
                  hintText: hint,
                  helperText:
                      hasHelper ? _tr(L18nKeys.certFieldFromConfig) : null,
                  helperStyle: const TextStyle(
                    fontSize: 10,
                    color: Colors.green,
                  ),
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
                maxLength: isCountry ? 2 : null,
                validator: (v) =>
                    v?.isEmpty == true ? _tr(L18nKeys.certGenRequired) : null,
              ),
            ),
            if (isCountry) ...[
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _controllers['state'],
                  decoration: InputDecoration(
                    labelText: _tr(L18nKeys.certFieldState),
                    helperText:
                        _useCustomConfig && _configDefaults['ST'] != null
                            ? _tr(L18nKeys.certFieldFromConfig)
                            : null,
                    helperStyle: const TextStyle(
                      fontSize: 10,
                      color: Colors.green,
                    ),
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  ),
                  validator: (v) =>
                      v?.isEmpty == true ? _tr(L18nKeys.certGenRequired) : null,
                ),
              ),
            ],
          ],
        );
      } else {
        final requiredFields = [
          'name',
          'validity',
          'commonName',
          'organization',
          'orgUnit',
          'city'
        ];

        final textColor = (Theme.of(context).brightness == Brightness.dark)
            ? Colors.white
            : Colors.black;
        field = TextFormField(
          controller: _controllers[key],
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            helperText: hasHelper ? _tr(L18nKeys.certFieldFromConfig) : null,
            helperStyle: const TextStyle(
              fontSize: 10,
              color: Colors.green,
            ),
            hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
            labelStyle: TextStyle(color: textColor.withOpacity(0.5)),
          ),
          keyboardType: key == 'validity' ? TextInputType.number : null,
          validator: requiredFields.contains(key)
              ? (v) {
                  if (v?.isEmpty == true) return _tr(L18nKeys.certGenRequired);
                  if (key == 'validity' && int.tryParse(v!) == null) {
                    return _tr(L18nKeys.certFieldInvalidNumber);
                  }
                  return null;
                }
              : null,
        );
      }

      return [field, const SizedBox(height: 16)];
    }).toList();
  }

  Future<void> _generateCertificate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final settingsProvider = context.read<SSLSettingsProvider>();
      final certProvider = context.read<CertificateProvider>();
      final settings = settingsProvider.settings!;
      final opensslService = OpenSSLService();

      final Certificate cert;
      if (isCA) {
        cert = await opensslService.generateCACertificate(
          outputPath: settings.getCertificatePathByType('CA'),
          caName: _controllers['name']!.text,
          validityDays: int.parse(_controllers['validity']!.text),
          country: _controllers['country']!.text,
          state: _controllers['state']!.text,
          city: _controllers['city']!.text,
          organization: _controllers['organization']!.text,
          organizationalUnit: _controllers['orgUnit']!.text,
          commonName: _controllers['commonName']!.text,
          email: _controllers['email']!.text.isEmpty
              ? null
              : _controllers['email']!.text,
          encrypt: _encrypt,
          password: _encrypt ? _controllers['password']!.text : null,
          configPath: _useCustomConfig ? settings.opensslConfigPath : null,
          purpose: _selectedPurpose, // 添加用途
          customKeyUsage:
              _showCustomPurpose ? _customKeyUsageController.text : null,
          customExtKeyUsage:
              _showCustomPurpose ? _customExtKeyUsageController.text : null,
        );
      } else {
        final sanList = _controllers['san']!.text.isNotEmpty
            ? _controllers['san']!.text.split(',').map((e) => e.trim()).toList()
            : null;

        cert = await opensslService.generateSSLCertificate(
          outputPath: settings.getCertificatePathByType('SSL'),
          certName: _controllers['name']!.text,
          caCertPath: _selectedCA!.filePath,
          caKeyPath: _selectedCA!.details['keyPath']!,
          validityDays: int.parse(_controllers['validity']!.text),
          country: _controllers['country']!.text,
          state: _controllers['state']!.text,
          city: _controllers['city']!.text,
          organization: _controllers['organization']!.text,
          organizationalUnit: _controllers['orgUnit']!.text,
          commonName: _controllers['commonName']!.text,
          email: _controllers['email']!.text.isEmpty
              ? null
              : _controllers['email']!.text,
          subjectAltNames: sanList,
          encrypt: _encrypt,
          password: _encrypt ? _controllers['password']!.text : null,
          caPassword: _selectedCA!.isEncrypted
              ? _controllers['caPassword']!.text
              : null,
          configPath: _useCustomConfig ? settings.opensslConfigPath : null,
          purpose: _selectedPurpose, // 添加用途
          customKeyUsage:
              _showCustomPurpose ? _customKeyUsageController.text : null,
          customExtKeyUsage:
              _showCustomPurpose ? _customExtKeyUsageController.text : null,
        );
      }
      await certProvider.addCertificate(cert);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${isCA ? _tr(L18nKeys.certGenSuccessCA) : _tr(L18nKeys.certGenSuccessSSL)}'
              '${_useCustomConfig ? _tr(L18nKeys.certGenSuccessCustomConfig) : ''}'
              '\n${_tr(L18nKeys.certGenSuccessPurpose)}${_selectedPurpose?.name ?? 'Default'}',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _ExportPFXDialog extends StatefulWidget {
  final Certificate certificate;
  final OpenSSLService opensslService;

  const _ExportPFXDialog(
      {required this.certificate, required this.opensslService});

  @override
  State<_ExportPFXDialog> createState() => _ExportPFXDialogState();
}

class _ExportPFXDialogState extends State<_ExportPFXDialog> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _pfxPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _includeCACert = false;
  Certificate? _selectedCA;

  // 添加翻译辅助方法
  String _tr(String key) {
    return AppLocalization.of(context).translate(key);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _pfxPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final caCerts = context.watch<CertificateProvider>().caCertificates;

    return AlertDialog(
      title: Text(_tr(L18nKeys.certExportTitle)),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.certificate.isEncrypted)
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: _tr(L18nKeys.certExportCertPassword),
                ),
                obscureText: true,
                validator: (v) =>
                    v?.isEmpty == true ? _tr(L18nKeys.certGenRequired) : null,
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _pfxPasswordController,
              decoration: InputDecoration(
                labelText: _tr(L18nKeys.certExportPFXPassword),
              ),
              obscureText: true,
              validator: (v) =>
                  v?.isEmpty == true ? _tr(L18nKeys.certGenRequired) : null,
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              value: _includeCACert,
              onChanged: (v) => setState(() => _includeCACert = v ?? false),
              title: Text(_tr(L18nKeys.certExportIncludeCA)),
              contentPadding: EdgeInsets.zero,
            ),
            if (_includeCACert) ...[
              const SizedBox(height: 8),
              DropdownButtonFormField<Certificate>(
                value: _selectedCA,
                decoration: InputDecoration(
                  labelText: _tr(L18nKeys.certExportSelectCA),
                ),
                items: caCerts
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c.name),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCA = v),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(_tr(L18nKeys.certCancel)),
        ),
        CustomButton(
          text: _tr(L18nKeys.certExportButton),
          onPressed: _exportToPFX,
          isLoading: _isLoading,
        ),
      ],
    );
  }

  Future<void> _exportToPFX() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final outputPath = await FilePicker.platform.saveFile(
        dialogTitle: _tr(L18nKeys.certExportSaveTitle),
        fileName: '${widget.certificate.name}.pfx',
        type: FileType.custom,
        allowedExtensions: ['pfx'],
      );

      if (outputPath == null) {
        setState(() => _isLoading = false);
        return;
      }

      await widget.opensslService.exportToPFX(
        certPath: widget.certificate.filePath,
        keyPath: widget.certificate.details['keyPath']!,
        pfxPath: outputPath,
        pfxPassword: _pfxPasswordController.text,
        keyPassword:
            widget.certificate.isEncrypted ? _passwordController.text : null,
        caCertPath: _includeCACert && _selectedCA != null
            ? _selectedCA!.filePath
            : null,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_tr(L18nKeys.certExportSuccess)),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_tr(L18nKeys.certExportError)}$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class FieldConfig {
  final String key;
  final String label;
  final String? hint;
  final bool isRow;

  FieldConfig(this.key, this.label, this.hint, {this.isRow = false});
}
