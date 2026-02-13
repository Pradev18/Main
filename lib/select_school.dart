import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gala_travels_app/loginpage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'api_confige.dart';

class select_school extends StatefulWidget {
  @override
  State<select_school> createState() => _select_schoolState();
}

class _select_schoolState extends State<select_school> {
  /// ⭐ controller for searchable dropdown
  TextEditingController? schoolController;

  @override
  void initState() {
    super.initState();
    checkLoggedIn();
    fetchSchools();
  }

  Future<void> checkLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('loggedIn') && prefs.getBool('loggedIn')!) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      );
    }
  }

  PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  int _totalPages = 4;

  List<Map<String, dynamic>> schoolList = [];
  String? selectedSchool;

  /// fetch schools from API
  Future<void> fetchSchools() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfige.BASE_URL}/get_school_list.php'),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());

        if (data['success_code'] == 1) {
          var schoolsData = data['school_list'];

          if (schoolsData != null && schoolsData is List) {
            setState(() {
              schoolList = List<Map<String, dynamic>>.from(schoolsData);
            });
          }
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFAF9F6),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _totalPages,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemBuilder: (BuildContext context, int index) {
                return _buildPage(index);
              },
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                if (_currentPage < _totalPages - 1) {
                  _pageController.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }

                if (_currentPage == _totalPages - 1) {
                  if (selectedSchool == null) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Center(child: Image.asset('assets/error.png')),
                          content: Text('Please Select a School'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            LoginPage(schoolId: selectedSchool),
                      ),
                    );
                  }
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
                  'Next',
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
          ),
        ],
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return Container(child: Image.asset('assets/screen_1.jpg'));

      case 1:
        return Container(child: Image.asset('assets/screen_2.jpg'));

      case 2:
        return Image.asset('assets/screen_3.jpg');

      case 3:
        return SingleChildScrollView(
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
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/img.jpeg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.29,
                bottom: 0,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
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
                                  'Select School',
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
                                  "Lakshya IoT Solutions provides reliable school bus tracking to help you monitor your child’s journey with ease.",
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

                        /// ⭐ SEARCHABLE DROPDOWN
                        Container(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              TypeAheadField<Map<String, dynamic>>(
                                suggestionsCallback: (pattern) async {
                                  if (pattern.trim().isEmpty) return [];

                                  return schoolList.where((school) {
                                    final schoolName = school['school_name']
                                        .toString()
                                        .toLowerCase();

                                    return schoolName
                                        .contains(pattern.toLowerCase());
                                  }).toList();
                                },
                                builder: (context, controller, focusNode) {
                                  schoolController = controller;

                                  return TextField(
                                    controller: controller,
                                    focusNode: focusNode,
                                    decoration: InputDecoration(
                                      labelText: 'Select School',
                                      fillColor: Color(0xFFF7F3F4),
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                  );
                                },
                                itemBuilder: (context, suggestion) {
                                  return ListTile(
                                    title: Text(
                                      suggestion['school_name'].toString(),
                                    ),
                                  );
                                },
                                onSelected: (suggestion) {
                                  setState(() {
                                    selectedSchool =
                                        suggestion['school_id'].toString();

                                    // show selected value in field
                                    schoolController?.text =
                                        suggestion['school_name'].toString();
                                  });
                                },
                                emptyBuilder: (context) => SizedBox(),
                              ),
                              SizedBox(height: 25),
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
        );

      default:
        return Container();
    }
  }
}
