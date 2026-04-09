import 'package:flutter/material.dart';

import '../../../../core/services/localization_service.dart';
import '../../localization/localization_keys.dart';
import '../../models/ssl_models.dart';
import '../../providers/ssl_certificate_manager_provider.dart';
import 'ssl_input_config.dart';
import 'ssl_validators.dart';

/// A panel that lists Subject Alternative Name entries with type dropdowns,
/// text fields and pin/remove controls.
class SslAltNamesPanel extends StatelessWidget {
  const SslAltNamesPanel({super.key, required this.provider});

  final SslCertificateManagerProvider provider;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationKeys.altNames.tr(context),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Column(
              children: [
                for (int i = 0; i < provider.altNames.length; i++)
                  _AltNameRow(provider: provider, index: i),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: () => provider.addAltName(),
                    icon: const Icon(Icons.add),
                    label: Text(LocalizationKeys.addAltName.tr(context)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AltNameRow extends StatelessWidget {
  const _AltNameRow({required this.provider, required this.index});

  final SslCertificateManagerProvider provider;
  final int index;

  @override
  Widget build(BuildContext context) {
    final altName = provider.altNames[index];
    final config = SslInputConfigResolver.altNameConfig(altName.type);
    final fieldKey = provider.altNameFieldKey(index);
    final isPinned = provider.isIssueFieldPinned(fieldKey);
    final canToggle = isPinned || provider.canPinIssueField(fieldKey);
    return Row(
      children: [
        DropdownButton<AltNameType>(
          value: altName.type,
          items: [
            DropdownMenuItem(
              value: AltNameType.dns,
              child: Text(LocalizationKeys.altNameTypeDns.tr(context)),
            ),
            DropdownMenuItem(
              value: AltNameType.ip,
              child: Text(LocalizationKeys.altNameTypeIp.tr(context)),
            ),
          ],
          onChanged: isPinned
              ? null
              : (v) {
                  if (v != null) provider.updateAltNameType(index, v);
                },
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            key: ValueKey('alt_name_$index'),
            initialValue: altName.value,
            keyboardType: config.keyboardType,
            inputFormatters: config.inputFormatters,
            textCapitalization: config.textCapitalization,
            readOnly: isPinned,
            onChanged: isPinned
                ? null
                : (v) => provider.updateAltNameValue(index, v),
            decoration: InputDecoration(
              isDense: true,
              suffixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
              suffixIcon: IconButton(
                tooltip: isPinned
                    ? LocalizationKeys.unpinField.tr(context)
                    : LocalizationKeys.pinField.tr(context),
                onPressed: canToggle
                    ? () => provider.toggleIssueFieldPinned(fieldKey)
                    : null,
                icon: Icon(
                  isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  color: isPinned
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).iconTheme.color?.withValues(
                            alpha: canToggle ? 0.78 : 0.5,
                          ),
                ),
              ),
              errorText: SslValidators.validationErrorForAltName(
                type: altName.type,
                value: altName.value,
                context: context,
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: isPinned ? null : () => provider.removeAltName(index),
          icon: const Icon(Icons.remove_circle_outline),
        ),
      ],
    );
  }
}
