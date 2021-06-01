import 'dart:isolate';
import 'dart:ui';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:globe_flutter/const.dart';
import 'package:globe_flutter/global_navigator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:globe_flutter/generated/l10n.dart';

const MethodChannel platform = MethodChannel('dexterx.dev/flutter_local_notifications_example');
const String isolateName = 'globe_isolate';

int alarmId = 1006;
typedef UnRegisterCallback = void Function();


const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'globe_local_notification',
    'Globe local notification channel',
    'for sending scheduled local notification',
    importance: Importance.max,
    priority: Priority.high,
    icon: "mipmap/ic_launcher",
    ticker: 'ticker');

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

class GlobeNotificationController{

  static SendPort? uiSendPort;

  GlobeNotificationController(){
    _configureLocalTimeZone();
    // appTitle =  S.of(GlobalNavigator.Key.currentContext!).appTitle;
    // notificationBody = S.of(GlobalNavigator.Key.currentContext!).localNotificationBody;
  }

  Future<void> setNotificationAlarm() async {
    print("setNotificationAlarm()");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var notificationTime = prefs.getStringList(LS_FIELD.NOTIFICATION_TIME);
    var now = DateTime.now();
    var targetDateTime = new DateTime(now.year, now.month, now.day, 12, 00, 00);
    if(notificationTime != null && notificationTime.length == 2){
      targetDateTime = new DateTime(now.year, now.month, now.day, int.parse(notificationTime[0]), int.parse(notificationTime[1]), 00);
      if( targetDateTime.isBefore(now) ){
        targetDateTime = new DateTime(now.year,  now.month, now.day, int.parse(notificationTime[0]), int.parse(notificationTime[1]), 00).add(const Duration(days: 1));
      }
      await AndroidAlarmManager.oneShotAt(targetDateTime,
          alarmId,
          callback,
        exact: true,
          rescheduleOnReboot:true,
        allowWhileIdle: true);

      // await AndroidAlarmManager.oneShot(Duration(seconds: 5),
      //     alarmId,
      //     callback);

      print("setNotificationAlarm() ${targetDateTime} ");

    }else{
      print("notification time is null");
    }
  }

  static Future<void> callback() async {
    print('AndroidAlarmManager callback' + DateTime.now().toString());
    uiSendPort ??= IsolateNameServer.lookupPortByName(isolateName);
    uiSendPort?.send("globe call");
    setNotification();
  }

  static Future<void> setNotification() async {
    print("setNotification()");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    const NotificationDetails notificationDetails = NotificationDetails(android: androidPlatformChannelSpecifics);
    var notificationText = prefs.getStringList(LS_FIELD.NOTIFICATION_TEXT);
    await flutterLocalNotificationsPlugin.periodicallyShow(
        0,
        notificationText![0],
        notificationText[1],
        RepeatInterval.daily,
        notificationDetails,
        payload: 'periodicallyShow :' + DateTime.now().toString(),
        androidAllowWhileIdle: true);

    await flutterLocalNotificationsPlugin.show(1, notificationText[0], notificationText[1], notificationDetails);
  }

  bool isNotificationRegistered(){
    print("isNotificationRegistered()");
    flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    print(flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails().toString());
    return true;
  }

  Future<void> setDefaultNotification() async {
    print("setDefaultNotification()");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(LS_FIELD.NOTIFICATION_TIME, ["16", "20"]);
    prefs.setBool(LS_FIELD.NOTIFICATION_SETTING, true);
    registerScheduledNotification();
  }

  Future<void> registerScheduledNotification() async {
    print("registerScheduledNotification()");
    await setNotificationAlarm();
  }

  Future<void> unregisterScheduledNotification(UnRegisterCallback callback) async {
    print("unregisterScheduledNotification()");
    // final List<PendingNotificationRequest> pendingNotificationRequests = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    // // print("pendingNotificationRequests");
    // // print(pendingNotificationRequests);
    await flutterLocalNotificationsPlugin.cancelAll();
    await AndroidAlarmManager.cancel(alarmId);
    callback();
  }

  Future<void> _configureLocalTimeZone() async {
    print("_configureLocalTimeZone()");
    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));
  }

  Future<void> setNotificationSetting(bool flag) async {
    print("setNotificationSetting(${flag})");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(LS_FIELD.NOTIFICATION_SETTING, flag);
  }

  Future<bool> getNotificationSetting() async {
    print("getNotificationSetting()");
    try{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var notificationSetting = prefs.getBool(LS_FIELD.NOTIFICATION_SETTING);
      if(notificationSetting == null){
        return true;
      }else{
        return notificationSetting;
      }
    }catch(error){
      print(error);
      return true;
    }
  }

  Future<List<String>> getRegisteredNotifications() async {
    final List<PendingNotificationRequest> pendingNotificationRequests = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    print("pendingNotificationRequests:" + pendingNotificationRequests.length.toString());
    if(pendingNotificationRequests.length > 0){
      print(pendingNotificationRequests[0].title);
      print(pendingNotificationRequests[0].body);
      print(pendingNotificationRequests[0].payload);
      print(pendingNotificationRequests[0].id);
    }
    return [];
  }
}