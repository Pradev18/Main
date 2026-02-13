import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gala_travels_app/menu_pages/constants/constants.dart';
import 'package:gala_travels_app/menu_pages/menubar.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import '../../../api_confige.dart';

class AltPerson extends StatefulWidget {
  @override
  State<AltPerson> createState() => _AltPersonState();
}

class _AltPersonState extends State<AltPerson> {
  List<Map<String, dynamic>> alternatePersons = [];
  bool _isLoading = false; // Add this variable

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      _isLoading = true; // Show progress indicator
    });
    try {
      final response = await http.get(Uri.parse(
          '${ApiConfige.BASE_URL}/get_parent_alternate_person_list.php?parent_id=${Constants.parentId}'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          alternatePersons = List.from(data['alternate_person_list']);
        });

        if (alternatePersons.isNotEmpty) {
          Constants.alternateId = alternatePersons[0]['alternate_person_id'];
          Constants.setalternate = alternatePersons[0]['set_alternate'];
          print('set : ${Constants.setalternate}');
          print('id ${Constants.alternateId}');
        }

        print('data : $alternatePersons');
        // ApiConstants.alternateId =
        //     data['alternate_person_list']['alternate_person_id'];
        // print(ApiConstants.alternateId);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false; // Hide progress indicator
      });
    }
  }

  void clear() async {
    try {
      Response response = await post(
          Uri.parse(
              '${ApiConfige.BASE_URL}/parent_clear_alternate_person_option.php'),
          body: {'parent_id': Constants.parentId});
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
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
                content: Text('Alternanate Cleaned', textAlign: TextAlign.center,),
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
        fetchData();
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
      body: _isLoading ? Center(child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>( Color(0xFFFF6600)),
        strokeWidth: 5.0,))
          : Column(
        children: [
          CustomAppBar(onAddPressed: _showBottomSheet),
          Expanded(child: DetailsList(alternatePersons: alternatePersons)),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(onPressed: clear, child: Text('Clear'), backgroundColor: Colors.white,foregroundColor: Colors.black,),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return AddDetails(
            onDetailsAdded: fetchData); // Pass the fetchData method
      },
    );
  }
}

class CustomAppBar extends StatelessWidget {
  final VoidCallback onAddPressed;

  const CustomAppBar({required this.onAddPressed});

  @override
  Widget build(BuildContext context) {
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
                  'Alternate Person',
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
          GestureDetector(
            onTap: onAddPressed,
            child: Container(
                width: 52,
                height: 52,
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1, color: Color(0xFFE1E1E1)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Image.asset('assets/add.png')),
          ),
        ],
      ),
    );
  }
}

class DetailsList extends StatefulWidget {
  final List<Map<String, dynamic>> alternatePersons;

  const DetailsList({required this.alternatePersons});

  @override
  State<DetailsList> createState() => _DetailsListState();
}

class _DetailsListState extends State<DetailsList> {
  int selectedPersonIndex = -1;

