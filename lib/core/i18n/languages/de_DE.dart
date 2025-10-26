// ============================================================================
// Deutsch (Deutschland) Übersetzung
// ============================================================================

import '../localization_keys.dart';

class DeDE {
  static const Map<String, String> translations = {
    // ========== Allgemein ==========
    L18nKeys.appTitle: 'OwO! Systemwerkzeuge',
    L18nKeys.ok: 'OK',
    L18nKeys.cancel: 'Abbrechen',

    // ========== Navigation ==========
    L18nKeys.menu: 'Menü',
    L18nKeys.home: 'Startseite',
    L18nKeys.settings: 'Einstellungen',
    L18nKeys.about: 'Über',
    L18nKeys.monitor: 'Monitor',
    L18nKeys.ssl: 'SSL-Zertifikatsverwaltung',

    // ========== Willkommensseite ==========
    L18nKeys.welcome: 'Willkommen',
    L18nKeys.welcomeMessage: 'Ein vollständiges Flutter-Anwendungs-Framework',
    L18nKeys.welcomeDescription:
        'Unterstützt plattformübergreifende adaptive Layouts, perfekt angepasst für mobile Geräte, Tablets und Desktop-Computer',
    L18nKeys.exploreFeatures: 'Funktionen erkunden',

    // ========== Spracheinstellungen ==========
    L18nKeys.languageSettings: 'Spracheinstellungen',
    L18nKeys.selectLanguage: 'Sprache auswählen',
    L18nKeys.changingLanguage: 'Sprache wird geändert',

    // ========== Einstellungshauptseite ==========
    L18nKeys.adjustTheme: 'Theme-Modus und Farbschema anpassen',
    L18nKeys.selectAppLanguage: 'Anzeigesprache der Anwendung auswählen',
    L18nKeys.configureHostMonitor: 'Host-Überwachungsoptionen konfigurieren',

    // ========== Theme-Einstellungen ==========
    L18nKeys.themeMode: 'Theme-Modus',
    L18nKeys.changingTheme: 'Theme wird geändert',
    L18nKeys.themeSettings: 'Theme-Einstellungen',
    L18nKeys.themeColorSettings: 'Theme-Farben',
    L18nKeys.cyberpunkTheme: 'Cyberpunk-Theme',
    L18nKeys.lightTheme: 'Helles Theme',
    L18nKeys.darkTheme: 'Dunkles Theme',
    L18nKeys.systemTheme: 'Systemstandard',
    L18nKeys.defaultTheme: 'Standard-Theme',
    L18nKeys.techTheme: 'Tech-Theme',
    L18nKeys.natureTheme: 'Natur-Theme',
    L18nKeys.sunsetTheme: 'Sonnenuntergangs-Theme',
    L18nKeys.oceanTheme: 'Ozean-Theme',

    // ========== Host-Monitor-Einstellungen ==========
    L18nKeys.hostMonitorSettings: 'Host-Monitor-Einstellungen',
    L18nKeys.refreshSettings: 'Aktualisierungseinstellungen',
    L18nKeys.hostPollingInterval: 'Host-Abfrageintervall',
    L18nKeys.enterRefreshInterval:
        'Aktualisierungsintervall eingeben (Sekunden)',
    L18nKeys.seconds: 'Sekunden',
    L18nKeys.recommendedInterval:
        'Empfohlener Bereich: 1-10 Sekunden. Zu kurz kann die Leistung beeinträchtigen',
    L18nKeys.hostCheckSettings: 'Host-Überprüfungseinstellungen',
    L18nKeys.checkTimeout: 'Überprüfungs-Timeout',
    L18nKeys.enterTimeout: 'Timeout eingeben (Sekunden)',
    L18nKeys.timeoutDescription:
        'Timeout für die Überprüfung des Host-Online-Status, empfohlen 3-10 Sekunden',
    L18nKeys.backgroundCheckInterval: 'Hintergrundüberprüfungsintervall',
    L18nKeys.enterCheckInterval: 'Überprüfungsintervall eingeben (Minuten)',
    L18nKeys.minutes: 'Minuten',
    L18nKeys.checkIntervalDescription:
        'Intervall für die stille Hintergrundüberprüfung der Host-Liste, empfohlen 5-30 Minuten',
    L18nKeys.alertSettings: 'Warnungseinstellungen',
    L18nKeys.enableAlert: 'Warnungen aktivieren',
    L18nKeys.enableAlertDescription:
        'Benachrichtigungen senden, wenn Ressourcennutzung Schwellenwerte überschreitet',
    L18nKeys.alertThreshold: 'Warnschwellenwert',
    L18nKeys.cpuUsage: 'CPU-Auslastung',
    L18nKeys.memoryUsage: 'Speicherauslastung',
    L18nKeys.diskUsage: 'Festplattenauslastung',
    L18nKeys.uploadSpeed: 'Upload-Geschwindigkeit',
    L18nKeys.downloadSpeed: 'Download-Geschwindigkeit',
    L18nKeys.notificationSettings: 'Benachrichtigungseinstellungen',
    L18nKeys.disconnectNotification:
        'Verbindungsunterbrechungsbenachrichtigung',
    L18nKeys.soundAlert: 'Ton-Warnung',
    L18nKeys.vibrationAlert: 'Vibrations-Warnung',
    L18nKeys.vibrationAlertDescription: 'Nur auf mobilen Geräten wirksam',
    L18nKeys.save: 'Speichern',
    L18nKeys.settingsSaved: 'Einstellungen gespeichert',
    L18nKeys.longRefreshInterval: 'Langes Aktualisierungsintervall',
    L18nKeys.longRefreshIntervalWarning:
        'Sie haben das Aktualisierungsintervall auf {interval} Sekunden gesetzt, was zu verzögerten Datenaktualisierungen führen kann. Fortfahren?',
    L18nKeys.invalidRefreshInterval:
        'Bitte geben Sie ein gültiges Aktualisierungsintervall ein (mindestens 1 Sekunde)',
    L18nKeys.invalidTimeout:
        'Bitte geben Sie einen gültigen Überprüfungs-Timeout ein (1-60 Sekunden)',
    L18nKeys.invalidCheckInterval:
        'Bitte geben Sie ein gültiges Überprüfungsintervall ein (1-1440 Minuten)',

    // ========== Visuelle Effekte ==========
    L18nKeys.visualEffects: 'Visuelle Effekte',
    L18nKeys.visualEffectsDescription: 'Exklusive Effekte für Cyberpunk-Theme',
    L18nKeys.matrixRainEffect: 'Matrix-Regen-Effekt',
    L18nKeys.matrixRainDescription: 'Matrix-Stil Hintergrundanimation',
    L18nKeys.glowEffect: 'Leuchteffekt',
    L18nKeys.glowEffectDescription: 'Schaltflächen- und Karten-Leuchteffekte',
    L18nKeys.scanningLine: 'Scannlinie',
    L18nKeys.scanningLineDescription: 'Bildschirm-Scannlinien-Animation',
    L18nKeys.glitchEffect: 'Glitch-Effekt',
    L18nKeys.glitchEffectDescription: 'Digitale Glitch-Stil-Effekte',

    // ========== App-Informationen ==========
    L18nKeys.appInfo: 'App-Informationen',
    L18nKeys.appName: 'OwO! Systemwerkzeuge',
    L18nKeys.appDescription:
        'Eine leistungsstarke plattformübergreifende Systemwerkzeug-Suite mit Host-Überwachung, Leistungsanalyse und mehr',
    L18nKeys.appVersion: 'Version',
    L18nKeys.developerInfo: 'Entwicklerinformationen',
    L18nKeys.developerName: 'Entwickler',
    L18nKeys.contactEmail: 'Kontakt-E-Mail',
    L18nKeys.flutterVersion: 'Flutter-Version',
    L18nKeys.serviceHomepage: 'Service-Homepage',
    L18nKeys.openSource: 'Open Source',
    L18nKeys.openSourceDescription:
        'Dieses Projekt ist Open Source lizenziert. Beiträge willkommen',
    L18nKeys.viewSourceCode: 'Quellcode anzeigen',
    L18nKeys.license: 'Lizenz',
    L18nKeys.supportDevelopment: 'Entwicklung unterstützen',
    L18nKeys.donationDescription:
        'Wenn Sie dieses Projekt hilfreich finden, unterstützen Sie bitte die Entwicklung',
    L18nKeys.donateNow: 'Jetzt spenden',
    L18nKeys.topDonors: 'Top-Spender',
    L18nKeys.cannotOpenUrl: 'URL kann nicht geöffnet werden',
    L18nKeys.loadFailed: 'Laden fehlgeschlagen',
    L18nKeys.retry: 'Erneut versuchen',
    L18nKeys.noDonorsYet: 'Noch keine Spenderdatensätze',

    // ========== Tech-Stack-Karten ==========
    L18nKeys.techStack: 'Technologie-Stack',
    L18nKeys.flutter: 'Flutter',
    L18nKeys.flutterDescription: 'Plattformübergreifendes UI-Framework',
    L18nKeys.goLang: 'Go-Sprache',
    L18nKeys.goLangDescription: 'Hochleistungs-Backend-Service',
    L18nKeys.tcpIp: 'TCP/IP',
    L18nKeys.tcpIpDescription: 'Netzwerkkommunikationsprotokoll',
    L18nKeys.materialDesign: 'Material Design',
    L18nKeys.materialDesignDescription: 'Moderne Designsprache',

    // ========== Benutzervereinbarung ==========
    L18nKeys.userAgreement: 'Benutzervereinbarung',
    L18nKeys.agreementContent:
        '1. Dieses Anwendungs-Framework ist nur für Lern- und Entwicklungszwecke\n2. Bitte befolgen Sie relevante Gesetze und Vorschriften\n3. Unterstützt mobile, Tablet- und PC-Plattformen\n4. Entwickler behält sich alle Rechte vor\n5. Dieses Projekt folgt der MIT Open-Source-Lizenz\n6. Bitte lesen Sie die Dokumentation sorgfältig vor der Verwendung\n7. Entwickler behält sich das endgültige Auslegungsrecht vor',
    L18nKeys.github: 'GitHub',

    // ========== Geräteinformationen ==========
    L18nKeys.deviceInfo: 'Geräteinformationen',
    L18nKeys.screenSize: 'Bildschirmgröße',
    L18nKeys.deviceType: 'Gerätetyp',
    L18nKeys.mobileDevice: 'Mobilgerät',
    L18nKeys.tabletDevice: 'Tablet',
    L18nKeys.desktopDevice: 'Desktop',
    L18nKeys.layoutMode: 'Layout-Modus',
    L18nKeys.adaptiveLayout: 'Adaptives Layout',

    // ========== Fenstersteuerung ==========
    L18nKeys.minimize: 'Minimieren',
    L18nKeys.maximize: 'Maximieren',
    L18nKeys.restore: 'Wiederherstellen',
    L18nKeys.close: 'Schließen',

    // ========== Host-Bearbeitungsseite ==========
    L18nKeys.editHost: 'Host bearbeiten',
    L18nKeys.addHost: 'Host hinzufügen',
    L18nKeys.hostName: 'Hostname',
    L18nKeys.hostNameHint: 'Hostname eingeben',
    L18nKeys.pleaseEnterHostName: 'Bitte Hostname eingeben',
    L18nKeys.hostNameMinLength: 'Hostname muss mindestens 2 Zeichen lang sein',
    L18nKeys.hostAddress: 'Host-Adresse',
    L18nKeys.hostAddressHint: 'z.B. 192.168.1.100',
    L18nKeys.pleaseEnterHostAddress: 'Bitte Host-Adresse eingeben',
    L18nKeys.hostAddressNoSpaces:
        'Host-Adresse darf keine Leerzeichen enthalten',
    L18nKeys.port: 'Port',
    L18nKeys.portHint: 'Portnummer eingeben',
    L18nKeys.pleaseEnterPort: 'Bitte Portnummer eingeben',
    L18nKeys.portRangeError: 'Portnummer muss zwischen 1-65535 liegen',
    L18nKeys.password: 'Passwort',
    L18nKeys.pleaseEnterPassword: 'Bitte Passwort eingeben',
    L18nKeys.passwordMinLength: 'Passwort muss mindestens 6 Zeichen lang sein',
    L18nKeys.testConnection: 'Verbindung testen',
    L18nKeys.saveChanges: 'Änderungen speichern',
    L18nKeys.requiredFieldNote: '* Pflichtfelder',
    L18nKeys.hostUpdated: 'Host-Informationen aktualisiert',
    L18nKeys.hostAdded: 'Host erfolgreich hinzugefügt',
    L18nKeys.saveFailed: 'Speichern fehlgeschlagen',
    L18nKeys.testingConnection: 'Verbindung wird getestet',
    L18nKeys.connectionSuccess: 'Verbindung erfolgreich',
    L18nKeys.connectionFailed: 'Verbindung fehlgeschlagen',
    L18nKeys.connectionSuccessMessage:
        'Host-Verbindung ist normal, Konfiguration ist gültig',
    L18nKeys.connectionFailedMessage:
        'Kann nicht mit Host verbinden, bitte Konfiguration überprüfen',
    L18nKeys.connectionTestError: 'Verbindungstest-Fehler',

    // ========== Warnungsverlauf ==========
    L18nKeys.alertHistory: 'Warnungsverlauf',
    L18nKeys.clearHistory: 'Verlauf löschen',
    L18nKeys.noAlertRecords: 'Keine Warnungsdatensätze',
    L18nKeys.acknowledge: 'Bestätigen',
    L18nKeys.alertAcknowledged: 'Warnung bestätigt',
    L18nKeys.confirmClearAlertHistory:
        'Sind Sie sicher, dass Sie den gesamten Warnungsverlauf löschen möchten?',
    L18nKeys.clear: 'Löschen',
    L18nKeys.historyCleared: 'Verlauf gelöscht',

    // ========== Host-Monitor ==========
    L18nKeys.hostMonitor: 'Host-Monitor',
    L18nKeys.loadHostListFailed: 'Laden der Host-Liste fehlgeschlagen',
    L18nKeys.loadGeoInfoFailed:
        'Laden der geografischen Standortinformationen fehlgeschlagen',
    L18nKeys.hostStatusRefreshed: 'Host-Status aktualisiert',
    L18nKeys.refreshFailed: 'Aktualisierung fehlgeschlagen',
    L18nKeys.refreshHostStatus: 'Host-Status aktualisieren',
    L18nKeys.forceDisconnectMessage: 'Host-Überwachung erzwungen getrennt!',
    L18nKeys.safeDisconnectMessage: 'Host-Überwachung sicher getrennt.',
    L18nKeys.disconnect: 'Trennen',
    L18nKeys.loadingGeoInfo: 'IP-Standortinformationen werden geladen...',
    L18nKeys.loadingHostList: 'Host-Liste wird geladen...',
    L18nKeys.connecting: 'Verbindung wird hergestellt...',
    L18nKeys.pleaseWait: 'Bitte warten',
    L18nKeys.noSavedHosts: 'Noch keine gespeicherten Hosts',
    L18nKeys.clickToAddFirstHost:
        'Klicken Sie auf die Schaltfläche unten rechts, um Ihren ersten Host hinzuzufügen',
    L18nKeys.addNow: 'Jetzt hinzufügen',
    L18nKeys.total: 'Gesamt',
    L18nKeys.online: 'Online',
    L18nKeys.offline: 'Offline',
    L18nKeys.error: 'Fehler',
    L18nKeys.confirmDelete: 'Löschen bestätigen',
    L18nKeys.confirmDeleteHostPart1:
        'Sind Sie sicher, dass Sie den Host löschen möchten',
    L18nKeys.confirmDeleteHostPart2:
        '?\n\nDiese Aktion löscht auch alle Warnungsdatensätze für diesen Host.',
    L18nKeys.delete: 'Löschen',
    L18nKeys.hostDeleted: 'Host gelöscht',
    L18nKeys.deleteFailed: 'Löschen fehlgeschlagen',
    L18nKeys.timeout: 'Zeitüberschreitung',

    // ========== Dialoge ==========
    L18nKeys.connectionTimeout: 'Verbindungszeitüberschreitung',
    L18nKeys.connectionTimeoutMessage:
        'Kann nicht mit Host "{hostName}" verbinden\n\nBitte überprüfen:\n• Server läuft\n• Netzwerkverbindung ist normal\n• Firewall-Einstellungen',
    L18nKeys.tokenValidationFailed: 'Token-Validierung fehlgeschlagen',
    L18nKeys.tokenValidationFailedMessage:
        'Zugriffstoken für Host "{hostName}" ist falsch',

    // ========== Host-Details ==========
    L18nKeys.waitingSystemData: 'Warte auf Systemdaten',
    L18nKeys.connectedGettingSystemInfo:
        'Verbunden, Systeminformationen werden abgerufen...',
    L18nKeys.unnamedHost: 'Unbenannter Host',
    L18nKeys.connected: 'Verbunden',
    L18nKeys.cpuUsageTrend: 'CPU-Auslastungsverlauf',
    L18nKeys.memoryUsageTrend: 'Speicherauslastungsverlauf',
    L18nKeys.diskUsageTrend: 'Festplattenauslastungsverlauf',
    L18nKeys.uploadSpeedLabel: 'Upload-Geschwindigkeit',
    L18nKeys.downloadSpeedLabel: 'Download-Geschwindigkeit',
    L18nKeys.load1min: '1 Min. Last',
    L18nKeys.load5min: '5 Min. Last',
    L18nKeys.load15min: '15 Min. Last',
    L18nKeys.cpuCoreUsage: 'CPU-Kern-Auslastung',
    L18nKeys.systemInfo: 'Systeminformationen',
    L18nKeys.processor: 'Prozessor',
    L18nKeys.processorCores: 'Prozessorkerne',
    L18nKeys.coresUnit: 'Kerne',
    L18nKeys.processorFrequency: 'Prozessorfrequenz',
    L18nKeys.processCount: 'Prozessanzahl',
    L18nKeys.countUnit: 'Anzahl',
    L18nKeys.systemLoad: 'Systemlast',
    L18nKeys.systemArchitecture: 'Systemarchitektur',
    L18nKeys.operatingSystem: 'Betriebssystem',
    L18nKeys.kernelVersion: 'Kernel-Version',
    L18nKeys.hostname: 'Hostname',
    L18nKeys.uptime: 'Betriebszeit',
    L18nKeys.memoryDetails: 'Speicherdetails',
    L18nKeys.usageRate: 'Auslastungsrate',
    L18nKeys.totalMemory: 'Gesamtspeicher',
    L18nKeys.usedMemory: 'Verwendeter Speicher',
    L18nKeys.availableMemory: 'Verfügbarer Speicher',
    L18nKeys.diskDetails: 'Festplattendetails',
    L18nKeys.used: 'Verwendet',
    L18nKeys.networkDetails: 'Netzwerkdetails',
    L18nKeys.upload: 'Upload',
    L18nKeys.download: 'Download',
    L18nKeys.bytesSent: 'Gesendete Bytes',
    L18nKeys.bytesReceived: 'Empfangene Bytes',

    // ========== SSL-Zertifikatsverwaltung ==========
    L18nKeys.sslCertificateManager: 'SSL-Zertifikatsverwaltung',
    L18nKeys.sslBack: 'Zurück',
    L18nKeys.sslToggleTheme: 'Theme wechseln',
    L18nKeys.sslWelcomeTitle: 'Willkommen bei der SSL-Zertifikatsverwaltung',
    L18nKeys.sslWelcomeSubtitle:
        'Verwalten Sie Ihre OpenSSL-Zertifikate einfach',
    L18nKeys.sslTotalCertificates: 'Zertifikate insgesamt',
    L18nKeys.sslCACertificates: 'CA-Zertifikate',
    L18nKeys.sslSSLCertificates: 'SSL-Zertifikate',
    L18nKeys.sslExpired: 'Abgelaufen',
    L18nKeys.sslNavigation: 'Navigation',
    L18nKeys.sslCertificates: 'Zertifikate',
    L18nKeys.sslManageCertificates: 'Zertifikate verwalten',
    L18nKeys.sslConfig: 'Konfiguration',
    L18nKeys.sslOpenSSLConfiguration: 'OpenSSL-Konfiguration',
    L18nKeys.sslAppSettings: 'App-Einstellungen',

    // ========== Einstellungsbildschirm ==========
    L18nKeys.settingsSelectCertDirectory:
        'Zertifikat-Speicherverzeichnis auswählen',
    L18nKeys.settingsSelectConfigFile: 'OpenSSL-Konfigurationsdatei auswählen',
    L18nKeys.settingsCreateConfigFile: 'OpenSSL-Konfigurationsdatei erstellen',
    L18nKeys.settingsRequired: 'Erforderlich',
    L18nKeys.settingsSaveSuccess: 'Einstellungen erfolgreich gespeichert',
    L18nKeys.settingsSaveError:
        'Fehler beim Speichern der Einstellungen: {error}',
    L18nKeys.settingsCertStorage: 'Zertifikatsspeicher',
    L18nKeys.settingsCertStoragePath: 'Zertifikatsspeicherpfad *',
    L18nKeys.settingsCertPathHint: '/pfad/zu/zertifikaten',
    L18nKeys.settingsCertStorageDesc:
        'Alle generierten Zertifikate werden in diesem Verzeichnis gespeichert',
    L18nKeys.settingsOpenSSLConfig: 'OpenSSL-Konfiguration',
    L18nKeys.settingsConfigFilePath: 'Konfigurationsdateipfad *',
    L18nKeys.settingsConfigPathHint: '/pfad/zu/openssl.cnf',
    L18nKeys.settingsCreateNew: 'Neu erstellen',
    L18nKeys.settingsSelectExisting: 'Vorhandene auswählen',
    L18nKeys.settingsConfigFileDesc:
        'OpenSSL-Konfigurationsvorlagendatei. Wird beim Generieren von Zertifikaten verwendet.',
    L18nKeys.settingsCACertDefaults: 'CA-Zertifikat-Standardeinstellungen',
    L18nKeys.settingsDefaultCAName: 'Standard-CA-Name *',
    L18nKeys.settingsCANameHint: 'MeineRootCA',
    L18nKeys.settingsEncryptCAByDefault: 'CA standardmäßig verschlüsseln',
    L18nKeys.settingsEncryptCADesc:
        'CA-Privatschlüssel automatisch verschlüsseln beim Generieren',
    L18nKeys.settingsDefaultCAPassword: 'Standard-CA-Passwort',
    L18nKeys.settingsCAPasswordHint: 'Leer lassen, um jedes Mal aufzufordern',
    L18nKeys.settingsPasswordWarning:
        'Warnung: Nicht empfohlen, Passwörter in Produktion zu speichern',
    L18nKeys.settingsAbout: 'Über',
    L18nKeys.settingsAppName: 'SSL-Zertifikatsverwaltung',
    L18nKeys.settingsAppVersion: 'Version 1.0.0',
    L18nKeys.settingsAppDescription:
        'Professionelle OpenSSL-Zertifikatsverwaltungsanwendung mit Flutter erstellt.',
    L18nKeys.settingsPoweredBy: 'Powered by OpenSSL',
    L18nKeys.settingsReset: 'Zurücksetzen',
    L18nKeys.settingsSaveSettings: 'Einstellungen speichern',

    // ========== OpenSSL-Konfigurationsbildschirm ==========
    L18nKeys.configLoadError: 'Fehler beim Laden der Konfiguration: {error}',
    L18nKeys.configSaveSuccess: 'Konfiguration erfolgreich gespeichert',
    L18nKeys.configSaveError:
        'Fehler beim Speichern der Konfiguration: {error}',
    L18nKeys.configResetToDefault: 'Auf Standard zurücksetzen',
    L18nKeys.configResetConfirm:
        'Sind Sie sicher, dass Sie die Konfiguration auf Standard zurücksetzen möchten? Dies überschreibt Ihre aktuelle Konfiguration.',
    L18nKeys.configCancel: 'Abbrechen',
    L18nKeys.configReset: 'Zurücksetzen',
    L18nKeys.configEditHint:
        'OpenSSL-Konfigurationsvorlage bearbeiten. Diese Vorlage wird beim Generieren von Zertifikaten verwendet.',
    L18nKeys.configPlaceholder: 'OpenSSL-Konfiguration...',
    L18nKeys.configResetToDefaultBtn: 'Auf Standard zurücksetzen',
    L18nKeys.configSaveConfiguration: 'Konfiguration speichern',

    // ========== Zertifikatsverwaltungsbildschirm ==========
    L18nKeys.certImport: 'Importieren',
    L18nKeys.certGenerateCA: 'CA-Zertifikat generieren',
    L18nKeys.certGenerateSSL: 'SSL-Zertifikat generieren',
    L18nKeys.certPath: 'Pfad',
    L18nKeys.certCopyFullChainPath: 'Vollständigen Chain-Pfad kopieren',
    L18nKeys.certClose: 'Schließen',
    L18nKeys.certDeleteTitle: 'Zertifikat löschen',
    L18nKeys.certDeleteConfirm:
        'Sind Sie sicher, dass Sie das Zertifikat {name} löschen möchten?',
    L18nKeys.certCancel: 'Abbrechen',
    L18nKeys.certDelete: 'Löschen',
    L18nKeys.certDeleteSuccess: 'Zertifikat erfolgreich gelöscht',
    L18nKeys.certImportCertificate: 'Zertifikat importieren',
    L18nKeys.certImportSSLTitle: 'SSL-Zertifikat importieren',
    L18nKeys.certImportSSLDesc:
        'Vollständiges SSL-Zertifikat importieren (Zertifikat + Privatschlüssel + Chain)',
    L18nKeys.certImportCATitle: 'CA-Zertifikat importieren',
    L18nKeys.certImportCADesc: 'CA-Root- oder Zwischenzertifikat importieren',
    L18nKeys.certImportPFXTitle: 'PFX/P12 importieren',
    L18nKeys.certImportPFXDesc:
        'PFX- oder P12-Format-Zertifikatspaket importieren',

    // ========== Zertifikatsverwaltungsbildschirm ==========
    L18nKeys.certSearchPlaceholder: 'Zertifikate suchen...',
    L18nKeys.certNoFound: 'Keine Zertifikate gefunden',

    // SSL-Zertifikat-Import-Dialog
    L18nKeys.importSslCertificate: 'SSL-Zertifikat importieren',
    L18nKeys.selectSslCertificateFile: 'SSL-Zertifikatsdatei auswählen',
    L18nKeys.selectPrivateKeyFile: 'Privatschlüsseldatei auswählen',
    L18nKeys.selectCertificateChainFile: 'Zertifikatskettendatei auswählen',
    L18nKeys.invalidCertificateFile: 'Ungültige Zertifikatsdatei',
    L18nKeys.caCertificateWarning:
        'Dies scheint ein CA-Zertifikat zu sein. Bitte verwenden Sie die Funktion "PEM-Zertifikat importieren".',
    L18nKeys.importedSslCertificate: 'SSL-Zertifikat importiert',
    L18nKeys.sslCertificateValidatedSuccessfully:
        'SSL-Zertifikat erfolgreich validiert',
    L18nKeys.validationError: 'Validierungsfehler',
    L18nKeys.invalidPrivateKeyOrPassword:
        'Ungültige Privatschlüsseldatei oder falsches Passwort',
    L18nKeys.certificateKeyMismatch:
        'Zertifikat und Privatschlüssel stimmen nicht überein',
    L18nKeys.privateKeyValidatedSuccessfully:
        'Privatschlüssel erfolgreich validiert',
    L18nKeys.noCertificatesFoundInChain:
        'Keine Zertifikate in der Chain-Datei gefunden',
    L18nKeys.certificateChainValidated:
        'Zertifikatskette erfolgreich validiert',
    L18nKeys.certificates: 'Zertifikate',
    L18nKeys.chainValidationError: 'Chain-Validierungsfehler',
    L18nKeys.pleaseValidateCertificateFirst:
        'Bitte zuerst Zertifikat validieren',
    L18nKeys.pleaseValidatePrivateKeyFirst:
        'Bitte zuerst Privatschlüssel validieren',
    L18nKeys.pleaseValidateChainFirst: 'Bitte zuerst Chain validieren',
    L18nKeys.sslCertificateImportedSuccessfully:
        'SSL-Zertifikat erfolgreich importiert',
    L18nKeys.importError: 'Import-Fehler',
    L18nKeys.importSslCertificateDescription:
        'Vorhandenes SSL-Zertifikat mit Privatschlüssel und Zertifikatskette importieren. Unterstützt PEM-Format.',
    L18nKeys.sslCertificateFileRequired: 'SSL-Zertifikatsdatei (Erforderlich)',
    L18nKeys.selectPemCrtCerFile: '.pem, .crt oder .cer Datei auswählen',
    L18nKeys.required: 'Erforderlich',
    L18nKeys.validateCertificate: 'Zertifikat validieren',
    L18nKeys.sslCertificate: 'SSL-Zertifikat',
    L18nKeys.issuer: 'Aussteller',
    L18nKeys.expiry: 'Ablauf',
    L18nKeys.certificateNameRequired: 'Zertifikatsname (Erforderlich)',
    L18nKeys.enterFriendlyName: 'Einen benutzerfreundlichen Namen eingeben',
    L18nKeys.includePrivateKey: 'Privatschlüssel einschließen',
    L18nKeys.privateKeyFileRequired: 'Privatschlüsseldatei (Erforderlich)',
    L18nKeys.selectPemKeyFile: '.pem oder .key Datei auswählen',
    L18nKeys.privateKeyIsEncrypted: 'Privatschlüssel ist verschlüsselt',
    L18nKeys.privateKeyPasswordRequired:
        'Privatschlüssel-Passwort (Erforderlich)',
    L18nKeys.validatePrivateKey: 'Privatschlüssel validieren',
    L18nKeys.includeCertificateChain: 'Zertifikatskette einschließen',
    L18nKeys.intermediateRootCaCertificates:
        'Zwischen- und Root-CA-Zertifikate',
    L18nKeys.certificateChainFile: 'Zertifikatskettendatei',
    L18nKeys.selectChainPemFile: '.pem Datei mit Zertifikatskette auswählen',
    L18nKeys.validateChain: 'Chain validieren',
    L18nKeys.chainContains: 'Chain enthält',
    L18nKeys.import: 'Importieren',
// PFX-Import-Dialog
    L18nKeys.importFromPfx: 'Von PFX importieren',
    L18nKeys.selectPfxFile: 'PFX-Datei auswählen',
    L18nKeys.pfxFileRequired: 'PFX-Datei (Erforderlich)',
    L18nKeys.selectPfxOrP12File: '.pfx oder .p12 Datei auswählen',
    L18nKeys.pfxPasswordRequired: 'PFX-Passwort (Erforderlich)',
    L18nKeys.pfxImportedSuccessfullyTo: 'PFX erfolgreich importiert nach',
    L18nKeys.folder: 'Ordner',

// Zertifikat-Import-Dialog
    L18nKeys.importCertificate: 'Zertifikat importieren',
    L18nKeys.selectCertificateFile: 'Zertifikatsdatei auswählen',
    L18nKeys.certificateFileRequired: 'Zertifikatsdatei (Erforderlich)',
    L18nKeys.importedCertificate: 'Importiertes Zertifikat',
    L18nKeys.certificateValidated: 'Zertifikat validiert',
    L18nKeys.expired: 'Abgelaufen',
    L18nKeys.expiresIn: 'Läuft ab in',
    L18nKeys.days: 'Tage',
    L18nKeys.certificateImportedSuccessfullyTo:
        'Zertifikat erfolgreich importiert nach',
    L18nKeys.type: 'Typ',
    L18nKeys.certificate: 'Zertifikat',
    L18nKeys.commonName: 'Common Name',
    L18nKeys.organization: 'Organisation',
    L18nKeys.issueDate: 'Ausstellungsdatum',
    L18nKeys.expiryDate: 'Ablaufdatum',
    L18nKeys.daysUntilExpiry: 'Tage bis Ablauf',
    L18nKeys.thisCertificateHasExpired: 'Dieses Zertifikat ist abgelaufen!',
    L18nKeys.thisCertificateWillExpireIn: 'Dieses Zertifikat läuft ab in',
    L18nKeys.daysAgo: 'Tage her',

// Zertifikatsverwaltungsbildschirm
    L18nKeys.certTabAll: 'Alle',
    L18nKeys.certTabCA: 'CA-Zertifikate',
    L18nKeys.certTabSSL: 'SSL-Zertifikate',

// Zertifikatsdetails
    L18nKeys.certDetailType: 'Typ',
    L18nKeys.certDetailCommonName: 'Common Name',
    L18nKeys.certDetailOrganization: 'Organisation',
    L18nKeys.certDetailCountry: 'Land',
    L18nKeys.certDetailState: 'Bundesland',
    L18nKeys.certDetailCity: 'Stadt',
    L18nKeys.certDetailIssuerCN: 'Aussteller-CN',
    L18nKeys.certDetailIssuerOrg: 'Aussteller-Organisation',
    L18nKeys.certDetailIssueDate: 'Ausstellungsdatum',
    L18nKeys.certDetailExpiryDate: 'Ablaufdatum',
    L18nKeys.certDetailDaysUntilExpiry: 'Tage bis Ablauf',
    L18nKeys.certDetailEncrypted: 'Verschlüsselt',
    L18nKeys.certDetailSerial: 'Seriennummer',
    L18nKeys.certDetailFilePath: 'Dateipfad',
    L18nKeys.certDetailKeyPath: 'Schlüsselpfad',
    L18nKeys.certDetailChainPath: 'Chain-Pfad',
    L18nKeys.certDetailFullChainPath: 'Vollständiger Chain-Pfad',
    L18nKeys.certDetailChainLength: 'Chain-Länge',
    L18nKeys.certDetailImportedFrom: 'Importiert von',
    L18nKeys.certDetailPurpose: 'Zweck',
    L18nKeys.certDetailPurposeName: 'Zweckname',
    L18nKeys.certYes: 'Ja',
    L18nKeys.certNo: 'Nein',
    L18nKeys.certNA: 'K.A.',
    L18nKeys.certExternal: 'Extern',
    L18nKeys.certCertificates: 'Zertifikate',

// Zertifikat-generieren-Dialog
    L18nKeys.certGenTitle: 'Zertifikat generieren',
    L18nKeys.certGenSubtitle:
        'Füllen Sie das folgende Formular aus, um Ihr Zertifikat zu erstellen',
    L18nKeys.certGenClose: 'Schließen',
    L18nKeys.certGenConfigTitle: 'OpenSSL-Konfiguration',
    L18nKeys.certGenUseCustomConfig:
        'Benutzerdefinierte OpenSSL-Konfiguration verwenden',
    L18nKeys.certGenUsingConfig: 'Verwendet: ',
    L18nKeys.certGenUsingDefault: 'OpenSSL-Standardkonfiguration verwenden',
    L18nKeys.certGenConfigApplied: 'Konfigurationsstandardwerte angewendet',

    L18nKeys.certGenPurposeTitle: 'Zertifikatszweck',
    L18nKeys.certGenSelectPurpose: 'Zweck auswählen *',
    L18nKeys.certGenPurposeHelper:
        'Definiert die Zertifikatsschlüsselverwendung',
    L18nKeys.certGenRequired: 'Erforderlich',
    L18nKeys.certGenKeyUsage: 'Schlüsselverwendung:',
    L18nKeys.certGenExtendedUsage: 'Erweiterte Verwendung:',
    L18nKeys.certGenCustomKeyUsage: 'Benutzerdefinierte Schlüsselverwendung',
    L18nKeys.certGenCustomKeyUsageHint:
        'critical, digitalSignature, keyEncipherment',
    L18nKeys.certGenCustomExtKeyUsage:
        'Benutzerdefinierte erweiterte Schlüsselverwendung',
    L18nKeys.certGenCustomExtKeyUsageHint:
        'serverAuth, clientAuth, codeSigning',
    L18nKeys.certGenCommaSeparated: 'Durch Kommas getrennte Werte',
    L18nKeys.certGenCommonKeyUsage: 'Häufige Schlüsselverwendungswerte:',
    L18nKeys.certGenCommonExtKeyUsage:
        'Häufige erweiterte Schlüsselverwendungswerte:',

    L18nKeys.certGenCATitle: 'CA-Zertifikatsauswahl',
    L18nKeys.certGenSelectCA: 'CA-Zertifikat auswählen *',
    L18nKeys.certGenSelectCAHelper:
        'Wählen Sie aus, welche CA dieses Zertifikat signiert',
    L18nKeys.certGenCAPassword: 'CA-Passwort *',
    L18nKeys.certGenPleaseSelectCA: 'Bitte CA-Zertifikat auswählen',

    L18nKeys.certGenInfoTitle: 'Zertifikatsinformationen',
    L18nKeys.certGenSecurityTitle: 'Sicherheitsoptionen',
    L18nKeys.certGenEncryptKey: 'Privatschlüssel verschlüsseln',
    L18nKeys.certGenEncryptKeyDesc:
        'Privatschlüssel mit einem Passwort schützen',
    L18nKeys.certGenPassword: 'Passwort *',
    L18nKeys.certGenPasswordHelper: 'Starkes Passwort eingeben',

    L18nKeys.certGenGenerating: 'Zertifikat wird generiert...',
    L18nKeys.certGenCancel: 'Abbrechen',
    L18nKeys.certGenGenerate: 'Zertifikat generieren',

// Formularfelder
    L18nKeys.certFieldName: 'Zertifikatsname *',
    L18nKeys.certFieldNameHintCA: 'MeineRootCA',
    L18nKeys.certFieldNameHintSSL: 'beispiel.de',
    L18nKeys.certFieldCountry: 'Ländercode *',
    L18nKeys.certFieldState: 'Bundesland *',
    L18nKeys.certFieldCity: 'Stadt *',
    L18nKeys.certFieldOrganization: 'Organisation *',
    L18nKeys.certFieldOrgUnit: 'Organisationseinheit *',
    L18nKeys.certFieldCommonName: 'Common Name *',
    L18nKeys.certFieldCommonNameHintCA: 'Meine Root CA',
    L18nKeys.certFieldCommonNameHintSSL: 'beispiel.de',
    L18nKeys.certFieldEmail: 'E-Mail',
    L18nKeys.certFieldEmailHint: 'admin@beispiel.de',
    L18nKeys.certFieldSAN: 'Alternative Antragstellernamen',
    L18nKeys.certFieldSANHint: 'www.beispiel.de,mail.beispiel.de',
    L18nKeys.certFieldValidity: 'Gültigkeit (Tage) *',
    L18nKeys.certFieldFromConfig: 'Aus Konfiguration',
    L18nKeys.certFieldInvalidNumber: 'Ungültige Nummer',

// Erfolgsmeldungen
    L18nKeys.certGenSuccessCA: 'CA-Zertifikat erfolgreich generiert',
    L18nKeys.certGenSuccessSSL: 'SSL-Zertifikat erfolgreich generiert',
    L18nKeys.certGenSuccessCustomConfig:
        ' mit benutzerdefinierter Konfiguration',
    L18nKeys.certGenSuccessPurpose: 'Zweck: ',
    L18nKeys.certGenError: 'Fehler: ',

// PFX-Export-Dialog
    L18nKeys.certExportTitle: 'Als PFX exportieren',
    L18nKeys.certExportCertPassword: 'Zertifikatspasswort *',
    L18nKeys.certExportPFXPassword: 'PFX-Passwort *',
    L18nKeys.certExportIncludeCA: 'CA-Zertifikat einschließen',
    L18nKeys.certExportSelectCA: 'CA-Zertifikat auswählen',
    L18nKeys.certExportButton: 'Exportieren',
    L18nKeys.certExportSaveTitle: 'PFX-Datei speichern',
    L18nKeys.certExportSuccess: 'PFX erfolgreich exportiert',
    L18nKeys.certExportError: 'Export-Fehler: ',

// Zertifikatskarten-Status
    L18nKeys.certStatusActive: 'Aktiv',
    L18nKeys.certStatusExpired: 'Abgelaufen',
    L18nKeys.certStatusExpiringSoon: 'Läuft bald ab',

// Zertifikatskarten-Infobeschriftungen
    L18nKeys.certCardIssueDate: 'Ausstellungsdatum',
    L18nKeys.certCardExpiryDate: 'Ablaufdatum',
    L18nKeys.certCardDaysUntilExpiry: 'Tage bis Ablauf',
    L18nKeys.certCardDays: 'Tage',
    L18nKeys.certCardEncrypted: 'Verschlüsselt',
    L18nKeys.certCardChain: 'Chain',
    L18nKeys.certCardCerts: 'Zertifikat(e)',
    L18nKeys.certCardImported: 'Importiert',

// Zertifikatskarten-Aktionen
    L18nKeys.certActionExport: 'Exportieren',
    L18nKeys.certActionDelete: 'Löschen',
  };
}
