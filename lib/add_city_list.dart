import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemChrome, SystemUiOverlayStyle, rootBundle;
import 'package:globe_flutter/setting.dart';

import 'app_bar.dart';
import 'city.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef void OnDismiss();

class AddCityList extends StatefulWidget {

  OnDismiss onDismiss;

  AddCityList({required this.onDismiss, key}) : super(key: key);

  @override
  _AddCityListState createState() => new _AddCityListState();
}

Future<String> _loadAvailable() async {
  return await rootBundle.loadString('assets/available.json');
}

class _AddCityListState extends State<AddCityList> {

  TextEditingController _editingController = new TextEditingController();
  List<City> _availableCities = [];
  List<City> _savedCities = [];
  var items = <City>[];
  List<int> extraWoeid = [];
  List<int> prevExtraWoeid = [];
  late OnDismiss? callbackFuntion;

  @override
  void initState() {
    super.initState();
    callbackFuntion = null;
    (() async {
      await _getSavedLocations();
      _updateAvaliableCities();
      prevExtraWoeid.addAll(extraWoeid);
    })();
  }

  void _updateAvaliableCities() async {

    final rawCities = json.decode(await _loadAvailable());
    List<City> cities = [];
    _savedCities.clear();
    _availableCities.clear();

    rawCities.forEach((city){
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
//      Navigator.of(context).pop();
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
//    Navigator.of(context).pop();
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
                  fontSize: 16.0,
                  color: isSaved ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(
                width: 5.0,
              ),
              Text(
                items[index].country,
                style: TextStyle(
                  fontSize: 14.0,
                  color:  isSaved ? Colors.grey[400] : Colors.grey,
                ),
              ),
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

        var tempExtraWoeid = [];
        tempExtraWoeid.addAll(extraWoeid);
        tempExtraWoeid.sort((a, b) => a - b);
        prevExtraWoeid.sort((a, b) => a - b);
        if( listEquals(tempExtraWoeid, prevExtraWoeid) ){

        }else{
          callbackFuntion = widget.onDismiss;
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

    return WillPopScope(
      onWillPop: () async {
        bool shouldPop = true;
        callbackFuntion!();
        Navigator.of(context).pop();
        return shouldPop;
      },
      child: Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.topRight,
              colors: [Colors.pink.shade300, Colors.blue])),
      child: new SafeArea(
        child: Scaffold(
            appBar: getAppBar(context, this.widget, title, VIEW.ADD_CITY, callbackFuntion),
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
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(3.0))
                              )
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
                ],
              ),
            )
          )
        )
      )
    );
  }
}
