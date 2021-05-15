import 'package:flutter/material.dart';

class LogoView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Container(
      height:100,
      child:Center(
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Image.asset(
              'assets/logo.png',
              height: 60.0,
              width: 60.0
            ),
            Text(
              "Globe",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                fontSize: 25.0,
              ),
            )
          ],
        )
      )
    );
  }

}