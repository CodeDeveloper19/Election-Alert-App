import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class localNotification extends StatefulWidget {
  localNotification({super.key, required this.notificationTitle,
    required this.notificationBody, required this.id, required this.mapController, required this.alertLatitude, required this.alertLongitude});

  final String notificationTitle;
  final String notificationBody;
  final int id;
  final GoogleMapController mapController;
  final double alertLatitude;
  final double alertLongitude;

  Future<void> showNotification() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    await FlutterAppBadger.updateBadgeCount(2);

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/launcher_icon'); // Replace 'app_icon' with your app's icon name

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: (notificationResponse) async {
      await mapController.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(alertLatitude, alertLongitude),
          17.0, // You can adjust the zoom level as needed.
        ),
      );
      // homePage.
    });

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

    // Set your custom payload here
    String customPayload = 'custom_action';

    // Store the payload in shared_preferences
    // SharedPreferences preferences = await SharedPreferences.getInstance();
    // await preferences.setString('notification_payload', customPayload);

    await flutterLocalNotificationsPlugin.show(
      id, // Notification ID
      notificationTitle, // Notification title
      notificationBody, // Notification body
      platformChannelSpecifics,
      payload: customPayload, // Optional payload
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
