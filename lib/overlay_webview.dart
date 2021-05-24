// import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:globe_flutter/overlay_loader.dart';
import 'package:globe_flutter/webview_listnerabl_values.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OverlayView extends StatelessWidget {
  const OverlayView({
    key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("OverlayView:build()");
    var _controller;

    return ValueListenableBuilder<WebviewListnerablValues>(
        valueListenable: OverlayLoader.loader.loaderWebviewValueNotifier,
        builder: (context, value, child) {
          if (value.showing) {
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
                Container(
                    // padding: EdgeInsets.all(10),
                    child: Padding(
                  padding: EdgeInsets.only(
                      left: 50, right: 50, bottom: 100, top: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(
                      const Radius.circular(15.0),
                    ),
                    child: WebView(
                      initialUrl: value.url,
                      javascriptMode: JavascriptMode.unrestricted,
                      onWebViewCreated: (WebViewController webViewController) {
                        _controller = webViewController;
                        webViewController.canGoBack();
                      },
                    ),
                  ),
                )),
                Container(
                  alignment: Alignment.bottomCenter,
                  padding: EdgeInsets.only(bottom: 25),
                  child: ClipOval(
                    child: Material(
                        child: IconButton(
                      color: Colors.grey[700],
                      icon: new Icon(Icons.arrow_back, size: 25.0),
                      onPressed: () async {
                        if (await _controller.canGoBack() ) {
                          _controller.goBack();
                        } else {
                          OverlayLoader.loader.hideLoader();
                        }
                      },
                    )),
                  ),
                )
              ],
            );
          } else {
            return Container();
          }
        });
  }
}
