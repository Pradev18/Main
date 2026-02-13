// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:webview_flutter/webview_flutter.dart';
// import 'dart:convert';
//
// import '../../api_confige.dart';
// import 'homepage.dart';
//
// class payment extends StatefulWidget {
//   final String childamt;
//
//   const payment({super.key, required this.childamt});
//
//   @override
//   State<payment> createState() => _PaymentWebViewState();
// }
//
// class _PaymentWebViewState extends State<payment> {
//   int? amount;
//   String? paymentUrl;
//   late WebViewController _controller;
//
//   @override
//   void initState() {
//     super.initState();
//     amount = int.tryParse(widget.childamt);
//     fetchdataPayment();
//   }
//
//   Future<void> fetchdataPayment() async {
//     try {
//       var response = await http.post(
//         Uri.parse('${ApiConfige.BASE_URL}/expresscheckout/initiateJuspayPayment.php'),
//         body: {
//           'amount': widget.childamt,
//         },
//       );
//
//       print("Sent amount: ${widget.childamt}");
//
//       if (response.statusCode == 200) {
//         print('Payment data fetched successfully: ${response.body}');
//
//         // Assuming the API returns a JSON with a key 'payment_url'
//         var jsonData = json.decode(response.body);
//         if (jsonData['paymentLinks'] != null && jsonData['paymentLinks']['web'] != null) {
//           setState(() {
//             paymentUrl = jsonData['paymentLinks']['web']; // Use the web URL from the API response
//           });
//         } else {
//           print('Payment URL is missing from the response');
//         }
//       } else {
//         print('Failed to fetch payment data');
//       }
//     } catch (e) {
//       print('Exception while fetching payment data: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Payment Page'),
//         backgroundColor: Colors.orange,
//       ),
//       body: paymentUrl == null
//           ? const Center(child: CircularProgressIndicator())
//           : WebViewWidget(
//         controller: WebViewController()
//           ..setJavaScriptMode(JavaScriptMode.unrestricted)
//           ..setNavigationDelegate(
//             NavigationDelegate(
//                 onPageStarted: (String url) {
//                   print('Navigating to: $url');
//
//                   if (url.contains('handleJuspayResponse.php')) {
//                     // ✅ Assuming this is your final success or completion URL
//                     Navigator.of(context).pushAndRemoveUntil(
//                       MaterialPageRoute(builder: (context) => HomePage()), // Replace with your actual Home screen
//                           (Route<dynamic> route) => false,
//                     );
//
//                     // Show a message after navigation
//                     Future.delayed(Duration(milliseconds: 300), () {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text("Payment Process Completed!"),
//                           backgroundColor: Colors.green,
//                         ),
//                       );
//                     });
//                   }
//                 }
//
//             ),
//           )
//           ..loadRequest(Uri.parse(paymentUrl!)),
//       )
//
//     );
//   }
// }
