import 'package:flutter/material.dart';

import '../../../../core/services/localization_service.dart';
import '../../localization/localization_keys.dart';
import '../../providers/ssl_certificate_manager_provider.dart';

class SslTemplateTab extends StatelessWidget {
  final SslCertificateManagerProvider provider;
  final bool isTemplateExpanded;
  final VoidCallback onToggleTemplateExpanded;
  final TextEditingController templateController;
  final Widget Function(
    String label,
    TextEditingController controller, {
    bool obscureText,
    String? helperText,
  })
  fieldBuilder;
  final VoidCallback onApplyToTemplate;
  final Future<void> Function() onSaveTemplate;
  final Future<void> Function() onReloadTemplate;
  final TextEditingController owoDomainController;
  final TextEditingController owoCommonNameController;
  final TextEditingController owoCountryNameController;
  final TextEditingController owoStateNameController;
  final TextEditingController owoLocalityNameController;
  final TextEditingController owoOrganizationNameController;
  final TextEditingController owoOrganizationUnitController;
  final TextEditingController owoEmailController;
  final TextEditingController owoExplicitTextController;
  final TextEditingController owoChallengePasswordController;
  final TextEditingController owoUnstructuredNameController;
  final TextEditingController owoOcspDomainController;
  final TextEditingController owoRootCaFileNameController;
  final TextEditingController dns1Controller;
  final TextEditingController dns2Controller;
  final TextEditingController ip1Controller;
  final TextEditingController ip2Controller;
  final TextEditingController tsaPolicy1Controller;
  final TextEditingController tsaPolicy2Controller;
  final TextEditingController tsaPolicy3Controller;

