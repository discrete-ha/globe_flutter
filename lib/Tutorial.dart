// import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:globe_flutter/main.dart';
import 'package:globe_flutter/overlay_loader.dart';
import 'package:globe_flutter/webview_listnerabl_values.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Tutorial extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    print("OverlayView:build()");
        if (initRun) {
          return new Stack(
            children: <Widget>[
              Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      OverlayLoader.loader.hideLoader();
                    },
                    child: Container(
                      padding: EdgeInsets.all(0),
                      alignment: Alignment.bottomCenter,
                      decoration: BoxDecoration(color: Colors.black45),
                    ),
                  )),
              Container()
            ],
          );
        } else {
          return Container();
        }
  }
}
