// @dart=2.9
import 'dart:isolate';
import 'dart:ui';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:globe_flutter/available_cities.dart';
import 'package:globe_flutter/const.dart';
import 'package:globe_flutter/globa_data.dart';
import 'package:globe_flutter/global_navigator.dart';
import 'package:globe_flutter/globe_notification_controller.dart';
import 'package:globe_flutter/globe_view.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:globe_flutter/received_notification.dart';
import 'package:package_info/package_info.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'overlay_webview.dart';
import 'generated/l10n.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();
final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>();

const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
        'globe_local_notification',
        'Globe local notification channel',
        'for sending scheduled local notification',
        importance: Importance.max,
        priority: Priority.high,
        icon: "mipmap/ic_launcher",
        ticker: 'ticker');

const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

String packageVersion;
String packageNuildNumber;

final ReceivePort port = ReceivePort();
const String isolateName = 'globe_isolate';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  await Firebase.initializeApp();
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await AvailableCities.instance.loadFile();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  GlobalData.VERSION = packageInfo.version;
  GlobalData.BUILD_NUMBER = packageInfo.buildNumber;

  runApp(App());
  await AndroidAlarmManager.initialize();
  // globeNotificationController.registerScheduledNotification();
  GlobeNotificationController globeNotificationController = GlobeNotificationController();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var initialized = prefs.getBool(LS_FIELD.INITIALIZED);
  if(initialized == null || initialized == false){
    print("initial running...");
    globeNotificationController.setDefaultNotification();
    prefs.setBool(LS_FIELD.INITIALIZED, true);
  }

  prefs.setStringList(LS_FIELD.NOTIFICATION_TEXT, [
    S.of(GlobalNavigator.Key.currentContext).appTitle,
    S.of(GlobalNavigator.Key.currentContext).localNotificationBody
  ]);

  IsolateNameServer.registerPortWithName(
    port.sendPort,
    isolateName,
  );

  globeNotificationController.getRegisteredNotifications();
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AppState();
}

class _AppState extends State<App> {

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
    } else {
      bool isAndroid = Theme.of(context).platform == TargetPlatform.android;
      if (isAndroid) WebView.platform = SurfaceAndroidWebView();
      // if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
      _requestPermissions();
      _configureDidReceiveLocalNotificationSubject();
      _configureSelectNotificationSubject();
    }
  }

  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationSubject.stream
        .listen((ReceivedNotification receivedNotification) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body)
              : null,
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                await Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => GlobeView(),
                  ),
                );
              },
              child: const Text('Ok'),
            )
          ],
        ),
      );
    });
  }

  void _requestPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future<void> initLocalNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('mipmap/ic_launcher');

    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
            onDidReceiveLocalNotification:
                (int id, String title, String body, String payload) async {
              didReceiveLocalNotificationSubject.add(ReceivedNotification(
                  id: id, title: title, body: body, payload: payload));
            });
    const MacOSInitializationSettings initializationSettingsMacOS =
        MacOSInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false);
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
            macOS: initializationSettingsMacOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) async {
      if (payload != null) {
        debugPrint('notification payload: $payload');
      }
      selectNotificationSubject.add(payload);
    });
  }

  void _configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((String payload) async {
      await Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (BuildContext context) => GlobeView()),
      );
    });
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GlobeView(),
                ),
              );
            },
          )
        ],
      ),
    );
  }


  Future<void> fcmSubscribe(String lang) async {
    print(DateTime.now().timeZoneName);
    print('language_' + lang);

    if (!kIsWeb) {
      switch (lang) {
        case "es":
        case "ko":
        case "ja":
          {
            await FirebaseMessaging.instance
                .subscribeToTopic('language_' + lang);
            break;
          }
        default:
          {
            await FirebaseMessaging.instance.subscribeToTopic('language_en');
            break;
          }
      }
    }
  }

  Future<void> fcmUnSubscribe(String lang) async {
    await FirebaseMessaging.instance.subscribeToTopic('language_' + lang);
  }

  @override
  Widget build(BuildContext context) {
    print("main:build()");
    // AppLocalizationDelegate().
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SystemChrome.setSystemUIOverlayStyle( SystemUiOverlayStyle(statusBarBrightness: Brightness.dark));
    FirebaseAnalytics analytics = FirebaseAnalytics();
    return MaterialApp(
        navigatorKey: GlobalNavigator.Key,
        debugShowCheckedModeBanner: false,
        title: 'Globe',
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: analytics),
        ],
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Stack(
          children: [
            Container(
                color: Colors.white,
                child: new SafeArea(child: GlobeView())),
            SafeArea(child: OverlayView()),
          ],
        ),
        localeResolutionCallback: (deviceLocale, supportedLocales) {
          print("localeResolutionCallback");
          print("localeResolutionCallback countryCode:" +
              deviceLocale.countryCode);
          print("localeResolutionCallback languageCode:" +
              deviceLocale.languageCode);
          if (deviceLocale != null) {
            for (Locale supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == deviceLocale.languageCode ||
                  supportedLocale.countryCode == deviceLocale.countryCode) {
                fcmSubscribe(deviceLocale.languageCode);
                return supportedLocale;
              }
            }
          }
          return supportedLocales.first;
        },
        supportedLocales: [
          Locale('en'),
          Locale('ko'),
          Locale('ja'),
        ]);
  }

  // Future<void> registerScheduledNotification() async {
  //   await showPeriodicNotification();
  // }
  //
  // Future<void> unregisterScheduledNotification() async {
  //   await flutterLocalNotificationsPlugin.cancel(0);
  // }
}