  const SslTemplateTab({
    super.key,
    required this.provider,
    required this.isTemplateExpanded,
    required this.onToggleTemplateExpanded,
    required this.templateController,
    required this.fieldBuilder,
    required this.onApplyToTemplate,
    required this.onSaveTemplate,
    required this.onReloadTemplate,
    required this.owoDomainController,
    required this.owoCommonNameController,
    required this.owoCountryNameController,
    required this.owoStateNameController,
    required this.owoLocalityNameController,
    required this.owoOrganizationNameController,
    required this.owoOrganizationUnitController,
    required this.owoEmailController,
    required this.owoExplicitTextController,
    required this.owoChallengePasswordController,
    required this.owoUnstructuredNameController,
    required this.owoOcspDomainController,
    required this.owoRootCaFileNameController,
    required this.dns1Controller,
    required this.dns2Controller,
    required this.ip1Controller,
    required this.ip2Controller,
    required this.tsaPolicy1Controller,
    required this.tsaPolicy2Controller,
    required this.tsaPolicy3Controller,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTemplateQuickFormSection(context),
          const SizedBox(height: 12),
          _buildTemplateEditorCard(context),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: provider.isRunning ? null : onApplyToTemplate,
                icon: const Icon(Icons.tune_rounded),
                label: Text(LocalizationKeys.applyToTemplate.tr(context)),
              ),
              FilledButton.icon(
                onPressed: provider.isRunning ? null : onSaveTemplate,
                icon: const Icon(Icons.save_rounded),
                label: Text(LocalizationKeys.saveTemplate.tr(context)),
              ),
              OutlinedButton.icon(
                onPressed: provider.isRunning ? null : onReloadTemplate,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(LocalizationKeys.reloadTemplate.tr(context)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateEditorCard(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            title: Text(LocalizationKeys.templateSection.tr(context)),
            trailing: Icon(
              isTemplateExpanded
                  ? Icons.expand_less_rounded
                  : Icons.expand_more_rounded,
            ),
            onTap: onToggleTemplateExpanded,
          ),
          if (isTemplateExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 460),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: TextField(
                  controller: templateController,
                  maxLines: null,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTemplateQuickFormSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${LocalizationKeys.templateQuickFormSection.tr(context)} - 证书主体',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _buildTemplateFieldRow([
                  fieldBuilder(
                    'owo_domain',
                    owoDomainController,
                    helperText: '证书默认域名，用于DNS拼接',
                  ),
                  fieldBuilder(
                    'owo_commonName',
                    owoCommonNameController,
                    helperText: '证书CN名称',
                  ),
                ]),
                _buildTemplateFieldRow([
                  fieldBuilder(
                    'owo_countryName',
                    owoCountryNameController,
                    helperText: '国家代码，例如 CN/DE',
                  ),
                  fieldBuilder(
                    'owo_stateName',
                    owoStateNameController,
                    helperText: '省/州名称',
                  ),
                ]),
                _buildTemplateFieldRow([
                  fieldBuilder(
                    'owo_localityName',
                    owoLocalityNameController,
                    helperText: '城市名称',
                  ),
                  fieldBuilder(
                    'owo_organizationName',
                    owoOrganizationNameController,
                    helperText: '组织名称(O)',
                  ),
                ]),
                _buildTemplateFieldRow([
                  fieldBuilder(
                    'owo_organizationalUnitName',
                    owoOrganizationUnitController,
                    helperText: '组织单位(OU)',
                  ),
                  fieldBuilder(
                    'owo_emailAddress',
                    owoEmailController,
                    helperText: '证书联系人邮箱',
                  ),
                ]),
                _buildTemplateFieldRow([
                  fieldBuilder(
                    'owo_explicitText',
                    owoExplicitTextController,
                    helperText: '策略说明文本',
                  ),
                  fieldBuilder(
                    'owo_challengePassword',
                    owoChallengePasswordController,
                    obscureText: true,
                    helperText: 'CSR挑战口令',
                  ),
                ]),
                _buildTemplateFieldRow([
                  fieldBuilder(
                    'owo_unstructuredName',
                    owoUnstructuredNameController,
                    helperText: '附加组织别名',
                  ),
                  fieldBuilder(
                    'owo_OCSP_Domain',
                    owoOcspDomainController,
                    helperText: 'OCSP/CRL服务域名',
                  ),
                ]),
                _buildTemplateFieldRow([
                  fieldBuilder(
                    'owo_rootCAFileName',
                    owoRootCaFileNameController,
                    helperText: '根CA文件名前缀',
                  ),
                  const SizedBox.shrink(),
                ]),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${LocalizationKeys.templateQuickFormSection.tr(context)} - SAN与TSA策略',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _buildTemplateFieldRow([
                  fieldBuilder(
                    'DNS.1',
                    dns1Controller,
                    helperText: '证书备用域名1(SAN)',
                  ),
                  fieldBuilder(
                    'DNS.2',
                    dns2Controller,
                    helperText: '证书备用域名2(SAN)',
                  ),
                ]),
                _buildTemplateFieldRow([
                  fieldBuilder(
                    'IP.1',
                    ip1Controller,
                    helperText: '证书绑定IP 1(SAN)',
                  ),
                  fieldBuilder(
                    'IP.2',
                    ip2Controller,
                    helperText: '证书绑定IP 2(SAN)',
                  ),
                ]),
                _buildTemplateFieldRow([
                  fieldBuilder(
                    'tsa_policy1',
                    tsaPolicy1Controller,
                    helperText: '时间戳策略OID 1',
                  ),
                  fieldBuilder(
                    'tsa_policy2',
                    tsaPolicy2Controller,
                    helperText: '时间戳策略OID 2',
                  ),
                ]),
                _buildTemplateFieldRow([
                  fieldBuilder(
                    'tsa_policy3',
                    tsaPolicy3Controller,
                    helperText: '时间戳策略OID 3',
                  ),
                  const SizedBox.shrink(),
                ]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateFieldRow(List<Widget> children) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: children[0]),
        const SizedBox(width: 8),
        Expanded(child: children[1]),
      ],
    );
  }
}
