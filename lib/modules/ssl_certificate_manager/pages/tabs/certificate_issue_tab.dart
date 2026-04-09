import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/localization_service.dart';
import '../../../../core/widgets/common/dialog.dart';
import '../../localization/localization_keys.dart';
import '../../models/ssl_models.dart';
import '../../providers/ssl_certificate_manager_provider.dart';
import '../../widgets/form/ssl_validators.dart';
import '../../widgets/issue/issue_step_content.dart';
import '../../widgets/shared/step_progress_indicator.dart';

/// Helper class for tracking issue step completion.
class _IssueStepProgressStats {
  const _IssueStepProgressStats({required this.completed, required this.total});

  final int completed;
  final int total;

  bool get isCompleted => completed >= total;

  double get ratio {
    if (total <= 0) return 0;
    return (completed / total).clamp(0.0, 1.0).toDouble();
  }
}

/// The certificate issue wizard tab with step navigation.
class CertificateIssueTab extends StatefulWidget {
  const CertificateIssueTab({super.key});

  @override
  State<CertificateIssueTab> createState() => _CertificateIssueTabState();
}

class _CertificateIssueTabState extends State<CertificateIssueTab> {
  int _issueStep = 0;
  bool _showRootCaPassword = false;
  bool _showChallengePassword = false;

  void _changeIssueStep(int delta) {
    setState(() {
      _issueStep += delta;
    });
  }

  void _resetIssueStep() {
    setState(() {
      _issueStep = 0;
    });
  }

  void _toggleRootCaPasswordVisibility() {
    setState(() {
      _showRootCaPassword = !_showRootCaPassword;
    });
  }

