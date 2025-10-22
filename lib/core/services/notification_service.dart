import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// 通知服务类
///
/// 提供跨平台(Android、iOS、Windows)的本地通知功能
/// 支持多种通知类型：简单通知、进度通知、定时通知、周期通知等
///
/// 使用示例:
/// ```dart
/// final notificationService = NotificationService();
/// await notificationService.initialize();
/// await notificationService.showNotification(
///   id: 1,
///   title: '标题',
///   body: '内容',
/// );
/// ```
class NotificationService {
  // ==================== 单例模式 ====================

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // ==================== 常量定义 ====================

  /// 通知渠道 ID 常量
  static const String _defaultChannelId = 'default_channel';
  static const String _progressChannelId = 'progress_channel';
  static const String _bigTextChannelId = 'big_text_channel';
  static const String _bigPictureChannelId = 'big_picture_channel';
  static const String _scheduledChannelId = 'scheduled_channel';
  static const String _periodicChannelId = 'periodic_channel';
  static const String _actionChannelId = 'action_channel';
  static const String _soundChannelId = 'sound_channel';
  static const String _badgeChannelId = 'badge_channel';

  /// 通知渠道名称常量
  static const String _defaultChannelName = '默认通知';
  static const String _progressChannelName = '进度通知';
  static const String _bigTextChannelName = '大文本通知';
  static const String _bigPictureChannelName = '图片通知';
  static const String _scheduledChannelName = '定时通知';
  static const String _periodicChannelName = '周期通知';
  static const String _actionChannelName = '操作通知';
  static const String _soundChannelName = '声音通知';
  static const String _badgeChannelName = '徽章通知';

  /// iOS 操作分类 ID
  static const String _iosActionCategoryId = 'actionCategory';

  /// Windows 应用配置
  static const String _windowsAppName = 'OwO! System Tools';
  static const String _windowsAppUserModelId = 'com.owoblog.owo_system_tool';
  static const String _windowsGuid = 'a8c22b2c-94e3-4b5d-9a84-3b3e3e3e3e3e';
  static const String _windowsIconPath = '../../assets/icons/app_icon.png';

  // ==================== 私有成员 ====================

  /// 通知插件实例
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// 初始化状态标志
  bool _initialized = false;

  // ==================== 初始化方法 ====================

  /// 点击回调方法
  Function? onCustomNotificationTapped;

  /// 初始化通知服务
  ///
  /// 必须在使用任何通知功能前调用
  /// 建议在应用启动时调用，如 main() 函数中
  ///
  /// 返回 [Future<void>] 初始化完成的 Future
  ///
  /// 功能:
  /// - 初始化时区数据（用于定时通知）
  /// - 配置 Android、iOS、Windows 平台的通知设置
  /// - 请求必要的系统权限
  /// - 设置通知点击回调
  Future<void> initialize() async {
    // 防止重复初始化
    if (_initialized) return;

    try {
      // 1. 初始化时区数据（定时通知必需）
      tz.initializeTimeZones();

      // 2. 创建初始化配置
      final initSettings = InitializationSettings(
        android: _createAndroidInitSettings(),
        iOS: _createIOSInitSettings(),
        windows: _createWindowsInitSettings(),
      );

      // 3. 初始化插件
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // 4. 请求各平台权限
      await _requestPermissions();

      _initialized = true;
      debugPrint('✅ 通知服务初始化成功');
    } catch (e) {
      debugPrint('❌ 通知服务初始化失败: $e');
      rethrow;
    }
  }

  /// 创建 Android 初始化设置
  AndroidInitializationSettings _createAndroidInitSettings() {
    return const AndroidInitializationSettings('@drawable/app_icon');
  }

