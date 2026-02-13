import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:gala_travels_app/payment/responcse.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hypersdkflutter/hypersdkflutter.dart';

class PaymentPage extends StatefulWidget {
  final String? childPaymentId;
  final String? parentId;
  final String? childId;
  final HyperSDK hyperSDK;
  final String amount;
  const PaymentPage({Key? key, required this.hyperSDK, required this.amount, this.childId, this.parentId, this.childPaymentId})
      : super(key: key);
  @override
  _PaymentPageState createState() => _PaymentPageState(amount);
}

class _PaymentPageState extends State<PaymentPage> {
  var showLoader = true;
  var processCalled = false;
  var paymentSuccess = false;
  var paymentFailed = false;
  var amount = "0";
  _PaymentPageState(amount) {
    this.amount = amount;
  }

  @override
  Widget build(BuildContext context) {
    if (!processCalled) {
      startPayment(amount);
    }
//block:start:onBackPress
    return WillPopScope(
      onWillPop: () async {
        if (Platform.isAndroid) {
          var backpressResult = await widget.hyperSDK.onBackPress();

          if (backpressResult.toLowerCase() == "true") {
            return false;
          } else {
            return true;
          }
        } else {
          return true;
        }
      },
//block:end:onBackPress
      child: Container(
        color: Colors.white,
        child: Center(
          child: showLoader ? const CircularProgressIndicator() : Container(),
        ),
      ),
    );
  }

  // block:start:startPayment
  void startPayment(amount) async {
    processCalled = true;
    var headers = {
      'Content-Type': 'application/json',
    };

    var requestBody = {
      "parent_id": widget.parentId,
      "child_id": widget.childId,
      "child_payment_id": widget.childPaymentId,

      // Use the amount passed into the function, ensure it's compatible (e.g., double or String as needed by backend)
      "amount": double.tryParse(amount) ?? 0.0 // Or handle parsing appropriately
    };

    try {
      var response = await http.post(
          Uri.parse('https://www.shreegalatoursandtravels.com/api/expresscheckout/initiatePayment.php'),
          headers: headers,
          body: jsonEncode(requestBody));
      print("Sent amount: ${requestBody}");

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        print("------------Response Payload------------\n${jsonEncode(jsonResponse)}\n------------------------------------"); // Log the full response

        var sdkPayload = jsonResponse['sdkPayload'];

        // Check if sdkPayload exists and is a Map
        if (sdkPayload is Map<String, dynamic>) {
          var innerPayload = sdkPayload['payload'];

          // Check if the inner payload exists and is a Map
          if (innerPayload is Map<String, dynamic>) {

            // --- Modification Start ---
            print("--- Passing Inner Payload to openPaymentPage ---");
            print(jsonEncode(innerPayload));
            print("---------------------------------------------");

            // Optional: Ensure amount is a String if native side expects it
            // if (innerPayload.containsKey('amount')) {
            //    innerPayload['amount'] = innerPayload['amount'].toString();
            // }

            widget.hyperSDK.openPaymentPage(sdkPayload, hyperSDKCallbackHandler);
            print("------------------open Payment Page------------------");
            // --- Modification End ---

          } else {
            print("Error: Inner 'payload' within 'sdkPayload' is missing or not a Map.");
            setState(() { showLoader = false; }); // Hide loader on error
            // Handle error appropriately (show message to user, etc.)
          }
        } else {
          print("Error: 'sdkPayload' is missing or not a Map in the response.");
          setState(() { showLoader = false; }); // Hide loader on error
          // Handle error appropriately
        }
      } else {
        print('API call failed with status code ${response.statusCode}');
        print('Response body: ${response.body}');
        setState(() { showLoader = false; }); // Hide loader on error
        // Handle error appropriately
      }
    } catch (e) {
      print("Error during payment initiation: $e");
      setState(() { showLoader = false; }); // Hide loader on error
      // Handle error appropriately
    }
  }
  // block:end:startPayment

  // block:start:create-hyper-callback
  void hyperSDKCallbackHandler(MethodCall methodCall) {
    print(
        'Method Channel triggered for platform view ${methodCall.method}, ${methodCall.arguments}');
    switch (methodCall.method) {
      case "hide_loader":
        setState(() {
          showLoader = false;
        });
        break;
      case "process_result":
        var args = {};

        try {
          args = json.decode(methodCall.arguments);
        } catch (e) {
          print(e);
        }
        var innerPayload = args["payload"] ?? {};
        var status = innerPayload["status"] ?? " ";
        var orderId = args['orderId'];

        switch (status) {
          case "backpressed":
          case "user_aborted":
            {
              Navigator.pop(context);
            }
            break;
          default:
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ResponseScreen(amount: widget.amount),
                    settings: RouteSettings(arguments: orderId)));
        }
    }
  }
// block:end:create-hyper-callback
}
