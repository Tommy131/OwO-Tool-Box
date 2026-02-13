class LocalizationKeys {
  static const String configureHostMonitor = 'configure_host_monitor';
  static const String navMonitor = 'nav_monitor';
  static const String navAbout = 'nav_about';

  // ========== 主机监控设置 ==========
  static const String hostMonitorSettings = 'host_monitor_settings';
  static const String refreshSettings = 'refresh_settings';
  static const String hostPollingInterval = 'host_polling_interval';
  static const String enterRefreshInterval = 'enter_refresh_interval';
  static const String seconds = 'seconds';
  static const String recommendedInterval = 'recommended_interval';
  static const String hostCheckSettings = 'host_check_settings';
  static const String checkTimeout = 'check_timeout';
  static const String enterTimeout = 'enter_timeout';
  static const String timeoutDescription = 'timeout_description';
  static const String backgroundCheckInterval = 'background_check_interval';
  static const String enterCheckInterval = 'enter_check_interval';
  static const String minutes = 'minutes';
  static const String checkIntervalDescription = 'check_interval_description';
  static const String alertSettings = 'alert_settings';
  static const String enableAlert = 'enable_alert';
  static const String enableAlertDescription = 'enable_alert_description';
  static const String alertThreshold = 'alert_threshold';
  static const String cpuUsage = 'cpu_usage';
  static const String memoryUsage = 'memory_usage';
  static const String diskUsage = 'disk_usage';
  static const String uploadSpeed = 'upload_speed';
  static const String downloadSpeed = 'download_speed';
  static const String notificationSettings = 'notification_settings';
  static const String disconnectNotification = 'disconnect_notification';
  static const String soundAlert = 'sound_alert';
  static const String vibrationAlert = 'vibration_alert';
  static const String vibrationAlertDescription = 'vibration_alert_description';
  static const String save = 'save';
  static const String settingsSaved = 'settings_saved';
  static const String longRefreshInterval = 'long_refresh_interval';
  static const String longRefreshIntervalWarning =
      'long_refresh_interval_warning';
  static const String invalidRefreshInterval = 'invalid_refresh_interval';
  static const String invalidTimeout = 'invalid_timeout';
  static const String invalidCheckInterval = 'invalid_check_interval';

  // ========== 主机编辑页面 ==========
  static const String editHost = 'edit_host';
  static const String addHost = 'add_host';
  static const String hostName = 'host_name';
  static const String hostNameHint = 'host_name_hint';
  static const String pleaseEnterHostName = 'please_enter_host_name';
  static const String hostNameMinLength = 'host_name_min_length';
  static const String hostAddress = 'host_address';
  static const String hostAddressHint = 'host_address_hint';
  static const String pleaseEnterHostAddress = 'please_enter_host_address';
  static const String hostAddressNoSpaces = 'host_address_no_spaces';
  static const String port = 'port';
  static const String portHint = 'port_hint';
  static const String pleaseEnterPort = 'please_enter_port';
  static const String portRangeError = 'port_range_error';
  static const String password = 'password';
  static const String pleaseEnterPassword = 'please_enter_password';
  static const String passwordMinLength = 'password_min_length';
  static const String testConnection = 'test_connection';
  static const String saveChanges = 'save_changes';
  static const String requiredFieldNote = 'required_field_note';
  static const String hostUpdated = 'host_updated';
  static const String hostAdded = 'host_added';
  static const String saveFailed = 'save_failed';
  static const String testingConnection = 'testing_connection';
  static const String connectionSuccess = 'connection_success';
  static const String connectionFailed = 'connection_failed';
  static const String connectionSuccessMessage = 'connection_success_message';
  static const String connectionFailedMessage = 'connection_failed_message';
  static const String connectionTestError = 'connection_test_error';

  // ========== 对话框 ==========
  static const String connectionTimeout = 'connection_timeout';
  static const String connectionTimeoutMessage = 'connection_timeout_message';
  static const String tokenValidationFailed = 'token_validation_failed';
  static const String tokenValidationFailedMessage =
      'token_validation_failed_message';

  // ========== 告警历史页面 ==========
  static const String alertHistory = 'alert_history';
  static const String clearHistory = 'clear_history';
  static const String noAlertRecords = 'no_alert_records';
  static const String acknowledge = 'acknowledge';
  static const String alertAcknowledged = 'alert_acknowledged';
  static const String confirmClearAlertHistory = 'confirm_clear_alert_history';
  static const String clear = 'clear';
  static const String historyCleared = 'history_cleared';

  // ========== 主机监控页面 ==========
  static const String hostMonitor = 'host_monitor';
  static const String loadHostListFailed = 'load_host_list_failed';
  static const String loadGeoInfoFailed = 'load_geo_info_failed';
  static const String hostStatusRefreshed = 'host_status_refreshed';
  static const String refreshFailed = 'refresh_failed';
  static const String refreshHostStatus = 'refresh_host_status';
  static const String forceDisconnectMessage = 'force_disconnect_message';
  static const String safeDisconnectMessage = 'safe_disconnect_message';
  static const String disconnect = 'disconnect';
  static const String loadingGeoInfo = 'loading_geo_info';
  static const String loadingHostList = 'loading_host_list';
  static const String connecting = 'connecting';
  static const String pleaseWait = 'please_wait';
  static const String noSavedHosts = 'no_saved_hosts';
  static const String clickToAddFirstHost = 'click_to_add_first_host';
  static const String addNow = 'add_now';
  static const String total = 'total';
  static const String online = 'online';
  static const String offline = 'offline';
  static const String error = 'error';
  static const String confirmDelete = 'confirm_delete';
  static const String confirmDeleteHostPart1 = 'confirm_delete_host_part1';
  static const String confirmDeleteHostPart2 = 'confirm_delete_host_part2';
  static const String delete = 'delete';
  static const String hostDeleted = 'host_deleted';
  static const String deleteFailed = 'delete_failed';
  static const String timeout = 'timeout';

  // ========== 主机详情页面 ==========
  static const String waitingSystemData = 'waiting_system_data';
  static const String connectedGettingSystemInfo =
      'connected_getting_system_info';
  static const String unnamedHost = 'unnamed_host';
  static const String connected = 'connected';
  static const String cpuUsageTrend = 'cpu_usage_trend';
  static const String memoryUsageTrend = 'memory_usage_trend';
  static const String diskUsageTrend = 'disk_usage_trend';
  static const String uploadSpeedLabel = 'upload_speed_label';
  static const String downloadSpeedLabel = 'download_speed_label';
  static const String load1min = 'load_1min';
  static const String load5min = 'load_5min';
  static const String load15min = 'load_15min';
  static const String cpuCoreUsage = 'cpu_core_usage';
  static const String systemInfo = 'system_info';
  static const String processor = 'processor';
  static const String processorCores = 'processor_cores';
  static const String coresUnit = 'cores_unit';
  static const String processorFrequency = 'processor_frequency';
  static const String processCount = 'process_count';
  static const String countUnit = 'count_unit';
  static const String systemLoad = 'system_load';
  static const String systemArchitecture = 'system_architecture';
  static const String operatingSystem = 'operating_system';
  static const String kernelVersion = 'kernel_version';
  static const String hostname = 'hostname';
  static const String uptime = 'uptime';
  static const String memoryDetails = 'memory_details';
  static const String usageRate = 'usage_rate';
  static const String totalMemory = 'total_memory';
  static const String usedMemory = 'used_memory';
  static const String availableMemory = 'available_memory';
  static const String diskDetails = 'disk_details';
  static const String used = 'used';
  static const String networkDetails = 'network_details';
  static const String upload = 'upload';
  static const String download = 'download';
  static const String bytesSent = 'bytes_sent';
  static const String bytesReceived = 'bytes_received';
}
