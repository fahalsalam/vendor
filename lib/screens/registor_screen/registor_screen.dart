import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:page_transition/page_transition.dart';
import 'package:vendor/Utils/constants.dart';
import 'package:vendor/Utils/custom_error_bottomsheet.dart';
import 'package:vendor/Utils/smsTypes.dart';
import 'package:vendor/Utils/toast_widget.dart';
import 'package:vendor/models/vendor_model.dart';
import 'package:vendor/screens/sign_in_screen/api_service.dart';
import 'package:vendor/screens/sign_in_screen/sign_in_screen.dart';
import 'package:vendor/screens/terms_and_conditions/terms_and_conditions.dart';
import 'package:vendor/widgets/custom_button.dart';
import 'package:vendor/widgets/custom_textFeild.dart';

class RegistorScreen extends StatefulWidget {
  final String? mobileNumber;
  final String? vendorId;
  final bool? isScreenFromSignin;
  const RegistorScreen(
      {super.key,
      this.mobileNumber = "",
      this.vendorId = "",
      this.isScreenFromSignin});

  @override
  State<RegistorScreen> createState() => _RegistorScreenState();
}

final ApiService apiService = ApiService();
TextEditingController _vendorIdController = TextEditingController();
TextEditingController _vendorMobileNumberController = TextEditingController();
bool isPasswordVisible = false;
bool isCheckBoxClicked = false;
bool isButtonDisabled = true;

DateTime? currentBackPressTime;

class _RegistorScreenState extends State<RegistorScreen> {
  @override
  void initState() {
    super.initState();
    _vendorIdController.text = widget.vendorId.toString();
    _vendorMobileNumberController.text = widget.mobileNumber.toString();
    isCheckBoxClicked = false;
    // isButtonDisabled = true;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void checkVendor() async {
    String token = Constants().token;
    VendorModel? vendorModel = await apiService.getVendorData(
        token, _vendorMobileNumberController.text, context);
    if (vendorModel != null) {
      switch (vendorModel.vendorActivationStatus) {
        case "ACTIVE VENDOR":
          _handleNewVendorDialog(vendorModel);
          break;
        case "NEW VENDOR":
          // _handleNewVendorDialog(vendorModel);
          break;
        case "INVALID VENDOR":
          _handleInavlidVendorDialog();
          break;
        default:
      }
    }
  }

