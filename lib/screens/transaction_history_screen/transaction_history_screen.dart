import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:vendor/Utils/SharedPreferences.dart';
import 'package:vendor/Utils/constants.dart';
import 'package:vendor/Utils/toast_widget.dart';
import 'package:vendor/Utils/transaction_icon.dart';
import 'package:vendor/Utils/urls.dart';
import 'package:vendor/models/vendor_transaction%20_model.dart';
import 'package:vendor/screens/my_drawer/my_drawer.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({Key? key}) : super(key: key);

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  List<VendorTransactions> transactions = [];
  bool isLoading = false;
  bool errorOccurred = false;

  DateTime? currentBackPressTime;

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    setState(() {
      errorOccurred = false;
    });

    try {
      EasyLoading.show(
          dismissOnTap: false, maskType: EasyLoadingMaskType.black);
      final token = Constants().token;
      final vendorId = SharedPreference().getVendorId();

      transactions = await getVendorTransactions(token, vendorId);
    } catch (e) {
      if (e is SocketException) {}
      setState(() {
        errorOccurred = true;
      });
    } finally {
      setState(() {
        EasyLoading.dismiss();
      });
    }
  }

  Future<List<VendorTransactions>> getVendorTransactions(
      String token, String vendorId) async {
    final url = Uri.parse(Urls.vendorTransactions);
    final headers = {
      'Token': token,
      'VendorID': vendorId,
    };

    try {
      EasyLoading.show(
          dismissOnTap: false, maskType: EasyLoadingMaskType.black);
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        // First, decode the response to a Map
        Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Then, access the list inside the map (adjust 'transactions' to match your JSON structure)
        List<dynamic> transactionsJson = jsonResponse['data'];

        // Finally, parse the list of transactions
        List<VendorTransactions> transactions = transactionsJson
            .map((x) => VendorTransactions.fromJson(x))
            .toList();

        return transactions;
      } else {
        throw Exception('Failed to load vendor transactions');
      }
    } catch (error) {
      if (error is SocketException) {}
      throw Exception('Failed to connect to the server');
    } finally {
      EasyLoading.dismiss();
    }
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
        appBar: AppBar(
          title: Text(
            "Transaction History",
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.03,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 0.0,
        ),
        drawer: MyDrawer(),
        body: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text(
                "Recent Transactions",
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.03,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: _buildTransactionList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (errorOccurred) {
      return Center(child: Text('No Transactions yet...'));
    } else if (transactions.isEmpty) {
      return Center(
        child: Text(
          'No Transactions yet...',
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width * 0.03,
            color: Colors.grey,
          ),
        ),
      );
    } else {
      return ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          Color valueColor;

          // Determine color based on TransType
          if (transactions[index].TransType == 'Redemption') {
            valueColor = Colors.green;
          } else if (transactions[index].TransType == 'TopUp') {
            valueColor = Colors.blue; // Color for 'TopUp'
          } else {
            valueColor = Colors.red; // Default color for other types
          }
          return Card(
            margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: MediaQuery.of(context).size.width * 0.05,
                        backgroundColor: valueColor.withOpacity(0.2),
                        child: TransactionIcon(
                          icon: transactions[index].TransType == 'Redemption'
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
                          color: valueColor,
                          isRedemption:
                              transactions[index].TransType == 'Redemption',
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transactions[index].TransType,
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.03,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              transactions[index].TransDate,
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.025,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        transactions[index].Amount.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.03,
                          fontWeight: FontWeight.bold,
                          color: valueColor,
                        ),
                      ),
                    ],
                  ),
                  if (transactions[index].TransType != 'Wallet Top-Up') ...[
                    Divider(color: Colors.grey.shade300, thickness: 1),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Customer Name: ${transactions[index].CustomerName}',
                            style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.03,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Card Number: ${transactions[index].CardNumber}',
                            style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.03,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Mobile No: ${transactions[index].MobileNo}',
                            style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.03,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      );
    }
  }
}
