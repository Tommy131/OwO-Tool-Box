/*
 *        _____   _          __  _____   _____   _       _____   _____
 *      /  _  \ | |        / / /  _  \ |  _  \ | |     /  _  \ /  ___|
 *      | | | | | |  __   / /  | | | | | |_| | | |     | | | | | |
 *      | | | | | | /  | / /   | | | | |  _  { | |     | | | | | |   _
 *      | |_| | | |/   |/ /    | |_| | | |_| | | |___  | |_| | | |_| |
 *      \_____/ |___/|___/     \_____/ |_____/ |_____| \_____/ \_____/
 *
 *  Copyright (c) 2023 by OwOTeam-DGMT (OwOBlog).
 * @Date         : 2025-10-22
 * @Author       : HanskiJay
 * @LastEditors  : HanskiJay
 * @LastEditTime : 2025-10-22
 * @E-Mail       : support@owoblog.com
 * @Telegram     : https://t.me/HanskiJay
 * @GitHub       : https://github.com/Tommy131
 */
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ssl_settings_provider.dart';
import '../widgets/custom_button.dart';
import '../../core/i18n/app_localization.dart';
import '../../core/i18n/localization_keys.dart';

class OpenSSLConfigScreen extends StatefulWidget {
  const OpenSSLConfigScreen({super.key});

  @override
  State<OpenSSLConfigScreen> createState() => _OpenSSLConfigScreenState();
}

class _OpenSSLConfigScreenState extends State<OpenSSLConfigScreen> {
  final _configController = TextEditingController();
  bool _isModified = false;
  bool _isLoading = true;

  // 国际化翻译辅助方法
  String _tr(String key) {
    return AppLocalization.of(context).translate(key);
  }

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  @override
  void dispose() {
    _configController.dispose();
    super.dispose();
  }

  Future<void> _loadConfig() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final settingsProvider = context.read<SSLSettingsProvider>();
      final content = await settingsProvider.getConfigContent();
      _configController.text = content;
      _isModified = false;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_tr(L18nKeys.configLoadError)
                .replaceAll('{error}', e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveConfig() async {
    try {
      final settingsProvider = context.read<SSLSettingsProvider>();
      await settingsProvider.saveConfigContent(_configController.text);

      setState(() {
        _isModified = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_tr(L18nKeys.configSaveSuccess)),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_tr(L18nKeys.configSaveError)
                .replaceAll('{error}', e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _resetToDefault() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_tr(L18nKeys.configResetToDefault)),
        content: Text(_tr(L18nKeys.configResetConfirm)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_tr(L18nKeys.configCancel)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _loadConfig();
            },
            child: Text(
              _tr(L18nKeys.configReset),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _tr(L18nKeys.configEditHint),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: _configController,
                        maxLines: null,
                        expands: true,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: _tr(L18nKeys.configPlaceholder),
                        ),
                        onChanged: (value) {
                          if (!_isModified) {
                            setState(() {
                              _isModified = true;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomButton(
                      text: _tr(L18nKeys.configResetToDefaultBtn),
                      onPressed: _resetToDefault,
                      isOutlined: true,
                      icon: Icons.restore,
                    ),
                    const SizedBox(width: 12),
                    CustomButton(
                      text: _tr(L18nKeys.configSaveConfiguration),
                      onPressed: _isModified ? _saveConfig : () {},
                      icon: Icons.save,
                    ),
                  ],
                ),
              ),
            ],
          );
  }
}
