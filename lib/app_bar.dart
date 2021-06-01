import 'package:flutter/material.dart';
import 'package:globe_flutter/global_navigator.dart';
import 'add_city_list.dart';
import 'const.dart';

import 'package:flutter/services.dart';

void addIfNonNull(Widget? child, List children) {
  if (child != null) {
    children.add(child);
  }
}

AppBar GlobeAppBar(BuildContext context ,String title, String? subtitle, int VIEW_ID, leadFunction){
  List<Widget> actions = [];
  Widget leading = Container();
  bool defaultIcon = true;
  switch(VIEW_ID){
    case VIEW.INDEX:
      defaultIcon = true;
      actions = <Widget>[
        Builder(
          builder: (context) => new IconButton(
            color: Colors.grey[700],
            icon:
            new Icon(
                Icons.add,size: 25.0
            ),
            onPressed: () {
              // _scaffoldkey.currentState!.openEndDrawer();
              Scaffold.of(context).openEndDrawer();
              // Navigator.push(
              //   context,
              //   EnterExitRoute(exitPage: context.widget, enterPage: AddCityList(onDismiss: leadFunction)),
              // );
            },
          )
        )
      ];

      leading = new IconButton(
          icon: new Icon(Icons.refresh, color: Colors.grey.shade600),
          onPressed: () {
            if(leadFunction != null){
              (() async {
                leadFunction();
              })();
            }
          });
      break;
    case VIEW.ADD_CITY:
      defaultIcon = false;
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
    case VIEW.ADD_CITY:
      defaultIcon = false;
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
  actions = [leading, ...actions];

  List<Widget> titleWidgets = [
    Text(
      title,
      style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700]
      )
    )
  ];

  var subtitleWidget = subtitle == null ? null :
      Container(
        margin: EdgeInsets.only(top: 35),
          child:
        Text(
            subtitle,
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey[400]
            ))
      );


  addIfNonNull(subtitleWidget, titleWidgets);

  return AppBar(
    iconTheme: IconThemeData(color: Colors.grey[600] ),
    // leading: leading,
    title: Stack(
        alignment: Alignment.center,
        children: titleWidgets
    ),
    actions: actions,
    backgroundColor: Colors.white,
    brightness: Brightness.light,
    centerTitle: true,
  );
}


//
// class SlideRightRoute extends PageRouteBuilder {
//   final Widget page;
//   SlideRightRoute({required this.page})
//       : super(
//     pageBuilder: (
//         BuildContext context,
//         Animation<double> animation,
//         Animation<double> secondaryAnimation,
//         ) =>
//     page,
//     transitionsBuilder: (
//         BuildContext context,
//         Animation<double> animation,
//         Animation<double> secondaryAnimation,
//         Widget child,) =>
//         SlideTransition(
//           position: Tween<Offset>(
//             begin: const Offset(0, 0),
//             end: Offset.zero,
//           ).animate(animation),
//           child: child,
//         ),
//   );
// }
// //
// class EnterExitRoute extends PageRouteBuilder {
//   final Widget enterPage;
//   final Widget exitPage;
//   EnterExitRoute({required this.exitPage, required this.enterPage})
//       : super(
//     pageBuilder: (
//         BuildContext context,
//         Animation<double> animation,
//         Animation<double> secondaryAnimation,
//         ) =>
//     enterPage,
//     transitionsBuilder: (
//         BuildContext context,
//         Animation<double> animation,
//         Animation<double> secondaryAnimation,
//         Widget child,
//         ) =>
//         Stack(
//           children: <Widget>[
//             SlideTransition(
//               position: new Tween<Offset>(
//                 begin: const Offset(0.0, 0.0),
//                 end: const Offset(-1.0, 0.0),
//               ).animate(animation),
//               child: exitPage,
//             ),
//             SlideTransition(
//               position: new Tween<Offset>(
//                 begin: const Offset(1.0, 0.0),
//                 end: Offset.zero,
//               ).animate(animation),
//               child: enterPage,
//             )
//           ],
//         ),
//   );
// }