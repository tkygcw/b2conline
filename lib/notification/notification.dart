class CustomNotificationChannel {
  int? channelId;
  String? title, description, message, channelName, sound;

  CustomNotificationChannel({this.channelId, this.title, this.description, this.message, this.channelName, this.sound});

  factory CustomNotificationChannel.fromJson(Map<String, dynamic> json) {
    return CustomNotificationChannel(
        channelId: json['id'] as int,
        title: json['title'],
        description: json['description'],
        message: json['message'] as String,
        channelName: json['channel_name'] as String,
        sound: json['sound'] as String);
  }
}























// import 'dart:convert';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:http/http.dart' as http;
//
// import '../main.dart';
//
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//
// const AndroidNotificationChannel channel = AndroidNotificationChannel(
//   'custom_notification_channel_id',
//   'Notification',
//   description: 'notifications from Your App Name.',
//   importance: Importance.high,
// );
//
// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
// }
//
// void setupFcm() {
//   var initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');
//   var initializationSettingsIOs = const IOSInitializationSettings();
//   var initializationSettings = InitializationSettings(
//     android: initializationSettingsAndroid,
//     iOS: initializationSettingsIOs,
//   );
//
//   //when the app is in foreground state and you click on notification.
//   flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: (String? payload) {
//     if (payload != null) {
//       Map<String, dynamic> data = json.decode(payload);
//       // goToNextScreen(data);
//       navigatorKey.currentState!.pushNamed(
//         '/',
//       );
//     }
//   });
//
//   //When the app is terminated, i.e., app is neither in foreground or background.
//   FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
//     //Its compulsory to check if RemoteMessage instance is null or not.
//     if (message != null) {
//       // goToNextScreen(message.data);
//       navigatorKey.currentState!.pushNamed(
//         '/',
//       );
//     }
//   });
//
//   //When the app is in the background, but not terminated.
//   FirebaseMessaging.onMessageOpenedApp.listen(
//         (event) {
//       // goToNextScreen(event.data);
//     },
//     cancelOnError: false,
//     onDone: () {},
//   );
//
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//     RemoteNotification? notification = message.notification;
//     AndroidNotification? android = message.notification?.android;
//
//     flutterLocalNotificationsPlugin.show(
//       notification.hashCode,
//       notification!.title,
//       notification.body,
//       NotificationDetails(
//         android: AndroidNotificationDetails(
//           channel.id,
//           channel.name,
//           channelDescription: channel.description,
//           icon: 'logo',
//           color: Colors.green,
//           importance: Importance.max,
//           priority: Priority.high,
//         ),
//       ),
//       payload: json.encode(message.data),
//     );
//   });
// }
//
// Future<void> deleteFcmToken() async {
//   return await FirebaseMessaging.instance.deleteToken();
// }
//
// Future<String> getFcmToken() async {
//   String? token = await FirebaseMessaging.instance.getToken();
//   return Future.value(token);
// }
//
// void goToNextScreen(Map<String, dynamic> data) {
//   if (data['click_action'] != null) {
//     navigatorKey.currentState!.pushNamed(
//       '/testing',
//     );
//     return;
//   }
// }
//
// Future<String> _base64encodedImage(String url) async {
//   final http.Response response = await http.get(Uri.parse(url));
//   final String base64Data = base64Encode(response.bodyBytes);
//   return base64Data;
// }

