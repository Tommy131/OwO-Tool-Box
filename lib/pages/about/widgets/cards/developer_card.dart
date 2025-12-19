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

import '../../../../core/constants/app_constants.dart';
import '../../../../core/i18n/app_localization.dart';
import '../../../../core/i18n/localization_keys.dart';
import '../common/clickable_info_row.dart';
import '../common/card_header.dart';

class DeveloperCard extends StatelessWidget {
  const DeveloperCard({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalization.of(context);
    // final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CardHeader(
              icon: Icons.code_rounded,
              title: localizations.translate(L18nKeys.developerInfo),
            ),
            const Divider(height: 24),
            ClickableInfoRow(
              label: localizations.translate(L18nKeys.developerName),
              value: AppConstants.developerName,
              url: AppConstants.owoServiceUrl,
              icon: Icons.person,
            ),
            const SizedBox(height: 12),
            ClickableInfoRow(
              label: localizations.translate(L18nKeys.contactEmail),
              value: AppConstants.developerEmail,
              url: 'mailto:${AppConstants.developerEmail}',
              icon: Icons.email_rounded,
            ),
            const SizedBox(height: 12),
            const ClickableInfoRow(
              label: 'GitHub',
              value: AppConstants.githubUrl,
              url: 'https://${AppConstants.githubUrl}',
              icon: Icons.code_rounded,
            ),
            const SizedBox(height: 12),
            ClickableInfoRow(
              label: localizations.translate(L18nKeys.serviceHomepage),
              value: AppConstants.owoServiceUrl,
              url: AppConstants.owoServiceUrl,
              icon: Icons.web_rounded,
            ),
            const SizedBox(height: 12),
            const ClickableInfoRow(
              label: 'Instagram',
              value: '@${AppConstants.instagramName}',
              url: AppConstants.instagramUrl,
              icon: Icons.photo_camera_rounded,
            ),
          ],
        ),
      ),
    );
  }
}
