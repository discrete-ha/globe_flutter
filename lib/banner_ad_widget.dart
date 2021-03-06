import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:globe_flutter/const.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdWidget extends StatefulWidget {
  String type;

  BannerAdWidget(this.type);

  final AdSize mainSize = AdSize.largeBanner;
  final AdSize menuSize = AdSize.mediumRectangle;
  final AdSize addCitySize = AdSize.mediumRectangle;

  @override
  State<StatefulWidget> createState() => BannerAdState();
}

class BannerAdState extends State<BannerAdWidget> {
  late BannerAd _bannerAd;
  final Completer<BannerAd> bannerCompleter = Completer<BannerAd>();

  @override
  void initState() {
    super.initState();
    MobileAds.instance.initialize().then((InitializationStatus status) {
      print('Initialization done: ${status.adapterStatuses}');
    });
    var adUnitId = "";
    var adSize;
    switch(widget.type){
      case BannerType.Main:
        adUnitId = SETTING.admobMainBannerUnitId;
        adSize = widget.mainSize;
        break;
      case BannerType.Menu:
        adUnitId = SETTING.admobMenuBannerUnitId;
        adSize = widget.menuSize;
        break;
      case BannerType.AddCity:
        adUnitId = SETTING.admobAddCityBannerUnitId;
        adSize = widget.addCitySize;
        break;
    }
    // adUnitId = "ca-app-pub-3940256099942544/6300978111";

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: AdRequest(),
      size: adSize,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('$BannerAd loaded.');
          bannerCompleter.complete(ad as BannerAd);
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          print("BannerAd ad.adUnitId:"+ad.adUnitId);
          print('$BannerAd failedToLoad: $error');
          bannerCompleter.completeError(error);
        },
        onAdOpened: (Ad ad) => print('$BannerAd onAdOpened.'),
        onAdClosed: (Ad ad) => print('$BannerAd onAdClosed.'),
      ),
    );
    Future<void>.delayed(Duration(seconds: 1), () => _bannerAd.load());
  }

  @override
  void dispose() {
    super.dispose();
    _bannerAd.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BannerAd>(
      future: bannerCompleter.future,
      builder: (BuildContext context, AsyncSnapshot<BannerAd> snapshot) {
        Widget child;

        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
          case ConnectionState.active:
            child = Container();
            break;
          case ConnectionState.done:
            if (snapshot.hasData) {
              child = AdWidget(ad: _bannerAd);
            } else {
              child = Text('Error loading $BannerAd');
            }
        }

        return Container(
          width: _bannerAd.size.width.toDouble(),
          height: _bannerAd.size.height.toDouble(),
          color: Colors.transparent,
          child: child,
        );
      },
    );
  }
}
