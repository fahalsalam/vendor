import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_name/context.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vendor/Utils/SharedPreferences.dart';
import 'package:vendor/Utils/conform_dialogue.dart';
import 'package:vendor/Utils/constants.dart';
import 'package:vendor/Utils/custom_alert_dialogue.dart';
import 'package:vendor/Utils/custom_error_bottomsheet.dart';
import 'package:vendor/Utils/toast_widget.dart';
import 'package:vendor/Utils/urls.dart';
import 'package:vendor/models/user_verification_model.dart';
import 'package:vendor/models/vendor_model.dart';
import 'package:vendor/screens/dashboard/api_service.dart';
import 'package:vendor/screens/my_drawer/my_drawer.dart';
import 'package:vendor/screens/redeem_screen/api_service.dart';
import 'package:vendor/widgets/custom_button.dart';
import 'package:vendor/widgets/custom_textFeild.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({super.key});

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  final ApiServiceRewards _apiServiceRewards = ApiServiceRewards();
  final ApiServiceRedeem _apiServiceRedeem = ApiServiceRedeem();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _discountValueController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  FocusNode _mobileNumberFocus = FocusNode();
  FocusNode _rewardValueFocus = FocusNode();

  String customerName = "";
  int verificationStatus = 1;
  String mobileNo = "";
  num vendorAmount = 0.0;
  int? customerId;
  int? customerCardNumber;
  String? customerDeviceID;
  num customerWalletBalance = 0.0;
  num vendorWalletBalance = 0.0;
  String? bizVendorVersion;

  bool isMobileNumberSelected = true;
  DateTime? currentBackPressTime;
  bool isButtonDisabled = true;

  @override
  void initState() {
    super.initState();
    getVendor();
    isButtonDisabled = true;
    print(
        "vendormobileNumber:>>>|||${SharedPreference().getVendorMobileNumber()}");
    print("vendorWalletBalance:>>>$vendorWalletBalance");
    _checkForUpdates();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    _mobileNumberFocus.dispose();
    _rewardValueFocus.dispose();
  }

  void showUpdateBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(height: 20),
              Icon(
                Icons.system_update,
                color: Constants().appColor,
                size: 50,
              ),
              SizedBox(height: 20),
              Text(
                'Update Available',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'A new version of the app is available. Please update to the latest version for the best experience.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  const url =
                      'https://play.google.com/store/apps/details?id=com.bizvendor.app';
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url));
                  } else {
                    print('Could not launch $url');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants().appColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.update, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      'Update Now',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Later',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _checkForUpdates() async {
    final response = await http.get(
      Uri.parse(Urls.getAppConfig),
      headers: {
        'Token': Constants().token,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['isSuccess']) {
        final data = responseData['data'][0];
        bizVendorVersion = data['BizVendorVersion'];

        // Check if the versions match
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        if (bizVendorVersion != packageInfo.version) {
          showUpdateBottomSheet(context);
        }
      }
    } else {
      // Handle error response
      print('Failed to load config');
    }
  }

  void getVendor() async {
    try {
      String mobNumber = SharedPreference().getVendorMobileNumber();
      final vendorData = await getVendorData(Constants().token, mobNumber);
      setState(() {
        if (vendorData != null) {
          vendorWalletBalance =
              num.parse(vendorData.vendorWalletBalance.toString());
          print("vendor wallet balance:>>>$vendorWalletBalance");
        }
      });
    } catch (e) {
      if (e is SocketException) {}
      if (kDebugMode) {
        print('Error fetching vendor data: $e');
      }
    }
  }

  Future<VendorModel?> getVendorData(
      String token, String registeredVendorMobileNumber) async {
    const url = Urls.getVendorActivationCheck;
    final headers = {
      'Content-Type': 'application/json',
      'Token': token,
      'RegisteredVendorMobileNumber': registeredVendorMobileNumber.toString(),
    };
    EasyLoading.show(dismissOnTap: false, maskType: EasyLoadingMaskType.black);
    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return VendorModel.fromJson(jsonResponse);
      } else {
        if (kDebugMode) {
          print('API request failed with status ${response.statusCode}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during API request: $e');
      }
      return null;
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> checkCustomerIsEligibleByCard() async {
    const url = Urls.isCustomerEligibileByCardNumber;
    final String token = Constants().token;
    final headers = {
      'flag': "1",
      'Token': token,
      'cardNumber': _mobileNumberController.text,
    };
    try {
      EasyLoading.show(
          dismissOnTap: false, maskType: EasyLoadingMaskType.black);
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['isEligible'] == true) {
          await _fetchCustomerDeatilsByCard();
        }
        else
          {
            showCustomErrorBottomSheet(
                context: context,
                title: 'Oops! Something went wrong',
                messageSpans: [
                  TextSpan(
                    text: '${jsonResponse["reason"]}',
                    style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ],
            );
            _mobileNumberController.text = "";
          }
      } else {
        showCustomErrorBottomSheet(
          context: context,
          title: 'Oops! Something went wrong',
          messageSpans: [
            TextSpan(
              text: 'Invalid Card',
              style:
              TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ],
        );
        _mobileNumberController.text = "";
      }
    } catch (e) {
      if (e is SocketException) {}
      print('Error during API call: $e');
      throw e;
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> _fetchCustomerDeatilsByCard() async {
    try {
      EasyLoading.show(
          dismissOnTap: false, maskType: EasyLoadingMaskType.black);
      final UserVerificationModel userData;
      String token = Constants().token;
      userData = await _apiServiceRewards.getUserVerificationDataByCard1(
          _mobileNumberController.text, token, context,
          controller: _mobileNumberController);
      setState(() {
        customerName = userData.customerName;
        customerWalletBalance = userData.walletbalance;
        customerId = userData.customerID;
        customerCardNumber = userData.cardNumber;
        customerDeviceID = userData.customerDeviceId;
      });
      if (userData.verificationStatus == "ACTIVE CUSTOMER") {
        verificationStatus = 1;
      } else {
        verificationStatus = 2;
        print("Costomer not Eligible");
      }
    } catch (e) {
      if (e is SocketException) {}
      print('Error:>>> $e');
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> checkCustomerIsEligible() async {
    const apiUrl = Urls.checkCustomerEligible;
    String token = Constants().token;
    String mobileNumber = _mobileNumberController.text;
    int flag = 1;
    Map<String, String> headers = {
      "flag": flag.toString(),
      "Token": token,
      "mobileNumber": mobileNumber,
    };

    try {
      http.Response response =
          await http.get(Uri.parse(apiUrl), headers: headers);
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        bool isEligible = jsonResponse['isEligible'];
        if (isEligible) {
          await _fetchCustomerDeatils();
        } else {
          showCustomErrorBottomSheet(
            context: context,
            title: 'Oops! Something went wrong',
            messageSpans: [
              TextSpan(
                text: '${jsonResponse['reason']}',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ],
          );
          _mobileNumberController.clear();
        }
      } else {
        showCustomErrorBottomSheet(
          context: context,
          title: 'Oops! Something went wrong',
          messageSpans: [
            TextSpan(
              text:
                  'No customer found with the provided mobile number. Please verify and retry',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ],
        );
        _mobileNumberController.clear();
      }
    } catch (e) {
      if (e is SocketException) {}
      print("Exception???: $e");
    }
  }

  Future<void> _fetchCustomerDeatils() async {
    try {
      EasyLoading.show(
          dismissOnTap: false, maskType: EasyLoadingMaskType.black);
      final UserVerificationModel userData;
      userData = await _apiServiceRewards.getUserVerificationData(
          _mobileNumberController.text, Constants().token, context,
          controller: _mobileNumberController);
      setState(() {
        customerName = userData.customerName;
        customerWalletBalance = userData.walletbalance;
        customerId = userData.customerID;
        customerCardNumber = userData.cardNumber;
        customerDeviceID = userData.customerDeviceId;
      });
      if (userData.verificationStatus == "ACTIVE CUSTOMER") {
        verificationStatus = 1;
        isCustomerEligible(
            _mobileNumberController.text, Constants().token, 1, context);
      } else {
        verificationStatus = 2;
        print("Customer not Eligible");
      }
    } catch (e) {
      if (e is SocketException) {}
      print('Error:>>> $e');
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<bool> isCustomerEligible(
      String mobileNumber, String token, int flag, context) async {
    const String url = Urls.isCustomerEligible;
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
        return isEligible;
      } else {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        showCustomErrorBottomSheet(
          context: context,
          title: 'Oops! Something went wrong',
          messageSpans: [
            TextSpan(
              text: '${jsonResponse["reason"]}',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ],
        );
        _mobileNumberController.clear();
        throw Exception('API call failed');
      }
    } catch (e) {
      if (e is SocketException) {}
      print('Error: $e');
      throw Exception('Network error');
    }
  }

  Future<void> postReward() async {
    EasyLoading.show(dismissOnTap: false, maskType: EasyLoadingMaskType.black);
    const url = Urls.postReward;
    Map<String, String> headers = {
      "Token": Constants().token,
      "Content-Type": "application/json",
    };
    Map<String, dynamic> requestBody = {
      "flag": 1,
      "jsonData": [
        {
          "rwaid": 0,
          "rwRef": 0,
          "rwDateTime":
              DateFormat("yyyy-MM-ddTHH:mm:ss.SSSZ").format(DateTime.now()),
          "rwCustomerID": customerId,
          "rwCustomerCardNumber": customerCardNumber,
          "rwVendorID": SharedPreference().getVendorId(),
          "rwValue": _discountValueController.text,
          "rwVendorDeviceID": SharedPreference().getVendorDeviceId(),
          "rwCustomerDeviceID": customerDeviceID.toString()
        }
      ]
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
          ),
          builder: (BuildContext context) {
            final mediaQuery = MediaQuery.of(context);
            final bottomPadding = mediaQuery.viewInsets.bottom;
            final screenWidth = mediaQuery.size.width;
            return Padding(
              padding: EdgeInsets.only(
                bottom: bottomPadding,
                left: 16.0,
                right: 16.0,
                top: 24.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  SizedBox(height: 16),
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: screenWidth * 0.15,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Reward Processed Successfully',
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _mobileNumberController.clear();
                        _discountValueController.clear();
                        customerName = '';
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "OK",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      } else {
        ToastWidget().showToastError("${response.body}");
      }
    } catch (e) {
      print('Error: $e');
      if (e is SocketException) {}
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<bool> onWillpop() async {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      ToastWidget().showToastError("Press Back Again to exit");
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillpop,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        drawer: MyDrawer(),
        appBar: AppBar(
          scrolledUnderElevation: 0.0,
          title: Text(
            "REWARDS",
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.r),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: double.infinity, height: 70.h),
                  SizedBox(height: 30.h),
                  Container(
                    height: 91.h,
                    width: 201.w,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/images/ic_logo.png")),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Center(
                    child: customerName.isNotEmpty
                        ? Text(
                            "Customer Name: " + customerName,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          )
                        : SizedBox.shrink(),
                  ),
                  SizedBox(height: 60.h),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.07,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ToggleButtons(
                                isSelected: [
                                  isMobileNumberSelected,
                                  !isMobileNumberSelected
                                ],
                                onPressed: (index) {
                                  setState(() {
                                    isMobileNumberSelected = index == 0;
                                    _mobileNumberController.clear();
                                    _discountValueController.clear();
                                    customerName = '';
                                  });
                                },
                                fillColor: const Color(0xfff05a28),
                                selectedColor: Colors.white,
                                color: Colors.grey.shade700,
                                borderRadius: BorderRadius.circular(10),
                                constraints: BoxConstraints(
                                  minWidth: constraints.maxWidth / 2 - 8,
                                  minHeight:
                                      MediaQuery.of(context).size.height * 0.06,
                                ),
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      "Mobile Number",
                                      style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.04,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      "Card Number",
                                      style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.04,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                                borderColor: Colors.grey.shade300,
                                selectedBorderColor: const Color(0xfff05a28),
                                splashColor:
                                    const Color(0xfff05a28).withOpacity(0.2),
                                highlightColor:
                                    const Color(0xfff05a28).withOpacity(0.1),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Expanded(
                        child: TextFeildWidget(
                          inputFormatters: [
                            if (isMobileNumberSelected)
                              LengthLimitingTextInputFormatter(10),
                            FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                          ],
                          focusNode: _mobileNumberFocus,
                          readOnly: !isMobileNumberSelected ? true : false,
                          textInputType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          width: 324.w,
                          height: 52,
                          labelText: isMobileNumberSelected
                              ? "Customer Mobile Number"
                              : "Customer Card Number",
                          controller: _mobileNumberController,
                          onChanged: (value) {
                            setState(() {
                              if (value.isEmpty) {
                                isButtonDisabled = false;
                                customerName = '';
                              }
                              if (_mobileNumberController.text.isEmpty) {
                                isButtonDisabled = false;
                                customerName = '';
                              }
                              isButtonDisabled = true;
                              customerName = '';
                              if (isMobileNumberSelected) {
                                if (value.length == 10) {
                                  isButtonDisabled = true;
                                  customerName = '';
                                  _fetchCustomerDeatils();
                                  isButtonDisabled = false;
                                }
                              }
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 9.w),
                      Opacity(
                        opacity: isMobileNumberSelected ? 0.5 : 1,
                        child: GestureDetector(
                          onTap: !isMobileNumberSelected
                              ? () {
                                  isButtonDisabled = true;
                                  customerName = '';
                                  scanQrCode();
                                  isButtonDisabled = false;
                                }
                              : () {},
                          child: Container(
                            height: 52,
                            width: 52,
                            decoration: BoxDecoration(
                              color: const Color(0xff575757),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: SizedBox(
                                height: 36,
                                width: 36,
                                child: Image.asset(
                                  "assets/images/icon _qrcode-scan_.png",
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 10.h),
                  TextFeildWidget(
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(12),
                      FilteringTextInputFormatter.allow(RegExp('^(?!0+)[0-9]*'))
                    ],
                    focusNode: _rewardValueFocus,
                    textInputType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    height: 52,
                    controller: _discountValueController,
                    onChanged: (value) {
                      setState(() {
                        isButtonDisabled = !value.isNotEmpty;
                      });
                      _discountValueController.text = value;
                      setState(() {
                        if (_discountValueController.text.isNotEmpty) {
                          validateAndProceed();
                        }
                      });
                    },
                    labelText: "Reward Value",
                  ),
                  SizedBox(height: 30.h),
                  CustomButton(
                    onPress: isButtonDisabled != true
                        ? () {
                            try {
                              if (isButtonDisabled) {
                                return;
                              }
                              if (_mobileNumberController.text.isEmpty &&
                                  _discountValueController.text.isEmpty) {
                                ToastWidget().showToastError(
                                    "Please fill both Mobile Number and Discount Value");
                              } else if (_mobileNumberController.text.isEmpty) {
                                if (isMobileNumberSelected) {
                                  ToastWidget().showToastError(
                                      "Mobile Number is required");
                                } else {
                                  ToastWidget().showToastError(
                                      "Card Number is required");
                                }
                              } else if (_mobileNumberController.text.length <
                                      10 &&
                                  isMobileNumberSelected) {
                                ToastWidget().showToastError(
                                    "Mobile Number is Incorrect");
                              } else if (_discountValueController
                                  .text.isEmpty) {
                                ToastWidget().showToastError(
                                    "Please fill the discount value");
                              } else if (_discountValueController.text == "0") {
                                ToastWidget().showToastError(
                                    "Rewarded value can't be zero");
                              } else {
                                setState(() {
                                  isButtonDisabled = true;
                                });
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return ReusableDialog(
                                      title: 'Confirmation',
                                      content: 'Do you want to proceed?',
                                      onYesPressed: () {
                                        postReward().then((result) {
                                          setState(() {
                                            isButtonDisabled = false;
                                            customerName = '';
                                          });
                                        });
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    DashBoardScreen()));
                                      },
                                      onNoPressed: () {
                                        _discountValueController.clear();
                                        print('User pressed No');
                                      },
                                    );
                                  },
                                );
                              }
                            } catch (e) {
                              print("mwsg:>>>>>>>>>>>>$e");
                            }
                          }
                        : null,
                    btnText: "GIVE DISCOUNT",
                    bgc: const Color(0xfff05a28),
                    height: 52,
                    width: double.infinity,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void scanQrCode() async {
    try {
      final qrCode = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, ScanMode.QR);
      if (mounted) {
        isButtonDisabled = true;
        if (qrCode != "-1") {
          setState(() {
            String formattedQrCode = qrCode.replaceAll(' ', '');
            print("QR Trimmed Result :>>> $formattedQrCode");
            _mobileNumberController.text = formattedQrCode;
            _discountValueController.clear();
            isButtonDisabled = false;
            checkCustomerIsEligibleByCard();
            isButtonDisabled = true;
          });
        } else {
          _mobileNumberController.clear();
        }
        isButtonDisabled = false;
      }
      print("QR Code Result :>>> $qrCode");
    } on PlatformException {
      ToastWidget().showToastError('No QR code found');
    }
  }

  void validateAndProceed() {
    num enteredAmount = num.tryParse(_discountValueController.text) ?? 0;
    if (_mobileNumberController.text.isNotEmpty &&
        enteredAmount >= vendorWalletBalance) {
      showInsufficientBalanceBottomSheet(
        context: context,
        customerWalletBalance: vendorWalletBalance,
        amount1: 0,
        title: 'Insufficient Wallet Balance',
        title1: 'Your Current Balance',
        title2:
            'Unable to process. Top up your wallet or enter a smaller reward value',
        isMinimumRedemption: false,
        isMaximumRedemption: false,
        isWalletBalanceZero: false,
        isRewardScreen: true,
      );
      _discountValueController.clear();
    }
  }

  Future<String> _customerNameWithDelay() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      customerName = customerName;
    });
    return customerName;
  }
}
