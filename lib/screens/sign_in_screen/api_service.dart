import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';
import 'package:vendor/Utils/constants.dart';
import 'package:vendor/Utils/toast_widget.dart';
import 'package:vendor/Utils/urls.dart';
import 'package:vendor/models/vendor_model.dart';
import 'package:vendor/screens/otp_screen/otp_screen.dart';

class ApiService {
  Future<VendorModel?> getVendorData(
      String token, String registeredVendorMobileNumber, context) async {
    const url = Urls.getVendorActivationCheck;
    final headers = {
      'Content-Type': 'application/json',
      'Token': token,
      'RegisteredVendorMobileNumber': registeredVendorMobileNumber.toString(),
    };

    print("Headers:>>>$headers");
    print("Headers:>>>||$registeredVendorMobileNumber");
    try {
      EasyLoading.show(
          dismissOnTap: false, maskType: EasyLoadingMaskType.black);
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print("Response:>>>$jsonResponse");
        return VendorModel.fromJson(jsonResponse);
      } else {
        // Handle error response
        final Map<String, dynamic> jsonResponse1 = json.decode(response.body);
        print('API request failed with status $jsonResponse1');
        return null;
      }
    } catch (e) {
      // Handle network or other errors
      print('Error during API request: $e');
      ToastWidget().showToastError(e.toString());
      if (e is SocketException) {}
      return null;
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> getOtp(
    String phone,
    BuildContext context,
    String otpType, {
    bool fromResetScreen = false,
    bool fromRedeemScreen = false, // Default to false
    Function? onOtpVerified, // Optional callback
  }) async {
    EasyLoading.show(dismissOnTap: false, maskType: EasyLoadingMaskType.black);
    NavigatorState? navigator;
    final request = http.MultipartRequest("POST", Uri.parse(Urls.sendOtp));

    try {
      navigator = Navigator.of(context);

      var response = await http.post(
        Uri.parse(Urls.sendOtp),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'MobileNumber': phone,
          'OtpType': otpType,
        }),
      );
      // var response = await http.get(
      //   Uri.parse(Urls.sendOtp),
      //   headers: {
      //     'Content-type': 'application/json',
      //     'Accept': 'application/json',
      //     'Token': Constants().token,
      //     'MobileNumber': phone,
      //     'OtpType': otpType,
      //   },
      // );

      if (response.statusCode == 200) {
        EasyLoading.dismiss();
        log(response.body);
        Map<String, dynamic> resp = jsonDecode(response.body);
        var otp = resp['otp'].toString();

        navigator?.push(
          MaterialPageRoute(
            builder: (context) => OTPScreen(
              phone,
              otp,
              otpType,
              fromRedeemScreen: fromRedeemScreen,
              onOtpVerified: onOtpVerified,
            ),
          ),
        );
      } else {
        Map<String, dynamic> value = json.decode(response.body);
        EasyLoading.dismiss();
        ToastWidget().showToastError(value['message'].toString());
        log(response.body);
      }
    } catch (error, stackTrace) {
      if (error is SocketException) {
        log(error.toString());
        log(stackTrace.toString());
      }
      EasyLoading.dismiss();
      log(error.toString());
      log(stackTrace.toString());
    }
  }

  void getResetOtp(
    String phone,
    BuildContext context,
    String fromScreen,
    String otpType,
  ) async {
    EasyLoading.show(dismissOnTap: false, maskType: EasyLoadingMaskType.black);
    final request = http.MultipartRequest("POST", Uri.parse(Urls.sendOtp));

    try {
      var response = await http.post(
        Uri.parse(Urls.sendOtp),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'MobileNumber': phone,
          'OtpType': otpType,
        }),
      );

      // var response = await http.get(
      //   Uri.parse(Urls.sendOtp),
      //   headers: {
      //     'Content-type': 'application/json',
      //     'Accept': 'application/json',
      //     'Token': Constants().token,
      //     'MobileNumber': phone,
      //     'OtpType': otpType,
      //   },
      // );

      if (response.statusCode == 200) {
        EasyLoading.dismiss();
        log(response.body);
        Map<String, dynamic> resp = jsonDecode(response.body);
        var otp = resp['otp'].toString();
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) =>
                OTPScreen(phone, otp, otpType, fromResetScreen: true)));
        // Navigator.push(
        //   context,
        //   PageTransition(
        //     type: PageTransitionType.rightToLeft,
        //     child: OTPScreen(
        //       phone,
        //       otp,otpType
        //       // "",
        //       // "",
        //       // "",
        //       // "",
        //       // "",
        //       // "",
        //       // "",
        //       // "",
        //       // "password",
        //     ),
        //   ),
        // );
      } else {
        Map<String, dynamic> value = json.decode(response.body);
        EasyLoading.dismiss();
        ToastWidget().showToastError(value['message'].toString());
        log(response.body);
      }
    } catch (error, stackTrace) {
      if (error is SocketException) {}
      EasyLoading.dismiss();
      log(error.toString());
      log(stackTrace.toString());
    }
  }

  // final String baseUrl;
  // final String token;

  // ApiClient(this.baseUrl, this.token);
}
