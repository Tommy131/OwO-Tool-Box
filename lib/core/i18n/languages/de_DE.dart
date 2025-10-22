// ============================================================================
// Deutsche Übersetzung
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

    // ========== Willkommensseite ==========
    L18nKeys.welcome: 'Willkommen',
    L18nKeys.welcomeMessage:
        'Dies ist ein voll funktionsfähiges Flutter-Anwendungsframework',
    L18nKeys.welcomeDescription:
        'Unterstützt multiplattform-adaptives Layout, perfekt angepasst für Mobilgeräte, Tablets und Desktop-Geräte',
    L18nKeys.exploreFeatures: 'Funktionen erkunden',

    // ========== Spracheinstellungen ==========
    L18nKeys.languageSettings: 'Spracheinstellungen',
    L18nKeys.selectLanguage: 'Sprache auswählen',
    L18nKeys.changingLanguage: 'Sprache wird geändert',

    // ========== Einstellungshauptseite ==========
    L18nKeys.adjustTheme: 'Themamodus und Farbschema anpassen',
    L18nKeys.selectAppLanguage: 'Anzeigesprache der Anwendung auswählen',
    L18nKeys.configureHostMonitor: 'Host-Überwachungsoptionen konfigurieren',

    // ========== Themaeinstellungen ==========
    L18nKeys.themeMode: 'Themamodus',
    L18nKeys.changingTheme: 'Thema wird geändert',
    L18nKeys.themeSettings: 'Themaeinstellungen',
    L18nKeys.themeColorSettings: 'Themafarben',
    L18nKeys.cyberpunkTheme: 'Cyberpunk-Thema',
    L18nKeys.lightTheme: 'Helles Thema',
    L18nKeys.darkTheme: 'Dunkles Thema',
    L18nKeys.systemTheme: 'System folgen',
    L18nKeys.defaultTheme: 'Standardthema',
    L18nKeys.techTheme: 'Tech-Thema',
    L18nKeys.natureTheme: 'Natur-Thema',
    L18nKeys.sunsetTheme: 'Sonnenuntergang-Thema',
    L18nKeys.oceanTheme: 'Ozean-Thema',

    // ========== Host-Monitor-Einstellungen ==========
    L18nKeys.hostMonitorSettings: 'Host-Monitor-Einstellungen',
    L18nKeys.refreshSettings: 'Aktualisierungseinstellungen',
    L18nKeys.hostPollingInterval: 'Host-Abfrageintervall',
    L18nKeys.enterRefreshInterval:
        'Aktualisierungsintervall eingeben (Sekunden)',
    L18nKeys.seconds: 'Sekunden',
    L18nKeys.recommendedInterval:
        'Empfohlen zwischen 1-10 Sekunden, zu kurz kann die Leistung beeinträchtigen',
    L18nKeys.hostCheckSettings: 'Host-Überprüfungseinstellungen',
    L18nKeys.checkTimeout: 'Zeitüberschreitung prüfen',
    L18nKeys.enterTimeout: 'Zeitüberschreitung eingeben (Sekunden)',
    L18nKeys.timeoutDescription:
        'Zeitüberschreitung für die Überprüfung des Host-Online-Status, empfohlen 3-10 Sekunden',
    L18nKeys.backgroundCheckInterval: 'Hintergrundprüfungsintervall',
    L18nKeys.enterCheckInterval: 'Prüfintervall eingeben (Minuten)',
    L18nKeys.minutes: 'Minuten',
    L18nKeys.checkIntervalDescription:
        'Hintergrund-Stillprüfungsintervall für Host-Listenstatus, empfohlen 5-30 Minuten',
    L18nKeys.alertSettings: 'Alarmeinstellungen',
    L18nKeys.enableAlert: 'Alarme aktivieren',
    L18nKeys.enableAlertDescription:
        'Wenn aktiviert, werden Benachrichtigungen gesendet, wenn die Ressourcennutzung den Schwellenwert überschreitet',
    L18nKeys.alertThreshold: 'Alarmschwelle',
    L18nKeys.cpuUsage: 'CPU-Auslastung',
    L18nKeys.memoryUsage: 'Speicherauslastung',
    L18nKeys.diskUsage: 'Festplattenauslastung',
    L18nKeys.uploadSpeed: 'Upload-Geschwindigkeit',
    L18nKeys.downloadSpeed: 'Download-Geschwindigkeit',
    L18nKeys.notificationSettings: 'Benachrichtigungseinstellungen',
    L18nKeys.disconnectNotification: 'Trennungsbenachrichtigung',
    L18nKeys.soundAlert: 'Tonalarm',
    L18nKeys.vibrationAlert: 'Vibrationsalarm',
    L18nKeys.vibrationAlertDescription: 'Nur auf Mobilgeräten wirksam',
    L18nKeys.save: 'Speichern',
    L18nKeys.settingsSaved: 'Einstellungen gespeichert',
    L18nKeys.longRefreshInterval: 'Langes Aktualisierungsintervall',
    L18nKeys.longRefreshIntervalWarning:
        'Sie haben das Aktualisierungsintervall auf {interval} Sekunden eingestellt, was zu verzögerten Datenaktualisierungen führen kann. Fortfahren?',
    L18nKeys.invalidRefreshInterval:
        'Bitte geben Sie ein gültiges Aktualisierungsintervall ein (mindestens 1 Sekunde)',
    L18nKeys.invalidTimeout:
        'Bitte geben Sie eine gültige Zeitüberschreitung ein (1-60 Sekunden)',
    L18nKeys.invalidCheckInterval:
        'Bitte geben Sie ein gültiges Prüfintervall ein (1-1440 Minuten)',

    // ========== Visuelle Effekte ==========
    L18nKeys.visualEffects: 'Visuelle Effekte',
    L18nKeys.visualEffectsDescription: 'Exklusive Effekte für Cyberpunk-Thema',
    L18nKeys.matrixRainEffect: 'Matrix-Regen-Effekt',
    L18nKeys.matrixRainDescription: 'Matrix-Stil Hintergrundanimation',
    L18nKeys.glowEffect: 'Leuchteffekt',
    L18nKeys.glowEffectDescription: 'Button- und Karten-Leuchteffekte',
    L18nKeys.scanningLine: 'Scanlinie',
    L18nKeys.scanningLineDescription: 'Bildschirm-Scanlinienanimation',
    L18nKeys.glitchEffect: 'Glitch-Art',
    L18nKeys.glitchEffectDescription: 'Digitale Glitch-Stil-Effekte',

    // ========== App-Informationen ==========
    L18nKeys.appInfo: 'App-Informationen',
    L18nKeys.appName: 'OwO! Systemwerkzeuge',
    L18nKeys.appDescription:
        'Eine leistungsstarke plattformübergreifende Systemwerkzeugsammlung mit Host-Überwachung, Leistungsanalyse und mehr',
    L18nKeys.appVersion: 'Version',
    L18nKeys.developerInfo: 'Entwicklerinformationen',
    L18nKeys.developerName: 'Entwickler',
    L18nKeys.contactEmail: 'Kontakt-E-Mail',
    L18nKeys.flutterVersion: 'Flutter-Version',
    L18nKeys.serviceHomepage: 'Service-Homepage',
    L18nKeys.openSource: 'Open-Source-Projekt',
    L18nKeys.openSourceDescription:
        'Dieses Projekt verwendet eine Open-Source-Lizenz, Beiträge sind willkommen',
    L18nKeys.viewSourceCode: 'Quellcode anzeigen',
    L18nKeys.license: 'Lizenz',
    L18nKeys.supportDevelopment: 'Entwicklung unterstützen',
    L18nKeys.donationDescription:
        'Wenn Sie dieses Projekt hilfreich finden, erwägen Sie bitte, die Entwicklung zu unterstützen',
    L18nKeys.donateNow: 'Jetzt spenden',
    L18nKeys.topDonors: 'Top-Spender',
    L18nKeys.cannotOpenUrl: 'URL kann nicht geöffnet werden',
    L18nKeys.loadFailed: 'Laden fehlgeschlagen',
    L18nKeys.retry: 'Erneut versuchen',
    L18nKeys.noDonorsYet: 'Noch keine Spendenaufzeichnungen',

    // ========== Tech-Stack-Karte ==========
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
        'Dies ist der Inhalt der Benutzervereinbarung...',
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
    L18nKeys.hostNameHint: 'Bitte Hostname eingeben',
    L18nKeys.pleaseEnterHostName: 'Bitte Hostname eingeben',
    L18nKeys.hostNameMinLength: 'Hostname muss mindestens 2 Zeichen lang sein',
    L18nKeys.hostAddress: 'Host-Adresse',
    L18nKeys.hostAddressHint: 'z.B.: 192.168.1.100',
    L18nKeys.pleaseEnterHostAddress: 'Bitte Host-Adresse eingeben',
    L18nKeys.hostAddressNoSpaces:
        'Host-Adresse darf keine Leerzeichen enthalten',
    L18nKeys.port: 'Port',
    L18nKeys.portHint: 'Bitte Portnummer eingeben',
    L18nKeys.pleaseEnterPort: 'Bitte Portnummer eingeben',
    L18nKeys.portRangeError: 'Portnummer muss zwischen 1-65535 liegen',
    L18nKeys.password: 'Passwort',
    L18nKeys.pleaseEnterPassword: 'Bitte Passwort eingeben',
    L18nKeys.passwordMinLength: 'Passwort muss mindestens 6 Zeichen lang sein',
    L18nKeys.testConnection: 'Verbindung testen',
    L18nKeys.saveChanges: 'Änderungen speichern',
    L18nKeys.requiredFieldNote: '* Pflichtfeld',
    L18nKeys.hostUpdated: 'Host-Informationen aktualisiert',
    L18nKeys.hostAdded: 'Host erfolgreich hinzugefügt',
    L18nKeys.saveFailed: 'Speichern fehlgeschlagen',
    L18nKeys.testingConnection: 'Verbindung wird getestet',
    L18nKeys.connectionSuccess: 'Verbindung erfolgreich',
    L18nKeys.connectionFailed: 'Verbindung fehlgeschlagen',
    L18nKeys.connectionSuccessMessage:
        'Host-Verbindung ist normal, Konfiguration ist gültig',
    L18nKeys.connectionFailedMessage:
        'Verbindung zum Host nicht möglich, bitte Konfiguration überprüfen',
    L18nKeys.connectionTestError: 'Verbindungstestfehler',

    // ========== Alarmverlaufsseite ==========
    L18nKeys.alertHistory: 'Alarmverlauf',
    L18nKeys.clearHistory: 'Verlauf löschen',
    L18nKeys.noAlertRecords: 'Keine Alarmaufzeichnungen',
    L18nKeys.acknowledge: 'Bestätigen',
    L18nKeys.alertAcknowledged: 'Alarm bestätigt',
    L18nKeys.confirmClearAlertHistory:
        'Sind Sie sicher, dass Sie alle Alarmverlaufsaufzeichnungen löschen möchten?',
    L18nKeys.clear: 'Löschen',
    L18nKeys.historyCleared: 'Verlauf gelöscht',

    // ========== Host-Monitor-Seite ==========
    L18nKeys.hostMonitor: 'Host-Monitor',
    L18nKeys.loadHostListFailed: 'Laden der Host-Liste fehlgeschlagen',
    L18nKeys.loadGeoInfoFailed:
        'Laden der Geolokalisierungsinformationen fehlgeschlagen',
    L18nKeys.hostStatusRefreshed: 'Host-Status aktualisiert',
    L18nKeys.refreshFailed: 'Aktualisierung fehlgeschlagen',
    L18nKeys.refreshHostStatus: 'Host-Status aktualisieren',
    L18nKeys.forceDisconnectMessage: 'Host-Überwachung zwangsweise getrennt!',
    L18nKeys.safeDisconnectMessage: 'Host-Überwachung sicher getrennt.',
    L18nKeys.disconnect: 'Trennen',
    L18nKeys.loadingGeoInfo:
        'IP-Geolokalisierungsinformationen werden geladen...',
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
    L18nKeys.confirmDeleteHostPart1: 'Sind Sie sicher, dass Sie den Host',
    L18nKeys.confirmDeleteHostPart2:
        ' löschen möchten?\n\nDieser Vorgang löscht auch alle Alarmaufzeichnungen für diesen Host.',
    L18nKeys.delete: 'Löschen',
    L18nKeys.hostDeleted: 'Host gelöscht',
    L18nKeys.deleteFailed: 'Löschen fehlgeschlagen',
    L18nKeys.timeout: 'Zeitüberschreitung',

    // ========== Host-Detailseite ==========
    L18nKeys.waitingSystemData: 'Warten auf Systemdaten',
    L18nKeys.connectedGettingSystemInfo:
        'Verbunden, Systeminformationen werden abgerufen...',
    L18nKeys.unnamedHost: 'Unbenannter Host',
    L18nKeys.connected: 'Verbunden',
    L18nKeys.cpuUsageTrend: 'CPU-Auslastungstrend',
    L18nKeys.memoryUsageTrend: 'Speicherauslastungstrend',
    L18nKeys.diskUsageTrend: 'Festplattenauslastungstrend',
    L18nKeys.uploadSpeedLabel: 'Upload-Geschwindigkeit',
    L18nKeys.downloadSpeedLabel: 'Download-Geschwindigkeit',
    L18nKeys.load1min: '1-Minuten-Last',
    L18nKeys.load5min: '5-Minuten-Last',
    L18nKeys.load15min: '15-Minuten-Last',
    L18nKeys.cpuCoreUsage: 'CPU-Kern-Auslastung',
    L18nKeys.systemInfo: 'Systeminformationen',
    L18nKeys.processor: 'Prozessor',
    L18nKeys.processorCores: 'Prozessorkerne',
    L18nKeys.coresUnit: 'Kerne',
    L18nKeys.processorFrequency: 'Prozessorfrequenz',
    L18nKeys.processCount: 'Prozessanzahl',
    L18nKeys.countUnit: '',
    L18nKeys.systemLoad: 'Systemlast',
    L18nKeys.systemArchitecture: 'Systemarchitektur',
    L18nKeys.operatingSystem: 'Betriebssystem',
    L18nKeys.kernelVersion: 'Kernel-Version',
    L18nKeys.hostname: 'Hostname',
    L18nKeys.uptime: 'Betriebszeit',
    L18nKeys.memoryDetails: 'Speicherdetails',
    L18nKeys.usageRate: 'Nutzungsrate',
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
  };
}
