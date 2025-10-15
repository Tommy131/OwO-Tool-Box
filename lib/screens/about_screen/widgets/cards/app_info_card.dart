import 'package:flutter/material.dart';

import '../../../../constants/app_constants.dart';
import '../../../../utils/i18n/app_localization.dart';
import '../../../../utils/i18n/localization_keys.dart';
import '../common/info_row.dart';
import '../common/card_header.dart';

class AppInfoCard extends StatelessWidget {
  const AppInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalization.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CardHeader(
              icon: Icons.info_rounded,
              title: localizations.translate(L18nKeys.appInfo),
            ),
            const Divider(height: 24),
            InfoRow(
              label: localizations.translate(L18nKeys.appName),
              value: AppConstants.appName,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            InfoRow(
              label: localizations.translate(L18nKeys.appVersion),
              value: 'v${AppConstants.appVersion}',
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            InfoRow(
              label: localizations.translate(L18nKeys.appDescription),
              value: AppConstants.appDescription,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            InfoRow(
              label: localizations.translate(L18nKeys.license),
              value: AppConstants.license,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }
}
