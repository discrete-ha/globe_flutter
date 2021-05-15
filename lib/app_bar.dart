import 'package:flutter/material.dart';
// import 'package:screenshot_share_image/screenshot_share_image.dart';

import 'add_city_list.dart';
import 'setting.dart';

import 'package:flutter/services.dart';

AppBar getAppBar(BuildContext context, Widget currentWidget, String title, int VIEW_ID, leadFunction){
  List<Widget> actions = [];
  Widget leading = Container();

  switch(VIEW_ID){
    case VIEW.INDEX:
      actions = <Widget>[
        // new IconButton(
        //   color: Colors.grey[700],
        //   icon:
        //   new Icon(
        //       Icons.share,size: 25.0
        //   ),
        //   tooltip: 'Add Location',
        //   onPressed: () {
        //     ScreenshotShareImage.takeScreenshotShareImage();
        //   },
        // ),
        new IconButton(
          color: Colors.grey[700],
          icon:
          new Icon(
              Icons.add,size: 25.0
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddCityList(onDismiss: leadFunction)),
            );
          },
        )
      ];

      leading = new IconButton(
          icon: new Icon(Icons.refresh, color: Colors.grey),
          onPressed: () {
            if(leadFunction != null){
              (() async {
                leadFunction();
              })();
            }
          });
      break;
    case VIEW.ADD_CITY:
      leading = new IconButton(
          icon: new Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () {
            SystemChannels.textInput.invokeMethod('TextInput.hide');
            Navigator.of(context).pop();
            if(leadFunction != null){
              (() async {
                leadFunction();
              })();
            }
          });
      break;
  }

  return AppBar(
    iconTheme: IconThemeData(color: Colors.grey[600] ),
    leading: leading,
    title: Text(
        title,
        style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700]
        )
    ),
    actions: actions,
    backgroundColor: Colors.white,
    brightness: Brightness.light,
    centerTitle: true,
  );
}

class SlideRightRoute extends PageRouteBuilder {
  final Widget page;
  SlideRightRoute({required this.page})
      : super(
    pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        ) =>
    page,
    transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
        ) =>
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
  );
}