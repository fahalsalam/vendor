import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vendor/Utils/SharedPreferences.dart';
import 'package:vendor/Utils/constants.dart';
import 'package:vendor/Utils/toast_widget.dart';
import 'package:vendor/Utils/urls.dart';
import 'package:vendor/models/vendor_model.dart';
import 'package:vendor/screens/dashboard/dashboard_screen.dart';
import 'package:vendor/screens/redeem_screen/redeem_screen.dart';
import 'package:vendor/screens/sign_in_screen/sign_in_screen.dart';
import 'package:vendor/screens/transaction_history_screen/transaction_history_screen.dart';
import 'package:http/http.dart' as http;

class MyDrawer extends StatefulWidget {
  const MyDrawer({
    Key? key,
  }) : super(key: key);

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

final Uri _url = Uri.parse('https://bizatom.in/faq/#faq-2301');
String walletBalance = "";
String vendorMobileNumber = "";
num calculatedWalletBalance = 0.0;
String token = Constants().token;
String terms_CoditionUrl = "";
String supportUrl = "";

class _MyDrawerState extends State<MyDrawer> {
  @override
  void initState() {
    super.initState();
    vendorMobileNumber = SharedPreference().getVendorMobileNumber();
    walletBalance = SharedPreference().getVendorWalletBalance();
    getVendor();
    internalUrls();
  }

  Future<void> internalUrls() async {
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
        terms_CoditionUrl = data['Terms_Condition_Url'];
        supportUrl = data['Support_Url'];
      }
    } else {
      // Handle error response
      print('Failed to load config');
    }
  }

  void getVendor() async {
    try {
      final vendorData = await getVendorData(token, vendorMobileNumber);
      if (vendorData != null) {
        setState(() {
          calculatedWalletBalance =
              num.parse(vendorData.vendorWalletBalance.toString());
        });
      }
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
    if (kDebugMode) {
      print("Headers:>>>$headers");
      print("Headers:>>>$registeredVendorMobileNumber");
    }
    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (kDebugMode) {
          print("Response from drawer:>>>$jsonResponse");
        }
        return VendorModel.fromJson(jsonResponse);
      } else {
        // Handle error response
        if (kDebugMode) {
          print('API request failed with status ${response.statusCode}');
        }
        return null;
      }
    } catch (e) {
      if (e is SocketException) {}
      // Handle network or other errors
      if (kDebugMode) {
        print('Error during API request: $e');
      }
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    String vendorBusinessName = SharedPreference().getVendorBussinessName();
    String firstLetter =
        vendorBusinessName.isNotEmpty ? vendorBusinessName[0] : "";

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Constants().appColor,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 35.r,
                  backgroundColor: Colors.grey.shade200,
                  child: Text(
                    firstLetter,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
                SizedBox(width: 15.w),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vendorBusinessName,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      // Text(
                      //   "${SharedPreference().getVendorBranchName()}, City, District, ${SharedPreference().getVendorPinCode()}",
                      //   style: TextStyle(
                      //     fontSize: 14.sp,
                      //     color: Colors.white70,
                      //   ),
                      // ),
                      Text(
                        "${SharedPreference().getVendorMobileNumber()}",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.account_balance_wallet, size: 30.sp),
            title: Text(
              "Wallet Balance: ${calculatedWalletBalance.toStringAsFixed(2)}",
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
            ),
          ),
          _buildDrawerItem(
            icon: Icons.card_giftcard,
            text: "Rewards",
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const DashBoardScreen(),
              ));
            },
          ),
          _buildDrawerItem(
            icon: Icons.redeem,
            text: "Redeem",
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const RedeemScreen(),
              ));
            },
          ),
          _buildDrawerItem(
            icon: Icons.history,
            text: "History",
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const TransactionHistoryScreen(),
              ));
            },
          ),
          _buildDrawerItem(
            icon: Icons.policy,
            text: "Terms & Conditions",
            onTap: () {
              Navigator.pop(context);
              _launchInWebView(Uri.parse(terms_CoditionUrl));
            },
          ),
          _buildDrawerItem(
            icon: Icons.support_agent,
            text: "Support",
            onTap: () {
              Navigator.pop(context);
              _launchInWebView(Uri.parse(supportUrl));
            },
          ),
          _buildDrawerItem(
            icon: Icons.logout,
            text: "Log Out",
            onTap: _handleSignOutDialog,
          ),
          SizedBox(height: 20.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Text(
                    'Version: ${snapshot.data!.version}',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                  );
                } else {
                  return SizedBox();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      {required IconData icon,
      required String text,
      required GestureTapCallback onTap}) {
    return ListTile(
      leading: Icon(icon, size: 28.sp),
      title: Text(
        text,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
    );
  }

  Future<void> _launchInWebView(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.inAppWebView)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<dynamic> _handleSignOutDialog() {
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
                Icons.exit_to_app,
                color: Colors.red,
                size: isLandscape ? screenHeight * 0.08 : screenHeight * 0.06,
              ),
              SizedBox(height: screenHeight * 0.015),
              Text(
                "Sign Out",
                style: TextStyle(
                  color: Colors.black,
                  fontSize:
                      isLandscape ? screenHeight * 0.025 : screenHeight * 0.02,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.015),
              Text(
                "Are you sure you want to sign out?",
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
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.015),
                      ),
                      onPressed: () {
                        _signOut();
                      },
                      child: Text(
                        "Sign Out",
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

  void _signOut() {
    SharedPreference().setVendorId("");
    SharedPreference().setVendorMobileNumber("");
    SharedPreference().setLoggedIn(false);
    SharedPreference().clearAllData();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
      (route) => false,
    );
  }
}
