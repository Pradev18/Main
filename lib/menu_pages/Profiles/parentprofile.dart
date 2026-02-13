import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gala_travels_app/controller/api_controller.dart';
import 'package:gala_travels_app/loginpage.dart';
import 'package:gala_travels_app/menu_pages/Profiles/childprofile/childprofile.dart';
import 'package:gala_travels_app/menu_pages/Profiles/payment_details.dart';
import 'package:gala_travels_app/menu_pages/Profiles/childprofile/qr_scanner.dart';
import 'package:gala_travels_app/menu_pages/Profiles/support_form.dart';
import 'package:gala_travels_app/menu_pages/constants/constants.dart';
import 'package:gala_travels_app/menu_pages/menubar.dart';
import 'package:gala_travels_app/model/parent_model.dart';
import 'package:gala_travels_app/select_school.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../api_confige.dart';

class profile extends StatefulWidget {
  @override
  State<profile> createState() => _profileState();
}

class _profileState extends State<profile> {
  Apicontroller apicontroller = Get.put(Apicontroller());
  var isLoading = false.obs;


  @override
  void initState() {
    super.initState();
    fetchData();
    loadSwitchValue();
  }

  void logout() async {
    try {
      final response = await post(
        Uri.parse('${ApiConfige.BASE_URL}/parent_logout.php'),
        body: {
          'parent_id': Constants.parentId,
          'parent_firebase_id': Constants.firebaseid,
          'ip_address': Constants.IpAddress ?? ' ',
          'latitude': Constants.latitude ?? ' ',
          'longitude': Constants.longitude ?? ' '
        },
      );

      if (response.statusCode == 200) {

        var data = jsonDecode(response.body.toString());

        if (data['success_code'] == 1) {
          setLoggedIn(false);
          Constants.clearData();// Set logged out status
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
                content: Text('Logout Successfully', textAlign: TextAlign.center,),
                backgroundColor: Colors.white,
              );
            },
          ).then((result) {
            if (result != null && result) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => select_school()));
            }
          });
        } else {
          print('false');
        }
        print(data);
        print(Constants.fcmToken);
        Apicontroller().apimodel?.clear();
      } else {
        print('failed');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> setLoggedIn(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('loggedIn', value);
  }

  void fetchData() async {
    try {
      isLoading(true);
      await apicontroller.Fetchdata();
    } finally {
      isLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
      // Navigate to the home page (Menubar)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Menubar()),
            (route) => false,
      );
      return false; // Prevent default back button behavior
    },
    child: Scaffold(
      backgroundColor: Color(0xffFAF9F6),
      body: Obx(
        () {
          if (isLoading.value) {
            return Center(child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>( Color(0xFFFF6600)),
              strokeWidth: 5.0,));
          } else {
            return buildprofilePage();
          }
        },
      ),
    ),
    );
  }

  Widget buildprofilePage() {
    var parentModels = apicontroller.apimodel ?? <parentmodel>[];
    return Scaffold(
      backgroundColor: Color(0xffFAF9F6),
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildheaderSection(parentModels),
            // Placeholder for the user profile section
            buildUserProfileSection(parentModels),
            // // Placeholder for the list of children
            buildChildrenList(parentModels),
            // // Placeholder for the settings
            buildSettingSection(parentModels),
          ],
        ),
      ),
    );
  }

  Widget buildheaderSection(List<parentmodel> parentModels) {
    double Width = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.only(top: 46, left: 16, right: 16, bottom: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => Menubar(),));
            },
            child: Container(
              width: Width*0.132,
              height: Width*0.132,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(width: 1, color: Color(0xFFE1E1E1)),
              ),
              child: Center(
                child: Container(
                  width: Width*0.132,
                  height: Width*0.132,
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
          SizedBox(width: Width*0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Profile',
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
          GestureDetector(
            onTap: (){
              showAlertBox();
            },
            child: Container(
              width: Width*0.132,
              height: Width*0.132,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 1, color: Color(0xFFE1E1E1)),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Image.asset('assets/exiticon.png'),
            ),
          )
        ],
      ),
    );
  }

  void showAlertBox() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Log Out'),
          content: Text('Do you want to log out ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the alert box
                logout();
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Widget buildUserProfileSection(List<parentmodel> parentModels) {
    double Width = MediaQuery.of(context).size.width;

    if (parentModels.isNotEmpty) {
      var firstParent = parentModels[0];

      return GestureDetector(
        onTap: (){
          _ShowBottomSheet(firstParent);
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Container(
            width: double.infinity,
            height: Width*0.225,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 1, color: Color(0xFFE1E1E1)),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    children: [
                      firstParent.parentDetails?.parentPhoto == ''
                      ? Container(
                        width: Width*0.18,
                        height: Width*0.18,
                        decoration: ShapeDecoration(
                          color: Colors.orange,
                          image: DecorationImage(
                            image: AssetImage('assets/jolly.png'),
                            fit: BoxFit.cover,
                          ),
                          shape: CircleBorder(
                            side: BorderSide(width: 2, color: Color(0xFFFF6600)),
                          ),
                        ),
                      )
                      : Container(
                        width: Width*0.18,
                        height: Width*0.18,
                        decoration: ShapeDecoration(
                          color: Colors.orange,
                          image: DecorationImage(
                            image: NetworkImage(firstParent.parentDetails?.parentPhoto ?? 'no photo'),
                            fit: BoxFit.cover,
                          ),
                          shape: CircleBorder(
                            side: BorderSide(width: 2, color: Color(0xFFFF6600)),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: Width*0.062,
                          height: Width*0.062,
                          decoration: ShapeDecoration(
                            color: Color(0xffF56600),
                            // image: DecorationImage(
                            //   image: AssetImage('assets/penicon.jpg'),
                            //   fit: BoxFit.cover,
                            // ),
                            shape: CircleBorder(
                              side: BorderSide(width: 2, color: Color(0xFFFF6600)),
                            ),
                          ),
                          child: Icon(Icons.edit,color: Colors.white,size: 15),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${capitalize(firstParent.parentDetails?.parentName)}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        height: 0,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Guardian',
                      style: TextStyle(
                        color: Color(0xFF747474),
                        fontSize: 12,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                        height: 0,
                      ),
                    ),
                    SizedBox(
                      height: Width*0.01,
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Contact No. : ',
                            style: TextStyle(
                              color: Color(0xFF747474),
                              fontSize: 12,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500,
                              height: 0,
                            ),
                          ),
                          TextSpan(
                            text:
                                '${firstParent.parentDetails?.parentPhone ?? "No Name"}',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                              height: 0,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      );
    } else {
      return Container(); // Placeholder for when the list is empty
    }
  }

  Widget buildChildrenList(List<parentmodel> parentModels) {

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 15, top: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'My Children :',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                height: 0,
              ),
            ),
          ),
        ),
        // Use SingleChildScrollView to make the Column scrollable
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var parent in parentModels) ...[
                if (parentModels.indexOf(parent) == 0) ...[
                  for (var child in parent.childDetails ?? []) ...[
                    GestureDetector(
                      onTap: () {
                        // Handle the tap event, e.g., navigate to child profile
                        navigateToChildProfile(child);
                      },
                      child:Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16,bottom: 10),
                          child: Container(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.width*0.19,
                            decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1,
                                  color: Color(0xFFE1E1E1),
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: child.childPhotoUrl == ''
                                      ? CircleAvatar(
                                    radius: 27.0,
                                    backgroundColor:
                                    Color(0xffefecfd),
                                    backgroundImage: AssetImage(child
                                        .childGender ==
                                        'MALE'
                                        ? 'assets/sujalhassan.png'
                                        : 'assets/laylaimg.png'),
                                  )
                                      : CircleAvatar(
                                      radius: 27.0,
                                      backgroundColor:
                                      Color(0xffefecfd),
                                      backgroundImage: NetworkImage(child?.childPhotoUrl)
                                  ),
                                ),
                                Text(
                                  '${capitalize(child?.childName)}',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600,
                                    height: 0,
                                  ),
                                ),
                                Spacer(),
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Image(
                                    image: AssetImage('assets/back-arrow.png'),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ],
              ],
            ],
          ),
        ),
        // Padding(
        //   padding: const EdgeInsets.fromLTRB(35, 10, 35, 0),
        //   child: Container(
        //     width: double.infinity,
        //     decoration: ShapeDecoration(
        //       shape: RoundedRectangleBorder(
        //         side: BorderSide(
        //           width: 1,
        //           strokeAlign: BorderSide.strokeAlignCenter,
        //           color: Color(0xFFE1E1E1),
        //         ),
        //       ),
        //     ),
        //   ),
        // )
      ],
    );
  }

  Widget buildSettingSection(List<parentmodel> parentModels) {
    double Width = MediaQuery.of(context).size.width;

    if (parentModels.isNotEmpty) {
      var firstParent = parentModels[0];
      return Column(
      children: [
        // Padding(
        //   padding: const EdgeInsets.only(left: 16,right: 16,top: 20),
        //   child: Container(
        //     width: double.infinity,
        //     height: 64,
        //     decoration: ShapeDecoration(
        //       color: Colors.white,
        //       shape: RoundedRectangleBorder(
        //         side: BorderSide(width: 1, color: Color(0xFFE1E1E1)),
        //         borderRadius: BorderRadius.circular(14),
        //       ),
        //     ),
        //     child: Row(
        //       children: [
        //         Padding(
        //           padding: const EdgeInsets.all(8.0),
        //           child: Image(image: AssetImage('assets/alarm.png')),
        //         ),
        //         Text(
        //           'Notify me Before',
        //           style: TextStyle(
        //             color: Colors.black,
        //             fontSize: 16,
        //             fontFamily: 'Montserrat',
        //             fontWeight: FontWeight.w500,
        //             height: 0,
        //           ),
        //         ),
        //         SizedBox(
        //           width: 50,
        //         ),
        //         Image(image: AssetImage('assets/subtract.png')),
        //         SizedBox(
        //           width: 20,
        //         ),
        //         Text(
        //           '2 KM',
        //           textAlign: TextAlign.center,
        //           style: TextStyle(
        //             color: Colors.black,
        //             fontSize: 14,
        //             fontFamily: 'Montserrat',
        //             fontWeight: FontWeight.w600,
        //             height: 0,
        //           ),
        //         ),
        //         SizedBox(
        //           width: 20,
        //         ),
        //         Image(image: AssetImage('assets/add.png')),
        //       ],
        //     ),
        //   ),
        // ),
        SizedBox(
          height: Width*0.03,
        ),
        GestureDetector(
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentDetails(),));
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 16,right: 16),
            child: Container(
              width: double.infinity,
              height: Width*0.16,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 1, color: Color(0xFFE1E1E1)),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image(image: AssetImage('assets/paymentlist.png')),
                  ),
                  Text(
                    'Payment Details',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                      height: 0,
                    ),
                  ),
                  Spacer(), // or use Expanded()
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Image(image: AssetImage('assets/back-arrow.png')),
                  )
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: Width*0.04,
        ),
        GestureDetector(
          onTap: (){
            _showBottomSheet(firstParent);
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 16,right: 16),
            child: Container(
              width: double.infinity,
              height: Width*0.16,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 1, color: Color(0xFFE1E1E1)),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image(image: AssetImage('assets/settingicon.png')),
                  ),
                  Text(
                    'Settings',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                      height: 0,
                    ),
                  ),
                  Spacer(), // or use Expanded()
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Image(image: AssetImage('assets/back-arrow.png')),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
    } else {
      return Container(); // Placeholder for when the list is empty
    }
  }

  void notificationSetting(String flag) async {
    try {
      final response = await post(
        Uri.parse('${ApiConfige.BASE_URL}/parent_notification_on_off.php'),
        body: {
          'parent_id': Constants.parentId,
          'parent_firebase_id': Constants.firebaseid,
          'flag': flag
        },
      );
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        print(data);
      } else {
        print('failed');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  bool switchValue = true;

  void loadSwitchValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      switchValue = prefs.getBool('switchValue') ?? true; // Use 'true' as a default value if it's not stored yet
    });
  }

  void saveSwitchValue(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('switchValue', value);
  }

  void _showBottomSheet(parentmodel firstParent) {
    final parentDetails = firstParent.parentDetails;
    if (parentDetails != null) {
      showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return _buildBottomSheetContent(parentDetails);
        },
      );
    }
  }

  Widget _buildBottomSheetContent(ParentDetails parentDetails) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Text(
                  'Settings',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    height: 0,
                  ),
                ),
              ),
              Container(
                width: 312,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(width: 1, color: Color(0xFFE1E1E1)),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: ShapeDecoration(
                        shape: OvalBorder(
                          side: BorderSide(
                            width: 1,
                            color: Color(0xFFFF6600),
                          ),
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 30,
                          height: 30,
                          child: Icon(Icons.notifications_on_outlined,color: Color(0xFFFF6600),),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                      child: Text(
                        'Notification',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                          height: 0,
                        ),
                      ),
                    ),
                    Spacer(),
                    Switch(
                      value: switchValue,
                      onChanged: (value) {
                        setState(() {
                          switchValue = value;
                        });
                        saveSwitchValue(value);
                        Navigator.of(context).pop();
                        notificationSetting(value ? '1' : '0');
                      },
                      activeTrackColor: Color(0xFFFF6600),
                      inactiveTrackColor: Colors.white,
                    ),
                  ]
                ),
              ),
              GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SupportForm(parentDetails: parentDetails,),),);

                },
                child: Container(
                  width: 312,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(width: 1, color: Color(0xFFE1E1E1)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: ShapeDecoration(
                          shape: OvalBorder(
                            side: BorderSide(
                              width: 1,
                              color: Color(0xFFFF6600),
                            ),
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 30,
                            height: 30,
                            child: Icon(Icons.support_agent_sharp,color: Color(0xFFFF6600),),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                        child: Text(
                          'Support',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                            height: 0,
                          ),
                        ),
                      ),
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Image(image: AssetImage('assets/back-arrow.png')),
                      )
                    ],
                  ),
                ),
              ),
              // GestureDetector(
              //   onTap: (){
              //     showalertBox();
              //   },
              //   child: Container(
              //     width: 312,
              //     height: 64,
              //     decoration: BoxDecoration(
              //       color: Colors.white,
              //       border: Border(
              //         bottom: BorderSide(width: 1, color: Color(0xFFE1E1E1)),
              //       ),
              //     ),
              //     child: Row(
              //       children: [
              //         Container(
              //           width: 40,
              //           height: 40,
              //           decoration: ShapeDecoration(
              //             shape: OvalBorder(
              //               side: BorderSide(
              //                 width: 1,
              //                 color: Color(0xFFFF6600),
              //               ),
              //             ),
              //           ),
              //           child: Center(
              //             child: Container(
              //               width: 30,
              //               height: 30,
              //               child: Icon(Icons.delete,color: Color(0xFFFF6600),),
              //             ),
              //           ),
              //         ),
              //         // Padding(
              //         //   padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
              //         //   child: Text(
              //         //     'Account Delete',
              //         //     style: TextStyle(
              //         //       color: Colors.black,
              //         //       fontSize: 16,
              //         //       fontFamily: 'Montserrat',
              //         //       fontWeight: FontWeight.w500,
              //         //       height: 0,
              //         //     ),
              //         //   ),
              //         // ),
              //         Spacer(),
              //         Padding(
              //           padding: const EdgeInsets.only(right: 10),
              //           child: Image(image: AssetImage('assets/back-arrow.png')),
              //         )
              //       ],
              //     ),
              //   ),
              // ),
              GestureDetector(
                onTap: (){
                  _launchAsInAppWebViewWithCustomHeaders(
                      Uri.parse('https://www.track.lakshyaiotsolutions.com/privacy_lakshya.php'));
                },
                child: Container(
                  width: 312,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(width: 1, color: Color(0xFFE1E1E1)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: ShapeDecoration(
                          shape: OvalBorder(
                            side: BorderSide(
                              width: 1,
                              color: Color(0xFFFF6600),
                            ),
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 30,
                            height: 30,
                            child: Icon(Icons.privacy_tip_outlined,color: Color(0xFFFF6600),),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                        child: Text(
                          'Privacy Policy',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                            height: 0,
                          ),
                        ),
                      ),
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Image(image: AssetImage('assets/back-arrow.png')),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

  void delete() async {
    try {
      final response = await post(
        Uri.parse('${ApiConfige.BASE_URL}/parent_account_delete.php?'),
        body: {
          'parent_id': Constants.parentId,
          'parent_firebase_id': Constants.firebaseid,
          'ip_address': Constants.IpAddress ?? ' ',
          'latitude': Constants.latitude ?? ' ',
          'longitude': Constants.longitude ?? ' '
        },
      );

      if (response.statusCode == 200) {

        var data = jsonDecode(response.body.toString());

        if (data['success_code'] == 1) {
          logout();

        } else {
          print('false');
        }
        print(data);

      } else {
        print('failed');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void showalertBox() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Account'),
          content: Text('Do you want to delete your account ?'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('No',style: TextStyle(color: Colors.black),)
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the alert box
                delete();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF6600),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text('Yes',style: TextStyle(color: Colors.white),),
            ),
          ],
        );
      },
    );
  }


  // void _navigateToWebView(BuildContext context, String url) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => WebViewPage(url: url),
  //     ),
  //   );
  // }

  void setState(VoidCallback fn) {
    // Use Flutter's setState method to update the state
    if (mounted) {
      super.setState(fn);
    }
  }

  void navigateToChildProfile(ChildDetails child) {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChildProfile(child: child),
      ),
    );
  }

  String capitalize(String? input) {
    if (input == null || input.isEmpty) {
      return input ?? '';
    }

    List<String> words = input.split(' ');
    List<String> capitalizedWords = words.map((word) {
      if (word.isNotEmpty) {
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      }
      return '';
    }).toList();

    return capitalizedWords.join(' ');
  }

  void _ShowBottomSheet(parentmodel firstParent) {
    final parentDetails = firstParent.parentDetails;
    if (parentDetails != null) {
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return Editparent(parentDetails: parentDetails);
        },
      );
    }
  }
}

