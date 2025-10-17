// ============================================================================
// 应用常量配置
// ============================================================================

class AppConstants {
  // 私有构造函数，防止实例化
  AppConstants._();

  // ========== 应用信息 ==========
  static const String appName = 'OwO! System Tools';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'A multifunctional System Tools';

  // ========== 开发者信息 ==========
  static const String developerName = 'HanskiJay';
  static const String developerEmail = 'support@owoblog.com';
  static const String githubUsername = 'HanskiJay';
  static const String githubRepo = 'owo-flutter-app-framework';
  static const String instagramName = 'jay.jay2045';

  // ========== 外部链接 ==========
  static const String instagramUrl = 'https://instagram.com/$instagramName';
  static const String owoServiceUrl = 'https://owoblog.com/service';
  static const String githubUrl = 'https://github.com/Tommy131';
  static const String githubRepoUrl =
      'https://github.com/$githubUsername/$githubRepo';
  static const String donationUrl = 'https://owoblog.com/donation';

  // ========== API 配置 ==========
  static const String apiBaseUrl = 'https://owoserver.com/api/v1';
  static const String donationApiEndpoint = '/check-donation/';

  // ========== License ==========
  static const String license = 'MIT License';
  static const String copyright = '© 2025 $developerName. All rights reserved.';
}
