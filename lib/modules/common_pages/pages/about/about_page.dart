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
// ============================================================================
// 关于页面内容
// ============================================================================

import 'package:flutter/material.dart';

import 'widgets/cards/copyright_card.dart';
import 'widgets/cards/donation_card.dart';
import 'widgets/cards/app_icon_card.dart';
import 'widgets/cards/app_info_card.dart';
import 'widgets/cards/developer_card.dart';
import 'widgets/cards/open_source_card.dart';
import 'widgets/cards/agreement_card.dart';
import 'widgets/cards/tech_stack_card.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 36),
                AppIconCard(),
                SizedBox(height: 36),
                AppInfoCard(),
                SizedBox(height: 16),
                DeveloperCard(),
                SizedBox(height: 16),
                TechStackCard(),
                SizedBox(height: 16),
                DonationCard(),
                SizedBox(height: 16),
                OpenSourceCard(),
                SizedBox(height: 16),
                AgreementCard(),
                SizedBox(height: 16),
                CopyrightCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
