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
import 'package:owo_tool_box/core/constants/app_constants.dart';

import '../../../../core/i18n/app_localization.dart';
import '../../../../core/i18n/localization_keys.dart';
import '../../../../core/utils/url_launcher_helper.dart';
import '../common/card_header.dart';

class OpenSourceCard extends StatelessWidget {
  const OpenSourceCard({super.key});

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
              icon: Icons.favorite_rounded,
              title: localizations.translate(L18nKeys.openSource),
            ),
            const SizedBox(height: 16),
            Text(
              localizations.translate(L18nKeys.openSourceDescription),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                  ),
            ),
            const SizedBox(height: 16),
            _buildRepositoryLink(context, localizations, isDark),
            const SizedBox(height: 12),
            _buildLicenseInfo(context, localizations, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildRepositoryLink(
    BuildContext context,
    AppLocalization localizations,
    bool isDark,
  ) {
    return InkWell(
      onTap: () => UrlLauncherHelper.launchURL(AppConstants.githubRepoUrl),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.code_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.translate(L18nKeys.viewSourceCode),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppConstants.githubRepoUrl,
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.open_in_new_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLicenseInfo(
    BuildContext context,
    AppLocalization localizations,
    bool isDark,
  ) {
    return Row(
      children: [
        Icon(
          Icons.gavel_rounded,
          size: 16,
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
        ),
        const SizedBox(width: 8),
        Text(
          localizations.translate(L18nKeys.license),
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'MIT License',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
