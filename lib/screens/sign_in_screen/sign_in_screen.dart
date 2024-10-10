import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vendor/Utils/SharedPreferences.dart';
import 'package:vendor/Utils/constants.dart';
import 'package:vendor/Utils/custom_alert_dialogue.dart';
import 'package:vendor/Utils/custom_dialoge_box.dart';
import 'package:vendor/Utils/custom_error_bottomsheet.dart';
import 'package:vendor/Utils/toast_widget.dart';
import 'package:vendor/models/vendor_model.dart';
import 'package:vendor/screens/dashboard/dashboard_screen.dart';
import 'package:vendor/screens/registor_screen/registor_screen.dart';
import 'package:vendor/screens/sign_in_screen/api_service.dart';
import 'package:vendor/widgets/custom_button.dart';
import 'package:vendor/widgets/custom_textFeild.dart';
import 'package:http/http.dart' as http;

import '../../Utils/urls.dart';

class SignInScreen extends StatefulWidget {
  final String? mobileNumber;
  const SignInScreen({super.key, this.mobileNumber = ""});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

bool isPasswordVisible = false;
bool isCheckBoxClicked = false;
bool isScreenFromSignin = false;
bool isUserChecking = true;
String? bizVendorVersion;

class _SignInScreenState extends State<SignInScreen> {
  final ApiService apiService = ApiService();
  final TextEditingController _vendorPhoneNumberController =
      TextEditingController();

  final TextEditingController _vendorPasswordController =
      TextEditingController();

  FocusNode? _vendorIdfocusNode;
  FocusNode? _passwordfocusNode;

  DateTime? currentBackPressTime;

  @override
  void initState() {
    super.initState();
    _passwordfocusNode = FocusNode();
    _vendorIdfocusNode = FocusNode();
    _vendorPhoneNumberController.text = widget.mobileNumber.toString();
  }

