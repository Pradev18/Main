import 'dart:async';
import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:gala_travels_app/controller/api_controller.dart';
import 'package:gala_travels_app/menu_pages/constants/constants.dart';
import 'package:gala_travels_app/menu_pages/homescreen/eta_time.dart';
import 'package:gala_travels_app/menu_pages/homescreen/payment.dart';
import 'package:gala_travels_app/menu_pages/homescreen/provider.dart';
import 'package:gala_travels_app/model/parent_model.dart';
import 'package:gala_travels_app/notification/messeing_service.dart';
import 'package:gala_travels_app/notification/notification_screen.dart';
import 'package:get/get.dart';
import 'package:get/get_core/get_core.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:hypersdkflutter/hypersdkflutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../api_confige.dart';
import '../../payment/payment_page.dart';

class HomePage extends StatefulWidget {
  final hyperSDK = HyperSDK();
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {



  Apicontroller apicontroller = Get.put(Apicontroller());
  var isLoading = false.obs;


  NotificationServies notificationServies = NotificationServies();
  List<String> notifications = [];

  LocationData? _currentLocation;
  String ipAddress = 'Loading...';

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color(0xffFAF9F6),
      body: Obx(
        () {
          if (isLoading.value) {
            return Center(
                child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFFFF6600)),
                    strokeWidth: 5.0));
          } else {
            return buildHomePage();
          }
        },
      ),
    );
  }

  Widget buildHomePage() {
    var parentModels = apicontroller.apimodel ?? <parentmodel>[];
    return Material(
      child: Scaffold(
        backgroundColor: Color(0xffFAF9F6),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Placeholder for the user profile section
              buildUserProfileSection(parentModels),
              // Placeholder for the carousel slider
              buildCarouselSlider(parentModels),
              // Placeholder for the list of children
              buildChildrenList(parentModels),
              // Your existing UI code goes here
            ],
          ),
        ),
      ),
    );
  }

  Widget buildUserProfileSection(List<parentmodel> parentModels) {
    double Width = MediaQuery.of(context).size.width;
    double Height = MediaQuery.of(context).size.height;


    if (parentModels.isNotEmpty) {
      var firstParent = parentModels[0];

      // Get current time
      var now = DateTime.now();
      var formatter = DateFormat('HH');
      var hour = int.parse(formatter.format(now));

      // Determine the greeting based on the time
      String greeting;
      if (hour >= 5 && hour < 12) {
        greeting = 'Good Morning!';
      } else if (hour >= 12 && hour < 17) {
        greeting = 'Good Afternoon!';
      } else if (hour >= 17 && hour < 21) {
        greeting = 'Good Evening!';
      } else {
        greeting = 'Good Night!';
      }

      return Container(
        padding: EdgeInsets.only(top: 46, left: 16, right: 16, bottom: 16),
        child: Row(
          children: [
            Container(
              width: Width*0.13,
              height: Width*0.13,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(width: 1, color: Color(0xFFE1E1E1)),
              ),
              child: Center(
                  child: firstParent.parentDetails?.parentPhoto == ''
                      ? Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.orange,
                            image: DecorationImage(
                              image: AssetImage('assets/jolly.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.orange,
                            image: DecorationImage(
                              image: NetworkImage(
                                  firstParent.parentDetails?.parentPhoto ??
                                      'no photo'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )),
            ),
            SizedBox(width: Width*0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    greeting,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    '${capitalize(firstParent.parentDetails?.parentName)}',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationsScreen(),
                  ),
                );
              },
              child: Container(
                width: 52,
                height:52,
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1, color: Color(0xFFE1E1E1)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Image.asset('assets/notification-bing.png'),
              ),
            )
          ],
        ),
      );
    } else {
      return Container(); // Placeholder for when the list is empty
    }
  }

  Widget buildCarouselSlider(List<parentmodel> parentModels) {
    double Width = MediaQuery.of(context).size.width;
    double Height = MediaQuery.of(context).size.height;


    var banners =
        parentModels.isNotEmpty ? parentModels[0].bannerList ?? [] : [];

    return banners.isEmpty
        ? Container()
        : CarouselSlider(
            options: CarouselOptions(
              height: Height*0.30,
              // aspectRatio: 16 / 9,
              viewportFraction: 1.0,
              // enlargeCenterPage: true,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 3),
              onPageChanged: (index, reason) {
                // Your existing onPageChanged logic...
              },
              // Set width to the screen width
              // aspectRatio: MediaQuery.of(context).size.width / 150,
            ),
            items: banners.map((banner) {
              return Builder(
                builder: (BuildContext context) {
                  return Stack(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: GestureDetector(
                          onTap: () {
                            _launchAsInAppWebViewWithCustomHeaders(
                                Uri.parse('${banner.bannerLink ?? ''}'));
                          },
                          child: ClipRRect(
                            child: Image.network(
                              banner.bannerImageDisplay ?? '',
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Color(0xFFFF6600)),
                                      strokeWidth: 5.0),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      // You can adjust the position and size of CircularProgressIndicator as per your UI requirements
                      // if (banners.indexOf(banner) == 0 && banners.length > 5)
                      //   Positioned(
                      //     top: 0,
                      //     left: 0,
                      //     right: 0,
                      //     bottom: 0,
                      //     child: Center(
                      //       child: CircularProgressIndicator(
                      //                valueColor:
                      //                AlwaysStoppedAnimation<Color>(Color(0xFFFF6600)),
                      //               strokeWidth: 5.0
                      //       ),
                      //     ),
                      //   ),
                    ],
                  );
                },
              );
            }).toList(),
          );
  }

  // Example usage in your buildChildrenList() method
  Widget buildChildrenList(List<parentmodel> parentModels) {
    print("parent --"+parentModels.toString());
    double Width = MediaQuery.of(context).size.width;
    double Height = MediaQuery.of(context).size.height;

    var dateTime = DateTime.now();
    var formatter = DateFormat('yyyy-MM-dd');
    String? today = formatter.format(dateTime);
    print(today); //
    var unixTimeMilliseconds = DateTime.now().toUtc().millisecondsSinceEpoch;
    // Assuming pickupRouteStartTime is a String (e.g., "2025-03-26 08:30:00")
    var pickupstart =today+" "+parentModels[0].childDetails![0].pickupRouteStartTime.toString();
    DateTime pickupDateTime = DateTime.parse(pickupstart!).toUtc();
    int unixTimeMillisecondspickstart = pickupDateTime.millisecondsSinceEpoch;
    var pickupstop =today+" "+parentModels[0].childDetails![0].pickupRouteEndTime.toString();
    DateTime pickupstopdate = DateTime.parse(pickupstop!).toUtc();
    int unixTimeMillisecondspickstop = pickupstopdate.millisecondsSinceEpoch;
    print("unixTimeMillisecondspickstart    "+unixTimeMillisecondspickstart.toString()+"---unixTimeMillisecondspickstop"+unixTimeMillisecondspickstop.toString());

    var dropstart =today+" "+parentModels[0].childDetails![0].dropRouteStartTime.toString();
    DateTime dropDateTimestart = DateTime.parse(dropstart!).toUtc();
    int unixdropstart = dropDateTimestart.millisecondsSinceEpoch;
    var dropstop =today+" "+parentModels[0].childDetails![0].dropRouteEndTime.toString();
    DateTime dropDateTimestop = DateTime.parse(dropstop!).toUtc();
    int unixdropstop = dropDateTimestop.millisecondsSinceEpoch;

    print(unixdropstop.toString()+"---unixdropstop");
    print("unixdropstart---"+unixdropstart.toString());

    print(unixTimeMillisecondspickstop.toString()+"---unixTimeMillisecondspick");

    print("unixTimeMilliseconds---"+unixTimeMilliseconds.toString());




    int? pickupStartTime;
    int? pickupEndTime;
    int? dropStartTime;
    int? dropEndTime;
    String selectedChildid = '';
    String selectedChildPayId = '';

    DateTime currentTime = DateTime.now();
    TimeOfDay currentTimeOfDay = TimeOfDay.fromDateTime(currentTime);


  print("object not in provider");
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

        Consumer<HomeProvider> (
    builder: (context, provider, child) {
      print("Home provider: ${child}");
      print("Home provider: ${provider.refreshCount}");
        return  SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var parent in parentModels) ...[
                if (parentModels.indexOf(parent) == 0) ...[
                  for (var child in parent.childDetails ?? []) ...[

                    Container(
                      child: (child?.pickupRouteStartTime == '' &&
                              child?.pickupRouteEndTime == '' &&
                              child?.dropRouteStartTime == '' &&
                              child?.dropRouteEndTime == '')
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                              child: Container(
                                width: double.infinity,
                                height: Height*0.070,
                                decoration: ShapeDecoration(
                                  color: Color(0x19DD1D1C),
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        width: 1, color: Color(0xFFDD1D1C)),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 0, 0, 0),
                                      child: Image(
                                          image:
                                              AssetImage('assets/error.png')),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(5, 0, 0, 0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${capitalize(child?.childName)}',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w700,
                                              height: 0,
                                            ),
                                          ),
                                          Text(
                                            'Trip has not been allocated yet !',
                                            style: TextStyle(
                                              color: Color(0xFFDD1D1C),
                                              fontSize: 12,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w500,
                                              height: 0,
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          : Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 16),
                                  child: Container(
                                    width: double.infinity,
                                    // height: 180,
                                    decoration: ShapeDecoration(
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            width: 1, color: Color(0xFFE1E1E1)),
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(14),
                                            topRight: Radius.circular(14)),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: 10, top: 5, right: 10),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              child.childPhotoUrl == ''
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
                                                      backgroundImage:
                                                          NetworkImage(child
                                                              ?.childPhotoUrl)),
                                              SizedBox(width: Width*0.04),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '${capitalize(child?.childName)}',
                                                      style: TextStyle(
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.04,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            Color(0xff000000),
                                                      ),
                                                    ),
                                                    SizedBox(height: Width*0.01),
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                          width: Width*0.02,
                                                          height: Width*0.02,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4.0),
                                                            color: Color(
                                                                0xff2ab154),
                                                          ),
                                                          margin:
                                                              EdgeInsets.only(
                                                                  right: 8.0),
                                                        ),
                                                        Text(
                                                          'At Home',
                                                          style: TextStyle(
                                                            fontSize: 12.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Color(
                                                                0xff747474),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    () {
                                                      // DateTime currentTime =
                                                      //     DateTime.now();
                                                      // TimeOfDay
                                                      //     currentTimeOfDay =
                                                      //     TimeOfDay
                                                      //         .fromDateTime(
                                                      //             currentTime);

                                                      String displayTime = '';

                                                      pickupStartTime =
                                                          int.tryParse(child
                                                                  ?.pickupRouteStartTime
                                                                  ?.split(
                                                                      ":")[0] ??
                                                              '');
                                                      pickupEndTime =
                                                          int.tryParse(child
                                                                  ?.pickupRouteEndTime
                                                                  ?.split(
                                                                      ":")[0] ??
                                                              '');
                                                      dropStartTime =
                                                          int.tryParse(child
                                                                  ?.dropRouteStartTime
                                                                  ?.split(
                                                                      ":")[0] ??
                                                              '');
                                                      dropEndTime =
                                                          int.tryParse(child
                                                                  ?.dropRouteEndTime
                                                                  ?.split(
                                                                      ":")[0] ??
                                                              '');

                                                      print("times " +
                                                          "$pickupStartTime-" +
                                                          "$pickupEndTime-" +
                                                          "$dropStartTime-" +
                                                          "$dropEndTime-");

                                                      if (pickupStartTime !=
                                                              null &&
                                                          pickupEndTime !=
                                                              null &&
                                                          unixTimeMilliseconds >=
                                                              unixTimeMillisecondspickstart! &&
                                                          unixTimeMilliseconds <
                                                              unixTimeMillisecondspickstop!) {
                                                        // Display pickupRouteEndTime
                                                        displayTime = child
                                                                ?.pickupRouteEndTime ??
                                                            '00:00';
                                                      } else if (dropStartTime !=
                                                              null &&
                                                          dropEndTime != null &&
                                                          unixTimeMilliseconds >=
                                                              unixdropstart! &&
                                                          unixTimeMilliseconds <
                                                              unixdropstop!) {
                                                        // Display dropRouteEndTime
                                                        displayTime = child
                                                                ?.dropRouteEndTime ??
                                                            '00:00';
                                                      } else {
                                                        // Display some default message or handle another case
                                                        displayTime = '00:00';
                                                      }
                                            print("currentTimeOfDay---"+currentTimeOfDay.toString());
                                                      // Format the time using intl package
                                                      if (displayTime !=
                                                          '00:00') {
                                                        displayTime = DateFormat
                                                                .jm()
                                                            .format(DateFormat(
                                                                    'HH:mm')
                                                                .parse(
                                                                    displayTime));
                                                      } else {
                                                        displayTime = '00:00';
                                                      }

                                                      return displayTime;
                                                    }(),
                                                    textAlign: TextAlign.right,
                                                    style: TextStyle(
                                                      fontSize: 14.0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Color(0xff000000),
                                                    ),
                                                  ),
                                                  SizedBox(height: Width*0.01),
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                        width: Width*0.02,
                                                        height: Width*0.02,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      4.0),
                                                          color:
                                                              Color(0xffdd1d1c),
                                                        ),
                                                        margin: EdgeInsets.only(
                                                            right: 8.0),
                                                      ),
                                                      Text(
                                                        'Trip Ended',
                                                        textAlign:
                                                            TextAlign.right,
                                                        style: TextStyle(
                                                          fontSize: 12.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color:
                                                              Color(0xff747474),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 20,
                                              bottom: 15,
                                              left: 10,
                                              right: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Column(
                                                children: [
                                                  Container(
                                                    width: Width*0.11,
                                                    height: Width*0.11,
                                                    decoration: ShapeDecoration(
                                                      shape: OvalBorder(
                                                        side: BorderSide(
                                                          width: 2,
                                                          color: (pickupStartTime != null &&
                                                                  pickupEndTime !=
                                                                      null &&
                                                              unixTimeMilliseconds >=
                                                                  unixTimeMillisecondspickstart! &&
                                                              unixTimeMilliseconds <
                                                                  unixTimeMillisecondspickstop!)
                                                              ? Color(
                                                                  0xFFFF6600)
                                                              : Color(
                                                                  0xFFE1E1E1),
                                                        ),
                                                      ),
                                                    ),
                                                    child: Center(
                                                      child: Container(
                                                        width: Width*0.080,
                                                        height: Width*0.08,
                                                        decoration:
                                                            BoxDecoration(
                                                          image:
                                                              DecorationImage(
                                                            image: AssetImage(
                                                                'assets/marker.png'),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: Width*0.01,
                                                  ),
                                                  Text(
                                                    '${child?.pickupRouteStartTime ?? 'no time'}',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: (pickupStartTime !=
                                                                  null &&
                                                              pickupEndTime !=
                                                                  null &&
                                                          unixTimeMilliseconds >=
                                                              unixTimeMillisecondspickstart! &&
                                                          unixTimeMilliseconds <
                                                                  unixTimeMillisecondspickstop!)
                                                          ? Color(0xFFFF6600)
                                                          : Color(0xFFE1E1E1),
                                                      fontSize: 10,
                                                      fontFamily: 'Montserrat',
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      height: 0,
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Expanded(
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.only(top: 10,bottom: 7),
                                                      child: Image(
                                                        image: AssetImage(
                                                          (pickupStartTime != null &&
                                                                  pickupEndTime !=
                                                                      null &&
                                                              unixTimeMilliseconds >=
                                                                  unixTimeMillisecondspickstart! &&
                                                              unixTimeMilliseconds <=
                                                                      unixTimeMillisecondspickstop!)
                                                              ? 'assets/Line 8.png'
                                                              : 'assets/Line 7.png',
                                                        ),
                                                      ),
                                                    ),
                                                    child?.shotEta == "1" ? pickupStartTime != null &&
                                                        pickupEndTime !=
                                                            null &&
                                                        unixTimeMilliseconds >=
                                                            unixTimeMillisecondspickstart! &&
                                                        unixTimeMilliseconds <
                                                            unixTimeMillisecondspickstop!
                                                    ?
                                                    EtaScreen(
                                                        childId: child?.childId,
                                                    )
                                                        : Text(
                                                      "ETA\n00:00:00",
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                        color: Color(0xFFE1E1E1), // Default color
                                                        fontSize: 10,
                                                        fontFamily: 'Montserrat',
                                                        fontWeight: FontWeight.w700,
                                                        height: 1.2,
                                                      ),
                                                    ) : Container(height: 15,)
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                children: [
                                                  Container(
                                                    width: Width*0.11,
                                                    height: Width*0.11,
                                                    decoration: ShapeDecoration(
                                                      color: Colors.white,
                                                      shape: OvalBorder(
                                                        side: BorderSide(
                                                          width: 2,
                                                          color: (dropStartTime != null &&
                                                                  dropEndTime !=
                                                                      null &&
                                                              unixTimeMilliseconds >=
                                                                  unixdropstart! &&
                                                              unixTimeMilliseconds <=
                                                                  unixdropstop!
                                                          )
                                                              ? Color(
                                                                  0xFFFF6600)
                                                              : Color(
                                                                  0xFFE1E1E1),
                                                        ),
                                                      ),
                                                    ),
                                                    child: Center(
                                                      child: Container(
                                                        width: Width*0.08,
                                                        height: Width*0.08,
                                                        decoration:
                                                            BoxDecoration(
                                                          image:
                                                              DecorationImage(
                                                            image: AssetImage(
                                                                'assets/school.png'),
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: Width*0.01,
                                                  ),
                                                  Text(
                                                    unixdropstart <= unixTimeMilliseconds ?
                                                    '${child?.dropRouteStartTime ?? 'no time'}' :
                                                     '${child?.pickupRouteEndTime ?? 'no time'}',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: (dropStartTime !=
                                                                  null &&
                                                              dropEndTime !=
                                                                  null &&
                                                          unixTimeMilliseconds >=
                                                                  unixdropstart! &&
                                                          unixTimeMilliseconds <=
                                                                  unixdropstop!)
                                                          ? Color(0xFFFF6600)
                                                          : Color(0xFFE1E1E1),
                                                      fontSize: 10,
                                                      fontFamily: 'Montserrat',
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      height: 0,
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Expanded(
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.only(top: 10,bottom: 7),
                                                      child: Image(
                                                        image: AssetImage(
                                                          (dropStartTime != null &&
                                                                  dropEndTime !=
                                                                      null &&
                                                              unixTimeMilliseconds >=
                                                                  unixdropstart! &&
                                                              unixTimeMilliseconds <=
                                                                  unixdropstop!)
                                                              ? 'assets/Line 8.png'
                                                              : 'assets/Line 7.png',
                                                        ),
                                                      ),
                                                    ),
                                                    child?.shotEta == "1" ? dropStartTime != null &&
                                                        dropEndTime !=
                                                            null &&
                                                        unixTimeMilliseconds >=
                                                            unixdropstart! &&
                                                        unixTimeMilliseconds <=
                                                            unixdropstop!
                                                    ?
                                                    EtaScreen(
                                                      childId: child?.childId, // End of pickup time
                                                    )
                                                        : Text(
                                                      "ETA\n00:00:00",
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                        color: Color(0xFFE1E1E1), // Default color
                                                        fontSize: 10,
                                                        fontFamily: 'Montserrat',
                                                        fontWeight: FontWeight.w700,
                                                        height: 1.2,
                                                      ),
                                                    )
                                                    : Container(height: 15,)
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                children: [
                                                  Container(
                                                    width: Width*0.11,
                                                    height: Width*0.11,
                                                    decoration: ShapeDecoration(
                                                      color: Colors.white,
                                                      shape: OvalBorder(
                                                        side: BorderSide(
                                                          width: 2,
                                                          color: (dropEndTime !=
                                                                      null &&
                                                              unixTimeMilliseconds ==
                                                                  unixdropstop!)
                                                              ? Color(
                                                                  0xFFFF6600)
                                                              : Color(
                                                                  0xFFE1E1E1),
                                                        ),
                                                      ),
                                                    ),
                                                    child: Center(
                                                      child: Container(
                                                        width: Width*0.08,
                                                        height: Width*0.08,
                                                        decoration:
                                                            BoxDecoration(
                                                          image:
                                                              DecorationImage(
                                                            image: AssetImage(
                                                                'assets/homeimg.png'),
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: Width*0.01,
                                                  ),
                                                  Text(
                                                    '${child?.dropRouteEndTime ?? 'no time'}',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: (dropEndTime !=
                                                                  null &&
                                                          unixTimeMilliseconds ==
                                                                  unixdropstop!)
                                                          ? Color(0xFFFF6600)
                                                          : Color(0xFFE1E1E1),
                                                      fontSize: 10,
                                                      fontFamily: 'Montserrat',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      height: 0,
                                                    ),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                child?.showPaymentButton == '0'
                                    ? SizedBox()
                                    : Padding(
                                        padding: const EdgeInsets.only(
                                            left: 16, right: 16),
                                        child: Container(
                                          width: double.infinity,
                                          // height: 74,
                                          decoration: ShapeDecoration(
                                            color: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                width: Width*0.01,
                                                color: Color(0xFFE1E1E1),
                                              ),
                                            ),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                left: 10, top: 5),
                                            child: Container(
                                              margin: EdgeInsets.fromLTRB(
                                                  0, 0, 5, 10),
                                              width: double.infinity,
                                              height: 54,
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                            margin:
                                                                EdgeInsets
                                                                    .fromLTRB(
                                                                        0,
                                                                        0,
                                                                        10,
                                                                        0),
                                                            width: 54,
                                                            height: 54,
                                                            decoration:
                                                                BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                27),
                                                                    border: Border.all(
                                                                        color: Color(
                                                                            0xffe1e1e1)),
                                                                    color: Color(
                                                                        0xffefecfd),
                                                                    image:
                                                                        DecorationImage(
                                                                      image: AssetImage(
                                                                          'assets/payment.jpg'),
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ))),
                                                        Container(
                                                          margin: EdgeInsets
                                                              .fromLTRB(
                                                                  0, 6, 0, 0),
                                                          height:
                                                              double.infinity,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Container(
                                                                margin: EdgeInsets
                                                                    .fromLTRB(
                                                                        0,
                                                                        10,
                                                                        0,
                                                                        0),
                                                                child: Text(
                                                                  'Make Payment' +"(${
                                                                      child?.paymentamt
                                                                          .toString()
                                                                          ?? '0'
                                                                    })",
                                                                  overflow: TextOverflow.ellipsis,
                                                                  maxLines: 1,
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Montserrat',
                                                                    fontSize:
                                                                        MediaQuery.of(
                                                                                context)
                                                                            .size
                                                                            .width * 0.04,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: Color(
                                                                        0xff000000),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        selectedChildid =
                                                            child?.childPaymentId;
                                                        print(
                                                            'childid : $selectedChildid : $selectedChildid');
                                                      });
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                PaymentPage(
                                                                  parentId: parentModels[0]
                                                                      .parentDetails
                                                                      ?.parentId,
                                                                    childId: child
                                                                        ?.childId,
                                                                  amount: child?.paymentamt,
                                                                  childPaymentId:
                                                                    selectedChildid, hyperSDK: widget.hyperSDK,

                                                                ),
                                                          )
                                                      ).then((value) {
                                                        // Handle the result if needed
                                                        setState(() {
                                                        });
                                                      });
                                                    },
                                                    child: Container(
                                                      width: 40,
                                                      height: 40,
                                                      margin:
                                                          EdgeInsets.fromLTRB(
                                                              0, 0, 5, 0),
                                                      decoration:
                                                          ShapeDecoration(
                                                        color:
                                                            Colors.deepOrange,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(14),
                                                        ),
                                                      ),
                                                      child: Image.asset(
                                                          'assets/pay.png'),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        )),
                                child?.pickupAttendantName != null ||
                                        child?.dropAttendantName != null
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                            left: 16, right: 16, bottom: 10),
                                        child: Container(
                                          width: double.infinity,
                                          // height: 80,
                                          decoration: ShapeDecoration(
                                            color: Colors.white,
                                            shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                  width: 1,
                                                  color: Color(0xFFE1E1E1),
                                                ),
                                                borderRadius: BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(14),
                                                    bottomRight:
                                                        Radius.circular(14))),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                left: 10, top: 5),
                                            child: Container(
                                              margin: EdgeInsets.fromLTRB(
                                                  0, 0, 5, 10),
                                              width: double.infinity,
                                              height: Width*0.13,
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                      child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      (() {
                                                        // if () {
                                                        return pickupStartTime != null &&
                                                                    pickupEndTime !=
                                                                        null &&
                                                            unixTimeMilliseconds >=
                                                                unixTimeMillisecondspickstart! &&
                                                            unixTimeMilliseconds <
                                                                        unixTimeMillisecondspickstop! ||
                                                                dropStartTime != null &&
                                                                    dropEndTime !=
                                                                        null &&
                                                                    unixTimeMilliseconds >=
                                                                        unixdropstart! &&
                                                                    unixTimeMilliseconds <
                                                                        unixdropstop!
                                                            ? Container(
                                                                margin: EdgeInsets
                                                                    .fromLTRB(
                                                                        0,
                                                                        0,
                                                                        10,
                                                                        0),
                                                                width: Width*0.135,
                                                                height: Width*0.135,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              27),
                                                                  border: Border.all(
                                                                      color: Color(
                                                                          0xffe1e1e1)),
                                                                  color: Color(
                                                                      0xffefecfd),
                                                                  image:
                                                                      DecorationImage(
                                                                    image:
                                                                        NetworkImage(
                                                                            () {
                                                                      String
                                                                          displayphoto =
                                                                          '';

                                                                      if (pickupStartTime != null &&
                                                                          pickupEndTime !=
                                                                              null && unixTimeMilliseconds >= unixTimeMillisecondspickstart! && unixTimeMilliseconds < unixTimeMillisecondspickstop!) {
                                                                        // Display pickupRouteEndTime
                                                                        displayphoto = child.pickupAttendantPhoto ?? 'Trip not Started';
                                                                      } else if (dropStartTime !=
                                                                          null &&
                                                                          dropEndTime !=
                                                                              null && unixTimeMilliseconds >=
                                                                          unixdropstart! &&
                                                                          unixTimeMilliseconds <
                                                                              unixdropstop!) {
                                                                        // Display dropRouteEndTime
                                                                        displayphoto =
                                                                            child.dropAttendantPhoto ??
                                                                                'Trip Not Started';
                                                                      }
                                                                      return displayphoto;
                                                                    }()),
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ),
                                                              )
                                                            : Container(margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                                                                width: 54,
                                                                height: 54,
                                                                decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              27),
                                                                  border: Border.all(
                                                                      color: Color(
                                                                          0xffe1e1e1)),
                                                                  color: Color(
                                                                      0xffefecfd),
                                                                  image:
                                                                      DecorationImage(
                                                                    image: AssetImage(
                                                                        'assets/attandent.jpg'),
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ),
                                                              );
                                                        // } else {
                                                        //   return Container(
                                                        //     margin: EdgeInsets
                                                        //         .fromLTRB(0, 0,
                                                        //             10, 0),
                                                        //     width: 54,
                                                        //     height: 54,
                                                        //     decoration:
                                                        //         BoxDecoration(
                                                        //       borderRadius:
                                                        //           BorderRadius
                                                        //               .circular(
                                                        //                   27),
                                                        //       border: Border.all(
                                                        //           color: Color(
                                                        //               0xffe1e1e1)),
                                                        //       color: Color(
                                                        //           0xffefecfd),
                                                        //       image:
                                                        //           DecorationImage(
                                                        //         image: AssetImage(
                                                        //             'assets/attandent.jpg'),
                                                        //         fit: BoxFit
                                                        //             .cover,
                                                        //       ),
                                                        //     ),
                                                        //   );
                                                        // }
                                                      })(),
                                                      Expanded(
                                                        child: Text(
                                                          (() {
                                                            String displayname =
                                                                '';

                                                            if (pickupStartTime != null &&
                                                                pickupEndTime !=
                                                                    null &&
                                                                unixTimeMilliseconds >=
                                                                    unixTimeMillisecondspickstart! &&
                                                                unixTimeMilliseconds <
                                                                    unixTimeMillisecondspickstop!) {
                                                              // Display pickupRouteEndTime
                                                              displayname =
                                                                  capitalize(child
                                                                          .pickupAttendantName) ??
                                                                      'no driver';
                                                            } else if (dropStartTime !=
                                                                    null &&
                                                                dropEndTime !=
                                                                    null &&
                                                                unixTimeMilliseconds >=
                                                                    unixdropstart! &&
                                                                unixTimeMilliseconds <
                                                                    unixdropstop!) {
                                                              // Display dropRouteEndTime
                                                              displayname =
                                                                  capitalize(child
                                                                          .dropAttendantName) ??
                                                                      'no driver';
                                                            } else {
                                                              // Display some default message or handle another case
                                                              displayname =
                                                                  'Trip Not Started';
                                                            }

                                                            return displayname;
                                                          })(),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Montserrat',
                                                            fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.03,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Color(
                                                                0xff000000),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                                  InkWell(
                                                    onTap: () {
                                                      String phoneNumber = '';

                                                      DateTime currentTime =
                                                          DateTime.now();
                                                      TimeOfDay
                                                          currentTimeOfDay =
                                                          TimeOfDay
                                                              .fromDateTime(
                                                                  currentTime);

                                                      if (pickupStartTime !=
                                                              null &&
                                                          pickupEndTime !=
                                                              null &&
                                                          unixTimeMilliseconds >=
                                                              unixTimeMillisecondspickstart! &&
                                                          unixTimeMilliseconds <
                                                              unixTimeMillisecondspickstop!) {
                                                        // Display pickupRouteEndTime
                                                        phoneNumber = child
                                                                ?.pickupAttendantPhone1 ??
                                                            'no number';
                                                      } else if (dropStartTime !=
                                                              null &&
                                                          dropEndTime != null &&
                                                          unixTimeMilliseconds >=
                                                              unixdropstart! &&
                                                          unixTimeMilliseconds <
                                                              unixdropstop!) {
                                                        // Display dropRouteEndTime
                                                        phoneNumber = child
                                                                ?.dropAttendantPhone1 ??
                                                            'no number';
                                                      } else {
                                                        // Display some default message or handle another case
                                                        phoneNumber = '';
                                                      }

                                                      launch("tel:$phoneNumber");
                                                    },
                                                    child: Container(
                                                      width: Width*0.1,
                                                      height: Width*0.1,
                                                      margin:
                                                          EdgeInsets.fromLTRB(
                                                              0, 0, 10, 0),
                                                      decoration:
                                                          ShapeDecoration(
                                                        color:
                                                            Color(0xFFFF6600),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(14),
                                                        ),
                                                      ),
                                                      child: Image.asset(
                                                          'assets/call-calling.png'),
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      // DateTime now =
                                                      //     DateTime.now();
                                                      // int currentHour =
                                                      //     now.hour;

                                                      String urlToLaunch;
                                                      if(child?.trackLiveUrl == '') {
                                                        if (pickupStartTime !=
                                                            null &&
                                                            pickupEndTime !=
                                                                null &&
                                                            unixTimeMilliseconds >=
                                                                unixTimeMillisecondspickstart! &&
                                                            unixTimeMilliseconds <
                                                                unixTimeMillisecondspickstop!) {
                                                          // Launch first URL
                                                          urlToLaunch = child
                                                              ?.galaPickupUrl ??
                                                              'no rout';
                                                        } else
                                                        if (dropStartTime !=
                                                            null &&
                                                            dropEndTime !=
                                                                null &&
                                                            unixTimeMilliseconds >=
                                                                unixdropstart! &&
                                                            unixTimeMilliseconds <=
                                                                unixdropstop!) {
                                                          // Launch second URL
                                                          urlToLaunch = child
                                                              ?.galaDropUrl ??
                                                              'no rout';
                                                        } else {
                                                          urlToLaunch = child?.galaDropUrl ?? 'no rout';
                                                        }
                                                      } else {
                                                        urlToLaunch = child?.trackLiveUrl ;
                                                      }
                                                       print("track : $urlToLaunch");
                                                      _navigateToWebView(
                                                       context, urlToLaunch);
                                                      print("url --- "+urlToLaunch);
                                                      print("url --- "+dropStartTime.toString());
                                                      },

                                                    child: Container(
                                                      width: Width*0.1,
                                                      height: Width*0.1,
                                                      margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                                                      decoration:
                                                          ShapeDecoration(
                                                        color: Colors.black,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(14),
                                                        ),
                                                      ),
                                                      child: Image.asset(
                                                          'assets/routing.png'),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ))
                                    : Padding(
                                        padding: const EdgeInsets.only(
                                            left: 16, right: 16, bottom: 10),
                                        child: Container(
                                          width: double.infinity,
                                          height: 15,
                                          decoration: ShapeDecoration(
                                            color: Colors.white,
                                            shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                  width: 1,
                                                  color: Color(0xFFE1E1E1),
                                                ),
                                                borderRadius: BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(14),
                                                    bottomRight:
                                                        Radius.circular(14))),
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                      // Other UI elements based on the child properties
                    ),
                  ],
                ],
              ],
            ],
          ),
        );
        }
        ),
      ],
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

  void fetchData() async {
    try {
      isLoading(true);
      await apicontroller.Fetchdata();
    } finally {
      isLoading(false);
    }
  }

  int getCurrentHour() {
    DateTime now = DateTime.now();
    return now.hour;
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    notificationServies.requestNotificationPermission();
    notificationServies.getToken().then((value){
      print("token : $value");
    }) ;
    notificationServies.firebaseinit(context);
    // _getLocation();
    _getIpAddress();
  }

  void loginlog() async {
    try {
      final response = await post(Uri.parse(Constants.loginlog), body: {
        'parent_id': Constants.parentId,
        'parent_firebase_id': Constants.firebaseid,
        'ip_address': Constants.IpAddress,
        'latitude': Constants.latitude,
        'longitude': Constants.longitude
      });
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

  Future<void> _getIpAddress() async {
    final response =
        await http.get(Uri.parse('https://api64.ipify.org?format=json'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = await json.decode(response.body);
      setState(() {
        ipAddress = data['ip'];
      });
      Constants.IpAddress = ipAddress;
      print('ip address : ${Constants.IpAddress}');
    } else {
      setState(() {
        ipAddress = 'Failed to retrieve IP address';
      });
    }
  }

  // Future<void> _getLocation() async {
  //   final location = Location();
  //
  //   try {
  //     var _locationData = await location.getLocation();
  //     setState(() {
  //       _currentLocation = _locationData;
  //     });
  //     Constants.latitude = _currentLocation!.latitude.toString();
  //     Constants.longitude = _currentLocation!.longitude.toString();
  //
  //     print('lat lag : ${Constants.latitude} : ${Constants.longitude}');
  //       } catch (e) {
  //     print("Error getting location: $e");
  //   }
  // }

  void _navigateToWebView(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewPage(url: url),
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

  // Future<dynamic> eta(String? id) async {
  //   if (id == null || id.isEmpty) {
  //     return null;
  //   }
  //
  //   try {
  //     final response = await http.post(
  //         Uri.parse("${ApiConfige.BASE_URL}/eta.php"),
  //         body: {
  //           'child_id': id
  //         }
  //     );
  //
  //     if (response.statusCode == 200) {
  //       var data = jsonDecode(response.body.toString());
  //       print(data);
  //
  //       if (data['success_code'] == 1) {
  //         return data;
  //       }
  //     }
  //     return null;
  //   } catch(e) {
  //     print(e.toString());
  //     return null;
  //   }
  // }
}

class WebViewPage extends StatefulWidget {
  final String url;

  WebViewPage({required this.url});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}


class _WebViewPageState extends State<WebViewPage> {
  Apicontroller apicontroller = Get.put(Apicontroller());
  late final WebViewController controller;
  bool showCloseButton = false;
  bool showBanners = true; // Initially, the close button is not visible
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));

    // Start a timer to show the close button after 10 seconds
    _timer = Timer(Duration(seconds: 10), () {
      setState(() {
        showCloseButton = true; // Show the close button after 10 seconds
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  Widget buildCarouselSlider(List<parentmodel> parentModels) {
    var banners =
    parentModels.isNotEmpty ? parentModels[0].bannerList ?? [] : [];

    return showBanners && banners.isNotEmpty
        ? Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Column(
                children: [
          Stack(
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  height: MediaQuery.of(context).size.width*0.57,
                  viewportFraction: 1.0,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 3),
                  onPageChanged: (index, reason) {
                    // Your existing onPageChanged logic...
                  },
                ),
                items: banners.map((banner) {
                  return Builder(
                    builder: (BuildContext context) {
                      return ClipRRect(
                        child: Image.network(
                          banner.bannerImageDisplay ?? '',
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFFFF6600)),
                                strokeWidth: 5.0,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              // Close button (X) displayed inside the banner after 10 seconds
              if (showCloseButton)
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        showBanners = false; // Hide the button when clicked
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
            ],
          ),
                ],
              ),
        )
        : Container();

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

  @override
  Widget build(BuildContext context) {
    var parentModels = apicontroller.apimodel ?? <parentmodel>[];
    double Width = MediaQuery.of(context).size.width;
    double Height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: Width*0.13,
                    height: Width*0.13,
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
                SizedBox(width: Width*0.04),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Map',
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
          buildCarouselSlider(parentModels),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 5, right: 5, bottom: 10),
              child: Container(
                width: double.infinity,
                decoration: ShapeDecoration(
                  color: Colors.black,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: Width*0.001,
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





