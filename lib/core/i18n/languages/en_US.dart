// ============================================================================
// English Translation
// ============================================================================

import '../localization_keys.dart';

class EnUS {
  static const Map<String, String> translations = {
    // ========== Common ==========
    L18nKeys.appTitle: 'OwO! System Tools',
    L18nKeys.ok: 'OK',
    L18nKeys.cancel: 'Cancel',

    // ========== Navigation ==========
    L18nKeys.menu: 'Menu',
    L18nKeys.home: 'Home',
    L18nKeys.settings: 'Settings',
    L18nKeys.about: 'About',
    L18nKeys.monitor: 'Monitor',

    // ========== Welcome Page ==========
    L18nKeys.welcome: 'Welcome',
    L18nKeys.welcomeMessage:
        'This is a fully-featured Flutter application framework',
    L18nKeys.welcomeDescription:
        'Supports multi-platform adaptive layout, perfectly adapted for mobile, tablet and desktop devices',
    L18nKeys.exploreFeatures: 'Explore Features',

    // ========== Language Settings ==========
    L18nKeys.languageSettings: 'Language Settings',
    L18nKeys.selectLanguage: 'Select Language',
    L18nKeys.changingLanguage: 'Changing Language',

    // ========== Settings Main Page ==========
    L18nKeys.adjustTheme: 'Adjust theme mode and color scheme',
    L18nKeys.selectAppLanguage: 'Select application display language',
    L18nKeys.configureHostMonitor: 'Configure host monitoring options',

    // ========== Theme Settings ==========
    L18nKeys.themeMode: 'Theme Mode',
    L18nKeys.changingTheme: 'Changing Theme',
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

    // ========== Host Monitor Settings ==========
    L18nKeys.hostMonitorSettings: 'Host Monitor Settings',
    L18nKeys.refreshSettings: 'Refresh Settings',
    L18nKeys.hostPollingInterval: 'Host Polling Interval',
    L18nKeys.enterRefreshInterval: 'Enter refresh interval (seconds)',
    L18nKeys.seconds: 'seconds',
    L18nKeys.recommendedInterval:
        'Recommended to set between 1-10 seconds, too short may affect performance',
    L18nKeys.hostCheckSettings: 'Host Check Settings',
    L18nKeys.checkTimeout: 'Check Timeout',
    L18nKeys.enterTimeout: 'Enter timeout (seconds)',
    L18nKeys.timeoutDescription:
        'Timeout for checking host online status, recommended 3-10 seconds',
    L18nKeys.backgroundCheckInterval: 'Background Check Interval',
    L18nKeys.enterCheckInterval: 'Enter check interval (minutes)',
    L18nKeys.minutes: 'minutes',
    L18nKeys.checkIntervalDescription:
        'Background silent check interval for host list status, recommended 5-30 minutes',
    L18nKeys.alertSettings: 'Alert Settings',
    L18nKeys.enableAlert: 'Enable Alerts',
    L18nKeys.enableAlertDescription:
        'When enabled, notifications will be sent when resource usage exceeds threshold',
    L18nKeys.alertThreshold: 'Alert Threshold',
    L18nKeys.cpuUsage: 'CPU Usage',
    L18nKeys.memoryUsage: 'Memory Usage',
    L18nKeys.diskUsage: 'Disk Usage',
    L18nKeys.uploadSpeed: 'Upload Speed',
    L18nKeys.downloadSpeed: 'Download Speed',
    L18nKeys.notificationSettings: 'Notification Settings',
    L18nKeys.disconnectNotification: 'Disconnect Notification',
    L18nKeys.soundAlert: 'Sound Alert',
    L18nKeys.vibrationAlert: 'Vibration Alert',
    L18nKeys.vibrationAlertDescription: 'Only effective on mobile devices',
    L18nKeys.save: 'Save',
    L18nKeys.settingsSaved: 'Settings Saved',
    L18nKeys.longRefreshInterval: 'Long Refresh Interval',
    L18nKeys.longRefreshIntervalWarning:
        'You have set the refresh interval to {interval} seconds, which may result in delayed data updates. Continue?',
    L18nKeys.invalidRefreshInterval:
        'Please enter a valid refresh interval (at least 1 second)',
    L18nKeys.invalidTimeout:
        'Please enter a valid check timeout (1-60 seconds)',
    L18nKeys.invalidCheckInterval:
        'Please enter a valid check interval (1-1440 minutes)',

    // ========== Visual Effects ==========
    L18nKeys.visualEffects: 'Visual Effects',
    L18nKeys.visualEffectsDescription: 'Exclusive effects for Cyberpunk theme',
    L18nKeys.matrixRainEffect: 'Matrix Rain Effect',
    L18nKeys.matrixRainDescription: 'Matrix-style background animation',
    L18nKeys.glowEffect: 'Glow Effect',
    L18nKeys.glowEffectDescription: 'Button and card glow effects',
    L18nKeys.scanningLine: 'Scanning Line',
    L18nKeys.scanningLineDescription: 'Screen scanning line animation',
    L18nKeys.glitchEffect: 'Glitch Art',
    L18nKeys.glitchEffectDescription: 'Digital glitch style effects',

    // ========== App Information ==========
    L18nKeys.appInfo: 'App Information',
    L18nKeys.appName: 'OwO! System Tools',
    L18nKeys.appDescription:
        'A powerful cross-platform system tools collection, supporting host monitoring, performance analysis and more',
    L18nKeys.appVersion: 'Version',
    L18nKeys.developerInfo: 'Developer Information',
    L18nKeys.developerName: 'Developer',
    L18nKeys.contactEmail: 'Contact Email',
    L18nKeys.flutterVersion: 'Flutter Version',
    L18nKeys.serviceHomepage: 'Service Homepage',
    L18nKeys.openSource: 'Open Source Project',
    L18nKeys.openSourceDescription:
        'This project uses an open source license, contributions are welcome',
    L18nKeys.viewSourceCode: 'View Source Code',
    L18nKeys.license: 'License',
    L18nKeys.supportDevelopment: 'Support Development',
    L18nKeys.donationDescription:
        'If you find this project helpful, please consider supporting development',
    L18nKeys.donateNow: 'Donate Now',
    L18nKeys.topDonors: 'Top Donors',
    L18nKeys.cannotOpenUrl: 'Cannot open URL',
    L18nKeys.loadFailed: 'Load Failed',
    L18nKeys.retry: 'Retry',
    L18nKeys.noDonorsYet: 'No donation records yet',

    // ========== Tech Stack Card ==========
    L18nKeys.techStack: 'Tech Stack',
    L18nKeys.flutter: 'Flutter',
    L18nKeys.flutterDescription: 'Cross-platform UI framework',
    L18nKeys.goLang: 'Go Language',
    L18nKeys.goLangDescription: 'High-performance backend service',
    L18nKeys.tcpIp: 'TCP/IP',
    L18nKeys.tcpIpDescription: 'Network communication protocol',
    L18nKeys.materialDesign: 'Material Design',
    L18nKeys.materialDesignDescription: 'Modern design language',

    // ========== User Agreement ==========
    L18nKeys.userAgreement: 'User Agreement',
    L18nKeys.agreementContent:
        'This application framework is for learning and development use only.\nPlease comply with relevant laws and regulations.\nSupports multi-platform use on mobile phones, tablets, and PCs.\nThe developer reserves the right of final interpretation.\nThis project follows the MIT open-source license.\nPlease read the relevant documentation carefully before use.\nThe developer reserves the right of final interpretation.',
    L18nKeys.github: 'GitHub',

    // ========== Device Information ==========
    L18nKeys.deviceInfo: 'Device Information',
    L18nKeys.screenSize: 'Screen Size',
    L18nKeys.deviceType: 'Device Type',
    L18nKeys.mobileDevice: 'Mobile',
    L18nKeys.tabletDevice: 'Tablet',
    L18nKeys.desktopDevice: 'Desktop',
    L18nKeys.layoutMode: 'Layout Mode',
    L18nKeys.adaptiveLayout: 'Adaptive Layout',

    // ========== Window Control ==========
    L18nKeys.minimize: 'Minimize',
    L18nKeys.maximize: 'Maximize',
    L18nKeys.restore: 'Restore',
    L18nKeys.close: 'Close',

    // ========== Host Edit Page ==========
    L18nKeys.editHost: 'Edit Host',
    L18nKeys.addHost: 'Add Host',
    L18nKeys.hostName: 'Host Name',
    L18nKeys.hostNameHint: 'Please enter host name',
    L18nKeys.pleaseEnterHostName: 'Please enter host name',
    L18nKeys.hostNameMinLength: 'Host name must be at least 2 characters',
    L18nKeys.hostAddress: 'Host Address',
    L18nKeys.hostAddressHint: 'e.g.: 192.168.1.100',
    L18nKeys.pleaseEnterHostAddress: 'Please enter host address',
    L18nKeys.hostAddressNoSpaces: 'Host address cannot contain spaces',
    L18nKeys.port: 'Port',
    L18nKeys.portHint: 'Please enter port number',
    L18nKeys.pleaseEnterPort: 'Please enter port number',
    L18nKeys.portRangeError: 'Port number must be between 1-65535',
    L18nKeys.password: 'Password',
    L18nKeys.pleaseEnterPassword: 'Please enter password',
    L18nKeys.passwordMinLength: 'Password must be at least 6 characters',
    L18nKeys.testConnection: 'Test Connection',
    L18nKeys.saveChanges: 'Save Changes',
    L18nKeys.requiredFieldNote: '* Required field',
    L18nKeys.hostUpdated: 'Host information updated',
    L18nKeys.hostAdded: 'Host added successfully',
    L18nKeys.saveFailed: 'Save failed',
    L18nKeys.testingConnection: 'Testing connection',
    L18nKeys.connectionSuccess: 'Connection successful',
    L18nKeys.connectionFailed: 'Connection failed',
    L18nKeys.connectionSuccessMessage:
        'Host connection is normal, configuration is valid',
    L18nKeys.connectionFailedMessage:
        'Unable to connect to host, please check configuration',
    L18nKeys.connectionTestError: 'Connection test error',

    // ========== Alert History Page ==========
    L18nKeys.alertHistory: 'Alert History',
    L18nKeys.clearHistory: 'Clear History',
    L18nKeys.noAlertRecords: 'No alert records',
    L18nKeys.acknowledge: 'Acknowledge',
    L18nKeys.alertAcknowledged: 'Alert acknowledged',
    L18nKeys.confirmClearAlertHistory:
        'Are you sure you want to clear all alert history records?',
    L18nKeys.clear: 'Clear',
    L18nKeys.historyCleared: 'History cleared',

    // ========== Host Monitor Page ==========
    L18nKeys.hostMonitor: 'Host Monitor',
    L18nKeys.loadHostListFailed: 'Failed to load host list',
    L18nKeys.loadGeoInfoFailed: 'Failed to load geolocation information',
    L18nKeys.hostStatusRefreshed: 'Host status refreshed',
    L18nKeys.refreshFailed: 'Refresh failed',
    L18nKeys.refreshHostStatus: 'Refresh host status',
    L18nKeys.forceDisconnectMessage: 'Host monitoring forcibly disconnected!',
    L18nKeys.safeDisconnectMessage: 'Host monitoring safely disconnected.',
    L18nKeys.disconnect: 'Disconnect',
    L18nKeys.loadingGeoInfo: 'Loading IP geolocation information...',
    L18nKeys.loadingHostList: 'Loading host list...',
    L18nKeys.connecting: 'Connecting...',
    L18nKeys.pleaseWait: 'Please wait',
    L18nKeys.noSavedHosts: 'No saved hosts yet',
    L18nKeys.clickToAddFirstHost:
        'Click the button at the bottom right to add your first host',
    L18nKeys.addNow: 'Add Now',
    L18nKeys.total: 'Total',
    L18nKeys.online: 'Online',
    L18nKeys.offline: 'Offline',
    L18nKeys.error: 'Error',
    L18nKeys.confirmDelete: 'Confirm Delete',
    L18nKeys.confirmDeleteHostPart1: 'Are you sure you want to delete host',
    L18nKeys.confirmDeleteHostPart2:
        '?\n\nThis operation will also delete all alert records for this host.',
    L18nKeys.delete: 'Delete',
    L18nKeys.hostDeleted: 'Host deleted',
    L18nKeys.deleteFailed: 'Delete failed',
    L18nKeys.timeout: 'Timeout',

    // ========== Dialogs ==========
    L18nKeys.connectionTimeout: 'Connection Timeout',
    L18nKeys.connectionTimeoutMessage:
        'Unable to connect to host "{hostName}"\n\nPlease check:\n• Server is running\n• Network connection is stable\n• Firewall settings',
    L18nKeys.tokenValidationFailed: 'Token Validation Failed',
    L18nKeys.tokenValidationFailedMessage:
        'Access token for host "{hostName}" is incorrect',

    // ========== Host Details Page ==========
    L18nKeys.waitingSystemData: 'Waiting for system data',
    L18nKeys.connectedGettingSystemInfo:
        'Connected, getting system information...',
    L18nKeys.unnamedHost: 'Unnamed Host',
    L18nKeys.connected: 'Connected',
    L18nKeys.cpuUsageTrend: 'CPU Usage Trend',
    L18nKeys.memoryUsageTrend: 'Memory Usage Trend',
    L18nKeys.diskUsageTrend: 'Disk Usage Trend',
    L18nKeys.uploadSpeedLabel: 'Upload Speed',
    L18nKeys.downloadSpeedLabel: 'Download Speed',
    L18nKeys.load1min: '1-minute Load',
    L18nKeys.load5min: '5-minute Load',
    L18nKeys.load15min: '15-minute Load',
    L18nKeys.cpuCoreUsage: 'CPU Core Usage',
    L18nKeys.systemInfo: 'System Information',
    L18nKeys.processor: 'Processor',
    L18nKeys.processorCores: 'Processor Cores',
    L18nKeys.coresUnit: 'cores',
    L18nKeys.processorFrequency: 'Processor Frequency',
    L18nKeys.processCount: 'Process Count',
    L18nKeys.countUnit: '',
    L18nKeys.systemLoad: 'System Load',
    L18nKeys.systemArchitecture: 'System Architecture',
    L18nKeys.operatingSystem: 'Operating System',
    L18nKeys.kernelVersion: 'Kernel Version',
    L18nKeys.hostname: 'Hostname',
    L18nKeys.uptime: 'Uptime',
    L18nKeys.memoryDetails: 'Memory Details',
    L18nKeys.usageRate: 'Usage Rate',
    L18nKeys.totalMemory: 'Total Memory',
    L18nKeys.usedMemory: 'Used Memory',
    L18nKeys.availableMemory: 'Available Memory',
    L18nKeys.diskDetails: 'Disk Details',
    L18nKeys.used: 'Used',
    L18nKeys.networkDetails: 'Network Details',
    L18nKeys.upload: 'Upload',
    L18nKeys.download: 'Download',
    L18nKeys.bytesSent: 'Bytes Sent',
    L18nKeys.bytesReceived: 'Bytes Received',
  };
}