  Future<bool> onWillPop() async {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      ToastWidget().showToastError("Press back again to exit");
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // var w = MediaQuery.of(context).size.width;
    // var h = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 0,
                        child: Padding(
                            padding: const EdgeInsets.only(
                              left: 10,
                            ),
                            child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              SignInScreen()));
                                },
                                child:
                                    Image.asset("assets/images/ic_back_img.png")
                                // Container()
                                )
                            //  Image.asset("assets/images/ic_back.png",height: 37.h,width: 37.w,)),
                            ),
                      ),
                    ],
                  ),
                  SizedBox(height: 150.h),
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: double.infinity),
                        Container(
                          height: 91.h,
                          width: 201.w,
                          decoration: const BoxDecoration(
                              image: DecorationImage(
                                  image:
                                      AssetImage("assets/images/ic_logo.png"))),
                        ),
                        SizedBox(height: 20.h),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                PageTransition(
                                    child: SignInScreen(),
                                    type: PageTransitionType.leftToRight));
                          },
                          child: Text("Activation",
                              style: TextStyle(
                                fontSize: 2.sp,
                                fontWeight: FontWeight.w700,
                              )),
                        ),
                        const SizedBox(height: 10),
                        Text(
                            "Add your phone number. We’ll send you a\n verification code so we know you’re real",
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xff828282))),
                        // const SizedBox(height: 10),
                        if (widget.isScreenFromSignin != true)
                          SizedBox(height: 10.h),

                        if (widget.isScreenFromSignin != true)
                          TextFeildWidget(
                            height: 52,
                            readOnly: true,
                            enable: false,
                            controller: _vendorIdController,
                            labelText: "Vendor ID",
                          ),
                        SizedBox(height: 10.h),

                        TextFeildWidget(
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                            LengthLimitingTextInputFormatter(10),
                          ],
                          textInputType: TextInputType.number,
                          height: 52,
                          controller: _vendorMobileNumberController,
                          labelText: "Registered Mobile Number",
                          obscureText: false,
                          readOnly:
                              widget.isScreenFromSignin == true ? false : true,
                          enable:
                              widget.isScreenFromSignin == true ? true : false,
                          onChanged: (value) {
                            setState(() {
                              isButtonDisabled = false;
                              if (value.length == 10) {
                                checkVendor();
                              } else {}
                            });
                          },
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: CheckboxListTile(
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: const VisualDensity(
                                    horizontal: -4, vertical: -4),
                                checkboxShape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                contentPadding: EdgeInsets.zero,
                                activeColor: Constants().appColor,
                                value: isCheckBoxClicked,
                                onChanged: (value) {
                                  setState(() {
                                    isCheckBoxClicked = value!;
                                  });
                                },
                                title: GestureDetector(
                                  onTap: () async {
                                    bool userAgreed = await Navigator.push(
                                      context,
                                      PageTransition(
                                        child: TermsAndConditions(),
                                        type: PageTransitionType.leftToRight,
                                      ),
                                    );

                                    if (userAgreed != null && userAgreed) {
                                      setState(() {
                                        isCheckBoxClicked = true;
                                      });
                                    }
                                  },
                                  child: RichText(
                                    text: const TextSpan(
                                      text:
                                          "By providing my phone number, I hereby agree and accept the ",
                                      style: TextStyle(
                                          color: Color(0xff828282),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600),
                                      children: [
                                        TextSpan(
                                          text: "Terms & Condition",
                                          style: TextStyle(
                                              decoration:
                                                  TextDecoration.underline,
                                              color: Color(0xffF05A28)),
                                        ),
                                        TextSpan(
                                          text: " and ",
                                          style: TextStyle(
                                              color: Color(0xff828282),
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        TextSpan(
                                          text: "Privacy Policy",
                                          style: TextStyle(
                                              color: Color(0xffF05A28)),
                                        ),
                                        TextSpan(
                                          text: " in use of the BRAND NAME",
                                          style: TextStyle(
                                              color: Color(0xff828282),
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                // fillColor: MaterialStateProperty.all(Color(0xff828282)),
                              ),
                            ),
                          ],
                        ),
                        CustomButton(
                          height: 50,
                          width: double.infinity,
                          btnText: "ACTIVATE VENDOR",
                          bgc: const Color(0xffF05A28),
                          onPress: () async {
                            //  if (isButtonDisabled) {
                            //   return;
                            // }
                            // setState(() {
                            //   isButtonDisabled = false;
                            // });

                            if (widget.isScreenFromSignin == true) {
                              if (_vendorMobileNumberController.text.length <
                                  10) {
                                ToastWidget().showToastError(
                                    "Mobile Number must be 10 digits.");
                              } else if (_vendorMobileNumberController
                                  .text.isEmpty) {
                                ToastWidget()
                                    .showToastError("Mobile Number is Empty!.");
                              } else if (!isCheckBoxClicked) {
                                ToastWidget().showToastError(
                                    "Please accept Terms and Conditions.");
                              } else {
                                // setState(() {
                                //   isButtonDisabled = false;
                                // });
                                moveToOtp(context);
                                // _vendorMobileNumberController.clear();
                              }
                            } else {
                              // setState(() {
                              //   isButtonDisabled = true;
                              // });
                              if (_vendorIdController.text.isEmpty &&
                                  _vendorMobileNumberController.text.isEmpty) {
                                ToastWidget().showToastError(
                                    "Please fill ID and Mobile Number");
                              } else if (_vendorIdController.text.isEmpty) {
                                ToastWidget().showToastError("ID is empty!");
                              } else if (_vendorMobileNumberController
                                  .text.isEmpty) {
                                ToastWidget()
                                    .showToastError("Mobile Number is Empty!.");
                              } else if (!isCheckBoxClicked) {
                                ToastWidget().showToastError(
                                    "Please accept Terms and Conditions.");
                              } else {
                                int smsType =
                                    getSMSType(SMSType.vendorActivation);
                                apiService.getOtp(
                                    widget.mobileNumber.toString(),
                                    context,
                                    smsType.toString(), // Fahal Changed
                                    fromResetScreen: true,
                                    fromRedeemScreen: false,
                                    onOtpVerified: null);
                                // .then((value) => {
                                //       setState(() {
                                //         isButtonDisabled = false;
                                //       })
                                //     });

                                _vendorMobileNumberController.clear();
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void moveToOtp(BuildContext context) {
    int smsType = getSMSType(SMSType.vendorActivation);
    apiService.getOtp(_vendorMobileNumberController.text.toString(), context,
        smsType.toString(), // Fahal Changed
        fromResetScreen: true,
        fromRedeemScreen: false,
        onOtpVerified: null);
    //     .then((response) {
    //   // Additional logic if needed after the API call is completed

    //   setState(() {
    //     isButtonDisabled =
    //         false; // Enable the button after the operation is completed
    //   });
    // });
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
                "This mobile number is already registered. Would you like to proceed to login ?",
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
                              builder: (context) => SignInScreen(
                                    mobileNumber:
                                        _vendorMobileNumberController.text,
                                    // vendorId: vendorModel.vendorId.toString(),
                                  )),
                        );
                      },
                      child: Text(
                        "Sign in",
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
                        _vendorMobileNumberController.clear();
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
              'Selected vendor is not valid. Please choose an alternative vendor.',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ],
    );
    _vendorMobileNumberController.clear();
    return Future.value();
  }
}
