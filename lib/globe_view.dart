import 'dart:async';
import 'dart:convert';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:globe_flutter/add_city_drawer.dart';
import 'package:globe_flutter/app_drawer.dart';
import 'package:globe_flutter/banner_ad_widget.dart';
import 'package:globe_flutter/custom_dialog.dart';
import 'package:globe_flutter/generated/l10n.dart';
import 'package:globe_flutter/global_navigator.dart';
import 'package:globe_flutter/loading_indicator.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:globe_flutter/const.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

import 'app_bar.dart';
import 'swiper_cards.dart';
import 'logo_view.dart';

class GlobeView extends StatefulWidget {
  @override
  _GlobeViewState createState() => _GlobeViewState();
}

class _GlobeViewState extends State<GlobeView> with WidgetsBindingObserver {
  var _updateLimitSeconds = 180;
  var _updateWoeidLimitSeconds = 1800;
  var viewId = 0;
  bool _isFetching = true;
  List<Map<String, dynamic>> issues = [];
  String appbarTitle = "";
  String? appbarSubTitle;
  String currentCityName = "";
  String? currentCountryName;
  List<int> extraWoeid = [];
  int totalFetchCount = 0;

  late DateTime _lastUpdateTime;
  late String jsonStringConfig;
  late SwiperCards swiperCards;
  late Stack overlayLayout;

  @override
  void initState() {
    super.initState();
    print("initState()");
    (() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setStringList(LS_FIELD.NOTIFICATION_TEXT, [
        S.of(context).appTitle,
        S.of(context).localNotificationBody
      ]);
      jsonStringConfig = await _loadConfig();
      loadData();
    })();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool _checkCacheTime() {
    if (_lastUpdateTime != null) {
      final date = DateTime.now();
      final difference = date.difference(_lastUpdateTime).inSeconds;
      if (difference > _updateLimitSeconds) {
        return true;
      }
      return false;
    } else {
      return false;
    }
  }

  _getSavedLocations() async {
    print("_getSavedLocations");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    extraWoeid.clear();
    String? locationsString = prefs.getString(LS_FIELD.LOCATIONS);
    print('locationsString:' + locationsString.toString());
    if (locationsString != null) {
      var locations = json.decode(locationsString.toString());
      locations.forEach((location) {
        extraWoeid.add(location);
      });
    }
  }

  _saveUpdateTime() async {
    _lastUpdateTime = DateTime.now();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(LS_FIELD.LAST_UPDATE_TIME, DateTime.now().toString());
  }

