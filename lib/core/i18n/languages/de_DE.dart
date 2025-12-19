// ============================================================================
// Deutsch (Deutschland) Übersetzung
// ============================================================================

import '../localization_keys.dart';

class DeDE {
  static const Map<String, String> translations = {
    // ========== Fenstersteuerung ==========
    L18nKeys.ok: 'OK',
    L18nKeys.cancel: 'Abbrechen',
    L18nKeys.minimize: 'Minimieren',
    L18nKeys.maximize: 'Maximieren',
    L18nKeys.restore: 'Wiederherstellen',
    L18nKeys.close: 'Schließen',

    // ========== Themeneinstellungen ==========
    L18nKeys.themeSettings: 'Themeneinstellungen',

    // ========== Spracheinstellungen ==========
    L18nKeys.languageSettings: 'Spracheninstellungen',
    L18nKeys.selectLanguage: 'Sprache auswählen',
    L18nKeys.changingLanguage: 'Sprache wird geändert',

    // ========== Einstellungshauptseite ==========
    L18nKeys.adjustTheme: 'Theme-Modus und Farbschema anpassen',
    L18nKeys.selectAppLanguage: 'Anzeigesprache der Anwendung auswählen',
    L18nKeys.configureHostMonitor: 'Host-Überwachungsoptionen konfigurieren',

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

    // ========== App-Informationen ==========
    L18nKeys.appInfo: 'App-Informationen',
    L18nKeys.appName: 'App Name',
    L18nKeys.appDescription: 'App Beschreibung',
    L18nKeys.descriptionMessage:
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
  };
}
