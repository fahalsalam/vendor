import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:vendor/Utils/constants.dart';
import 'package:vendor/Utils/custom_alert_dialogue.dart';
import 'package:vendor/Utils/custom_error_bottomsheet.dart';
import 'package:vendor/Utils/urls.dart';
import 'package:vendor/models/user_verification_model.dart';
import 'package:vendor/models/verificatio_by_card.dart';

class ApiServiceRewards {
  Future<UserVerificationModel> getUserVerificationData(
      String mobileNumber, String token, context,
      {TextEditingController? controller}) async {
    const String apiUrl = Urls.login;

    final Map<String, String> headers = {
      'mobileNumber': mobileNumber,
      'Token': token,
    };

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);
      List<dynamic> jsonList = json.decode(response.body);
      if (jsonList[0]["verificationStatus"] == "INVALID CARD") {
        showCustomErrorBottomSheet(
          context: context,
          title: 'INVALID CARD',
          messageSpans: [
            TextSpan(
              text:
                  'Card not valid. Double-check the card details or contact your card issuer',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ],
        );

        if (controller != null) {
          controller.clear();
        }
      }

      if (jsonList[0]["verificationStatus"] == "NEW ACTIVATION") {
        showCustomErrorBottomSheet(
          context: context,
          title: 'CARD NOT ACTIVATED',
          messageSpans: [
            TextSpan(
              text:
                  'The card is not activated. Please activate your card or reach out to your card issuer',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ],
        );
        if (controller != null) {
          controller.clear();
        }
      }

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        if (jsonList.isNotEmpty) {
          return UserVerificationModel.fromJson(jsonList[0]);
        } else {
          if (mobileNumber.length >= 10) {}
          throw Exception('Empty response');
        }
      } else {
        print('Error: ${response.statusCode}');

        throw Exception('No customer found for the given mobile number');
      }
    } catch (e) {
      if (e is SocketException) {}
      print('Error: $e');
      if (mobileNumber.length >= 10) {}

      throw Exception('Network error');
    }
  }

  Future<bool> isCustomerEligible(
      String mobileNumber, String token, int flag, context) async {
    const String url = "http://sacrosys.net:6664/api/2878/IsCustomerEligibile";

    final Map<String, String> headers = {
      "flag": flag.toString(),
      "mobileNumber": mobileNumber,
      "Token": token
    };
    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final parsedResponse = jsonDecode(response.body);

        bool isEligible = parsedResponse['isEligible'];
        if (flag == 1 && isEligible) {
          print("Second api call :>>>$flag ");
          return true;
        } else {
          print("Second api call :>>>$flag");
          return false;
        }
      } else {
        print('Error: ${response.statusCode}');
        print('Error:>>||?? ${response.body}');
        throw Exception('API call failed');
      }
    } catch (e) {
      if (e is SocketException) {}
      print('Errorwwww: $e');
      throw Exception('Network error');
    }
  }

  Future<List<VerificationByCardNumber>> getVerificationByCardNumber(
      String cardNumber) async {
    final url = Uri.parse(Urls.verificationByCardNumber);
    final String token = Constants().token;

    final headers = {
      'Token': token,
      'cardNumber': cardNumber,
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((data) => VerificationByCardNumber.fromJson(data))
          .toList();
    } else {
      throw Exception('Failed to load data');
    }
  }




  // Future<UserVerificationModel> getUserVerificationDataByCard(
  //     String mobileNumber, String token, context,{TextEditingController controller}) async {
  //   const String apiUrl = Urls.login;

  //   final Map<String, String> headers = {
  //     'cardNumber': mobileNumber,
  //     'Token': token,
  //   };

  //   try {
  //     EasyLoading.show();
  //     final response = await http.get(Uri.parse(apiUrl), headers: headers);

  //     if (response.statusCode == 200) {
  //       List<dynamic> jsonList = json.decode(response.body);
  //       if (jsonList.isNotEmpty) {
  //         return UserVerificationModel.fromJson(jsonList[0]);
  //       } else {
  //         if (mobileNumber.length >= 10) {
  //           showDialog(
  //             context: context,
  //             barrierDismissible: false,
  //             builder: (BuildContext context) {
  //               return AlertDialog(
  //                 title: const Center(child: Text('Not Activated')),
  //                 content: const Text('Invalid Mobile Number'),
  //                 actions: [
  //                   Center(
  //                     child: Container(
  //                       height: 52.h,
  //                       width: 143.w,
  //                       decoration: BoxDecoration(
  //                           borderRadius: BorderRadius.circular(10),
  //                           color: Colors.black),
  //                       child: TextButton(
  //                         onPressed: () {
  //                           if(contr)
  //                           Navigator.pop(context);
  //                         },
  //                         child: Text(
  //                           "Ok",
  //                           style: TextStyle(
  //                               color: Colors.white,
  //                               fontSize: 16.sp,
  //                               fontWeight: FontWeight.w500),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               );
  //             },
  //           );
  //         }
  //         throw Exception('Empty response');
  //       }
  //     } else {
  //       print('Error: ${response.statusCode}');
  //       // if (response.statusCode == 404 && mobileNumber.length >= 10) {
  //       //   showDialog(
  //       //     context: context,
  //       //     builder: (BuildContext context) {
  //       //       return AlertDialog(
  //       //         title: const Text('Not Activated'),
  //       //         content: Text('Invalid Mobile Number'),
  //       //         actions: [
  //       //           TextButton(
  //       //             onPressed: () {
  //       //               Navigator.pop(context);
  //       //             },
  //       //             child: Text('OK'),
  //       //           ),
  //       //         ],
  //       //       );
  //       //     },
  //       //   );
  //       // }
  //       throw Exception('No customer found for the given mobile number');
  //     }
  //   } catch (e) {
  //     if (e is SocketException) {
  //       InternetErrorBottomSheet.show(context);
  //     }
  //     print('Error: $e');
  //     if (mobileNumber.length >= 10) {
  //       showDialog(
  //         context: context,
  //         builder: (BuildContext context) {
  //           return AlertDialog(
  //             title: Center(child: const Text('Not Activated')),
  //             content: Text('$e'),
  //             actions: [
  //               Center(
  //                 child: Container(
  //                   height: 52.h,
  //                   width: 143.w,
  //                   decoration: BoxDecoration(
  //                       borderRadius: BorderRadius.circular(10),
  //                       color: Colors.black),
  //                   child: TextButton(
  //                     onPressed: () {
  //                       Navigator.pop(context);
  //                       mobileNumber = "";
  //                     },
  //                     child: Text(
  //                       "Ok",
  //                       style: TextStyle(
  //                           color: Colors.white,
  //                           fontSize: 16.sp,
  //                           fontWeight: FontWeight.w500),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     }

  //     throw Exception('Network error');
  //   } finally {
  //     EasyLoading.dismiss();
  //   }
  // }

  ///////////////////////////////////////////////////////////
  Future<UserVerificationModel> getUserVerificationDataByCard1(
      String mobileNumber, String token, context,
      {TextEditingController? controller}) async {
    const String apiUrl = Urls.verificationByCardNumber;

    final Map<String, String> headers = {
      'cardNumber': mobileNumber,
      'Token': token,
    };

    try {
      EasyLoading.show();
      final response = await http.get(Uri.parse(apiUrl), headers: headers);

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        if (jsonList.isNotEmpty) {
          print("Fetch Data from card number :>>>${jsonList[0]["cardNumber"]}");
          log(jsonList[0]["cardNumber"]);
          return UserVerificationModel.fromJson(jsonList[0]);
        } else {
          if (mobileNumber.length != jsonList[0]["cardNumber"]) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Center(child: const Text('Not Activated')),
                  content: const Text('Invalid Mobile Number'),
                  actions: [
                    Center(
                      child: Container(
                        height: 52.h,
                        width: 143.w,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.black),
                        child: TextButton(
                          onPressed: () {
                            if (controller != null) {
                              controller.clear();
                            }
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          }
          throw Exception('Empty response');
        }
      } else {
        print('Error: ${response.statusCode}');

        throw Exception('No customer found for the given mobile number');
      }
    } catch (e) {
      if (e is SocketException) {}
      print('Error: $e');

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Center(child: const Text('Not Activated')),
            content: Text('$e'),
            actions: [
              Center(
                child: Container(
                  height: 52.h,
                  width: 143.w,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (controller != null) {
                        controller.clear();
                      }
                    },
                    child: Text(
                      "Ok",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    } finally {
      EasyLoading.dismiss();
    }

    throw Exception('Network error');
  }
}
