import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart'as http;

import 'api_confige.dart';


class Forgotpass extends StatefulWidget {

  const Forgotpass({Key? key}) : super(key: key);

  @override
  State<Forgotpass> createState() => _ForgotpassState();
}

class _ForgotpassState extends State<Forgotpass> {

  TextEditingController EMAIL = TextEditingController();

  bool _isLoading = false;

  void PASSWORD(String Email) async {
    setState(() {
      _isLoading = true; // Show progress indicator when submitting
    });
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse("${ApiConfige.BASE_URL}/parent_forgot_password.php"),
      );

      request.fields['user_email'] = Email;

      final response = await request.send();
      final responseString =
      await http.Response.fromStream(response).then((value) => value.body);

      if (response.statusCode == 200) {
        var data = jsonDecode(responseString);
        var errorMsg = data['error_msg'] ?? 'Unknown error';
        if (data['success_code'] == 1) {
          // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Menubar(),),(route) => false,);
          print(data);
          var errorMsg = data['error_msg'] ?? 'Unknown error';
          if (data['success_code'] == 1) {
            print(data);
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
                        child: Image.asset('assets/rightgreen.png')
                    ),
                  ),
                  content: Text('Mail sent successfully.', textAlign: TextAlign.center,),
                  backgroundColor: Colors.white,
                );
              },
            );
          } else {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Center(child: Image.asset('assets/error.png')),
                  content: Text(errorMsg,textAlign: TextAlign.center,),
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
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Center(child: Image.asset('assets/error.png')),
                content: Text(errorMsg,textAlign: TextAlign.center,),
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
      } else {
        print('Failed: $responseString');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false; // Hide progress indicator after submission
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract notification date and time from the message data
    return Material(
      child: Scaffold(
        backgroundColor: Color(0xffFAF9F6),
        body: Column(
          children: [
            buildHeaderSection(context),
            Expanded(child: _buildForm())
          ],
        ),
      ),
    );
  }

  Widget buildHeaderSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 46, left: 16, right: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: (){
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
                  'Forgot Password',
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

  Widget _buildForm() {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    return _isLoading
        ? Center(child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>( Color(0xFFFF6600)),
      strokeWidth: 5.0,
    )) // Show progress indicator if loading
        : SingleChildScrollView(
      child: Container(
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
                      'Reset Password',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 30,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Login Form
            Form(
              key: _formKey,
              child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextFormField(
                      controller: EMAIL,
                      decoration: InputDecoration(
                        labelText: 'Email',
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        final emailRegex = RegExp(
                            r'^[a-zA-Z0-9._%+-]+@[a-z]+\.[a-z]{2,}$');
                        if (!emailRegex.hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },

                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          PASSWORD(EMAIL.text.toString());
                        } else {
                          print('Validation failed');
                        }
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
                          'Submit',
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
            ),
          ],
        ),
      ),
    );
  }
}
