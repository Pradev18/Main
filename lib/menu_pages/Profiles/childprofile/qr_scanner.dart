import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../api_confige.dart';

class QRScanner extends StatefulWidget {
  final String childId;
  final String action;

  const QRScanner({super.key, required this.childId, required this.action});

  @override
  _QRScannerState createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? result;
  bool isProcessing = false; // Flag to prevent multiple API calls

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    await Permission.camera.request();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> attendence(String vehicleNumber) async {
    if (isProcessing) return; // Prevent further API calls if one is already in process
    isProcessing = true;

    try {
      Response response = await post(
        Uri.parse('${ApiConfige.BASE_URL}/make_self_attendance.php'),
        body: {
          'pickup_drop': widget.action,
          'child_id': widget.childId,
          'latitude': '',
          'longitude': '',
          'attendance_type': 'P',
          'vehicle': vehicleNumber,
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        print(data);
        print("vnumber : $vehicleNumber");
        var errorMsg = data['error_msg'] ?? 'Unknown error';
        if (data['success_code'] == 1) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              Future.delayed(Duration(seconds: 2), () {
                // Navigator.of(context).pop(true);
                Navigator.of(context).pop();// Close the dialog
              });
              return AlertDialog(
                title: Center(
                  child: Container(
                    height: 50,
                    width: 50,
                    child: Image.asset('assets/rightgreen.png'),
                  ),
                ),
                content: Text('Attendance completed', textAlign: TextAlign.center),
                backgroundColor: Colors.white,
              );
            },
          );
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              Future.delayed(Duration(seconds: 2), () {
                Navigator.of(context).pop();// Close the dialog
              });
              return AlertDialog(
                title: Center(child: Image.asset('assets/error.png')),
                content: Text(errorMsg, textAlign: TextAlign.center),
                // actions: [
                //   TextButton(
                //     onPressed: () {
                //       Navigator.of(context).pop();
                //     },
                //     child: Text('OK'),
                //   ),
                // ],
                backgroundColor: Colors.white,
              );
            },
          );
        }
      } else {
        print('Failed');
      }
    } catch (e) {
      print(e.toString());
    } finally {
      isProcessing = false; // Reset the flag after the API call is done
      controller?.resumeCamera(); // Resume camera after processing

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          buildHeaderSection(),
          Expanded(child: buildScanner()),
        ],
      ),
    );
  }

  Widget buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.only(top: 46, left: 16, right: 16, bottom: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(width: 1, color: const Color(0xFFE1E1E1)),
              ),
              child: Center(
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: AssetImage('assets/Alt Arrow Left.png'),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Scanner',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    height: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildScanner() {
    return Column(
      children: <Widget>[
        Expanded(
          flex: 5,
          child: QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
          ),
        ),
        // Expanded(
        //   flex: 1,
        //   child: Center(
        //     child: Text(result != null ? 'Result: $result' : 'Scan a QR code'),
        //   ),
        // ),
      ],
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!isProcessing) {
        setState(() {
          result = scanData.code;
        });

        controller.pauseCamera(); // Pause the camera after scanning

        // Extract the vehicle number from the scanned QR code URL
        final uri = Uri.parse(result!);
        final vehicleNumber = uri.queryParameters['vehicle'];

        if (vehicleNumber != null) {
          attendence(vehicleNumber); // Trigger the API call with the vehicle number
        } else {
          // Show an alert dialog if the vehicle number is not found
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Center(child: Image.asset('assets/error.png')),
                content: Text('Invalid QR Code\n Scan a valid QR code, please.', textAlign: TextAlign.center),
                // title: Text(),
                // content: Text(),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      controller.resumeCamera(); // Resume camera to allow another scan
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      }
    }, onError: (error) {
      print("Error in scanning: $error");
    });
  }



}
