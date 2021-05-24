// @dart=2.9
// import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:globe_flutter/available_cities.dart';
import 'package:globe_flutter/globe_view.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'overlay_webview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  await Firebase.initializeApp();
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await AvailableCities.instance.loadFile();
  runApp(MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
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
    if(kIsWeb){

    }else{
      bool isAndroid = Theme.of(context).platform == TargetPlatform.android;
      if(isAndroid) WebView.platform = SurfaceAndroidWebView();
      // if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    }

  }

  Future<void> fcmSubscribe(String lang) async {
    print(DateTime.now().timeZoneName);
    print('language_' + lang);

    if(!kIsWeb){
      switch (lang) {
        case "es":
        case "ko":
        case "ja":
          {
            await FirebaseMessaging.instance.subscribeToTopic('language_'+lang);
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
    await FirebaseMessaging.instance.subscribeToTopic('language_'+lang);
  }

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
            print("localeResolutionCallback countryCode:"+deviceLocale.countryCode);
            print("localeResolutionCallback languageCode:"+deviceLocale.languageCode);
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
