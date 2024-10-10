import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vendor/Utils/constants.dart';

class ReusableDialog extends StatelessWidget {
  final String title;
  final String? content;
  final Function()? onYesPressed;
  final Function()? onNoPressed;

  ReusableDialog({
    required this.title,
    this.content,
    this.onYesPressed,
    this.onNoPressed,
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 5,
      backgroundColor: Colors.white,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        width: width * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            if (content != null) 
              Text(
                content!,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (onYesPressed != null) {
                      onYesPressed!();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Constants().appColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 5,
                    shadowColor: Colors.black54,
                    padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
                  ),
                  child: Text(
                    'Yes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (onNoPressed != null) {
                      onNoPressed!();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 5,
                    shadowColor: Colors.black54,
                    padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
                  ),
                  child: Text(
                    'No',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
