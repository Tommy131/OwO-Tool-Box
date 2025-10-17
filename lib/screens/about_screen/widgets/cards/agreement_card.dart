import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/i18n/app_localization.dart';
import '../../../../core/i18n/localization_keys.dart';
import '../common/card_header.dart';

class AgreementCard extends StatelessWidget {
  const AgreementCard({super.key});

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
              icon: Icons.description_rounded,
              title: localizations.translate(L18nKeys.userAgreement),
              iconSize: 28,
            ),
            const Divider(height: 24),
            Text(
              localizations.translate(L18nKeys.agreementContent),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                    height: 1.6,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              AppConstants.copyright,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
