class AppSettings {
  final String certificatePath;
  final String caName;
  final bool encryptCaByDefault;
  final String? defaultCaPassword;
  final String opensslConfigPath;

  AppSettings({
    required this.certificatePath,
    this.caName = 'MyRootCA',
    this.encryptCaByDefault = false,
    this.defaultCaPassword,
    required this.opensslConfigPath,
  });

  Map<String, dynamic> toJson() {
    return {
      'certificatePath': certificatePath,
      'caName': caName,
      'encryptCaByDefault': encryptCaByDefault,
      'defaultCaPassword': defaultCaPassword,
      'opensslConfigPath': opensslConfigPath,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      certificatePath: json['certificatePath'],
      caName: json['caName'] ?? 'MyRootCA',
      encryptCaByDefault: json['encryptCaByDefault'] ?? false,
      defaultCaPassword: json['defaultCaPassword'],
      opensslConfigPath: json['opensslConfigPath'],
    );
  }

  AppSettings copyWith({
    String? certificatePath,
    String? caName,
    bool? encryptCaByDefault,
    String? defaultCaPassword,
    String? opensslConfigPath,
    String? locale,
    bool? organizeByType,
  }) {
    return AppSettings(
      certificatePath: certificatePath ?? this.certificatePath,
      caName: caName ?? this.caName,
      encryptCaByDefault: encryptCaByDefault ?? this.encryptCaByDefault,
      defaultCaPassword: defaultCaPassword ?? this.defaultCaPassword,
      opensslConfigPath: opensslConfigPath ?? this.opensslConfigPath,
    );
  }

  // 获取按类型分类的证书路径
  String getCertificatePathByType(String type) {
    return '$certificatePath/$type';
  }
}
