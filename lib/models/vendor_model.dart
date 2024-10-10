// To parse this JSON data, do
//
//     final vendorModel = vendorModelFromJson(jsonString);

import 'dart:convert';

VendorModel vendorModelFromJson(String str) =>
    VendorModel.fromJson(json.decode(str));

String vendorModelToJson(VendorModel data) => json.encode(data.toJson());

class VendorModel {
  String? vendorActivationStatus;
  num? vendorId;
  num? vendorWalletBalance;
  String? vendorBusinessName;
  String? vendorBranchName;
  num? vendorRegisteredMobileNumber;
  String? vendorContactPersonName;
  String? vendorSecret;
  String? vendorAddressL1;
  String? vendorAddressL2;
  num? vendorPinCode;
  String? vendorEmail;
  String? vendorWebUrl;
  String? vendorLogoUrl;
  bool? iSvendorActive;

  VendorModel({
    this.vendorActivationStatus,
    this.vendorId,
    this.vendorWalletBalance,
    this.vendorBusinessName,
    this.vendorBranchName,
    this.vendorRegisteredMobileNumber,
    this.vendorContactPersonName,
    this.vendorSecret,
    this.vendorAddressL1,
    this.vendorAddressL2,
    this.vendorPinCode,
    this.vendorEmail,
    this.vendorWebUrl,
    this.vendorLogoUrl,
    this.iSvendorActive,
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) => VendorModel(
        vendorActivationStatus: json["vendorActivationStatus"] ?? "",
        vendorId: json["vendorId"] ?? 0,
        vendorWalletBalance: json["vendorWalletBalance"] ?? 0,
        vendorBusinessName: json["vendorBusinessName"] ?? "",
        vendorBranchName: json["vendorBranchName"] ?? "",
        vendorRegisteredMobileNumber: json["vendorRegisteredMobileNumber"] ?? 0,
        vendorContactPersonName: json["vendorContactPersonName"] ?? "",
        vendorSecret: json["vendorSecret"] ?? "",
        vendorAddressL1: json["vendorAddressL1"] ?? "",
        vendorAddressL2: json["vendorAddressL2"] ?? "",
        vendorPinCode: json["vendorPinCode"] ?? 0,
        vendorEmail: json["vendorEmail"] ?? '',
        vendorWebUrl: json["vendorWebUrl"] ?? "",
        vendorLogoUrl: json["vendorLogoUrl"] ?? "",
        iSvendorActive: json["iSvendorActive"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "vendorActivationStatus": vendorActivationStatus,
        "vendorId": vendorId,
        "vendorWalletBalance": vendorWalletBalance,
        "vendorBusinessName": vendorBusinessName,
        "vendorBranchName": vendorBranchName,
        "vendorRegisteredMobileNumber": vendorRegisteredMobileNumber,
        "vendorContactPersonName": vendorContactPersonName,
        "vendorSecret": vendorSecret,
        "vendorAddressL1": vendorAddressL1,
        "vendorAddressL2": vendorAddressL2,
        "vendorPinCode": vendorPinCode,
        "vendorEmail": vendorEmail,
        "vendorWebUrl": vendorWebUrl,
        "vendorLogoUrl": vendorLogoUrl,
        "iSvendorActive": iSvendorActive,
      };
}
