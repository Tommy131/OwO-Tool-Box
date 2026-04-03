import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/localization_service.dart';
import '../localization/localization_keys.dart';
import '../models/ssl_command_result.dart';
import '../models/ssl_config.dart';
import 'widgets/ssl_manager_sidebar.dart';
import 'widgets/ssl_operation_tab.dart';
import 'widgets/ssl_settings_tab.dart';
import 'widgets/ssl_template_tab.dart';
import '../providers/ssl_certificate_manager_provider.dart';

class SslCertificateManagerPage extends StatefulWidget {
  const SslCertificateManagerPage({super.key});

  @override
  State<SslCertificateManagerPage> createState() =>
      _SslCertificateManagerPageState();
}

class _SslCertificateManagerPageState extends State<SslCertificateManagerPage>
    with SingleTickerProviderStateMixin {
  final _baseDirController = TextEditingController();
  final _daysController = TextEditingController();
  final _domainController = TextEditingController();
  final _certNameController = TextEditingController();
  final _rootCaNameController = TextEditingController();
  final _ipController = TextEditingController();
  final _ocspServerUrlController = TextEditingController();
  final _crlUrlController = TextEditingController();
  final _userConfigPathController = TextEditingController();
  final _opensslConfigPathController = TextEditingController();
  final _templateController = TextEditingController();
  final _owoDomainController = TextEditingController();
  final _owoCommonNameController = TextEditingController();
  final _owoCountryNameController = TextEditingController();
  final _owoStateNameController = TextEditingController();
  final _owoLocalityNameController = TextEditingController();
  final _owoOrganizationNameController = TextEditingController();
  final _owoOrganizationUnitController = TextEditingController();
  final _owoEmailController = TextEditingController();
  final _owoExplicitTextController = TextEditingController();
  final _owoChallengePasswordController = TextEditingController();
  final _owoUnstructuredNameController = TextEditingController();
  final _owoOcspDomainController = TextEditingController();
  final _owoRootCaFileNameController = TextEditingController();
  final _dns1Controller = TextEditingController();
  final _dns2Controller = TextEditingController();
  final _ip1Controller = TextEditingController();
  final _ip2Controller = TextEditingController();
  final _tsaPolicy1Controller = TextEditingController();
  final _tsaPolicy2Controller = TextEditingController();
  final _tsaPolicy3Controller = TextEditingController();
  final _caKeyPasswordController = TextEditingController();
  final _pfxPasswordController = TextEditingController();

  late final TabController _tabController;
  bool _controllersReady = false;
  bool _isTemplateExpanded = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<SslCertificateManagerProvider>();
      await provider.initialize();
      if (!mounted) {
        return;
      }
      _syncControllers(provider.config);
      await _loadTemplateContent(provider);
      setState(() {
        _controllersReady = true;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _baseDirController.dispose();
    _daysController.dispose();
    _domainController.dispose();
    _certNameController.dispose();
    _rootCaNameController.dispose();
    _ipController.dispose();
    _ocspServerUrlController.dispose();
    _crlUrlController.dispose();
    _userConfigPathController.dispose();
    _opensslConfigPathController.dispose();
    _templateController.dispose();
    _owoDomainController.dispose();
    _owoCommonNameController.dispose();
    _owoCountryNameController.dispose();
    _owoStateNameController.dispose();
    _owoLocalityNameController.dispose();
    _owoOrganizationNameController.dispose();
    _owoOrganizationUnitController.dispose();
    _owoEmailController.dispose();
    _owoExplicitTextController.dispose();
    _owoChallengePasswordController.dispose();
    _owoUnstructuredNameController.dispose();
    _owoOcspDomainController.dispose();
    _owoRootCaFileNameController.dispose();
    _dns1Controller.dispose();
    _dns2Controller.dispose();
    _ip1Controller.dispose();
    _ip2Controller.dispose();
    _tsaPolicy1Controller.dispose();
    _tsaPolicy2Controller.dispose();
    _tsaPolicy3Controller.dispose();
    _caKeyPasswordController.dispose();
    _pfxPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!Platform.isWindows) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 72),
              const SizedBox(height: 16),
              Text(
                LocalizationKeys.platformNotSupported.tr(context),
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(LocalizationKeys.platformNotSupportedMessage.tr(context)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(LocalizationKeys.sslManager.tr(context))),
      body: Consumer<SslCertificateManagerProvider>(
        builder: (context, provider, child) {
          if (!_controllersReady) {
            return const Center(child: CircularProgressIndicator());
          }
          return Row(
            children: [
              SslManagerSidebar(
                tabController: _tabController,
                onSelect: (index) {
                  setState(() {
                    _tabController.index = index;
                  });
                },
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    SslOperationTab(
                      provider: provider,
                      onRunAction: _runActionAndToast,
                    ),
                    SslSettingsTab(
                      provider: provider,
                      fieldBuilder: _buildField,
                      baseDirController: _baseDirController,
                      daysController: _daysController,
                      domainController: _domainController,
                      certNameController: _certNameController,
                      rootCaNameController: _rootCaNameController,
                      ipController: _ipController,
                      ocspServerUrlController: _ocspServerUrlController,
                      crlUrlController: _crlUrlController,
                      userConfigPathController: _userConfigPathController,
                      opensslConfigPathController: _opensslConfigPathController,
                      caKeyPasswordController: _caKeyPasswordController,
                      pfxPasswordController: _pfxPasswordController,
                      onInitStorage: () =>
                          _handleInitStorage(context, provider),
                      onSaveConfig: () => _handleSaveConfig(context, provider),
                    ),
                    SslTemplateTab(
                      provider: provider,
                      isTemplateExpanded: _isTemplateExpanded,
                      onToggleTemplateExpanded: () {
                        setState(() {
                          _isTemplateExpanded = !_isTemplateExpanded;
                        });
                      },
                      templateController: _templateController,
                      fieldBuilder: _buildField,
                      onApplyToTemplate: () =>
                          _handleApplyTemplateQuickForm(context),
                      onSaveTemplate: () =>
                          _handleSaveTemplate(context, provider),
                      onReloadTemplate: () =>
                          _handleReloadTemplate(context, provider),
                      owoDomainController: _owoDomainController,
                      owoCommonNameController: _owoCommonNameController,
                      owoCountryNameController: _owoCountryNameController,
                      owoStateNameController: _owoStateNameController,
                      owoLocalityNameController: _owoLocalityNameController,
                      owoOrganizationNameController:
                          _owoOrganizationNameController,
                      owoOrganizationUnitController:
                          _owoOrganizationUnitController,
                      owoEmailController: _owoEmailController,
                      owoExplicitTextController: _owoExplicitTextController,
                      owoChallengePasswordController:
                          _owoChallengePasswordController,
                      owoUnstructuredNameController:
                          _owoUnstructuredNameController,
                      owoOcspDomainController: _owoOcspDomainController,
                      owoRootCaFileNameController: _owoRootCaFileNameController,
                      dns1Controller: _dns1Controller,
                      dns2Controller: _dns2Controller,
                      ip1Controller: _ip1Controller,
                      ip2Controller: _ip2Controller,
                      tsaPolicy1Controller: _tsaPolicy1Controller,
                      tsaPolicy2Controller: _tsaPolicy2Controller,
                      tsaPolicy3Controller: _tsaPolicy3Controller,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    bool obscureText = false,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            labelText: label,
            helperText: helperText,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _runActionAndToast(
    BuildContext context,
    String title,
    Future<SslCommandResult> Function() runner,
  ) async {
    final provider = context.read<SslCertificateManagerProvider>();
    await provider.updateConfig(_buildConfigFromInputs(provider.config));
    final result = await runner();
    if (!context.mounted) {
      return;
    }
    final text = result.success
        ? LocalizationKeys.success.tr(context)
        : LocalizationKeys.failed.tr(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$title: $text')));
  }

  Future<void> _handleInitStorage(
    BuildContext context,
    SslCertificateManagerProvider provider,
  ) async {
    final nextConfig = _buildConfigFromInputs(provider.config);
    await provider.updateConfig(nextConfig);
    await provider.initializeStorage();
    await _loadTemplateContent(provider);
    await provider.saveConfig();
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(LocalizationKeys.initStorage.tr(context))),
    );
  }

  Future<void> _handleSaveConfig(
    BuildContext context,
    SslCertificateManagerProvider provider,
  ) async {
    final nextConfig = _buildConfigFromInputs(provider.config);
    await provider.updateConfig(nextConfig);
    await provider.saveConfigAndSyncTemplate();
    await _loadTemplateContent(provider);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(LocalizationKeys.saveConfig.tr(context))),
    );
  }

  void _handleApplyTemplateQuickForm(BuildContext context) {
    _applyQuickFormToTemplate();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(LocalizationKeys.applyToTemplate.tr(context))),
    );
  }

  Future<void> _handleSaveTemplate(
    BuildContext context,
    SslCertificateManagerProvider provider,
  ) async {
    await provider.saveOpenSslTemplateContent(_templateController.text);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(LocalizationKeys.saveTemplate.tr(context))),
    );
  }

  Future<void> _handleReloadTemplate(
    BuildContext context,
    SslCertificateManagerProvider provider,
  ) async {
    await _loadTemplateContent(provider);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(LocalizationKeys.reloadTemplate.tr(context))),
    );
  }

  SslConfig _buildConfigFromInputs(SslConfig current) {
    final days = int.tryParse(_daysController.text.trim()) ?? current.days;
    return current.copyWith(
      baseDir: _baseDirController.text.trim(),
      days: days,
      domain: _domainController.text.trim(),
      certName: _certNameController.text.trim(),
      rootCaName: _rootCaNameController.text.trim(),
      ip: _ipController.text.trim(),
      ocspServerUrl: _ocspServerUrlController.text.trim(),
      crlUrl: _crlUrlController.text.trim(),
      userConfigPath: _userConfigPathController.text.trim(),
      opensslConfigPath: _opensslConfigPathController.text.trim(),
      caKeyPassword: _caKeyPasswordController.text.trim(),
      pfxPassword: _pfxPasswordController.text.trim(),
    );
  }

  void _syncControllers(SslConfig config) {
    _baseDirController.text = config.baseDir;
    _daysController.text = config.days.toString();
    _domainController.text = config.domain;
    _certNameController.text = config.certName;
    _rootCaNameController.text = config.rootCaName;
    _ipController.text = config.ip;
    _ocspServerUrlController.text = config.ocspServerUrl;
    _crlUrlController.text = config.crlUrl;
    _userConfigPathController.text = config.userConfigPath;
    _opensslConfigPathController.text = config.opensslConfigPath;
    _caKeyPasswordController.text = config.caKeyPassword;
    _pfxPasswordController.text = config.pfxPassword;
  }

  Future<void> _loadTemplateContent(
    SslCertificateManagerProvider provider,
  ) async {
    final content = await provider.loadOpenSslTemplateContent();
    _templateController.text = content;
    _syncQuickFormFromTemplate(content);
  }

  void _syncQuickFormFromTemplate(String content) {
    _owoDomainController.text = _getTemplateConfigValue(content, 'owo_domain');
    _owoCommonNameController.text = _getTemplateConfigValue(
      content,
      'owo_commonName',
    );
    _owoCountryNameController.text = _getTemplateConfigValue(
      content,
      'owo_countryName',
    );
    _owoStateNameController.text = _getTemplateConfigValue(
      content,
      'owo_stateName',
    );
    _owoLocalityNameController.text = _getTemplateConfigValue(
      content,
      'owo_localityName',
    );
    _owoOrganizationNameController.text = _getTemplateConfigValue(
      content,
      'owo_organizationName',
    );
    _owoOrganizationUnitController.text = _getTemplateConfigValue(
      content,
      'owo_organizationalUnitName',
    );
    _owoEmailController.text = _getTemplateConfigValue(
      content,
      'owo_emailAddress',
    );
    _owoExplicitTextController.text = _getTemplateConfigValue(
      content,
      'owo_explicitText',
    );
    _owoChallengePasswordController.text = _getTemplateConfigValue(
      content,
      'owo_challengePassword',
    );
    _owoUnstructuredNameController.text = _getTemplateConfigValue(
      content,
      'owo_unstructuredName',
    );
    _owoOcspDomainController.text = _getTemplateConfigValue(
      content,
      'owo_OCSP_Domain',
    );
    _owoRootCaFileNameController.text = _getTemplateConfigValue(
      content,
      'owo_rootCAFileName',
    );
    _dns1Controller.text = _getTemplateConfigValue(content, 'DNS.1');
    _dns2Controller.text = _getTemplateConfigValue(content, 'DNS.2');
    _ip1Controller.text = _getTemplateConfigValue(content, 'IP.1');
    _ip2Controller.text = _getTemplateConfigValue(content, 'IP.2');
    _tsaPolicy1Controller.text = _getTemplateConfigValue(
      content,
      'tsa_policy1',
    );
    _tsaPolicy2Controller.text = _getTemplateConfigValue(
      content,
      'tsa_policy2',
    );
    _tsaPolicy3Controller.text = _getTemplateConfigValue(
      content,
      'tsa_policy3',
    );
  }

  void _applyQuickFormToTemplate() {
    var content = _templateController.text;
    content = _setTemplateConfigValue(
      content,
      'owo_domain',
      _owoDomainController.text,
    );
    content = _setTemplateConfigValue(
      content,
      'owo_commonName',
      _owoCommonNameController.text,
    );
    content = _setTemplateConfigValue(
      content,
      'owo_countryName',
      _owoCountryNameController.text,
    );
    content = _setTemplateConfigValue(
      content,
      'owo_stateName',
      _owoStateNameController.text,
    );
    content = _setTemplateConfigValue(
      content,
      'owo_localityName',
      _owoLocalityNameController.text,
    );
    content = _setTemplateConfigValue(
      content,
      'owo_organizationName',
      _owoOrganizationNameController.text,
    );
    content = _setTemplateConfigValue(
      content,
      'owo_organizationalUnitName',
      _owoOrganizationUnitController.text,
    );
    content = _setTemplateConfigValue(
      content,
      'owo_emailAddress',
      _owoEmailController.text,
    );
    content = _setTemplateConfigValue(
      content,
      'owo_explicitText',
      _owoExplicitTextController.text,
    );
    content = _setTemplateConfigValue(
      content,
      'owo_challengePassword',
      _owoChallengePasswordController.text,
    );
    content = _setTemplateConfigValue(
      content,
      'owo_unstructuredName',
      _owoUnstructuredNameController.text,
    );
    content = _setTemplateConfigValue(
      content,
      'owo_OCSP_Domain',
      _owoOcspDomainController.text,
    );
    content = _setTemplateConfigValue(
      content,
      'owo_rootCAFileName',
      _owoRootCaFileNameController.text,
    );
    content = _setTemplateConfigValue(content, 'DNS.1', _dns1Controller.text);
    content = _setTemplateConfigValue(content, 'DNS.2', _dns2Controller.text);
    content = _setTemplateConfigValue(content, 'IP.1', _ip1Controller.text);
    content = _setTemplateConfigValue(content, 'IP.2', _ip2Controller.text);
    content = _setTemplateConfigValue(
      content,
      'tsa_policy1',
      _tsaPolicy1Controller.text,
    );
    content = _setTemplateConfigValue(
      content,
      'tsa_policy2',
      _tsaPolicy2Controller.text,
    );
    content = _setTemplateConfigValue(
      content,
      'tsa_policy3',
      _tsaPolicy3Controller.text,
    );
    _templateController.text = content;
  }

  String _getTemplateConfigValue(String content, String key) {
    final escapedKey = RegExp.escape(key);
    final pattern = RegExp('^\\s*$escapedKey\\s*=\\s*(.*)\$', multiLine: true);
    final match = pattern.firstMatch(content);
    if (match == null) {
      return '';
    }
    return match.group(1)?.trim() ?? '';
  }

  String _setTemplateConfigValue(String content, String key, String value) {
    final escapedKey = RegExp.escape(key);
    final pattern = RegExp('^(\\s*$escapedKey\\s*=\\s*).*\$', multiLine: true);
    if (pattern.hasMatch(content)) {
      return content.replaceFirst(pattern, '\$1$value');
    }
    return content;
  }
}
