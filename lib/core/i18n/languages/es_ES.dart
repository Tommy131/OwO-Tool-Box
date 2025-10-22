// ============================================================================
// Traducción al español
// ============================================================================

import '../localization_keys.dart';

class EsES {
  static const Map<String, String> translations = {
    // ========== Común ==========
    L18nKeys.appTitle: 'OwO! Herramientas del sistema',
    L18nKeys.ok: 'Aceptar',
    L18nKeys.cancel: 'Cancelar',

    // ========== Navegación ==========
    L18nKeys.menu: 'Menú',
    L18nKeys.home: 'Inicio',
    L18nKeys.settings: 'Configuración',
    L18nKeys.about: 'Acerca de',
    L18nKeys.monitor: 'Monitor',

    // ========== Página de bienvenida ==========
    L18nKeys.welcome: 'Bienvenido',
    L18nKeys.welcomeMessage:
        'Este es un framework de aplicación Flutter completamente funcional',
    L18nKeys.welcomeDescription:
        'Admite diseño adaptable multiplataforma, perfectamente adaptado para dispositivos móviles, tabletas y escritorio',
    L18nKeys.exploreFeatures: 'Explorar funciones',

    // ========== Configuración de idioma ==========
    L18nKeys.languageSettings: 'Configuración de idioma',
    L18nKeys.selectLanguage: 'Seleccionar idioma',
    L18nKeys.changingLanguage: 'Cambiando idioma',

    // ========== Página principal de configuración ==========
    L18nKeys.adjustTheme: 'Ajustar modo de tema y esquema de colores',
    L18nKeys.selectAppLanguage:
        'Seleccionar idioma de visualización de la aplicación',
    L18nKeys.configureHostMonitor: 'Configurar opciones de monitoreo de host',

    // ========== Configuración de tema ==========
    L18nKeys.themeMode: 'Modo de tema',
    L18nKeys.changingTheme: 'Cambiando tema',
    L18nKeys.themeSettings: 'Configuración de tema',
    L18nKeys.themeColorSettings: 'Colores del tema',
    L18nKeys.cyberpunkTheme: 'Tema Cyberpunk',
    L18nKeys.lightTheme: 'Tema claro',
    L18nKeys.darkTheme: 'Tema oscuro',
    L18nKeys.systemTheme: 'Seguir sistema',
    L18nKeys.defaultTheme: 'Tema predeterminado',
    L18nKeys.techTheme: 'Tema tecnológico',
    L18nKeys.natureTheme: 'Tema naturaleza',
    L18nKeys.sunsetTheme: 'Tema atardecer',
    L18nKeys.oceanTheme: 'Tema océano',

    // ========== Configuración del monitor de host ==========
    L18nKeys.hostMonitorSettings: 'Configuración del monitor de host',
    L18nKeys.refreshSettings: 'Configuración de actualización',
    L18nKeys.hostPollingInterval: 'Intervalo de sondeo de host',
    L18nKeys.enterRefreshInterval:
        'Ingrese el intervalo de actualización (segundos)',
    L18nKeys.seconds: 'segundos',
    L18nKeys.recommendedInterval:
        'Se recomienda configurar entre 1-10 segundos, demasiado corto puede afectar el rendimiento',
    L18nKeys.hostCheckSettings: 'Configuración de verificación de host',
    L18nKeys.checkTimeout: 'Tiempo de espera de verificación',
    L18nKeys.enterTimeout: 'Ingrese el tiempo de espera (segundos)',
    L18nKeys.timeoutDescription:
        'Tiempo de espera para verificar el estado en línea del host, recomendado 3-10 segundos',
    L18nKeys.backgroundCheckInterval:
        'Intervalo de verificación en segundo plano',
    L18nKeys.enterCheckInterval:
        'Ingrese el intervalo de verificación (minutos)',
    L18nKeys.minutes: 'minutos',
    L18nKeys.checkIntervalDescription:
        'Intervalo de verificación silenciosa en segundo plano para el estado de la lista de hosts, recomendado 5-30 minutos',
    L18nKeys.alertSettings: 'Configuración de alertas',
    L18nKeys.enableAlert: 'Habilitar alertas',
    L18nKeys.enableAlertDescription:
        'Cuando esté habilitado, se enviarán notificaciones cuando el uso de recursos exceda el umbral',
    L18nKeys.alertThreshold: 'Umbral de alerta',
    L18nKeys.cpuUsage: 'Uso de CPU',
    L18nKeys.memoryUsage: 'Uso de memoria',
    L18nKeys.diskUsage: 'Uso de disco',
    L18nKeys.uploadSpeed: 'Velocidad de carga',
    L18nKeys.downloadSpeed: 'Velocidad de descarga',
    L18nKeys.notificationSettings: 'Configuración de notificaciones',
    L18nKeys.disconnectNotification: 'Notificación de desconexión',
    L18nKeys.soundAlert: 'Alerta de sonido',
    L18nKeys.vibrationAlert: 'Alerta de vibración',
    L18nKeys.vibrationAlertDescription: 'Solo efectivo en dispositivos móviles',
    L18nKeys.save: 'Guardar',
    L18nKeys.settingsSaved: 'Configuración guardada',
    L18nKeys.longRefreshInterval: 'Intervalo de actualización largo',
    L18nKeys.longRefreshIntervalWarning:
        'Ha configurado el intervalo de actualización en {interval} segundos, lo que puede resultar en actualizaciones de datos retrasadas. ¿Continuar?',
    L18nKeys.invalidRefreshInterval:
        'Por favor ingrese un intervalo de actualización válido (al menos 1 segundo)',
    L18nKeys.invalidTimeout:
        'Por favor ingrese un tiempo de espera de verificación válido (1-60 segundos)',
    L18nKeys.invalidCheckInterval:
        'Por favor ingrese un intervalo de verificación válido (1-1440 minutos)',

    // ========== Efectos visuales ==========
    L18nKeys.visualEffects: 'Efectos visuales',
    L18nKeys.visualEffectsDescription:
        'Efectos exclusivos para el tema Cyberpunk',
    L18nKeys.matrixRainEffect: 'Efecto de lluvia Matrix',
    L18nKeys.matrixRainDescription: 'Animación de fondo estilo Matrix',
    L18nKeys.glowEffect: 'Efecto de brillo',
    L18nKeys.glowEffectDescription: 'Efectos de brillo en botones y tarjetas',
    L18nKeys.scanningLine: 'Línea de escaneo',
    L18nKeys.scanningLineDescription:
        'Animación de línea de escaneo de pantalla',
    L18nKeys.glitchEffect: 'Arte glitch',
    L18nKeys.glitchEffectDescription: 'Efectos de estilo glitch digital',

    // ========== Información de la aplicación ==========
    L18nKeys.appInfo: 'Información de la aplicación',
    L18nKeys.appName: 'OwO! Herramientas del sistema',
    L18nKeys.appDescription:
        'Una poderosa colección de herramientas del sistema multiplataforma, con soporte para monitoreo de host, análisis de rendimiento y más',
    L18nKeys.appVersion: 'Versión',
    L18nKeys.developerInfo: 'Información del desarrollador',
    L18nKeys.developerName: 'Desarrollador',
    L18nKeys.contactEmail: 'Correo electrónico de contacto',
    L18nKeys.flutterVersion: 'Versión de Flutter',
    L18nKeys.serviceHomepage: 'Página de inicio del servicio',
    L18nKeys.openSource: 'Proyecto de código abierto',
    L18nKeys.openSourceDescription:
        'Este proyecto utiliza una licencia de código abierto, las contribuciones son bienvenidas',
    L18nKeys.viewSourceCode: 'Ver código fuente',
    L18nKeys.license: 'Licencia',
    L18nKeys.supportDevelopment: 'Apoyar el desarrollo',
    L18nKeys.donationDescription:
        'Si encuentra útil este proyecto, por favor considere apoyar el desarrollo',
    L18nKeys.donateNow: 'Donar ahora',
    L18nKeys.topDonors: 'Principales donantes',
    L18nKeys.cannotOpenUrl: 'No se puede abrir la URL',
    L18nKeys.loadFailed: 'Error al cargar',
    L18nKeys.retry: 'Reintentar',
    L18nKeys.noDonorsYet: 'Aún no hay registros de donaciones',

    // ========== Tarjeta de pila tecnológica ==========
    L18nKeys.techStack: 'Pila tecnológica',
    L18nKeys.flutter: 'Flutter',
    L18nKeys.flutterDescription: 'Framework de interfaz multiplataforma',
    L18nKeys.goLang: 'Lenguaje Go',
    L18nKeys.goLangDescription: 'Servicio backend de alto rendimiento',
    L18nKeys.tcpIp: 'TCP/IP',
    L18nKeys.tcpIpDescription: 'Protocolo de comunicación de red',
    L18nKeys.materialDesign: 'Material Design',
    L18nKeys.materialDesignDescription: 'Lenguaje de diseño moderno',

    // ========== Acuerdo de usuario ==========
    L18nKeys.userAgreement: 'Acuerdo de usuario',
    L18nKeys.agreementContent:
        'Este marco de aplicación es solo para uso de aprendizaje y desarrollo.\nPor favor, cumpla con las leyes y regulaciones relevantes.\nSoporta múltiples plataformas: móviles, tablets y PC.\nEl desarrollador se reserva el derecho de interpretación final.\nEste proyecto sigue la licencia de código abierto MIT.\nLea detenidamente la documentación relevante antes de usar.\nEl desarrollador se reserva el derecho de interpretación final.',
    L18nKeys.github: 'GitHub',

    // ========== Información del dispositivo ==========
    L18nKeys.deviceInfo: 'Información del dispositivo',
    L18nKeys.screenSize: 'Tamaño de pantalla',
    L18nKeys.deviceType: 'Tipo de dispositivo',
    L18nKeys.mobileDevice: 'Móvil',
    L18nKeys.tabletDevice: 'Tableta',
    L18nKeys.desktopDevice: 'Escritorio',
    L18nKeys.layoutMode: 'Modo de diseño',
    L18nKeys.adaptiveLayout: 'Diseño adaptable',

    // ========== Control de ventana ==========
    L18nKeys.minimize: 'Minimizar',
    L18nKeys.maximize: 'Maximizar',
    L18nKeys.restore: 'Restaurar',
    L18nKeys.close: 'Cerrar',

    // ========== Página de edición de host ==========
    L18nKeys.editHost: 'Editar host',
    L18nKeys.addHost: 'Agregar host',
    L18nKeys.hostName: 'Nombre de host',
    L18nKeys.hostNameHint: 'Por favor ingrese el nombre de host',
    L18nKeys.pleaseEnterHostName: 'Por favor ingrese el nombre de host',
    L18nKeys.hostNameMinLength:
        'El nombre de host debe tener al menos 2 caracteres',
    L18nKeys.hostAddress: 'Dirección de host',
    L18nKeys.hostAddressHint: 'ej.: 192.168.1.100',
    L18nKeys.pleaseEnterHostAddress: 'Por favor ingrese la dirección de host',
    L18nKeys.hostAddressNoSpaces:
        'La dirección de host no puede contener espacios',
    L18nKeys.port: 'Puerto',
    L18nKeys.portHint: 'Por favor ingrese el número de puerto',
    L18nKeys.pleaseEnterPort: 'Por favor ingrese el número de puerto',
    L18nKeys.portRangeError: 'El número de puerto debe estar entre 1-65535',
    L18nKeys.password: 'Contraseña',
    L18nKeys.pleaseEnterPassword: 'Por favor ingrese la contraseña',
    L18nKeys.passwordMinLength:
        'La contraseña debe tener al menos 6 caracteres',
    L18nKeys.testConnection: 'Probar conexión',
    L18nKeys.saveChanges: 'Guardar cambios',
    L18nKeys.requiredFieldNote: '* Campo obligatorio',
    L18nKeys.hostUpdated: 'Información de host actualizada',
    L18nKeys.hostAdded: 'Host agregado exitosamente',
    L18nKeys.saveFailed: 'Error al guardar',
    L18nKeys.testingConnection: 'Probando conexión',
    L18nKeys.connectionSuccess: 'Conexión exitosa',
    L18nKeys.connectionFailed: 'Conexión fallida',
    L18nKeys.connectionSuccessMessage:
        'La conexión del host es normal, la configuración es válida',
    L18nKeys.connectionFailedMessage:
        'No se puede conectar al host, por favor verifique la configuración',
    L18nKeys.connectionTestError: 'Error de prueba de conexión',

    // ========== Diálogos ==========
    L18nKeys.connectionTimeout: 'Tiempo de conexión agotado',
    L18nKeys.connectionTimeoutMessage:
        'No se puede conectar al host "{hostName}"\n\nPor favor, verifique:\n• El servidor está en funcionamiento\n• La conexión de red es estable\n• La configuración del firewall',
    L18nKeys.tokenValidationFailed: 'Validación de token fallida',
    L18nKeys.tokenValidationFailedMessage:
        'El token de acceso para el host "{hostName}" es incorrecto',

    // ========== Página de historial de alertas ==========
    L18nKeys.alertHistory: 'Historial de alertas',
    L18nKeys.clearHistory: 'Limpiar historial',
    L18nKeys.noAlertRecords: 'No hay registros de alertas',
    L18nKeys.acknowledge: 'Reconocer',
    L18nKeys.alertAcknowledged: 'Alerta reconocida',
    L18nKeys.confirmClearAlertHistory:
        '¿Está seguro de que desea borrar todos los registros del historial de alertas?',
    L18nKeys.clear: 'Limpiar',
    L18nKeys.historyCleared: 'Historial limpiado',

    // ========== Página del monitor de host ==========
    L18nKeys.hostMonitor: 'Monitor de host',
    L18nKeys.loadHostListFailed: 'Error al cargar la lista de hosts',
    L18nKeys.loadGeoInfoFailed:
        'Error al cargar información de geolocalización',
    L18nKeys.hostStatusRefreshed: 'Estado de host actualizado',
    L18nKeys.refreshFailed: 'Error al actualizar',
    L18nKeys.refreshHostStatus: 'Actualizar estado de host',
    L18nKeys.forceDisconnectMessage:
        '¡Monitoreo de host desconectado forzosamente!',
    L18nKeys.safeDisconnectMessage:
        'Monitoreo de host desconectado de forma segura.',
    L18nKeys.disconnect: 'Desconectar',
    L18nKeys.loadingGeoInfo: 'Cargando información de geolocalización IP...',
    L18nKeys.loadingHostList: 'Cargando lista de hosts...',
    L18nKeys.connecting: 'Conectando...',
    L18nKeys.pleaseWait: 'Por favor espere',
    L18nKeys.noSavedHosts: 'Aún no hay hosts guardados',
    L18nKeys.clickToAddFirstHost:
        'Haga clic en el botón en la parte inferior derecha para agregar su primer host',
    L18nKeys.addNow: 'Agregar ahora',
    L18nKeys.total: 'Total',
    L18nKeys.online: 'En línea',
    L18nKeys.offline: 'Fuera de línea',
    L18nKeys.error: 'Error',
    L18nKeys.confirmDelete: 'Confirmar eliminación',
    L18nKeys.confirmDeleteHostPart1:
        '¿Está seguro de que desea eliminar el host',
    L18nKeys.confirmDeleteHostPart2:
        '?\n\nEsta operación también eliminará todos los registros de alertas para este host.',
    L18nKeys.delete: 'Eliminar',
    L18nKeys.hostDeleted: 'Host eliminado',
    L18nKeys.deleteFailed: 'Error al eliminar',
    L18nKeys.timeout: 'Tiempo de espera agotado',

    // ========== Página de detalles del host ==========
    L18nKeys.waitingSystemData: 'Esperando datos del sistema',
    L18nKeys.connectedGettingSystemInfo:
        'Conectado, obteniendo información del sistema...',
    L18nKeys.unnamedHost: 'Host sin nombre',
    L18nKeys.connected: 'Conectado',
    L18nKeys.cpuUsageTrend: 'Tendencia de uso de CPU',
    L18nKeys.memoryUsageTrend: 'Tendencia de uso de memoria',
    L18nKeys.diskUsageTrend: 'Tendencia de uso de disco',
    L18nKeys.uploadSpeedLabel: 'Velocidad de carga',
    L18nKeys.downloadSpeedLabel: 'Velocidad de descarga',
    L18nKeys.load1min: 'Carga de 1 minuto',
    L18nKeys.load5min: 'Carga de 5 minutos',
    L18nKeys.load15min: 'Carga de 15 minutos',
    L18nKeys.cpuCoreUsage: 'Uso de núcleos de CPU',
    L18nKeys.systemInfo: 'Información del sistema',
    L18nKeys.processor: 'Procesador',
    L18nKeys.processorCores: 'Núcleos del procesador',
    L18nKeys.coresUnit: 'núcleos',
    L18nKeys.processorFrequency: 'Frecuencia del procesador',
    L18nKeys.processCount: 'Cantidad de procesos',
    L18nKeys.countUnit: '',
    L18nKeys.systemLoad: 'Carga del sistema',
    L18nKeys.systemArchitecture: 'Arquitectura del sistema',
    L18nKeys.operatingSystem: 'Sistema operativo',
    L18nKeys.kernelVersion: 'Versión del kernel',
    L18nKeys.hostname: 'Nombre de host',
    L18nKeys.uptime: 'Tiempo de actividad',
    L18nKeys.memoryDetails: 'Detalles de memoria',
    L18nKeys.usageRate: 'Tasa de uso',
    L18nKeys.totalMemory: 'Memoria total',
    L18nKeys.usedMemory: 'Memoria usada',
    L18nKeys.availableMemory: 'Memoria disponible',
    L18nKeys.diskDetails: 'Detalles del disco',
    L18nKeys.used: 'Usado',
    L18nKeys.networkDetails: 'Detalles de red',
    L18nKeys.upload: 'Carga',
    L18nKeys.download: 'Descarga',
    L18nKeys.bytesSent: 'Bytes enviados',
    L18nKeys.bytesReceived: 'Bytes recibidos',
  };
}
