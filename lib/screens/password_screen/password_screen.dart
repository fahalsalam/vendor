import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vendor/Utils/SharedPreferences.dart';
import 'package:vendor/Utils/constants.dart';
import 'package:vendor/Utils/toast_widget.dart';
import 'package:vendor/Utils/urls.dart';
import 'package:vendor/screens/sign_in_screen/sign_in_screen.dart';
import 'package:vendor/widgets/custom_button.dart';
import 'package:vendor/widgets/custom_textFeild.dart';
import 'package:http/http.dart' as http;

class CreatePasswordScreen extends StatefulWidget {
  final String mobileNumber;
  final bool? fromResetScreen;
  const CreatePasswordScreen({
    super.key,
    required this.mobileNumber,
    this.fromResetScreen,
  });

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

TextEditingController _passwordController = TextEditingController();
TextEditingController _conformPasswordController = TextEditingController();

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  void _handleSuccessResponse(String msg) {
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text("Success!"),
          content: Text(msg),
          actions: [
            TextButton(
              onPressed: () {
                SharedPreference().setLoggedIn(true);
                Navigator.pop(context);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const SignInScreen(),
                  ),
                  (route) => false,
                );
              },
              child: const Text("OK"),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Container(
            //   width: 202.w,
            //   height: 91.h,
            //   decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(13),
            //       color: const Color(0xfff05a28)),
            //   child: Center(
            //       child: Text("BRAND LOGO",
            //           style: TextStyle(
            //               fontSize: 15.sp,
            //               fontWeight: FontWeight.w600,
            //               color: Colors.white))),
            // ),
            const SizedBox(height: 10),
            Container(
              height: h * 0.10,
              width: w * 0.45,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/ic_logo.png"))),
            ),
            Text("Create a Password",
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                )),
            SizedBox(height: 10.h),
            TextFeildWidget(
              labelText: "Password",
              obscureText: false,
              controller: _passwordController,
            ),
            SizedBox(height: 10.h),
            TextFeildWidget(
              labelText: "Confirm Password",
              obscureText: true,
              controller: _conformPasswordController,
            ),
            SizedBox(height: 10.h),
            CustomButton(
              onPress: () async {
                if (_passwordController.text.isEmpty &&
                    _conformPasswordController.text.isEmpty) {
                  ToastWidget().showToastError("Two feilds are required");
                } else if (_passwordController.text !=
                    _conformPasswordController.text) {
                  ToastWidget().showToastError("Password mismatched");
                } else if (_passwordController.text.isEmpty) {
                  ToastWidget()
                      .showToastError("Please fill the password feild");
                } else if (_conformPasswordController.text.isEmpty) {
                  ToastWidget()
                      .showToastError("Please fill the conform Password feild");
                } else {
                  // api call
                  if (widget.fromResetScreen == true) {
                    await reSetVendorPassword();
                    _passwordController.clear();
                    _conformPasswordController.clear();
                  } else {
                    await setVendorPassword();
                    _passwordController.clear();
                    _conformPasswordController.clear();
                  }
                  ToastWidget().showPasswordSetToast();
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => SignInScreen()));
                }
                // Navigator.of(context).pushReplacement(MaterialPageRoute(
                //     builder: (context) => const SignInScreen()));
              },
              btnText: "SAVE PASSWORD",
              bgc: const Color(0xfff05a28),
              height: 50,
              width: double.infinity,
            )
          ],
        ),
      ),
    );
  }

  Future<void> setVendorPassword() async {
    const String url = Urls.setVendorPassword;

    final Map<String, dynamic> bodyParams = {
      "vendorRegisteredMobileNumber": widget.mobileNumber,
      "password": _conformPasswordController.text,
    };

    final String token = Constants().token;

    try {
      EasyLoading.show(
          dismissOnTap: false, maskType: EasyLoadingMaskType.black);
      final http.Response response = await http.post(
        Uri.parse(url),
        headers: {'Token': token, 'Content-Type': 'application/json'},
        body: jsonEncode(bodyParams),
      );

      if (response.statusCode == 200) {
        _handleSuccessResponse(response.body);
        if (kDebugMode) {
          print('Response: ${response.body}');
        }
      } else {
        // Request failed
        if (kDebugMode) {
          print('Request failed with status: ${response.statusCode}');
          print('Response: ${response.body}');
        }
      }
    } catch (error) {
      if (error is SocketException) {
        ToastWidget().showToastError("Please check your internet Connection ");
      }
      if (kDebugMode) {
        print('Error: $error');
      }
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> reSetVendorPassword() async {
    const String url = Urls.reSetVendorPassword;

    final Map<String, dynamic> bodyParams = {
      "vendorRegisteredMobileNumber": widget.mobileNumber,
      "password": _conformPasswordController.text,
    };

    final String token = Constants().token;

    try {
      EasyLoading.show(
          dismissOnTap: false, maskType: EasyLoadingMaskType.black);
      final http.Response response = await http.post(
        Uri.parse(url),
        headers: {
          'Token': token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(bodyParams),
      );

      if (response.statusCode == 200) {
        _handleSuccessResponse(response.body);
        if (kDebugMode) {
          print('Response:>>> ${response.body}');
        }
      } else {
        // Request failed
        if (kDebugMode) {
          print('Request failed with status: ${response.statusCode}');
          print('Response: ${response.body}');
        }
      }
    } catch (error) {
      if (error is SocketException) {
        ToastWidget().showToastError("Please check your internet Connection ");
      }
      if (kDebugMode) {
        print('Error: $error');
      }
    } finally {
      EasyLoading.dismiss();
    }
  }
}
