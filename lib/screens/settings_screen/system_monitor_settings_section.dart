// ============================================================================
// System Monitor Settings Section Component
// ============================================================================

import 'package:flutter/material.dart';
import '../../models/alert_config.dart';
import '../../models/system_monitor_settings.dart';
import '../../utils/i18n/app_localization.dart';
import '../../utils/i18n/localization_keys.dart';
import 'setting_section.dart';

class SystemMonitorSettingsSection extends StatefulWidget {
  final SystemMonitorSettings initialSettings;
  final Function(SystemMonitorSettings) onSettingsChanged;

  const SystemMonitorSettingsSection({
    super.key,
    required this.initialSettings,
    required this.onSettingsChanged,
  });

  @override
  State<SystemMonitorSettingsSection> createState() =>
      _SystemMonitorSettingsSectionState();
}

class _SystemMonitorSettingsSectionState
    extends State<SystemMonitorSettingsSection> {
  late TextEditingController _intervalController;
  late TextEditingController _hostCheckTimeoutController;
  late TextEditingController _hostCheckIntervalController;
  late AlertConfig _alertConfig;

  @override
  void initState() {
    super.initState();
    _intervalController = TextEditingController(
      text: widget.initialSettings.refreshInterval.toString(),
    );
    _hostCheckTimeoutController = TextEditingController(
      text: widget.initialSettings.hostCheckTimeout.toString(),
    );
    _hostCheckIntervalController = TextEditingController(
      text: widget.initialSettings.hostCheckInterval.toString(),
    );
    _alertConfig = widget.initialSettings.alertConfig;

    _intervalController.addListener(_notifyChanges);
    _hostCheckTimeoutController.addListener(_notifyChanges);
    _hostCheckIntervalController.addListener(_notifyChanges);
  }

  @override
  void dispose() {
    _intervalController.dispose();
    _hostCheckTimeoutController.dispose();
    _hostCheckIntervalController.dispose();
    super.dispose();
  }

  void _notifyChanges() {
    final newSettings = SystemMonitorSettings(
      refreshInterval: int.tryParse(_intervalController.text) ??
          widget.initialSettings.refreshInterval,
      hostCheckTimeout: int.tryParse(_hostCheckTimeoutController.text) ??
          widget.initialSettings.hostCheckTimeout,
      hostCheckInterval: int.tryParse(_hostCheckIntervalController.text) ??
          widget.initialSettings.hostCheckInterval,
      alertConfig: _alertConfig,
    );
    widget.onSettingsChanged(newSettings);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalization.of(context);

    return Column(
      children: [
        _buildRefreshSettings(localizations),
        const SizedBox(height: 16),
        _buildHostCheckSettings(localizations),
        const SizedBox(height: 16),
        _buildAlertGeneralSettings(localizations),
        const SizedBox(height: 16),
        _buildAlertThresholdSettings(localizations),
        const SizedBox(height: 16),
        _buildNotificationSettings(localizations),
      ],
    );
  }

  Widget _buildRefreshSettings(AppLocalization localizations) {
    return SettingSection(
      title: localizations.translate(L18nKeys.refreshSettings),
      icon: Icons.refresh,
      children: [
        SettingTextField(
          label: localizations.translate(L18nKeys.pollingInterval),
          controller: _intervalController,
          suffix: localizations.translate(L18nKeys.secondsSuffix),
          hint: localizations.translate(L18nKeys.refreshIntervalHint),
          helperText: localizations.translate(L18nKeys.refreshIntervalTip),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildHostCheckSettings(AppLocalization localizations) {
    return SettingSection(
      title: localizations.translate(L18nKeys.hostCheckSettings),
      icon: Icons.monitor_heart,
      children: [
        SettingTextField(
          label: localizations.translate(L18nKeys.checkTimeout),
          controller: _hostCheckTimeoutController,
          suffix: localizations.translate(L18nKeys.secondsSuffix),
          hint: localizations.translate(L18nKeys.timeoutHint),
          helperText: localizations.translate(L18nKeys.hostTimeoutTip),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        SettingTextField(
          label: localizations.translate(L18nKeys.backgroundCheckInterval),
          controller: _hostCheckIntervalController,
          suffix: localizations.translate(L18nKeys.minutesSuffix),
          hint: localizations.translate(L18nKeys.checkIntervalHint),
          helperText: localizations.translate(L18nKeys.backgroundCheckTip),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildAlertGeneralSettings(AppLocalization localizations) {
    return SettingSection(
      title: localizations.translate(L18nKeys.alertSettings),
      icon: Icons.warning_amber,
      children: [
        SwitchListTile(
          title: Text(localizations.translate(L18nKeys.enableAlerts)),
          subtitle: Text(
            localizations.translate(L18nKeys.enableAlertsSubtitle),
            style: const TextStyle(fontSize: 12),
          ),
          value: _alertConfig.enabled,
          onChanged: (value) {
            setState(() {
              _alertConfig = _alertConfig.copyWith(enabled: value);
              _notifyChanges();
            });
          },
        ),
      ],
    );
  }

  Widget _buildAlertThresholdSettings(AppLocalization localizations) {
    return SettingSection(
      title: localizations.translate(L18nKeys.alertThresholds),
      icon: Icons.tune,
      children: [
        SettingSlider(
          label: localizations.translate(L18nKeys.cpuUsage),
          value: _alertConfig.cpuThreshold,
          min: 50,
          max: 100,
          unit: '%',
          onChanged: (value) {
            setState(() {
              _alertConfig = _alertConfig.copyWith(cpuThreshold: value);
              _notifyChanges();
            });
          },
        ),
        const SizedBox(height: 16),
        SettingSlider(
          label: localizations.translate(L18nKeys.memoryUsage),
          value: _alertConfig.memoryThreshold,
          min: 50,
          max: 100,
          unit: '%',
          onChanged: (value) {
            setState(() {
              _alertConfig = _alertConfig.copyWith(memoryThreshold: value);
              _notifyChanges();
            });
          },
        ),
        const SizedBox(height: 16),
        SettingSlider(
          label: localizations.translate(L18nKeys.diskUsage),
          value: _alertConfig.diskThreshold,
          min: 50,
          max: 100,
          unit: '%',
          onChanged: (value) {
            setState(() {
              _alertConfig = _alertConfig.copyWith(diskThreshold: value);
              _notifyChanges();
            });
          },
        ),
        const SizedBox(height: 16),
        SettingSlider(
          label: localizations.translate(L18nKeys.uploadRate),
          value: _alertConfig.networkUploadThreshold,
          min: 1024,
          max: 102400,
          unit: localizations.translate(L18nKeys.kbPerSecond),
          divisions: 100,
          onChanged: (value) {
            setState(() {
              _alertConfig =
                  _alertConfig.copyWith(networkUploadThreshold: value);
              _notifyChanges();
            });
          },
        ),
        const SizedBox(height: 16),
        SettingSlider(
          label: localizations.translate(L18nKeys.downloadRate),
          value: _alertConfig.networkDownloadThreshold,
          min: 1024,
          max: 102400,
          unit: localizations.translate(L18nKeys.kbPerSecond),
          divisions: 100,
          onChanged: (value) {
            setState(() {
              _alertConfig =
                  _alertConfig.copyWith(networkDownloadThreshold: value);
              _notifyChanges();
            });
          },
        ),
      ],
    );
  }

  Widget _buildNotificationSettings(AppLocalization localizations) {
    return SettingSection(
      title: localizations.translate(L18nKeys.notificationSettings),
      icon: Icons.notifications,
      children: [
        SwitchListTile(
          title: Text(localizations.translate(L18nKeys.notifyOnDisconnect)),
          value: _alertConfig.notifyOnDisconnect,
          onChanged: (value) {
            setState(() {
              _alertConfig = _alertConfig.copyWith(notifyOnDisconnect: value);
              _notifyChanges();
            });
          },
        ),
        SwitchListTile(
          title: Text(localizations.translate(L18nKeys.soundEnabled)),
          value: _alertConfig.soundEnabled,
          onChanged: (value) {
            setState(() {
              _alertConfig = _alertConfig.copyWith(soundEnabled: value);
              _notifyChanges();
            });
          },
        ),
        SwitchListTile(
          title: Text(localizations.translate(L18nKeys.vibrationEnabled)),
          subtitle: Text(
            localizations.translate(L18nKeys.vibrationNote),
            style: const TextStyle(fontSize: 12),
          ),
          value: _alertConfig.vibrationEnabled,
          onChanged: (value) {
            setState(() {
              _alertConfig = _alertConfig.copyWith(vibrationEnabled: value);
              _notifyChanges();
            });
          },
        ),
      ],
    );
  }
}
