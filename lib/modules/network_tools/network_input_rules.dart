class NetworkInputRules {
  static final RegExp hostAllowedCharsRegExp = RegExp(r'[0-9A-Za-z\.\-]');
  static final RegExp portRangeAllowedCharsRegExp = RegExp(r'[0-9,\s]');
  static final RegExp siteUrlAllowedCharsRegExp = RegExp(
    r'[0-9A-Za-z:/?&=._#%+\-~]',
  );

  static final RegExp _domainRegExp = RegExp(
    r'^(?=.{1,253}$)(?:[A-Za-z0-9](?:[A-Za-z0-9\-]{0,61}[A-Za-z0-9])?\.)+[A-Za-z]{2,63}$',
  );

  static bool isValidHostTarget(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return false;
    return isValidIpv4(normalized) || isValidDomain(normalized);
  }

  static bool isValidIpv4(String value) {
    final parts = value.split('.');
    if (parts.length != 4) return false;
    for (final part in parts) {
      if (part.isEmpty || part.length > 3) return false;
      if (!RegExp(r'^\d+$').hasMatch(part)) return false;
      final parsed = int.tryParse(part);
      if (parsed == null || parsed < 0 || parsed > 255) return false;
    }
    return true;
  }

  static bool isValidDomain(String value) {
    return _domainRegExp.hasMatch(value);
  }

  static String? validateHostTarget(
    String value, {
    String fieldLabel = '目标主机',
  }) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return '$fieldLabel不能为空';
    }
    if (!isValidHostTarget(normalized)) {
      return '$fieldLabel仅支持 IPv4 地址或有效域名';
    }
    return null;
  }

  static String? validatePositiveInt(
    String value,
    String fieldLabel, {
    int min = 1,
    int? max,
  }) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return '$fieldLabel不能为空';
    }
    final parsed = int.tryParse(normalized);
    if (parsed == null) {
      return '$fieldLabel只能输入数字';
    }
    if (parsed < min || (max != null && parsed > max)) {
      if (max != null) {
        return '$fieldLabel仅支持 $min-$max 的数字';
      }
      return '$fieldLabel必须大于等于 $min';
    }
    return null;
  }

  static String? validatePortList(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return '端口范围不能为空';
    }
    final parts = normalized.split(',');
    if (parts.any((part) => part.trim().isEmpty)) {
      return '端口范围格式无效，请使用英文逗号分隔';
    }
    for (final part in parts) {
      final single = validatePositiveInt(part, '端口', min: 1, max: 65535);
      if (single != null) return single;
    }
    return null;
  }

  static List<int> parsePortList(String value) {
    return value
        .split(',')
        .map((e) => int.parse(e.trim()))
        .toList(growable: false);
  }

  static String? validateSiteUrl(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return '站点地址不能为空';
    }
    final uri = Uri.tryParse(normalized);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return '站点地址格式无效';
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return '站点地址仅支持 http 或 https';
    }
    return null;
  }
}
