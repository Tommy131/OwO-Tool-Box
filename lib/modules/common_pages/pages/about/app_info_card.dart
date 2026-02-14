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
import 'widgets/info_row.dart';
import 'widgets/card_header.dart';

class AppInfoCard extends StatelessWidget {
  const AppInfoCard({super.key});

  String _tr(BuildContext context, String key) => key.tr(context);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CardHeader(
              icon: Icons.info_rounded,
              title: _tr(context, LocalizationKeys.appInfo),
            ),
            const Divider(height: 24),
            InfoRow(
              label: _tr(context, LocalizationKeys.appName),
              value: AppConstants.appName,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            InfoRow(
              label: _tr(context, LocalizationKeys.appVersion),
              value: 'v${AppConstants.appVersion}',
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            InfoRow(
              label: _tr(context, LocalizationKeys.appDescription),
              value: _tr(context, LocalizationKeys.descriptionMessage),
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            InfoRow(
              label: _tr(context, LocalizationKeys.license),
              value: AppConstants.license,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }
}
