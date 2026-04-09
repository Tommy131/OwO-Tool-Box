import 'package:flutter/material.dart';

import '../../../../core/services/localization_service.dart';
import '../../localization/localization_keys.dart';
import '../../providers/ssl_certificate_manager_provider.dart';
import '../shared/section_container.dart';

/// Panel for selecting key usage and extended key usage types.
class UsageTypePanel extends StatelessWidget {
  const UsageTypePanel({super.key, required this.provider});

  final SslCertificateManagerProvider provider;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SslSectionContainer(
          title: LocalizationKeys.keyUsageLabel.tr(context),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: SslCertificateManagerProvider.availableKeyUsageTypes
                .map(
                  (usage) => Tooltip(
                    message: _keyUsageDescription(context, usage),
                    child: FilterChip(
                      label: Text(usage),
                      selected:
                          provider.selectedKeyUsageTypes.contains(usage),
                      onSelected: (v) =>
                          provider.toggleKeyUsageType(usage, v),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        SslSectionContainer(
          title: LocalizationKeys.extendedKeyUsageLabel.tr(context),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: SslCertificateManagerProvider
                .availableExtendedKeyUsageTypes
                .map(
                  (usage) => Tooltip(
                    message:
                        _extendedKeyUsageDescription(context, usage),
                    child: FilterChip(
                      label: Text(usage),
                      selected: provider.selectedExtendedKeyUsageTypes
                          .contains(usage),
                      onSelected: (v) =>
                          provider.toggleExtendedKeyUsageType(usage, v),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  String _keyUsageDescription(BuildContext context, String usage) {
    switch (usage) {
      case 'digitalSignature':
        return LocalizationKeys.keyUsageDescDigitalSignature.tr(context);
      case 'nonRepudiation':
        return LocalizationKeys.keyUsageDescNonRepudiation.tr(context);
      case 'keyEncipherment':
        return LocalizationKeys.keyUsageDescKeyEncipherment.tr(context);
      case 'dataEncipherment':
        return LocalizationKeys.keyUsageDescDataEncipherment.tr(context);
      case 'keyAgreement':
        return LocalizationKeys.keyUsageDescKeyAgreement.tr(context);
      case 'keyCertSign':
        return LocalizationKeys.keyUsageDescKeyCertSign.tr(context);
      case 'cRLSign':
        return LocalizationKeys.keyUsageDescCrlSign.tr(context);
      case 'encipherOnly':
        return LocalizationKeys.keyUsageDescEncipherOnly.tr(context);
      case 'decipherOnly':
        return LocalizationKeys.keyUsageDescDecipherOnly.tr(context);
      default:
        return usage;
    }
  }

  String _extendedKeyUsageDescription(BuildContext context, String usage) {
    switch (usage) {
      case 'serverAuth':
        return LocalizationKeys.extKeyUsageDescServerAuth.tr(context);
      case 'clientAuth':
        return LocalizationKeys.extKeyUsageDescClientAuth.tr(context);
      case 'codeSigning':
        return LocalizationKeys.extKeyUsageDescCodeSigning.tr(context);
      case 'emailProtection':
        return LocalizationKeys.extKeyUsageDescEmailProtection.tr(context);
      case 'timeStamping':
        return LocalizationKeys.extKeyUsageDescTimeStamping.tr(context);
      case 'OCSPSigning':
        return LocalizationKeys.extKeyUsageDescOcspSigning.tr(context);
      case 'ipsecIKE':
        return LocalizationKeys.extKeyUsageDescIpsecIke.tr(context);
      case 'msCodeInd':
        return LocalizationKeys.extKeyUsageDescMsCodeInd.tr(context);
      case 'msCodeCom':
        return LocalizationKeys.extKeyUsageDescMsCodeCom.tr(context);
      case 'msCTLSign':
        return LocalizationKeys.extKeyUsageDescMsCtlSign.tr(context);
      case 'msEFS':
        return LocalizationKeys.extKeyUsageDescMsEfs.tr(context);
      case 'nsSGC':
        return LocalizationKeys.extKeyUsageDescNsSgc.tr(context);
      default:
        return usage;
    }
  }
}
