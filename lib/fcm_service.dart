import 'dart:convert';
import 'dart:io';
import 'package:b2conline/domain.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

import '../main.dart';
import 'home.dart';
import 'sharePreference.dart';

/*
  * firebase messaging
  * */
final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
final BehaviorSubject<ReceivedNotification> didReceivedLocalNotificationSubject = BehaviorSubject<ReceivedNotification>();

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void setupFcm() async {
  /*
    * register token
    * */
  _firebaseMessaging.getToken().then((token) async {
    await SharePreferences().save('token', token);
    await Domain().registerDeviceToken(token);
  });
  // Update the iOS foreground notification presentation options to allow
  // heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  if (Platform.isIOS) {
    _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  var initializationSettingsAndroid = AndroidInitializationSettings('logo');
  /*
    * ios
    * */
  var initializationSettingsIOS = IOSInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
    onDidReceiveLocalNotification: (id, title, body, payload) async {
      ReceivedNotification receivedNotification = ReceivedNotification(id: id, title: title, body: body, payload: payload);
      didReceivedLocalNotificationSubject.add(receivedNotification);
    },
  );

  /*
    * initialize for both
    * */
  var initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

  //when the app is in foreground state and you click on notification.
  flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: (String? payload) {
    if (payload != null) {
      Map<String, dynamic> data = json.decode(payload);
      goToNextScreen(data);
    }
  });

  //When the app is terminated, i.e., app is neither in foreground or background.
  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    //Its compulsory to check if RemoteMessage instance is null or not.
    if (message != null) {
      goToNextScreen(message.data);
    }
  });

  //When the app is in the background, but not terminated.
  FirebaseMessaging.onMessageOpenedApp.listen(
    (event) {
      goToNextScreen(event.data);
    },
    cancelOnError: false,
    onDone: () {},
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    // final String largeIcon =
    //     await _base64encodedImage('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQk7rx5vmxMYU6DBHinYadS51HC83IJiLnfzIS2MfXmTw&s');
    // final String bigPicture =
    //     await _base64encodedImage('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQk7rx5vmxMYU6DBHinYadS51HC83IJiLnfzIS2MfXmTw&s');
    //
    // final BigPictureStyleInformation bigPictureStyleInformation =
    //     BigPictureStyleInformation(ByteArrayAndroidBitmap.fromBase64String(bigPicture), //Base64AndroidBitmap(bigPicture),
    //         largeIcon: ByteArrayAndroidBitmap.fromBase64String(largeIcon),
    //         contentTitle: message.data['title'],
    //         htmlFormatContentTitle: true,
    //         summaryText: message.data['body'],
    //         htmlFormatSummaryText: true);
    // var bigPictureStyle = await _createBigPictureStyle('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQk7rx5vmxMYU6DBHinYadS51HC83IJiLnfzIS2MfXmTw&s');
    flutterLocalNotificationsPlugin.show(
      int.parse(message.data['id']),
      message.data['title'],
      message.data['body'],
      NotificationDetails(
        android: AndroidNotificationDetails(
          message.data['android_channel_id'], message.data['name'],
          channelDescription: message.data['body'],
          icon: 'logo',
          color: Colors.green,
          importance: Importance.max,
          priority: Priority.high,

          // styleInformation: bigPictureStyleInformation
        ),
      ),
      payload: json.encode(message.data),
    );
  });
}

// Future<BigPictureStyleInformation> _createBigPictureStyle(
//     String imagePath) async {
//   var largeIconPath = await _downloadAndSaveImage(notificationData['largeIconUrl']);
//   return BigPictureStyleInformation(
//     FilePathAndroid(imagePath),
//     largeIcon: FilePathAndroid(largeIconPath),
//     contentTitle: 'Notification Title',
//     summaryText: 'Notification Summary',
//   );
// }

// Future<String> _downloadAndSaveImage(String url) async {
//   final directory = await get();
//   final filePath = '${directory.path}/largeIcon.png';
//   var response = await http.get(Uri.parse(url));
//   var file = File(filePath);
//   await file.writeAsBytes(response.bodyBytes);
//   return filePath;
// }

Future<void> deleteFcmToken() async {
  return await FirebaseMessaging.instance.deleteToken();
}

Future<String> getFcmToken() async {
  String? token = await FirebaseMessaging.instance.getToken();
  return Future.value(token);
}

void goToNextScreen(Map<String, dynamic> data) {
  if (data['click_action'] != null) {
    navigatorKey.currentState!.push(
      MaterialPageRoute(
        builder: (context) => WebView(path: data['url']),
      ),
    );
    return;
  }
}

Future<String> _base64encodedImage(String url) async {
  final http.Response response = await http.get(Uri.parse(url));
  final String base64Data = base64Encode(response.bodyBytes);
  return base64Data;
}

class ReceivedNotification {
  final int? id;
  final String? title;
  final String? body;
  final String? payload;

  ReceivedNotification({
    this.id,
    this.title,
    this.body,
    this.payload,
  });
}
