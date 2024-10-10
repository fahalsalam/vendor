import 'dart:convert';
import 'dart:io';

// import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vendor/Utils/SharedPreferences.dart';
import 'package:vendor/Utils/conform_dialogue.dart';
import 'package:vendor/Utils/constants.dart';
import 'package:vendor/Utils/custom_alert_dialogue.dart';
import 'package:vendor/Utils/custom_error_bottomsheet.dart';
import 'package:vendor/Utils/smsTypes.dart';
import 'package:vendor/Utils/toast_widget.dart';
import 'package:vendor/Utils/urls.dart';
import 'package:vendor/models/user_verification_model.dart';
import 'package:vendor/screens/my_drawer/my_drawer.dart';
import 'package:vendor/screens/otp_screen/otp_screen.dart';
import 'package:vendor/screens/redeem_screen/api_service.dart';
import 'package:vendor/screens/registor_screen/registor_screen.dart';
import 'package:vendor/widgets/custom_button.dart';
import 'package:vendor/widgets/custom_textFeild.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class RedeemScreen extends StatefulWidget {
  const RedeemScreen({super.key});

  @override
  State<RedeemScreen> createState() => _RedeemScreenState();
}

class _RedeemScreenState extends State<RedeemScreen> {
  final ApiServiceRedeem _apiServiceRedeem = ApiServiceRedeem();

  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _discountValueController =
      TextEditingController();
  bool isNotValid = true;

  String customerName = "";
  String customerNameFromByCard = '';
  int verificationStatus = 1;
  String mobileNo = "";
  num vendorAmount = 0.0;
  int? customerId;
  int? customerCardNumber;
  String? customerDeviceID;
  int otpMobileNo = 0;
  num minRedemptionAmount = 0;
  num maxRedemptionAmountPerDay = 0;
  num minWalletBalance = 99;
  num CustomerDailyRedemptionValueSum = 0;

  bool isScannerOpen = false;
  bool isCard = false;

  double companyCommissionPercentage = 20;

  num customerWalletBalance = 0.0;
  num calculatedValue = 0;

  num _companyCommission = 0;
  num _customerRedeemdValue = 0;

  num get companyCommission => _companyCommission;
  num get customerRedeemdValue => _customerRedeemdValue;

