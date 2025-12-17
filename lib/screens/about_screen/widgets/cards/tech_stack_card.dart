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

import '../../../../core/i18n/app_localization.dart';
import '../../../../core/i18n/localization_keys.dart';
import '../common/card_header.dart';

class TechStackCard extends StatelessWidget {
  const TechStackCard({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalization.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CardHeader(
              icon: Icons.build,
              title: localizations.translate(L18nKeys.techStack),
              iconSize: 28,
            ),
            const SizedBox(height: 20),
            _buildTechItem(
              context,
              localizations.translate(L18nKeys.flutter),
              localizations.translate(L18nKeys.flutterDescription),
              Icons.phone_android,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildTechItem(
              context,
              localizations.translate(L18nKeys.goLang),
              localizations.translate(L18nKeys.goLangDescription),
              Icons.memory,
              Colors.cyan,
            ),
            const SizedBox(height: 12),
            _buildTechItem(
              context,
              localizations.translate(L18nKeys.tcpIp),
              localizations.translate(L18nKeys.tcpIpDescription),
              Icons.wifi,
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildTechItem(
              context,
              localizations.translate(L18nKeys.materialDesign),
              localizations.translate(L18nKeys.materialDesignDescription),
              Icons.palette,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechItem(
    BuildContext context,
    String tech,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.6)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tech,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
