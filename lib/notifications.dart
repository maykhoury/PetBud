import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:petbud/parent/HomePage.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final GlobalKey<NavigatorState> navigatorKey1 = GlobalKey<NavigatorState>();

class NotificationServices extends ChangeNotifier {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  //List<ActiveNotification> notifications = [];
  List<PendingNotificationRequest> notifications = [];

  Future<void> initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    // await flutterLocalNotificationsPlugin.initialize(initializationSettings,
    //     onDidReceiveNotificationResponse:
    //         (NotificationResponse notificationResponse) async {});

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
    onDidReceiveNotificationResponse:
        (NotificationResponse notificationResponse) async {
      String payload = notificationResponse.payload ?? '';
      print("Payload: $payload");
      await fetchNotifications();
      // Navigate to the parent's home page and scroll to the end
      navigatorKey1.currentState!.push(
        MaterialPageRoute(
          builder: (context) => ParentHomePage(shouldScrollToEnd: true),
        ),
      );
  });

    // Create a notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'channelId', // id
        'channelName', // title
        description: "channelDescription",
        importance: Importance.max);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await fetchNotifications();
  }

  notificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails("channelId", "channelName",
            channelDescription: "channelDescription",
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker'));
  }

  Future scheduleNotification(
      String docId, String title, String body, DateTime scheduledDate) async {
    int id = ((docId+scheduledDate.toIso8601String()).hashCode);
    print(
        'Scheduling notification at $scheduledDate for docId: $docId with id: $id');

    // Convert the scheduledDate to a timestamp
    int timestamp = scheduledDate.millisecondsSinceEpoch;

    // Combine the title, body, and timestamp into a JSON string
    String payload = jsonEncode({
      'title': title,
      'body': body,
      'timestamp': timestamp,
    });

    await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        await notificationDetails(),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload);
    // return flutterLocalNotificationsPlugin.show(
    //   id,
    //   title,
    //   body,
    //   await notificationDetails(),
    // );
    // Print all pending notifications
    List<PendingNotificationRequest> pendingNotifications =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    for (var notification in pendingNotifications) {
      print(notification.title);
      print(notification.body);
      print(notification.payload);
    }
      await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    print(pendingNotifications);

    // After scheduling the notification, fetch the notifications and notify listeners
    await fetchNotifications();
    notifyListeners();
  }

  Future scheduleRecurringNotification(
      int docId, String title, String body, Day day, DateTime time) async {
    int id = docId;
    print('Scheduling recurring notification for docId: $docId with id: $id');

    tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    // Get the hour and minute from the time variable
    int hour = time.hour;
    int minute = time.minute;

    // Create the scheduledDate
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    print('Device Time Zone: ${DateTime.now().timeZoneName}');
    print('tz.local Time Zone: ${tz.local}');

    print('Day: $day');
    print('Scheduled Date: $scheduledDate');
    print("Now: $now");

    // Convert the day and time to strings
    String dayString = DateFormat('EEEE').format(scheduledDate);
    String timeString = DateFormat('HH:mm').format(scheduledDate);

    // Combine the title, body, dayString, and timeString into a JSON string
    String payload = jsonEncode({
      'title': title,
      'body': body,
      'day': dayString,
      'time': timeString,
    });

    // If the scheduled date is in the past, add one week to it
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(Duration(days: 7));
    }

    var details = await notificationDetails();
    print('Notification Details: $details');

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      await notificationDetails(),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: payload);

    // After scheduling the notification, fetch the notifications and notify listeners
    await fetchNotifications();
    notifyListeners();
  }

  Future<bool> isNotificationScheduled(int docId) async {
    int id = docId;
    var pendingNotifications =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    for (var notification in pendingNotifications) {
      print(
          "notification.id: ${notification.id}, id: $id  notification.body: ${notification.body}");
      if (notification.id == id) {
        return true;
      }
    }
    return false;
  }

  Future cancelNotification(String docId) async {
    int id = docId.hashCode;
    await flutterLocalNotificationsPlugin.cancel(id);
    // After cacelling the notification, fetch the notifications and notify listeners
    await fetchNotifications();
    // Remove the cancelled notification from the notifications list
    notifications.removeWhere((notification) => notification.id == id);
    await fetchNotifications();
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();

    // After cancelling all notifications, fetch the notifications and notify listeners
    await fetchNotifications();
  }

  // Future<void> fetchNotifications() async {
  //   final List<ActiveNotification> activeNotification =
  //       await flutterLocalNotificationsPlugin.getActiveNotifications();

  //   // notifications = pendingNotifications.where((notification) {
  //   //   // Retrieve the scheduled time from the payload
  //   //   DateTime scheduledDate = DateTime.parse(notification.payload!);
  //   //   DateTime twoDaysAgo = DateTime.now().subtract(Duration(days: 2));
  //   //   return scheduledDate.isAfter(twoDaysAgo) && scheduledDate.isBefore(DateTime.now());
  //   // }).toList();
  //   notifications = activeNotification.toList();

  //   // Notify listeners about the change
  //   notifyListeners();
  // }
  Future<List<PendingNotificationRequest>> fetchNotifications() async {
    final List<PendingNotificationRequest> pendingNotifications =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    
    // Add only the notifications that do not exist in the notifications list
    for (var notification in pendingNotifications) {
      if (!notifications.any((n) => n.id == notification.id)) {
        notifications.add(notification);
      }
    }

    final List<ActiveNotification> activeNotifications =
        await flutterLocalNotificationsPlugin.getActiveNotifications();

    // Sort the notifications by ID
    // pendingNotifications.sort((a, b) => a.id.compareTo(b.id));
    // activeNotifications.sort((a, b) => a.id.compareTo(b.id));

    // Print the notifications
    print('Pending notifications:');
    for (var notification in pendingNotifications) {
      print('ID: ${notification.id}, Title: ${notification.title}, Body: ${notification.body}, Payload: ${notification.payload}');
    }

    print('Active notifications:');
    for (var notification in activeNotifications) {
      print('ID: ${notification.id}, Title: ${notification.title}, Body: ${notification.body}, Payload: ${notification.payload}');
    }
    print('Notifications:');
    for (var notification in notifications) {
      print('ID: ${notification.id}, Title: ${notification.title}, Body: ${notification.body}, Payload: ${notification.payload}');
    }

    // Notify listeners about the change
    //notifyListeners();
    return notifications;
  }
}


