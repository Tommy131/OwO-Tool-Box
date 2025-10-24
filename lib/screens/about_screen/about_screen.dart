// ============================================================================
// 关于页面内容
// ============================================================================

import 'package:flutter/material.dart';
import 'package:owo_system_tools/screens/about_screen/widgets/cards/copyright_card.dart';

import '../../core/layouts/responsive_break_points.dart';
import '../../core/i18n/app_localization.dart';
import '../../core/i18n/localization_keys.dart';
import '../../core/widgets/cards/donation_card.dart';
import 'widgets/cards/app_icon_card.dart';
import 'widgets/cards/app_info_card.dart';
import 'widgets/cards/developer_card.dart';
import 'widgets/cards/open_source_card.dart';
import 'widgets/cards/agreement_card.dart';
import 'widgets/cards/tech_stack_card.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalization.of(context);
    final responsiveBreakpoints = ResponsiveBreakpoints(context);
    final isMobile = responsiveBreakpoints.isMobile();
    final isDesktop = responsiveBreakpoints.isDesktop();
    final isTablet = responsiveBreakpoints.isTablet();

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: Text(localizations.translate(L18nKeys.about)),
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop
              ? 48
              : isTablet
                  ? 32
                  : 16),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop
                    ? 800
                    : isTablet
                        ? 600
                        : double.infinity,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMobile) ...[
                    Text(
                      localizations.translate(L18nKeys.about),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 24),
                  ],
                  const AppIconCard(),
                  const SizedBox(height: 36),
                  const AppInfoCard(),
                  const SizedBox(height: 16),
                  const DeveloperCard(),
                  const SizedBox(height: 16),
                  const TechStackCard(),
                  const SizedBox(height: 16),
                  const DonationCard(),
                  const SizedBox(height: 16),
                  const OpenSourceCard(),
                  const SizedBox(height: 16),
                  const AgreementCard(),
                  const SizedBox(height: 16),
                  const CopyrightCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
