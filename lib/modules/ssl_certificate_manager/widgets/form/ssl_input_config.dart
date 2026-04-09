import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/ssl_models.dart';
import '../../providers/ssl_certificate_manager_provider.dart';

/// Configuration bundle for a single text input field.
class SslInputConfig {
  const SslInputConfig({
    required this.keyboardType,
    this.inputFormatters = const <TextInputFormatter>[],
    this.obscureText = false,
    this.textCapitalization = TextCapitalization.none,
    this.suffix,
  });

  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final bool obscureText;
  final TextCapitalization textCapitalization;
  final Widget? suffix;
}

/// A [TextInputFormatter] that upper-cases alphabetic input and strips all
/// non-alpha characters.
class UpperCaseAlphaTextFormatter extends TextInputFormatter {
  const UpperCaseAlphaTextFormatter({required this.maxLength});

  final int maxLength;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final normalized = newValue.text
        .replaceAll(RegExp(r'[^A-Za-z]'), '')
        .toUpperCase();
    final truncated = normalized.characters.take(maxLength).toString();
    return TextEditingValue(
      text: truncated,
      selection: TextSelection.collapsed(offset: truncated.length),
    );
  }
}

/// Resolves the appropriate [SslInputConfig] for a given controller or
/// alt-name type.
class SslInputConfigResolver {
  SslInputConfigResolver._();

  /// Returns the [SslInputConfig] that matches the given [controller] within
  /// the [provider].
  ///
  /// [obscureRootCaPassword] and [obscureChallengePassword] control whether
  /// the corresponding password fields are shown in plain text.
  /// [onToggleRootCaPassword] and [onToggleChallengePassword] are callbacks
  /// for the visibility toggle buttons.
  static SslInputConfig resolve({
    required TextEditingController controller,
    required SslCertificateManagerProvider provider,
    bool obscureRootCaPassword = true,
    bool obscureChallengePassword = true,
    VoidCallback? onToggleRootCaPassword,
    VoidCallback? onToggleChallengePassword,
  }) {
    if (identical(controller, provider.domainController) ||
        identical(controller, provider.ocspDomainController)) {
      return SslInputConfig(
        keyboardType: TextInputType.url,
        inputFormatters: [
          LengthLimitingTextInputFormatter(255),
          FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9.*-]')),
        ],
      );
    }
    if (identical(controller, provider.commonNameController)) {
      return SslInputConfig(
        keyboardType: TextInputType.text,
        inputFormatters: [
          LengthLimitingTextInputFormatter(255),
          FilteringTextInputFormatter.allow(
            RegExp(r"[A-Za-z0-9\u4e00-\u9fff .,_\-()/#@:&]+"),
          ),
        ],
      );
    }
    if (identical(controller, provider.countryNameController)) {
      return const SslInputConfig(
        keyboardType: TextInputType.text,
        textCapitalization: TextCapitalization.characters,
        inputFormatters: [UpperCaseAlphaTextFormatter(maxLength: 2)],
      );
    }
    if (identical(controller, provider.emailAddressController)) {
      return SslInputConfig(
        keyboardType: TextInputType.emailAddress,
        inputFormatters: [
          LengthLimitingTextInputFormatter(254),
          FilteringTextInputFormatter.allow(RegExp(r"[A-Za-z0-9@._%+\-]")),
        ],
      );
    }
    if (identical(controller, provider.validDaysController)) {
      return SslInputConfig(
        keyboardType: TextInputType.number,
        inputFormatters: [
          LengthLimitingTextInputFormatter(5),
          FilteringTextInputFormatter.digitsOnly,
        ],
      );
    }
    if (identical(controller, provider.storagePathController) ||
        identical(controller, provider.rootCACertPathController) ||
        identical(controller, provider.rootCAKeyPathController)) {
      return SslInputConfig(
        keyboardType: TextInputType.text,
        inputFormatters: [
          LengthLimitingTextInputFormatter(512),
          FilteringTextInputFormatter.allow(
            RegExp(r"[A-Za-z0-9\u4e00-\u9fff _.:/\\()[\]-]"),
          ),
        ],
      );
    }
    if (identical(controller, provider.ocspCaIssuersUrlController) ||
        identical(controller, provider.ocspResponderUrlController) ||
        identical(controller, provider.crlDistributionUrlController)) {
      return SslInputConfig(
        keyboardType: TextInputType.url,
        inputFormatters: [
          LengthLimitingTextInputFormatter(512),
          FilteringTextInputFormatter.allow(
            RegExp(r"[A-Za-z0-9\-._~:/?#\[\]@!$&'()*+,;=%]"),
          ),
        ],
      );
    }
    if (identical(controller, provider.rootCAPasswordController)) {
      return SslInputConfig(
        keyboardType: TextInputType.visiblePassword,
        obscureText: obscureRootCaPassword,
        suffix: onToggleRootCaPassword != null
            ? IconButton(
                onPressed: onToggleRootCaPassword,
                icon: Icon(
                  obscureRootCaPassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
              )
            : null,
        inputFormatters: [
          LengthLimitingTextInputFormatter(128),
          FilteringTextInputFormatter.allow(
            RegExp(
              "[A-Za-z0-9!@#\\\$%\\^&*()_+\\-=\\[\\]{};':\",./<>?\\\\|`~]",
            ),
          ),
        ],
      );
    }
    if (identical(controller, provider.challengePasswordController)) {
      return SslInputConfig(
        keyboardType: TextInputType.visiblePassword,
        obscureText: obscureChallengePassword,
        suffix: onToggleChallengePassword != null
            ? IconButton(
                onPressed: onToggleChallengePassword,
                icon: Icon(
                  obscureChallengePassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
              )
            : null,
        inputFormatters: [
          LengthLimitingTextInputFormatter(128),
          FilteringTextInputFormatter.allow(
            RegExp(
              "[A-Za-z0-9!@#\\\$%\\^&*()_+\\-=\\[\\]{};':\",./<>?\\\\|`~]",
            ),
          ),
        ],
      );
    }
    if (identical(controller, provider.rootCANameController)) {
      return SslInputConfig(
        keyboardType: TextInputType.text,
        inputFormatters: [
          LengthLimitingTextInputFormatter(80),
          FilteringTextInputFormatter.allow(
            RegExp(r"[A-Za-z0-9\u4e00-\u9fff ._-]"),
          ),
        ],
      );
    }
    if (identical(controller, provider.revokeReasonController)) {
      return SslInputConfig(
        keyboardType: TextInputType.text,
        inputFormatters: [
          LengthLimitingTextInputFormatter(120),
          FilteringTextInputFormatter.allow(
            RegExp(r"[A-Za-z0-9\u4e00-\u9fff .,_()\-:/]"),
          ),
        ],
      );
    }
    return SslInputConfig(
      keyboardType: TextInputType.text,
      inputFormatters: [LengthLimitingTextInputFormatter(120)],
    );
  }

  /// Returns the [SslInputConfig] for an alt-name entry based on its [type].
  static SslInputConfig altNameConfig(AltNameType type) {
    if (type == AltNameType.ip) {
      return SslInputConfig(
        keyboardType: TextInputType.text,
        inputFormatters: [
          LengthLimitingTextInputFormatter(64),
          FilteringTextInputFormatter.allow(RegExp(r'[A-Fa-f0-9:.]')),
        ],
      );
    }
    return SslInputConfig(
      keyboardType: TextInputType.url,
      inputFormatters: [
        LengthLimitingTextInputFormatter(255),
        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9.*-]')),
      ],
    );
  }
}
