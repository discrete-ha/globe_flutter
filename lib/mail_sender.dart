import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:globe_flutter/app_bar.dart';
import 'package:globe_flutter/const.dart';
import 'package:globe_flutter/generated/l10n.dart';
import 'package:globe_flutter/rich_text_field.dart';

class MailSender extends StatelessWidget {

  final titleTextController = TextEditingController();
  final bodyTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:
            GlobeAppBar(context, S.of(context).contact, null ,VIEW.SEND_MAIL, () {}),
        body: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Padding(
                //     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                //     child: RichTextField(
                //         () {}, S.of(context).from, S.of(context).enter_email, titleTextController)),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    child: RichTextField(
                        () {}, S.of(context).title, S.of(context).enter_title, titleTextController)),
                Flexible(
                    child: Container(
                    padding: EdgeInsets.all(15),
                    height: 400,
                    width: double.infinity,
                    child: TextField(
                      controller: bodyTextController,
                      maxLines: 99,
                      decoration: InputDecoration(
                        hintText: S.of(context).enter_message,
                        enabledBorder: const OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.blueGrey, width: 1.0),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.blue, width: 1.0),
                        ),
                      ),
                  ),
                )),
                Container(
                  margin: EdgeInsets.only(top:10),
                    child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Ink(
                      decoration: const ShapeDecoration(
                        color: Colors.blueGrey,
                        shape: CircleBorder(),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.outgoing_mail),
                        color: Colors.white,
                        onPressed: () {
                          print("validation");
                          sendMail(titleTextController.text, bodyTextController.text);
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                )),
              ],
            )));
  }

  Future<void> sendMail(String title, String body) async {
    final Email email = Email(
      body: body,
      subject: title,
      recipients: ['air.flare.corp@gmail.com'],
      isHTML: false,
    );

    await FlutterEmailSender.send(email);
    addFBLog();
  }

  Future<void> addFBLog() async {
    await FirebaseAnalytics().logEvent(name: 'contact_us', parameters: {'action':'send_mail'});
  }
}
