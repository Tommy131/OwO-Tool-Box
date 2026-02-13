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

import '../../../core/localization/localization_keys.dart' as core_l10n;
import '../../../core/module_registry/settings_page/settings_page_item.dart';
import '../../../core/services/localization_service.dart';
import '../localization/localization_keys.dart' as host_l10n;
import '../models/host_monitor_settings_model.dart';
import '../providers/host_monitor_provider.dart';
import '../widgets/settings/settings_cards.dart';
import '../widgets/settings/threshold_slider.dart';

class HostMonitorSettingsPage extends SettingsPageItem {
  @override
  String get id => 'host_monitor_settings';

  @override
  String getTitle(BuildContext context) {
    return LocalizationService().translate(
      host_l10n.LocalizationKeys.hostMonitorSettings,
    );
  }

  @override
  IconData get icon => Icons.monitor_heart_rounded;

  @override
  int get priority => 80;

  @override
  String? getDescription(BuildContext context) {
    return LocalizationService().translate(
      host_l10n.LocalizationKeys.configureHostMonitor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const HostMonitorSettingsForm();
  }
}

class HostMonitorSettingsForm extends StatefulWidget {
  final bool showTitle;

  const HostMonitorSettingsForm({super.key, this.showTitle = true});

  @override
  State<HostMonitorSettingsForm> createState() =>
      _HostMonitorSettingsFormState();
}

class _HostMonitorSettingsFormState extends State<HostMonitorSettingsForm> {
  late TextEditingController _intervalController;
  late TextEditingController _hostCheckTimeoutController;
  late TextEditingController _hostCheckIntervalController;
  bool _hasChanges = false;

  late HostMonitorSettingsModel _settings;

  @override
  void initState() {
    super.initState();

    _settings = context.read<HostMonitorProvider>().settings;
    _initializeControllers();
  }

  void _initializeControllers() {
    _intervalController = TextEditingController(
      text: _settings.refreshInterval.toString(),
    );
    _hostCheckTimeoutController = TextEditingController(
      text: _settings.hostCheckTimeout.toString(),
    );
    _hostCheckIntervalController = TextEditingController(
      text: _settings.hostCheckInterval.toString(),
    );

    // 统一添加监听
    for (var controller in [
      _intervalController,
      _hostCheckTimeoutController,
      _hostCheckIntervalController,
    ]) {
      controller.addListener(() {
        setState(() => _hasChanges = true);
      });
    }
  }

  @override
  void dispose() {
    _intervalController.dispose();
    _hostCheckTimeoutController.dispose();
    _hostCheckIntervalController.dispose();
    super.dispose();
  }

  String _t(String key) {
    return LocalizationService().translate(key);
  }

