import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:globe_flutter/banner_ad_widget.dart';
import 'package:globe_flutter/const.dart';
import 'package:globe_flutter/generated/l10n.dart';
import 'package:globe_flutter/globa_data.dart';
import 'package:globe_flutter/global_navigator.dart';
import 'package:globe_flutter/globe_notification_controller.dart';
import 'package:globe_flutter/mail_sender.dart';
import 'package:globe_flutter/view_router.dart';
import 'package:globe_flutter/word_history.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';

TimeOfDay _time = TimeOfDay(hour: 12, minute: 00);

class AppDrawer extends StatefulWidget {
  AppDrawer(){
    Future.delayed(Duration.zero, () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var notificationTime = prefs.getStringList(LS_FIELD.NOTIFICATION_TIME);
      if(notificationTime != null){
        _time = TimeOfDay(hour: int.parse(notificationTime[0]), minute: int.parse(notificationTime[1]));
      }
    });
  }

  @override
  State<StatefulWidget> createState() => AppDrawerState();
}

class AppDrawerState extends State<AppDrawer> {
  GlobeNotificationController globeNotificationController = GlobeNotificationController();

  Future<bool> getNotificationSettingFromLocal() async {
    print("getNotificationSettingFromLocal()");
    var isNotificationSet = await globeNotificationController.getNotificationSetting();
    return isNotificationSet;
  }

  void _selectTime() async {
    print("_selectTime()");
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (newTime != null) {

      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _time = newTime;
        prefs.setStringList(LS_FIELD.NOTIFICATION_TIME,[newTime.hour.toString(), newTime.minute.toString()] );
        var savedTime = prefs.getStringList(LS_FIELD.NOTIFICATION_TIME);
        // print("savedTime");
        // print(savedTime);
        // globeNotificationController.setNotificationSetting(true);
        globeNotificationController.unregisterScheduledNotification((){
          globeNotificationController.registerScheduledNotification();
          globeNotificationController.setNotificationSetting(true);
        });

        addFBLog("reminder_time", savedTime.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(dividerColor: Colors.transparent);
    var drawerContents = [
      DrawerHeader(
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
          decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage('assets/world_map.webp'))),
          child: Stack(children: <Widget>[
            Positioned(
                bottom: 20.0,
                left: 16.0,
                child: Text("GLOBE",
                    style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 25.0,
                        fontWeight: FontWeight.w500))),
            Positioned(
                bottom: 10.0,
                left: 18.0,
                child: Text("Realtime news in a nutshell",
                    style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 10.0,
                        fontWeight: FontWeight.w500))),
          ])),
      kIsWeb ? Container():
      FutureBuilder(
          future: getNotificationSettingFromLocal(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            bool isNotificationON = true;
            if (snapshot.hasData) {
              isNotificationON = snapshot.data;
            }

            return Theme(child: ExpansionTile(
              leading: isNotificationON ?
              Icon(Icons.notifications_active_outlined, color: Colors.blue) :
              Icon(Icons.notifications_off),
              title: Text(
                S.of(context).reminder,
              ),
              children: <Widget>[
                new Container (
                  decoration: new BoxDecoration (
                      color: Colors.grey.shade100
                  ),
                  child: ListTile(
                      leading: Container(
                          width: 60,
                          child: isNotificationON
                              ? new Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(S.of(context).on),
                                Icon(Icons.toggle_on_outlined, color: Colors.blue)
                              ])
                              : new Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(S.of(context).off),
                                Icon(Icons.toggle_off)
                              ])),
                      onTap: () {
                        // _selectTime();
                        setState(() {
                          if (isNotificationON) {
                            globeNotificationController.unregisterScheduledNotification((){
                              globeNotificationController.setNotificationSetting(false);
                            });
                            addFBLog("reminder_setting", "off");
                          } else {
                            globeNotificationController.registerScheduledNotification();
                            globeNotificationController.setNotificationSetting(true);
                            addFBLog("reminder_setting", "on");
                          }
                        });
                      }),
                ),
                Divider(height : 1),
                new Container (
                    decoration: new BoxDecoration (
                        color: Colors.grey.shade100
                    ),
                    child: isNotificationON ? ListTile(
                      title: Text(_time.format(context)),
                      onTap: (){
                        _selectTime();
                      },
                    ):Container()
                )
              ],
            ),
              data:theme,
            );
          }),
      ListTile(
          title: Text(S.of(context).history),
          leading: Icon(Icons.list_alt),
          onTap: (){
            // Navigator.of(context).pop();
            Navigator.of(context).push(ViewRouter(WordHistory()));
            addFBLog("history", null);
          }),
      kIsWeb ? ListTile(
          title: Text(S.of(context).download_android),
          leading: Icon(Icons.android_rounded),
          onTap: () => launch('https://play.google.com/store/apps/details?id=com.airflare.globe_app')) :
      ListTile(
          title: Text(S.of(context).contact),
          leading: Icon(Icons.contact_mail_outlined),
          onTap: (){
            // Navigator.of(context).pop();
            Navigator.of(context).push(ViewRouter(MailSender()));
            addFBLog("contact_us", null);
          }),
      kIsWeb ? Container():
      Expanded(
        child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 15, bottom: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BannerAdWidget(BannerType.Menu),
                    Text(
                      "Version ${GlobalData.VERSION} - ${GlobalData.BUILD_NUMBER}",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                )
                //
            )),
      )
    ];
    return Drawer(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: drawerContents));
  }

  Future<void> addFBLog(String category, String? value) async {
    await FirebaseAnalytics().logEvent(name: 'memu', parameters: {'category': category, 'value':value});
  }
}
