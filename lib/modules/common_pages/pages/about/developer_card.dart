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
import '../../../../core/services/localization_service.dart';

import '../../localization/localization_keys.dart';
import 'widgets/clickable_info_row.dart';
import 'widgets/card_header.dart';

class DeveloperCard extends StatelessWidget {
  const DeveloperCard({super.key});

  String _tr(BuildContext context, String key) => key.tr(context);

  @override
  Widget build(BuildContext context) {
    // final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CardHeader(
              icon: Icons.code_rounded,
              title: _tr(context, LocalizationKeys.developerInfo),
            ),
            const Divider(height: 24),
            ClickableInfoRow(
              label: _tr(context, LocalizationKeys.developerName),
              value: AppConstants.developerName,
              url: AppConstants.owoServiceUrl,
              icon: Icons.person,
            ),
            const SizedBox(height: 12),
            ClickableInfoRow(
              label: _tr(context, LocalizationKeys.contactEmail),
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
              label: _tr(context, LocalizationKeys.serviceHomepage),
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
