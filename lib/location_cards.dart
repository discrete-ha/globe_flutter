import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_card_swipper/flutter_card_swiper.dart';
import 'package:globe_flutter/issue_list.dart';
import 'package:flutter/cupertino.dart';

typedef void OnTitlePageChanged(String title);

class LocationCards extends StatelessWidget{
  List<Map<String,dynamic>> issues;
  final String LAST_UPDATE_TIME = "LAST_UPDATE_TIME";
  final String LOCAL_WOEID = "LOCAL_WOEID";
  final String LOCAL_WOEID_TIME = "LOCAL_WOEID_TIME";
  String cityName = "";
  final OnTitlePageChanged onTitlePageChanged;

  LocationCards(this.issues, this.onTitlePageChanged);

  String _getTitle(int index){
    var city = this.issues[index]['location'];
    var country = this.issues[index]['country'];
    return city == "Worldwide" ? city : city  + ", " +country;
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
        this.onTitlePageChanged(_getTitle(index));
      },
      itemBuilder: ( context, index ) {
        return Padding(
            padding: EdgeInsets.fromLTRB(5.0,5.0,5.0,15.0),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(40.0),
                child: IssueList(
                    issue: this.issues[index],
                    ratio: wordCloudRatio
                )
            )
        );
      },
      pagination: new SwiperPagination(
        builder: new DotSwiperPaginationBuilder(
            color: Colors.grey[300],
            activeColor: Color.fromRGBO(80, 180, 255, 100)
        ),
        margin: const EdgeInsets.only(bottom:0.0),
      ),
      control: new SwiperControl(
        color:Colors.grey[300],
        padding:EdgeInsets.all(0),
      ),
      itemCount: this.issues.length

    // itemBuilder: (BuildContext context,int index){
    //   return new Image.network("http://via.placeholder.com/350x150",fit: BoxFit.fill,);
    // },
    // itemCount: 3,
    // pagination: new SwiperPagination(),
    // control: new SwiperControl(),
    );
  }
}


