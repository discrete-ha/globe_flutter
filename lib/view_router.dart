
import 'package:flutter/material.dart';

  Route ViewRouter(Widget nextView) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => nextView,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.fastOutSlowIn;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }