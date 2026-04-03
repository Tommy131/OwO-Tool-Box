import 'package:flutter/material.dart';

import '../../../../core/services/localization_service.dart';
import '../../localization/localization_keys.dart';

class SslManagerSidebar extends StatelessWidget {
  final TabController tabController;
  final ValueChanged<int> onSelect;

  const SslManagerSidebar({
    super.key,
    required this.tabController,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.5),
        border: Border(
          right: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _buildNavItem(
            context,
            0,
            Icons.build_outlined,
            LocalizationKeys.operationTab.tr(context),
          ),
          _buildNavItem(
            context,
            1,
            Icons.description_outlined,
            LocalizationKeys.templateTab.tr(context),
          ),
          _buildNavItem(
            context,
            2,
            Icons.settings_rounded,
            LocalizationKeys.settingsTab.tr(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData icon,
    String title,
  ) {
    final selected = tabController.index == index;
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: selected ? theme.colorScheme.primary : null),
      title: Text(
        title,
        style: TextStyle(
          color: selected ? theme.colorScheme.primary : null,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      selected: selected,
      onTap: () => onSelect(index),
    );
  }
}
