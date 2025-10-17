import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../my_models/host_monitor_settings_model.dart';
import '../my_providers/host_monitor_provider.dart';
import 'widgets/settings_cards.dart';
import 'widgets/threshold_slider.dart';

class HostMonitorSettingsScreen extends StatefulWidget {
  const HostMonitorSettingsScreen({super.key});

  @override
  State<HostMonitorSettingsScreen> createState() =>
      _HostMonitorSettingsScreenState();
}

class _HostMonitorSettingsScreenState extends State<HostMonitorSettingsScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '主机监控设置',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
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
      ],
    );
  }

  Widget _buildRefreshSettings() {
    return SettingsCard(
      title: '刷新设置',
      icon: Icons.refresh,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InputFieldCard(
            label: '主机轮询间隔',
            hint: '输入刷新间隔（秒）',
            suffix: '秒',
            controller: _intervalController,
            description: '建议设置为1-10秒之间，过短可能影响性能',
          ),
        ],
      ),
    );
  }

  Widget _buildHostCheckSettings() {
    return SettingsCard(
      title: '主机检测设置',
      icon: Icons.monitor_heart,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InputFieldCard(
            label: '检测超时时间',
            hint: '输入超时时间（秒）',
            suffix: '秒',
            controller: _hostCheckTimeoutController,
            description: '检测主机在线状态的超时时间，建议3-10秒',
          ),
          const SizedBox(height: 20),
          InputFieldCard(
            label: '后台检测间隔',
            hint: '输入检测间隔（分钟）',
            suffix: '分钟',
            controller: _hostCheckIntervalController,
            description: '后台静默检测主机列表状态的间隔时间，建议5-30分钟',
          ),
        ],
      ),
    );
  }

  Widget _buildAlertGeneralSettings() {
    return SettingsCard(
      title: '告警设置',
      icon: Icons.warning_amber,
      child: SwitchCard(
        title: '启用告警',
        subtitle: '开启后将在资源使用超过阈值时发送通知',
        value: _settings.enabledAlert,
        onChanged: (value) {
          _updateAlertSettings(
            _settings.copyWith(enabledAlert: value),
          );
        },
      ),
    );
  }

  Widget _buildAlertThresholdSettings() {
    return SettingsCard(
      title: '告警阈值',
      icon: Icons.tune,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ThresholdSlider(
            label: 'CPU 使用率',
            value: _settings.cpuThreshold.toDouble(),
            min: 50,
            max: 100,
            unit: '%',
            onChanged: (value) {
              _updateAlertSettings(
                _settings.copyWith(cpuThreshold: value),
              );
            },
          ),
          const SizedBox(height: 16),
          ThresholdSlider(
            label: '内存使用率',
            value: _settings.memoryThreshold.toDouble(),
            min: 50,
            max: 100,
            unit: '%',
            onChanged: (value) {
              _updateAlertSettings(
                _settings.copyWith(memoryThreshold: value),
              );
            },
          ),
          const SizedBox(height: 16),
          ThresholdSlider(
            label: '磁盘使用率',
            value: _settings.diskThreshold.toDouble(),
            min: 50,
            max: 100,
            unit: '%',
            onChanged: (value) {
              _updateAlertSettings(
                _settings.copyWith(diskThreshold: value),
              );
            },
          ),
          const SizedBox(height: 16),
          ThresholdSlider(
            label: '上传速率',
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
            label: '下载速率',
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
      title: '通知设置',
      icon: Icons.notifications,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchCard(
            title: '断开连接通知',
            value: _settings.notifyOnDisconnect,
            onChanged: (value) {
              _updateAlertSettings(
                _settings.copyWith(notifyOnDisconnect: value),
              );
            },
          ),
          SwitchCard(
            title: '声音提示',
            value: _settings.soundEnabled,
            onChanged: (value) {
              _updateAlertSettings(
                _settings.copyWith(soundEnabled: value),
              );
            },
          ),
          SwitchCard(
            title: '震动提示',
            subtitle: '仅在移动设备上生效',
            value: _settings.vibrationEnabled,
            onChanged: (value) {
              _updateAlertSettings(
                _settings.copyWith(vibrationEnabled: value),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    // final localizations = AppLocalization.of(context);
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
          child: const Text(
            '保存',
            // localizations.translate(L18nKeys.saveSettings),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Future<void> _saveSettings() async {
    final intervalSeconds = int.tryParse(_intervalController.text.trim());
    final hostCheckTimeout =
        int.tryParse(_hostCheckTimeoutController.text.trim());
    final hostCheckInterval =
        int.tryParse(_hostCheckIntervalController.text.trim());

    if (!_validateInputs(
        intervalSeconds, hostCheckTimeout, hostCheckInterval)) {
      return;
    }

    if (intervalSeconds! > 60) {
      final confirmed = await _showConfirmDialog(
        '刷新间隔较长',
        '您设置的刷新间隔为$intervalSeconds秒，这可能导致数据更新不及时。确定继续？',
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

    // 按需调用方法
    await provider.updateSettings(newSettings);

    setState(() => _hasChanges = false);
    _showSnackBar('设置已保存', Colors.green);
  }

  bool _validateInputs(int? interval, int? timeout, int? checkInterval) {
    final theme = Theme.of(context);
    if (interval == null || interval < 1) {
      _showSnackBar('请输入有效的刷新间隔（至少1秒）', theme.colorScheme.error);
      return false;
    }

    if (timeout == null || timeout < 1 || timeout > 60) {
      _showSnackBar('请输入有效的检测超时时间（1-60秒）', theme.colorScheme.error);
      return false;
    }

    if (checkInterval == null || checkInterval < 1 || checkInterval > 1440) {
      _showSnackBar('请输入有效的检测间隔（1-1440分钟）', theme.colorScheme.error);
      return false;
    }

    return true;
  }

  Future<bool> _showConfirmDialog(String title, String content) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定'),
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
