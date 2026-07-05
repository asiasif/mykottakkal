import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'booking_status_channel',
      'Booking Status Updates',
      channelDescription: 'Notifications for worker status updates',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    
    await _notificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  // Monitor booking status changes for the current user
  static void monitorBookings() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('bookings')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.modified) {
          final data = change.doc.data() as Map<String, dynamic>;
          final status = data['status'];
          final workerName = data['workerName'];
          
          if (status != null && workerName != null) {
             _handleStatusChange(status, workerName);
          }
        }
      }
    });
  }

  static void _handleStatusChange(String status, String workerName) {
    String title = "Update on your Booking";
    String body = "";

    switch (status) {
      case 'Confirmed':
        body = "$workerName has accepted your booking! 🎉";
        break;
      case 'On the Way':
        body = "$workerName is on the way to your location! 🚗";
        break;
      case 'Working':
        body = "$workerName has started working. 🛠️";
        break;
      case 'Completed':
        body = "Work completed by $workerName. Please rate! ⭐";
        break;
      case 'Cancelled':
        body = "Booking with $workerName was cancelled. ❌";
        break;
      default:
        return; 
    }

    showNotification(title, body);
  }
}
