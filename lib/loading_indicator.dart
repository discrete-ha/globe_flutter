import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child:  Container(
          width: 70,
          height: 70,
          child: Lottie.asset('assets/globe_lottie.json'),
        )
    );
  }
}