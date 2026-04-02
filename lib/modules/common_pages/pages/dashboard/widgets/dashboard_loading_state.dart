import 'package:flutter/material.dart';

import '../../../localization/localization_keys.dart';
import '../../../../../core/services/localization_service.dart';

class DashboardLoadingState extends StatelessWidget {
  const DashboardLoadingState({super.key, required this.primaryColor});

  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation(primaryColor),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            LocalizationKeys.loadingDeviceInfo.tr(context),
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
