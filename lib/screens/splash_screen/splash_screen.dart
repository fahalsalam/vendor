import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vendor/Utils/SharedPreferences.dart';
import 'package:vendor/screens/dashboard/dashboard_screen.dart';
import 'package:vendor/screens/sign_in_screen/sign_in_screen.dart';
import 'package:page_transition/page_transition.dart';

class SpalshScreen extends StatefulWidget {
  const SpalshScreen({super.key});

  @override
  State<SpalshScreen> createState() => _SpalshScreenState();
}

class _SpalshScreenState extends State<SpalshScreen> {
  bool islogged = false;

  @override
  void initState() {
    super.initState();
    islogged = SharedPreference().getLoggedIn();
    // SharedPreference().setVendorId("1000055");
    // SharedPreference().setVendorDeviceId("123456");

    startTime();
  }

  @override
  Widget build(BuildContext context) {
    // var w = MediaQuery.of(context).size.width;
    // var h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Image.asset(
                  "assets/images/ic_logo.png",
                  height: 91.h,
                  width: 201.w,
                  /*style: TextStyle(
                  color: AppColor.app_btn_color,
                  fontWeight: FontWeight.bold,
                  fontSize: 25
                ),*/
                ),
              ),
            ],
          ),
          // Positioned(
          //   bottom: -10.h,
          //   left: 0.0.w,
          //   child: Container(
          //     height: w * 0.5,
          //     width: w * 0.5,
          //     decoration: const BoxDecoration(
          //       image: DecorationImage(
          //         image: AssetImage("assets/images/Vector.png"),
          //       ),
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }

  startTime() async {
    var _duration = Duration(seconds: 3);
    await Timer(_duration, navigationPage);
  }

  void navigationPage() {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.leftToRight, child: SignInScreen()));

    // PageTransition(child: SignInScreen(), type: PageTransitionType.leftToRight));
    if (islogged) {
      Navigator.pop(context, true);
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.rightToLeft,
              child: const DashBoardScreen()));
    } else {
      Navigator.pop(context, true);
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.rightToLeft,
              child: const SignInScreen()));
    }
  }
}