  /// 创建 iOS 初始化设置
  DarwinInitializationSettings _createIOSInitSettings() {
    return DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      // 配置通知操作分类（用于带按钮的通知）
      notificationCategories: [
        DarwinNotificationCategory(
          _iosActionCategoryId,
          actions: [
            DarwinNotificationAction.plain('confirm', '确认'),
            DarwinNotificationAction.plain('cancel', '取消'),
          ],
        ),
      ],
    );
  }

  /// 创建 Windows 初始化设置
  WindowsInitializationSettings _createWindowsInitSettings() {
    return const WindowsInitializationSettings(
      appName: _windowsAppName,
      appUserModelId: _windowsAppUserModelId,
      guid: _windowsGuid,
      iconPath: _windowsIconPath,
    );
  }

  // ==================== 权限管理 ====================

  /// 请求各平台通知权限
  Future<void> _requestPermissions() async {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        await _requestAndroidPermissions();
        break;
      case TargetPlatform.iOS:
        await _requestIOSPermissions();
        break;
      default:
        // Windows 和其他平台不需要额外请求权限
        break;
    }
  }

  /// 请求 Android 通知权限
  ///
  /// 包括:
  /// - 通知权限 (Android 13+)
  /// - 精确闹钟权限 (用于定时通知)
  Future<void> _requestAndroidPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

    try {
      // Android 13+ 需要请求通知权限
      await androidPlugin.requestNotificationsPermission();
      // 请求精确闹钟权限（定时通知需要）
      await androidPlugin.requestExactAlarmsPermission();
      debugPrint('✅ Android 权限请求完成');
    } catch (e) {
      debugPrint('⚠️ Android 权限请求失败: $e');
    }
  }

  /// 请求 iOS 通知权限
  ///
  /// 包括:
  /// - 横幅提醒权限
  /// - 徽章权限
  /// - 声音权限
  ///
  /// 返回 [bool?] 是否授予权限，null 表示请求失败
  Future<bool?> _requestIOSPermissions() async {
    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (iosPlugin == null) return null;

    try {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('✅ iOS 权限请求完成: ${granted == true ? "已授权" : "已拒绝"}');
      return granted;
    } catch (e) {
      debugPrint('⚠️ iOS 权限请求失败: $e');
      return null;
    }
  }

  /// 检查 iOS 通知权限状态
  ///
  /// 返回 [bool] 是否已授予权限
  /// 非 iOS 平台总是返回 true
  Future<bool> checkIOSPermissions() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return true;

    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (iosPlugin == null) return false;

    try {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    } catch (e) {
      debugPrint('⚠️ 检查 iOS 权限失败: $e');
      return false;
    }
  }

  // ==================== 回调处理 ====================

  /// 通知点击回调
  ///
  /// 当用户点击通知或通知操作按钮时触发
  /// 可以在这里处理导航逻辑
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('''
📱 通知交互:
   - ID: ${response.id}
   - Action: ${response.actionId ?? '点击通知'}
   - Payload: ${response.payload ?? '无'}
''');

    onCustomNotificationTapped!();
  }

  // ==================== 通知详情构建器 ====================

  /// 构建通知详情
  ///
  /// 根据不同平台创建对应的通知配置
  NotificationDetails _buildNotificationDetails({
    required String channelId,
    required String channelName,
    String? channelDescription,
    Importance importance = Importance.high,
    Priority priority = Priority.high,
    AndroidNotificationDetails? customAndroid,
    DarwinNotificationDetails? customIOS,
  }) {
    return NotificationDetails(
      android: customAndroid ??
          AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: channelDescription ?? '$channelName渠道',
            icon: 'notification_icon',
            importance: importance,
            priority: priority,
            showWhen: true,
          ),
      iOS: customIOS ??
          const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
      windows: const WindowsNotificationDetails(),
    );
  }

  // ==================== 公共通知方法 ====================

  /// 显示简单通知
  ///
  /// 最基础的通知类型，包含标题和正文
  ///
  /// 参数:
  /// - [id] 通知唯一标识符，相同 ID 会覆盖旧通知
  /// - [title] 通知标题
  /// - [body] 通知正文
  /// - [payload] 自定义数据，点击通知时可获取
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await initialize();

    final details = _buildNotificationDetails(
      channelId: _defaultChannelId,
      channelName: _defaultChannelName,
    );

    await _notifications.show(id, title, body, details, payload: payload);
    debugPrint('📨 发送简单通知: $title');
  }

  /// 显示进度通知
  ///
  /// 用于显示下载、上传等进度
  ///
  /// 参数:
  /// - [id] 通知 ID（使用相同 ID 可更新进度）
  /// - [title] 通知标题
  /// - [progress] 当前进度值
  /// - [maxProgress] 最大进度值
  ///
  /// 注意: iOS 不支持进度条，会显示百分比文本
  Future<void> showProgressNotification({
    required int id,
    required String title,
    required int progress,
    required int maxProgress,
  }) async {
    await initialize();

    // Android: 显示进度条
    final androidDetails = AndroidNotificationDetails(
      _progressChannelId,
      _progressChannelName,
      channelDescription: '显示进度的通知',
      icon: 'notification_icon',
      importance: Importance.low,
      priority: Priority.low,
      showProgress: true,
      maxProgress: maxProgress,
      progress: progress,
      onlyAlertOnce: true, // 只在首次显示时提醒
    );

    // iOS: 显示进度百分比
    final percentage = (progress / maxProgress * 100).toStringAsFixed(0);
    final iosDetails = DarwinNotificationDetails(
      subtitle: '进度: $percentage%',
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      windows: const WindowsNotificationDetails(),
    );

    await _notifications.show(
      id,
      title,
      '$progress/$maxProgress',
      details,
    );
  }

  /// 显示大文本通知
  ///
  /// 用于显示长文本内容，支持展开查看
  ///
  /// 参数:
  /// - [id] 通知 ID
  /// - [title] 通知标题
  /// - [body] 简短摘要（未展开时显示）
  /// - [bigText] 完整文本内容（展开后显示）
  Future<void> showBigTextNotification({
    required int id,
    required String title,
    required String body,
    required String bigText,
  }) async {
    await initialize();

    // Android: 使用 BigTextStyle
    final androidDetails = AndroidNotificationDetails(
      _bigTextChannelId,
      _bigTextChannelName,
      channelDescription: '显示大量文本的通知',
      icon: 'notification_icon',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(
        bigText,
        contentTitle: title,
        summaryText: body,
      ),
    );

    // iOS: 使用 subtitle 显示摘要
    final iosDetails = DarwinNotificationDetails(
      subtitle: body,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      windows: const WindowsNotificationDetails(),
    );

    await _notifications.show(id, title, bigText, details);
    debugPrint('📄 发送大文本通知: $title');
  }

  /// 显示带图片的通知
  ///
  /// 在通知中显示图片
  ///
  /// 参数:
  /// - [id] 通知 ID
  /// - [title] 通知标题
  /// - [body] 通知正文
  /// - [imageUrl] 图片路径（本地文件路径）
  ///
  /// 注意:
  /// - Android 使用 BigPictureStyle
  /// - iOS 使用 Attachment 附件
  Future<void> showBigPictureNotification({
    required int id,
    required String title,
    required String body,
    required String imageUrl,
  }) async {
    await initialize();

    // Android: 使用 BigPictureStyle
    final androidDetails = AndroidNotificationDetails(
      _bigPictureChannelId,
      _bigPictureChannelName,
      channelDescription: '显示图片的通知',
      icon: 'notification_icon',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigPictureStyleInformation(
        FilePathAndroidBitmap(imageUrl),
        contentTitle: title,
        summaryText: body,
      ),
    );

    // iOS: 使用附件
    final iosDetails = DarwinNotificationDetails(
      attachments: [DarwinNotificationAttachment(imageUrl)],
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      windows: const WindowsNotificationDetails(),
    );

    await _notifications.show(id, title, body, details);
    debugPrint('🖼️ 发送图片通知: $title');
  }

  /// 定时通知
  ///
  /// 在指定时间显示通知
  ///
  /// 参数:
  /// - [id] 通知 ID
  /// - [title] 通知标题
  /// - [body] 通知正文
  /// - [scheduledTime] 计划显示时间
  /// - [payload] 自定义数据
  ///
  /// 注意: 需要精确闹钟权限（Android）
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    await initialize();

    final details = _buildNotificationDetails(
      channelId: _scheduledChannelId,
      channelName: _scheduledChannelName,
      channelDescription: '定时推送的通知',
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // uiLocalNotificationDateInterpretation was removed (not present in current plugin API)
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      payload: payload,
    );

    debugPrint('⏰ 设置定时通知: $title，时间: $scheduledTime');
  }

  /// 周期性通知
  ///
  /// 按固定间隔重复显示通知
  ///
  /// 参数:
  /// - [id] 通知 ID
  /// - [title] 通知标题
  /// - [body] 通知正文
  /// - [interval] 重复间隔（每分钟、每小时、每天、每周）
  ///
  /// 可用间隔:
  /// - RepeatInterval.everyMinute (每分钟)
  /// - RepeatInterval.hourly (每小时)
  /// - RepeatInterval.daily (每天)
  /// - RepeatInterval.weekly (每周)
  Future<void> showPeriodicNotification({
    required int id,
    required String title,
    required String body,
    required RepeatInterval interval,
  }) async {
    await initialize();

    final details = _buildNotificationDetails(
      channelId: _periodicChannelId,
      channelName: _periodicChannelName,
      channelDescription: '周期性推送的通知',
    );

    await _notifications.periodicallyShow(
      id,
      title,
      body,
      interval,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    debugPrint('🔄 设置周期通知: $title，间隔: $interval');
  }

  /// 显示带操作按钮的通知
  ///
  /// 通知中包含可点击的操作按钮
  ///
  /// 参数:
  /// - [id] 通知 ID
  /// - [title] 通知标题
  /// - [body] 通知正文
  ///
  /// 按钮操作:
  /// - 确认 (action: 'confirm')
  /// - 取消 (action: 'cancel')
  ///
  /// 可在 [_onNotificationTapped] 中处理按钮点击
  Future<void> showNotificationWithActions({
    required int id,
    required String title,
    required String body,
  }) async {
    await initialize();

    // Android: 使用 AndroidNotificationAction
    const androidDetails = AndroidNotificationDetails(
      _actionChannelId,
      _actionChannelName,
      channelDescription: '带操作按钮的通知',
      icon: 'notification_icon',
      importance: Importance.high,
      priority: Priority.high,
      actions: [
        AndroidNotificationAction('confirm', '确认'),
        AndroidNotificationAction('cancel', '取消'),
      ],
    );

    // iOS: 使用 categoryIdentifier 关联操作分类
    const iosDetails = DarwinNotificationDetails(
      categoryIdentifier: _iosActionCategoryId,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      windows: WindowsNotificationDetails(),
    );

    await _notifications.show(id, title, body, details);
    debugPrint('🔘 发送操作通知: $title');
  }

  /// 显示带自定义声音的通知
  ///
  /// 使用自定义音频文件作为通知提示音
  ///
  /// 参数:
  /// - [id] 通知 ID
  /// - [title] 通知标题
  /// - [body] 通知正文
  /// - [soundFile] 音频文件名（不含路径和扩展名）
  ///
  /// 注意:
  /// - Android: 将音频文件放在 android/app/src/main/res/raw/
  /// - iOS: 将音频文件放在 Runner/Resources/
  /// - 支持格式: .wav, .mp3
  Future<void> showNotificationWithSound({
    required int id,
    required String title,
    required String body,
    String? soundFile,
  }) async {
    await initialize();

    final androidDetails = AndroidNotificationDetails(
      _soundChannelId,
      _soundChannelName,
      channelDescription: '带自定义声音的通知',
      icon: 'notification_icon',
      importance: Importance.high,
      priority: Priority.high,
      sound: soundFile != null
          ? RawResourceAndroidNotificationSound(soundFile)
          : null,
    );

    final iosDetails = DarwinNotificationDetails(
      sound: soundFile,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      windows: const WindowsNotificationDetails(),
    );

    await _notifications.show(id, title, body, details);
    debugPrint('🔊 发送声音通知: $title');
  }

  /// 显示带徽章数字的通知 (主要用于 iOS)
  ///
  /// 在应用图标上显示数字徽章
  ///
  /// 参数:
  /// - [id] 通知 ID
  /// - [title] 通知标题
  /// - [body] 通知正文
  /// - [badgeNumber] 徽章数字（iOS 应用图标角标）
  ///
  /// 注意: Android 徽章由系统自动管理
  Future<void> showNotificationWithBadge({
    required int id,
    required String title,
    required String body,
    int? badgeNumber,
  }) async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      _badgeChannelId,
      _badgeChannelName,
      channelDescription: '带徽章数字的通知',
      icon: 'notification_icon',
      importance: Importance.high,
      priority: Priority.high,
    );

    final iosDetails = DarwinNotificationDetails(
      badgeNumber: badgeNumber,
      presentBadge: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      windows: const WindowsNotificationDetails(),
    );

    await _notifications.show(id, title, body, details);
    debugPrint('🔢 发送徽章通知: $title, 数字: $badgeNumber');
  }

  // ==================== 通知管理 ====================

  /// 取消指定 ID 的通知
  ///
  /// 移除已显示的通知或取消待显示的通知
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    debugPrint('❌ 取消通知: ID=$id');
  }

  /// 取消所有通知
  ///
  /// 清除所有已显示和待显示的通知
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    debugPrint('❌ 取消所有通知');
  }

  /// 获取待处理的通知列表
  ///
  /// 返回所有计划中但尚未显示的通知
  /// 包括定时通知和周期通知
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    final pending = await _notifications.pendingNotificationRequests();
    debugPrint('📋 待处理通知数量: ${pending.length}');
    return pending;
  }

  /// 获取当前活动的通知列表
  ///
  /// 返回当前显示在通知栏的通知
  ///
  /// 支持平台: Android, iOS
  /// Windows 不支持此功能
  Future<List<ActiveNotification>> getActiveNotifications() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await _getAndroidActiveNotifications();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return await _getIOSActiveNotifications();
    }
    return [];
  }

  /// 获取 Android 活动通知
  Future<List<ActiveNotification>> _getAndroidActiveNotifications() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final notifications = await androidPlugin.getActiveNotifications();
      debugPrint('📱 Android 活动通知数量: ${notifications.length}');
      return notifications;
    }
    return [];
  }

  /// 获取 iOS 活动通知
  Future<List<ActiveNotification>> _getIOSActiveNotifications() async {
    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (iosPlugin != null) {
      final notifications = await iosPlugin.getActiveNotifications();
      debugPrint('📱 iOS 活动通知数量: ${notifications.length}');

      // 转换为统一的 ActiveNotification 格式
      return notifications
          .map((n) => ActiveNotification(
                id: n.id ?? 0,
                channelId: '',
                title: n.title,
                body: n.body,
              ))
          .toList();
    }
    return [];
  }

  // ==================== 工具方法 ====================

  /// 检查是否已初始化
  bool get isInitialized => _initialized;

  /// 获取当前平台名称
  String get platformName => defaultTargetPlatform.name;
}