  @override
  Widget build(BuildContext context) {
    final sections = <Widget>[
      _buildRefreshSettings(),
      const SizedBox(height: 16),
      _buildHostCheckSettings(),
      const SizedBox(height: 16),
      _buildAlertGeneralSettings(),
      const SizedBox(height: 16),
      _buildAlertThresholdSettings(),
      const SizedBox(height: 16),
      _buildNotificationSettings(),
      const SizedBox(height: 16),
      if (_hasChanges) _buildSaveButton(),
    ];

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showTitle) ...[
            Text(
              _t(host_l10n.LocalizationKeys.hostMonitorSettings),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
          ],
          ...sections,
        ],
      ),
    );
  }

  Widget _buildRefreshSettings() {
    return SettingsCard(
      title: _t(host_l10n.LocalizationKeys.refreshSettings),
      icon: Icons.refresh,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InputFieldCard(
            label: _t(host_l10n.LocalizationKeys.hostPollingInterval),
            hint: _t(host_l10n.LocalizationKeys.enterRefreshInterval),
            suffix: _t(host_l10n.LocalizationKeys.seconds),
            controller: _intervalController,
            description: _t(host_l10n.LocalizationKeys.recommendedInterval),
          ),
        ],
      ),
    );
  }

  Widget _buildHostCheckSettings() {
    return SettingsCard(
      title: _t(host_l10n.LocalizationKeys.hostCheckSettings),
      icon: Icons.monitor_heart,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InputFieldCard(
            label: _t(host_l10n.LocalizationKeys.checkTimeout),
            hint: _t(host_l10n.LocalizationKeys.enterTimeout),
            suffix: _t(host_l10n.LocalizationKeys.seconds),
            controller: _hostCheckTimeoutController,
            description: _t(host_l10n.LocalizationKeys.timeoutDescription),
          ),
          const SizedBox(height: 20),
          InputFieldCard(
            label: _t(host_l10n.LocalizationKeys.backgroundCheckInterval),
            hint: _t(host_l10n.LocalizationKeys.enterCheckInterval),
            suffix: _t(host_l10n.LocalizationKeys.minutes),
            controller: _hostCheckIntervalController,
            description: _t(
              host_l10n.LocalizationKeys.checkIntervalDescription,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertGeneralSettings() {
    return SettingsCard(
      title: _t(host_l10n.LocalizationKeys.alertSettings),
      icon: Icons.warning_amber,
      child: SwitchCard(
        title: _t(host_l10n.LocalizationKeys.enableAlert),
        subtitle: _t(host_l10n.LocalizationKeys.enableAlertDescription),
        value: _settings.enabledAlert,
        onChanged: (value) {
          _updateAlertSettings(_settings.copyWith(enabledAlert: value));
        },
      ),
    );
  }

  Widget _buildAlertThresholdSettings() {
    return SettingsCard(
      title: _t(host_l10n.LocalizationKeys.alertThreshold),
      icon: Icons.tune,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ThresholdSlider(
            label: _t(host_l10n.LocalizationKeys.cpuUsage),
            value: _settings.cpuThreshold.toDouble(),
            min: 50,
            max: 100,
            unit: '%',
            onChanged: (value) {
              _updateAlertSettings(_settings.copyWith(cpuThreshold: value));
            },
          ),
          const SizedBox(height: 16),
          ThresholdSlider(
            label: _t(host_l10n.LocalizationKeys.memoryUsage),
            value: _settings.memoryThreshold.toDouble(),
            min: 50,
            max: 100,
            unit: '%',
            onChanged: (value) {
              _updateAlertSettings(_settings.copyWith(memoryThreshold: value));
            },
          ),
          const SizedBox(height: 16),
          ThresholdSlider(
            label: _t(host_l10n.LocalizationKeys.diskUsage),
            value: _settings.diskThreshold.toDouble(),
            min: 50,
            max: 100,
            unit: '%',
            onChanged: (value) {
              _updateAlertSettings(_settings.copyWith(diskThreshold: value));
            },
          ),
          const SizedBox(height: 16),
          ThresholdSlider(
            label: _t(host_l10n.LocalizationKeys.uploadSpeed),
            value: _settings.networkUploadThreshold,
            min: 1024,
            max: 102400,
            unit: ' KB/s',
            divisions: 100,
            onChanged: (value) {
              _updateAlertSettings(
                _settings.copyWith(networkUploadThreshold: value),
              );
            },
          ),
          const SizedBox(height: 16),
          ThresholdSlider(
            label: _t(host_l10n.LocalizationKeys.downloadSpeed),
            value: _settings.networkDownloadThreshold,
            min: 1024,
            max: 102400,
            unit: ' KB/s',
            divisions: 100,
            onChanged: (value) {
              _updateAlertSettings(
                _settings.copyWith(networkDownloadThreshold: value),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return SettingsCard(
      title: _t(host_l10n.LocalizationKeys.notificationSettings),
      icon: Icons.notifications,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchCard(
            title: _t(host_l10n.LocalizationKeys.disconnectNotification),
            value: _settings.notifyOnDisconnect,
            onChanged: (value) {
              _updateAlertSettings(
                _settings.copyWith(notifyOnDisconnect: value),
              );
            },
          ),
          SwitchCard(
            title: _t(host_l10n.LocalizationKeys.soundAlert),
            value: _settings.soundEnabled,
            onChanged: (value) {
              _updateAlertSettings(_settings.copyWith(soundEnabled: value));
            },
          ),
          SwitchCard(
            title: _t(host_l10n.LocalizationKeys.vibrationAlert),
            subtitle: _t(host_l10n.LocalizationKeys.vibrationAlertDescription),
            value: _settings.vibrationEnabled,
            onChanged: (value) {
              _updateAlertSettings(_settings.copyWith(vibrationEnabled: value));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: _hasChanges
              ? LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [Colors.grey.shade700, Colors.grey.shade700],
                ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ElevatedButton(
          onPressed: _hasChanges ? _saveSettings : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            _t(host_l10n.LocalizationKeys.save),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Future<void> _saveSettings() async {
    final intervalSeconds = int.tryParse(_intervalController.text.trim());
    final hostCheckTimeout = int.tryParse(
      _hostCheckTimeoutController.text.trim(),
    );
    final hostCheckInterval = int.tryParse(
      _hostCheckIntervalController.text.trim(),
    );

    if (!_validateInputs(
      intervalSeconds,
      hostCheckTimeout,
      hostCheckInterval,
    )) {
      return;
    }

    if (intervalSeconds! > 60) {
      final confirmed = await _showConfirmDialog(
        _t(host_l10n.LocalizationKeys.longRefreshInterval),
        _t(
          host_l10n.LocalizationKeys.longRefreshIntervalWarning,
        ).replaceAll('{interval}', intervalSeconds.toString()),
      );
      if (!confirmed) return;
    }

    if (!mounted) return;

    final provider = context.read<HostMonitorProvider>();
    final newSettings = _settings.copyWith(
      refreshInterval: intervalSeconds,
      hostCheckTimeout: hostCheckTimeout!,
      hostCheckInterval: hostCheckInterval!,
    );

    await provider.updateSettings(newSettings);

    setState(() => _hasChanges = false);
    _showSnackBar(_t(host_l10n.LocalizationKeys.settingsSaved), Colors.green);
  }

  bool _validateInputs(int? interval, int? timeout, int? checkInterval) {
    final theme = Theme.of(context);
    if (interval == null || interval < 1) {
      _showSnackBar(
        _t(host_l10n.LocalizationKeys.invalidRefreshInterval),
        theme.colorScheme.error,
      );
      return false;
    }

    if (timeout == null || timeout < 1 || timeout > 60) {
      _showSnackBar(
        _t(host_l10n.LocalizationKeys.invalidTimeout),
        theme.colorScheme.error,
      );
      return false;
    }

    if (checkInterval == null || checkInterval < 1 || checkInterval > 1440) {
      _showSnackBar(
        _t(host_l10n.LocalizationKeys.invalidCheckInterval),
        theme.colorScheme.error,
      );
      return false;
    }

    return true;
  }

  Future<bool> _showConfirmDialog(String title, String content) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(_t(core_l10n.LocalizationKeys.cancel)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(_t(core_l10n.LocalizationKeys.confirm)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _updateAlertSettings(HostMonitorSettingsModel newConfig) {
    setState(() {
      _settings = newConfig;
      _hasChanges = true;
    });
  }
}
