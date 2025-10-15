// ============================================================================
// English Translation
// ============================================================================

import '../localization_keys.dart';

class EnUS {
  static const Map<String, String> translations = {
    // ========== General ==========
    L18nKeys.appTitle: 'OwO! System Tools',
    L18nKeys.ok: 'OK',
    L18nKeys.cancel: 'Cancel',

    // ========== Navigation ==========
    L18nKeys.menu: 'Menu',
    L18nKeys.home: 'Home',
    L18nKeys.settings: 'Settings',
    L18nKeys.about: 'About',

    // ========== Welcome Page ==========
    L18nKeys.welcome: 'Welcome',
    L18nKeys.welcomeMessage:
        'A multifunctional system assistant developed by HanskiJay.',
    L18nKeys.welcomeDescription:
        'Supports adaptive layouts across multiple platforms — seamlessly fits phones, tablets, and desktops.',
    L18nKeys.exploreFeatures: 'Explore Features',

    // ========== Language Settings ==========
    L18nKeys.languageSettings: 'Language Settings',

    // ========== Theme Settings ==========
    L18nKeys.themeSettings: 'Theme Settings',
    L18nKeys.themeColorSettings: 'Theme Colors',
    L18nKeys.cyberpunkTheme: 'Cyberpunk Theme',
    L18nKeys.lightTheme: 'Light Theme',
    L18nKeys.darkTheme: 'Dark Theme',
    L18nKeys.systemTheme: 'Follow System',
    L18nKeys.defaultTheme: 'Default Theme',
    L18nKeys.techTheme: 'Tech Theme',
    L18nKeys.natureTheme: 'Nature Theme',
    L18nKeys.sunsetTheme: 'Sunset Theme',
    L18nKeys.oceanTheme: 'Ocean Theme',

    // ========== Visual Effects ==========
    L18nKeys.visualEffects: 'Visual Effects',
    L18nKeys.visualEffectsDescription:
        'Exclusive effects for the Cyberpunk theme',
    L18nKeys.matrixRainEffect: 'Matrix Rain Effect',
    L18nKeys.matrixRainDescription: 'Matrix-style code rain animation',
    L18nKeys.glowEffect: 'Glow Effect',
    L18nKeys.glowEffectDescription: 'Neon glow for header characters',
    L18nKeys.scanningLine: 'Scanning Line',
    L18nKeys.scanningLineDescription: 'Cyberpunk scanning animation',
    L18nKeys.glitchEffect: 'Glitch Effect',
    L18nKeys.glitchEffectDescription: 'Random pixel distortion',

    // ========== App Information ==========
    L18nKeys.appInfo: 'App Information',
    L18nKeys.appName: 'Application Name',
    L18nKeys.appDescription: 'Application Description',
    L18nKeys.appVersion: 'Version',
    L18nKeys.developerInfo: 'Developer Information',
    L18nKeys.developerName: 'Developer',
    L18nKeys.contactEmail: 'Contact Email',
    L18nKeys.flutterVersion: 'Flutter Version',
    L18nKeys.serviceHomepage: 'Service Homepage',
    L18nKeys.openSource: 'Open Source Info',
    L18nKeys.openSourceDescription:
        'This project is licensed under the MIT license. Contributions and suggestions are welcome.',
    L18nKeys.viewSourceCode: 'View Source Code',
    L18nKeys.license: 'License',
    L18nKeys.supportDevelopment: 'Support Development',
    L18nKeys.donationDescription:
        'Your donation helps keep the project growing.',
    L18nKeys.donateNow: 'Donate Now',
    L18nKeys.topDonors: 'Top 5 Donors',
    L18nKeys.cannotOpenUrl: 'Cannot open link',
    L18nKeys.loadFailed: 'Load failed',
    L18nKeys.retry: 'Retry',
    L18nKeys.noDonorsYet: 'No donations yet',

    // ========== User Agreement ==========
    L18nKeys.userAgreement: 'User Agreement',
    L18nKeys.agreementContent:
        '1. This app framework is for learning and development purposes only.\n'
            '2. Please comply with applicable laws and regulations.\n'
            '3. Supports mobile, tablet, and PC multi-platform.\n'
            '4. The developer reserves the final interpretation right.\n'
            '5. Licensed under the MIT open-source license.\n'
            '6. Please read the documentation carefully before use.\n'
            '7. The developer reserves the final interpretation right.',
    L18nKeys.github: 'GitHub',

    // ========== Device Information ==========
    L18nKeys.deviceInfo: 'Device Information',
    L18nKeys.screenSize: 'Screen Size',
    L18nKeys.deviceType: 'Device Type',
    L18nKeys.mobileDevice: 'Mobile Device',
    L18nKeys.tabletDevice: 'Tablet Device',
    L18nKeys.desktopDevice: 'Desktop Device',
    L18nKeys.layoutMode: 'Layout Mode',
    L18nKeys.adaptiveLayout: 'Adaptive Layout',

    // ========== Window Controls ==========
    L18nKeys.minimize: 'Minimize',
    L18nKeys.maximize: 'Maximize',
    L18nKeys.restore: 'Restore',
    L18nKeys.close: 'Close',

    // ========== Settings Page (SettingsScreen) ==========
    // Settings Categories
    L18nKeys.commonSettings: 'Common Settings',
    L18nKeys.hostMonitoringSettings: 'Host Monitoring Settings',

    // Section Titles
    L18nKeys.refreshSettings: 'Refresh Settings',
    L18nKeys.hostCheckSettings: 'Host Check Settings',
    L18nKeys.alertSettings: 'Alert Settings',
    L18nKeys.alertThresholds: 'Alert Thresholds',
    L18nKeys.notificationSettings: 'Notification Settings',

    // Refresh Settings
    L18nKeys.pollingInterval: 'Host Polling Interval',
    L18nKeys.secondsSuffix: 'sec',
    L18nKeys.refreshIntervalHint: 'Enter refresh interval (seconds)',
    L18nKeys.refreshIntervalTip:
        'Recommended between 1–10 seconds; too short may affect performance.',

    // Host Check Settings
    L18nKeys.checkTimeout: 'Check Timeout',
    L18nKeys.timeoutHint: 'Enter timeout (seconds)',
    L18nKeys.hostTimeoutTip:
        'Recommended timeout for host status check: 3–10 seconds.',
    L18nKeys.backgroundCheckInterval: 'Background Check Interval',
    L18nKeys.minutesSuffix: 'min',
    L18nKeys.checkIntervalHint: 'Enter check interval (minutes)',
    L18nKeys.backgroundCheckTip:
        'Recommended silent host check interval: 5–30 minutes.',

    // Alert Settings (main switch)
    L18nKeys.enableAlerts: 'Enable Alerts',
    L18nKeys.enableAlertsSubtitle:
        'Enable notifications when resource usage exceeds thresholds.',

    // Alert Thresholds (sliders)
    L18nKeys.cpuUsage: 'CPU Usage',
    L18nKeys.memoryUsage: 'Memory Usage',
    L18nKeys.diskUsage: 'Disk Usage',
    L18nKeys.uploadRate: 'Upload Speed',
    L18nKeys.downloadRate: 'Download Speed',
    L18nKeys.kbPerSecond: ' KB/s',

    // Notification Settings
    L18nKeys.notifyOnDisconnect: 'Disconnect Notification',
    L18nKeys.soundEnabled: 'Sound Alert',
    L18nKeys.vibrationEnabled: 'Vibration Alert',
    L18nKeys.vibrationNote: 'Applies to mobile devices only',

    // Interaction: Save / Validation / Dialogs / Feedback
    L18nKeys.saveSettings: 'Save Settings',
    L18nKeys.invalidRefreshInterval:
        'Please enter a valid refresh interval (minimum 1 second).',
    L18nKeys.invalidHostCheckTimeout:
        'Please enter a valid timeout (1–60 seconds).',
    L18nKeys.invalidHostCheckInterval:
        'Please enter a valid interval (1–1440 minutes).',
    L18nKeys.longRefreshTitle: 'Long Refresh Interval',
    // Placeholder {seconds} will be replaced with intervalSeconds
    L18nKeys.longRefreshContent:
        'You set the refresh interval to {seconds} seconds. This may cause delayed updates. Continue?',
    L18nKeys.settingsSaved: 'Settings saved successfully',
  };
}
