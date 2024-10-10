// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:vendor/Utils/constants.dart';
import 'package:vendor/Utils/toast_widget.dart';

import 'package:vendor/screens/password_screen/password_screen.dart';
import 'package:vendor/screens/redeem_screen/redeem_screen.dart';
import 'package:vendor/screens/sign_in_screen/api_service.dart';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';

class OTPScreen extends StatefulWidget {
  var phone = "";
  var otp = "";
  var otpType = "";
  bool fromResetScreen; // Fahal Changed
  final bool fromRedeemScreen; // Add this parameter
  final Function? onOtpVerified;
  final VoidCallback? onDispose; // Add this callback

  OTPScreen(
    this.phone,
    this.otp,
    this.otpType, // Fahal Changed
    {
    this.fromResetScreen = false,
    this.fromRedeemScreen = false, // Default to false
    this.onOtpVerified,
    this.onDispose, // Pass the callback
  });

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return OTPScreenState();
  }
}

class OTPScreenState extends State<OTPScreen> {
  ApiService apiService = ApiService();
  int secondsRemaining = 30;
  bool enableResend = false;
  late Timer timer;

  var pinPhoneController = TextEditingController();
  late NavigatorState _navigator; // Fahal Changed

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Save a reference to the Navigator
    _navigator = Navigator.of(context); // Fahal Changed
  }

  // super.initState();
  // timer = Timer.periodic(Duration(seconds: 1), (_) {
  //   if (secondsRemaining != 0) {
  //     setState(() {
  //       secondsRemaining--;
  //     });
  //   } else {
  //     setState(() {
  //       enableResend = true;
  //     });
  //   }
  // });

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (secondsRemaining != 0) {
        setState(() {
          secondsRemaining--;
        });
      } else {
        setState(() {
          enableResend = true;
        });
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    _navigator = NavigatorState(); // Clear the reference
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
                flex: 0,
                child: Container(
                  height: 50,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: Image.asset(
                            "assets/images/ic_back_img.png",
                          ),
                        ),
                      )
                    ],
                  ),
                )),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/ic_logo.png",
                    height: 91.h,
                    width: 201.w,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 25.0),
                    child: Text(
                      widget.fromRedeemScreen
                          ? "Please Verify your OTP"
                          : "Verify your phone number", // Conditional text
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Enter OTP code sent to - ${widget.phone}",
                      style: const TextStyle(
                          color: Color(0xFF828282),
                          fontSize: 15,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                    child: buildPinPut(),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, top: 20),
                    child: GestureDetector(
                      onTap: () async {
                        if (pinPhoneController.text.isEmpty) {
                          ToastWidget().showToastError("Please fill OTP");
                        } else if (pinPhoneController.text.toString() !=
                            widget.otp) {
                          print("Enter OTP sended Code .... - ${widget.otp}");
                          ToastWidget().showToastError("OTP is incorrect");
                        } else {
                          // Fahal Changed
                          if (widget.fromRedeemScreen == true &&
                              widget.onOtpVerified != null) {
                            widget.onOtpVerified!();
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => RedeemScreen()));
                          } else if (widget.onOtpVerified ==
                              null) // Fahal Changed
                          {
                            Navigator.of(context)
                                .pushReplacement(MaterialPageRoute(
                                    builder: (context) => CreatePasswordScreen(
                                          mobileNumber: widget.phone,
                                          fromResetScreen:
                                              widget.fromResetScreen,
                                        )));
                          }

                          // if (widget.from_screen == "password") {
                          //   // Navigator.push(
                          //   //     context,
                          //   //     PageTransition(
                          //   //         type: PageTransitionType.rightToLeft,
                          //   //         child: ForgotPasswordScreen(
                          //   //             widget.phone, widget.otp)));
                          // } else {
                          //   Navigator.push(
                          //       context,
                          //       PageTransition(
                          //           type: PageTransitionType.rightToLeft,
                          //           child: CreatePasswordScreen(
                          //               // widget.fullName,
                          //               // widget.phone,
                          //               // widget.email,
                          //               // widget.address1,
                          //               // widget.address2,
                          //               // widget.pinCode,
                          //               // widget.file,
                          //               // widget.deviceID,
                          //               // widget.cardNumber,
                          //               )));
                          // }
                        }
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Constants().appColor),
                        child: const Align(
                          alignment: Alignment.center,
                          child: Text(
                            "VERIFY",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(top: 10)),
                  Text("Resend Otp in:($secondsRemaining)"),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Text(
                      "Didn’t received OTP code?",
                      style: const TextStyle(
                          color: Color(0xFF828282),
                          fontSize: 15,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      enableResend ? _resendCode() : null;
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Text(
                        "Resend Code",
                        style: TextStyle(
                            color: enableResend
                                ? Constants().appColor
                                : Constants().grayColor,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildPinPut() {
    final defaultPinTheme = PinTheme(
      width: 49.w,
      height: 52.h,
      textStyle: TextStyle(
          fontSize: 20,
          color: Constants().appColor,
          fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Constants().appColor),
      borderRadius: BorderRadius.circular(10),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: const Color.fromRGBO(234, 239, 243, 1),
      ),
    );

    return Pinput(
      controller: pinPhoneController,
      length: 6,
      keyboardType: TextInputType.number,
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: focusedPinTheme,
      submittedPinTheme: submittedPinTheme,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp('[0-9]')),
      ],
      validator: (s) {
        return s == widget.otp ? null : 'Pin is incorrect';
      },
      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
      showCursor: true,
      onCompleted: (pin) => debugPrint(pin),
    );
  }

  void _resendCode() {
    setState(() {
      pinPhoneController.text = "";
      print("Resend Button Clicked");
      secondsRemaining = 30;
      enableResend = false;
      apiService.getOtp(widget.phone, context, widget.otpType,
          fromResetScreen: widget.fromResetScreen,
          fromRedeemScreen: widget.fromRedeemScreen,
          onOtpVerified: widget.onOtpVerified);
    });
  }
}
