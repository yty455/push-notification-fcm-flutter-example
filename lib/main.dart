import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> myBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  return _MyAppState()._showNotification(message, true);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(myBackgroundHandler);
  runApp(const MaterialApp(home: MyApp(),));
}

// 권한 요청 코드
void callPermissions() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.notification,
    Permission.storage,
  ].request();

  print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
  print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
  print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
  print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
  print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
  print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");

  print(statuses[Permission.notification]?.isGranted);
  print(statuses[Permission.storage]?.isGranted);
  print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
  print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
  print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
  print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
  print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
  print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
  print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");


}


class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double _progress = 0;
  late InAppWebViewController inAppWebViewController;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  String fcmToken = "Getting Firebase Token";

  void sendFcmTokenToWeb(String token){
    inAppWebViewController.evaluateJavascript(source: 'receiveFcmToken("${json.encode(token)}");');
  }

  @override
  void initState() {
    _initialNotification();
    super.initState();

    FirebaseMessaging.onMessage.listen((message) {
      print(message);
      if (message.data.isNotEmpty) _showNotification(message, false);
    });

    getFCMToken();
  }

  getFCMToken() async {
    String? token = await _firebaseMessaging.getToken();
    setState(() {
      fcmToken = token!;
      print(fcmToken);
      sendFcmTokenToWeb(fcmToken);
    });
  }

  Future _showNotification(RemoteMessage message, bool isFromBackground) async {
    const channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.max);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    print(message.data);
    Map<String, dynamic> data = message.data;
    AndroidNotification? android = message.notification?.android;
    flutterLocalNotificationsPlugin.show(
      0,
      isFromBackground ? 'Description from background' : data['title'],
      data['body'],
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          icon: android?.smallIcon,
          // other properties...
        ),
        // iOS: IOSNotificationDetails(presentAlert: true, presentSound: true),
      ),
      payload: 'Default_Sound',
    );
  }

  void _initialNotification() {
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        var isLastPage = await inAppWebViewController.canGoBack();

        if (isLastPage) {
          inAppWebViewController.goBack();
          return false;
        }

        return true;
      },
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          body: Stack(
            children: [
              InAppWebView(
                initialUrlRequest:
                URLRequest(url: Uri.parse("http://43.200.254.50:80")),
                onWebViewCreated: (InAppWebViewController controller) {
                  callPermissions();
                  inAppWebViewController = controller;
                  // 자바스크립트 채널 연결
                  inAppWebViewController.addJavaScriptHandler(handlerName: 'handleFoo', callback: (args) { print("나 왔어"); return{'fcmT':fcmToken};});
                },
                initialOptions: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(
                        useShouldOverrideUrlLoading: true,
                        verticalScrollBarEnabled: true,
                        userAgent: 'Mozilla/5.0 (Linux; Android 9; LG-H870 Build/PKQ1.190522.001) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/83.0.4103.106 Mobile Safari/537.36'
                    ),
                ),
                //파일 첨부 권한 요청
                androidOnPermissionRequest:
                    (InAppWebViewController controller, String origin,
                    List<String> resources) async {
                  return PermissionRequestResponse(
                      resources: resources,
                      action: PermissionRequestResponseAction.GRANT);
                },

                onProgressChanged:
                    (InAppWebViewController controller, int progress) {
                  setState(() {
                    _progress = progress / 100;
                  });
                },
              ),

              _progress < 1
                  ? Container(
                child: LinearProgressIndicator(
                  value: _progress,
                ),
              )
                  : const SizedBox()
            ],
          ),
        ),
      ),
    );
  }
}
