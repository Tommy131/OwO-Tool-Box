import 'localization_keys.dart';

final Map<String, Map<String, String>> translations = {
  'zh_CN': {
    LocalizationKeys.confirm: '确认',
    LocalizationKeys.cancel: '取消',

    // ========== 系统工具 ==========
    LocalizationKeys.navSystemTools: '系统工具',
    LocalizationKeys.systemTools: '系统工具',
    LocalizationKeys.platformNotSupported: '平台不支持',
    LocalizationKeys.platformNotSupportedMessage: '此功能仅支持 Windows 系统',

    // 定时关机
    LocalizationKeys.shutdownTimer: '定时关机',
    LocalizationKeys.shutdownScheduled: '已设置定时关机',
    LocalizationKeys.scheduleShutdown: '设置关机',
    LocalizationKeys.cancelShutdown: '取消关机',
    LocalizationKeys.shutdownCancelled: '关机任务已取消',
    LocalizationKeys.shutdownScheduledSuccess: '关机任务已设置',
    LocalizationKeys.scheduling: '设置中...',
    LocalizationKeys.duration: '延迟时间',
    LocalizationKeys.specificTime: '具体时间',
    LocalizationKeys.setDuration: '设置延迟时间',
    LocalizationKeys.setSpecificTime: '设置具体时间',
    LocalizationKeys.setDelayTime: '设置延迟时间',
    LocalizationKeys.setExactTime: '设置具体时间',
    LocalizationKeys.hours: '小时',
    LocalizationKeys.minute: '分钟',
    LocalizationKeys.second: '秒',
    LocalizationKeys.selectDateTime: '选择日期和时间',
    LocalizationKeys.pleaseSelectDateTime: '请选择日期和时间',
    LocalizationKeys.pleaseSetValidDuration: '请设置有效的时间',
    LocalizationKeys.quickActions: '快捷操作',
    LocalizationKeys.tenMinutes: '10分钟',
    LocalizationKeys.thirtyMinutes: '30分钟',
    LocalizationKeys.oneHour: '1小时',
    LocalizationKeys.twoHours: '2小时',
    LocalizationKeys.confirmCancelShutdown: '取消关机',
    LocalizationKeys.confirmCancelShutdownMessage: '确定要取消定时关机吗？',
    LocalizationKeys.keepSchedule: '保持计划',

    // 电源管理
    LocalizationKeys.powerManagement: '电源管理',
    LocalizationKeys.currentPowerPlan: '当前电源计划',
    LocalizationKeys.quickModeSwitch: '快速模式切换',
    LocalizationKeys.allPowerPlans: '所有电源计划',
    LocalizationKeys.powerActions: '电源操作',
    LocalizationKeys.highPerformance: '高性能',
    LocalizationKeys.balanced: '平衡',
    LocalizationKeys.powerSaver: '节能',
    LocalizationKeys.active: '活动',
    LocalizationKeys.sleep: '睡眠',
    LocalizationKeys.hibernate: '休眠',
    LocalizationKeys.changePowerMode: '更改电源模式',
    LocalizationKeys.switchToPowerMode: '切换到{mode}模式？',
    LocalizationKeys.powerModeChanged: '电源模式已切换到{mode}',
    LocalizationKeys.powerPlanChanged: '电源计划已切换到{plan}',
    LocalizationKeys.confirmSleep: '睡眠',
    LocalizationKeys.confirmHibernate: '休眠',
    LocalizationKeys.confirmSleepMessage: '确定要让系统进入睡眠状态吗？',
    LocalizationKeys.confirmHibernateMessage: '确定要让系统进入休眠状态吗？',
    LocalizationKeys.failedToAction: '{action}失败',

    // 电源模式描述
    LocalizationKeys.highPerformanceDesc: '最大性能，较高能耗',
    LocalizationKeys.balancedDesc: '平衡性能和能效',
    LocalizationKeys.powerSaverDesc: '降低性能，减少能耗',
  },
  'en_US': {
    LocalizationKeys.confirm: 'Confirm',
    LocalizationKeys.cancel: 'Cancel',

    // ========== System Tools ==========
    LocalizationKeys.navSystemTools: 'System Tools',
    LocalizationKeys.systemTools: 'System Tools',
    LocalizationKeys.platformNotSupported: 'Platform Not Supported',
    LocalizationKeys.platformNotSupportedMessage:
        'This feature is only available on Windows',

    // Shutdown Timer
    LocalizationKeys.shutdownTimer: 'Shutdown Timer',
    LocalizationKeys.shutdownScheduled: 'Shutdown Scheduled',
    LocalizationKeys.scheduleShutdown: 'Schedule Shutdown',
    LocalizationKeys.cancelShutdown: 'Cancel Shutdown',
    LocalizationKeys.shutdownCancelled: 'Shutdown cancelled successfully',
    LocalizationKeys.shutdownScheduledSuccess:
        'Shutdown scheduled successfully',
    LocalizationKeys.scheduling: 'Scheduling...',
    LocalizationKeys.duration: 'Duration',
    LocalizationKeys.specificTime: 'Specific Time',
    LocalizationKeys.setDuration: 'Set Duration',
    LocalizationKeys.setSpecificTime: 'Set Specific Time',
    LocalizationKeys.setDelayTime: 'Set delay time',
    LocalizationKeys.setExactTime: 'Set exact time',
    LocalizationKeys.hours: 'Hours',
    LocalizationKeys.minute: 'Minutes',
    LocalizationKeys.second: 'Seconds',
    LocalizationKeys.selectDateTime: 'Select Date & Time',
    LocalizationKeys.pleaseSelectDateTime: 'Please select a date and time',
    LocalizationKeys.pleaseSetValidDuration: 'Please set a valid duration',
    LocalizationKeys.quickActions: 'Quick Actions',
    LocalizationKeys.tenMinutes: '10 Minutes',
    LocalizationKeys.thirtyMinutes: '30 Minutes',
    LocalizationKeys.oneHour: '1 Hour',
    LocalizationKeys.twoHours: '2 Hours',
    LocalizationKeys.confirmCancelShutdown: 'Cancel Shutdown',
    LocalizationKeys.confirmCancelShutdownMessage:
        'Are you sure you want to cancel the scheduled shutdown?',
    LocalizationKeys.keepSchedule: 'Keep Schedule',

    // Power Management
    LocalizationKeys.powerManagement: 'Power Management',
    LocalizationKeys.currentPowerPlan: 'Current Power Plan',
    LocalizationKeys.quickModeSwitch: 'Quick Mode Switch',
    LocalizationKeys.allPowerPlans: 'All Power Plans',
    LocalizationKeys.powerActions: 'Power Actions',
    LocalizationKeys.highPerformance: 'High Performance',
    LocalizationKeys.balanced: 'Balanced',
    LocalizationKeys.powerSaver: 'Power Saver',
    LocalizationKeys.active: 'Active',
    LocalizationKeys.sleep: 'Sleep',
    LocalizationKeys.hibernate: 'Hibernate',
    LocalizationKeys.changePowerMode: 'Change Power Mode',
    LocalizationKeys.switchToPowerMode: 'Switch to {mode} mode?',
    LocalizationKeys.powerModeChanged: 'Power mode changed to {mode}',
    LocalizationKeys.powerPlanChanged: 'Power plan changed to {plan}',
    LocalizationKeys.confirmSleep: 'Sleep',
    LocalizationKeys.confirmHibernate: 'Hibernate',
    LocalizationKeys.confirmSleepMessage:
        'Are you sure you want to Sleep the system?',
    LocalizationKeys.confirmHibernateMessage:
        'Are you sure you want to Hibernate the system?',
    LocalizationKeys.failedToAction: 'Failed to {action}',

    // Power Mode Descriptions
    LocalizationKeys.highPerformanceDesc:
        'Maximum performance, higher energy consumption',
    LocalizationKeys.balancedDesc: 'Balanced performance and energy efficiency',
    LocalizationKeys.powerSaverDesc:
        'Reduced performance, lower energy consumption',
  },
};
