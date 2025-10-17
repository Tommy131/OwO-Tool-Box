import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../services/notification_service.dart';

class NotificationDemoPage extends StatefulWidget {
  const NotificationDemoPage({super.key});

  @override
  State<NotificationDemoPage> createState() => _NotificationDemoPageState();
}

class _NotificationDemoPageState extends State<NotificationDemoPage> {
  final NotificationService _notificationService = NotificationService();
  int _notificationId = 0;

  @override
  void initState() {
    super.initState();
    _notificationService.initialize();
  }

  int _getNextId() => _notificationId++;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('通知示例'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ElevatedButton(
            onPressed: () {
              _notificationService.showNotification(
                id: _getNextId(),
                title: '简单通知',
                body: '这是一个简单的通知消息',
                payload: 'simple_notification',
              );
            },
            child: const Text('显示简单通知'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              _notificationService.showBigTextNotification(
                id: _getNextId(),
                title: '大文本通知',
                body: '点击查看更多',
                bigText: '这是一段很长的文本内容,可以在展开的通知中显示更多详细信息。'
                    '支持多行显示,让用户看到完整的消息内容而无需打开应用。',
              );
            },
            child: const Text('显示大文本通知'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              final id = _getNextId();
              for (int i = 0; i <= 100; i += 10) {
                await Future.delayed(const Duration(milliseconds: 500));
                _notificationService.showProgressNotification(
                  id: id,
                  title: '下载中...',
                  progress: i,
                  maxProgress: 100,
                );
              }
            },
            child: const Text('显示进度通知'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              _notificationService.scheduleNotification(
                id: _getNextId(),
                title: '定时通知',
                body: '这是一个5秒后的定时通知',
                scheduledTime: DateTime.now().add(const Duration(seconds: 5)),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已设置5秒后的定时通知')),
              );
            },
            child: const Text('5秒后显示通知'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              _notificationService.showPeriodicNotification(
                id: _getNextId(),
                title: '周期通知',
                body: '这是一个每分钟重复的通知',
                interval: RepeatInterval.everyMinute,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已设置每分钟重复通知')),
              );
            },
            child: const Text('显示周期通知(每分钟)'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              _notificationService.showNotificationWithActions(
                id: _getNextId(),
                title: '操作通知',
                body: '这是一个带操作按钮的通知',
              );
            },
            child: const Text('显示带操作按钮的通知'),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              final pending =
                  await _notificationService.getPendingNotifications();
              if (context.mounted) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('待处理通知'),
                    content: Text('共有 ${pending.length} 个待处理通知'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('关闭'),
                      ),
                    ],
                  ),
                );
              }
            },
            child: const Text('查看待处理通知'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              _notificationService.cancelAllNotifications();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已取消所有通知')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('取消所有通知'),
          ),
        ],
      ),
    );
  }
}
