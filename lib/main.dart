import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
// import 'package:url_launcher/url_launcher.dart';

Future<void> myBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  return _MyAppState()._showNotification(message, true);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(myBackgroundHandler);
  // runApp() 호출 전 Flutter SDK 초기화
  KakaoSdk.init(
    nativeAppKey: '6715e7eb3fcb15643b5ddf2c35bd52d1',
    javaScriptAppKey: '94f660d5b29760bb7ff5e51729ad26be',
  );
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
  static const platform = const MethodChannel('intent');
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  String fcmToken = "Getting Firebase Token";
  DateTime? _lastPressedAt; // To track back button presses


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

    _localNotiSetting(); // Local notificiatioin 초기 설정

    getFCMToken();
  }

  void _localNotiSetting() async {
    var androidInitializationSettings =AndroidInitializationSettings('@mipmap/ic_launcher');
    // 안드로이드 알림 올 때 앱 아이콘 설정

    // 만약에 사용자에게 앱 권한을 안 물어봤을 경우 이 셋팅으로 인해 permission check 함

    var initsetting = InitializationSettings(
        android: androidInitializationSettings);

    await flutterLocalNotificationsPlugin.initialize(initsetting);
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
    print(message.notification?.title);
    Map<String, dynamic> data = message.data;
    AndroidNotification? android = message.notification?.android;
    if(!isFromBackground){
      flutterLocalNotificationsPlugin.show(
            0,
          message.notification?.title,
          message.notification?.body,
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
    // flutterLocalNotificationsPlugin.show(
    //   0,
    //   isFromBackground ? 'Description from background' : data['title'],
    //   data['body'],
    //   NotificationDetails(
    //     android: AndroidNotificationDetails(
    //       channel.id,
    //       channel.name,
    //       channelDescription: channel.description,
    //       icon: android?.smallIcon,
    //       // other properties...
    //     ),
    //     // iOS: IOSNotificationDetails(presentAlert: true, presentSound: true),
    //   ),
    //   payload: 'Default_Sound',
    // );
  }

  void _initialNotification() {
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }
  Future<void> _launchKotlinActivity() async {
    const platform = MethodChannel('com.example.push_notification_fcm_example/MainActivity');
    try {
      await platform.invokeMethod('openKotlinActivity');
    } catch (e) {
      print("Error invoking Kotlin activity: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // var isLastPage = await inAppWebViewController.canGoBack();
        //
        // if (isLastPage) {
        //   inAppWebViewController.goBack();
        //   return false;
        // }
        if (_lastPressedAt == null || DateTime.now().difference(_lastPressedAt!) > Duration(seconds: 2)) {
          _lastPressedAt = DateTime.now();
          // Show a toast or snackbar indicating that the user should press again to exit
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('한 번 더 누르면 앱이 종료됩니다.'),
              duration: Duration(seconds: 2),
            ),
          );
          return false;
        }
        // If the back button was pressed twice within the given time, exit the app
        return true;
      },
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          body: Stack(
            children: [
              InAppWebView(
                initialUrlRequest:
                URLRequest(url: Uri.parse("https://i9e104.p.ssafy.io")),
                onWebViewCreated: (InAppWebViewController controller) {
                  callPermissions();
                  _launchKotlinActivity();
                  inAppWebViewController = controller;
                  // 자바스크립트 채널 연결
                  inAppWebViewController.addJavaScriptHandler(handlerName: 'handleFoo', callback: (args) { print("나 왔어"); return{'fcmT':fcmToken};});
                  // 추가: WebViewController에 포그라운드 상태에서 알림 받기 위한 리스너 생성
                  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
                    _showNotification(message, false);
                  });
                },
                // InAppWebView 컴포넌트 내
                shouldOverrideUrlLoading:
                    (controller, NavigationAction navigationAction) async {
                  var uri = navigationAction.request.url!;
                  if (uri.scheme == 'intent' || uri.scheme == 'kakaotalk') {
                    try {
                      var result = await platform
                          .invokeMethod('launchKakaoTalk', {'url': uri.toString()});
                      if (result != null) {
                        await controller?.loadUrl(
                            urlRequest: URLRequest(url: Uri.parse(result)));
                      }

                    } catch (e) {
                      print('url fail $e');
                    }
                    return NavigationActionPolicy.CANCEL;
                  }
                  return NavigationActionPolicy.ALLOW;
                },
                initialOptions: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(
                        javaScriptEnabled: true,
                        javaScriptCanOpenWindowsAutomatically: true,
                        useShouldOverrideUrlLoading: true,
                        verticalScrollBarEnabled: true,
                        useShouldInterceptFetchRequest: true,
                        userAgent: 'Mozilla/5.0 (Linux; Android 10; SM-G981B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.162 Mobile Safari/537.36'
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
