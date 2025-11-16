import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';



class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  Timer? timer;
  DateTime? _splashStartTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((callback) async {
      _splashStartTime = DateTime.now();
    });
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body:  basicSplash()
    );
  }





  Widget basicSplash(){
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Image(
            //   image: AssetImage(Assets.images.image.path),
            //   width: 0.5.sw,
            //   height: 0.50.sh,
            //   fit: BoxFit.contain,
            // ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 3,
                  children: [
                    Text(
                      "انتظر لحظة",

                    ),

                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  " لأجلك نصنع الأفضل دائمًا\n✨🛍️💫".trim(),
                  textAlign: TextAlign.center,

                ),
              ],
            ),
            Spacer(),

          ],
        ),
      ),
    );

  }
}
