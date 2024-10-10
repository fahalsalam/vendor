// To parse this JSON data, do
//
//     final userVerificationModel = userVerificationModelFromJson(jsonString);

import 'dart:convert';

UserVerificationModel userVerificationModelFromJson(String str) =>
    UserVerificationModel.fromJson(json.decode(str));

String userVerificationModelToJson(UserVerificationModel data) =>
    json.encode(data.toJson());

class UserVerificationModel {
  String verificationStatus;
  int customerID;
  String customerName;
  int mobileNumber;
  int cardNumber;
  num walletbalance;
  String customerDeviceId;
  String customerSecret;
  int cardActive;
  DateTime cardRenewalDate;
  num customerDailyLimit;
  num maxRedemptionAmountPerDay;
  num minRedemptionAmount;
  num minWalletBalance;



  UserVerificationModel({
    required this.verificationStatus,
    required this.customerID,
    required this.customerName,
    required this.mobileNumber,
    required this.cardNumber,
    required this.walletbalance,
    required this.customerDeviceId,
    required this.customerSecret,
    required this.cardActive,
    required this.cardRenewalDate,
    required this.customerDailyLimit,
    required this.maxRedemptionAmountPerDay,
    required this.minRedemptionAmount,
    required this.minWalletBalance,
  });

  factory UserVerificationModel.fromJson(Map<String, dynamic> json) =>
      UserVerificationModel(
        verificationStatus: json["verificationStatus"],
        customerID: json["customerID"],
        customerName: json["customerName"],
        mobileNumber: json["mobileNumber"],
        cardNumber: json["cardNumber"],
        walletbalance: json["walletbalance"],
        customerDeviceId: json["customerDeviceID"],
        customerSecret: json["customerSecret"],
        cardActive: json["cardActive"],
        cardRenewalDate: DateTime.parse(json["cardRenewalDate"]),
        customerDailyLimit: json["customerDailyLimit"],
        maxRedemptionAmountPerDay: json["maxRedemptionAmountPerDay"],
        minRedemptionAmount: json["minRedemptionAmount"],
        minWalletBalance: json["minWalletBalance"] ?? 0.00,
      );

  Map<String, dynamic> toJson() => {
        "verificationStatus": verificationStatus,
        "customerID": customerID,
        "customerName": customerName,
        "mobileNumber": mobileNumber,
        "cardNumber": cardNumber,
        "walletbalance": walletbalance,
        "customerDeviceID": customerDeviceId,
        "customerSecret": customerSecret,
        "cardActive": cardActive,
        "cardRenewalDate": cardRenewalDate.toIso8601String(),
        "customerDailyLimit": customerDailyLimit,
        "maxRedemptionAmountPerDay": maxRedemptionAmountPerDay,
        "minRedemptionAmount": minRedemptionAmount,
        "minWalletBalance": minWalletBalance,
  };
}
