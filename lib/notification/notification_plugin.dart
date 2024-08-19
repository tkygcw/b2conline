import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:io' show Platform;

import 'notification.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

class NotificationPlugin {
  final BehaviorSubject<ReceivedNotification> didReceivedLocalNotificationSubject = BehaviorSubject<ReceivedNotification>();
  var initializationSettings;

  NotificationPlugin() {}

  void createChannel(List<CustomNotificationChannel> notificationChannels) {
    for (int i = 0; i < notificationChannels.length; i++) {
      createAndroidNotificationChannel(notificationChannels[i]);
    }
  }

  init() async {
    // flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    if (Platform.isIOS) {
      _requestIOSPermission();
    }
    initializePlatformSpecifics();
  }

  initializePlatformSpecifics() async {
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
    initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: onSelectNotification);
  }

  Future<void> onSelectNotification(String? payload) async {
    // Handle the notification click event
    // You can navigate to a specific screen or perform any other action
    print('our payload here $payload');
  }

  _requestIOSPermission() {
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
          alert: false,
          badge: true,
          sound: true,
        );
  }

  setListenerForLowerVersions(Function onNotificationInLowerVersions) {
    didReceivedLocalNotificationSubject.listen((receivedNotification) {
      onNotificationInLowerVersions(receivedNotification);
    });
  }

  Future<void> createAndroidNotificationChannel(CustomNotificationChannel channel) async {
    print('channel id: ${channel.channelId}');
    print('channel id: ${channel.sound}');
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var androidNotificationChannel = AndroidNotificationChannel(
      channel.channelId.toString(),
      channel.channelName!,
      description: channel.description,
      playSound: true,
      importance: Importance.high,
      sound: RawResourceAndroidNotificationSound(channel.sound),
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel);
  }

  Future<int> getPendingNotificationCount() async {
    List<PendingNotificationRequest> p = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    return p.length;
  }

  Future<void> cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancel(0);
  }

  Future<void> cancelAllNotification() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
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
