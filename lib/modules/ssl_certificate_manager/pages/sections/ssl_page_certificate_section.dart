part of '../ssl_certificate_manager_page.dart';

/// Certificate section: certificate list, detail panel, and issue wizard.
extension _SslPageCertificateSection on _SslCertificateManagerPageState {
  // ---------------------------------------------------------------------------
  // Certificate List Tab
  // ---------------------------------------------------------------------------

  Widget _buildCertificateList(SslCertificateManagerProvider provider) {
    final data = provider.filteredCertificates;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCertificateStatsBar(provider),
          const SizedBox(height: 12),
          _buildSearchAndFilterBar(provider),
          const SizedBox(height: 12),
          Expanded(
            child: data.isEmpty
                ? _buildEmptyState()
                : Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: _buildCertificateDataList(provider),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 4,
                        child: _buildCertificateDetailPanel(provider),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Stats Bar
  // ---------------------------------------------------------------------------

  Widget _buildCertificateStatsBar(SslCertificateManagerProvider provider) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildStatChip(
          icon: Icons.folder_outlined,
          label: LocalizationKeys.statsTotalCerts.tr(context),
          value: '${provider.totalCertCount}',
          color: Colors.blue,
        ),
        _buildStatChip(
          icon: Icons.check_circle_outline,
          label: LocalizationKeys.statsIssuedCount.tr(context),
          value: '${provider.issuedCertCount}',
          color: Colors.green,
        ),
        _buildStatChip(
          icon: Icons.block,
          label: LocalizationKeys.statsRevokedCount.tr(context),
          value: '${provider.revokedCertCount}',
          color: Colors.red,
        ),
        _buildStatChip(
          icon: Icons.warning_amber,
          label: LocalizationKeys.statsExpiringSoon.tr(context),
          value: '${provider.expiringSoonCount}',
          color: Colors.amber.shade700,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Search & Filter Bar
  // ---------------------------------------------------------------------------

  Widget _buildSearchAndFilterBar(SslCertificateManagerProvider provider) {
    final theme = Theme.of(context);
    final noFilterActive =
        provider.statusFilter.isEmpty && !provider.filterExpiringSoon;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: provider.searchController,
          onChanged: (value) => provider.updateSearchQuery(value),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: LocalizationKeys.searchCertificates.tr(context),
            border: const OutlineInputBorder(),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            FilterChip(
              label: Text(LocalizationKeys.filterAll.tr(context)),
              selected: noFilterActive,
              onSelected: (_) => provider.clearFilters(),
              selectedColor:
                  theme.colorScheme.primary.withValues(alpha: 0.15),
            ),
            FilterChip(
              label: Text(LocalizationKeys.statusIssued.tr(context)),
              selected:
                  provider.statusFilter.contains(SslCertStatus.issued),
              onSelected: (_) =>
                  provider.toggleStatusFilter(SslCertStatus.issued),
              selectedColor: Colors.green.withValues(alpha: 0.15),
            ),
            FilterChip(
              label: Text(LocalizationKeys.statusRevoked.tr(context)),
              selected:
                  provider.statusFilter.contains(SslCertStatus.revoked),
              onSelected: (_) =>
                  provider.toggleStatusFilter(SslCertStatus.revoked),
              selectedColor: Colors.red.withValues(alpha: 0.15),
            ),
            FilterChip(
              label: Text(LocalizationKeys.filterExpiringSoon.tr(context)),
              selected: provider.filterExpiringSoon,
              onSelected: (v) => provider.setFilterExpiringSoon(v),
              selectedColor: Colors.amber.withValues(alpha: 0.15),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Empty State
  // ---------------------------------------------------------------------------

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.badge_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
          ),
          const SizedBox(height: 12),
          Text(
            LocalizationKeys.noData.tr(context),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Certificate Data List
  // ---------------------------------------------------------------------------

  Widget _buildCertificateDataList(SslCertificateManagerProvider provider) {
    final theme = Theme.of(context);
    final data = provider.filteredCertificates;
    return Card(
      child: ListView.separated(
        itemCount: data.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = data[index];
          final isSelected = provider.selectedCertId == item.id;

          Color statusDotColor;
          if (item.status == SslCertStatus.revoked) {
            statusDotColor = Colors.red;
          } else if (item.isExpired) {
            statusDotColor = Colors.red.shade800;
          } else if (item.isExpiringSoon) {
            statusDotColor = Colors.amber.shade700;
          } else {
            statusDotColor = Colors.green;
          }

          return InkWell(
            onTap: () => provider.selectCertificate(item.id),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withValues(alpha: 0.06)
                    : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: statusDotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.domain,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _buildStatusBadge(item),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 4),
                    child: Text(
                      'CN: ${item.commonName}  |  SN: ${item.serialNumber}  |  ${LocalizationKeys.expiresAt.tr(context)}: ${item.expiresAt.toLocal().toString().split(".").first}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.55),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Certificate Detail Panel
  // ---------------------------------------------------------------------------

  Widget _buildCertificateDetailPanel(SslCertificateManagerProvider provider) {
    final cert = provider.selectedCertificate;
    if (cert == null) {
      return Card(
        child: Center(
          child: Text(
            LocalizationKeys.selectCertificate.tr(context),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
            ),
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final revokeConfig = _resolveInputConfig(provider.revokeReasonController);

    final daysColor = cert.isExpired
        ? Colors.red
        : (cert.daysRemaining <= 30 ? Colors.amber.shade700 : Colors.green);

    return Card(
      child: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          // Gradient header with domain and status badge
          _buildDetailGradientHeader(cert, theme),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subject info section
                _buildSectionContainer(
                  title: LocalizationKeys.sectionSubjectInfo.tr(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        label: LocalizationKeys.commonName.tr(context),
                        value: cert.commonName,
                        copyable: true,
                      ),
                      _buildInfoRow(
                        label: LocalizationKeys.issuer.tr(context),
                        value: cert.issuer,
                      ),
                      _buildInfoRow(
                        label: LocalizationKeys.serialNumber.tr(context),
                        value: cert.serialNumber,
                        copyable: true,
                      ),
                    ],
                  ),
                ),

                // Validity section
                _buildSectionContainer(
                  title: LocalizationKeys.sectionValidity.tr(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        label: LocalizationKeys.issuedAt.tr(context),
                        value: cert.issuedAt
                            .toLocal()
                            .toString()
                            .split('.')
                            .first,
                      ),
                      _buildInfoRow(
                        label: LocalizationKeys.expiresAt.tr(context),
                        value: cert.expiresAt
                            .toLocal()
                            .toString()
                            .split('.')
                            .first,
                      ),
                      _buildDaysRemainingRow(cert.daysRemaining, daysColor),
                    ],
                  ),
                ),

                // Extensions section (async)
                _buildSectionContainer(
                  title: LocalizationKeys.sectionExtensions.tr(context),
                  child: FutureBuilder<CertificateDetailInfo?>(
                    future: provider.fetchCertificateDetails(
                      cert.certFilePath,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            LocalizationKeys.loadingDetails.tr(context),
                            style: theme.textTheme.bodySmall,
                          ),
                        );
                      }
                      final detail = snapshot.data;
                      if (detail == null) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(
                            label: LocalizationKeys.certDetailPublicKey
                                .tr(context),
                            value: detail.publicKeyAlgorithm,
                          ),
                          _buildInfoRow(
                            label: LocalizationKeys.certDetailSignatureAlgo
                                .tr(context),
                            value: detail.signatureAlgorithm,
                          ),
                          _buildInfoRow(
                            label: LocalizationKeys.certDetailKeyUsage
                                .tr(context),
                            value: detail.keyUsage.join(', '),
                          ),
                          _buildInfoRow(
                            label: LocalizationKeys.certDetailExtKeyUsage
                                .tr(context),
                            value: detail.extendedKeyUsage.join(', '),
                          ),
                          _buildInfoRow(
                            label:
                                LocalizationKeys.certDetailSan.tr(context),
                            value: detail.subjectAltNames.join(', '),
                          ),
                          if (detail.basicConstraints != null)
                            _buildInfoRow(
                              label: LocalizationKeys
                                  .certDetailBasicConstraints
                                  .tr(context),
                              value: detail.basicConstraints!,
                            ),
                        ],
                      );
                    },
                  ),
                ),

                // Fingerprint section
                FutureBuilder<CertificateDetailInfo?>(
                  future: provider.fetchCertificateDetails(
                    cert.certFilePath,
                  ),
                  builder: (context, snapshot) {
                    final detail = snapshot.data;
                    if (detail == null || detail.sha256Fingerprint.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return _buildSectionContainer(
                      title:
                          LocalizationKeys.sectionFingerprints.tr(context),
                      child: _buildInfoRow(
                        label: 'SHA-256',
                        value: detail.sha256Fingerprint,
                        copyable: true,
                      ),
                    );
                  },
                ),

                // File paths section
                _buildSectionContainer(
                  title: LocalizationKeys.certDetailFilePaths.tr(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        label: LocalizationKeys.summaryCertPath.tr(context),
                        value: cert.certFilePath,
                        copyable: true,
                      ),
                      _buildInfoRow(
                        label: LocalizationKeys.summaryKeyPath.tr(context),
                        value: cert.keyFilePath,
                        copyable: true,
                      ),
                      _buildInfoRow(
                        label:
                            LocalizationKeys.summaryConfigPath.tr(context),
                        value: cert.configFilePath,
                        copyable: true,
                      ),
                    ],
                  ),
                ),

                // Actions section
                _buildSectionContainer(
                  title: LocalizationKeys.sectionActions.tr(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: provider.revokeReasonController,
                        keyboardType: revokeConfig.keyboardType,
                        inputFormatters: revokeConfig.inputFormatters,
                        obscureText: revokeConfig.obscureText,
                        textCapitalization: revokeConfig.textCapitalization,
                        decoration: InputDecoration(
                          labelText:
                              LocalizationKeys.revokeReason.tr(context),
                          suffixIcon: revokeConfig.suffix,
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              provider
                                  .prepareRenewalFromCertificate(cert.id);
                              _resetIssueStep();
                            },
                            icon: const Icon(Icons.autorenew),
                            label: Text(
                              LocalizationKeys.renewCertificate.tr(context),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.green,
                              side: const BorderSide(color: Colors.green),
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () =>
                                _showPfxExportDialog(provider, cert.id),
                            icon: const Icon(Icons.download),
                            label: Text(
                              LocalizationKeys.exportPkcs12.tr(context),
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final result =
                                  await provider.verifyCertificateChain(
                                cert.id,
                              );
                              if (!context.mounted) return;
                              _showInlineMessage(
                                result.valid
                                    ? LocalizationKeys.verifySuccess
                                        .tr(context)
                                    : '${LocalizationKeys.verifyFailed.tr(context)}: ${result.message}',
                              );
                            },
                            icon: const Icon(Icons.verified_outlined),
                            label: Text(
                              LocalizationKeys.verifyCertChain.tr(context),
                            ),
                          ),
                          FilledButton.icon(
                            onPressed: cert.status == SslCertStatus.revoked
                                ? null
                                : () =>
                                    provider.revokeCertificate(cert.id),
                            icon: const Icon(Icons.block),
                            label: Text(
                              LocalizationKeys.revoke.tr(context),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () =>
                                provider.deleteCertificate(cert.id),
                            icon: const Icon(Icons.delete_outline),
                            label: Text(
                              LocalizationKeys.delete.tr(context),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailGradientHeader(
    SslCertificateRecord cert,
    ThemeData theme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.16),
            theme.colorScheme.secondary.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.badge_outlined,
            color: theme.colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              cert.domain,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _buildStatusBadge(cert),
        ],
      ),
    );
  }

  /// Displays days remaining with a colored value.
  Widget _buildDaysRemainingRow(int days, Color color) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              LocalizationKeys.daysRemaining.tr(context),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '$days',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PFX Export Dialog
  // ---------------------------------------------------------------------------

  void _showPfxExportDialog(
    SslCertificateManagerProvider provider,
    String certId,
  ) {
    final pfxPasswordController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(LocalizationKeys.exportPkcs12.tr(context)),
          content: SizedBox(
            width: 400,
            child: TextField(
              controller: pfxPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: LocalizationKeys.exportPfxPassword.tr(context),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(LocalizationKeys.cancel.tr(context)),
            ),
            FilledButton(
              onPressed: () async {
                final password = pfxPasswordController.text;
                Navigator.of(ctx).pop();
                final path = await provider.exportCertificatePkcs12(
                  certId,
                  password,
                );
                if (!context.mounted) return;
                if (path != null) {
                  _showInlineMessage(
                    '${LocalizationKeys.exportSuccess.tr(context)}: $path',
                  );
                }
              },
              child: Text(LocalizationKeys.exportCertificate.tr(context)),
            ),
          ],
        );
      },
    ).then((_) => pfxPasswordController.dispose());
  }

  // ---------------------------------------------------------------------------
  // Issue Tab
  // ---------------------------------------------------------------------------

  Widget _buildIssueTab(SslCertificateManagerProvider provider) {
    final theme = Theme.of(context);
    final summaryRows = _buildIssueSummaryRows(provider);
    final configPreview = provider.buildDraftCnfPreview();
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.16),
                  theme.colorScheme.secondary.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.22),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.auto_fix_high,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    LocalizationKeys.issueGuideBanner.tr(context),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildStepProgressIndicator(
            currentStep: _issueStep,
            totalSteps: stepIcons.length,
            titles: _issueStepTitles(),
            icons: stepIcons,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _buildIssueCurrentStepHeader(
                      theme,
                      currentTitle,
                      currentSubtitle,
                    ),
                    const SizedBox(height: 10),
                    ListenableBuilder(
                      listenable: _issueProgressListenable(provider),
                      builder: (context, _) {
                        return _buildIssueGlobalProgressBar(provider);
                      },
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        child: _buildIssueStepContent(
                          provider,
                          theme,
                          summaryRows,
                          configPreview,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
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
                            icon: const Icon(Icons.arrow_back),
                            label: Text(
                              LocalizationKeys.previousStep.tr(context),
                            ),
                          ),
                        if (_issueStep > 0) const SizedBox(width: 8),
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
                                    await _handleIssueWithDialogs(provider);
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
  // Issue Step Titles & Subtitles
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
  // Issue Step Header
  // ---------------------------------------------------------------------------

  Widget _buildIssueCurrentStepHeader(
    ThemeData theme,
    String title,
    String subtitle,
  ) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Issue Step Progress
  // ---------------------------------------------------------------------------

  double _stepCompletionRatio(
    SslCertificateManagerProvider provider,
    int step,
  ) {
    return _stepProgressStats(provider, step).ratio;
  }

  Widget _buildIssueGlobalProgressBar(SslCertificateManagerProvider provider) {
    final theme = Theme.of(context);
    final value = _stepCompletionRatio(provider, _issueStep);
    final percent = (value * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${_issueStep + 1}/${_issueStepTitles().length} ${_issueStepTitles()[_issueStep]}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '$percent%',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 10,
            backgroundColor: theme.dividerColor.withValues(alpha: 0.18),
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  _IssueStepProgressStats _stepProgressStats(
    SslCertificateManagerProvider provider,
    int step,
  ) {
    if (step == 0) {
      final hasAltName = provider.altNames.any(
        (e) =>
            e.value.trim().isNotEmpty &&
            _validationErrorForAltName(e.type, e.value) == null,
      );
      return _IssueStepProgressStats(
        completed: [
          _isCompletedIssueField(provider.domainController),
          _isCompletedIssueField(provider.commonNameController),
          hasAltName,
          provider.challengePasswordController.text.trim().isNotEmpty,
          _isCompletedIssueField(provider.validDaysController),
        ].where((value) => value).length,
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
        completed: fields.where(_isCompletedIssueField).length,
        total: fields.length,
      );
    }
    if (step == 2) {
      return _IssueStepProgressStats(
        completed: [
          provider.selectedKeyUsageTypes.isNotEmpty,
          provider.selectedExtendedKeyUsageTypes.isNotEmpty,
        ].where((value) => value).length,
        total: 2,
      );
    }
    if (step == 3) {
      return _IssueStepProgressStats(
        completed: [
          _isCompletedIssueField(provider.crlDistributionUrlController),
          _isCompletedIssueField(provider.ocspCaIssuersUrlController),
          _isCompletedIssueField(provider.ocspResponderUrlController),
        ].where((value) => value).length,
        total: 3,
      );
    }
    if (step == 4) {
      final completed = List<int>.generate(4, (index) => index)
          .where((index) => _stepProgressStats(provider, index).isCompleted)
          .length;
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
  // Issue Step Content
  // ---------------------------------------------------------------------------

  Widget _buildIssueStepContent(
    SslCertificateManagerProvider provider,
    ThemeData theme,
    List<String> summaryRows,
    String configPreview,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_issueStep == 0)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _sizedField(
                    provider.domainController,
                    LocalizationKeys.domain.tr(context),
                    280,
                    pinFieldKey: provider.issueFieldKeyForController(
                      provider.domainController,
                    ),
                    requiredField: true,
                  ),
                  _sizedField(
                    provider.commonNameController,
                    LocalizationKeys.commonName.tr(context),
                    280,
                    pinFieldKey: provider.issueFieldKeyForController(
                      provider.commonNameController,
                    ),
                    requiredField: true,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _sizedField(
                    provider.challengePasswordController,
                    LocalizationKeys.challengePassword.tr(context),
                    300,
                    pinFieldKey: provider.issueFieldKeyForController(
                      provider.challengePasswordController,
                    ),
                  ),
                  _sizedField(
                    provider.validDaysController,
                    LocalizationKeys.validDays.tr(context),
                    180,
                    pinFieldKey: provider.issueFieldKeyForController(
                      provider.validDaysController,
                    ),
                    requiredField: true,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildAltNamesPanel(provider),
            ],
          ),
        if (_issueStep == 1)
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _sizedField(
                provider.countryNameController,
                LocalizationKeys.countryName.tr(context),
                180,
                pinFieldKey: provider.issueFieldKeyForController(
                  provider.countryNameController,
                ),
                requiredField: true,
              ),
              _sizedField(
                provider.stateNameController,
                LocalizationKeys.stateName.tr(context),
                220,
                pinFieldKey: provider.issueFieldKeyForController(
                  provider.stateNameController,
                ),
              ),
              _sizedField(
                provider.localityNameController,
                LocalizationKeys.localityName.tr(context),
                220,
                pinFieldKey: provider.issueFieldKeyForController(
                  provider.localityNameController,
                ),
              ),
              _sizedField(
                provider.organizationNameController,
                LocalizationKeys.organizationName.tr(context),
                260,
                pinFieldKey: provider.issueFieldKeyForController(
                  provider.organizationNameController,
                ),
                requiredField: true,
              ),
              _sizedField(
                provider.organizationalUnitNameController,
                LocalizationKeys.orgUnitName.tr(context),
                260,
                pinFieldKey: provider.issueFieldKeyForController(
                  provider.organizationalUnitNameController,
                ),
              ),
              _sizedField(
                provider.emailAddressController,
                LocalizationKeys.emailAddress.tr(context),
                260,
                pinFieldKey: provider.issueFieldKeyForController(
                  provider.emailAddressController,
                ),
              ),
              _sizedField(
                provider.explicitTextController,
                LocalizationKeys.explicitText.tr(context),
                280,
                pinFieldKey: provider.issueFieldKeyForController(
                  provider.explicitTextController,
                ),
              ),
              _sizedField(
                provider.unstructuredNameController,
                LocalizationKeys.unstructuredName.tr(context),
                260,
                pinFieldKey: provider.issueFieldKeyForController(
                  provider.unstructuredNameController,
                ),
              ),
              _sizedField(
                provider.ocspDomainController,
                LocalizationKeys.ocspDomain.tr(context),
                260,
                pinFieldKey: provider.issueFieldKeyForController(
                  provider.ocspDomainController,
                ),
              ),
            ],
          ),
        if (_issueStep == 2) _buildUsageTypePanel(provider),
        if (_issueStep == 3) _buildEndpointAddressPanel(provider),
        if (_issueStep == 4)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionContainer(
                title: LocalizationKeys.issueSummary.tr(context),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: summaryRows
                        .map(
                          (line) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: SelectableText(
                              line,
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              _buildCard(
                title: LocalizationKeys.draftOpenSslConfig.tr(context),
                child: SizedBox(
                  width: double.infinity,
                  child: SizedBox(
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
                ),
              ),
              const SizedBox(height: 4),
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
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Usage Type Panel
  // ---------------------------------------------------------------------------

  Widget _buildUsageTypePanel(SslCertificateManagerProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocalizationKeys.keyUsageLabel.tr(context),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: SslCertificateManagerProvider.availableKeyUsageTypes
              .map(
                (usage) => Tooltip(
                  message: _keyUsageDescription(usage),
                  child: FilterChip(
                    label: Text(usage),
                    selected: provider.selectedKeyUsageTypes.contains(usage),
                    onSelected: (v) => provider.toggleKeyUsageType(usage, v),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 14),
        Text(
          LocalizationKeys.extendedKeyUsageLabel.tr(context),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: SslCertificateManagerProvider.availableExtendedKeyUsageTypes
              .map(
                (usage) => Tooltip(
                  message: _extendedKeyUsageDescription(usage),
                  child: FilterChip(
                    label: Text(usage),
                    selected: provider.selectedExtendedKeyUsageTypes.contains(
                      usage,
                    ),
                    onSelected: (v) =>
                        provider.toggleExtendedKeyUsageType(usage, v),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Key Usage Descriptions
  // ---------------------------------------------------------------------------

  String _keyUsageDescription(String usage) {
    switch (usage) {
      case 'digitalSignature':
        return LocalizationKeys.keyUsageDescDigitalSignature.tr(context);
      case 'nonRepudiation':
        return LocalizationKeys.keyUsageDescNonRepudiation.tr(context);
      case 'keyEncipherment':
        return LocalizationKeys.keyUsageDescKeyEncipherment.tr(context);
      case 'dataEncipherment':
        return LocalizationKeys.keyUsageDescDataEncipherment.tr(context);
      case 'keyAgreement':
        return LocalizationKeys.keyUsageDescKeyAgreement.tr(context);
      case 'keyCertSign':
        return LocalizationKeys.keyUsageDescKeyCertSign.tr(context);
      case 'cRLSign':
        return LocalizationKeys.keyUsageDescCrlSign.tr(context);
      case 'encipherOnly':
        return LocalizationKeys.keyUsageDescEncipherOnly.tr(context);
      case 'decipherOnly':
        return LocalizationKeys.keyUsageDescDecipherOnly.tr(context);
      default:
        return usage;
    }
  }

  String _extendedKeyUsageDescription(String usage) {
    switch (usage) {
      case 'serverAuth':
        return LocalizationKeys.extKeyUsageDescServerAuth.tr(context);
      case 'clientAuth':
        return LocalizationKeys.extKeyUsageDescClientAuth.tr(context);
      case 'codeSigning':
        return LocalizationKeys.extKeyUsageDescCodeSigning.tr(context);
      case 'emailProtection':
        return LocalizationKeys.extKeyUsageDescEmailProtection.tr(context);
      case 'timeStamping':
        return LocalizationKeys.extKeyUsageDescTimeStamping.tr(context);
      case 'OCSPSigning':
        return LocalizationKeys.extKeyUsageDescOcspSigning.tr(context);
      case 'ipsecIKE':
        return LocalizationKeys.extKeyUsageDescIpsecIke.tr(context);
      case 'msCodeInd':
        return LocalizationKeys.extKeyUsageDescMsCodeInd.tr(context);
      case 'msCodeCom':
        return LocalizationKeys.extKeyUsageDescMsCodeCom.tr(context);
      case 'msCTLSign':
        return LocalizationKeys.extKeyUsageDescMsCtlSign.tr(context);
      case 'msEFS':
        return LocalizationKeys.extKeyUsageDescMsEfs.tr(context);
      case 'nsSGC':
        return LocalizationKeys.extKeyUsageDescNsSgc.tr(context);
      default:
        return usage;
    }
  }

  // ---------------------------------------------------------------------------
  // Endpoint Address Panel
  // ---------------------------------------------------------------------------

  Widget _buildEndpointAddressPanel(SslCertificateManagerProvider provider) {
    return Column(
      children: [
        const SizedBox(height: 8),
        _buildTextField(
          controller: provider.crlDistributionUrlController,
          label: LocalizationKeys.crlDistributionUrl.tr(context),
          pinFieldKey: provider.issueFieldKeyForController(
            provider.crlDistributionUrlController,
          ),
          requiredField: true,
        ),
        _buildTextField(
          controller: provider.ocspCaIssuersUrlController,
          label: LocalizationKeys.ocspCaIssuersUrl.tr(context),
          pinFieldKey: provider.issueFieldKeyForController(
            provider.ocspCaIssuersUrlController,
          ),
          requiredField: true,
        ),
        _buildTextField(
          controller: provider.ocspResponderUrlController,
          label: LocalizationKeys.ocspResponderUrl.tr(context),
          pinFieldKey: provider.issueFieldKeyForController(
            provider.ocspResponderUrlController,
          ),
          requiredField: true,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Issue Summary Rows
  // ---------------------------------------------------------------------------

  List<String> _buildIssueSummaryRows(SslCertificateManagerProvider provider) {
    final altLines = provider.altNames
        .where((e) => e.value.trim().isNotEmpty)
        .map((e) => '${e.type == AltNameType.dns ? 'DNS' : 'IP'}: ${e.value}')
        .toList();
    return [
      '${LocalizationKeys.summaryDomain.tr(context)}: ${provider.domainController.text.trim()}',
      '${LocalizationKeys.summaryCommonName.tr(context)}: ${provider.commonNameController.text.trim()}',
      '${LocalizationKeys.summaryLocation.tr(context)}: ${provider.countryNameController.text.trim()} / ${provider.stateNameController.text.trim()} / ${provider.localityNameController.text.trim()}',
      '${LocalizationKeys.summaryOrganization.tr(context)}: ${provider.organizationNameController.text.trim()} / ${provider.organizationalUnitNameController.text.trim()}',
      '${LocalizationKeys.summaryEmail.tr(context)}: ${provider.emailAddressController.text.trim()}',
      '${LocalizationKeys.summaryValidDays.tr(context)}: ${provider.validDaysController.text.trim()}',
      '${LocalizationKeys.summaryPassword.tr(context)}: ${provider.challengePasswordController.text.isEmpty ? LocalizationKeys.summaryPasswordNotSet.tr(context) : LocalizationKeys.summaryPasswordSet.tr(context)}',
      '${LocalizationKeys.summaryAltNames.tr(context)}: ${altLines.isEmpty ? LocalizationKeys.summaryNone.tr(context) : altLines.join(', ')}',
      '${LocalizationKeys.summaryKeyUsage.tr(context)}: ${provider.selectedKeyUsageTypes.join(', ')}',
      '${LocalizationKeys.summaryExtendedKeyUsage.tr(context)}: ${provider.selectedExtendedKeyUsageTypes.join(', ')}',
      '${LocalizationKeys.summaryCrlUrl.tr(context)}: ${provider.crlDistributionUrlController.text.trim()}',
      '${LocalizationKeys.summaryOcspCaIssuersUrl.tr(context)}: ${provider.ocspCaIssuersUrlController.text.trim()}',
      '${LocalizationKeys.summaryOcspResponderUrl.tr(context)}: ${provider.ocspResponderUrlController.text.trim()}',
    ];
  }

  // ---------------------------------------------------------------------------
  // Validation Helpers
  // ---------------------------------------------------------------------------

  bool _isCompletedIssueField(TextEditingController controller) {
    return controller.text.trim().isNotEmpty &&
        _validationErrorForController(controller) == null;
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
        final error = _validationErrorForController(controller);
        if (error != null) {
          return error;
        }
      }
      for (final altName in provider.altNames) {
        final error = _validationErrorForAltName(altName.type, altName.value);
        if (error != null) {
          return error;
        }
      }
    }
    if (step == 1) {
      for (final controller in [
        provider.countryNameController,
        provider.emailAddressController,
        provider.ocspDomainController,
      ]) {
        final error = _validationErrorForController(controller);
        if (error != null) {
          return error;
        }
      }
    }
    if (step == 3) {
      for (final controller in [
        provider.crlDistributionUrlController,
        provider.ocspCaIssuersUrlController,
        provider.ocspResponderUrlController,
      ]) {
        final error = _validationErrorForController(controller);
        if (error != null) {
          return error;
        }
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
        .where((controller) => controller.text.trim().isEmpty)
        .map(_labelForController)
        .toList(growable: false);
    if (missingFields.isEmpty) {
      return null;
    }
    return LocalizationKeys.validationRequiredFields
        .tr(context)
        .replaceFirst('@fields', missingFields.join('、'));
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

  Future<void> _handleIssueWithDialogs(
    SslCertificateManagerProvider provider,
  ) async {
    final confirmed = await showAdvancedConfirmDialog(
      context: context,
      style: ConfirmDialogStyle.darkNeon,
      title: LocalizationKeys.dialogIssueConfirmTitle.tr(context),
      content: LocalizationKeys.dialogIssueConfirmContent.tr(context),
      icon: Icons.verified_outlined,
      confirmText: LocalizationKeys.dialogIssueNow.tr(context),
      cancelText: LocalizationKeys.cancel.tr(context),
    );
    if (!mounted || confirmed != true) {
      return;
    }

    showLoadingDialog(
      context: context,
      style: ConfirmDialogStyle.darkNeon,
      title: LocalizationKeys.dialogIssuingTitle.tr(context),
      content: LocalizationKeys.dialogIssuingContent.tr(context),
    );

    final result = await provider.issueCertificate();
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();

    if (result.success && result.record != null) {
      final record = result.record!;
      await provider.resetUnpinnedIssueFields();
      if (!mounted) return;
      await showAdvancedConfirmDialog(
        context: context,
        style: ConfirmDialogStyle.darkNeon,
        title: LocalizationKeys.dialogIssueSuccessTitle.tr(context),
        content:
            '${LocalizationKeys.summaryDomain.tr(context)}: ${record.domain}\n'
            '${LocalizationKeys.summaryCn.tr(context)}: ${record.commonName}\n'
            '${LocalizationKeys.serialNumber.tr(context)}: ${record.serialNumber}\n'
            '${LocalizationKeys.issuer.tr(context)}: ${record.issuer}\n'
            '${LocalizationKeys.expiresAt.tr(context)}: ${record.expiresAt.toLocal()}\n'
            '${LocalizationKeys.summaryCertPath.tr(context)}: ${record.certFilePath}\n'
            '${LocalizationKeys.summaryKeyPath.tr(context)}: ${record.keyFilePath}\n'
            '${LocalizationKeys.summaryConfigPath.tr(context)}: ${record.configFilePath}',
        icon: Icons.check_circle_outline,
        confirmText: LocalizationKeys.confirm.tr(context),
        cancelText: '',
        dialogWidth: 860,
        contentTextAlign: TextAlign.left,
        contentTextStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white70,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
      );
      if (!mounted) return;
      _resetIssueStep();
      return;
    }

    await showAdvancedConfirmDialog(
      context: context,
      style: ConfirmDialogStyle.darkNeon,
      title: LocalizationKeys.dialogIssueFailedTitle.tr(context),
      content: result.message,
      icon: Icons.error_outline,
      confirmColor: Colors.redAccent,
      confirmText: LocalizationKeys.dialogAcknowledge.tr(context),
      cancelText: '',
      dialogWidth: 860,
      contentTextAlign: TextAlign.left,
      contentTextStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Colors.white70,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
    );
  }
}

class _IssueStepProgressStats {
  const _IssueStepProgressStats({required this.completed, required this.total});

  final int completed;
  final int total;

  bool get isCompleted => completed >= total;

  double get ratio {
    if (total <= 0) {
      return 0;
    }
    return (completed / total).clamp(0.0, 1.0).toDouble();
  }
}
