import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scatter/flutter_scatter.dart';
import 'package:globe_flutter/overlay_loader.dart';
import 'dart:convert' show utf8;
import 'issue.dart';

class WordColud extends StatelessWidget {
  final List<Issue> words;
  List<Widget> widgets = <Widget>[];
  String countryCode;
  final double ratio;

  WordColud(this.words, this.countryCode, this.ratio);

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

      widgets.add( CloudItem(words[i].word, color, fontSize.toDouble(), this.countryCode ));
    }

    return Scatter(
        fillGaps: false,
        delegate: ArchimedeanSpiralScatterDelegate(ratio: -(ratio), step: 0.02, rotation: 1),
      children:widgets
    );
  }
}

class CloudItem extends StatelessWidget {
  CloudItem(this.word, this.color, this.fontSize, this.countryCode);
  String word, countryCode;
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
        // padding: EdgeInsets.symmetric(vertical: 20, horizontal: 5.0),

        style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 5.0),
            ),
        child: Text(
            wordDisplay,
            style: style,
            textAlign: TextAlign.center
        ),
        onPressed: () => openBrowser(word, countryCode),
    );
  }
}

openBrowser(String message, String countryCode) async {
  print("openBrowser");
  var searchUrl = Uri.encodeFull("https://www.google.com/search?q=${message}&tbm=nws&source=lnt&tbs=sbd:1");
  if(countryCode == "KR"){
    searchUrl = Uri.encodeFull("https://search.naver.com/search.naver?sm=top_hty&fbm=1&ie=utf8&query=${message}");
  }

  OverlayLoader.loader.showLoader(searchUrl);
}



