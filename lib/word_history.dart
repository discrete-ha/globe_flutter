import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:globe_flutter/app_bar.dart';
import 'package:globe_flutter/const.dart';
import 'package:globe_flutter/generated/l10n.dart';
import 'package:globe_flutter/overlay_loader.dart';
import 'package:globe_flutter/overlay_webview.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WordHistory extends StatefulWidget {
  WordHistory({Key? key}) : super(key: key);

  @override
  WordHistoryState createState() {
    return WordHistoryState();
  }
}

class WordHistoryState extends State<WordHistory> {
  List<String> historyWords = [];
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    Future(() async {
      prefs = await SharedPreferences.getInstance();
      setState(() {
        historyWords = prefs.getStringList(LS_FIELD.HISTROY_WORDS) ?? [];
        print(historyWords);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: GlobeAppBar(
            context, S.of(context).history, null, VIEW.HISTORY, () {}),
        body: Stack(
          children: [
            Container(
                color: Colors.white,
                child: new SafeArea(
                  child: ListView.builder(
                    reverse: true,
                    shrinkWrap: true,
                    itemCount: historyWords.length,
                    itemBuilder: (context, index) {
                      final item = historyWords[index];
                      final itemSplit = item.split(",");

                      return Dismissible(
                        key: Key(item),
                        onDismissed: (direction) {
                          Future.delayed(Duration.zero, () async {
                            removeWord(item);
                          });
                          setState(() {
                            historyWords.removeAt(index);
                          });

                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('${itemSplit[0]} ' + S.of(context).deleted)));
                        },
                        background: Container(
                          padding: EdgeInsets.only(right: 20.0),
                          alignment: Alignment.centerRight,
                          color: Colors.blueGrey,
                          child: Text(
                            S.of(context).to_delete,
                            textAlign: TextAlign.right,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        child: ListTile(
                          // leading: Icon(Icons.text_fields_outlined),
                          leading: Icon(Icons.open_in_browser),
                          title: Text('${itemSplit[0]}',
                              style: TextStyle(fontSize: 18.0)),
                          subtitle: Text(
                            "${itemSplit[1]}, ${itemSplit[2]}",
                            style: TextStyle(fontSize: 12.0),
                          ),
                          onTap: () {
                            openBrowser(itemSplit[0], itemSplit[2]);
                          },
                        ),
                      );
                    },
                  ),
                )),
            SafeArea(child: OverlayView()),
          ],
        ));
  }

  openBrowser(String message, String country) async {
    print("openBrowser");
    var searchUrl = Uri.encodeFull(
        "https://www.google.com/search?q=${message}&tbm=nws&source=lnt&tbs=sbd:1");
    if (country == "Korea") {
      searchUrl = Uri.encodeFull(
          "https://search.naver.com/search.naver?sm=top_hty&fbm=1&ie=utf8&query=${message}");
    }
    logAddFolder(message);
    OverlayLoader.loader.showLoader(searchUrl);
  }

  Future logAddFolder(String word) async {
    await FirebaseAnalytics().logEvent(
        name: 'open_browser', parameters: {'word': word, 'view': 'history'});
  }

  void removeWord(String word) {
    historyWords.forEach((historyWordLine) {
      if (historyWordLine == word) {
        historyWords.remove(historyWordLine);
      }
    });
    prefs.setStringList(LS_FIELD.HISTROY_WORDS, historyWords);
  }
}
