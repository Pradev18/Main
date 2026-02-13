import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../menu_pages/menubar.dart';
import 'app_bar.dart';

class ResponseScreen extends StatelessWidget {
  final String amount;
  const ResponseScreen({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    final orderId = ModalRoute.of(context)!.settings.arguments;
    var screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
        onWillPop: () async {
          // Navigate to the home page (Menubar)
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Menubar()),
                (route) => false, // Clears all previous routes
          );
          return false; // Prevent default back button behavior
        },
    child: Scaffold(
          appBar: customAppBar(text: "Payment Status", context: context),
          body: FutureBuilder(
            future: getPaymentResponse(orderId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                Map<String, dynamic> data =
                snapshot.data as Map<String, dynamic>;
                String orderId = data['order_id'];
                String orderStatus = data['order_status'];
                String orderStatusText = "";
                String statusImageUrl = "";
                if (orderStatus != null) {
                  switch (orderStatus) {
                    case "CHARGED":
                    case "COD_INITIATED":
                      orderStatusText = "Payment Successful \n          ${amount}";
                      statusImageUrl = "assets/paymentSuccess.png";
                      break;
                    case "PENDING_VBV":
                      orderStatusText = "Payment Pending...";
                      statusImageUrl = "assets/pending.png";
                      break;
                    default:
                      orderStatusText = "Payment Failed";
                      statusImageUrl = "assets/paymentFailed.png";
                      break;
                  }
                } else {
                  Navigator.pop(context);
                  Navigator.pop(context);
                }
                return Column(
                  children: [
                     Container(
                      height: screenHeight / 4,
                      margin: const EdgeInsets.only(top: 100.0),
                      child: Image.asset(
                        statusImageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Expanded(
                      flex: 8,
                      child: Center(
                        child: Text(
                          orderStatusText, // Display the payment response
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "Order Id: " +
                              orderId, // Display the payment response
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "Status: " +
                              orderStatus, // Display the payment response
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        ));
  }

  Future<Map<String, dynamic>> getPaymentResponse(order_id) async {
    var headers = {
      'Content-Type': 'application/json',
    };

    // block:start:sendGetRequest
    //10.0.2.2 Works only on emulator
    var response = await http.get(
        Uri.parse(
            'https://www.shreegalatoursandtravels.com/api/expresscheckout/handleResponse.php?order_id=${order_id}'),
        headers: headers);
    // block:end:sendGetRequest

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse;
    } else {
      throw Exception(
          'API call failed with status code ${response.statusCode} ${response.body}');
    }
  }
}
