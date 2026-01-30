/*
 *        _____   _          __  _____   _____   _       _____   _____
 *      /  _  \ | |        / / /  _  \ |  _  \ | |     /  _  \ /  ___|
 *      | | | | | |  __   / /  | | | | | |_| | | |     | | | | | |
 *      | | | | | | /  | / /   | | | | |  _  { | |     | | | | | |   _
 *      | |_| | | |/   |/ /    | |_| | | |_| | | |___  | |_| | | |_| |
 *      \_____/ |___/|___/     \_____/ |_____/ |_____| \_____/ \_____/
 *
 *  Copyright (c) 2023 by OwOTeam-DGMT (OwOBlog).
 * @Date         : 2026-01-25 21:40:00
 * @Author       : HanskiJay
 * @LastEditors  : HanskiJay
 * @LastEditTime : 2026-01-25 21:40:00
 * @E-Mail       : support@owoblog.com
 * @Telegram     : https://t.me/HanskiJay
 * @GitHub       : https://github.com/Tommy131
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/system_tools_provider.dart';
import '../../../core/widgets/common/dialog.dart';
import '../../../core/i18n/app_localization.dart';
import '../../../core/i18n/localization_keys.dart';

/// 定时关机标签页
class ShutdownTab extends StatefulWidget {
  const ShutdownTab({super.key});

  @override
  State<ShutdownTab> createState() => _ShutdownTabState();
}

class _ShutdownTabState extends State<ShutdownTab> {
  final TextEditingController _hoursController = TextEditingController();
  final TextEditingController _minutesController = TextEditingController();
  final TextEditingController _secondsController = TextEditingController();

  DateTime? _selectedTime;
  bool _useSpecificTime = false;

  // 翻译辅助方法
  String _tr(String key) => AppLocalization.of(context).translate(key);

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<SystemToolsProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 当前状态卡片
          if (provider.hasActiveShutdown) _buildActiveTaskCard(theme, provider),

          // 设置关机时间卡片
          if (!provider.hasActiveShutdown) ...[
            _buildTimeModeSelector(theme),
            const SizedBox(height: 16),

            if (!_useSpecificTime)
              _buildDurationInput(theme)
            else
              _buildSpecificTimeInput(theme),

            const SizedBox(height: 24),
            _buildScheduleButton(theme, provider),
          ],

          // 错误信息
          if (provider.shutdownError != null) ...[
            const SizedBox(height: 16),
            _buildErrorBanner(theme, provider.shutdownError!),
          ],

          // 快捷操作
          const SizedBox(height: 24),
          _buildQuickActions(theme, provider),
        ],
      ),
    );
  }

  Widget _buildActiveTaskCard(ThemeData theme, SystemToolsProvider provider) {
    final task = provider.currentTask!;
    final remaining = task.getRemainingSeconds() ?? 0;
    final hours = remaining ~/ 3600;
    final minutes = (remaining % 3600) ~/ 60;
    final seconds = remaining % 60;

    return Card(
      elevation: 4,
      shadowColor: theme.colorScheme.primary.withValues(alpha: 0.2),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
            ],
          ),
        ),
        child: Column(
          children: [
            Icon(Icons.alarm, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              _tr(L18nKeys.shutdownScheduled),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 24),

            // 倒计时显示
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTimeUnit(theme, hours, _tr(L18nKeys.hours)),
                const SizedBox(width: 8),
                Text(':', style: theme.textTheme.headlineLarge),
                const SizedBox(width: 8),
                _buildTimeUnit(theme, minutes, _tr(L18nKeys.minute)),
                const SizedBox(width: 8),
                Text(':', style: theme.textTheme.headlineLarge),
                const SizedBox(width: 8),
                _buildTimeUnit(theme, seconds, _tr(L18nKeys.second)),
              ],
            ),

            const SizedBox(height: 24),

            // 取消按钮
            ElevatedButton.icon(
              onPressed: () => _cancelShutdown(provider),
              icon: const Icon(Icons.cancel),
              label: Text(_tr(L18nKeys.cancelShutdown)),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeUnit(ThemeData theme, int value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeModeSelector(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: RadioListTile<bool>(
                value: false,
                groupValue: _useSpecificTime,
                onChanged: (value) {
                  setState(() {
                    _useSpecificTime = value!;
                  });
                },
                title: Text(_tr(L18nKeys.duration)),
                subtitle: Text(_tr(L18nKeys.setDelayTime)),
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                value: true,
                groupValue: _useSpecificTime,
                onChanged: (value) {
                  setState(() {
                    _useSpecificTime = value!;
                  });
                },
                title: Text(_tr(L18nKeys.specificTime)),
                subtitle: Text(_tr(L18nKeys.setExactTime)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationInput(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _tr(L18nKeys.setDuration),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildNumberInput(
                    controller: _hoursController,
                    label: _tr(L18nKeys.hours),
                    icon: Icons.access_time,
                    max: 23,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildNumberInput(
                    controller: _minutesController,
                    label: _tr(L18nKeys.minute),
                    icon: Icons.timer,
                    max: 59,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildNumberInput(
                    controller: _secondsController,
                    label: _tr(L18nKeys.second),
                    icon: Icons.timer_outlined,
                    max: 59,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required int max,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(2),
          ],
          decoration: InputDecoration(
            hintText: '0',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          textAlign: TextAlign.center,
          onChanged: (value) {
            if (value.isNotEmpty) {
              final number = int.tryParse(value) ?? 0;
              if (number > max) {
                controller.text = max.toString();
                controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: controller.text.length),
                );
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildSpecificTimeInput(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _tr(L18nKeys.setSpecificTime),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(
                _selectedTime != null
                    ? '${_selectedTime!.year}-${_selectedTime!.month.toString().padLeft(2, '0')}-${_selectedTime!.day.toString().padLeft(2, '0')} ${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                    : _tr(L18nKeys.selectDateTime),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _pickDateTime,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: theme.dividerColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleButton(ThemeData theme, SystemToolsProvider provider) {
    return ElevatedButton.icon(
      onPressed: provider.isSchedulingShutdown
          ? null
          : () => _scheduleShutdown(provider),
      icon: provider.isSchedulingShutdown
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.schedule),
      label: Text(
        provider.isSchedulingShutdown
            ? _tr(L18nKeys.scheduling)
            : _tr(L18nKeys.scheduleShutdown),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildErrorBanner(ThemeData theme, String error) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: TextStyle(color: theme.colorScheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme, SystemToolsProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _tr(L18nKeys.quickActions),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildQuickActionChip(
                  theme,
                  label: _tr(L18nKeys.tenMinutes),
                  icon: Icons.timer_10,
                  onPressed: () => _quickSchedule(provider, 600),
                ),
                _buildQuickActionChip(
                  theme,
                  label: _tr(L18nKeys.thirtyMinutes),
                  icon: Icons.timer,
                  onPressed: () => _quickSchedule(provider, 1800),
                ),
                _buildQuickActionChip(
                  theme,
                  label: _tr(L18nKeys.oneHour),
                  icon: Icons.access_time,
                  onPressed: () => _quickSchedule(provider, 3600),
                ),
                _buildQuickActionChip(
                  theme,
                  label: _tr(L18nKeys.twoHours),
                  icon: Icons.schedule,
                  onPressed: () => _quickSchedule(provider, 7200),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionChip(
    ThemeData theme, {
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onPressed,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide.none,
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          _selectedTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _scheduleShutdown(SystemToolsProvider provider) async {
    bool success = false;

    if (_useSpecificTime) {
      if (_selectedTime == null) {
        _showError(_tr(L18nKeys.pleaseSelectDateTime));
        return;
      }
      success = await provider.scheduleShutdownByTime(_selectedTime!);
    } else {
      final hours = int.tryParse(_hoursController.text) ?? 0;
      final minutes = int.tryParse(_minutesController.text) ?? 0;
      final seconds = int.tryParse(_secondsController.text) ?? 0;

      final totalSeconds = hours * 3600 + minutes * 60 + seconds;

      if (totalSeconds <= 0) {
        _showError(_tr(L18nKeys.pleaseSetValidDuration));
        return;
      }

      success = await provider.scheduleShutdownBySeconds(totalSeconds);
    }

    if (success && mounted) {
      _showSuccess(_tr(L18nKeys.shutdownScheduledSuccess));
      // 清空输入
      _hoursController.clear();
      _minutesController.clear();
      _secondsController.clear();
      _selectedTime = null;
    }
  }

  Future<void> _quickSchedule(SystemToolsProvider provider, int seconds) async {
    final success = await provider.scheduleShutdownBySeconds(seconds);
    if (success && mounted) {
      _showSuccess(_tr(L18nKeys.shutdownScheduledSuccess));
    }
  }

  Future<void> _cancelShutdown(SystemToolsProvider provider) async {
    final confirm = await showAdvancedConfirmDialog(
      context: context,
      title: _tr(L18nKeys.confirmCancelShutdown),
      content: _tr(L18nKeys.confirmCancelShutdownMessage),
      icon: Icons.warning_amber_rounded,
      confirmText: _tr(L18nKeys.cancelShutdown),
      cancelText: _tr(L18nKeys.keepSchedule),
    );

    if (confirm == true) {
      final success = await provider.cancelShutdown();
      if (success && mounted) {
        _showSuccess(_tr(L18nKeys.shutdownCancelled));
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
      ),
    );
  }
}
