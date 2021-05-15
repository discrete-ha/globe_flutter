import 'dart:io';


abstract class SETTING {
  static final String SERVER_URL = "http://ec2-52-196-52-243.ap-northeast-1.compute.amazonaws.com:3000";
  static final String admobUnitIdTest = 'ca-app-pub-3940256099942544/6300978111';
  static final String admobAppId = Platform.isAndroid ? 'ca-app-pub-9623769649834685~7994032794' : 'ca-app-pub-9623769649834685~3207957973';
  static final String admobUnitId = Platform.isAndroid ? 'ca-app-pub-9623769649834685/2550134426' : 'ca-app-pub-9623769649834685/6380916226';
//  static final String admobAppId = Platform.isAndroid ? 'ca-app-pub-3304304215047232~8077017567' : 'ca-app-pub-3304304215047232~8077017567';
//  static final String admobUnitId = Platform.isAndroid ? 'ca-app-pub-9623769649834685/4479136959' : 'ca-app-pub-3304304215047232/5259282534';

//google.com, pub-9623769649834685, DIRECT, f08c47fec0942fa0
//ca-app-pub-9623769649834685/4479136959
}

class VIEW{
  static const int INDEX = 1;
  static const int ADD_CITY = 2;
}


class LS_FIELD{
  static String LAST_UPDATE_TIME = "LAST_UPDATE_TIME";
  static String LOCAL_WOEID = "LOCAL_WOEID";
  static String LOCAL_WOEID_TIME = "LOCAL_WOEID_TIME";
  static String LOCATIONS = "local_storage_location";
}