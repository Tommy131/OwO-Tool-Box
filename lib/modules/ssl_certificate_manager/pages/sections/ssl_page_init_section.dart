part of '../ssl_certificate_manager_page.dart';

/// 初始化引导区：负责首启配置、路径选择、证书导入确认和风险提示。
extension _SslPageInitSection on _SslCertificateManagerPageState {
  Widget _buildInitGuide(SslCertificateManagerProvider provider) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: ListView(
        children: [
          Text(
            LocalizationKeys.initGuide.tr(context),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildCard(
            title: LocalizationKeys.setupStoragePath.tr(context),
            child: Column(
              children: [
                const SizedBox(height: 8),
                _buildTextField(
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
              ],
            ),
          ),
          _buildCard(
            title: LocalizationKeys.setupRootCA.tr(context),
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    provider.importRootCA
                        ? LocalizationKeys.importRootCA.tr(context)
                        : LocalizationKeys.generateRootCA.tr(context),
                  ),
                  value: provider.importRootCA,
                  onChanged: provider.setImportRootCA,
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: provider.rootCANameController,
                  label: LocalizationKeys.rootCaName.tr(context),
                ),
                _buildTextField(
                  controller: provider.rootCAPasswordController,
                  label: LocalizationKeys.rootCaPassword.tr(context),
                ),
                if (provider.importRootCA) ...[
                  _buildTextField(
                    controller: provider.rootCACertPathController,
                    label: LocalizationKeys.rootCaCertPath.tr(context),
                    suffix: IconButton(
                      icon: const Icon(Icons.upload_file),
                      onPressed: () async {
                        final path = await _pickCertFile();
                        if (path != null) {
                          provider.rootCACertPathController.text = path;
                        }
                      },
                    ),
                  ),
                  _buildTextField(
                    controller: provider.rootCAKeyPathController,
                    label: LocalizationKeys.rootCaKeyPath.tr(context),
                    suffix: IconButton(
                      icon: const Icon(Icons.upload_file),
                      onPressed: () async {
                        final path = await _pickKeyFile();
                        if (path != null) {
                          provider.rootCAKeyPathController.text = path;
                        }
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: provider.isLoading
                ? null
                : () => _handleCompleteInitialization(provider),
            icon: const Icon(Icons.check_circle_outline),
            label: Text(LocalizationKeys.completeInit.tr(context)),
          ),
          const SizedBox(height: 8),
          Text(
            provider.infoMessage,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
