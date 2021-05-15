// @dart=2.9
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:globe_flutter/globe_view.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:globe_flutter/setting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'overlay_webview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    // _firebaseMessaging.configure(
    //   onMessage: (Map<String, dynamic> message) async {
    //     print("onMessage: $message");
    //   },
    //   onLaunch: (Map<String, dynamic> message) async {
    //     print("onLaunch: $message");
    //   },
    //   onResume: (Map<String, dynamic> message) async {
    //     print("onResume: $message");
    //   },
    // );
    // _firebaseMessaging.requestNotificationPermissions(
    //     const IosNotificationSettings(sound: true, badge: true, alert: true));
    // _firebaseMessaging.onIosSettingsRegistered
    //     .listen((IosNotificationSettings settings) {
    //   print("Settings registered: $settings");
    // });
    // _firebaseMessaging.getToken().then((String token) {
    //   assert(token != null);
    //   print("Push Messaging token: $token");
    // });
  }

  void fcmSubscribe(String lang) {
    print(DateTime.now().timeZoneName);
    switch (lang) {
      case "es":
      case "ko":
      case "ja":
        {
          print('language_' + lang);
          // _firebaseMessaging.subscribeToTopic('language_'+lang);
          break;
        }
      default:
        {
          // _firebaseMessaging.subscribeToTopic('language_en');
          break;
        }
    }
  }

  //
  // void fcmUnSubscribe(String lang) {
  //   _firebaseMessaging.unsubscribeFromTopic('language_'+lang);
  // }

  @override
  Widget build(BuildContext context) {
    print("main:build()");
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarBrightness: Brightness.dark));

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Globe',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
          home: Stack(
            children: [
              Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.topRight,
                            colors: [Colors.blue, Colors.pink.shade300])),
                    child: new SafeArea(child: GlobeView())
              ),
              SafeArea(child: OverlayView()),
            ],
          ),
          localizationsDelegates: [
            // ... app-specific localization delegate[s] here
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (deviceLocale, supportedLocales) {
            print("localeResolutionCallback");
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
            Locale('es'),
          ]
    );
  }
}
