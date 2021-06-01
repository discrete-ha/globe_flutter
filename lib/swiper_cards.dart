import 'dart:convert';
import 'dart:math';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swipper/flutter_card_swiper.dart';
import 'package:globe_flutter/word_cloud_list.dart';
import 'package:flutter/cupertino.dart';

typedef void OnTitlePageChanged(String title, String subTitle);

class SwiperCards extends StatelessWidget{
  List<Map<String,dynamic>> issues;
  final String LAST_UPDATE_TIME = "LAST_UPDATE_TIME";
  final String LOCAL_WOEID = "LOCAL_WOEID";
  final String LOCAL_WOEID_TIME = "LOCAL_WOEID_TIME";
  String cityName = "";
  final OnTitlePageChanged onTitlePageChanged;

  SwiperCards(this.issues, this.onTitlePageChanged);

  String _getCity(int index){
    var city = this.issues[index]['location'];
    return city;
  }

  String _getCountry(int index){
    var country = this.issues[index]['country'] == "Worldwide" ? null : this.issues[index]['country'];
    return country;
  }

  @override
  Widget build(BuildContext context) {
    print("LocationCards build()");
    var size = MediaQuery.of(context).size;

    var cardWidth = (size.width * 0.87);
    var cardHeight = size.height;
    var wordCloudRatio = (cardHeight/cardWidth).toDouble();
    var offsetVertical = cardWidth * sin(7.3 * pi/180) - 10;
    var offsetSide = cardWidth * sin(82.7 * pi/180) + offsetVertical;
    var startIndex = -1;

    return new Swiper(
      layout: SwiperLayout.CUSTOM,
      customLayoutOption: new CustomLayoutOption(
          startIndex: startIndex,
          stateCount: 3
      ).addRotate([
        -25.0/180,
        0.0,
        25.0/180
      ]).addTranslate([
        new Offset(-offsetSide, -offsetVertical),
        new Offset(0, 0.0),
        new Offset(offsetSide, -offsetVertical)
      ]),
      itemWidth: cardWidth,
      itemHeight: cardHeight,
      onIndexChanged: (int index) {
        var city = _getCity(index);
        var country = _getCountry(index);
        this.onTitlePageChanged(city, country);
        logChangeCity(city+","+country);
      },
      itemBuilder: ( context, index ) {
        return Padding(
            padding: EdgeInsets.fromLTRB(5.0,5.0,5.0,15.0),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(40.0),
                child: WordCloudList(
                    issue: this.issues[index],
                    ratio: wordCloudRatio
                )
            )
        );
      },
      pagination: new SwiperPagination(
        builder: new DotSwiperPaginationBuilder(
            color: Colors.grey[200],
            activeColor: Colors.blue.shade200
        ),
        margin: const EdgeInsets.only(bottom:0.0),
      ),
      control: new SwiperControl(
        color:Colors.grey[300],
        padding:EdgeInsets.only(left: 6, right:0),
      ),
      itemCount: this.issues.length
    );
  }
}

Future logChangeCity(String city) async {
  await FirebaseAnalytics().logEvent(name: 'change_city', parameters: {'city': city});
}