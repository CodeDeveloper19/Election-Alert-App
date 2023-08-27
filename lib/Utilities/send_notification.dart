import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class localNotification extends StatefulWidget {
  localNotification({super.key, required this.notificationTitle, required this.notificationBody});

  final String notificationTitle;
  final String notificationBody;

  Future<void> showNotification() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    await FlutterAppBadger.updateBadgeCount(2);

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/launcher_icon'); // Replace 'app_icon' with your app's icon name
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'election_alert_app', // Replace with your channel ID
      'Election Alert App', // Replace with your channel name
      channelDescription: 'alert notification for election alert app', // Replace with your channel description
      importance: Importance.max,
      priority: Priority.high,
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
      enableVibration: true,
      color: Colors.green.shade600,
      fullScreenIntent: true
    );

    NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      notificationTitle, // Notification title
      notificationBody, // Notification body
      platformChannelSpecifics,
      payload: 'item x', // Optional payload
    );
    // Remove the badge count when the app is opened
    await FlutterAppBadger.removeBadge();
  }

  @override
  State<localNotification> createState() => _localNotificationState();
}

class _localNotificationState extends State<localNotification> {
  @override
  Widget build(BuildContext context) {

    return const Placeholder();
  }
}
