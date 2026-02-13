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
import 'package:provider/provider.dart';

import '../../../core/services/localization_service.dart';

import '../localization/localization_keys.dart';
import '../providers/system_tools_provider.dart';
import '../models/power_plan.dart';
import '../../../core/widgets/common/dialog.dart';

/// 电源管理标签页
class PowerManagementTab extends StatefulWidget {
  const PowerManagementTab({super.key});

  @override
  State<PowerManagementTab> createState() => _PowerManagementTabState();
}

class _PowerManagementTabState extends State<PowerManagementTab> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<SystemToolsProvider>();

    return RefreshIndicator(
      onRefresh: () => provider.loadPowerPlans(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 当前电源计划
            _buildCurrentPlanCard(theme, provider),

            const SizedBox(height: 16),

            // 快速切换电源模式
            _buildQuickModeSelector(theme, provider),

            const SizedBox(height: 16),

            // 所有电源计划
            _buildAllPlansSection(theme, provider),

            // 错误信息
            if (provider.powerError != null) ...[
              const SizedBox(height: 16),
              _buildErrorBanner(theme, provider.powerError!),
            ],

            const SizedBox(height: 16),

            // 电源操作
            _buildPowerActions(theme, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPlanCard(ThemeData theme, SystemToolsProvider provider) {
    if (provider.isLoadingPowerPlans) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: CircularProgressIndicator(color: theme.colorScheme.primary),
          ),
        ),
      );
    }

    final currentPlan = provider.currentPowerPlan;

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
            Icon(
              _getPowerModeIcon(currentPlan?.mode),
              size: 48,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 12),
            Text(
              LocalizationKeys.currentPowerPlan.tr(context),
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer.withValues(
                  alpha: 0.7,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              currentPlan?.name ?? 'Unknown',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            if (currentPlan?.description != null) ...[
              const SizedBox(height: 8),
              Text(
                currentPlan!.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer.withValues(
                    alpha: 0.8,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickModeSelector(
    ThemeData theme,
    SystemToolsProvider provider,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationKeys.quickModeSwitch.tr(context),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildModeCard(
                    theme,
                    provider,
                    PowerMode.highPerformance,
                    Icons.speed,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildModeCard(
                    theme,
                    provider,
                    PowerMode.balanced,
                    Icons.balance,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildModeCard(
                    theme,
                    provider,
                    PowerMode.powerSaver,
                    Icons.eco,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeCard(
    ThemeData theme,
    SystemToolsProvider provider,
    PowerMode mode,
    IconData icon,
    Color color,
  ) {
    final isActive = provider.currentPowerPlan?.mode == mode;
    final isChanging = provider.isChangingPowerPlan;

    return InkWell(
      onTap: isChanging || isActive
          ? null
          : () => _changePowerMode(provider, mode),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive
              ? color.withValues(alpha: 0.15)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isActive
                  ? color
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              mode.nameKey.tr(context).split(' ').first,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? color : null,
              ),
              textAlign: TextAlign.center,
            ),
            if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  LocalizationKeys.active.tr(context),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllPlansSection(ThemeData theme, SystemToolsProvider provider) {
    if (provider.powerPlans.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationKeys.allPowerPlans.tr(context),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...provider.powerPlans.map(
              (plan) => _buildPlanTile(theme, provider, plan),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanTile(
    ThemeData theme,
    SystemToolsProvider provider,
    PowerPlanModel plan,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: plan.isActive
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: plan.isActive
            ? Border.all(color: theme.colorScheme.primary, width: 2)
            : null,
      ),
      child: ListTile(
        leading: Icon(
          _getPowerModeIcon(plan.mode),
          color: plan.isActive
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        title: Text(
          plan.name,
          style: TextStyle(
            fontWeight: plan.isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: plan.description.isNotEmpty ? Text(plan.description) : null,
        trailing: plan.isActive
            ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  LocalizationKeys.active.tr(context),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
        onTap: plan.isActive || provider.isChangingPowerPlan
            ? null
            : () => _changePowerPlan(provider, plan),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  Widget _buildPowerActions(ThemeData theme, SystemToolsProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationKeys.powerActions.tr(context),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _performPowerAction(provider, LocalizationKeys.sleep),
                    icon: const Icon(Icons.bedtime),
                    label: Text(LocalizationKeys.sleep.tr(context)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _performPowerAction(
                      provider,
                      LocalizationKeys.hibernate,
                    ),
                    icon: const Icon(Icons.power_settings_new),
                    label: Text(LocalizationKeys.hibernate.tr(context)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPowerModeIcon(PowerMode? mode) {
    if (mode == null) return Icons.help_outline;

    switch (mode) {
      case PowerMode.highPerformance:
        return Icons.speed;
      case PowerMode.balanced:
        return Icons.balance;
      case PowerMode.powerSaver:
        return Icons.eco;
    }
  }

  Future<void> _changePowerMode(
    SystemToolsProvider provider,
    PowerMode mode,
  ) async {
    final confirm = await showAdvancedConfirmDialog(
      context: context,
      title: LocalizationKeys.changePowerMode.tr(context),
      content:
          '${LocalizationKeys.switchToPowerMode.tr(context).replaceAll('{mode}', mode.nameKey.tr(context))}\n\n${mode.descriptionKey.tr(context)}',
      icon: Icons.battery_charging_full,
      confirmText: LocalizationKeys.confirm.tr(context),
      cancelText: LocalizationKeys.cancel.tr(context),
    );

    if (confirm == true) {
      final success = await provider.setPowerMode(mode);
      if (success && mounted) {
        _showSuccess(
          LocalizationKeys.powerModeChanged
              .tr(context)
              .replaceAll('{mode}', mode.nameKey.tr(context)),
        );
      }
    }
  }

  Future<void> _changePowerPlan(
    SystemToolsProvider provider,
    PowerPlanModel plan,
  ) async {
    final success = await provider.setPowerPlanByGuid(plan.guid);
    if (success && mounted) {
      _showSuccess(
        LocalizationKeys.powerPlanChanged
            .tr(context)
            .replaceAll('{plan}', plan.name),
      );
    }
  }

  Future<void> _performPowerAction(
    SystemToolsProvider provider,
    String actionKey,
  ) async {
    final action = actionKey.tr(context);
    final contentKey = actionKey == LocalizationKeys.sleep
        ? LocalizationKeys.confirmSleepMessage
        : LocalizationKeys.confirmHibernateMessage;

    final confirm = await showAdvancedConfirmDialog(
      context: context,
      title: action,
      content: contentKey.tr(context),
      icon: actionKey == LocalizationKeys.sleep
          ? Icons.bedtime
          : Icons.power_settings_new,
      confirmText: action,
      cancelText: LocalizationKeys.cancel.tr(context),
      confirmColor: Colors.orange,
    );

    if (confirm == true) {
      bool success = false;
      if (actionKey == LocalizationKeys.sleep) {
        success = await provider.sleep();
      } else if (actionKey == LocalizationKeys.hibernate) {
        success = await provider.hibernate();
      }

      if (!success && mounted) {
        _showError(
          LocalizationKeys.failedToAction
              .tr(context)
              .replaceAll('{action}', action),
        );
      }
    }
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
}
