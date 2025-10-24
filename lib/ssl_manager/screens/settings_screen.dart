import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../providers/ssl_settings_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_card.dart';
import '../../core/i18n/app_localization.dart';
import '../../core/i18n/localization_keys.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _certPathController;
  late TextEditingController _configPathController;
  late TextEditingController _caNameController;
  late TextEditingController _caPasswordController;
  bool _encryptCaByDefault = false;
  bool _isModified = false;

  // 国际化翻译辅助方法
  String _tr(String key) {
    return AppLocalization.of(context).translate(key);
  }

  @override
  void initState() {
    super.initState();
    _certPathController = TextEditingController();
    _configPathController = TextEditingController();
    _caNameController = TextEditingController();
    _caPasswordController = TextEditingController();
    _loadSettings();
  }

  @override
  void dispose() {
    _certPathController.dispose();
    _configPathController.dispose();
    _caNameController.dispose();
    _caPasswordController.dispose();
    super.dispose();
  }

  void _loadSettings() {
    final settingsProvider = context.read<SSLSettingsProvider>();
    final settings = settingsProvider.settings;

    if (settings != null) {
      _certPathController.text = settings.certificatePath;
      _configPathController.text = settings.opensslConfigPath;
      _caNameController.text = settings.caName;
      _caPasswordController.text = settings.defaultCaPassword ?? '';
      _encryptCaByDefault = settings.encryptCaByDefault;
    }
  }

  void _markModified() {
    if (!_isModified) {
      setState(() {
        _isModified = true;
      });
    }
  }

  Future<void> _selectCertDirectory() async {
    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: _tr(L18nKeys.settingsSelectCertDirectory),
    );

    if (result != null) {
      _certPathController.text = result;
      _markModified();
    }
  }

  Future<void> _selectConfigFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['cnf', 'conf', 'config', 'txt'],
      dialogTitle: _tr(L18nKeys.settingsSelectConfigFile),
    );

    if (result != null && result.files.isNotEmpty) {
      _configPathController.text = result.files.first.path!;
      _markModified();
    }
  }

  Future<void> _createNewConfigFile() async {
    final result = await FilePicker.platform.saveFile(
      dialogTitle: _tr(L18nKeys.settingsCreateConfigFile),
      fileName: 'openssl.cnf',
      type: FileType.custom,
      allowedExtensions: ['cnf'],
    );

    if (result != null) {
      _configPathController.text = result;
      _markModified();
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isModified = false;
    });

    try {
      final settingsProvider = context.read<SSLSettingsProvider>();
      final currentSettings = settingsProvider.settings!;

      final newSettings = currentSettings.copyWith(
        certificatePath: _certPathController.text,
        opensslConfigPath: _configPathController.text,
        caName: _caNameController.text,
        encryptCaByDefault: _encryptCaByDefault,
        defaultCaPassword: _caPasswordController.text.isEmpty
            ? null
            : _caPasswordController.text,
      );

      // 创建目录
      final directory = Directory(newSettings.certificatePath);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // 验证配置文件
      final configFile = File(newSettings.opensslConfigPath);
      if (!await configFile.exists()) {
        // 创建父目录
        await configFile.parent.create(recursive: true);
      }

      await settingsProvider.updateSettings(newSettings);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_tr(L18nKeys.settingsSaveSuccess)),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_tr(L18nKeys.settingsSaveError)
                .replaceAll('{error}', e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Certificate Storage Section
                Text(
                  _tr(L18nKeys.settingsCertStorage),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _certPathController,
                        decoration: InputDecoration(
                          labelText: _tr(L18nKeys.settingsCertStoragePath),
                          hintText: _tr(L18nKeys.settingsCertPathHint),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.folder_open),
                            onPressed: _selectCertDirectory,
                          ),
                        ),
                        validator: (value) => value?.isEmpty == true
                            ? _tr(L18nKeys.settingsRequired)
                            : null,
                        onChanged: (value) => _markModified(),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _tr(L18nKeys.settingsCertStorageDesc),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // OpenSSL Configuration Section
                Text(
                  _tr(L18nKeys.settingsOpenSSLConfig),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _configPathController,
                        decoration: InputDecoration(
                          labelText: _tr(L18nKeys.settingsConfigFilePath),
                          hintText: _tr(L18nKeys.settingsConfigPathHint),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.create_new_folder),
                                onPressed: _createNewConfigFile,
                                tooltip: _tr(L18nKeys.settingsCreateNew),
                              ),
                              IconButton(
                                icon: const Icon(Icons.folder_open),
                                onPressed: _selectConfigFile,
                                tooltip: _tr(L18nKeys.settingsSelectExisting),
                              ),
                            ],
                          ),
                        ),
                        validator: (value) => value?.isEmpty == true
                            ? _tr(L18nKeys.settingsRequired)
                            : null,
                        onChanged: (value) => _markModified(),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _tr(L18nKeys.settingsConfigFileDesc),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // CA Certificate Defaults Section
                Text(
                  _tr(L18nKeys.settingsCACertDefaults),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                CustomCard(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _caNameController,
                        decoration: InputDecoration(
                          labelText: _tr(L18nKeys.settingsDefaultCAName),
                          hintText: _tr(L18nKeys.settingsCANameHint),
                        ),
                        validator: (value) => value?.isEmpty == true
                            ? _tr(L18nKeys.settingsRequired)
                            : null,
                        onChanged: (value) => _markModified(),
                      ),
                      const SizedBox(height: 16),
                      CheckboxListTile(
                        value: _encryptCaByDefault,
                        onChanged: (value) {
                          setState(() {
                            _encryptCaByDefault = value ?? false;
                          });
                          _markModified();
                        },
                        title: Text(_tr(L18nKeys.settingsEncryptCAByDefault)),
                        subtitle: Text(
                          _tr(L18nKeys.settingsEncryptCADesc),
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                      if (_encryptCaByDefault) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _caPasswordController,
                          decoration: InputDecoration(
                            labelText: _tr(L18nKeys.settingsDefaultCAPassword),
                            hintText: _tr(L18nKeys.settingsCAPasswordHint),
                          ),
                          obscureText: true,
                          onChanged: (value) => _markModified(),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _tr(L18nKeys.settingsPasswordWarning),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // About Section
                Text(
                  _tr(L18nKeys.settingsAbout),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: Text(_tr(L18nKeys.settingsAppName)),
                        subtitle: Text(_tr(L18nKeys.settingsAppVersion)),
                        contentPadding: EdgeInsets.zero,
                      ),
                      const Divider(),
                      Text(
                        _tr(L18nKeys.settingsAppDescription),
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.code, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _tr(L18nKeys.settingsPoweredBy),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Save Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomButton(
                      text: _tr(L18nKeys.settingsReset),
                      onPressed: () {
                        _loadSettings();
                        setState(() {
                          _isModified = false;
                        });
                      },
                      icon: Icons.restore_outlined,
                      isOutlined: true,
                    ),
                    const SizedBox(width: 12),
                    CustomButton(
                      text: _tr(L18nKeys.settingsSaveSettings),
                      onPressed: _isModified ? _saveSettings : () {},
                      icon: Icons.save,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
