import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';

class NotificationScreen extends StatefulWidget {
  static const routeName = '/notifications';
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user != null) {
        Provider.of<NotificationProvider>(
          context,
          listen: false,
        ).fetchNotifications(user.token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationData = Provider.of<NotificationProvider>(context);
    final user = Provider.of<AuthProvider>(context, listen: false).user;

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: notificationData.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notificationData.notifications.isEmpty
          ? const Center(child: Text('No notifications yet.'))
          : ListView.builder(
              itemCount: notificationData.notifications.length,
              itemBuilder: (ctx, i) {
                final notification = notificationData.notifications[i];
                return Card(
                  color: notification.isRead ? Colors.white : Colors.blue[50],
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: ListTile(
                    leading: Icon(
                      notification.isRead
                          ? Icons.notifications_none
                          : Icons.notifications_active,
                      color: notification.isRead ? Colors.grey : Colors.blue,
                    ),
                    title: Text(notification.message),
                    subtitle: Text(
                      DateFormat(
                        'dd MMM yyyy, hh:mm a',
                      ).format(notification.createdAt),
                    ),
                    onTap: () {
                      if (!notification.isRead && user != null) {
                        notificationData.markAsRead(
                          user.token,
                          notification.id,
                        );
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
