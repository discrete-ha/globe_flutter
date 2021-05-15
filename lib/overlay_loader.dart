import 'package:flutter/material.dart';
import 'package:globe_flutter/webview_listnerabl_values.dart';

class OverlayLoader {
  static final OverlayLoader loader = OverlayLoader();
  late ValueNotifier<WebviewListnerablValues> loaderWebviewValueNotifier = ValueNotifier(new WebviewListnerablValues(false, ""));

  void showLoader(String url) {
    print("OverlayLoader:showLoader()");
    loaderWebviewValueNotifier.value = new WebviewListnerablValues(true, url);
  }

  void hideLoader() {
    print("OverlayLoader:hideLoader()");
    loaderWebviewValueNotifier.value = new WebviewListnerablValues(false, "");
  }
}