// ============================================================================
// Français (France) Traduction
// ============================================================================

import '../localization_keys.dart';

class FrFR {
  static const Map<String, String> translations = {
    // ========== Général ==========
    L18nKeys.appTitle: 'OwO! Outils Système',
    L18nKeys.ok: 'OK',
    L18nKeys.cancel: 'Annuler',

    // ========== Navigation ==========
    L18nKeys.menu: 'Menu',
    L18nKeys.home: 'Accueil',
    L18nKeys.settings: 'Paramètres',
    L18nKeys.about: 'À propos',
    L18nKeys.monitor: 'Moniteur',
    L18nKeys.ssl: 'Gestionnaire de Certificats SSL',

    // ========== Page de Bienvenue ==========
    L18nKeys.welcome: 'Bienvenue',
    L18nKeys.welcomeMessage: 'Un framework d\'application Flutter complet',
    L18nKeys.welcomeDescription:
        'Prend en charge les mises en page adaptatives multiplateformes, parfaitement adapté aux appareils mobiles, tablettes et ordinateurs de bureau',
    L18nKeys.exploreFeatures: 'Explorer les Fonctionnalités',

    // ========== Paramètres de Langue ==========
    L18nKeys.languageSettings: 'Paramètres de Langue',
    L18nKeys.selectLanguage: 'Sélectionner la Langue',
    L18nKeys.changingLanguage: 'Changement de Langue',

    // ========== Page Principale des Paramètres ==========
    L18nKeys.adjustTheme: 'Ajuster le mode de thème et le jeu de couleurs',
    L18nKeys.selectAppLanguage:
        'Sélectionner la langue d\'affichage de l\'application',
    L18nKeys.configureHostMonitor:
        'Configurer les options de surveillance d\'hôte',

    // ========== Paramètres de Thème ==========
    L18nKeys.themeMode: 'Mode de Thème',
    L18nKeys.changingTheme: 'Changement de Thème',
    L18nKeys.themeSettings: 'Paramètres de Thème',
    L18nKeys.themeColorSettings: 'Couleurs du Thème',
    L18nKeys.cyberpunkTheme: 'Thème Cyberpunk',
    L18nKeys.lightTheme: 'Thème Clair',
    L18nKeys.darkTheme: 'Thème Sombre',
    L18nKeys.systemTheme: 'Par Défaut du Système',
    L18nKeys.defaultTheme: 'Thème par Défaut',
    L18nKeys.techTheme: 'Thème Tech',
    L18nKeys.natureTheme: 'Thème Nature',
    L18nKeys.sunsetTheme: 'Thème Coucher de Soleil',
    L18nKeys.oceanTheme: 'Thème Océan',

    // ========== Paramètres du Moniteur d'Hôte ==========
    L18nKeys.hostMonitorSettings: 'Paramètres du Moniteur d\'Hôte',
    L18nKeys.refreshSettings: 'Paramètres d\'Actualisation',
    L18nKeys.hostPollingInterval: 'Intervalle d\'Interrogation d\'Hôte',
    L18nKeys.enterRefreshInterval:
        'Entrer l\'intervalle d\'actualisation (secondes)',
    L18nKeys.seconds: 'secondes',
    L18nKeys.recommendedInterval:
        'Plage recommandée : 1-10 secondes. Trop court peut affecter les performances',
    L18nKeys.hostCheckSettings: 'Paramètres de Vérification d\'Hôte',
    L18nKeys.checkTimeout: 'Délai de Vérification',
    L18nKeys.enterTimeout: 'Entrer le délai (secondes)',
    L18nKeys.timeoutDescription:
        'Délai pour vérifier l\'état en ligne de l\'hôte, recommandé 3-10 secondes',
    L18nKeys.backgroundCheckInterval:
        'Intervalle de Vérification en Arrière-plan',
    L18nKeys.enterCheckInterval:
        'Entrer l\'intervalle de vérification (minutes)',
    L18nKeys.minutes: 'minutes',
    L18nKeys.checkIntervalDescription:
        'Intervalle pour la vérification silencieuse en arrière-plan de la liste d\'hôtes, recommandé 5-30 minutes',
    L18nKeys.alertSettings: 'Paramètres d\'Alerte',
    L18nKeys.enableAlert: 'Activer les Alertes',
    L18nKeys.enableAlertDescription:
        'Envoyer des notifications lorsque l\'utilisation des ressources dépasse les seuils',
    L18nKeys.alertThreshold: 'Seuil d\'Alerte',
    L18nKeys.cpuUsage: 'Utilisation du CPU',
    L18nKeys.memoryUsage: 'Utilisation de la Mémoire',
    L18nKeys.diskUsage: 'Utilisation du Disque',
    L18nKeys.uploadSpeed: 'Vitesse de Téléversement',
    L18nKeys.downloadSpeed: 'Vitesse de Téléchargement',
    L18nKeys.notificationSettings: 'Paramètres de Notification',
    L18nKeys.disconnectNotification: 'Notification de Déconnexion',
    L18nKeys.soundAlert: 'Alerte Sonore',
    L18nKeys.vibrationAlert: 'Alerte Vibration',
    L18nKeys.vibrationAlertDescription:
        'Uniquement efficace sur les appareils mobiles',
    L18nKeys.save: 'Enregistrer',
    L18nKeys.settingsSaved: 'Paramètres Enregistrés',
    L18nKeys.longRefreshInterval: 'Intervalle d\'Actualisation Long',
    L18nKeys.longRefreshIntervalWarning:
        'Vous avez défini l\'intervalle d\'actualisation sur {interval} secondes, ce qui peut entraîner des retards dans les mises à jour des données. Continuer ?',
    L18nKeys.invalidRefreshInterval:
        'Veuillez entrer un intervalle d\'actualisation valide (au moins 1 seconde)',
    L18nKeys.invalidTimeout:
        'Veuillez entrer un délai de vérification valide (1-60 secondes)',
    L18nKeys.invalidCheckInterval:
        'Veuillez entrer un intervalle de vérification valide (1-1440 minutes)',

    // ========== Effets Visuels ==========
    L18nKeys.visualEffects: 'Effets Visuels',
    L18nKeys.visualEffectsDescription:
        'Effets exclusifs pour le thème Cyberpunk',
    L18nKeys.matrixRainEffect: 'Effet Pluie Matrix',
    L18nKeys.matrixRainDescription: 'Animation d\'arrière-plan style Matrix',
    L18nKeys.glowEffect: 'Effet Lumineux',
    L18nKeys.glowEffectDescription: 'Effets lumineux sur les boutons et cartes',
    L18nKeys.scanningLine: 'Ligne de Balayage',
    L18nKeys.scanningLineDescription: 'Animation de ligne de balayage d\'écran',
    L18nKeys.glitchEffect: 'Effet Glitch',
    L18nKeys.glitchEffectDescription: 'Effets de style glitch numérique',

    // ========== Informations sur l'Application ==========
    L18nKeys.appInfo: 'Informations sur l\'Application',
    L18nKeys.appName: 'OwO! Outils Système',
    L18nKeys.appDescription:
        'Une suite d\'outils système multiplateformes puissante prenant en charge la surveillance d\'hôte, l\'analyse de performance et plus',
    L18nKeys.appVersion: 'Version',
    L18nKeys.developerInfo: 'Informations sur le Développeur',
    L18nKeys.developerName: 'Développeur',
    L18nKeys.contactEmail: 'Email de Contact',
    L18nKeys.flutterVersion: 'Version de Flutter',
    L18nKeys.serviceHomepage: 'Page d\'Accueil du Service',
    L18nKeys.openSource: 'Open Source',
    L18nKeys.openSourceDescription:
        'Ce projet est sous licence open source. Les contributions sont les bienvenues',
    L18nKeys.viewSourceCode: 'Voir le Code Source',
    L18nKeys.license: 'Licence',
    L18nKeys.supportDevelopment: 'Soutenir le Développement',
    L18nKeys.donationDescription:
        'Si vous trouvez ce projet utile, veuillez envisager de soutenir le développement',
    L18nKeys.donateNow: 'Faire un Don Maintenant',
    L18nKeys.topDonors: 'Principaux Donateurs',
    L18nKeys.cannotOpenUrl: 'Impossible d\'ouvrir l\'URL',
    L18nKeys.loadFailed: 'Échec du Chargement',
    L18nKeys.retry: 'Réessayer',
    L18nKeys.noDonorsYet: 'Pas encore d\'enregistrements de dons',

    // ========== Cartes de Pile Technologique ==========
    L18nKeys.techStack: 'Pile Technologique',
    L18nKeys.flutter: 'Flutter',
    L18nKeys.flutterDescription: 'Framework UI multiplateformes',
    L18nKeys.goLang: 'Langage Go',
    L18nKeys.goLangDescription: 'Service backend haute performance',
    L18nKeys.tcpIp: 'TCP/IP',
    L18nKeys.tcpIpDescription: 'Protocole de communication réseau',
    L18nKeys.materialDesign: 'Material Design',
    L18nKeys.materialDesignDescription: 'Langage de conception moderne',

    // ========== Accord Utilisateur ==========
    L18nKeys.userAgreement: 'Accord Utilisateur',
    L18nKeys.agreementContent:
        '1. Ce framework d\'application est uniquement à des fins d\'apprentissage et de développement\n2. Veuillez respecter les lois et règlements pertinents\n3. Prend en charge les plateformes mobiles, tablettes et PC\n4. Le développeur se réserve tous les droits\n5. Ce projet suit la licence open source MIT\n6. Veuillez lire attentivement la documentation avant utilisation\n7. Le développeur se réserve le droit d\'interprétation finale',
    L18nKeys.github: 'GitHub',

    // ========== Informations sur l'Appareil ==========
    L18nKeys.deviceInfo: 'Informations sur l\'Appareil',
    L18nKeys.screenSize: 'Taille de l\'Écran',
    L18nKeys.deviceType: 'Type d\'Appareil',
    L18nKeys.mobileDevice: 'Mobile',
    L18nKeys.tabletDevice: 'Tablette',
    L18nKeys.desktopDevice: 'Bureau',
    L18nKeys.layoutMode: 'Mode de Mise en Page',
    L18nKeys.adaptiveLayout: 'Mise en Page Adaptative',

    // ========== Contrôles de Fenêtre ==========
    L18nKeys.minimize: 'Réduire',
    L18nKeys.maximize: 'Agrandir',
    L18nKeys.restore: 'Restaurer',
    L18nKeys.close: 'Fermer',

    // ========== Page d'Édition d'Hôte ==========
    L18nKeys.editHost: 'Modifier l\'Hôte',
    L18nKeys.addHost: 'Ajouter un Hôte',
    L18nKeys.hostName: 'Nom de l\'Hôte',
    L18nKeys.hostNameHint: 'Entrer le nom de l\'hôte',
    L18nKeys.pleaseEnterHostName: 'Veuillez entrer le nom de l\'hôte',
    L18nKeys.hostNameMinLength:
        'Le nom de l\'hôte doit contenir au moins 2 caractères',
    L18nKeys.hostAddress: 'Adresse de l\'Hôte',
    L18nKeys.hostAddressHint: 'ex. 192.168.1.100',
    L18nKeys.pleaseEnterHostAddress: 'Veuillez entrer l\'adresse de l\'hôte',
    L18nKeys.hostAddressNoSpaces:
        'L\'adresse de l\'hôte ne peut pas contenir d\'espaces',
    L18nKeys.port: 'Port',
    L18nKeys.portHint: 'Entrer le numéro de port',
    L18nKeys.pleaseEnterPort: 'Veuillez entrer le numéro de port',
    L18nKeys.portRangeError: 'Le numéro de port doit être entre 1-65535',
    L18nKeys.password: 'Mot de Passe',
    L18nKeys.pleaseEnterPassword: 'Veuillez entrer le mot de passe',
    L18nKeys.passwordMinLength:
        'Le mot de passe doit contenir au moins 6 caractères',
    L18nKeys.testConnection: 'Tester la Connexion',
    L18nKeys.saveChanges: 'Enregistrer les Modifications',
    L18nKeys.requiredFieldNote: '* Champs obligatoires',
    L18nKeys.hostUpdated: 'Informations de l\'hôte mises à jour',
    L18nKeys.hostAdded: 'Hôte ajouté avec succès',
    L18nKeys.saveFailed: 'Échec de l\'enregistrement',
    L18nKeys.testingConnection: 'Test de connexion',
    L18nKeys.connectionSuccess: 'Connexion réussie',
    L18nKeys.connectionFailed: 'Échec de connexion',
    L18nKeys.connectionSuccessMessage:
        'La connexion à l\'hôte est normale, la configuration est valide',
    L18nKeys.connectionFailedMessage:
        'Impossible de se connecter à l\'hôte, veuillez vérifier la configuration',
    L18nKeys.connectionTestError: 'Erreur de test de connexion',

    // ========== Historique des Alertes ==========
    L18nKeys.alertHistory: 'Historique des Alertes',
    L18nKeys.clearHistory: 'Effacer l\'Historique',
    L18nKeys.noAlertRecords: 'Aucun enregistrement d\'alerte',
    L18nKeys.acknowledge: 'Reconnaître',
    L18nKeys.alertAcknowledged: 'Alerte reconnue',
    L18nKeys.confirmClearAlertHistory:
        'Êtes-vous sûr de vouloir effacer tout l\'historique des alertes ?',
    L18nKeys.clear: 'Effacer',
    L18nKeys.historyCleared: 'Historique effacé',

    // ========== Moniteur d'Hôte ==========
    L18nKeys.hostMonitor: 'Moniteur d\'Hôte',
    L18nKeys.loadHostListFailed: 'Échec du chargement de la liste d\'hôtes',
    L18nKeys.loadGeoInfoFailed:
        'Échec du chargement des informations de localisation géographique',
    L18nKeys.hostStatusRefreshed: 'État de l\'hôte actualisé',
    L18nKeys.refreshFailed: 'Échec de l\'actualisation',
    L18nKeys.refreshHostStatus: 'Actualiser l\'État de l\'Hôte',
    L18nKeys.forceDisconnectMessage:
        'Surveillance d\'hôte déconnectée de force !',
    L18nKeys.safeDisconnectMessage:
        'Surveillance d\'hôte déconnectée en toute sécurité.',
    L18nKeys.disconnect: 'Déconnecter',
    L18nKeys.loadingGeoInfo:
        'Chargement des informations de localisation géographique IP...',
    L18nKeys.loadingHostList: 'Chargement de la liste d\'hôtes...',
    L18nKeys.connecting: 'Connexion en cours...',
    L18nKeys.pleaseWait: 'Veuillez patienter',
    L18nKeys.noSavedHosts: 'Aucun hôte enregistré',
    L18nKeys.clickToAddFirstHost:
        'Cliquez sur le bouton en bas à droite pour ajouter votre premier hôte',
    L18nKeys.addNow: 'Ajouter Maintenant',
    L18nKeys.total: 'Total',
    L18nKeys.online: 'En ligne',
    L18nKeys.offline: 'Hors ligne',
    L18nKeys.error: 'Erreur',
    L18nKeys.confirmDelete: 'Confirmer la Suppression',
    L18nKeys.confirmDeleteHostPart1:
        'Êtes-vous sûr de vouloir supprimer l\'hôte',
    L18nKeys.confirmDeleteHostPart2:
        ' ?\n\nCette action supprimera également tous les enregistrements d\'alerte pour cet hôte.',
    L18nKeys.delete: 'Supprimer',
    L18nKeys.hostDeleted: 'Hôte supprimé',
    L18nKeys.deleteFailed: 'Échec de la suppression',
    L18nKeys.timeout: 'Délai d\'attente dépassé',

    // ========== Dialogues ==========
    L18nKeys.connectionTimeout: 'Délai de Connexion Dépassé',
    L18nKeys.connectionTimeoutMessage:
        'Impossible de se connecter à l\'hôte "{hostName}"\n\nVeuillez vérifier :\n• Le serveur est en cours d\'exécution\n• La connexion réseau est normale\n• Les paramètres du pare-feu',
    L18nKeys.tokenValidationFailed: 'Échec de Validation du Token',
    L18nKeys.tokenValidationFailedMessage:
        'Le token d\'accès pour l\'hôte "{hostName}" est incorrect',

    // ========== Page de Détails de l'Hôte ==========
    L18nKeys.waitingSystemData: 'En attente des données système',
    L18nKeys.connectedGettingSystemInfo:
        'Connecté, récupération des informations système...',
    L18nKeys.unnamedHost: 'Hôte Sans Nom',
    L18nKeys.connected: 'Connecté',
    L18nKeys.cpuUsageTrend: 'Tendance d\'Utilisation du CPU',
    L18nKeys.memoryUsageTrend: 'Tendance d\'Utilisation de la Mémoire',
    L18nKeys.diskUsageTrend: 'Tendance d\'Utilisation du Disque',
    L18nKeys.uploadSpeedLabel: 'Vitesse de Téléversement',
    L18nKeys.downloadSpeedLabel: 'Vitesse de Téléchargement',
    L18nKeys.load1min: 'Charge 1 Min',
    L18nKeys.load5min: 'Charge 5 Min',
    L18nKeys.load15min: 'Charge 15 Min',
    L18nKeys.cpuCoreUsage: 'Utilisation des Cœurs CPU',
    L18nKeys.systemInfo: 'Informations Système',
    L18nKeys.processor: 'Processeur',
    L18nKeys.processorCores: 'Cœurs du Processeur',
    L18nKeys.coresUnit: 'cœurs',
    L18nKeys.processorFrequency: 'Fréquence du Processeur',
    L18nKeys.processCount: 'Nombre de Processus',
    L18nKeys.countUnit: 'nombre',
    L18nKeys.systemLoad: 'Charge Système',
    L18nKeys.systemArchitecture: 'Architecture Système',
    L18nKeys.operatingSystem: 'Système d\'Exploitation',
    L18nKeys.kernelVersion: 'Version du Noyau',
    L18nKeys.hostname: 'Nom d\'Hôte',
    L18nKeys.uptime: 'Temps de Fonctionnement',
    L18nKeys.memoryDetails: 'Détails de la Mémoire',
    L18nKeys.usageRate: 'Taux d\'Utilisation',
    L18nKeys.totalMemory: 'Mémoire Totale',
    L18nKeys.usedMemory: 'Mémoire Utilisée',
    L18nKeys.availableMemory: 'Mémoire Disponible',
    L18nKeys.diskDetails: 'Détails du Disque',
    L18nKeys.used: 'Utilisé',
    L18nKeys.networkDetails: 'Détails du Réseau',
    L18nKeys.upload: 'Téléversement',
    L18nKeys.download: 'Téléchargement',
    L18nKeys.bytesSent: 'Octets Envoyés',
    L18nKeys.bytesReceived: 'Octets Reçus',

    // ========== Gestionnaire de Certificats SSL ==========
    L18nKeys.sslCertificateManager: 'Gestionnaire de Certificats SSL',
    L18nKeys.sslBack: 'Retour',
    L18nKeys.sslToggleTheme: 'Changer de Thème',
    L18nKeys.sslWelcomeTitle:
        'Bienvenue dans le Gestionnaire de Certificats SSL',
    L18nKeys.sslWelcomeSubtitle: 'Gérez vos certificats OpenSSL facilement',
    L18nKeys.sslTotalCertificates: 'Certificats Totaux',
    L18nKeys.sslCACertificates: 'Certificats CA',
    L18nKeys.sslSSLCertificates: 'Certificats SSL',
    L18nKeys.sslExpired: 'Expiré',
    L18nKeys.sslNavigation: 'Navigation',
    L18nKeys.sslCertificates: 'Certificats',
    L18nKeys.sslManageCertificates: 'Gérer les Certificats',
    L18nKeys.sslConfig: 'Configuration',
    L18nKeys.sslOpenSSLConfiguration: 'Configuration OpenSSL',
    L18nKeys.sslAppSettings: 'Paramètres de l\'Application',

    // ========== Écran de Paramètres ==========
    L18nKeys.settingsSelectCertDirectory:
        'Sélectionner le répertoire de stockage des certificats',
    L18nKeys.settingsSelectConfigFile:
        'Sélectionner le fichier de configuration OpenSSL',
    L18nKeys.settingsCreateConfigFile:
        'Créer un fichier de configuration OpenSSL',
    L18nKeys.settingsRequired: 'Obligatoire',
    L18nKeys.settingsSaveSuccess: 'Paramètres enregistrés avec succès',
    L18nKeys.settingsSaveError:
        'Erreur lors de l\'enregistrement des paramètres : {error}',
    L18nKeys.settingsCertStorage: 'Stockage des Certificats',
    L18nKeys.settingsCertStoragePath: 'Chemin de Stockage des Certificats *',
    L18nKeys.settingsCertPathHint: '/chemin/vers/certificats',
    L18nKeys.settingsCertStorageDesc:
        'Tous les certificats générés seront stockés dans ce répertoire',
    L18nKeys.settingsOpenSSLConfig: 'Configuration OpenSSL',
    L18nKeys.settingsConfigFilePath: 'Chemin du Fichier de Configuration *',
    L18nKeys.settingsConfigPathHint: '/chemin/vers/openssl.cnf',
    L18nKeys.settingsCreateNew: 'Créer Nouveau',
    L18nKeys.settingsSelectExisting: 'Sélectionner Existant',
    L18nKeys.settingsConfigFileDesc:
        'Fichier de modèle de configuration OpenSSL. Utilisé lors de la génération de certificats.',
    L18nKeys.settingsCACertDefaults: 'Paramètres par Défaut du Certificat CA',
    L18nKeys.settingsDefaultCAName: 'Nom CA par Défaut *',
    L18nKeys.settingsCANameHint: 'MonCAracine',
    L18nKeys.settingsEncryptCAByDefault: 'Chiffrer CA par Défaut',
    L18nKeys.settingsEncryptCADesc:
        'Chiffrer automatiquement la clé privée CA lors de la génération',
    L18nKeys.settingsDefaultCAPassword: 'Mot de Passe CA par Défaut',
    L18nKeys.settingsCAPasswordHint: 'Laisser vide pour demander à chaque fois',
    L18nKeys.settingsPasswordWarning:
        'Avertissement : Non recommandé de stocker les mots de passe en production',
    L18nKeys.settingsAbout: 'À propos',
    L18nKeys.settingsAppName: 'Gestionnaire de Certificats SSL',
    L18nKeys.settingsAppVersion: 'Version 1.0.0',
    L18nKeys.settingsAppDescription:
        'Application professionnelle de gestion de certificats OpenSSL construite avec Flutter.',
    L18nKeys.settingsPoweredBy: 'Propulsé par OpenSSL',
    L18nKeys.settingsReset: 'Réinitialiser',
    L18nKeys.settingsSaveSettings: 'Enregistrer les Paramètres',

    // ========== Écran de Configuration OpenSSL ==========
    L18nKeys.configLoadError:
        'Erreur lors du chargement de la configuration : {error}',
    L18nKeys.configSaveSuccess: 'Configuration enregistrée avec succès',
    L18nKeys.configSaveError:
        'Erreur lors de l\'enregistrement de la configuration : {error}',
    L18nKeys.configResetToDefault: 'Réinitialiser aux Valeurs par Défaut',
    L18nKeys.configResetConfirm:
        'Êtes-vous sûr de vouloir réinitialiser la configuration aux valeurs par défaut ? Cela écrasera votre configuration actuelle.',
    L18nKeys.configCancel: 'Annuler',
    L18nKeys.configReset: 'Réinitialiser',
    L18nKeys.configEditHint:
        'Modifier le modèle de configuration OpenSSL. Ce modèle sera utilisé lors de la génération de certificats.',
    L18nKeys.configPlaceholder: 'Configuration OpenSSL...',
    L18nKeys.configResetToDefaultBtn: 'Réinitialiser aux Valeurs par Défaut',
    L18nKeys.configSaveConfiguration: 'Enregistrer la Configuration',

    // ========== Écran de Gestion des Certificats ==========
    L18nKeys.certImport: 'Importer',
    L18nKeys.certGenerateCA: 'Générer un Certificat CA',
    L18nKeys.certGenerateSSL: 'Générer un Certificat SSL',
    L18nKeys.certPath: 'Chemin',
    L18nKeys.certCopyFullChainPath: 'Copier le chemin de la chaîne complète',
    L18nKeys.certClose: 'Fermer',
    L18nKeys.certDeleteTitle: 'Supprimer le Certificat',
    L18nKeys.certDeleteConfirm:
        'Êtes-vous sûr de vouloir supprimer le certificat {name} ?',
    L18nKeys.certCancel: 'Annuler',
    L18nKeys.certDelete: 'Supprimer',
    L18nKeys.certDeleteSuccess: 'Certificat supprimé avec succès',
    L18nKeys.certImportCertificate: 'Importer un Certificat',
    L18nKeys.certImportSSLTitle: 'Importer un Certificat SSL',
    L18nKeys.certImportSSLDesc:
        'Importer un certificat SSL complet (certificat + clé privée + chaîne)',
    L18nKeys.certImportCATitle: 'Importer un Certificat CA',
    L18nKeys.certImportCADesc:
        'Importer un certificat CA racine ou intermédiaire',
    L18nKeys.certImportPFXTitle: 'Importer PFX/P12',
    L18nKeys.certImportPFXDesc:
        'Importer un package de certificats au format PFX ou P12',

    // ========== Écran de Gestion des Certificats ==========
    L18nKeys.certSearchPlaceholder: 'Rechercher des certificats...',
    L18nKeys.certNoFound: 'Aucun certificat trouvé',

    // Dialogue d'Importation de Certificat SSL
    L18nKeys.importSslCertificate: 'Importer un Certificat SSL',
    L18nKeys.selectSslCertificateFile:
        'Sélectionner le fichier de certificat SSL',
    L18nKeys.selectPrivateKeyFile: 'Sélectionner le fichier de clé privée',
    L18nKeys.selectCertificateChainFile:
        'Sélectionner le fichier de chaîne de certificats',
    L18nKeys.invalidCertificateFile: 'Fichier de certificat non valide',
    L18nKeys.caCertificateWarning:
        'Ceci semble être un certificat CA. Veuillez utiliser la fonction "Importer un certificat PEM".',
    L18nKeys.importedSslCertificate: 'Certificat SSL importé',
    L18nKeys.sslCertificateValidatedSuccessfully:
        'Certificat SSL validé avec succès',
    L18nKeys.validationError: 'Erreur de Validation',
    L18nKeys.invalidPrivateKeyOrPassword:
        'Fichier de clé privée non valide ou mot de passe incorrect',
    L18nKeys.certificateKeyMismatch:
        'Le certificat et la clé privée ne correspondent pas',
    L18nKeys.privateKeyValidatedSuccessfully: 'Clé privée validée avec succès',
    L18nKeys.noCertificatesFoundInChain:
        'Aucun certificat trouvé dans le fichier de chaîne',
    L18nKeys.certificateChainValidated:
        'Chaîne de certificats validée avec succès',
    L18nKeys.certificates: 'certificats',
    L18nKeys.chainValidationError: 'Erreur de validation de chaîne',
    L18nKeys.pleaseValidateCertificateFirst:
        'Veuillez d\'abord valider le certificat',
    L18nKeys.pleaseValidatePrivateKeyFirst:
        'Veuillez d\'abord valider la clé privée',
    L18nKeys.pleaseValidateChainFirst: 'Veuillez d\'abord valider la chaîne',
    L18nKeys.sslCertificateImportedSuccessfully:
        'Certificat SSL importé avec succès',
    L18nKeys.importError: 'Erreur d\'Importation',
    L18nKeys.importSslCertificateDescription:
        'Importer un certificat SSL existant avec clé privée et chaîne de certificats. Prend en charge le format PEM.',
    L18nKeys.sslCertificateFileRequired:
        'Fichier de Certificat SSL (Obligatoire)',
    L18nKeys.selectPemCrtCerFile: 'Sélectionner un fichier .pem, .crt ou .cer',
    L18nKeys.required: 'Obligatoire',
    L18nKeys.validateCertificate: 'Valider le Certificat',
    L18nKeys.sslCertificate: 'Certificat SSL',
    L18nKeys.issuer: 'Émetteur',
    L18nKeys.expiry: 'Expiration',
    L18nKeys.certificateNameRequired: 'Nom du Certificat (Obligatoire)',
    L18nKeys.enterFriendlyName: 'Entrer un nom convivial',
    L18nKeys.includePrivateKey: 'Inclure la Clé Privée',
    L18nKeys.privateKeyFileRequired: 'Fichier de Clé Privée (Obligatoire)',
    L18nKeys.selectPemKeyFile: 'Sélectionner un fichier .pem ou .key',
    L18nKeys.privateKeyIsEncrypted: 'La clé privée est chiffrée',
    L18nKeys.privateKeyPasswordRequired:
        'Mot de Passe de Clé Privée (Obligatoire)',
    L18nKeys.validatePrivateKey: 'Valider la Clé Privée',
    L18nKeys.includeCertificateChain: 'Inclure la Chaîne de Certificats',
    L18nKeys.intermediateRootCaCertificates:
        'Certificats CA intermédiaires et racine',
    L18nKeys.certificateChainFile: 'Fichier de Chaîne de Certificats',
    L18nKeys.selectChainPemFile:
        'Sélectionner un fichier .pem contenant la chaîne de certificats',
    L18nKeys.validateChain: 'Valider la Chaîne',
    L18nKeys.chainContains: 'La chaîne contient',
    L18nKeys.import: 'Importer',
// Dialogue d'Importation PFX
    L18nKeys.importFromPfx: 'Importer depuis PFX',
    L18nKeys.selectPfxFile: 'Sélectionner un Fichier PFX',
    L18nKeys.pfxFileRequired: 'Fichier PFX (Obligatoire)',
    L18nKeys.selectPfxOrP12File: 'Sélectionner un fichier .pfx ou .p12',
    L18nKeys.pfxPasswordRequired: 'Mot de Passe PFX (Obligatoire)',
    L18nKeys.pfxImportedSuccessfullyTo: 'PFX importé avec succès vers',
    L18nKeys.folder: 'dossier',

// Dialogue d'Importation de Certificat
    L18nKeys.importCertificate: 'Importer un Certificat',
    L18nKeys.selectCertificateFile: 'Sélectionner un Fichier de Certificat',
    L18nKeys.certificateFileRequired: 'Fichier de Certificat (Obligatoire)',
    L18nKeys.importedCertificate: 'Certificat Importé',
    L18nKeys.certificateValidated: 'Certificat validé',
    L18nKeys.expired: 'Expiré',
    L18nKeys.expiresIn: 'Expire dans',
    L18nKeys.days: 'jours',
    L18nKeys.certificateImportedSuccessfullyTo:
        'Certificat importé avec succès vers',
    L18nKeys.type: 'Type',
    L18nKeys.certificate: 'Certificat',
    L18nKeys.commonName: 'Nom Commun',
    L18nKeys.organization: 'Organisation',
    L18nKeys.issueDate: 'Date d\'Émission',
    L18nKeys.expiryDate: 'Date d\'Expiration',
    L18nKeys.daysUntilExpiry: 'Jours Jusqu\'à l\'Expiration',
    L18nKeys.thisCertificateHasExpired: 'Ce certificat a expiré !',
    L18nKeys.thisCertificateWillExpireIn: 'Ce certificat expirera dans',
    L18nKeys.daysAgo: 'jours',

// Écran de Gestion des Certificats
    L18nKeys.certTabAll: 'Tous',
    L18nKeys.certTabCA: 'Certificats CA',
    L18nKeys.certTabSSL: 'Certificats SSL',

// Détails du Certificat
    L18nKeys.certDetailType: 'Type',
    L18nKeys.certDetailCommonName: 'Nom Commun',
    L18nKeys.certDetailOrganization: 'Organisation',
    L18nKeys.certDetailCountry: 'Pays',
    L18nKeys.certDetailState: 'État/Province',
    L18nKeys.certDetailCity: 'Ville',
    L18nKeys.certDetailIssuerCN: 'CN de l\'Émetteur',
    L18nKeys.certDetailIssuerOrg: 'Organisation de l\'Émetteur',
    L18nKeys.certDetailIssueDate: 'Date d\'Émission',
    L18nKeys.certDetailExpiryDate: 'Date d\'Expiration',
    L18nKeys.certDetailDaysUntilExpiry: 'Jours Jusqu\'à l\'Expiration',
    L18nKeys.certDetailEncrypted: 'Chiffré',
    L18nKeys.certDetailSerial: 'Numéro de Série',
    L18nKeys.certDetailFilePath: 'Chemin du Fichier',
    L18nKeys.certDetailKeyPath: 'Chemin de la Clé',
    L18nKeys.certDetailChainPath: 'Chemin de la Chaîne',
    L18nKeys.certDetailFullChainPath: 'Chemin de Chaîne Complète',
    L18nKeys.certDetailChainLength: 'Longueur de la Chaîne',
    L18nKeys.certDetailImportedFrom: 'Importé depuis',
    L18nKeys.certDetailPurpose: 'Objectif',
    L18nKeys.certDetailPurposeName: 'Nom de l\'Objectif',
    L18nKeys.certYes: 'Oui',
    L18nKeys.certNo: 'Non',
    L18nKeys.certNA: 'N/D',
    L18nKeys.certExternal: 'Externe',
    L18nKeys.certCertificates: 'certificats',

// Dialogue de Génération de Certificat
    L18nKeys.certGenTitle: 'Générer un Certificat',
    L18nKeys.certGenSubtitle:
        'Remplissez le formulaire ci-dessous pour créer votre certificat',
    L18nKeys.certGenClose: 'Fermer',
    L18nKeys.certGenConfigTitle: 'Configuration OpenSSL',
    L18nKeys.certGenUseCustomConfig:
        'Utiliser une configuration OpenSSL personnalisée',
    L18nKeys.certGenUsingConfig: 'Utilisation : ',
    L18nKeys.certGenUsingDefault:
        'Utiliser la configuration par défaut d\'OpenSSL',
    L18nKeys.certGenConfigApplied:
        'Valeurs par défaut de configuration appliquées',

    L18nKeys.certGenPurposeTitle: 'Objectif du Certificat',
    L18nKeys.certGenSelectPurpose: 'Sélectionner l\'Objectif *',
    L18nKeys.certGenPurposeHelper:
        'Définit l\'utilisation de la clé du certificat',
    L18nKeys.certGenRequired: 'Obligatoire',
    L18nKeys.certGenKeyUsage: 'Utilisation de la Clé :',
    L18nKeys.certGenExtendedUsage: 'Utilisation Étendue :',
    L18nKeys.certGenCustomKeyUsage: 'Utilisation de Clé Personnalisée',
    L18nKeys.certGenCustomKeyUsageHint:
        'critical, digitalSignature, keyEncipherment',
    L18nKeys.certGenCustomExtKeyUsage:
        'Utilisation de Clé Étendue Personnalisée',
    L18nKeys.certGenCustomExtKeyUsageHint:
        'serverAuth, clientAuth, codeSigning',
    L18nKeys.certGenCommaSeparated: 'Valeurs séparées par des virgules',
    L18nKeys.certGenCommonKeyUsage: 'Valeurs courantes d\'utilisation de clé :',
    L18nKeys.certGenCommonExtKeyUsage:
        'Valeurs courantes d\'utilisation de clé étendue :',

    L18nKeys.certGenCATitle: 'Sélection de Certificat CA',
    L18nKeys.certGenSelectCA: 'Sélectionner un Certificat CA *',
    L18nKeys.certGenSelectCAHelper:
        'Choisissez quelle CA signera ce certificat',
    L18nKeys.certGenCAPassword: 'Mot de Passe CA *',
    L18nKeys.certGenPleaseSelectCA: 'Veuillez sélectionner un certificat CA',

    L18nKeys.certGenInfoTitle: 'Informations du Certificat',
    L18nKeys.certGenSecurityTitle: 'Options de Sécurité',
    L18nKeys.certGenEncryptKey: 'Chiffrer la clé privée',
    L18nKeys.certGenEncryptKeyDesc:
        'Protéger la clé privée avec un mot de passe',
    L18nKeys.certGenPassword: 'Mot de Passe *',
    L18nKeys.certGenPasswordHelper: 'Entrer un mot de passe fort',

    L18nKeys.certGenGenerating: 'Génération du certificat...',
    L18nKeys.certGenCancel: 'Annuler',
    L18nKeys.certGenGenerate: 'Générer le Certificat',

// Champs du Formulaire
    L18nKeys.certFieldName: 'Nom du Certificat *',
    L18nKeys.certFieldNameHintCA: 'MonCAracine',
    L18nKeys.certFieldNameHintSSL: 'exemple.com',
    L18nKeys.certFieldCountry: 'Code Pays *',
    L18nKeys.certFieldState: 'État/Province *',
    L18nKeys.certFieldCity: 'Ville *',
    L18nKeys.certFieldOrganization: 'Organisation *',
    L18nKeys.certFieldOrgUnit: 'Unité Organisationnelle *',
    L18nKeys.certFieldCommonName: 'Nom Commun *',
    L18nKeys.certFieldCommonNameHintCA: 'Mon CA Racine',
    L18nKeys.certFieldCommonNameHintSSL: 'exemple.com',
    L18nKeys.certFieldEmail: 'Email',
    L18nKeys.certFieldEmailHint: 'admin@exemple.com',
    L18nKeys.certFieldSAN: 'Noms Alternatifs du Sujet',
    L18nKeys.certFieldSANHint: 'www.exemple.com,mail.exemple.com',
    L18nKeys.certFieldValidity: 'Validité (jours) *',
    L18nKeys.certFieldFromConfig: 'Depuis la configuration',
    L18nKeys.certFieldInvalidNumber: 'Numéro non valide',

// Messages de Succès
    L18nKeys.certGenSuccessCA: 'Certificat CA généré avec succès',
    L18nKeys.certGenSuccessSSL: 'Certificat SSL généré avec succès',
    L18nKeys.certGenSuccessCustomConfig:
        ' en utilisant une configuration personnalisée',
    L18nKeys.certGenSuccessPurpose: 'Objectif : ',
    L18nKeys.certGenError: 'Erreur : ',

// Dialogue d'Exportation PFX
    L18nKeys.certExportTitle: 'Exporter vers PFX',
    L18nKeys.certExportCertPassword: 'Mot de Passe du Certificat *',
    L18nKeys.certExportPFXPassword: 'Mot de Passe PFX *',
    L18nKeys.certExportIncludeCA: 'Inclure le Certificat CA',
    L18nKeys.certExportSelectCA: 'Sélectionner un Certificat CA',
    L18nKeys.certExportButton: 'Exporter',
    L18nKeys.certExportSaveTitle: 'Enregistrer le fichier PFX',
    L18nKeys.certExportSuccess: 'PFX exporté avec succès',
    L18nKeys.certExportError: 'Erreur d\'exportation : ',

// État de la Carte de Certificat
    L18nKeys.certStatusActive: 'Actif',
    L18nKeys.certStatusExpired: 'Expiré',
    L18nKeys.certStatusExpiringSoon: 'Expire Bientôt',

// Étiquettes d'Information de Carte de Certificat
    L18nKeys.certCardIssueDate: 'Date d\'Émission',
    L18nKeys.certCardExpiryDate: 'Date d\'Expiration',
    L18nKeys.certCardDaysUntilExpiry: 'Jours Jusqu\'à l\'Expiration',
    L18nKeys.certCardDays: 'jours',
    L18nKeys.certCardEncrypted: 'Chiffré',
    L18nKeys.certCardChain: 'Chaîne',
    L18nKeys.certCardCerts: 'certificat(s)',
    L18nKeys.certCardImported: 'Importé',

// Actions de Carte de Certificat
    L18nKeys.certActionExport: 'Exporter',
    L18nKeys.certActionDelete: 'Supprimer',
  };
}