  @override
  void dispose() {
    super.dispose();
    _passwordfocusNode?.dispose();
    _vendorIdfocusNode?.dispose();
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

  void checkVendor() async {
    String token = Constants().token;
    VendorModel? vendorModel = await apiService.getVendorData(
        token, _vendorPhoneNumberController.text, context);
    if (vendorModel != null) {
      switch (vendorModel.vendorActivationStatus) {
        case "NEW VENDOR":
          _handleNewVendorDialog(vendorModel);
          break;
        case "INVALID VENDOR":
          _handleInvalideVendorDialog();
          break;
        case "BLOCK VENDOR":
          Flushbar(
            message:
                'Your account is blocked. Please contact support for assistance.',
            backgroundColor: Colors.red,
            flushbarPosition: FlushbarPosition.TOP,
            duration: Duration(seconds: 5),
            icon: Icon(
              Icons.error,
              color: Colors.white,
            ),
          ).show(context);
          _vendorPhoneNumberController.clear();
        case "INACTIVE VENDOR":
          Flushbar(
            message:
                'Your account is inactive. Please contact support to reactivate.',
            backgroundColor: Colors.red,
            flushbarPosition: FlushbarPosition.TOP,
            duration: Duration(seconds: 5),
            icon: Icon(
              Icons.error,
              color: Colors.white,
            ),
          ).show(context);
          _vendorPhoneNumberController.clear();
        default:
      }
    }
    setState(() {
      isUserChecking = false;
    });
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

  void signIn() async {
    String token = Constants().token;

    VendorModel? vendorModel = await apiService.getVendorData(
        token, _vendorPhoneNumberController.text, context);

    if (vendorModel != null) {
      if (kDebugMode) {
        print("Vendor ID: ${vendorModel.vendorId}");
        print("Vendor Name: ${vendorModel.vendorBusinessName}");
      }
      switch (vendorModel.vendorActivationStatus) {
        case "ACTIVE VENDOR":
          SharedPreference().setVendorActivated(true);
          SharedPreference().setLoggedIn(true);
          SharedPreference().setVendorWalletBalance(
              vendorModel.vendorWalletBalance.toString());
          SharedPreference().setVendorId(vendorModel.vendorId.toString());
          SharedPreference().setVendorBussinessName(
              vendorModel.vendorBusinessName.toString());
          SharedPreference()
              .setVendorBranchName(vendorModel.vendorBranchName.toString());
          SharedPreference()
              .setVendorPinCode(vendorModel.vendorPinCode.toString());
          SharedPreference()
              .setVendorAddressL1(vendorModel.vendorAddressL1.toString());
          SharedPreference().setVendorMobileNumber(
              vendorModel.vendorRegisteredMobileNumber.toString());
          if (vendorModel.vendorSecret == _vendorPasswordController.text) {
            _reDirectToDashboardScreen();
          } else {
            ToastWidget().showToastError("Please check your password");
          }

          break;
        case "NEW VENDOR":
          _reDirectToRegistorScreen();
          break;
        case "INVALID VENDOR":
          _handleInavlidVendorDialog();
          break;
        default:
          if (kDebugMode) {
            print("Unknown vendorActivationStatus");
          }
      }
    } else {
      if (kDebugMode) {
        print("API call failed");
      }
    }
  }

  Future<bool> onWillPop() async {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      ToastWidget().showToastError("Press back again to exit");
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  const SizedBox(width: double.infinity),
                  Container(
                    height: 91.h,
                    width: 201.w,
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("assets/images/ic_logo.png"))),
                  ),
                  SizedBox(height: 20.h),
                  Text("Sign in",
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                      )),
                  Text(
                      "Add your phone number. We’ll send you a\n verification code so we know you’re real",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff828282))),
                  SizedBox(height: 10.h),
                  TextFeildWidget(
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                      LengthLimitingTextInputFormatter(10),
                    ],
                    textInputType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    onChanged: (val) {
                      setState(() {
                        _vendorPhoneNumberController.text = val;
                        if (val.length == 10) {
                          checkVendor();
                        }
                      });
                    },
                    controller: _vendorPhoneNumberController,
                    labelText: "Mobile Number",
                    focusNode: _vendorIdfocusNode,
                  ),
                  SizedBox(height: 10.h),
                  TextFeildWidget(
                    textInputAction: TextInputAction.done,
                    controller: _vendorPasswordController,
                    focusNode: _passwordfocusNode,
                    labelText: "Password",
                    obscureText: !isPasswordVisible ? true : false,
                    suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                        child: Icon(!isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility)),
                  ),
                  // Checkbox(
                  //   materialTapTargetSize: MaterialTapTargetSize
                  //         .shrinkWrap, // Removes default tap target padding
                  //     visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                  //   value: false, onChanged: (val){}),
                  Row(
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity:
                              const VisualDensity(horizontal: -4, vertical: -4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          contentPadding: EdgeInsets.zero,
                          value: isCheckBoxClicked,
                          dense: true,
                          activeColor: Constants().appColor,
                          onChanged: (value) {
                            setState(() {
                              isCheckBoxClicked = value!;
                            });
                          },
                          title: Text("Remember me",
                              style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xff828282))),
                          controlAffinity: ListTileControlAffinity.leading,

                          // fillColor: MaterialStateProperty.all(Color(0xff828282)),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return const CustomDialogBox(
                                  title: "Custom Dialog Demo",
                                  descriptions:
                                      "Hii all this is a custom dialog in flutter and  you will be use in your flutter applications",
                                  text: "Yes",
                                  img: "",
                                );
                              });
                        },
                        child: Text("Forget your password?",
                            style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xff828282))),
                      )
                    ],
                  ),
                  CustomButton(
                    height: 52,
                    width: double.infinity,
                    btnText: "SIGN IN",
                    bgc: const Color(0xffF05A28),
                    onPress: () {
                      if (_vendorPhoneNumberController.text.isEmpty &&
                          _vendorPasswordController.text.isEmpty) {
                        ToastWidget().showToastError(
                            "Both feilds are empty, Please fill phone Number and Password");
                      } else if (_vendorPhoneNumberController.text.isEmpty) {
                        ToastWidget().showToastError(
                            "Phone Number  is Empty, Please Fill it out");
                      } else if (_vendorPasswordController.text.isEmpty) {
                        ToastWidget().showToastError(
                            "Password is Empty, Please Fill it out");
                      } else {
                        signIn();
                      }

                      // Navigator.push(
                      //     context,
                      //     PageTransition(
                      //         type: PageTransitionType.leftToRight,
                      //         child: const RegistorScreen()));
                    },
                  ),
                  const Spacer(),
                  Visibility(
                    // visible: !isActivated! ?? false,
                    child: Padding(
                      padding: EdgeInsets.only(top: 20.h),
                      child: Align(
                        alignment: Alignment.center,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => const RegistorScreen(
                                        isScreenFromSignin: true)));
                            // Navigator.pop(context, true);
                            // Navigator.push(
                            //     context,
                            //     PageTransition(
                            //         type: PageTransitionType.rightToLeft,
                            //         child: RegisterScreen()));
                          },
                          child: Text(
                            "New User? Sign Up!",
                            style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Constants().grayColor,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // if (!_passwordfocusNode!.hasFocus && !_vendorIdfocusNode!.hasFocus)
              //   Positioned(
              //     bottom: 0,
              //     left: 0,
              //     right: 0,
              //     child: Column(
              //       mainAxisAlignment: MainAxisAlignment.end,
              //       children: [
              //         const Text("For vendor activation",
              //             style: TextStyle(
              //                 fontSize: 15,
              //                 fontWeight: FontWeight.w600,
              //                 color: Color(0xff828282))),
              //         const SizedBox(height: 10),
              //         CustomButton(
              //           height: 50,
              //           width: double.infinity,
              //           btnText: "ACTIVATE VENDOR",
              //           bgc: const Color.fromARGB(255, 3, 2, 2),
              //           onPress: () {},
              //         ),
              //       ],
              //     ),
              //   )
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> _handleInvalideVendorDialog() {
    showCustomErrorBottomSheet(
      context: context,
      title: 'Invalid Vendor',
      messageSpans: [
        TextSpan(
          text:
              'Selected vendor is not valid. Please choose an alternative vendor.',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ],
    );
    // _vendorPhoneNumberController.clear();
    return Future.value();
  }

  Future<dynamic> _handleNewVendorDialog(VendorModel vendorModel) {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        final mediaQuery = MediaQuery.of(context);
        final screenHeight = mediaQuery.size.height;
        final screenWidth = mediaQuery.size.width;
        final isLandscape = mediaQuery.orientation == Orientation.landscape;

        return Container(
          padding: EdgeInsets.all(screenWidth * 0.04),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_add,
                color: Constants().appColor,
                size: isLandscape ? screenHeight * 0.08 : screenHeight * 0.06,
              ),
              SizedBox(height: screenHeight * 0.015),
              Text(
                "New Activation",
                style: TextStyle(
                  color: Colors.black,
                  fontSize:
                      isLandscape ? screenHeight * 0.025 : screenHeight * 0.02,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.015),
              Text(
                "Mobile number not activated. Would you like to proceed to activate ?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize:
                      isLandscape ? screenHeight * 0.02 : screenHeight * 0.018,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Constants().appColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.015),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegistorScreen(
                              mobileNumber: _vendorPhoneNumberController.text,
                              vendorId: vendorModel.vendorId.toString(),
                            ),
                          ),
                        );
                      },
                      child: Text(
                        "Activate",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isLandscape
                              ? screenHeight * 0.02
                              : screenHeight * 0.018,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[700]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.015),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _vendorPhoneNumberController.clear();
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.grey[700]!,
                          fontSize: isLandscape
                              ? screenHeight * 0.02
                              : screenHeight * 0.018,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<dynamic> _handleInavlidVendorDialog() {
    showCustomErrorBottomSheet(
      context: context,
      title: 'Invalid Vendor',
      messageSpans: [
        TextSpan(
          text:
              'Credentials not recognized. Please check your information or contact support.',
          style: TextStyle(fontWeight: FontWeight.w400, color: Colors.black),
        ),
      ],
    );
    // _vendorPhoneNumberController.clear();
    return Future.value();
  }

  void _reDirectToDashboardScreen() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const DashBoardScreen()));
  }

  void _reDirectToRegistorScreen() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const RegistorScreen()));
  }
}
