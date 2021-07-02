import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:globe_flutter/add_city_list.dart';
import 'package:globe_flutter/const.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddCityDrawer extends StatefulWidget {
  Function callback;

  AddCityDrawer({required this.callback, key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AddCityDrawerState();
}

class AddCityDrawerState extends State<AddCityDrawer> {
  late Function? callbackFuntion;
  List<int> previousWoeids = [];

  @override
  void initState() {
    super.initState();
    callbackFuntion = widget.callback;
    Future.delayed(Duration.zero, () async {
      previousWoeids = await _getSavedLoaction();
      adFBLog();
    });
  }

  Future<List<int>> _getSavedLoaction() async {
    List<int> locationWoeids = [];
    var prefs = await SharedPreferences.getInstance();
    Object? savedLocation = prefs.get(LS_FIELD.LOCATIONS);
    if(savedLocation != null){
      print("locationsString:"+savedLocation.toString());
      var locations = json.decode(savedLocation.toString());
      locations.forEach((location){
        locationWoeids.add(location);
      });
    }
    return locationWoeids;
  }
  @override
  Future<void> dispose() async {
    super.dispose();
    print("dispose");

    List<int> newLocationWoeids = await _getSavedLoaction();

    newLocationWoeids.sort((a, b) => a - b);
    previousWoeids.sort((a, b) => a - b);
    if( !listEquals(newLocationWoeids, previousWoeids) ){
      Future.delayed(Duration.zero, () async {
        callbackFuntion!();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: AddCityList(),
    );
  }


  Future adFBLog() async {
    await FirebaseAnalytics().logEvent(name: 'open_add_city');
  }
}
