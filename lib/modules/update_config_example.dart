/// 版本更新配置示例
///
/// 开发者可以在modules文件夹或其他位置创建类似的配置文件，
/// 在应用启动时调用UpdateConfig.setCustomConfig()来自定义更新检测配置。
///
/// 使用示例：
/// ```dart
/// import 'package:owo_dashboard/core/services/update_config.dart';
///
/// void setupUpdateConfig() {
///   UpdateConfig.setCustomConfig(
///     UpdateConfig(
///       versionCheckUrl: 'https://your-api.com/version',
///       downloadUrl: 'https://your-website.com/download',
///       timeoutSeconds: 15,
///     ),
///   );
/// }
/// ```
///
/// API响应格式示例：
/// ```json
/// {
///   "version": "1.0.1",
///   "description": "修复了若干bug\n新增了某某功能",
///   "downloadUrl": "https://example.com/download/app-v1.0.1.exe"
/// }
/// ```
///
/// 注意：
/// 1. versionCheckUrl 必须返回JSON格式的版本信息
/// 2. downloadUrl 可以在JSON中提供，也可以在配置中提供作为默认值
/// 3. 如果JSON中的downloadUrl为空，将使用配置中的downloadUrl
/// 4. 版本号格式应为 x.y.z（如：1.0.0, 2.1.3）
library;

import '../core/module_registry/update/update_config.dart';

/// 配置示例1：基础配置
void setupBasicUpdateConfig() {
  UpdateConfig.setCustomConfig(
    const UpdateConfig(
      versionCheckUrl: 'https://api.example.com/app/version',
      timeoutSeconds: 10,
    ),
  );
}

/// 配置示例2：带默认下载地址的配置
void setupUpdateConfigWithDownload() {
  UpdateConfig.setCustomConfig(
    const UpdateConfig(
      versionCheckUrl: 'https://api.example.com/app/version',
      downloadUrl: 'https://example.com/download',
      timeoutSeconds: 15,
    ),
  );
}

/// 配置示例3：GitHub Releases配置
void setupGitHubReleasesConfig() {
  UpdateConfig.setCustomConfig(
    const UpdateConfig(
      versionCheckUrl:
          'https://api.github.com/repos/username/repo/releases/latest',
      timeoutSeconds: 20,
    ),
  );
}
