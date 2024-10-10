// To parse this JSON data, do
//
//     final verificationByCardNumber = verificationByCardNumberFromJson(jsonString);

import 'dart:convert';

List<VerificationByCardNumber> verificationByCardNumberFromJson(String str) =>
    List<VerificationByCardNumber>.from(
        json.decode(str).map((x) => VerificationByCardNumber.fromJson(x)));

String verificationByCardNumberToJson(List<VerificationByCardNumber> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class VerificationByCardNumber {
  String verificationStatus;
  num customerId;
  String customerName;
  num mobileNumber;
  num cardNumber;
  num walletbalance;
  String customerDeviceId;
  String customerSecret;
  num cardActive;
  DateTime cardRenewalDate;

  VerificationByCardNumber({
    required this.verificationStatus,
    required this.customerId,
    required this.customerName,
    required this.mobileNumber,
    required this.cardNumber,
    required this.walletbalance,
    required this.customerDeviceId,
    required this.customerSecret,
    required this.cardActive,
    required this.cardRenewalDate,
  });

  factory VerificationByCardNumber.fromJson(Map<String, dynamic> json) =>
      VerificationByCardNumber(
        verificationStatus: json["verificationStatus"]??"",
        customerId: json["customerID"]??0,
        customerName: json["customerName"]??"",
        mobileNumber: json["mobileNumber"]??0,
        cardNumber: json["cardNumber"]??0,
        walletbalance: json["walletbalance"]??0,
        customerDeviceId: json["customerDeviceID"]??"",
        customerSecret: json["customerSecret"]??"",
        cardActive: json["cardActive"]??0,
        cardRenewalDate: DateTime.parse(json["cardRenewalDate"]),
      );

  Map<String, dynamic> toJson() => {
        "verificationStatus": verificationStatus,
        "customerID": customerId,
        "customerName": customerName,
        "mobileNumber": mobileNumber,
        "cardNumber": cardNumber,
        "walletbalance": walletbalance,
        "customerDeviceID": customerDeviceId,
        "customerSecret": customerSecret,
        "cardActive": cardActive,
        "cardRenewalDate": cardRenewalDate.toIso8601String(),
      };
}