  _getLocalWoeid() async {
    print("_getLocalWoeid()");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var updateTime = prefs.get(LS_FIELD.LOCAL_WOEID_TIME);
    print(updateTime);
    if (updateTime != null) {
      var now = DateTime.now();
      final difference =
          now.difference(DateTime.parse(updateTime.toString())).inSeconds;
      if (difference < _updateWoeidLimitSeconds) {
        return prefs.getString(LS_FIELD.LOCAL_WOEID);
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  _setLocalWoeid(woeid) async {
    print("_setWoeid:" + woeid);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var updateTime = prefs.getString(LS_FIELD.LOCAL_WOEID_TIME);
    var now = DateTime.now();
    if (updateTime != null) {
      final difference = now.difference(DateTime.parse(updateTime)).inSeconds;
      if (difference >= _updateWoeidLimitSeconds) {
        prefs.setString(LS_FIELD.LOCAL_WOEID, woeid);
        prefs.setString(LS_FIELD.LOCAL_WOEID_TIME, now.toString());
      }
    } else {
      prefs.setString(LS_FIELD.LOCAL_WOEID, woeid);
      prefs.setString(LS_FIELD.LOCAL_WOEID_TIME, now.toString());
    }
  }

  Future loadData() async {
    print("loadData()");
    // this._isFetching = true;
    await _getSavedLocations();
    _fetchIssue();
  }

  @override
  Future didChangeAppLifecycleState(AppLifecycleState state) async {
    print("didChangeAppLifecycleState");
    switch (state) {
      case AppLifecycleState.resumed:
        if (_checkCacheTime()) {
          loadData();
        }
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<String> _loadConfig() async {
    return await rootBundle.loadString('assets/config.json');
  }

  @override
  Widget build(BuildContext context) {
    print("_MainViewState build()");
    var contentBody = !this._isFetching && this.issues.length > 0
        ? swiperCards
        : LoadingIndicator();

    return Scaffold(
        resizeToAvoidBottomInset: false,
        drawer: AppDrawer(),
        endDrawer: AddCityDrawer(callback: forceLoad),
        appBar: GlobeAppBar(context, this.appbarTitle, this.appbarSubTitle , VIEW.INDEX, forceLoad ),
        body: Builder(builder: (BuildContext context) {
          return Center(
            child: Container(
                color: Colors.blueGrey.shade300,
                // color: Colors.grey.shade500,
                child: Stack(
                  children: <Widget>[
                    new Padding(
                        padding: EdgeInsets.only(bottom: 100), child: contentBody),
                    new Positioned(
                      child: new Align(
                          alignment: FractionalOffset.bottomCenter,
                          child: new LogoView()),
                    ),
                    new Positioned(
                      child: new Align(
                          alignment: FractionalOffset.bottomCenter,
                          child: kIsWeb ? Container() : BannerAdWidget(BannerType.Main)),
                    )
                  ],
                )),
          );
        }));
  }

  void forceLoad() {
    print("forceLoad");
    _loadDataBackground();
  }

  _loadDataBackground() {
    print("_loadDataBackground");
    setState(() {
      this._isFetching = true;
    });
    loadData();
  }

  void onTitlePageChanged(String title, String? subTitle) {
    print("onTitlePageChanged:" + title);
    setState(() {
      if(this.currentCityName == title && this.currentCountryName == subTitle){
        this.appbarTitle = "Your location";
        if(subTitle == null){
          this.appbarSubTitle = title;
        }else{
          this.appbarSubTitle = title + "," + subTitle;
        }
      }else{
        this.appbarTitle = title;
        this.appbarSubTitle = subTitle;
      }
    });

    addFBLog();
  }

  Future<LocationData?> _getLocation() async {
    var location = new Location();
    try {
      return await location.getLocation();
    } catch (e) {
      return null;
    }
  }

  _parseIssue(String responseBody, bool isMain) {
    // print("_parseIssue" + responseBody);
    try {
      final parsed = json.decode(responseBody);
      if (isMain) {
        this.appbarTitle = "Your location";
        if(parsed["country"] == null ){
          this.appbarSubTitle = parsed["location"];
        }else{
          this.appbarSubTitle = parsed["location"] + "," + parsed["country"];
        }

        this.currentCityName = parsed["location"];
        this.currentCountryName = parsed["country"];
      }

      setState(() {
        if (this.totalFetchCount == (this.issues.length + 1)) {
          this._isFetching = false;
          this.swiperCards = new SwiperCards(this.issues, this.onTitlePageChanged);
        }
        this.issues.add(parsed);
      });
    } catch (e) {
      print(e.toString());
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomDialog(
              title: DIALOG_TEXT.ERROR,
              descriptions: ERROR_MESSEGE.SERVER_NOT_RESPONSE,
              text: DIALOG_TEXT.RELOAD,
            );
          });
    }
  }

  Future<Map<String, dynamic>?> _fetchIssue() async {
    print("_fetchIssue");
    try {
      var client = http.Client();
      this.issues.clear();
      _saveUpdateTime();
      totalFetchCount = 1 + extraWoeid.length;

      final CONFIG = json.decode(jsonStringConfig);
      var API_APPID = CONFIG['API_APPID'];
      var response;
      var woeid = await _getLocalWoeid();
      print("saved woeid:" + woeid.toString());

      SharedPreferences prefs = await SharedPreferences.getInstance();
      var updateTime = prefs.getString(LS_FIELD.LOCAL_WOEID_TIME);
      var now = DateTime.now();
      if (updateTime != null) {
        final difference = now.difference(DateTime.parse(updateTime)).inSeconds;
        if (difference >= _updateWoeidLimitSeconds) {
          woeid = null;
        }
      } else {
        woeid = null;
      }

      if (woeid == null) {
        LocationData? userLocation = (await _getLocation());
        print("userLocation:" + userLocation.toString());
        if (userLocation == null) {
          print(1);
          woeid = "1";
          response = await client.get(Uri.parse('${SETTING.SERVER_URL}/topics/$API_APPID/$woeid'));
          print(response);
        } else {
          //current location
          var lat = userLocation.latitude.toString();
          var lon = userLocation.longitude.toString();
          print("lat:" + lat.toString());
          print("lon:" + lon.toString());
          response = await client.get(Uri.parse('${SETTING.SERVER_URL}/topics/$API_APPID/$lat/$lon'));
          var parsedResponse = json.decode(response.body);
          _setLocalWoeid(parsedResponse["woeid"]);
        }

      } else {
        response = await client.get(Uri.parse('${SETTING.SERVER_URL}/topics/$API_APPID/$woeid'));
      }

      _parseIssue(response.body, true);

      extraWoeid.forEach((woeid) async {
        print("request ${woeid}");
        response = await client
            .get(Uri.parse('${SETTING.SERVER_URL}/topics/$API_APPID/$woeid'));
        _parseIssue(response.body, false);
      });
    } catch (error) {
      print("_fetchIssue() error:" + error.toString());
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomDialog(
              title: DIALOG_TEXT.ERROR,
              descriptions: ERROR_MESSEGE.SERVER_NOT_RESPONSE,
              text: DIALOG_TEXT.RELOAD,
            );
          }).then((val) {
        _loadDataBackground();
      });
    }
  }

  Future<void> addFBLog() async {
    await FirebaseAnalytics().logEvent(name: 'change_card');
  }
}
