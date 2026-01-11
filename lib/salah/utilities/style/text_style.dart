import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextStyle {
  TextStyle heading1L = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 18.sp,

    // fontFamily: 'CrimsonText',
    color: Colors.white,
  );
  TextStyle pacifico = TextStyle(
    // fontFamily: "Pacifico",
    fontSize: 17.sp,
    height: 0.5.h,
    color: Colors.black,
  );

  TextStyle chewy = TextStyle(
    fontFamily: "Chewy",
    fontWeight: FontWeight.bold,
    fontSize: 30.sp,
    color: Color(0XFF2387FC),
  );

  TextStyle rubik = TextStyle(
    fontFamily: "Rubik",
    fontSize: 15.sp,
    color: Colors.black,
  );

  TextStyle crimson = TextStyle(
    // fontFamily: 'CrimsonText',
    fontSize: 15.sp,
    color: Colors.black45,
  );

  TextStyle cairo = TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w200,
    color: Colors.white,
    fontFamily: 'Cairo',
  );
}
