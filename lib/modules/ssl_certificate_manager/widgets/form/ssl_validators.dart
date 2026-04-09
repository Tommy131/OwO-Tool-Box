import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/services/localization_service.dart';
import '../../localization/localization_keys.dart';
import '../../models/ssl_models.dart';
import '../../providers/ssl_certificate_manager_provider.dart';

/// Pure validation helpers for SSL certificate form fields.
class SslValidators {
  SslValidators._();

  static bool isValidEmail(String value) {
    return RegExp(
      r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)+$",
    ).hasMatch(value);
  }

  static bool isValidHttpUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return false;
    }
    if (uri.host.isEmpty || value.contains(' ')) {
      return false;
    }
    if (!isValidDomainOrIp(uri.host)) {
      return false;
    }
    final port = uri.hasPort ? uri.port : null;
    if (port != null && (port < 1 || port > 65535)) {
      return false;
    }
    return true;
  }

  static bool isValidIp(String value) {
    return InternetAddress.tryParse(value) != null;
  }

  static bool isValidDomainOrIp(String value, {bool allowWildcard = false}) {
    return isValidIp(value) ||
        isValidDnsName(value, allowWildcard: allowWildcard);
  }

  static bool isValidDnsName(String value, {bool allowWildcard = false}) {
    var candidate = value.trim();
    if (candidate.isEmpty || candidate.length > 253) {
      return false;
    }
    if (candidate.endsWith('.')) {
      candidate = candidate.substring(0, candidate.length - 1);
    }
    if (allowWildcard && candidate.startsWith('*.')) {
      candidate = candidate.substring(2);
    }
    final labels = candidate.split('.');
    if (labels.length < 2) {
      return false;
    }
    for (final label in labels) {
      if (label.isEmpty ||
          label.length > 63 ||
          label.startsWith('-') ||
          label.endsWith('-') ||
          !RegExp(r'^[A-Za-z0-9-]+$').hasMatch(label)) {
        return false;
      }
    }
    return true;
  }

  /// Returns a localised error string for the given [controller], or `null` if
  /// the current value is valid. [provider] is needed to identify which field
  /// the controller belongs to.
  static String? validationErrorForController({
    required TextEditingController controller,
    required SslCertificateManagerProvider provider,
    required BuildContext context,
  }) {
    final value = controller.text.trim();
    if (value.isEmpty) {
      return null;
    }

    if (identical(controller, provider.domainController)) {
      return isValidDomainOrIp(value, allowWildcard: true)
          ? null
          : LocalizationKeys.validationInvalidDomainOrIp.tr(context);
    }

    if (identical(controller, provider.ocspDomainController)) {
      return isValidDomainOrIp(value)
          ? null
          : LocalizationKeys.validationInvalidDomainOrIp.tr(context);
    }

    if (identical(controller, provider.emailAddressController)) {
      return isValidEmail(value)
          ? null
          : LocalizationKeys.validationInvalidEmail.tr(context);
    }

    if (identical(controller, provider.countryNameController)) {
      return RegExp(r'^[A-Z]{2}$').hasMatch(value)
          ? null
          : LocalizationKeys.validationInvalidCountryCode.tr(context);
    }

    if (identical(controller, provider.validDaysController)) {
      final days = int.tryParse(value);
      return days != null && days > 0
          ? null
          : LocalizationKeys.validationValidDays.tr(context);
    }

    if (identical(controller, provider.ocspCaIssuersUrlController) ||
        identical(controller, provider.ocspResponderUrlController) ||
        identical(controller, provider.crlDistributionUrlController)) {
      return isValidHttpUrl(value)
          ? null
          : LocalizationKeys.validationInvalidUrl.tr(context);
    }

    return null;
  }

  /// Returns a localised error string for an alt-name entry, or `null` when
  /// valid.
  static String? validationErrorForAltName({
    required AltNameType type,
    required String value,
    required BuildContext context,
  }) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    if (type == AltNameType.ip) {
      return isValidIp(trimmed)
          ? null
          : LocalizationKeys.validationInvalidIp.tr(context);
    }
    return isValidDnsName(trimmed, allowWildcard: true)
        ? null
        : LocalizationKeys.validationInvalidDomain.tr(context);
  }
}