  void delete(String alternatePersonId) async {
    try {
      Response response = await post(
        Uri.parse(
            '${ApiConfige.BASE_URL}/parent_delete_alternate_person.php'),
        body: {
          'parent_id': Constants.parentId,
          'alternate_person_id': alternatePersonId,
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
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
                content: Text('Delete Successfully', textAlign: TextAlign.center,),
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
        // Refresh the UI after deletion
        _AltPersonState? altPersonState =
            context.findAncestorStateOfType<_AltPersonState>();
        altPersonState?.fetchData();
      } else {
        print('Failed to Delete');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void edit(Map<String, dynamic> alternatePerson) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditDetails(alternatePerson: alternatePerson);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.alternatePersons.isEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(image: AssetImage('assets/nodataimg.png')),
              SizedBox(
                height: 20,
              ),
              Text(
                'No Data Available',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  height: 0,
                ),
              )
            ],
          )
        : Container(
            height: MediaQuery.of(context)
                .size
                .height, // Set a fixed height or use other constraints
            child: ListView.builder(
              itemCount: widget.alternatePersons.length,
              itemBuilder: (context, index) {
                final person = widget.alternatePersons[index];
                final String isSetAlternate =
                    person['set_alternate'].toString();
                print('setalt = $isSetAlternate');
                return Padding(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 10, bottom: 5),
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    decoration: ShapeDecoration(
                      color: isSetAlternate == '1'
                          ? Colors.orange
                              .shade400 // Change the highlight color as needed
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 1, color: Color(0xFFE1E1E1)),
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: ShapeDecoration(
                                  // color: Colors.orange,
                                  image: DecorationImage(
                                    image: NetworkImage(
                                        person['alternate_person_photo_url']),
                                    fit: BoxFit.cover,
                                  ),
                                  shape: OvalBorder(
                                    side: BorderSide(
                                        width: 2, color: Color(0xFFFF6600)),
                                  ),
                                ),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  person['alternate_person_name'],
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
                                  'Alternate Person',
                                  style: TextStyle(
                                    color: Color(0xFF747474),
                                    fontSize: 12,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w500,
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
                                        text: person['alternate_person_phone'],
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
                            ),
                            Spacer(),
                            Checkbox(
                              value: index == selectedPersonIndex,
                              onChanged: (bool? value) {
                                setState(() {
                                  selectedPersonIndex = index;
                                });
                                if (value == true) {
                                  changeAlternatePerson(person['alternate_person_id']);
                                  // showAlertBox();
                                }
                              },
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 16, right: 8),
                                child: ElevatedButton(
                                  onPressed: () {
                                    edit(person);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: Container(
                                    // width: double.infinity,
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                    child: Text(
                                      'Edit',
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
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 8, right: 16),
                                child: ElevatedButton(
                                  onPressed: () {
                                    showalertBox(person['alternate_person_id']);
                                    // delete(person['alternate_person_id']);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFFF6600),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: Container(
                                    // width: double.infinity,
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                    child: Text(
                                      'Delete',
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
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
  }

  // void showAlertBox(String alternatePersonId) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Change Alternate Person'),
  //         content: Text('Do you want to change the alternate person?'),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //             },
  //               child: Text('No',style: TextStyle(color: Colors.black),)
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               Navigator.pop(context); // Close the alert box
  //               changeAlternatePerson(alternatePersonId);
  //             },
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: Color(0xFFFF6600),
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(25),
  //               ),
  //             ),
  //             child: Text('Yes',style: TextStyle(color: Colors.white),),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void showalertBox(String alternatePersonId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Alternate Person'),
          content: Text('Do you want to delete the alternate person?'),
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
                delete(alternatePersonId);
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

  void changeAlternatePerson(String alternatePersonId) async {
    try {
      Response response = await post(
        Uri.parse(
            '${ApiConfige.BASE_URL}/parent_change_alternate_person.php'),
        body: {
          'parent_id': Constants.parentId,
          'alternate_person_id': alternatePersonId
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
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
                content: Text('Alternate Person Changed Successfully', textAlign: TextAlign.center,),
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
        print('Failed to change alternate person');
      }
    } catch (e) {
      print(e.toString());
    }
  }
}

class AddDetails extends StatefulWidget {
  final Function onDetailsAdded; // Change the type to Function

  const AddDetails({Key? key, required this.onDetailsAdded}) : super(key: key);

  @override
  State<AddDetails> createState() => _AddDetailsState();
}

class _AddDetailsState extends State<AddDetails> {
  File? _selectedImage;
  final _formKey = GlobalKey<FormState>();
  TextEditingController altName = TextEditingController();
  TextEditingController altNumber = TextEditingController();
  bool _isLoading = false; // State variable to manage loading state

  void addandupadate_person(
      String name, String number, VoidCallback onCompletion) async {
    setState(() {
      _isLoading = true; // Show progress indicator when submitting
    });
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(Constants.alternate_add),
      );

      request.fields['parent_id'] = Constants.parentId;
      request.fields['alternate_person_id'] = '0';
      request.fields['alternate_person_name'] = name;
      request.fields['alternate_person_phone'] = number;
      request.fields['set_alternate'] = '0';

      if (_selectedImage != null) {
        List<int> imageBytes = await _selectedImage!.readAsBytes();
        http.MultipartFile file = http.MultipartFile.fromBytes(
          'alternate_person_photo',
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
                content: Text('Alternate Person Add Successfully', textAlign: TextAlign.center,),
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
        widget.onDetailsAdded(); // Call the method passed from _AltPersonState
        onCompletion();
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
    return _buildBottomSheetContent();
  }

  Widget _buildBottomSheetContent() {
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Alternate Person Details',
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
                controller: altName,
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
              SizedBox(height: 16),
              TextFormField(
                controller: altNumber,
                decoration: InputDecoration(
                  labelText: 'Number ',
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
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value?.length != 10) {
                    return 'Please enter a 10 valid number';
                  }
                  return null;
                },
              ),
              Spacer(),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                  addandupadate_person(
                      altName.text.toString(), altNumber.text.toString(), () {
                    Navigator.pop(context);
                  });
                  }
                  altName.clear();
                  altNumber.clear();
                  _selectedImage!.delete();
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
    );
  }
}

class EditDetails extends StatefulWidget {
  final Map<String, dynamic> alternatePerson;

  const EditDetails({Key? key, required this.alternatePerson})
      : super(key: key);

  @override
  State<EditDetails> createState() => _EditDetailsState();
}

class _EditDetailsState extends State<EditDetails> {
  File? _selectedImage;
  final _formKey = GlobalKey<FormState>();
  TextEditingController altName = TextEditingController();
  TextEditingController altNumber = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data
    altName.text = widget.alternatePerson['alternate_person_name'];
    altNumber.text = widget.alternatePerson['alternate_person_phone'];
  }

  @override
  Widget build(BuildContext context) {
    return _buildEditDialog();
  }

  Widget _buildEditDialog() {
    return SingleChildScrollView(
      child: AlertDialog(
        title: Text('Edit Alternate Person Details'),
        content: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: GestureDetector(
                  onTap: () async {
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles();

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
                controller: altName,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: altNumber,
                decoration: InputDecoration(labelText: 'Number'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  if (value.length != 10) {
                    return 'Please enter a valid 10-digit phone number';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel',style: TextStyle(color: Colors.black,),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _updatePersonDetails(
                  widget.alternatePerson['alternate_person_id'],
                  altName.text.toString(),
                  altNumber.text.toString(),
                      () {

                  },
                );
              }

            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF6600),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text('Save',style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
    );
  }

  void _updatePersonDetails(
    String alternatePersonId,
    String name,
    String number,
    VoidCallback onCompletion,
  ) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(Constants.alternate_add),
      );

      request.fields['parent_id'] = Constants.parentId;
      request.fields['alternate_person_id'] = alternatePersonId;
      request.fields['alternate_person_name'] = name;
      request.fields['alternate_person_phone'] = number;
      request.fields['set_alternate'] =
          '1'; // Indicate that it's for editing details

      if (_selectedImage != null) {
        List<int> imageBytes = await _selectedImage!.readAsBytes();
        http.MultipartFile file = http.MultipartFile.fromBytes(
          'alternate_person_photo',
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
        print(data);
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
                content: Text('Alternate Person Updated', textAlign: TextAlign.center,),
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
        // Refresh the UI after editing details
        _AltPersonState? altPersonState =
            context.findAncestorStateOfType<_AltPersonState>();
        altPersonState?.fetchData();
        onCompletion();
      } else {
        print('Failed: $responseString');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