  void _toggleChallengePasswordVisibility() {
    setState(() {
      _showChallengePassword = !_showChallengePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<SslCertificateManagerProvider>();
    final currentTitle = _issueStepTitles()[_issueStep];
    final currentSubtitle = _issueStepSubtitles()[_issueStep];

    const stepIcons = [
      Icons.badge_outlined,
      Icons.business_outlined,
      Icons.vpn_key_outlined,
      Icons.link_outlined,
      Icons.check_circle_outline,
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SslStepProgressIndicator(
            currentStep: _issueStep,
            totalSteps: stepIcons.length,
            titles: _issueStepTitles(),
            icons: stepIcons,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Step title + subtitle + progress badge
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            stepIcons[_issueStep],
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentTitle,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                currentSubtitle,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ListenableBuilder(
                          listenable: _issueProgressListenable(provider),
                          builder: (context, _) {
                            final ratio = _stepCompletionRatio(
                              provider,
                              _issueStep,
                            );
                            final percent = (ratio * 100).round();
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: ratio >= 1.0
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : theme.colorScheme.primary.withValues(
                                        alpha: 0.08,
                                      ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$percent%',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: ratio >= 1.0
                                      ? Colors.green
                                      : theme.colorScheme.primary,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Divider(
                      height: 1,
                      color: theme.dividerColor.withValues(alpha: 0.12),
                    ),
                    const SizedBox(height: 14),
                    // Form content
                    Expanded(
                      child: SingleChildScrollView(
                        child: IssueStepContent(
                          issueStep: _issueStep,
                          provider: provider,
                          onShowInlineMessage: _showInlineMessage,
                          obscureRootCaPassword: !_showRootCaPassword,
                          obscureChallengePassword: !_showChallengePassword,
                          onToggleRootCaPassword:
                              _toggleRootCaPasswordVisibility,
                          onToggleChallengePassword:
                              _toggleChallengePasswordVisibility,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Navigation buttons
                    Row(
                      children: [
                        if (_issueStep > 0)
                          OutlinedButton.icon(
                            onPressed: provider.isLoading
                                ? null
                                : () {
                                    if (_issueStep == 0) return;
                                    _changeIssueStep(-1);
                                  },
                            icon: const Icon(Icons.arrow_back, size: 18),
                            label: Text(
                              LocalizationKeys.previousStep.tr(context),
                            ),
                          ),
                        const Spacer(),
                        FilledButton.icon(
                          onPressed: provider.isLoading
                              ? null
                              : () async {
                                  if (!_validateBeforeNext(
                                    provider,
                                    _issueStep,
                                  )) {
                                    return;
                                  }
                                  if (_issueStep == 4) {
                                    await _handleIssueWithSystemDialogs(provider);
                                    return;
                                  }
                                  _changeIssueStep(1);
                                },
                          icon: Icon(
                            _issueStep == 4
                                ? Icons.verified_outlined
                                : Icons.arrow_forward,
                          ),
                          label: Text(
                            _issueStep == 4
                                ? LocalizationKeys.confirmIssue.tr(context)
                                : LocalizationKeys.nextStep.tr(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Step Titles & Subtitles
  // ---------------------------------------------------------------------------

  List<String> _issueStepTitles() {
    return [
      LocalizationKeys.stepBasicIdentity.tr(context),
      LocalizationKeys.stepSubjectInfo.tr(context),
      LocalizationKeys.stepUsageType.tr(context),
      LocalizationKeys.stepEndpoint.tr(context),
      LocalizationKeys.stepFinalConfirm.tr(context),
    ];
  }

  List<String> _issueStepSubtitles() {
    return [
      LocalizationKeys.stepBasicIdentitySubtitle.tr(context),
      LocalizationKeys.stepSubjectInfoSubtitle.tr(context),
      LocalizationKeys.stepUsageTypeSubtitle.tr(context),
      LocalizationKeys.stepEndpointSubtitle.tr(context),
      LocalizationKeys.stepFinalConfirmSubtitle.tr(context),
    ];
  }

  // ---------------------------------------------------------------------------
  // Step Progress
  // ---------------------------------------------------------------------------

  double _stepCompletionRatio(
    SslCertificateManagerProvider provider,
    int step,
  ) {
    return _stepProgressStats(provider, step).ratio;
  }

  _IssueStepProgressStats _stepProgressStats(
    SslCertificateManagerProvider provider,
    int step,
  ) {
    if (step == 0) {
      final hasAltName = provider.altNames.any(
        (e) =>
            e.value.trim().isNotEmpty &&
            SslValidators.validationErrorForAltName(
                  type: e.type,
                  value: e.value,
                  context: context,
                ) ==
                null,
      );
      return _IssueStepProgressStats(
        completed: [
          _isCompletedIssueField(provider, provider.domainController),
          _isCompletedIssueField(provider, provider.commonNameController),
          hasAltName,
          provider.challengePasswordController.text.trim().isNotEmpty,
          _isCompletedIssueField(provider, provider.validDaysController),
        ].where((v) => v).length,
        total: 5,
      );
    }
    if (step == 1) {
      final fields = [
        provider.countryNameController,
        provider.stateNameController,
        provider.localityNameController,
        provider.organizationNameController,
        provider.organizationalUnitNameController,
        provider.emailAddressController,
        provider.explicitTextController,
        provider.unstructuredNameController,
        provider.ocspDomainController,
      ];
      return _IssueStepProgressStats(
        completed: fields
            .where((c) => _isCompletedIssueField(provider, c))
            .length,
        total: fields.length,
      );
    }
    if (step == 2) {
      return _IssueStepProgressStats(
        completed: [
          provider.selectedKeyUsageTypes.isNotEmpty,
          provider.selectedExtendedKeyUsageTypes.isNotEmpty,
        ].where((v) => v).length,
        total: 2,
      );
    }
    if (step == 3) {
      return _IssueStepProgressStats(
        completed: [
          _isCompletedIssueField(
            provider,
            provider.crlDistributionUrlController,
          ),
          _isCompletedIssueField(provider, provider.ocspCaIssuersUrlController),
          _isCompletedIssueField(provider, provider.ocspResponderUrlController),
        ].where((v) => v).length,
        total: 3,
      );
    }
    if (step == 4) {
      final completed = List<int>.generate(
        4,
        (i) => i,
      ).where((i) => _stepProgressStats(provider, i).isCompleted).length;
      return _IssueStepProgressStats(completed: completed, total: 4);
    }
    return const _IssueStepProgressStats(completed: 0, total: 1);
  }

  Listenable _issueProgressListenable(SslCertificateManagerProvider provider) {
    return Listenable.merge([
      provider,
      provider.domainController,
      provider.commonNameController,
      provider.countryNameController,
      provider.stateNameController,
      provider.localityNameController,
      provider.organizationNameController,
      provider.organizationalUnitNameController,
      provider.emailAddressController,
      provider.explicitTextController,
      provider.challengePasswordController,
      provider.unstructuredNameController,
      provider.ocspDomainController,
      provider.validDaysController,
      provider.ocspCaIssuersUrlController,
      provider.ocspResponderUrlController,
      provider.crlDistributionUrlController,
    ]);
  }

  // ---------------------------------------------------------------------------
  // Validation
  // ---------------------------------------------------------------------------

  bool _isCompletedIssueField(
    SslCertificateManagerProvider provider,
    TextEditingController controller,
  ) {
    return controller.text.trim().isNotEmpty &&
        SslValidators.validationErrorForController(
              controller: controller,
              provider: provider,
              context: context,
            ) ==
            null;
  }

  String? _firstIssueFormatError(
    SslCertificateManagerProvider provider,
    int step,
  ) {
    if (step == 0) {
      for (final controller in [
        provider.domainController,
        provider.commonNameController,
        provider.validDaysController,
      ]) {
        final error = SslValidators.validationErrorForController(
          controller: controller,
          provider: provider,
          context: context,
        );
        if (error != null) return error;
      }
      for (final altName in provider.altNames) {
        final error = SslValidators.validationErrorForAltName(
          type: altName.type,
          value: altName.value,
          context: context,
        );
        if (error != null) return error;
      }
    }
    if (step == 1) {
      for (final controller in [
        provider.countryNameController,
        provider.emailAddressController,
        provider.ocspDomainController,
      ]) {
        final error = SslValidators.validationErrorForController(
          controller: controller,
          provider: provider,
          context: context,
        );
        if (error != null) return error;
      }
    }
    if (step == 3) {
      for (final controller in [
        provider.crlDistributionUrlController,
        provider.ocspCaIssuersUrlController,
        provider.ocspResponderUrlController,
      ]) {
        final error = SslValidators.validationErrorForController(
          controller: controller,
          provider: provider,
          context: context,
        );
        if (error != null) return error;
      }
    }
    return null;
  }

  bool _validateBeforeNext(SslCertificateManagerProvider provider, int step) {
    final requiredFieldsError = _missingRequiredFieldsMessage(provider, step);
    if (requiredFieldsError != null) {
      _showInlineMessage(requiredFieldsError);
      return false;
    }
    final formatError = _firstIssueFormatError(provider, step);
    if (formatError != null) {
      _showInlineMessage(formatError);
      return false;
    }
    if (step == 2 &&
        provider.selectedKeyUsageTypes.isEmpty &&
        provider.selectedExtendedKeyUsageTypes.isEmpty) {
      _showInlineMessage(LocalizationKeys.validationSelectUsage.tr(context));
      return false;
    }
    return true;
  }

  String? _missingRequiredFieldsMessage(
    SslCertificateManagerProvider provider,
    int step,
  ) {
    final missingFields = _requiredControllersForStep(provider, step)
        .where((c) => c.text.trim().isEmpty)
        .map(_labelForController)
        .toList(growable: false);
    if (missingFields.isEmpty) return null;
    return LocalizationKeys.validationRequiredFields
        .tr(context)
        .replaceFirst('@fields', missingFields.join('\u3001'));
  }

  List<TextEditingController> _requiredControllersForStep(
    SslCertificateManagerProvider provider,
    int step,
  ) {
    switch (step) {
      case 0:
        return [
          provider.domainController,
          provider.commonNameController,
          provider.validDaysController,
        ];
      case 1:
        return [
          provider.countryNameController,
          provider.organizationNameController,
        ];
      case 3:
        return [
          provider.crlDistributionUrlController,
          provider.ocspCaIssuersUrlController,
          provider.ocspResponderUrlController,
        ];
      default:
        return const [];
    }
  }

  String _labelForController(TextEditingController controller) {
    final provider = context.read<SslCertificateManagerProvider>();
    if (identical(controller, provider.domainController)) {
      return LocalizationKeys.domain.tr(context);
    }
    if (identical(controller, provider.commonNameController)) {
      return LocalizationKeys.commonName.tr(context);
    }
    if (identical(controller, provider.validDaysController)) {
      return LocalizationKeys.validDays.tr(context);
    }
    if (identical(controller, provider.countryNameController)) {
      return LocalizationKeys.countryName.tr(context);
    }
    if (identical(controller, provider.organizationNameController)) {
      return LocalizationKeys.organizationName.tr(context);
    }
    if (identical(controller, provider.crlDistributionUrlController)) {
      return LocalizationKeys.crlDistributionUrl.tr(context);
    }
    if (identical(controller, provider.ocspCaIssuersUrlController)) {
      return LocalizationKeys.ocspCaIssuersUrl.tr(context);
    }
    if (identical(controller, provider.ocspResponderUrlController)) {
      return LocalizationKeys.ocspResponderUrl.tr(context);
    }
    return '';
  }

  // ---------------------------------------------------------------------------
  // Inline Message & Issue Dialogs
  // ---------------------------------------------------------------------------

  void _showInlineMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleIssueWithSystemDialogs(
    SslCertificateManagerProvider provider,
  ) async {
    final confirmed = await showAdvancedConfirmDialog(
      context: context,
      title: LocalizationKeys.dialogIssueConfirmTitle.tr(context),
      content: LocalizationKeys.dialogIssueConfirmContent.tr(context),
      icon: Icons.verified_outlined,
      confirmText: LocalizationKeys.dialogIssueNow.tr(context),
      cancelText: LocalizationKeys.cancel.tr(context),
    );
    if (!mounted || confirmed != true) return;

    final result = await provider.issueCertificate();
    if (!mounted) return;

    if (result.success && result.record != null) {
      final record = result.record!;
      await provider.resetUnpinnedIssueFields();
      if (!mounted) return;
      await _showIssueSuccessDialog(record);
      if (!mounted) return;
      _resetIssueStep();
      return;
    }

    await showAdvancedConfirmDialog(
      context: context,
      title: LocalizationKeys.dialogIssueFailedTitle.tr(context),
      content: result.message,
      icon: Icons.error_outline,
      confirmColor: Colors.redAccent,
      confirmText: LocalizationKeys.dialogAcknowledge.tr(context),
      cancelText: '',
    );
  }

  Future<void> _showIssueSuccessDialog(SslCertificateRecord record) {
    final expiresText = record.expiresAt.toLocal().toString().split('.').first;
    final rows = <({String label, String value})>[
      (
        label: '${LocalizationKeys.summaryDomain.tr(context)}：',
        value: record.domain,
      ),
      (
        label: '${LocalizationKeys.summaryCn.tr(context)}：',
        value: record.commonName,
      ),
      (
        label: '${LocalizationKeys.serialNumber.tr(context)}：',
        value: record.serialNumber,
      ),
      (
        label: '${LocalizationKeys.issuer.tr(context)}：',
        value: record.issuer,
      ),
      (
        label: '${LocalizationKeys.expiresAt.tr(context)}：',
        value: expiresText,
      ),
      (
        label: '${LocalizationKeys.summaryCertPath.tr(context)}：',
        value: record.certFilePath,
      ),
      (
        label: '${LocalizationKeys.summaryKeyPath.tr(context)}：',
        value: record.keyFilePath,
      ),
      (
        label: '${LocalizationKeys.summaryConfigPath.tr(context)}：',
        value: record.configFilePath,
      ),
    ];

    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final maxWidth = MediaQuery.sizeOf(dialogContext).width - 48;
        final dialogWidth = maxWidth.clamp(520.0, 900.0);
        const labelWidth = 92.0;

        return AlertDialog(
          icon: const Icon(Icons.check_circle_outline),
          title: Text(LocalizationKeys.dialogIssueSuccessTitle.tr(dialogContext)),
          contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          content: SizedBox(
            width: dialogWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: rows
                  .map(
                    (row) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: labelWidth,
                            child: Text(
                              row.label,
                              textAlign: TextAlign.left,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              row.value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.left,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(LocalizationKeys.confirm.tr(dialogContext)),
            ),
          ],
        );
      },
    );
  }
}
