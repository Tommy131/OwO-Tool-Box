import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/revoked_certificate.dart';
import 'custom_card.dart';
import 'info_row.dart';

class CertificateListItem extends StatelessWidget {
  final RevokedCertificate certificate;

  const CertificateListItem({
    super.key,
    required this.certificate,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      color: Colors.red.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '序列号: ${certificate.serialNumber}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          InfoRow(
            label: '吊销日期',
            value: DateFormat('yyyy-MM-dd HH:mm:ss')
                .format(certificate.revocationDate),
          ),
          InfoRow(label: '吊销原因', value: certificate.reason),
          InfoRow(label: '证书主题', value: certificate.issuer),
        ],
      ),
    );
  }
}
