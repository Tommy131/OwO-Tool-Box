part of '../ssl_certificate_manager_page.dart';

/// 存储配置区：展示配置状态并维护域名别名与 TSA 策略列表。
extension _SslPageStorageSection on _SslCertificateManagerPageState {
  Widget _buildStorageTab(SslCertificateManagerProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          _buildCard(
            title: LocalizationKeys.storageConfig.tr(context),
            child: Column(
              children: [
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
                _buildTextField(
                  controller: provider.rootCANameController,
                  label: LocalizationKeys.rootCaName.tr(context),
                ),
                _buildTextField(
                  controller: provider.rootCACertPathController,
                  label: LocalizationKeys.rootCaCertPath.tr(context),
                ),
                _buildTextField(
                  controller: provider.rootCAKeyPathController,
                  label: LocalizationKeys.rootCaKeyPath.tr(context),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: provider.isLoading
                      ? null
                      : () => _handleCompleteInitialization(provider),
                  icon: const Icon(Icons.settings_backup_restore),
                  label: Text(LocalizationKeys.setupComplete.tr(context)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAltNamesPanel(SslCertificateManagerProvider provider) {
    return _buildCard(
      title: LocalizationKeys.altNames.tr(context),
      child: Column(
        children: [
          for (int i = 0; i < provider.altNames.length; i++)
            Builder(
              builder: (context) {
                final altName = provider.altNames[i];
                final config = _altNameInputConfig(altName.type);
                final fieldKey = provider.altNameFieldKey(i);
                final isPinned = provider.isIssueFieldPinned(fieldKey);
                final canToggle =
                    isPinned || provider.canPinIssueField(fieldKey);
                return Row(
                  children: [
                    DropdownButton<AltNameType>(
                      value: altName.type,
                      items: [
                        DropdownMenuItem(
                          value: AltNameType.dns,
                          child: Text(
                            LocalizationKeys.altNameTypeDns.tr(context),
                          ),
                        ),
                        DropdownMenuItem(
                          value: AltNameType.ip,
                          child: Text(
                            LocalizationKeys.altNameTypeIp.tr(context),
                          ),
                        ),
                      ],
                      onChanged: isPinned
                          ? null
                          : (v) {
                              if (v != null) provider.updateAltNameType(i, v);
                            },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        key: ValueKey('alt_name_$i'),
                        initialValue: altName.value,
                        keyboardType: config.keyboardType,
                        inputFormatters: config.inputFormatters,
                        textCapitalization: config.textCapitalization,
                        readOnly: isPinned,
                        onChanged: isPinned
                            ? null
                            : (v) => provider.updateAltNameValue(i, v),
                        decoration: InputDecoration(
                          isDense: true,
                          suffixIconConstraints: const BoxConstraints(
                            minWidth: 0,
                            minHeight: 0,
                          ),
                          suffixIcon: IconButton(
                            tooltip: isPinned
                                ? LocalizationKeys.unpinField.tr(context)
                                : LocalizationKeys.pinField.tr(context),
                            onPressed: canToggle
                                ? () =>
                                      provider.toggleIssueFieldPinned(fieldKey)
                                : null,
                            icon: Icon(
                              isPinned
                                  ? Icons.push_pin
                                  : Icons.push_pin_outlined,
                              color: isPinned
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(
                                      context,
                                    ).iconTheme.color?.withValues(
                                      alpha: canToggle ? 0.78 : 0.5,
                                    ),
                            ),
                          ),
                          errorText: _validationErrorForAltName(
                            altName.type,
                            altName.value,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: isPinned
                          ? null
                          : () => provider.removeAltName(i),
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                  ],
                );
              },
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () {
                provider.addAltName();
              },
              icon: const Icon(Icons.add),
              label: Text(LocalizationKeys.addAltName.tr(context)),
            ),
          ),
        ],
      ),
    );
  }
}
