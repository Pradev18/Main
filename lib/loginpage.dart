import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gala_travels_app/forgot_password.dart';
import 'package:gala_travels_app/menu_pages/constants/constants.dart';
import 'package:gala_travels_app/menu_pages/menubar.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LoginPage extends StatefulWidget {
  final String? schoolId; // Define a field to hold the schoolId

  LoginPage({Key? key, this.schoolId}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController user = TextEditingController();
  TextEditingController pass = TextEditingController();

  bool isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    checkLoggedIn(); // Check login status on initialization
  }

  Future<void> checkLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('loggedIn') && prefs.getBool('loggedIn')!) {
      // If already logged in, navigate to home page
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Menubar()),
        (route) => false,
      );
    }
  }

  Future<void> setLoggedIn(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('loggedIn', value);
  }

  Future<Map<String, dynamic>> parseJsonInIsolate(String responseBody) async {
    return await Isolate.run(() => jsonDecode(responseBody));
  }

  void login(String username, String password) async {
    try {
      Response response = await post(
        Uri.parse(Constants.login),
        body: {
          'parent_email': username,
          'password': password,
          'device_token': Constants.fcmToken,
          'parent_device': '1',
          'school_id': widget.schoolId,
          'ip_address': '',
          'latitude': '',
          'longitude': '',
        },
      );
      if (response.statusCode == 200) {
        var data = await parseJsonInIsolate(response.body);
        print(data['success_code']);
        var errorMsg = data['error_msg'] ?? 'Unknown error';

        if (data['success_code'] == 1) {
          Constants.parentId = data['parent_detail']['parent_id'];
          Constants.firebaseid = data['parent_detail']['parent_firebase_id'];
          setLoggedIn(true);
          showDialog(
            context: context,
            builder: (BuildContext context) {
              Future.delayed(Duration(seconds: 1), () {
                Navigator.of(context).pop(true); // Close the dialog
              });
              return AlertDialog(
                title: Center(
                  child: Container(
                      height: 50,
                      width: 50,
                      child: Image.asset('assets/rightgreen.png')),
                ),
                content: Text(
                  'Login Successfully',
                  textAlign: TextAlign.center,
                ),
                backgroundColor: Colors.white,
              );
            },
          ).then((result) {
            if (result != null && result) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => Menubar()),
                (route) => false,
              );
            }
          });
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Center(child: Image.asset('assets/error.png')),
                content: Text(
                  errorMsg,
                  textAlign: TextAlign.center,
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
                backgroundColor: Colors.white,
              );
            },
          );
        }

        await Constants.saveToSharedPreferences();
      } else {
        print('failed');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xffFAF9F6),
        resizeToAvoidBottomInset: false, // Add this line
        // Wrap with Material widget
        body: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height,
            ),
            child: Stack(children: <Widget>[
              Positioned(
                top: 0,
                bottom: MediaQuery.of(context).size.height * 0.66,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9999,
                  // height: MediaQuery.of(context).size.height * 0.25,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/img.jpeg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              // Container(
              //   child: Image.asset('assets/img.jpeg'),
              // ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.29,
                bottom: 0,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    // height: MediaQuery.of(context).size.height * 0.99,
                    width: MediaQuery.of(context).size.width * 0.9999,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(30),
                        topLeft: Radius.circular(30),
                      ),
                      color: Color(0xffFAF9F6),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Text(
                                  'Welcome Back',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 30,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Center(
                                child: Text(
                                  'Login to your account',
                                  style: TextStyle(
                                    color: Color(0xFF747474),
                                    fontSize: 14,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Login Form
                        Container(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: user,
                                decoration: InputDecoration(
                                  labelText: 'Mobile Number/Email',
                                  labelStyle: TextStyle(
                                    color: Color(0xFF747474),
                                    fontSize: 14,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w500,
                                  ),
                                  fillColor: Color(0xFFF7F3F4),
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                keyboardType: TextInputType
                                    .emailAddress, // Allows email input by default
                                inputFormatters: [
                                  FilteringTextInputFormatter.deny(
                                      RegExp(r'\s')), // Deny spaces
                                  LengthLimitingTextInputFormatter(
                                      50), // Limit total input to 50 characters (email length)
                                ],
                                validator: (value) {
                                  if (value != null &&
                                      value.isNotEmpty &&
                                      value.length == 10 &&
                                      RegExp(r'^[0-9]+$').hasMatch(value)) {
                                    return null;
                                  }
                                  // If not a valid email or numeric input of 10 digits
                                  return 'Enter a valid email or 10-digit number';
                                },
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                controller: pass,
                                obscureText: !isPasswordVisible,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  labelStyle: TextStyle(
                                    color: Color(0xFF747474),
                                    fontSize: 14,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w500,
                                  ),
                                  fillColor: Color(0xFFF7F3F4),
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                    onPressed: () {
                                      // Toggle the visibility of the password
                                      setState(() {
                                        isPasswordVisible = !isPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Forgotpass(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  login(user.text.toString(),
                                      pass.text.toString());

                                  user.clear();
                                  pass.clear();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFFF6600),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  child: Text(
                                    'Log In',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  String urlToLaunch =
                                      'https://www.shreegalatoursandtravels.com/registration_form/';
                                  _navigateToWebView(context, urlToLaunch);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  child: Text(
                                    'Sign Up',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Assistance Section
                        Container(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              // Text(
                              //   'Need assistance with login or any other query?',
                              //   style: TextStyle(
                              //     color: Color(0xFF747474),
                              //     fontSize: 14,
                              //     fontFamily: 'Montserrat',
                              //     fontWeight: FontWeight.w500,
                              //   ),
                              // ),
                              // SizedBox(height: 8),
                              // Text(
                              //   'We are here to help you.',
                              //   style: TextStyle(
                              //     color: Color(0xFFFF6600),
                              //     fontSize: 14,
                              //     fontFamily: 'Montserrat',
                              //     fontWeight: FontWeight.w600,
                              //   ),
                              // ),
                              Text(
                                'Read the policy before filling the registration form',
                                style: TextStyle(
                                  color: Color(0xFF747474),
                                  fontSize: 14,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              GestureDetector(
                                onTap: () {
                                  _launchAsInAppWebViewWithCustomHeaders(Uri.parse(
                                      'https://www.track.lakshyaiotsolutions.com/privacy_lakshya.php'));
                                },
                                child: Text(
                                  'Privacy Policy',
                                  style: TextStyle(
                                    color: Color(0xFFFF6600),
                                    fontSize: 14,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ));
  }

  Future<void> _launchAsInAppWebViewWithCustomHeaders(Uri url) async {
    if (!await launch(
      url.toString(), // Use .toString() to convert Uri to a String
      forceSafariVC: false,
      forceWebView: false,
      headers: {'my_header_key': 'my_header_value'},
    )) {
      throw Exception('Could not launch $url');
    }
  }

  void _navigateToWebView(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewPage(url: url),
      ),
    );
  }
}

class WebViewPage extends StatefulWidget {
  final String url;

  WebViewPage({required this.url});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 46, left: 16, right: 16, bottom: 16),
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
                      border: Border.all(width: 1, color: Color(0xFFE1E1E1)),
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
                        'Registration Form',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          height: 0,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 5, right: 5, bottom: 16),
              child: Container(
                width: double.infinity,
                decoration: ShapeDecoration(
                  color: Colors.black,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1,
                      color: Colors.black,
                    ),
                  ),
                ),
                child: WebViewWidget(controller: controller),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