  DateTime? currentBackPressTime;
  bool isButtonDisabled = true;
  int datavalue = 0;
  FocusNode _mobileNumberFocused = FocusNode();
  FocusNode _discountValueFocused = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isButtonDisabled = true;
  }

  Future<void> _fetchCustomerDeatilsByCard() async {
    try {
      EasyLoading.show(
          dismissOnTap: false, maskType: EasyLoadingMaskType.black);
      final UserVerificationModel userData;
      String token = Constants().token;

      userData = await _apiServiceRedeem.getUserVerificationDataByCard1(
          _mobileNumberController.text, token, context,
          controller: _mobileNumberController);

      print("Uder Data get from crad number:>>>${userData.verificationStatus}");
      setState(() {
        customerName = userData.customerName;
        customerWalletBalance = userData.walletbalance;
        customerId = userData.customerID;
        customerCardNumber = userData.cardNumber;
        customerDeviceID = userData.customerDeviceId;
        otpMobileNo = userData.mobileNumber;
        minRedemptionAmount = userData.minRedemptionAmount;
        maxRedemptionAmountPerDay = userData.maxRedemptionAmountPerDay;
        minWalletBalance = userData.minWalletBalance;
        CustomerDailyRedemptionValueSum = userData.customerDailyLimit;
        isNotValid = false;
      });

      setState(() {
        if (userData.verificationStatus == "ACTIVE CUSTOMER") {
          verificationStatus = 1;
          // _apiServiceRedeem.isCustomerEligible(_mobileNumberController.text,
          //     Constants().token, verificationStatus);
          // checkCustomerIsEligibleByCard();
        } else {
          verificationStatus = 2;
          print("Costomer nor Eligible");
        }
      });
    } catch (e) {
      // Handle errors
      print('Error:>>> $e');
      if (e is SocketException) {}
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> checkCustomerIsEligibleByCard() async {
    const apiUrl = Urls.isCustomerEligibileByCardNumber;
    String token = Constants().token;
    String cardNumber = _mobileNumberController.text;
    int flag = 2;
    Map<String, String> headers = {
      "flag": flag.toString(),
      "Token": token,
      "cardNumber": cardNumber,
    };
    print("headres details from card number:>>>$headers");
    try {
      EasyLoading.show(
          dismissOnTap: false, maskType: EasyLoadingMaskType.black);
      http.Response response =
          await http.get(Uri.parse(apiUrl), headers: headers);

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        bool isEligible = jsonResponse['isEligible'];

        if (isEligible) {
          await _fetchCustomerDeatilsByCard();
        } else {
          isCard = false;
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
          _discountValueController.clear();
          _mobileNumberController.clear();
        }
      } else {
        print("Error: ${response.statusCode}");
        print("Error: ${response.body}");
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        String reason = jsonResponse["reason"];
        if (isScannerOpen == false) _mobileNumberController.clear();

        showCustomErrorBottomSheet(
          context: context,
          title: 'Oops! Something went wrong',
          messageSpans: [
            TextSpan(
              text: reason == null
                  ? "The QR code you scanned is not valid or has expired. Please verify and retry"
                  : '$reason',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ],
        );
        _mobileNumberController.clear();
      }
    } catch (e) {
      print("Exception: $e");
      if (e is SocketException) {
      } else {
        showCustomErrorBottomSheet(
          context: context,
          title: 'Oops! Something went wrong',
          messageSpans: [
            TextSpan(
              text:
                  'The QR code you scanned is not valid or has expired. Please verify and retry',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ],
        );
        //   Navigator.pop(context);
        _mobileNumberController.clear();
      }
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> checkCustomerIsEligible() async {
    const apiUrl = Urls.checkCustomerEligible;
    String token = Constants().token;
    String mobileNumber = _mobileNumberController.text;
    int flag = 2;
    Map<String, String> headers = {
      "flag": flag.toString(),
      "Token": token,
      "mobileNumber": mobileNumber,
    };

    try {
      EasyLoading.show(
          dismissOnTap: false, maskType: EasyLoadingMaskType.black);
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
                text: '${jsonResponse["reason"]}',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ],
          );
          _discountValueController.clear();
          _mobileNumberController.clear();
        }
      } else {
        showCustomErrorBottomSheet(
          context: context,
          title: 'Oops! Something went wrong',
          messageSpans: [
            TextSpan(
              text:
                  'No customer found with the provided mobile number. Please verify and retry.',
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
    } finally {
      EasyLoading.dismiss();
    }
  }

//todo for delete
  Future<void> _fetchCustomerDeatils() async {
    try {
      EasyLoading.show(
          dismissOnTap: false, maskType: EasyLoadingMaskType.black);
      final UserVerificationModel userData =
          await _apiServiceRedeem.getUserVerificationData(
              _mobileNumberController.text, Constants().token, context,
              controller: _mobileNumberController);
      print("Uder Data:>>>${userData.verificationStatus}");
      setState(() {
        customerName = userData.customerName;
        customerWalletBalance = userData.walletbalance;
        customerId = userData.customerID;
        customerCardNumber = userData.cardNumber;
        customerDeviceID = userData.customerDeviceId;
        otpMobileNo = userData.mobileNumber;
        minRedemptionAmount = userData.minRedemptionAmount;
        maxRedemptionAmountPerDay = userData.maxRedemptionAmountPerDay;
        CustomerDailyRedemptionValueSum = userData.customerDailyLimit;
        isNotValid = false;
      });
      print("Customer Wallet Balance ===== $customerWalletBalance");
      setState(() {
        if (userData.verificationStatus == "ACTIVE CUSTOMER") {
          verificationStatus = 1;
          String mobileNumber = _mobileNumberController.text;
          isCustomerEligible(
              mobileNumber, Constants().token, 2, context, mobileNumber);
        } else if (userData.verificationStatus == "INVALID CARD") {
          ToastWidget().showToastError("Invalid card");
          verificationStatus = 2;
          print("Costomer nor Eligible");
          // _showErrorMessage();
          ToastWidget().showToastError("Costomer nor Eligible");
        }
      });
    } catch (e) {
      // Handle errors
      print('Error: fetch from mobile number>>> $e');
      if (e is SocketException) {}
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<bool> isCustomerEligible(
      String mobileNumber, String token, int flag, context, controller) async {
    // const String url = "http://sacrosys.net:6662/api/2878/IsCustomerEligibile";
    const String url = Urls.isCustomerEligible;

    final Map<String, String> headers = {
      "flag": flag.toString(),
      "mobileNumber": mobileNumber,
      "Token": token
    };
    isCard = false;

    print("Check header params:>>>$headers");
    try {
      EasyLoading.show(
          dismissOnTap: false, maskType: EasyLoadingMaskType.black);
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
        print('Error>>>>>>: ${response.statusCode}');
        print("Status Body:${response.body}");
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
      print('Errorwwww: $e');
      if (e is SocketException) {}
      throw Exception('Network error');
    } finally {
      EasyLoading.dismiss();
    }
  }

  num calculateCustomerRedeemValue(
      num vendorAmount, num companyCommissionPercentage) {
    // Calculate CustomerRedeemValue
    num customerRedeemValue =
        vendorAmount / (1 - companyCommissionPercentage / 100);
    print("Customer Redeemed Value :>>>$customerRedeemValue");
    return customerRedeemValue;
  }

  num calculateCompanyCommissionValue(
      num customerRedeemValue, num vendorAmount) {
    // Calculate Company Commission Value
    num companyCommissionValue = customerRedeemValue - vendorAmount;
    return companyCommissionValue;
  }
// num calculateCompanyCommissionValue(num customerRedeemValue, num vendorAmount,
//       num companyCommissionPercentage) {
//     // Convert companyCommissionPercentage to decimal
//     double commissionDecimal = companyCommissionPercentage / 100;

//     // Calculate Company Commission Value
//     num companyCommissionValue =
//         customerRedeemValue - vendorAmount * commissionDecimal;
//     return companyCommissionValue;
//   }

  Future<void> postRedeem() async {
    // Show loading indicator
    EasyLoading.show(dismissOnTap: false, maskType: EasyLoadingMaskType.black);

    const url = Urls.postRedeem;
    Map<String, String> headers = {
      "Token": Constants().token,
      "Content-Type": "application/json",
    };

    Map<String, dynamic> requestBody = {
      "flag": 2,
      "jsonData": [
        {
          "rdRef": 123,
          "rdDateTime":
              DateFormat("yyyy-MM-ddTHH:mm:ss.SSSZ").format(DateTime.now()),
          "rdCustomerId": customerId,
          "rdCustomerCardNumber": customerCardNumber,
          "rdVendorId": SharedPreference().getVendorId(),
          "rdCustomerRedeemValue": _customerRedeemdValue,
          "rdVendorRedeemValue": vendorAmount,
          "rdCompanyRedeemValue": _companyCommission,
          "rdCompanyCommPercentage": 20,
          "rdVendorDeviceId": "sdf34r5",
          "rdCustomerDeviceId": customerDeviceID.toString()
        }
      ]
    };

    print("request Body :>>>$requestBody");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        _showRedeemSuccessDialog(context);
      } else {
        ToastWidget().showToastError("${response.body}");
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      ToastWidget().showToastError("$e");
      if (e is SocketException) {}
    } finally {
      EasyLoading.dismiss();
    }
  }

  void _showRedeemSuccessDialog(BuildContext context) {
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
        final screenHeight = mediaQuery.size.height;

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
                width: screenWidth * 0.15,
                height: screenHeight * 0.01,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: screenWidth * 0.15,
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                'Redemption Processed Successfully',
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.03),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _mobileNumberController.clear();
                    _discountValueController.clear();
                  },
                  style: ElevatedButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "OK",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
            ],
          ),
        );
      },
    );
  }

  Future<bool> onWillPop() async {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      ToastWidget().showToastError("Press again to exit");
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        // drawerEnableOpenDragGesture: false,
        drawer: MyDrawer(),
        appBar: AppBar(
          scrolledUnderElevation: 0.0,
          title: Text(
            "REDEEM",
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 70.h,
                ),
                // Container(
                //   width: 202.w,
                //   height: 91.h,
                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(13),
                //     color: const Color(0xfff05a28),
                //   ),
                //   child: Center(
                //     child: Text("Vendor Logo",
                //         style: TextStyle(
                //           fontSize: 15.sp,
                //           fontWeight: FontWeight.w600,
                //         )),
                //   ),
                // ),
                SizedBox(height: 30.h),
                Container(
                  height: 91.h,
                  width: 201.w,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/images/ic_logo.png"))),
                ),
                SizedBox(height: 20.h),
                Center(
                  child: customerName != null && customerName.isNotEmpty
                      ? Text(
                          "Customer Name: " + customerName,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.red, // Set the text color to red
                          ),
                        )
                      : SizedBox.shrink(),
                ),
                SizedBox(height: 50.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextFeildWidget(
                        focusNode: _mobileNumberFocused,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                          LengthLimitingTextInputFormatter(10),
                        ],
                        textInputType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        width: 324.w,
                        height: 52,
                        labelText: isScannerOpen == true
                            ? "Card Number"
                            : "Customer Mobile Number",
                        controller: _mobileNumberController,
                        onChanged: (value) {
                          setState(() {
                            mobileNo = value;
                            if (_mobileNumberFocused.hasFocus) {
                              _discountValueController.clear();
                            }
                            if (_mobileNumberController.text.isEmpty) {
                              setState(() {
                                isButtonDisabled = false;
                              });
                            }
                            setState(() {
                              isButtonDisabled = true;
                              customerName = '';
                            });

                            if (mobileNo.length == 10) {
                              setState(() {
                                isButtonDisabled = true;
                                customerName = '';
                              });

                              _fetchCustomerDeatils();
                              setState(() {
                                isButtonDisabled = true;
                              });
                            }
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 9.w),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isScannerOpen = true;
                          _mobileNumberController.clear();
                          isButtonDisabled = false;
                          print("Scanner clicked :>>>$isScannerOpen");
                          scanQrCode();
                          isCard = true;
                          isButtonDisabled = true;
                        });
                      },
                      child: Container(
                        height: 52,
                        width: 52,
                        decoration: BoxDecoration(
                          color: Color(0xff575757),
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
                    )
                  ],
                ),
                SizedBox(height: 10.h),
                TextFeildWidget(
                  focusNode: _discountValueFocused,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(12),
                    // FilteringTextInputFormatter.allow(RegExp('[0-9]'))
                    FilteringTextInputFormatter.allow(RegExp('^(?!0+)[0-9]*'))
                  ],
                  textInputType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  height: 52,
                  onChanged: (value) {
                    setState(() {
                      double enteredValue = double.tryParse(value) ?? 0;
                      isButtonDisabled = enteredValue < minRedemptionAmount;
                      // Check if the entered value is greater than 2000
                      if (enteredValue > 2000) {
                        // Show a message or take necessary action
                        // For example, you can clear the text field and show a warning
                        _discountValueController.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Maximum allowed value is 2000'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                        return;
                      }

                      // check the redemption amount is greather than customer wallet
                      if (enteredValue > customerWalletBalance) {
                        showCustomErrorBottomSheet(
                          context: context,
                          title: 'Insufficient Wallet Balance',
                          messageSpans: [
                            const TextSpan(
                                text: 'Your current wallet balance is '),
                            TextSpan(
                              text:
                                  '${customerWalletBalance.toStringAsFixed(2)} rupees',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red),
                            ),
                          ],
                        );
                        _discountValueController.clear();
                        isButtonDisabled = true;
                        return;
                      }
                    });
                  },
                  controller: _discountValueController,
                  // hintText: "Discount Valuer",
                  labelText: "Redeem Value",
                  readOnly: isNotValid,
                ),
                SizedBox(height: 30.h),
                CustomButton(
                  onPress: isButtonDisabled != true
                      ? () {
                          if (isButtonDisabled) {
                            return;
                          }
                          if (_mobileNumberController.text.isEmpty &&
                              _discountValueController.text.isEmpty) {
                            ToastWidget().showToastError(
                                "Please fill both Mobile Number and Discount Value");
                          } else if (_mobileNumberController.text.isEmpty) {
                            ToastWidget()
                                .showToastError("Mobile Number is required");
                          } else if (_mobileNumberController.text.length < 10 &&
                              isCard == false) {
                            ToastWidget()
                                .showToastError("Mobile Number is Incorrect");
                          } else if (_discountValueController.text.isEmpty) {
                            ToastWidget().showToastError(
                                "Please fill the discount value");
                          } else if (_discountValueController.text == "0") {
                            ToastWidget()
                                .showToastError("Redeemed Value Can;t be Zero");
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
                                    vendorAmount = double.parse(
                                        _discountValueController.text);
                                    _customerRedeemdValue =
                                        calculateCustomerRedeemValue(
                                            vendorAmount,
                                            companyCommissionPercentage);
                                    _companyCommission =
                                        calculateCompanyCommissionValue(
                                            _customerRedeemdValue,
                                            vendorAmount);

                                    double companyCommission1 =
                                        (customerWalletBalance * 0.2);

                                    double redeemedAmount =
                                        customerWalletBalance -
                                            companyCommission1;

                                    double possibleAmt = customerWalletBalance -
                                        companyCommission1;

                                    //for Push Notification
                                    //sendNotification(_mobileNumberController.text);

                                    // Check Internet Connection Availability
                                    // var connectivityResult =
                                    //     (Connectivity().checkConnectivity());
                                    // if (connectivityResult ==
                                    //     ConnectivityResult.none) {
                                    //   InternetErrorBottomSheet.show(context);
                                    //   _discountValueController.clear();
                                    //   print(
                                    //       "No internet connection. Please check your connection.");
                                    //   return;
                                    // }

                                    // Customer Wallet Balance Validation..
                                    if (_mobileNumberController.text
                                        .isNotEmpty) if (customerWalletBalance == 0) {
                                      showInsufficientBalanceBottomSheet(
                                          context: context,
                                          customerWalletBalance:
                                              customerWalletBalance,
                                          amount1: minRedemptionAmount,
                                          title: 'Insufficient Wallet Balance ',
                                          title1: '',
                                          title2: '',
                                          isMinimumRedemption: false,
                                          isMaximumRedemption: false,
                                          isWalletBalanceZero: true,
                                          isRewardScreen: false);
                                      setState(() {
                                        isButtonDisabled = false;
                                      });
                                      return;
                                    }

                                    if(minRedemptionAmount > (customerWalletBalance+_customerRedeemdValue)){
                                    print("Second Condition ---------- ${(customerWalletBalance + _customerRedeemdValue)}");

                                      showInsufficientBalanceBottomSheet(
                                          context: context,
                                          customerWalletBalance:
                                          minRedemptionAmount,
                                          amount1: 0.00,
                                          title:
                                          'Insufficient Wallet Balance ',
                                          title1: 'Minimum Redemption Amount ',
                                          title2: 'Available Redemption Amount ',
                                          isMinimumRedemption: false,
                                          isMaximumRedemption: true,
                                          isWalletBalanceZero: false,
                                          isRewardScreen: false);
                                      setState(() {
                                        isButtonDisabled = false;
                                      });
                                      return;
                                    }


                                    //Validate Customer Daily Redemption sum value  with With maxRedemptionAmount Per Day From Comapany Settings
                                    if ((CustomerDailyRedemptionValueSum +
                                            _customerRedeemdValue) >
                                        maxRedemptionAmountPerDay) {
                                      num nm1 = maxRedemptionAmountPerDay -
                                          CustomerDailyRedemptionValueSum;
                                      num nm2 = nm1 * 0.2; // Company Commision
                                      num nm3 = nm1 - nm2;

                                      showInsufficientBalanceBottomSheet(
                                          context: context,
                                          customerWalletBalance:
                                              maxRedemptionAmountPerDay,
                                          amount1: nm3,
                                          title:
                                              'Daily Redemption Limit Reached ',
                                          title1: 'Daily Redemption Limit ',
                                          title2: 'Available Redemption Limit ',
                                          isMinimumRedemption: false,
                                          isMaximumRedemption: true,
                                          isWalletBalanceZero: false,
                                          isRewardScreen: false);
                                      setState(() {
                                        isButtonDisabled = false;
                                      });
                                      return;
                                    }

                                    // Validate customerWalletBalance With Minimum Wallet Balance keep 99
                                    if ((customerWalletBalance -
                                        _customerRedeemdValue) <
                                        minWalletBalance) {
                                      num v1 = customerWalletBalance - _customerRedeemdValue;
                                      num v2 = v1 * 0.2; // Company Commision
                                      num v3 = (v1 - v2) <= minWalletBalance ? 0 : (v1 - v2);

                                      showCustomErrorBottomSheet(
                                        context: context,
                                        title: 'Insufficient Wallet Balance',
                                        messageSpans: [
                                          const TextSpan(
                                              text:
                                                  'Your current wallet balance is '),
                                          TextSpan(
                                            text:
                                                '${customerWalletBalance.toStringAsFixed(2)} rupees',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red),
                                          ),
                                          const TextSpan(text: '. Redeeming '),
                                          TextSpan(
                                            text:
                                                '${vendorAmount.toStringAsFixed(2)} rupees',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red),
                                          ),
                                          const TextSpan(
                                              text:
                                                  ' will bring your balance below the required 99 rupees. The maximum amount you can redeem is '),
                                          TextSpan(
                                            text:
                                                '${v3.toStringAsFixed(2)} rupees',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red),
                                          ),
                                          const TextSpan(
                                              text:
                                                  '. Please adjust your redemption amount to proceed.'),
                                        ],
                                      );
                                      setState(() {
                                        isButtonDisabled = false;
                                      });
                                      return;
                                    }

                                    //Validate Customer redemption  amount after calcilating Vendor Amount plus Comapany Commision
                                    if (redeemedAmount < vendorAmount) {
                                      showInsufficientBalanceBottomSheet(
                                          context: context,
                                          customerWalletBalance:
                                              customerWalletBalance,
                                          amount1: possibleAmt,
                                          title: 'Insufficient Wallet Balance ',
                                          title1: 'Current Wallet Balance ',
                                          title2: 'Possible Redemtion Amount ',
                                          isMinimumRedemption: false,
                                          isMaximumRedemption: false,
                                          isWalletBalanceZero: false,
                                          isRewardScreen: false);
                                      setState(() {
                                        isButtonDisabled = false;
                                      });
                                      return;
                                    }
                                    moveToOtp(context);
                                  },
                                  onNoPressed: () {
                                    _mobileNumberController.clear();
                                    _discountValueController.clear();
                                    customerName = '';
                                    setState(() {
                                      isButtonDisabled = true;
                                    });
                                  },
                                );
                              },
                            );

                            // postRedeem();

                            // postRedeem().then((value) {
                            //   setState(() {
                            //     isButtonDisabled = false;
                            //   });
                            // });
                          }
                        }
                      : null,
                  btnText: "REDEEM POINT",
                  bgc: const Color(0xfff05a28),
                  height: 52,
                  width: double.infinity,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void scanQrCode() async {
    try {
      setState(() {
        isButtonDisabled = false;
        isScannerOpen = true;
      });
      var qrCode = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666",
        "Cancel",
        true,
        ScanMode.QR,
      );
      if (!mounted) return;

      setState(() {
        isButtonDisabled = true;
        if (qrCode != "-1") {
          String formattedQrCode = qrCode.replaceAll(' ', '');
          _mobileNumberController.text = formattedQrCode;
          _discountValueController.clear();
          isButtonDisabled = false;
          checkCustomerIsEligibleByCard();
          isButtonDisabled = true;
          isScannerOpen = false;
        } else {
          _mobileNumberController.clear();
          isScannerOpen = true;
        }
        isButtonDisabled = false;
        isScannerOpen = true;
      });
    } catch (e) {
      setState(() {
        isButtonDisabled = false;
        isScannerOpen = true;
      });

      // Handle any errors here
      print('Error occurred while scanning QR code: $e');
    }
  }

  // void scanQrCode() async {
  //   try {
  //     isButtonDisabled = false;
  //     var qrCode = await FlutterBarcodeScanner.scanBarcode(
  //       "#ff6666",
  //       "Cancel",
  //       true,
  //       ScanMode.QR,
  //     );
  //     if (mounted) {
  //       isButtonDisabled = true;
  //       if (qrCode != "-1") {
  //         setState(() {
  //           _mobileNumberController.text = qrCode;
  //           _discountValueController.clear();
  //           isButtonDisabled = false;
  //           checkCustomerIsEligibleByCard();
  //           isButtonDisabled = true;
  //           isScannerOpen = true;
  //         });
  //       } else {
  //         _mobileNumberController.clear();
  //         isScannerOpen = false;
  //       }
  //       isButtonDisabled = false;
  //     }

  //     // Handle cancel button press
  //     // if (qrCode == '-1') {
  //     //   // Treat as empty result
  //     //   qrCode = '';
  //     // }

  //     // if (!mounted || qrCode == '-1') return;

  //     // setState(() {
  //     //   _mobileNumberController.text = qrCode;
  //     //   checkCustomerIsEligibleByCard();
  //     //   // _fetchCustomerDeatilsByCard();
  //     //   isScannerOpen = false;
  //     // });

  //     print("QR Code Result :>>> $qrCode");
  //   } on PlatformException catch (e) {
  //     if (e is SocketException) {
  //       InternetErrorBottomSheet.show(context);
  //     }
  //     if (e.code == -1) {
  //       ToastWidget().showToastError('No QR code found');
  //     } else {}
  //   }
  // }

  void moveToOtp(BuildContext context) {
    int smsType = getSMSType(SMSType.customerRedemption);
    apiService.getOtp(
      otpMobileNo.toString(),
      context,
      smsType.toString(),
      fromResetScreen: false,
      fromRedeemScreen: true,
      onOtpVerified: () {
        postRedeem();
      },
    );
  }

  // void scanQrCode() async {
  //   try {
  //     final qrCode = await FlutterBarcodeScanner.scanBarcode(
  //         "#ff6666", "Cancel", true, ScanMode.QR);

  //     if (!mounted) return;

  //     setState(() {
  //       _mobileNumberController.text = qrCode;
  //       checkCustomerIsEligibleByCard();
  //       isScannerOpen = false;
  //     });

  //     print("QR Code Result :>>> $qrCode");
  //   } on PlatformException {
  //     ToastWidget().showToastError('No QR code found');
  //   }
  // }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _mobileNumberFocused.dispose();
    _discountValueFocused.dispose();
  }
}
