import 'dart:convert';

List<VendorTransactions> vendorTransactionsFromJson(String str) =>
    List<VendorTransactions>.from(
        (json.decode(str) as List<dynamic>).map<VendorTransactions>((x) => VendorTransactions.fromJson(x as Map<String, dynamic>)));

String vendorTransactionsToJson(List<VendorTransactions> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class VendorTransactions {
  dynamic TransType;
  dynamic TransDate;
  dynamic CustomerName;
  dynamic MobileNo;
  dynamic CardNumber;
  dynamic Amount;

  VendorTransactions({
    required this.TransType,
    required this.TransDate,
    required this.Amount,
    required this.CustomerName,
    required this.MobileNo,
    required this.CardNumber,
  });

  factory VendorTransactions.fromJson(Map<String, dynamic> json) =>
      VendorTransactions(
        TransType: json["TransType"],
        TransDate: json["TransDate"],
        Amount: json["Amount"],
        CustomerName: json["CustomerName"],
        MobileNo: json["MobileNo"],
        CardNumber: json["CardNumber"],
      );

  Map<String, dynamic> toJson() => {
    "TransType": TransType,
    "TransDate": TransDate,
    "Amount": Amount,
    "CustomerName": CustomerName,
    "MobileNo": MobileNo,
    "CardNumber": CardNumber,
  };
}
