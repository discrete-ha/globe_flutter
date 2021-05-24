import 'dart:convert';

import 'package:flutter/services.dart';

class AvailableCities {
  static final AvailableCities _singleton = AvailableCities._internal();
  factory AvailableCities() => _singleton;
  AvailableCities._internal();
  static AvailableCities get instance => _singleton;
  List<dynamic> cities = [] ;

  loadFile() async {
    var rawJson = _loadAvailable();
    cities = json.decode(await rawJson);
  }

  static Future<String> _loadAvailable() async {
    return await rootBundle.loadString('assets/available.json');
  }
}
