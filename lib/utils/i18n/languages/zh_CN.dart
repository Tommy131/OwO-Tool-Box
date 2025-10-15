// ============================================================================
// 简体中文翻译
// ============================================================================

import '../localization_keys.dart';

class ZhCN {
  static const Map<String, String> translations = {
    // ========== 通用 ==========
    L18nKeys.appTitle: 'OwO! System Tools',
    L18nKeys.ok: '确定',
    L18nKeys.cancel: '取消',

    // ========== 导航 ==========
    L18nKeys.menu: '菜单',
    L18nKeys.home: '首页',
    L18nKeys.settings: '设置',
    L18nKeys.about: '关于',

    // ========== 欢迎页 ==========
    L18nKeys.welcome: '欢迎使用',
    L18nKeys.welcomeMessage: '由HanskiJay开发的多功能系统助手',
    L18nKeys.welcomeDescription: '支持多平台自适应布局,完美适配手机、平板和桌面设备',
    L18nKeys.exploreFeatures: '探索功能',

    // ========== 语言设置 ==========
    L18nKeys.languageSettings: '语言设置',

    // ========== 主题设置 ==========
    L18nKeys.themeSettings: '主题设置',
    L18nKeys.themeColorSettings: '主题配色',
    L18nKeys.cyberpunkTheme: '赛博朋克主题',
    L18nKeys.lightTheme: '浅色主题',
    L18nKeys.darkTheme: '深色主题',
    L18nKeys.systemTheme: '跟随系统',
    L18nKeys.defaultTheme: '默认主题',
    L18nKeys.techTheme: '科技主题',
    L18nKeys.natureTheme: '自然主题',
    L18nKeys.sunsetTheme: '日落主题',
    L18nKeys.oceanTheme: '海洋主题',

    // ========== 视觉特效 ==========
    L18nKeys.visualEffects: '视觉特效',
    L18nKeys.visualEffectsDescription: '赛博朋克主题专属特效',
    L18nKeys.matrixRainEffect: '代码雨特效',
    L18nKeys.matrixRainDescription: '黑客帝国风格背景动画',
    L18nKeys.glowEffect: '发光效果',
    L18nKeys.glowEffectDescription: '头部字符霓虹发光',
    L18nKeys.scanningLine: '扫描线',
    L18nKeys.scanningLineDescription: '赛博朋克扫描动画',
    L18nKeys.glitchEffect: '故障效果',
    L18nKeys.glitchEffectDescription: '随机像素抖动',

    // ========== 应用信息 ==========
    L18nKeys.appInfo: '应用信息',
    L18nKeys.appName: '应用名称',
    L18nKeys.appDescription: '应用描述',
    L18nKeys.appVersion: '版本号',
    L18nKeys.developerInfo: '开发者信息',
    L18nKeys.developerName: '开发者',
    L18nKeys.contactEmail: '联系邮箱',
    L18nKeys.flutterVersion: 'Flutter 版本',
    L18nKeys.serviceHomepage: '服务主页',
    L18nKeys.openSource: '开源信息',
    L18nKeys.openSourceDescription: '本项目采用 MIT 开源协议,欢迎贡献代码和提出建议。',
    L18nKeys.viewSourceCode: '查看源代码',
    L18nKeys.license: '开源协议',
    L18nKeys.supportDevelopment: '支持开发',
    L18nKeys.donationDescription: '您的捐赠将帮助项目持续发展',
    L18nKeys.donateNow: '立即捐赠',
    L18nKeys.topDonors: '捐赠榜单 TOP 5',
    L18nKeys.cannotOpenUrl: '无法打开链接',
    L18nKeys.loadFailed: '加载失败',
    L18nKeys.retry: '重试',
    L18nKeys.noDonorsYet: '暂无捐赠记录',

    // ========== 用户协议 ==========
    L18nKeys.userAgreement: '用户使用须知',
    L18nKeys.agreementContent:
        '1. 本应用框架仅供学习和开发使用\n2. 请遵守相关法律法规\n3. 支持手机、平板、PC多平台\n4. 开发者保留最终解释权\n5. 本项目遵循 MIT 开源协议\n6. 使用前请仔细阅读相关文档\n7. 开发者保留最终解释权',
    L18nKeys.github: 'GitHub',

    // ========== 设备信息 ==========
    L18nKeys.deviceInfo: '设备信息',
    L18nKeys.screenSize: '屏幕尺寸',
    L18nKeys.deviceType: '设备类型',
    L18nKeys.mobileDevice: '手机设备',
    L18nKeys.tabletDevice: '平板设备',
    L18nKeys.desktopDevice: '桌面设备',
    L18nKeys.layoutMode: '布局模式',
    L18nKeys.adaptiveLayout: '自适应布局',

    // ========== 窗口控制 ==========
    L18nKeys.minimize: '最小化',
    L18nKeys.maximize: '最大化',
    L18nKeys.restore: '还原',
    L18nKeys.close: '关闭',

    // ========== 设置页（SettingsScreen）==========
    // 设置分类
    L18nKeys.commonSettings: '通用设置',
    L18nKeys.hostMonitoringSettings: '主机监控设置',

    // 分组标题
    L18nKeys.refreshSettings: '刷新设置',
    L18nKeys.hostCheckSettings: '主机检测设置',
    L18nKeys.alertSettings: '告警设置',
    L18nKeys.alertThresholds: '告警阈值',
    L18nKeys.notificationSettings: '通知设置',

    // 刷新设置
    L18nKeys.pollingInterval: '主机轮询间隔',
    L18nKeys.secondsSuffix: '秒',
    L18nKeys.refreshIntervalHint: '输入刷新间隔（秒）',
    L18nKeys.refreshIntervalTip: '建议设置为1-10秒之间，过短可能影响性能',

    // 主机检测设置
    L18nKeys.checkTimeout: '检测超时时间',
    L18nKeys.timeoutHint: '输入超时时间（秒）',
    L18nKeys.hostTimeoutTip: '检测主机在线状态的超时时间，建议3-10秒',
    L18nKeys.backgroundCheckInterval: '后台检测间隔',
    L18nKeys.minutesSuffix: '分钟',
    L18nKeys.checkIntervalHint: '输入检测间隔（分钟）',
    L18nKeys.backgroundCheckTip: '后台静默检测主机列表状态的间隔时间，建议5-30分钟',

    // 告警设置（总开关）
    L18nKeys.enableAlerts: '启用告警',
    L18nKeys.enableAlertsSubtitle: '开启后将在资源使用超过阈值时发送通知',

    // 告警阈值（滑块标签）
    L18nKeys.cpuUsage: 'CPU 使用率',
    L18nKeys.memoryUsage: '内存使用率',
    L18nKeys.diskUsage: '磁盘使用率',
    L18nKeys.uploadRate: '上传速率',
    L18nKeys.downloadRate: '下载速率',
    L18nKeys.kbPerSecond: ' KB/s',

    // 通知设置
    L18nKeys.notifyOnDisconnect: '断开连接通知',
    L18nKeys.soundEnabled: '声音提示',
    L18nKeys.vibrationEnabled: '震动提示',
    L18nKeys.vibrationNote: '仅在移动设备上生效',

    // 交互：保存与校验提示、确认弹窗、结果提示
    L18nKeys.saveSettings: '保存设置',
    L18nKeys.invalidRefreshInterval: '请输入有效的刷新间隔（至少1秒）',
    L18nKeys.invalidHostCheckTimeout: '请输入有效的检测超时时间（1-60秒）',
    L18nKeys.invalidHostCheckInterval: '请输入有效的检测间隔（1-1440分钟）',
    L18nKeys.longRefreshTitle: '刷新间隔较长',
    // 占位变量：{seconds} 用来替换 intervalSeconds
    L18nKeys.longRefreshContent: '您设置的刷新间隔为{seconds}秒，这可能导致数据更新不及时。确定继续？',
    L18nKeys.settingsSaved: '设置已保存',
  };
}
