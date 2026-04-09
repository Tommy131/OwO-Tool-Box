import 'package:flutter/material.dart';

import '../../../../core/services/localization_service.dart';
import '../../localization/localization_keys.dart';
import '../../models/ssl_models.dart';
import '../../providers/ssl_certificate_manager_provider.dart';
import '../shared/section_container.dart';

/// Structured summary for the final confirmation step.
class IssueSummarySection extends StatelessWidget {
  const IssueSummarySection({super.key, required this.provider});

  final SslCertificateManagerProvider provider;

  @override
  Widget build(BuildContext context) {
    final altLines = provider.altNames
        .where((e) => e.value.trim().isNotEmpty)
        .map((e) => '${e.type == AltNameType.dns ? 'DNS' : 'IP'}: ${e.value}')
        .join(', ');
    return Column(
      children: [
        SslSectionContainer(
          title: LocalizationKeys.sectionIdentity.tr(context),
          child: Column(
            children: [
              SslInfoRow(
                label: LocalizationKeys.summaryDomain.tr(context),
                value: provider.domainController.text.trim(),
              ),
              SslInfoRow(
                label: LocalizationKeys.summaryCommonName.tr(context),
                value: provider.commonNameController.text.trim(),
              ),
              SslInfoRow(
                label: LocalizationKeys.summaryAltNames.tr(context),
                value: altLines.isEmpty
                    ? LocalizationKeys.summaryNone.tr(context)
                    : altLines,
              ),
            ],
          ),
        ),
        SslSectionContainer(
          title: LocalizationKeys.sectionOrganization.tr(context),
          child: Column(
            children: [
              SslInfoRow(
                label: LocalizationKeys.summaryLocation.tr(context),
                value:
                    '${provider.countryNameController.text.trim()} / ${provider.stateNameController.text.trim()} / ${provider.localityNameController.text.trim()}',
              ),
              SslInfoRow(
                label: LocalizationKeys.summaryOrganization.tr(context),
                value:
                    '${provider.organizationNameController.text.trim()} / ${provider.organizationalUnitNameController.text.trim()}',
              ),
              SslInfoRow(
                label: LocalizationKeys.summaryEmail.tr(context),
                value: provider.emailAddressController.text.trim(),
              ),
            ],
          ),
        ),
        SslSectionContainer(
          title: LocalizationKeys.sectionSecurity.tr(context),
          child: Column(
            children: [
              SslInfoRow(
                label: LocalizationKeys.summaryValidDays.tr(context),
                value: provider.validDaysController.text.trim(),
              ),
              SslInfoRow(
                label: LocalizationKeys.summaryPassword.tr(context),
                value: provider.challengePasswordController.text.isEmpty
                    ? LocalizationKeys.summaryPasswordNotSet.tr(context)
                    : LocalizationKeys.summaryPasswordSet.tr(context),
              ),
              SslInfoRow(
                label: LocalizationKeys.summaryKeyUsage.tr(context),
                value: provider.selectedKeyUsageTypes.join(', '),
              ),
              SslInfoRow(
                label: LocalizationKeys.summaryExtendedKeyUsage.tr(context),
                value: provider.selectedExtendedKeyUsageTypes.join(', '),
              ),
            ],
          ),
        ),
        SslSectionContainer(
          title: LocalizationKeys.sectionEndpoints.tr(context),
          child: Column(
            children: [
              SslInfoRow(
                label: LocalizationKeys.summaryCrlUrl.tr(context),
                value: provider.crlDistributionUrlController.text.trim(),
              ),
              SslInfoRow(
                label: LocalizationKeys.summaryOcspCaIssuersUrl.tr(context),
                value: provider.ocspCaIssuersUrlController.text.trim(),
              ),
              SslInfoRow(
                label:
                    LocalizationKeys.summaryOcspResponderUrl.tr(context),
                value: provider.ocspResponderUrlController.text.trim(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