class Editparent extends StatefulWidget {
  final ParentDetails parentDetails;

  const Editparent({Key? key, required this.parentDetails}) : super(key: key);

  @override
  _EditparentState createState() => _EditparentState();
}

class _EditparentState extends State<Editparent> {
  File? _selectedImage;
  TextEditingController ParentName = TextEditingController();
  bool _isLoading = false; // State variable to manage loading state

  @override
  void initState() {
    super.initState();
    ParentName.text = widget.parentDetails.parentName!;
  }

  void upadate_perent(String name) async {
    setState(() {
      _isLoading = true; // Show progress indicator when submitting
    });
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(Constants.editparent),
      );

      request.fields['parent_id'] = Constants.parentId;
      request.fields['parent_name'] = name;

      if (_selectedImage != null) {
        List<int> imageBytes = await _selectedImage!.readAsBytes();
        http.MultipartFile file = http.MultipartFile.fromBytes(
          'parent_photo',
          imageBytes,
          filename: 'photo.jpg',
        );
        request.files.add(file);
      }

      final response = await request.send();
      final responseString =
      await http.Response.fromStream(response).then((value) => value.body);

      if (response.statusCode == 200) {
        var data = jsonDecode(responseString);
        var errorMsg = data['error_msg'] ?? 'Unknown error';
        if (data['success_code'] == 1) {
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
                content: Text('Updated Parent Details', textAlign: TextAlign.center,),
                backgroundColor: Colors.white,
              );
            },
          ).then((result) {
            if (result != null && result) {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Menubar(),),(route) => false,);
            }
          });
          print(data);
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
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    return _isLoading
        ? Center(child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>( Color(0xFFFF6600)),
      strokeWidth: 5.0,
    )) // Show progress indicator if loading
        : Padding(
      padding: mediaQueryData.viewInsets,
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(25)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit Parent Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: GestureDetector(
                onTap: () async {
                  // Open the file picker
                  FilePickerResult? result =
                  await FilePicker.platform.pickFiles();

                  // Update the selected image
                  if (result != null) {
                    setState(() {
                      _selectedImage = File(result.files.single.path!);
                    });
                  }
                },
                child: Container(                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.grey[200],
                  ),
                  child: _selectedImage != null
                      ? Image.file(_selectedImage!, fit: BoxFit.cover)
                      : Icon(Icons.add_a_photo, color: Colors.grey),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: ParentName,
              decoration: InputDecoration(
                labelText: 'Name ',
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
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                upadate_perent(
                    ParentName.text.toString());
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
                  'Update Parent Profile',
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
    );
  }
}


