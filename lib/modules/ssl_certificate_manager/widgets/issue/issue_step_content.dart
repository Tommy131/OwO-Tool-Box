import 'package:flutter/material.dart';

import '../../../../core/services/localization_service.dart';
import '../../localization/localization_keys.dart';
import '../../providers/ssl_certificate_manager_provider.dart';
import '../form/alt_names_panel.dart';
import '../form/ssl_text_field.dart';
import '../shared/field_row.dart';
import '../shared/section_container.dart';
import 'issue_summary.dart';
import 'usage_type_panel.dart';

/// Renders the form content for a given issue step.
class IssueStepContent extends StatelessWidget {
  const IssueStepContent({
    super.key,
    required this.issueStep,
    required this.provider,
    required this.onShowInlineMessage,
    required this.obscureRootCaPassword,
    required this.obscureChallengePassword,
    this.onToggleRootCaPassword,
    this.onToggleChallengePassword,
  });

  final int issueStep;
  final SslCertificateManagerProvider provider;
  final void Function(String message) onShowInlineMessage;
  final bool obscureRootCaPassword;
  final bool obscureChallengePassword;
  final VoidCallback? onToggleRootCaPassword;
  final VoidCallback? onToggleChallengePassword;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (issueStep == 0) _buildStep0(context),
        if (issueStep == 1) _buildStep1(context),
        if (issueStep == 2) UsageTypePanel(provider: provider),
        if (issueStep == 3) _buildStep3(context),
        if (issueStep == 4) _buildStep4(context, theme),
      ],
    );
  }

  // Step 0: Basic Identity
  Widget _buildStep0(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SslSectionContainer(
          title: LocalizationKeys.sectionIdentity.tr(context),
          child: Column(
            children: [
              SslFieldRow(
                fields: [
                  _buildIssueField(
                    provider.domainController,
                    LocalizationKeys.domain.tr(context),
                    requiredField: true,
                  ),
                  _buildIssueField(
                    provider.commonNameController,
                    LocalizationKeys.commonName.tr(context),
                    requiredField: true,
                  ),
                ],
              ),
            ],
          ),
        ),
        SslSectionContainer(
          title: LocalizationKeys.sectionSecurity.tr(context),
          child: SslFieldRow(
            fields: [
              _buildIssueField(
                provider.validDaysController,
                LocalizationKeys.validDays.tr(context),
                requiredField: true,
              ),
              _buildIssueField(
                provider.challengePasswordController,
                LocalizationKeys.challengePassword.tr(context),
              ),
            ],
          ),
        ),
        SslAltNamesPanel(provider: provider),
      ],
    );
  }

  // Step 1: Subject Info
  Widget _buildStep1(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SslSectionContainer(
          title: LocalizationKeys.summaryLocation.tr(context),
          child: SslFieldRow(
            fields: [
              _buildIssueField(
                provider.countryNameController,
                LocalizationKeys.countryName.tr(context),
                requiredField: true,
              ),
              _buildIssueField(
                provider.stateNameController,
                LocalizationKeys.stateName.tr(context),
              ),
              _buildIssueField(
                provider.localityNameController,
                LocalizationKeys.localityName.tr(context),
              ),
            ],
          ),
        ),
        SslSectionContainer(
          title: LocalizationKeys.sectionOrganization.tr(context),
          child: SslFieldRow(
            fields: [
              _buildIssueField(
                provider.organizationNameController,
                LocalizationKeys.organizationName.tr(context),
                requiredField: true,
              ),
              _buildIssueField(
                provider.organizationalUnitNameController,
                LocalizationKeys.orgUnitName.tr(context),
              ),
            ],
          ),
        ),
        SslSectionContainer(
          title: LocalizationKeys.summaryEmail.tr(context),
          child: Column(
            children: [
              SslFieldRow(
                fields: [
                  _buildIssueField(
                    provider.emailAddressController,
                    LocalizationKeys.emailAddress.tr(context),
                  ),
                  _buildIssueField(
                    provider.ocspDomainController,
                    LocalizationKeys.ocspDomain.tr(context),
                  ),
                ],
              ),
              SslFieldRow(
                fields: [
                  _buildIssueField(
                    provider.explicitTextController,
                    LocalizationKeys.explicitText.tr(context),
                  ),
                  _buildIssueField(
                    provider.unstructuredNameController,
                    LocalizationKeys.unstructuredName.tr(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Step 3: Endpoint Addresses
  Widget _buildStep3(BuildContext context) {
    return SslSectionContainer(
      title: LocalizationKeys.sectionEndpoints.tr(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIssueField(
            provider.crlDistributionUrlController,
            LocalizationKeys.crlDistributionUrl.tr(context),
            requiredField: true,
          ),
          _buildIssueField(
            provider.ocspCaIssuersUrlController,
            LocalizationKeys.ocspCaIssuersUrl.tr(context),
            requiredField: true,
          ),
          _buildIssueField(
            provider.ocspResponderUrlController,
            LocalizationKeys.ocspResponderUrl.tr(context),
            requiredField: true,
          ),
        ],
      ),
    );
  }

  // Step 4: Final Confirm
  Widget _buildStep4(BuildContext context, ThemeData theme) {
    final configPreview = provider.buildDraftCnfPreview();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IssueSummarySection(provider: provider),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocalizationKeys.draftOpenSslConfig.tr(context),
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 220,
                  child: SingleChildScrollView(
                    child: SelectableText(
                      configPreview,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          LocalizationKeys.confirmBeforeIssue.tr(context),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        if (provider.isLoading)
          Text(
            LocalizationKeys.issuingWait.tr(context),
            style: theme.textTheme.bodySmall,
          ),
      ],
    );
  }

  Widget _buildIssueField(
    TextEditingController controller,
    String label, {
    bool requiredField = false,
  }) {
    return SslTextField(
      controller: controller,
      label: label,
      pinFieldKey: provider.issueFieldKeyForController(controller),
      requiredField: requiredField,
      obscureRootCaPassword: obscureRootCaPassword,
      obscureChallengePassword: obscureChallengePassword,
      onToggleRootCaPassword: onToggleRootCaPassword,
      onToggleChallengePassword: onToggleChallengePassword,
    );
  }
}
