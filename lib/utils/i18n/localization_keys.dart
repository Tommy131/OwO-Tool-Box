// ============================================================================
// 国际化键常量
// ============================================================================

class L18nKeys {
  // ========== 通用 ==========
  static const String appTitle = 'app_title';
  static const String ok = 'ok';
  static const String cancel = 'cancel';

  // ========== 导航 ==========
  static const String menu = 'menu';
  static const String home = 'home';
  static const String settings = 'settings';
  static const String about = 'about';
  static const String monitor = 'monitor';

  // ========== 欢迎页 ==========
  static const String welcome = 'welcome';
  static const String welcomeMessage = 'welcome_message';
  static const String welcomeDescription = 'welcome_description';
  static const String exploreFeatures = 'explore_features';

  // ========== 监控页 ==========
  static const String systemMonitorPage = 'system_monitor_page';
  static const String systemMonitoring = 'system_monitoring';

  // ========== 语言设置 ==========
  static const String languageSettings = 'language_settings';
  static const String chinese = 'chinese';
  static const String english = 'english';

  // ========== 主题设置 ==========
  static const String themeSettings = 'theme_settings';
  static const String themeColorSettings = 'theme_color_settings';
  static const String cyberpunkTheme = 'cyberpunk_theme';
  static const String lightTheme = 'light_theme';
  static const String darkTheme = 'dark_theme';
  static const String systemTheme = 'system_theme';
  static const String defaultTheme = 'default_theme';
  static const String techTheme = 'tech_theme';
  static const String natureTheme = 'nature_theme';
  static const String sunsetTheme = 'sunset_theme';
  static const String oceanTheme = 'ocean_theme';

  // ========== 视觉特效 ==========
  static const String visualEffects = 'visual_effects';
  static const String visualEffectsDescription = 'visual_effects_description';
  static const String matrixRainEffect = 'matrix_rain_effect';
  static const String matrixRainDescription = 'matrix_rain_description';
  static const String glowEffect = 'glow_effect';
  static const String glowEffectDescription = 'glow_effect_description';
  static const String scanningLine = 'scanning_line';
  static const String scanningLineDescription = 'scanning_line_description';
  static const String glitchEffect = 'glitch_effect';
  static const String glitchEffectDescription = 'glitch_effect_description';

  // ========== 应用信息 ==========
  static const String appInfo = 'app_info';
  static const String appName = 'app_name';
  static const String appDescription = 'app_description';
  static const String appVersion = 'app_version';
  static const String developerInfo = 'developer_info';
  static const String developerName = 'developer_name';
  static const String contactEmail = 'contact_email';
  static const String flutterVersion = 'flutter_version';
  static const String serviceHomepage = 'service_homepage';
  static const String openSource = 'open_source';
  static const String openSourceDescription = 'open_source_description';
  static const String viewSourceCode = 'view_source_code';
  static const String license = 'license';
  static const String supportDevelopment = 'support_development';
  static const String donationDescription = 'donation_description';
  static const String donateNow = 'donate_now';
  static const String topDonors = 'top_donors';
  static const String cannotOpenUrl = 'cannot_open_url';
  static const String loadFailed = 'load_failed';
  static const String retry = 'retry';
  static const String noDonorsYet = 'no_donors_yet';

  // ========== 用户协议 ==========
  static const String userAgreement = 'user_agreement';
  static const String agreementContent = 'agreement_content';
  static const String github = 'github';

  // ========== 设备信息 ==========
  static const String deviceInfo = 'device_info';
  static const String screenSize = 'screen_size';
  static const String deviceType = 'device_type';
  static const String mobileDevice = 'mobile_device';
  static const String tabletDevice = 'tablet_device';
  static const String desktopDevice = 'desktop_device';
  static const String layoutMode = 'layout_mode';
  static const String adaptiveLayout = 'adaptive_layout';

  // ========== 窗口控制 ==========
  static const String minimize = 'minimize';
  static const String maximize = 'maximize';
  static const String restore = 'restore';
  static const String close = 'close';

  // ========== 设置页（SettingsScreen）==========
  // 设置分类
  static const String commonSettings = 'common_settings';
  static const String hostMonitoringSettings = 'host_monitoring_settings';

  // 列表分组标题
  static const String refreshSettings = 'refresh_settings';
  static const String hostCheckSettings = 'host_check_settings';
  static const String alertSettings = 'alert_settings';
  static const String alertThresholds = 'alert_thresholds';
  static const String notificationSettings = 'notification_settings';

  // 刷新设置
  static const String pollingInterval = 'polling_interval';
  static const String secondsSuffix = 'seconds_suffix';
  static const String refreshIntervalHint = 'refresh_interval_hint';
  static const String refreshIntervalTip = 'refresh_interval_tip';

  // 主机检测设置
  static const String checkTimeout = 'check_timeout';
  static const String timeoutHint = 'timeout_hint';
  static const String hostTimeoutTip = 'host_timeout_tip';
  static const String backgroundCheckInterval = 'background_check_interval';
  static const String minutesSuffix = 'minutes_suffix';
  static const String checkIntervalHint = 'check_interval_hint';
  static const String backgroundCheckTip = 'background_check_tip';

  // 告警设置（开关与说明）
  static const String enableAlerts = 'enable_alerts';
  static const String enableAlertsSubtitle = 'enable_alerts_subtitle';

  // 告警阈值（滑块标签）
  static const String cpuUsage = 'cpu_usage';
  static const String memoryUsage = 'memory_usage';
  static const String diskUsage = 'disk_usage';
  static const String uploadRate = 'upload_rate';
  static const String downloadRate = 'download_rate';
  static const String kbPerSecond = 'kb_per_second';

  // 通知设置（开关与说明）
  static const String notifyOnDisconnect = 'notify_on_disconnect';
  static const String soundEnabled = 'sound_enabled';
  static const String vibrationEnabled = 'vibration_enabled';
  static const String vibrationNote = 'vibration_note';

  // 交互：保存与校验提示、确认弹窗、结果提示
  static const String saveSettings = 'save_settings';
  static const String invalidRefreshInterval = 'invalid_refresh_interval';
  static const String invalidHostCheckTimeout = 'invalid_host_check_timeout';
  static const String invalidHostCheckInterval = 'invalid_host_check_interval';
  static const String longRefreshTitle = 'long_refresh_title';
  static const String longRefreshContent = 'long_refresh_content';
  static const String settingsSaved = 'settings_saved';
}
