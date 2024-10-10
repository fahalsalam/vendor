import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void showInsufficientBalanceBottomSheet({
  required BuildContext context,
  required num customerWalletBalance,
  required num amount1,
  required String title,
  required String title1,
  required String title2,
  required bool isMinimumRedemption,
  required bool isMaximumRedemption,
  required bool isWalletBalanceZero,
  required bool isRewardScreen,

}) {
  double companyCommission = customerWalletBalance * 0.2;
  double possibleAmt = customerWalletBalance - companyCommission;

  // Conditional Logics  
  String title2Text = ''; 
  String title1Text = '';  

  if (isMinimumRedemption) {
    title2Text = '$title2: ${amount1.toStringAsFixed(2)}';
    title1Text = '$title1: $customerWalletBalance';
  } else if (isMaximumRedemption) {
    title2Text = '$title2: ${amount1.toStringAsFixed(2)}';
    title1Text = '$title1: $customerWalletBalance';
  }
  else if (isRewardScreen) {
    title2Text = '$title2';
    title1Text = '$title1: $customerWalletBalance';
  }  
  else {
    title2Text = '$title2: ${amount1.toStringAsFixed(2)}';
    title1Text = '$title1: $customerWalletBalance';
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20.h),
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 40.sp,
              ),
              SizedBox(height: 10.h),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp, 
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (!isWalletBalanceZero) ...[
                SizedBox(height: 10.h),
                Divider(),
                SizedBox(height: 10.h),
                Text(
                  title1Text,
                  style: TextStyle(
                    fontSize: 14.sp, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  title2Text,
                  style: TextStyle(
                    fontSize: 14.sp, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              SizedBox(height: 20.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h), backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      );
    },
  );
}
