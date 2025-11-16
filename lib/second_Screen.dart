import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';



class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
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
                ElevatedButton(onPressed: (){

                }, child: Text("data")
                ),
                Text(
                  " ✨🛍️💫".trim(),
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
