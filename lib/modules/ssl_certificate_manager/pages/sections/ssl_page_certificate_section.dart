part of '../ssl_certificate_manager_page.dart';

/// 证书功能区：包含证书列表、详情展示与签发模板表单。
extension _SslPageCertificateSection on _SslCertificateManagerPageState {
  Widget _buildCertificateList(SslCertificateManagerProvider provider) {
    final data = provider.certificates;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (provider.infoMessage.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(provider.infoMessage),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: data.isEmpty
                ? Center(child: Text(LocalizationKeys.noData.tr(context)))
                : Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Card(
                          child: ListView.separated(
                            itemCount: data.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final item = data[index];
                              final isSelected =
                                  provider.selectedCertId == item.id;
                              return ListTile(
                                selected: isSelected,
                                title: Text(item.domain),
                                subtitle: Text(
                                  '${LocalizationKeys.issuer.tr(context)}: ${item.issuer} | ${LocalizationKeys.expiresAt.tr(context)}: ${item.expiresAt.toLocal().toString().split(".").first}',
                                ),
                                trailing: Chip(
                                  label: Text(
                                    item.status == SslCertStatus.issued
                                        ? LocalizationKeys.statusIssued.tr(
                                            context,
                                          )
                                        : LocalizationKeys.statusRevoked.tr(
                                            context,
                                          ),
                                  ),
                                ),
                                onTap: () =>
                                    provider.selectCertificate(item.id),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: _buildCertificateDetail(provider),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificateDetail(SslCertificateManagerProvider provider) {
    final cert = provider.selectedCertificate;
    if (cert == null) {
      return Center(child: Text(LocalizationKeys.detail.tr(context)));
    }
    final revokeConfig = _resolveInputConfig(provider.revokeReasonController);
    return ListView(
      children: [
        Text(cert.domain, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          '${LocalizationKeys.serialNumber.tr(context)}: ${cert.serialNumber}',
        ),
        Text('${LocalizationKeys.issuer.tr(context)}: ${cert.issuer}'),
        Text(
          '${LocalizationKeys.issuedAt.tr(context)}: ${cert.issuedAt.toLocal()}',
        ),
        Text(
          '${LocalizationKeys.expiresAt.tr(context)}: ${cert.expiresAt.toLocal()}',
        ),
        const SizedBox(height: 8),
        TextField(
          controller: provider.revokeReasonController,
          keyboardType: revokeConfig.keyboardType,
          inputFormatters: revokeConfig.inputFormatters,
          obscureText: revokeConfig.obscureText,
          textCapitalization: revokeConfig.textCapitalization,
          decoration: InputDecoration(
            labelText: LocalizationKeys.revokeReason.tr(context),
            suffixIcon: revokeConfig.suffix,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ElevatedButton.icon(
              onPressed: cert.status == SslCertStatus.revoked
                  ? null
                  : () => provider.revokeCertificate(cert.id),
              icon: const Icon(Icons.block),
              label: Text(LocalizationKeys.revoke.tr(context)),
            ),
            OutlinedButton.icon(
              onPressed: () => provider.deleteCertificate(cert.id),
              icon: const Icon(Icons.delete_outline),
              label: Text(LocalizationKeys.delete.tr(context)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIssueTab(SslCertificateManagerProvider provider) {
    final theme = Theme.of(context);
    final summaryRows = _buildIssueSummaryRows(provider);
    final configPreview = provider.buildDraftCnfPreview();
    final currentTitle = _issueStepTitles()[_issueStep];
    final currentSubtitle = _issueStepSubtitles()[_issueStep];

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
              _buildCard(
                title: LocalizationKeys.issueSummary.tr(context),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: summaryRows
                        .map(
                          (line) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: SelectableText(line),
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
