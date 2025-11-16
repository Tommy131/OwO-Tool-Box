// ============================================================================
// English (United States) Translation
// ============================================================================

import '../localization_keys.dart';

class EnUS {
  static const Map<String, String> translations = {
    // ========== General ==========
    L18nKeys.appTitle: 'OwO! Tool Box',
    L18nKeys.ok: 'OK',
    L18nKeys.cancel: 'Cancel',

    // ========== Navigation ==========
    L18nKeys.menu: 'Menu',
    L18nKeys.home: 'Home',
    L18nKeys.settings: 'Settings',
    L18nKeys.about: 'About',
    L18nKeys.monitor: 'Monitor',
    L18nKeys.ssl: 'SSL Certificate Manager',

    // ========== Welcome Page ==========
    L18nKeys.welcome: 'Welcome',
    L18nKeys.welcomeMessage:
        'A powerful cross-platform system tools suite supporting host monitoring, performance analysis and more',
    L18nKeys.welcomeDescription:
        'Supports multi-platform adaptive layouts, perfectly adapted for mobile, tablet, and desktop devices',
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
    L18nKeys.systemTheme: 'System Default',
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
        'Recommended range: 1-10 seconds. Too short may affect performance',
    L18nKeys.hostCheckSettings: 'Host Check Settings',
    L18nKeys.checkTimeout: 'Check Timeout',
    L18nKeys.enterTimeout: 'Enter timeout (seconds)',
    L18nKeys.timeoutDescription:
        'Timeout for checking host online status, recommended 3-10 seconds',
    L18nKeys.backgroundCheckInterval: 'Background Check Interval',
    L18nKeys.enterCheckInterval: 'Enter check interval (minutes)',
    L18nKeys.minutes: 'minutes',
    L18nKeys.checkIntervalDescription:
        'Interval for background silent checking of host list status, recommended 5-30 minutes',
    L18nKeys.alertSettings: 'Alert Settings',
    L18nKeys.enableAlert: 'Enable Alerts',
    L18nKeys.enableAlertDescription:
        'Send notifications when resource usage exceeds thresholds',
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
        'You have set the refresh interval to {interval} seconds, which may cause data updates to be delayed. Continue?',
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
    L18nKeys.glitchEffect: 'Glitch Effect',
    L18nKeys.glitchEffectDescription: 'Digital glitch style effects',

    // ========== App Info ==========
    L18nKeys.appInfo: 'App Info',
    L18nKeys.appName: 'App Name',
    L18nKeys.appDescription: 'App Description',
    L18nKeys.appVersion: 'Version',
    L18nKeys.developerInfo: 'Developer Info',
    L18nKeys.developerName: 'Developer',
    L18nKeys.contactEmail: 'Contact Email',
    L18nKeys.flutterVersion: 'Flutter Version',
    L18nKeys.serviceHomepage: 'Service Homepage',
    L18nKeys.openSource: 'Open Source',
    L18nKeys.openSourceDescription:
        'This project is open source licensed. Contributions welcome',
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

    // ========== Tech Stack Cards ==========
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
        '1. This application framework is for learning and development use only\n2. Please comply with relevant laws and regulations\n3. Supports mobile, tablet, and PC platforms\n4. Developer reserves all rights\n5. This project follows the MIT open source license\n6. Please read the documentation carefully before use\n7. Developer reserves the right of final interpretation',
    L18nKeys.github: 'GitHub',

    // ========== Device Info ==========
    L18nKeys.deviceInfo: 'Device Info',
    L18nKeys.screenSize: 'Screen Size',
    L18nKeys.deviceType: 'Device Type',
    L18nKeys.mobileDevice: 'Mobile',
    L18nKeys.tabletDevice: 'Tablet',
    L18nKeys.desktopDevice: 'Desktop',
    L18nKeys.layoutMode: 'Layout Mode',
    L18nKeys.adaptiveLayout: 'Adaptive Layout',

    // ========== Window Controls ==========
    L18nKeys.minimize: 'Minimize',
    L18nKeys.maximize: 'Maximize',
    L18nKeys.restore: 'Restore',
    L18nKeys.close: 'Close',

    // ========== Host Edit Page ==========
    L18nKeys.editHost: 'Edit Host',
    L18nKeys.addHost: 'Add Host',
    L18nKeys.hostName: 'Host Name',
    L18nKeys.hostNameHint: 'Enter host name',
    L18nKeys.pleaseEnterHostName: 'Please enter host name',
    L18nKeys.hostNameMinLength: 'Host name must be at least 2 characters',
    L18nKeys.hostAddress: 'Host Address',
    L18nKeys.hostAddressHint: 'e.g., 192.168.1.100',
    L18nKeys.pleaseEnterHostAddress: 'Please enter host address',
    L18nKeys.hostAddressNoSpaces: 'Host address cannot contain spaces',
    L18nKeys.port: 'Port',
    L18nKeys.portHint: 'Enter port number',
    L18nKeys.pleaseEnterPort: 'Please enter port number',
    L18nKeys.portRangeError: 'Port number must be between 1-65535',
    L18nKeys.password: 'Password',
    L18nKeys.pleaseEnterPassword: 'Please enter password',
    L18nKeys.passwordMinLength: 'Password must be at least 6 characters',
    L18nKeys.testConnection: 'Test Connection',
    L18nKeys.saveChanges: 'Save Changes',
    L18nKeys.requiredFieldNote: '* Required fields',
    L18nKeys.hostUpdated: 'Host information updated',
    L18nKeys.hostAdded: 'Host added successfully',
    L18nKeys.saveFailed: 'Save failed',
    L18nKeys.testingConnection: 'Testing connection',
    L18nKeys.connectionSuccess: 'Connection successful',
    L18nKeys.connectionFailed: 'Connection failed',
    L18nKeys.connectionSuccessMessage:
        'Host connection is normal, configuration is valid',
    L18nKeys.connectionFailedMessage:
        'Cannot connect to host, please check configuration',
    L18nKeys.connectionTestError: 'Connection test error',

    // ========== Alert History Page ==========
    L18nKeys.alertHistory: 'Alert History',
    L18nKeys.clearHistory: 'Clear History',
    L18nKeys.noAlertRecords: 'No alert records',
    L18nKeys.acknowledge: 'Acknowledge',
    L18nKeys.alertAcknowledged: 'Alert acknowledged',
    L18nKeys.confirmClearAlertHistory:
        'Are you sure you want to clear all alert history?',
    L18nKeys.clear: 'Clear',
    L18nKeys.historyCleared: 'History cleared',

    // ========== Host Monitor Page ==========
    L18nKeys.hostMonitor: 'Host Monitor',
    L18nKeys.loadHostListFailed: 'Failed to load host list',
    L18nKeys.loadGeoInfoFailed:
        'Failed to load geographic location information',
    L18nKeys.hostStatusRefreshed: 'Host status refreshed',
    L18nKeys.refreshFailed: 'Refresh failed',
    L18nKeys.refreshHostStatus: 'Refresh Host Status',
    L18nKeys.forceDisconnectMessage: 'Host monitoring forcibly disconnected!',
    L18nKeys.safeDisconnectMessage: 'Host monitoring safely disconnected.',
    L18nKeys.disconnect: 'Disconnect',
    L18nKeys.loadingGeoInfo: 'Loading IP geographic location information...',
    L18nKeys.loadingHostList: 'Loading host list...',
    L18nKeys.connecting: 'Connecting...',
    L18nKeys.pleaseWait: 'Please wait',
    L18nKeys.noSavedHosts: 'No saved hosts yet',
    L18nKeys.clickToAddFirstHost:
        'Click the button in the bottom right to add your first host',
    L18nKeys.addNow: 'Add Now',
    L18nKeys.total: 'Total',
    L18nKeys.online: 'Online',
    L18nKeys.offline: 'Offline',
    L18nKeys.error: 'Error',
    L18nKeys.confirmDelete: 'Confirm Delete',
    L18nKeys.confirmDeleteHostPart1: 'Are you sure you want to delete host',
    L18nKeys.confirmDeleteHostPart2:
        '?\n\nThis action will also delete all alert records for this host.',
    L18nKeys.delete: 'Delete',
    L18nKeys.hostDeleted: 'Host deleted',
    L18nKeys.deleteFailed: 'Delete failed',
    L18nKeys.timeout: 'Timeout',

    // ========== Dialogs ==========
    L18nKeys.connectionTimeout: 'Connection Timeout',
    L18nKeys.connectionTimeoutMessage:
        'Cannot connect to host "{hostName}"\n\nPlease check:\n• Server is running\n• Network connection is normal\n• Firewall settings',
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
    L18nKeys.load1min: '1 Min Load',
    L18nKeys.load5min: '5 Min Load',
    L18nKeys.load15min: '15 Min Load',
    L18nKeys.cpuCoreUsage: 'CPU Core Usage',
    L18nKeys.systemInfo: 'System Info',
    L18nKeys.processor: 'Processor',
    L18nKeys.processorCores: 'Processor Cores',
    L18nKeys.coresUnit: 'cores',
    L18nKeys.processorFrequency: 'Processor Frequency',
    L18nKeys.processCount: 'Process Count',
    L18nKeys.countUnit: 'count',
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

    // ========== SSL Certificate Manager ==========
    L18nKeys.sslCertificateManager: 'SSL Certificate Manager',
    L18nKeys.sslBack: 'Back',
    L18nKeys.sslToggleTheme: 'Toggle Theme',
    L18nKeys.sslWelcomeTitle: 'Welcome to SSL Certificate Manager',
    L18nKeys.sslWelcomeSubtitle: 'Easily manage your OpenSSL certificates',
    L18nKeys.sslTotalCertificates: 'Total Certificates',
    L18nKeys.sslCACertificates: 'CA Certificates',
    L18nKeys.sslSSLCertificates: 'SSL Certificates',
    L18nKeys.sslExpired: 'Expired',
    L18nKeys.sslNavigation: 'Navigation',
    L18nKeys.sslCertificates: 'Certificates',
    L18nKeys.sslManageCertificates: 'Manage Certificates',
    L18nKeys.sslConfig: 'Configuration',
    L18nKeys.sslOpenSSLConfiguration: 'OpenSSL Configuration',
    L18nKeys.sslAppSettings: 'App Settings',

    // ========== Settings Screen ==========
    L18nKeys.settingsSelectCertDirectory:
        'Select Certificate Storage Directory',
    L18nKeys.settingsSelectConfigFile: 'Select OpenSSL Configuration File',
    L18nKeys.settingsCreateConfigFile: 'Create OpenSSL Configuration File',
    L18nKeys.settingsRequired: 'Required',
    L18nKeys.settingsSaveSuccess: 'Settings saved successfully',
    L18nKeys.settingsSaveError: 'Error saving settings: {error}',
    L18nKeys.settingsCertStorage: 'Certificate Storage',
    L18nKeys.settingsCertStoragePath: 'Certificate Storage Path *',
    L18nKeys.settingsCertPathHint: '/path/to/certificates',
    L18nKeys.settingsCertStorageDesc:
        'All generated certificates will be stored in this directory',
    L18nKeys.settingsOpenSSLConfig: 'OpenSSL Configuration',
    L18nKeys.settingsConfigFilePath: 'Configuration File Path *',
    L18nKeys.settingsConfigPathHint: '/path/to/openssl.cnf',
    L18nKeys.settingsCreateNew: 'Create New',
    L18nKeys.settingsSelectExisting: 'Select Existing',
    L18nKeys.settingsConfigFileDesc:
        'OpenSSL configuration template file. Used when generating certificates.',
    L18nKeys.settingsCACertDefaults: 'CA Certificate Default Settings',
    L18nKeys.settingsDefaultCAName: 'Default CA Name *',
    L18nKeys.settingsCANameHint: 'MyRootCA',
    L18nKeys.settingsEncryptCAByDefault: 'Encrypt CA by Default',
    L18nKeys.settingsEncryptCADesc:
        'Automatically encrypt CA private key when generating',
    L18nKeys.settingsDefaultCAPassword: 'Default CA Password',
    L18nKeys.settingsCAPasswordHint: 'Leave empty to prompt each time',
    L18nKeys.settingsPasswordWarning:
        'Warning: Not recommended to store passwords in production',
    L18nKeys.settingsAbout: 'About',
    L18nKeys.settingsAppName: 'SSL Certificate Manager',
    L18nKeys.settingsAppVersion: 'Version 1.0.0',
    L18nKeys.settingsAppDescription:
        'Professional OpenSSL certificate management application built with Flutter.',
    L18nKeys.settingsPoweredBy: 'Powered by OpenSSL',
    L18nKeys.settingsReset: 'Reset',
    L18nKeys.settingsSaveSettings: 'Save Settings',

    // ========== OpenSSL Configuration Screen ==========
    L18nKeys.configLoadError: 'Error loading configuration: {error}',
    L18nKeys.configSaveSuccess: 'Configuration saved successfully',
    L18nKeys.configSaveError: 'Error saving configuration: {error}',
    L18nKeys.configResetToDefault: 'Reset to Default',
    L18nKeys.configResetConfirm:
        'Are you sure you want to reset the configuration to default? This will overwrite your current configuration.',
    L18nKeys.configCancel: 'Cancel',
    L18nKeys.configReset: 'Reset',
    L18nKeys.configEditHint:
        'Edit OpenSSL configuration template. This template will be used when generating certificates.',
    L18nKeys.configPlaceholder: 'OpenSSL configuration...',
    L18nKeys.configResetToDefaultBtn: 'Reset to Default',
    L18nKeys.configSaveConfiguration: 'Save Configuration',

    // ========== Certificate Management Screen ==========
    L18nKeys.certImport: 'Import',
    L18nKeys.certGenerateCA: 'Generate CA Certificate',
    L18nKeys.certGenerateSSL: 'Generate SSL Certificate',
    L18nKeys.certPath: 'Path',
    L18nKeys.certCopyFullChainPath: 'Copy Full Chain Path',
    L18nKeys.certClose: 'Close',
    L18nKeys.certDeleteTitle: 'Delete Certificate',
    L18nKeys.certDeleteConfirm:
        'Are you sure you want to delete certificate {name}?',
    L18nKeys.certCancel: 'Cancel',
    L18nKeys.certDelete: 'Delete',
    L18nKeys.certDeleteSuccess: 'Certificate deleted successfully',
    L18nKeys.certImportCertificate: 'Import Certificate',
    L18nKeys.certImportSSLTitle: 'Import SSL Certificate',
    L18nKeys.certImportSSLDesc:
        'Import complete SSL certificate (certificate + private key + chain)',
    L18nKeys.certImportCATitle: 'Import CA Certificate',
    L18nKeys.certImportCADesc: 'Import CA root or intermediate certificate',
    L18nKeys.certImportPFXTitle: 'Import PFX/P12',
    L18nKeys.certImportPFXDesc: 'Import PFX or P12 format certificate package',

    // ========== Certificate Management Screen ==========
    L18nKeys.certSearchPlaceholder: 'Search certificates...',
    L18nKeys.certNoFound: 'No certificates found',

    // Import SSL Certificate Dialog
    L18nKeys.importSslCertificate: 'Import SSL Certificate',
    L18nKeys.selectSslCertificateFile: 'Select SSL Certificate File',
    L18nKeys.selectPrivateKeyFile: 'Select Private Key File',
    L18nKeys.selectCertificateChainFile: 'Select Certificate Chain File',
    L18nKeys.invalidCertificateFile: 'Invalid certificate file',
    L18nKeys.caCertificateWarning:
        'This appears to be a CA certificate. Please use "Import PEM Certificate" function.',
    L18nKeys.importedSslCertificate: 'Imported SSL Certificate',
    L18nKeys.sslCertificateValidatedSuccessfully:
        'SSL certificate validated successfully',
    L18nKeys.validationError: 'Validation Error',
    L18nKeys.invalidPrivateKeyOrPassword:
        'Invalid private key file or wrong password',
    L18nKeys.certificateKeyMismatch: 'Certificate and private key do not match',
    L18nKeys.privateKeyValidatedSuccessfully:
        'Private key validated successfully',
    L18nKeys.noCertificatesFoundInChain: 'No certificates found in chain file',
    L18nKeys.certificateChainValidated:
        'Certificate chain validated successfully',
    L18nKeys.certificates: 'certificates',
    L18nKeys.chainValidationError: 'Chain validation error',
    L18nKeys.pleaseValidateCertificateFirst:
        'Please validate certificate first',
    L18nKeys.pleaseValidatePrivateKeyFirst: 'Please validate private key first',
    L18nKeys.pleaseValidateChainFirst: 'Please validate chain first',
    L18nKeys.sslCertificateImportedSuccessfully:
        'SSL certificate imported successfully',
    L18nKeys.importError: 'Import Error',
    L18nKeys.importSslCertificateDescription:
        'Import existing SSL certificate with private key and certificate chain. Supports PEM format.',
    L18nKeys.sslCertificateFileRequired: 'SSL Certificate File (Required)',
    L18nKeys.selectPemCrtCerFile: 'Select .pem, .crt, or .cer file',
    L18nKeys.required: 'Required',
    L18nKeys.validateCertificate: 'Validate Certificate',
    L18nKeys.sslCertificate: 'SSL Certificate',
    L18nKeys.issuer: 'Issuer',
    L18nKeys.expiry: 'Expiry',
    L18nKeys.certificateNameRequired: 'Certificate Name (Required)',
    L18nKeys.enterFriendlyName: 'Enter a friendly name',
    L18nKeys.includePrivateKey: 'Include Private Key',
    L18nKeys.privateKeyFileRequired: 'Private Key File (Required)',
    L18nKeys.selectPemKeyFile: 'Select .pem or .key file',
    L18nKeys.privateKeyIsEncrypted: 'Private key is encrypted',
    L18nKeys.privateKeyPasswordRequired: 'Private Key Password (Required)',
    L18nKeys.validatePrivateKey: 'Validate Private Key',
    L18nKeys.includeCertificateChain: 'Include Certificate Chain',
    L18nKeys.intermediateRootCaCertificates:
        'Intermediate and root CA certificates',
    L18nKeys.certificateChainFile: 'Certificate Chain File',
    L18nKeys.selectChainPemFile:
        'Select .pem file containing certificate chain',
    L18nKeys.validateChain: 'Validate Chain',
    L18nKeys.chainContains: 'Chain contains',
    L18nKeys.import: 'Import',

    // Import PFX Dialog
    L18nKeys.importFromPfx: 'Import from PFX',
    L18nKeys.selectPfxFile: 'Select PFX File',
    L18nKeys.pfxFileRequired: 'PFX File (Required)',
    L18nKeys.selectPfxOrP12File: 'Select .pfx or .p12 file',
    L18nKeys.pfxPasswordRequired: 'PFX Password (Required)',
    L18nKeys.pfxImportedSuccessfullyTo: 'PFX imported successfully to',
    L18nKeys.folder: 'folder',

    // Import Certificate Dialog
    L18nKeys.importCertificate: 'Import Certificate',
    L18nKeys.selectCertificateFile: 'Select Certificate File',
    L18nKeys.certificateFileRequired: 'Certificate File (Required)',
    L18nKeys.importedCertificate: 'Imported Certificate',
    L18nKeys.certificateValidated: 'Certificate validated',
    L18nKeys.expired: 'Expired',
    L18nKeys.expiresIn: 'Expires in',
    L18nKeys.days: 'days',
    L18nKeys.certificateImportedSuccessfullyTo:
        'Certificate imported successfully to',
    L18nKeys.type: 'Type',
    L18nKeys.certificate: 'Certificate',
    L18nKeys.commonName: 'Common Name',
    L18nKeys.organization: 'Organization',
    L18nKeys.issueDate: 'Issue Date',
    L18nKeys.expiryDate: 'Expiry Date',
    L18nKeys.daysUntilExpiry: 'Days Until Expiry',
    L18nKeys.thisCertificateHasExpired: 'This certificate has expired!',
    L18nKeys.thisCertificateWillExpireIn: 'This certificate will expire in',
    L18nKeys.daysAgo: 'days ago',

    // Certificate Management Screen
    L18nKeys.certTabAll: 'All',
    L18nKeys.certTabCA: 'CA Certificates',
    L18nKeys.certTabSSL: 'SSL Certificates',

    // Certificate Details
    L18nKeys.certDetailType: 'Type',
    L18nKeys.certDetailCommonName: 'Common Name',
    L18nKeys.certDetailOrganization: 'Organization',
    L18nKeys.certDetailCountry: 'Country',
    L18nKeys.certDetailState: 'State/Province',
    L18nKeys.certDetailCity: 'City',
    L18nKeys.certDetailIssuerCN: 'Issuer CN',
    L18nKeys.certDetailIssuerOrg: 'Issuer Organization',
    L18nKeys.certDetailIssueDate: 'Issue Date',
    L18nKeys.certDetailExpiryDate: 'Expiry Date',
    L18nKeys.certDetailDaysUntilExpiry: 'Days Until Expiry',
    L18nKeys.certDetailEncrypted: 'Encrypted',
    L18nKeys.certDetailSerial: 'Serial Number',
    L18nKeys.certDetailFilePath: 'File Path',
    L18nKeys.certDetailKeyPath: 'Key Path',
    L18nKeys.certDetailChainPath: 'Chain Path',
    L18nKeys.certDetailFullChainPath: 'Full Chain Path',
    L18nKeys.certDetailChainLength: 'Chain Length',
    L18nKeys.certDetailImportedFrom: 'Imported From',
    L18nKeys.certDetailPurpose: 'Purpose',
    L18nKeys.certDetailPurposeName: 'Purpose Name',
    L18nKeys.certYes: 'Yes',
    L18nKeys.certNo: 'No',
    L18nKeys.certNA: 'N/A',
    L18nKeys.certExternal: 'External',
    L18nKeys.certCertificates: 'certificates',

    // Generate Certificate Dialog
    L18nKeys.certGenTitle: 'Generate Certificate',
    L18nKeys.certGenSubtitle:
        'Fill in the form below to create your certificate',
    L18nKeys.certGenClose: 'Close',
    L18nKeys.certGenConfigTitle: 'OpenSSL Configuration',
    L18nKeys.certGenUseCustomConfig: 'Use custom OpenSSL config',
    L18nKeys.certGenUsingDefault: 'Using OpenSSL default configuration',
    L18nKeys.certGenConfigApplied: 'Configuration defaults applied',

    L18nKeys.certGenPurposeTitle: 'Certificate Purpose',
    L18nKeys.certGenSelectPurpose: 'Select Purpose *',
    L18nKeys.certGenPurposeHelper: 'Defines the certificate key usage',
    L18nKeys.certGenRequired: 'Required',
    L18nKeys.certGenKeyUsage: 'Key Usage:',
    L18nKeys.certGenExtendedUsage: 'Extended Usage:',
    L18nKeys.certGenCustomKeyUsage: 'Custom Key Usage',
    L18nKeys.certGenCustomKeyUsageHint:
        'critical, digitalSignature, keyEncipherment',
    L18nKeys.certGenCustomExtKeyUsage: 'Custom Extended Key Usage',
    L18nKeys.certGenCustomExtKeyUsageHint:
        'serverAuth, clientAuth, codeSigning',
    L18nKeys.certGenCommaSeparated: 'Comma-separated values',
    L18nKeys.certGenCommonKeyUsage: 'Common Key Usage Values:',
    L18nKeys.certGenCommonExtKeyUsage: 'Common Extended Key Usage Values:',

    L18nKeys.certGenCATitle: 'CA Certificate Selection',
    L18nKeys.certGenSelectCA: 'Select CA Certificate *',
    L18nKeys.certGenSelectCAHelper:
        'Choose which CA will sign this certificate',
    L18nKeys.certGenCAPassword: 'CA Password *',
    L18nKeys.certGenPleaseSelectCA: 'Please select a CA certificate',

    L18nKeys.certGenInfoTitle: 'Certificate Information',
    L18nKeys.certGenSecurityTitle: 'Security Options',
    L18nKeys.certGenEncryptKey: 'Encrypt private key',
    L18nKeys.certGenEncryptKeyDesc: 'Protect the private key with a password',
    L18nKeys.certGenPassword: 'Password *',
    L18nKeys.certGenPasswordHelper: 'Enter a strong password',

    L18nKeys.certGenGenerating: 'Generating certificate...',
    L18nKeys.certGenCancel: 'Cancel',
    L18nKeys.certGenGenerate: 'Generate Certificate',

    // Form Fields
    L18nKeys.certFieldName: 'Certificate Name *',
    L18nKeys.certFieldNameHintCA: 'MyRootCA',
    L18nKeys.certFieldNameHintSSL: 'example.com',
    L18nKeys.certFieldCountry: 'Country Code *',
    L18nKeys.certFieldState: 'State/Province *',
    L18nKeys.certFieldCity: 'City *',
    L18nKeys.certFieldOrganization: 'Organization *',
    L18nKeys.certFieldOrgUnit: 'Organization Unit *',
    L18nKeys.certFieldCommonName: 'Common Name *',
    L18nKeys.certFieldCommonNameHintCA: 'My Root CA',
    L18nKeys.certFieldCommonNameHintSSL: 'example.com',
    L18nKeys.certFieldEmail: 'Email',
    L18nKeys.certFieldEmailHint: 'admin@example.com',
    L18nKeys.certFieldSAN: 'Subject Alternative Names',
    L18nKeys.certFieldSANHint: 'www.example.com,mail.example.com',
    L18nKeys.certFieldValidity: 'Validity (days) *',
    L18nKeys.certFieldFromConfig: 'From config',
    L18nKeys.certFieldInvalidNumber: 'Invalid number',

    // Success Messages
    L18nKeys.certGenSuccessCA: 'CA certificate generated successfully',
    L18nKeys.certGenSuccessSSL: 'SSL certificate generated successfully',
    L18nKeys.certGenSuccessCustomConfig: ' using custom config',
    L18nKeys.certGenSuccessPurpose: 'Purpose: ',
    L18nKeys.certGenError: 'Error: ',

    // Export PFX Dialog
    L18nKeys.certExportTitle: 'Export to PFX',
    L18nKeys.certExportCertPassword: 'Certificate Password *',
    L18nKeys.certExportPFXPassword: 'PFX Password *',
    L18nKeys.certExportIncludeCA: 'Include CA Certificate',
    L18nKeys.certExportSelectCA: 'Select CA Certificate',
    L18nKeys.certExportButton: 'Export',
    L18nKeys.certExportSaveTitle: 'Save PFX file',
    L18nKeys.certExportSuccess: 'PFX exported successfully',
    L18nKeys.certExportError: 'Export error: ',

    // Certificate Card Status
    L18nKeys.certStatusActive: 'Active',
    L18nKeys.certStatusExpired: 'Expired',
    L18nKeys.certStatusExpiringSoon: 'Expiring Soon',

    // Certificate Card Info Labels
    L18nKeys.certCardIssueDate: 'Issue Date',
    L18nKeys.certCardExpiryDate: 'Expiry Date',
    L18nKeys.certCardDaysUntilExpiry: 'Days Until Expiry',
    L18nKeys.certCardDays: 'days',
    L18nKeys.certCardEncrypted: 'Encrypted',
    L18nKeys.certCardChain: 'Chain',
    L18nKeys.certCardCerts: 'cert(s)',
    L18nKeys.certCardImported: 'Imported',

    // Certificate Card Actions
    L18nKeys.certActionExport: 'Export',
    L18nKeys.certActionDelete: 'Delete',
  };
}
