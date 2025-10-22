// ============================================================================
// Traduction française
// ============================================================================

import '../localization_keys.dart';

class FrFR {
  static const Map<String, String> translations = {
    // ========== Commun ==========
    L18nKeys.appTitle: 'OwO! Outils système',
    L18nKeys.ok: 'OK',
    L18nKeys.cancel: 'Annuler',

    // ========== Navigation ==========
    L18nKeys.menu: 'Menu',
    L18nKeys.home: 'Accueil',
    L18nKeys.settings: 'Paramètres',
    L18nKeys.about: 'À propos',
    L18nKeys.monitor: 'Moniteur',

    // ========== Page de bienvenue ==========
    L18nKeys.welcome: 'Bienvenue',
    L18nKeys.welcomeMessage:
        'Ceci est un framework d\'application Flutter entièrement fonctionnel',
    L18nKeys.welcomeDescription:
        'Prend en charge la mise en page adaptative multiplateforme, parfaitement adapté aux appareils mobiles, tablettes et ordinateurs de bureau',
    L18nKeys.exploreFeatures: 'Explorer les fonctionnalités',

    // ========== Paramètres de langue ==========
    L18nKeys.languageSettings: 'Paramètres de langue',
    L18nKeys.selectLanguage: 'Sélectionner la langue',
    L18nKeys.changingLanguage: 'Changement de langue',

    // ========== Page principale des paramètres ==========
    L18nKeys.adjustTheme: 'Ajuster le mode de thème et le jeu de couleurs',
    L18nKeys.selectAppLanguage:
        'Sélectionner la langue d\'affichage de l\'application',
    L18nKeys.configureHostMonitor:
        'Configurer les options de surveillance d\'hôte',

    // ========== Paramètres de thème ==========
    L18nKeys.themeMode: 'Mode de thème',
    L18nKeys.changingTheme: 'Changement de thème',
    L18nKeys.themeSettings: 'Paramètres de thème',
    L18nKeys.themeColorSettings: 'Couleurs du thème',
    L18nKeys.cyberpunkTheme: 'Thème Cyberpunk',
    L18nKeys.lightTheme: 'Thème clair',
    L18nKeys.darkTheme: 'Thème sombre',
    L18nKeys.systemTheme: 'Suivre le système',
    L18nKeys.defaultTheme: 'Thème par défaut',
    L18nKeys.techTheme: 'Thème technologique',
    L18nKeys.natureTheme: 'Thème nature',
    L18nKeys.sunsetTheme: 'Thème coucher de soleil',
    L18nKeys.oceanTheme: 'Thème océan',

    // ========== Paramètres de surveillance d'hôte ==========
    L18nKeys.hostMonitorSettings: 'Paramètres de surveillance d\'hôte',
    L18nKeys.refreshSettings: 'Paramètres d\'actualisation',
    L18nKeys.hostPollingInterval: 'Intervalle d\'interrogation d\'hôte',
    L18nKeys.enterRefreshInterval:
        'Entrer l\'intervalle d\'actualisation (secondes)',
    L18nKeys.seconds: 'secondes',
    L18nKeys.recommendedInterval:
        'Recommandé entre 1 et 10 secondes, trop court peut affecter les performances',
    L18nKeys.hostCheckSettings: 'Paramètres de vérification d\'hôte',
    L18nKeys.checkTimeout: 'Délai de vérification',
    L18nKeys.enterTimeout: 'Entrer le délai (secondes)',
    L18nKeys.timeoutDescription:
        'Délai pour vérifier l\'état en ligne de l\'hôte, recommandé 3 à 10 secondes',
    L18nKeys.backgroundCheckInterval:
        'Intervalle de vérification en arrière-plan',
    L18nKeys.enterCheckInterval:
        'Entrer l\'intervalle de vérification (minutes)',
    L18nKeys.minutes: 'minutes',
    L18nKeys.checkIntervalDescription:
        'Intervalle de vérification silencieuse en arrière-plan pour l\'état de la liste d\'hôtes, recommandé 5 à 30 minutes',
    L18nKeys.alertSettings: 'Paramètres d\'alerte',
    L18nKeys.enableAlert: 'Activer les alertes',
    L18nKeys.enableAlertDescription:
        'Lorsqu\'activé, des notifications seront envoyées lorsque l\'utilisation des ressources dépasse le seuil',
    L18nKeys.alertThreshold: 'Seuil d\'alerte',
    L18nKeys.cpuUsage: 'Utilisation du CPU',
    L18nKeys.memoryUsage: 'Utilisation de la mémoire',
    L18nKeys.diskUsage: 'Utilisation du disque',
    L18nKeys.uploadSpeed: 'Vitesse de téléchargement',
    L18nKeys.downloadSpeed: 'Vitesse de téléchargement',
    L18nKeys.notificationSettings: 'Paramètres de notification',
    L18nKeys.disconnectNotification: 'Notification de déconnexion',
    L18nKeys.soundAlert: 'Alerte sonore',
    L18nKeys.vibrationAlert: 'Alerte vibrante',
    L18nKeys.vibrationAlertDescription:
        'Efficace uniquement sur les appareils mobiles',
    L18nKeys.save: 'Enregistrer',
    L18nKeys.settingsSaved: 'Paramètres enregistrés',
    L18nKeys.longRefreshInterval: 'Intervalle d\'actualisation long',
    L18nKeys.longRefreshIntervalWarning:
        'Vous avez défini l\'intervalle d\'actualisation à {interval} secondes, ce qui peut entraîner des mises à jour de données retardées. Continuer ?',
    L18nKeys.invalidRefreshInterval:
        'Veuillez entrer un intervalle d\'actualisation valide (au moins 1 seconde)',
    L18nKeys.invalidTimeout:
        'Veuillez entrer un délai de vérification valide (1 à 60 secondes)',
    L18nKeys.invalidCheckInterval:
        'Veuillez entrer un intervalle de vérification valide (1 à 1440 minutes)',

    // ========== Effets visuels ==========
    L18nKeys.visualEffects: 'Effets visuels',
    L18nKeys.visualEffectsDescription:
        'Effets exclusifs pour le thème Cyberpunk',
    L18nKeys.matrixRainEffect: 'Effet de pluie matricielle',
    L18nKeys.matrixRainDescription: 'Animation d\'arrière-plan de style Matrix',
    L18nKeys.glowEffect: 'Effet de lueur',
    L18nKeys.glowEffectDescription: 'Effets de lueur des boutons et cartes',
    L18nKeys.scanningLine: 'Ligne de balayage',
    L18nKeys.scanningLineDescription: 'Animation de ligne de balayage d\'écran',
    L18nKeys.glitchEffect: 'Art glitch',
    L18nKeys.glitchEffectDescription: 'Effets de style glitch numérique',

    // ========== Informations sur l'application ==========
    L18nKeys.appInfo: 'Informations sur l\'application',
    L18nKeys.appName: 'OwO! Outils système',
    L18nKeys.appDescription:
        'Une puissante collection d\'outils système multiplateforme, prenant en charge la surveillance d\'hôte, l\'analyse des performances et plus encore',
    L18nKeys.appVersion: 'Version',
    L18nKeys.developerInfo: 'Informations sur le développeur',
    L18nKeys.developerName: 'Développeur',
    L18nKeys.contactEmail: 'E-mail de contact',
    L18nKeys.flutterVersion: 'Version Flutter',
    L18nKeys.serviceHomepage: 'Page d\'accueil du service',
    L18nKeys.openSource: 'Projet open source',
    L18nKeys.openSourceDescription:
        'Ce projet utilise une licence open source, les contributions sont les bienvenues',
    L18nKeys.viewSourceCode: 'Voir le code source',
    L18nKeys.license: 'Licence',
    L18nKeys.supportDevelopment: 'Soutenir le développement',
    L18nKeys.donationDescription:
        'Si vous trouvez ce projet utile, veuillez envisager de soutenir le développement',
    L18nKeys.donateNow: 'Faire un don maintenant',
    L18nKeys.topDonors: 'Meilleurs donateurs',
    L18nKeys.cannotOpenUrl: 'Impossible d\'ouvrir l\'URL',
    L18nKeys.loadFailed: 'Échec du chargement',
    L18nKeys.retry: 'Réessayer',
    L18nKeys.noDonorsYet: 'Aucun enregistrement de don pour le moment',

    // ========== Carte de pile technologique ==========
    L18nKeys.techStack: 'Pile technologique',
    L18nKeys.flutter: 'Flutter',
    L18nKeys.flutterDescription:
        'Framework d\'interface utilisateur multiplateforme',
    L18nKeys.goLang: 'Langage Go',
    L18nKeys.goLangDescription: 'Service backend haute performance',
    L18nKeys.tcpIp: 'TCP/IP',
    L18nKeys.tcpIpDescription: 'Protocole de communication réseau',
    L18nKeys.materialDesign: 'Material Design',
    L18nKeys.materialDesignDescription: 'Langage de conception moderne',

    // ========== Accord utilisateur ==========
    L18nKeys.userAgreement: 'Accord utilisateur',
    L18nKeys.agreementContent:
        "Ce cadre d'application est destiné uniquement à des fins d'apprentissage et de développement.\nVeuillez respecter les lois et réglementations en vigueur.\nPrend en charge les multi-plateformes : téléphones mobiles, tablettes et PC.\nLe développeur se réserve le droit d'interprétation finale.\nCe projet suit la licence open-source MIT.\nVeuillez lire attentivement la documentation pertinente avant utilisation.\nLe développeur se réserve le droit d'interprétation finale.",
    L18nKeys.github: 'GitHub',

    // ========== Informations sur l'appareil ==========
    L18nKeys.deviceInfo: 'Informations sur l\'appareil',
    L18nKeys.screenSize: 'Taille de l\'écran',
    L18nKeys.deviceType: 'Type d\'appareil',
    L18nKeys.mobileDevice: 'Mobile',
    L18nKeys.tabletDevice: 'Tablette',
    L18nKeys.desktopDevice: 'Bureau',
    L18nKeys.layoutMode: 'Mode de mise en page',
    L18nKeys.adaptiveLayout: 'Mise en page adaptative',

    // ========== Contrôle de fenêtre ==========
    L18nKeys.minimize: 'Réduire',
    L18nKeys.maximize: 'Agrandir',
    L18nKeys.restore: 'Restaurer',
    L18nKeys.close: 'Fermer',

    // ========== Page d'édition d'hôte ==========
    L18nKeys.editHost: 'Modifier l\'hôte',
    L18nKeys.addHost: 'Ajouter un hôte',
    L18nKeys.hostName: 'Nom d\'hôte',
    L18nKeys.hostNameHint: 'Veuillez entrer le nom d\'hôte',
    L18nKeys.pleaseEnterHostName: 'Veuillez entrer le nom d\'hôte',
    L18nKeys.hostNameMinLength:
        'Le nom d\'hôte doit contenir au moins 2 caractères',
    L18nKeys.hostAddress: 'Adresse d\'hôte',
    L18nKeys.hostAddressHint: 'par exemple : 192.168.1.100',
    L18nKeys.pleaseEnterHostAddress: 'Veuillez entrer l\'adresse d\'hôte',
    L18nKeys.hostAddressNoSpaces:
        'L\'adresse d\'hôte ne peut pas contenir d\'espaces',
    L18nKeys.port: 'Port',
    L18nKeys.portHint: 'Veuillez entrer le numéro de port',
    L18nKeys.pleaseEnterPort: 'Veuillez entrer le numéro de port',
    L18nKeys.portRangeError: 'Le numéro de port doit être entre 1 et 65535',
    L18nKeys.password: 'Mot de passe',
    L18nKeys.pleaseEnterPassword: 'Veuillez entrer le mot de passe',
    L18nKeys.passwordMinLength:
        'Le mot de passe doit contenir au moins 6 caractères',
    L18nKeys.testConnection: 'Tester la connexion',
    L18nKeys.saveChanges: 'Enregistrer les modifications',
    L18nKeys.requiredFieldNote: '* Champ obligatoire',
    L18nKeys.hostUpdated: 'Informations d\'hôte mises à jour',
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

    // ========== Dialogues ==========
    L18nKeys.connectionTimeout: 'Délai de connexion dépassé',
    L18nKeys.connectionTimeoutMessage:
        'Impossible de se connecter à l\'hôte "{hostName}"\n\nVeuillez vérifier :\n• Le serveur est en cours d\'exécution\n• La connexion réseau est stable\n• Les paramètres du pare-feu',
    L18nKeys.tokenValidationFailed: 'Échec de la validation du token',
    L18nKeys.tokenValidationFailedMessage:
        'Le token d\'accès pour l\'hôte "{hostName}" est incorrect',

    // ========== Page d'historique des alertes ==========
    L18nKeys.alertHistory: 'Historique des alertes',
    L18nKeys.clearHistory: 'Effacer l\'historique',
    L18nKeys.noAlertRecords: 'Aucun enregistrement d\'alerte',
    L18nKeys.acknowledge: 'Acquitter',
    L18nKeys.alertAcknowledged: 'Alerte acquittée',
    L18nKeys.confirmClearAlertHistory:
        'Êtes-vous sûr de vouloir effacer tous les enregistrements d\'historique d\'alertes ?',
    L18nKeys.clear: 'Effacer',
    L18nKeys.historyCleared: 'Historique effacé',

    // ========== Page de surveillance d'hôte ==========
    L18nKeys.hostMonitor: 'Moniteur d\'hôte',
    L18nKeys.loadHostListFailed: 'Échec du chargement de la liste d\'hôtes',
    L18nKeys.loadGeoInfoFailed:
        'Échec du chargement des informations de géolocalisation',
    L18nKeys.hostStatusRefreshed: 'État d\'hôte actualisé',
    L18nKeys.refreshFailed: 'Échec de l\'actualisation',
    L18nKeys.refreshHostStatus: 'Actualiser l\'état d\'hôte',
    L18nKeys.forceDisconnectMessage:
        'Surveillance d\'hôte déconnectée de force !',
    L18nKeys.safeDisconnectMessage:
        'Surveillance d\'hôte déconnectée en toute sécurité.',
    L18nKeys.disconnect: 'Déconnecter',
    L18nKeys.loadingGeoInfo:
        'Chargement des informations de géolocalisation IP...',
    L18nKeys.loadingHostList: 'Chargement de la liste d\'hôtes...',
    L18nKeys.connecting: 'Connexion en cours...',
    L18nKeys.pleaseWait: 'Veuillez patienter',
    L18nKeys.noSavedHosts: 'Aucun hôte enregistré pour le moment',
    L18nKeys.clickToAddFirstHost:
        'Cliquez sur le bouton en bas à droite pour ajouter votre premier hôte',
    L18nKeys.addNow: 'Ajouter maintenant',
    L18nKeys.total: 'Total',
    L18nKeys.online: 'En ligne',
    L18nKeys.offline: 'Hors ligne',
    L18nKeys.error: 'Erreur',
    L18nKeys.confirmDelete: 'Confirmer la suppression',
    L18nKeys.confirmDeleteHostPart1:
        'Êtes-vous sûr de vouloir supprimer l\'hôte',
    L18nKeys.confirmDeleteHostPart2:
        ' ?\n\nCette opération supprimera également tous les enregistrements d\'alerte pour cet hôte.',
    L18nKeys.delete: 'Supprimer',
    L18nKeys.hostDeleted: 'Hôte supprimé',
    L18nKeys.deleteFailed: 'Échec de la suppression',
    L18nKeys.timeout: 'Délai dépassé',

    // ========== Page de détails de l'hôte ==========
    L18nKeys.waitingSystemData: 'En attente des données système',
    L18nKeys.connectedGettingSystemInfo:
        'Connecté, récupération des informations système...',
    L18nKeys.unnamedHost: 'Hôte sans nom',
    L18nKeys.connected: 'Connecté',
    L18nKeys.cpuUsageTrend: 'Tendance d\'utilisation du CPU',
    L18nKeys.memoryUsageTrend: 'Tendance d\'utilisation de la mémoire',
    L18nKeys.diskUsageTrend: 'Tendance d\'utilisation du disque',
    L18nKeys.uploadSpeedLabel: 'Vitesse de téléchargement',
    L18nKeys.downloadSpeedLabel: 'Vitesse de téléchargement',
    L18nKeys.load1min: 'Charge 1 minute',
    L18nKeys.load5min: 'Charge 5 minutes',
    L18nKeys.load15min: 'Charge 15 minutes',
    L18nKeys.cpuCoreUsage: 'Utilisation des cœurs CPU',
    L18nKeys.systemInfo: 'Informations système',
    L18nKeys.processor: 'Processeur',
    L18nKeys.processorCores: 'Cœurs de processeur',
    L18nKeys.coresUnit: 'cœurs',
    L18nKeys.processorFrequency: 'Fréquence du processeur',
    L18nKeys.processCount: 'Nombre de processus',
    L18nKeys.countUnit: '',
    L18nKeys.systemLoad: 'Charge système',
    L18nKeys.systemArchitecture: 'Architecture système',
    L18nKeys.operatingSystem: 'Système d\'exploitation',
    L18nKeys.kernelVersion: 'Version du noyau',
    L18nKeys.hostname: 'Nom d\'hôte',
    L18nKeys.uptime: 'Temps de fonctionnement',
    L18nKeys.memoryDetails: 'Détails de la mémoire',
    L18nKeys.usageRate: 'Taux d\'utilisation',
    L18nKeys.totalMemory: 'Mémoire totale',
    L18nKeys.usedMemory: 'Mémoire utilisée',
    L18nKeys.availableMemory: 'Mémoire disponible',
    L18nKeys.diskDetails: 'Détails du disque',
    L18nKeys.used: 'Utilisé',
    L18nKeys.networkDetails: 'Détails du réseau',
    L18nKeys.upload: 'Téléchargement',
    L18nKeys.download: 'Téléchargement',
    L18nKeys.bytesSent: 'Octets envoyés',
    L18nKeys.bytesReceived: 'Octets reçus',
  };
}
