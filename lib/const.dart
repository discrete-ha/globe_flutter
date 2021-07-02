// import 'dart:io';


abstract class SETTING {
  static final String SERVER_URL = "http://ec2-52-196-52-243.ap-northeast-1.compute.amazonaws.com:3000";
  // static final String SERVER_URL = "http://localhost:3000";
  static final String admobUnitIdTest = 'ca-app-pub-3940256099942544/6300978111';
  static final String admobAppId = 'ca-app-pub-9623769649834685~7994032794';
  static final String admobMainBannerUnitId = 'ca-app-pub-9623769649834685/2550134426';
  static final String admobMenuBannerUnitId = 'ca-app-pub-9623769649834685/3177277503';
  static final String admobAddCityBannerUnitId = 'ca-app-pub-9623769649834685/5441312915';

}
class BannerType{
  static const String Main = "main";
  static const String Menu = "menu";
  static const String AddCity = "add_city";
}

class VIEW{
  static const int INDEX = 1;
  static const int ADD_CITY = 2;
  static const int SEND_MAIL = 3;
  static const int HISTORY = 4;
  static const int INIT_VIEW = 5;
}

class LS_FIELD{
  static String LAST_UPDATE_TIME = "LAST_UPDATE_TIME";
  static String LOCAL_WOEID = "LOCAL_WOEID";
  static String LOCAL_WOEID_TIME = "LOCAL_WOEID_TIME";
  static String LOCATIONS = "local_storage_location";
  static String NOTIFICATION_SETTING = "notification_setting";
  static String NOTIFICATION_TIME = "notification_time";
  static String HISTROY_WORDS = "history_words";
  static String INITIALIZED = "initialized";
  static String NOTIFICATION_TEXT = "notification_text";
}

class ERROR_MESSEGE{
  static const String SERVER_NOT_RESPONSE =  "Server temporarily unavailable";
}

class DIALOG_TEXT{
  static const String ERROR =  "Error";
  static const String RELOAD =  "Reload";
}

