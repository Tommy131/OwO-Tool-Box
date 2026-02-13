import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/localization_keys.dart' as core_l10n;
import '../../../core/services/localization_service.dart';
import '../../../core/setup_wizard/wizard_step.dart';
import '../localization/localization_keys.dart' as host_l10n;
import '../models/host_monitor_settings_model.dart';
import '../pages/host_monitor_settings_pages.dart';
import '../providers/host_monitor_provider.dart';

/// 主机监控向导步骤（已整合到 HostMonitorPagesModule）
class HostMonitorWizardStep extends WizardStep {
  Map<String, String>? _summary;

  @override
  String get id => 'host_monitor_step';

  @override
  String get title => host_l10n.LocalizationKeys.hostMonitorSettings;

  @override
  int get priority => 50;

  @override
  bool canGoNext() => true;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<HostMonitorProvider>().settings;
    _summary = _buildSummary(settings);

    return const SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: HostMonitorSettingsForm(showTitle: false),
    );
  }

  @override
  Map<String, String>? getSummary() {
    return _summary;
  }

  String _tr(String key) {
    return LocalizationService().translate(key);
  }

  String _formatBool(bool value) {
    return value
        ? _tr(core_l10n.LocalizationKeys.enabled)
        : _tr(core_l10n.LocalizationKeys.disabled);
  }

  Map<String, String> _buildSummary(HostMonitorSettingsModel settings) {
    return {
      _tr(
        host_l10n.LocalizationKeys.hostPollingInterval,
      ): '${settings.refreshInterval} ${_tr(host_l10n.LocalizationKeys.seconds)}',
      _tr(
        host_l10n.LocalizationKeys.checkTimeout,
      ): '${settings.hostCheckTimeout} ${_tr(host_l10n.LocalizationKeys.seconds)}',
      _tr(
        host_l10n.LocalizationKeys.backgroundCheckInterval,
      ): '${settings.hostCheckInterval} ${_tr(host_l10n.LocalizationKeys.minutes)}',
      _tr(host_l10n.LocalizationKeys.enableAlert): _formatBool(
        settings.enabledAlert,
      ),
      _tr(host_l10n.LocalizationKeys.cpuUsage):
          '${settings.cpuThreshold.toStringAsFixed(0)}%',
      _tr(host_l10n.LocalizationKeys.memoryUsage):
          '${settings.memoryThreshold.toStringAsFixed(0)}%',
      _tr(host_l10n.LocalizationKeys.diskUsage):
          '${settings.diskThreshold.toStringAsFixed(0)}%',
      _tr(host_l10n.LocalizationKeys.uploadSpeed):
          '${settings.networkUploadThreshold.toStringAsFixed(0)} KB/s',
      _tr(host_l10n.LocalizationKeys.downloadSpeed):
          '${settings.networkDownloadThreshold.toStringAsFixed(0)} KB/s',
      _tr(host_l10n.LocalizationKeys.disconnectNotification): _formatBool(
        settings.notifyOnDisconnect,
      ),
      _tr(host_l10n.LocalizationKeys.soundAlert): _formatBool(
        settings.soundEnabled,
      ),
      _tr(host_l10n.LocalizationKeys.vibrationAlert): _formatBool(
        settings.vibrationEnabled,
      ),
    };
  }
}
