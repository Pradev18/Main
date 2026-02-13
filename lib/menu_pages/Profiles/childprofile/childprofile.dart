import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gala_travels_app/menu_pages/Profiles/childprofile/alternate_person.dart';
import 'package:gala_travels_app/menu_pages/Profiles/childprofile/leave.dart';
import 'package:gala_travels_app/menu_pages/Profiles/childprofile/selfpickdrop.dart';
import 'package:gala_travels_app/menu_pages/Profiles/childprofile/attendancereport.dart';
import 'package:gala_travels_app/menu_pages/Profiles/childprofile/qr_scanner.dart';
import 'package:gala_travels_app/menu_pages/constants/constants.dart';
import 'package:gala_travels_app/menu_pages/menubar.dart';
import 'package:gala_travels_app/model/parent_model.dart';

import 'package:get/get.dart';
import 'package:http/http.dart'as http;

class ChildProfile extends StatefulWidget {
  final ChildDetails child;

  const ChildProfile({Key? key, required this.child}) : super(key: key);

  @override
  State<ChildProfile> createState() => _ChildProfileState();
}

class _ChildProfileState extends State<ChildProfile> {
  var isLoading = false.obs;
  String selectedChildId = '';
  late String action;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFAF9F6),
      body: Obx(
        () {
          if (isLoading.value) {
            return Center(child: CircularProgressIndicator());
          } else {
            return buildprofilePage();
          }
        },
      ),
    );
  }

  Widget buildprofilePage() {
    return Scaffold(
      backgroundColor: Color(0xffFAF9F6),
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildheaderSection(),
            buildUserProfileSection(),
            buildSettingSection(),
          ],
        ),
      ),
    );
  }

  Widget buildheaderSection() {
    return Container(
      padding: EdgeInsets.only(top: 46, left: 16, right: 16, bottom: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              // Navigate back when the image is tapped
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
                  'Children Profile',
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
    );
  }

  Widget buildUserProfileSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: (){
            _ShowBottomSheet(context);
          },
          child: Stack(
            children: [
              widget.child.childPhotoUrl == ''
                           ? Container(
                width: 70,
                height: 70,
                decoration: ShapeDecoration(
                  color: Colors.orange,
                  image: DecorationImage(
                    image: AssetImage(
                      widget.child.childGender == 'MALE'
                          ? 'assets/sujalhassan.png'
                          : 'assets/laylaimg.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                  shape: CircleBorder(
                    side: BorderSide(width: 2, color: Color(0xFFFF6600)),
                  ),
                ),
              )
                           : Container(
                width: 70,
                height: 70,
                decoration: ShapeDecoration(
                  color: Colors.orange,
                  image: DecorationImage(
                    image: NetworkImage(widget.child.childPhotoUrl ?? 'no photo'),
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
                  width: 25,
                  height: 25,
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
        SizedBox(
          height: 20,
        ),
        Text(
          '${capitalize(widget.child.childName)}',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            height: 0,
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Class :  ',
                style: TextStyle(
                  color: Color(0xFF747474),
                  fontSize: MediaQuery.of(context).size.width > 400 ? 14 : 12,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w400,
                  height: 0,
                ),
              ),
              TextSpan(
                text:
                    '${widget.child.childStandard ?? 'No Child Name'} ${widget.child.childDivision ?? 'No Child Name'}',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w600,
                  height: 0,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        )
      ],
    );
  }

  Widget buildSettingSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              selectedChildId =
                  widget.child.childId!; // Store the selected child ID
            });
            print(widget.child.childId);
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => leave(childId: selectedChildId),
                ));
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
            child: Container(
              width: double.infinity,
              height: 64,
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
                    child: CircleAvatar(
                      backgroundImage: AssetImage('assets/leave2.jpg')
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.all(8.0),
                  //   child: Image(image: AssetImage('assets/leave.jpg')),
                  // ),
                  Text(
                    'Leave',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: MediaQuery.of(context).size.width > 400 ? 16 : 14,
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
        GestureDetector(
          onTap: () {
            setState(() {
              selectedChildId =
                  widget.child.childId!; // Store the selected child ID
            });
            print(widget.child.childId);
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Selfpickdrop(childId: selectedChildId),
                ));
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
            child: Container(
              width: double.infinity,
              height: 64,
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
                    child: ClipOval(
                      child: Image.asset(
                        'assets/selfdrop.jpg',
                        fit: BoxFit.contain, // Ensures the entire image fits within the circle
                        width: 50.0,        // Set width for the circle
                        height: 55.0,       // Set height for the circle
                      ),
                    ),
                  ),

                  // Padding(
                  //   padding: const EdgeInsets.all(8.0),
                  //   child: Image(image: AssetImage('assets/selfdrop.jpg')),
                  // ),
                  Text(
                    'Self Pick Drop',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: MediaQuery.of(context).size.width > 400 ? 16 : 14,
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
        GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AltPerson(),
                ));
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
            child: Container(
              width: double.infinity,
              height: 64,
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
                    child: CircleAvatar(
                        backgroundImage: AssetImage('assets/add-person.png')
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.all(8.0),
                  //   child: Image(image: AssetImage('assets/add-person.png')),
                  // ),
                  Text(
                    'Alternate Person',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: MediaQuery.of(context).size.width > 400 ? 16 : 14,
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
        GestureDetector(
          onTap: (){
            setState(() {
              selectedChildId =
              widget.child.childId!; // Store the selected child ID
            });
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => report(childId: selectedChildId)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
            child: Container(
              width: double.infinity,
              height: 64,
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
                    child: CircleAvatar(
                        backgroundImage: AssetImage('assets/report1.png')
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.all(8.0),
                  //   child: Image(image: AssetImage('assets/report.jpg')),
                  // ),
                  Text(
                    'Report',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: MediaQuery.of(context).size.width > 400 ? 16 : 14,
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
        GestureDetector(
          onTap: (){
            setState(() {
              selectedChildId =
              widget.child.childId!; // Store the selected child ID
            });
            _showActionDialog();
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 16,right: 16, top: 16),
            child: Container(
              width: double.infinity,
              height: 64,
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
                    child: Image(image: AssetImage('assets/Scanner.png')),
                  ),
                  Text(
                    'QR Scanner',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: MediaQuery.of(context).size.width > 400 ? 16 : 14,
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
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
          child: Container(
            width: double.infinity,
            height: 64,
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
                  child: Image(image: AssetImage('assets/uparrow.png')),
                ),
                Flexible(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Pickup Route : ',
                          style: TextStyle(
                            color: Color(0xFF747474),
                            fontSize: MediaQuery.of(context).size.width > 400 ? 14 : 12,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w400,
                            height: 0,
                          ),
                        ),
                        TextSpan(
                          text:
                          '${widget.child.pickupRouteName ?? 'No Route'}',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: MediaQuery.of(context).size.width > 400 ? 14 : 12,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w600,
                            height: 0,
                          ),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                // Spacer(), // or use Expanded()
                // Padding(
                //   padding: const EdgeInsets.only(right: 10),
                //   child: Image(image: AssetImage('assets/back-arrow.png')),
                // )
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
          child: Container(
            width: double.infinity,
            height: 64,
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
                  child: Image(image: AssetImage('assets/downarrow.png')),
                ),
                Flexible(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Drop Route : ',
                          style: TextStyle(
                            color: Color(0xFF747474),
                            fontSize: MediaQuery.of(context).size.width > 400 ? 14 : 12,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w400,
                            height: 0,
                          ),
                        ),
                        TextSpan( 
                          text:
                          '${widget.child.dropRouteName ?? 'No Route'}',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: MediaQuery.of(context).size.width > 400 ? 14 : 12,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w600,
                            height: 0,
                          ),
                        ),
                  
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                // Spacer(), // or use Expanded()
                // Padding(
                //   padding: const EdgeInsets.only(right: 10),
                //   child: Image(image: AssetImage('assets/back-arrow.png')),
                // )
              ],
            ),
          ),
        ),
        SizedBox(
          height: 30,
        ),
      ],
    );
  }

  void _showActionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose Route'),
          content: Text('Please Select Route'),
          actions: [
            TextButton(
              child: Text('Pickup'),
              onPressed: () {
                setState(() {
                  action = 'PICKUP';
                });
                Navigator.of(context).pop(); // Close the dialog
                _navigateToQRScanner();
              },
            ),
            TextButton(
              child: Text('Drop'),
              onPressed: () {
                setState(() {
                  action = 'DROP';
                });
                Navigator.of(context).pop(); // Close the dialog
                _navigateToQRScanner();
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToQRScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScanner(childId: selectedChildId, action: action),
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

  void _ShowBottomSheet(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return  Editchild(child: widget.child,);
      },
    );
  }
}

class Editchild extends StatefulWidget {
  final ChildDetails child;

  const Editchild({Key? key, required this.child}) : super(key: key);
  @override
  _EditchildState createState() => _EditchildState();
}

class _EditchildState extends State<Editchild> {
  File? _selectedImage;
  TextEditingController ChildName = TextEditingController();
  TextEditingController std = TextEditingController();
  TextEditingController div = TextEditingController();
  String ChildId = '';
  bool _isLoading = false; // State variable to manage loading state

  @override
  void initState() {
    super.initState();
    ChildId = widget.child.childId!;
    ChildName.text = widget.child.childName!;
    std.text = widget.child.childStandard!;
    div.text = widget.child.childDivision!;
    print(ChildId);
  }

  void update_child(String name, String standard, String division) async {
    setState(() {
      _isLoading = true; // Show progress indicator when submitting
    });
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(Constants.editchild),
      );

      request.fields['child_id'] = ChildId;
      request.fields['child_name'] = name;
      request.fields['child_standard'] = standard;
      request.fields['child_division'] = division;

      if (_selectedImage != null) {
        List<int> imageBytes = await _selectedImage!.readAsBytes();
        http.MultipartFile file = http.MultipartFile.fromBytes(
          'child_photo',
          imageBytes,
          filename: 'photo.jpg',
        );
        request.files.add(file);
      }

      final response = await request.send();
      final responseString = await http.Response.fromStream(response).then((value) => value.body);

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
                content: Text('Updated Child Details', textAlign: TextAlign.center,),
                backgroundColor: Colors.white,
              );
            },
          ).then((result) {
            if (result != null && result) {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Menubar(),), (route) => false,);
            }
          });
          print(data);
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Center(child: Image.asset('assets/error.png')),
                content: Text(errorMsg, textAlign: TextAlign.center,),
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
      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6600)),
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
              'Edit Child Profile',
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
                  FilePickerResult? result = await FilePicker.platform.pickFiles();

                  // Update the selected image
                  if (result != null) {
                    setState(() {
                      _selectedImage = File(result.files.single.path!);
                    });
                  }
                },
                child: Container(
                  width: 100,
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
              controller: ChildName,
              decoration: InputDecoration(
                labelText: 'Child Name',
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
            SizedBox(height: 16),
            SuggestionTextField(
              controller: std,
              suggestions: ['NURSERY', 'Jr kg', 'Sr kg', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'],
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: div,
              decoration: InputDecoration(
                labelText: 'Division',
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
                update_child(
                  ChildName.text.toString(),
                  std.text.toString(),
                  div.text.toString(),
                );
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
                  'Update Child Profile',
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

class SuggestionTextField extends StatefulWidget {
  final TextEditingController controller;
  final List<String> suggestions;

  SuggestionTextField({required this.controller, required this.suggestions});

  @override
  _SuggestionTextFieldState createState() => _SuggestionTextFieldState();
}

class _SuggestionTextFieldState extends State<SuggestionTextField> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  List<String> _filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      _filterSuggestions();
      _updateOverlay();
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _filterSuggestions() {
    final text = widget.controller.text;
    if (text.isEmpty) {
      _filteredSuggestions = [];
    } else {
      _filteredSuggestions = widget.suggestions
          .where((s) => s.toLowerCase().contains(text.toLowerCase()))
          .toList();
    }
  }

  void _updateOverlay() {
    _removeOverlay();
    if (_filteredSuggestions.isEmpty) {
      return;
    }
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Size size = renderBox.size;
    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 5.0),
          child: Material(
            elevation: 4.0,
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: _filteredSuggestions.map((suggestion) {
                return ListTile(
                  title: Text(suggestion),
                  onTap: () {
                    widget.controller.text = suggestion;
                    _removeOverlay();
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: widget.controller,
        decoration: InputDecoration(
          labelText: 'Standard',
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
    );
  }
}

