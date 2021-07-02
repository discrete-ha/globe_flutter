import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scatter/flutter_scatter.dart';
import 'package:globe_flutter/const.dart';
import 'package:globe_flutter/overlay_loader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert' show utf8;
import 'issue.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class WordColud extends StatelessWidget {
  final List<Issue> words;
  List<Widget> widgets = <Widget>[];
  final double ratio;
  String countryCode, cityName, countryName;

  WordColud(this.words, this.countryCode, this.ratio, this.cityName, this.countryName);

  @override
  Widget build(BuildContext context) {
//    print("countryCode ${countryCode}");
    var length =  words.length > 30 ? 30 : words.length;

    var colorBottom = [80, 180, 255];
    var colorTop = [237, 20, 111];

    var diffR = colorBottom[0] - colorTop[0];
    var diffG = colorBottom[1] - colorTop[1];
    var diffB = colorBottom[2] - colorTop[2];

    for (var i = 0; i < length; i++) {
      var wordSize = words[i].size;
      var fontSize =  ( wordSize + ( 70 - i ) ).toInt();
      var ratio = (length - i ) / length;
      var color = Color.fromRGBO(
          (colorBottom[0] - ( diffR * ratio ) ).toInt() ,
          (colorBottom[1] - ( diffG * ratio ) ).toInt(),
          (colorBottom[2] - ( diffB * ratio ) ).toInt(), 1 );
      widgets.add( CloudItem(words[i].word, color, fontSize.toDouble(), this.countryCode, this.cityName, this.countryName ));
    }

    return Scatter(
        fillGaps: false,
        delegate: ArchimedeanSpiralScatterDelegate(ratio: -(ratio), step: 0.02, rotation: 1),
      children:widgets
    );
  }
}

class CloudItem extends StatelessWidget {
  CloudItem(this.word, this.color, this.fontSize, this.countryCode, this.cityName, this.countryName);
  String word, countryCode, cityName, countryName;
  final Color color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {

    final TextStyle style = Theme.of(context).textTheme.bodyText2!.copyWith(
      fontSize: fontSize ,
      color: color
    );
    var encoded = utf8.encode(word);
    var wordDisplay= word;
    if(encoded.length > 30){
      wordDisplay = word.substring(0, 9) + "...";
    }

    return TextButton(
        style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 5.0),
            ),
        child: Text(
            wordDisplay,
            style: style,
            textAlign: TextAlign.center
        ),
        onPressed: () {
          openBrowser(word, countryCode);
          addHistory(word, cityName, countryName);
        }
    );
  }

  Future<void> addHistory(String word, String cityName, String countryName) async {
    print("addHistory()");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> historyWords = prefs.getStringList(LS_FIELD.HISTROY_WORDS) ?? [];
    print(historyWords);
    var addLine = "${word},${cityName},${countryName}";
    historyWords.forEach(( historyWordLine) {
      if(historyWordLine == addLine){
        historyWords.remove(historyWordLine);
      }
    });
    if(historyWords.length >= 200){
      historyWords.removeLast();
    }
    historyWords.add(addLine);
    prefs.setStringList(LS_FIELD.HISTROY_WORDS, historyWords);
  }

  openBrowser(String message, String countryCode) async {
    print("openBrowser");
    var searchUrl = Uri.encodeFull("https://www.google.com/search?q=${message}&tbm=nws&source=lnt&tbs=sbd:1");
    if(countryCode == "KR"){
      searchUrl = Uri.encodeFull("https://search.naver.com/search.naver?sm=top_hty&fbm=1&ie=utf8&query=${message}");
    }
    logAddFolder(message);
    if(kIsWeb){
      await canLaunch(searchUrl) ? await launch(searchUrl) : throw 'Could not launch $searchUrl';
    }else{
      OverlayLoader.loader.showLoader(searchUrl);
    }
  }

  Future logAddFolder(String word) async {
    await FirebaseAnalytics().logEvent(name: 'open_browser', parameters: {'word': word, 'view':'word cloud'});
  }
}




