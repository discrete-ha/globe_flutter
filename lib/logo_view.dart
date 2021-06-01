import 'package:flutter/material.dart';

class LogoView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 100,
        width: 210,
        // color: Colors.blue,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[

            Positioned(
                bottom: 30.0,
                left: 0.0,
                child: new Image.asset(
                    'assets/logo.png',
                    height: 40.0,
                    width: 40.0)
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  child: Text(
                    "Globe",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 25.0,
                    ),
                  ),
                ),
                Container(
                    child: Text(
                      "Realtime news in a nutshell",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 10.0,
                      ),
                    )),
              ],
            )
          ],
        ));
  }
}
