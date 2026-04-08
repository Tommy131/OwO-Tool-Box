part of '../ssl_certificate_manager_page.dart';

/// 初始化引导区：负责首启配置、路径选择、证书导入确认和风险提示。
extension _SslPageInitSection on _SslCertificateManagerPageState {
  Widget _buildInitGuide(SslCertificateManagerProvider provider) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: ListView(
        children: [
          _buildGradientHeader(
            title: LocalizationKeys.initWelcomeTitle.tr(context),
            subtitle: LocalizationKeys.initWelcomeSubtitle.tr(context),
            icon: Icons.verified_user,
          ),
          const SizedBox(height: 20),
          _buildPremiumCard(
            title: LocalizationKeys.setupStoragePath.tr(context),
            icon: Icons.folder_outlined,
            child: _buildTextField(
              controller: provider.storagePathController,
              label: LocalizationKeys.setupStoragePath.tr(context),
              suffix: IconButton(
                icon: const Icon(Icons.folder_open),
                onPressed: () async {
                  final path = await _pickDirectory();
                  if (path != null) {
                    await provider.changeStoragePath(path);
                  }
                },
              ),
            ),
          ),
          _buildPremiumCard(
            title: LocalizationKeys.setupRootCA.tr(context),
            icon: Icons.security_outlined,
            child: Column(
              children: [
                SegmentedButton<bool>(
                  segments: [
                    ButtonSegment<bool>(
                      value: false,
                      label: Text(
                        LocalizationKeys.generateRootCA.tr(context),
                      ),
                      icon: const Icon(Icons.auto_fix_high_outlined),
                    ),
                    ButtonSegment<bool>(
                      value: true,
                      label: Text(
                        LocalizationKeys.importRootCA.tr(context),
                      ),
                      icon: const Icon(Icons.upload_file_outlined),
                    ),
                  ],
                  selected: {provider.importRootCA},
                  onSelectionChanged: (selected) {
                    provider.setImportRootCA(selected.first);
                  },
                  showSelectedIcon: false,
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: provider.rootCANameController,
                  label: LocalizationKeys.rootCaName.tr(context),
                ),
                _buildTextField(
                  controller: provider.rootCAPasswordController,
                  label: LocalizationKeys.rootCaPassword.tr(context),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  child: provider.importRootCA
                      ? Column(
                          children: [
                            _buildTextField(
                              controller: provider.rootCACertPathController,
                              label:
                                  LocalizationKeys.rootCaCertPath.tr(context),
                              suffix: IconButton(
                                icon: const Icon(Icons.upload_file),
                                onPressed: () async {
                                  final path = await _pickCertFile();
                                  if (path != null) {
                                    provider.rootCACertPathController.text =
                                        path;
                                  }
                                },
                              ),
                            ),
                            _buildTextField(
                              controller: provider.rootCAKeyPathController,
                              label:
                                  LocalizationKeys.rootCaKeyPath.tr(context),
                              suffix: IconButton(
                                icon: const Icon(Icons.upload_file),
                                onPressed: () async {
                                  final path = await _pickKeyFile();
                                  if (path != null) {
                                    provider.rootCAKeyPathController.text =
                                        path;
                                  }
                                },
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: SizedBox(
              width: 280,
              height: 48,
              child: FilledButton.icon(
                onPressed: provider.isLoading
                    ? null
                    : () => _handleCompleteInitialization(provider),
                icon: const Icon(Icons.check_circle_outline),
                label: Text(
                  LocalizationKeys.completeInit.tr(context),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (provider.infoMessage.trim().isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      provider.infoMessage,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
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
}
