import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/localization_service.dart';
import '../../localization/localization_keys.dart';
import '../../providers/ssl_certificate_manager_provider.dart';
import 'ssl_input_config.dart';
import 'ssl_validators.dart';

/// A themed text field that automatically resolves its input configuration
/// and validation from the [SslCertificateManagerProvider].
class SslTextField extends StatelessWidget {
  const SslTextField({
    super.key,
    required this.controller,
    required this.label,
    this.suffix,
    this.pinFieldKey,
    this.requiredField = false,
    this.obscureRootCaPassword = true,
    this.obscureChallengePassword = true,
    this.onToggleRootCaPassword,
    this.onToggleChallengePassword,
  });

  final TextEditingController controller;
  final String label;
  final Widget? suffix;
  final String? pinFieldKey;
  final bool requiredField;
  final bool obscureRootCaPassword;
  final bool obscureChallengePassword;
  final VoidCallback? onToggleRootCaPassword;
  final VoidCallback? onToggleChallengePassword;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<SslCertificateManagerProvider>();
    final config = SslInputConfigResolver.resolve(
      controller: controller,
      provider: provider,
      obscureRootCaPassword: obscureRootCaPassword,
      obscureChallengePassword: obscureChallengePassword,
      onToggleRootCaPassword: onToggleRootCaPassword,
      onToggleChallengePassword: onToggleChallengePassword,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ListenableBuilder(
        listenable: pinFieldKey == null
            ? controller
            : Listenable.merge([controller, provider]),
        builder: (context, _) {
          final isPinned =
              pinFieldKey != null && provider.isIssueFieldPinned(pinFieldKey!);
          return TextField(
            controller: controller,
            keyboardType: config.keyboardType,
            inputFormatters: config.inputFormatters,
            obscureText: config.obscureText,
            readOnly: isPinned,
            textCapitalization: config.textCapitalization,
            decoration: InputDecoration(
              labelText: _buildFieldLabel(label, requiredField),
              border: const OutlineInputBorder(),
              suffixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
              suffixIcon: _buildInputSuffix(
                context: context,
                controller: controller,
                suffix: suffix ?? config.suffix,
                pinFieldKey: pinFieldKey,
                provider: provider,
              ),
              errorText: SslValidators.validationErrorForController(
                controller: controller,
                provider: provider,
                context: context,
              ),
            ),
          );
        },
      ),
    );
  }
}

String _buildFieldLabel(String label, bool requiredField) {
  return requiredField ? '$label *' : label;
}

Widget? _buildInputSuffix({
  required BuildContext context,
  required TextEditingController controller,
  Widget? suffix,
  String? pinFieldKey,
  required SslCertificateManagerProvider provider,
}) {
  if (suffix == null && pinFieldKey == null) {
    return null;
  }

  final theme = Theme.of(context);
  final actions = <Widget>[];

  if (suffix != null) {
    actions.add(suffix);
  }

  if (pinFieldKey != null) {
    final isPinned = provider.isIssueFieldPinned(pinFieldKey);
    final canToggle = isPinned || provider.canPinIssueField(pinFieldKey);
    actions.add(
      IconButton(
        tooltip: isPinned
            ? LocalizationKeys.unpinField.tr(context)
            : LocalizationKeys.pinField.tr(context),
        onPressed: canToggle
            ? () => provider.toggleIssueFieldPinned(pinFieldKey)
            : null,
        icon: Icon(
          isPinned ? Icons.push_pin : Icons.push_pin_outlined,
          color: isPinned
              ? theme.colorScheme.primary
              : theme.iconTheme.color?.withValues(
                  alpha: canToggle ? 0.78 : 0.35,
                ),
        ),
      ),
    );
  }

  return Row(mainAxisSize: MainAxisSize.min, children: actions);
}