// class WebViewPage extends StatefulWidget {
//   final String url;
//
//   WebViewPage({required this.url});
//
//   @override
//   State<WebViewPage> createState() => _WebViewPageState();
// }
//
// class _WebViewPageState extends State<WebViewPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           Container(
//             padding: EdgeInsets.only(top: 46, left: 16, right: 16, bottom: 16),
//             child: Row(
//               children: [
//                 GestureDetector(
//                   onTap: () {
//                     // Navigate back when the image is tapped
//                     Navigator.of(context).pop();
//                   },
//                   child: Container(
//                     width: 52,
//                     height: 52,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(width: 1, color: Color(0xFFE1E1E1)),
//                     ),
//                     child: Center(
//                       child: Container(
//                         width: 52,
//                         height: 52,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(12),
//                           image: DecorationImage(
//                             image: AssetImage('assets/Alt Arrow Left.png'),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         'Reset Password',
//                         style: TextStyle(
//                           color: Colors.black,
//                           fontSize: 14,
//                           fontFamily: 'Montserrat',
//                           fontWeight: FontWeight.w600,
//                           height: 0,
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.only(left: 5, right: 5, bottom: 16),
//               child: Container(
//                 width: double.infinity,
//                 decoration: ShapeDecoration(
//                     color: Colors.black,
//                     shape: RoundedRectangleBorder(
//                       side: BorderSide(
//                         width: 1,
//                         color: Colors.black,
//                       ),
//                     )),
//                 child: WebView(
//                   initialUrl: widget.url,
//                   javascriptMode: JavascriptMode.unrestricted,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
// }


