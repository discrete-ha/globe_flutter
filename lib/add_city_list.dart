import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemChrome, SystemUiOverlayStyle, rootBundle;
import 'package:globe_flutter/app_drawer.dart';
import 'package:globe_flutter/available_cities.dart';
import 'package:globe_flutter/banner_ad_widget.dart';
import 'package:globe_flutter/const.dart';
import 'package:globe_flutter/main.dart';

import 'app_bar.dart';
import 'city.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef void OnDismiss();

class AddCityList extends StatefulWidget {

  @override
  _AddCityListState createState() => new _AddCityListState();
}

class _AddCityListState extends State<AddCityList> {

  TextEditingController _editingController = new TextEditingController();
  List<City> _availableCities = [];
  List<City> _savedCities = [];
  var items = <City>[];
  List<int> extraWoeid = [];
  List<int> prevExtraWoeid = [];

  @override
  void initState() {
    super.initState();
    (() async {
      await _getSavedLocations();
      _updateAvaliableCities();
      prevExtraWoeid.addAll(extraWoeid);
    })();
  }

  void _updateAvaliableCities() async {

    List<City> cities = [];
    _savedCities.clear();
    _availableCities.clear();

    AvailableCities.instance.cities.forEach((city){
      var isWoeidExist = false;
      extraWoeid.forEach((woeid){
        if(woeid == city['woeid']){
          isWoeidExist = true;
        }
      });


      City newCity = City(city['name'],
          city['parentid'],
          city['country'],
          city['woeid'],
          city['countryCode']);

      if(isWoeidExist == false){
        cities.add(newCity);
      }else{
        _savedCities.add(newCity);
      }
    });

    setState(() {
      _availableCities = cities;
      _updateItemList();
    });
  }

  _updateItemList(){
    items.clear();
    final totalCities = {
      ..._savedCities,
      ..._availableCities,
    };
    items.addAll(totalCities);
  }

  _filterSearchResults(String query) {
    List<City> dummySearchList = <City>[];
    dummySearchList.addAll(_availableCities);

    if(query.isNotEmpty) {
      List<City> dummyListData = <City>[];
      dummySearchList.forEach((item) {
        if(item.contains(query)) {
          dummyListData.add(item);
        }
      });

      setState(() {
        items.clear();
        items.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        _updateItemList();
      });
    }
  }

  _getSavedLocations() async {
    var prefs = await SharedPreferences.getInstance();
    Object? savedLocation = prefs.get(LS_FIELD.LOCATIONS);
    if(savedLocation != null){
      print("locationsString:"+savedLocation.toString());
      var locations = json.decode(savedLocation.toString());
      locations.forEach((location){
        extraWoeid.add(location);
      });
    }
  }

  _removeLocation(City item) async {
    extraWoeid.remove(item.woeid);
    var prefs = await SharedPreferences.getInstance();
    prefs.setString(LS_FIELD.LOCATIONS, jsonEncode(extraWoeid));
    _updateAvaliableCities();
  }

  _addLocation(City item) async {
    var isWoeidExist = false;
    if(extraWoeid.length >= 5){
      print(extraWoeid);
      return;
    }

    extraWoeid.forEach((woeid){
      if(woeid == item.woeid){
        isWoeidExist =true;
      }
    });

    if(isWoeidExist == false){
      extraWoeid.add(item.woeid);
      var prefs = await SharedPreferences.getInstance();
      prefs.setString(LS_FIELD.LOCATIONS, jsonEncode(extraWoeid));
    }
    _editingController.clear();
    _updateAvaliableCities();
    logAddCity(item.name);
  }

  _buildLocationCard(int index){
    var isSaved = extraWoeid.contains(items[index].woeid);
    return InkWell(
      child: Card(
        color: isSaved ? Colors.blue[600] : Colors.white ,
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                items[index].name,
                style: TextStyle(
                  fontSize: 15.0,
                  color: isSaved ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(
                width: 5.0,
              ),
          Flexible(
            fit: FlexFit.loose,
            child:Container(
              alignment: Alignment.bottomLeft,
              height: 18,
              padding: EdgeInsets.all(0),
              child: Text(
                items[index].country,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.0,
                  color:  isSaved ? Colors.grey[400] : Colors.grey,
                ),
              ),
            ),)
            ],
          ),
        ),
      ),
      onTap: () async {
        if(isSaved){
          _removeLocation(items[index]);
        }else{
          _addLocation(items[index]);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarBrightness: Brightness.dark)
    );

    var title =  extraWoeid.length == 0 ? "" : extraWoeid.length.toString() + "/5";

    return Container(
      color: Colors.white,
      child: new SafeArea(
        child: Scaffold(
            // drawer: AppDrawer(),
            appBar: GlobeAppBar(context, title, null, initRun ? VIEW.INIT_VIEW : VIEW.ADD_CITY, (){}),
            body: Container(
              child: Column(
                children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: new Container(
                        height: 45.0,
                        child:TextField(
                          onChanged: (value) {
                            _filterSearchResults(value);
                          },
                          controller: _editingController,
                          decoration: InputDecoration(
                              labelText: "Search",
                              hintText: "City",
                              contentPadding: new EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
                              prefixIcon: Icon(Icons.search),
                              border: UnderlineInputBorder()
                          ),
                        ),
                      )
                  ),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return _buildLocationCard(index);
                      },
                    ),
                  ),
                  BannerAdWidget(BannerType.AddCity)
                ],
              ),
            )
          )
        )
    );
  }
}

Future logAddCity(String city) async {
  await FirebaseAnalytics().logEvent(name: 'add_city', parameters: {'city': city});
}