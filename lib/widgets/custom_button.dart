import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButton extends StatelessWidget {
  final double? height;
  final double? width;
  final String? btnText;
  VoidCallback? onPress;
  Color? bgc;
  // TextStyle? style;

  CustomButton({
    Key? key,
    this.height,
    this.width,
    this.onPress,
    this.bgc,
    this.btnText,
    // this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        
        onPressed: onPress,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          // backgroundColor: Color(0xffF05A28), // background
          backgroundColor: bgc, // background
        ),
        child: Text("$btnText",
            style:  TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
      ),
    );
  }
}
