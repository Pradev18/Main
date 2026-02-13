import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gala_travels_app/menu_pages/constants/constants.dart';
import 'package:http/http.dart';
import 'package:http/http.dart'as http;

import '../../../api_confige.dart';

class Selfpickdrop extends StatefulWidget {
  final String childId;

  const Selfpickdrop({super.key, required this.childId});

  @override
  State<Selfpickdrop> createState() => _SelfpickdropState();
}

class _SelfpickdropState extends State<Selfpickdrop> {

  void pickdropApply() async {
    final startDateFormatted = '${_startDate.toLocal()}'.split(' ')[0];
    final endDateFormatted = '${_endDate.toLocal()}'.split(' ')[0];

    try {
      Response response = await post(
        Uri.parse('${ApiConfige.BASE_URL}/parent_apply_child_self_pickup_drop.php'),
        body: {
          'parent_id': Constants.parentId,
          'child_id': widget.childId,
          'start_date': startDateFormatted,
          'end_date': endDateFormatted,
          'self_pickup_drop_type': selectedLeaveType ?? ''
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
                content: Text('Self Pickup Drop Applied', textAlign: TextAlign.center,),
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
        // After successfully applying for leave, refresh the leave list
        SelfPickdropData();
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildHeaderSection(),
            DateSection(),
            buildPickdropList(),
          ],
        ),
      ),
    );
  }

  Widget buildHeaderSection() {
    return Container(
      padding: EdgeInsets.only(top: 46, left: 16, right: 16, bottom: 16),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(width: 1, color: Color(0xFFE1E1E1)),
            ),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  // Navigate back when the image is tapped
                  Navigator.of(context).pop();
                },
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
                  'Apply For Self Pickup Drop',
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

  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now();
    _endDate = DateTime.now();
    _startDateController = TextEditingController(text: '${_startDate.day.toString().padLeft(2, '0')}/${_startDate.month.toString().padLeft(2, '0')}/${_startDate.year}');
    _endDateController = TextEditingController(text: '${_endDate.day.toString().padLeft(2, '0')}/${_endDate.month.toString().padLeft(2, '0')}/${_endDate.year}');
    print(widget.childId);

    SelfPickdropData();
  }

  Future<void> _selectStartDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101), // Set an arbitrary future date as the last selectable date
    );

    if (picked != null && picked != _startDate) {
      // If start date is after end date, update end date to match start date
      if (_endDate.isBefore(picked)) {
        setState(() {
          _endDate = picked;
          _endDateController.text =
          '${_endDate.day.toString().padLeft(2, '0')}/${_endDate.month.toString().padLeft(2, '0')}/${_endDate.year}';
        });
      }
      setState(() {
        _startDate = picked;
        _startDateController.text =
        '${_startDate.day.toString().padLeft(2, '0')}/${_startDate.month.toString().padLeft(2, '0')}/${_startDate.year}';
      });

      _selectEndDate(context);
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101), // Set an arbitrary future date as the last selectable date
    );

    if (picked != null && picked != _endDate) {
      // If end date is before start date, update start date to match end date
      if (_startDate.isAfter(picked)) {
        setState(() {
          _startDate = picked;
          _startDateController.text =
          '${_startDate.day.toString().padLeft(2, '0')}/${_startDate.month.toString().padLeft(2, '0')}/${_startDate.year}';
        });
      }
      setState(() {
        _endDate = picked;
        _endDateController.text =
        '${_endDate.day.toString().padLeft(2, '0')}/${_endDate.month.toString().padLeft(2, '0')}/${_endDate.year}';
      });
    }
  }


  void Selfpickupapply() {
    String formattedStartDate = '${_startDate.toLocal()}'.split(' ')[0];
    String formattedEndDate = '${_endDate.toLocal()}'.split(' ')[0];

    print('Selected Start Date: $formattedStartDate');
    print('Selected End Date: $formattedEndDate');
    pickdropApply();
  }

  String? selectedLeaveType;


  Widget DateSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Container(
                  height: 50,
                  decoration: ShapeDecoration(
                    color: Color(0xFFF7F3F4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.date_range_outlined),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _startDateController,
                          readOnly: true,
                          onTap: () => _selectStartDate(context),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 16),
                            // labelText: 'Start Date',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 50,
                  decoration: ShapeDecoration(
                    color: Color(0xFFF7F3F4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.date_range_outlined),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _endDateController,
                          readOnly: true,
                          onTap: () => _selectEndDate(context),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 16),
                            // labelText: 'End Date',
                            border: InputBorder.none,
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
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: DropdownButtonFormField<String>(
              value: selectedLeaveType,
              onChanged: (String? newValue) {
                setState(() {
                  selectedLeaveType = newValue!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Select Type',
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: Colors.orange, // Set the border color when focused
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: Colors.orange, // Set the border color when not focused
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
              ),
              items: <String>['PICKUP', 'DROP', 'BOTH']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
          child: ElevatedButton(
            onPressed: () {
              Selfpickupapply();
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
                'Apply',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  height: 0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> SelfPickdata = [];
  bool _isLoading = false; // Add this variable


  SelfPickdropData() async {
    setState(() {
      _isLoading = true; // Show progress indicator
    });
    try {
    final response = await http.get(Uri.parse(
        '${ApiConfige.BASE_URL}/get_parent_child_self_pickup_drop_list.php?parent_id=${Constants.parentId}&child_id=${widget.childId}'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final SelfPickupdetails = jsonData['leave_list'];

      setState(() {
        SelfPickdata = List<Map<String, dynamic>>.from(SelfPickupdetails);
      });

      print(SelfPickdata);

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

  // Widget buildPickdropList() {
  //   return Column(
  //     children: [
  //       Align(
  //         alignment: Alignment.topLeft,
  //         child: Padding(
  //           padding: const EdgeInsets.all(16),
  //           child: Text(
  //             'Self PickupDrop List',
  //             style: TextStyle(
  //               color: Colors.black,
  //               fontSize: 20,
  //               fontFamily: 'Montserrat',
  //               fontWeight: FontWeight.w600,
  //               height: 0,
  //             ),
  //           ),
  //         ),
  //       ),
  //       Container(
  //         height: MediaQuery.of(context).size.height * 0.57,
  //         child: Center(
  //           child: _isLoading ? CircularProgressIndicator(
  //             valueColor: AlwaysStoppedAnimation<Color>( Color(0xFFFF6600)),
  //             strokeWidth: 5.0,
  //           )
  //          : SelfPickdata.isEmpty
  //               ? Column(
  //             // crossAxisAlignment: CrossAxisAlignment.center,
  //             // mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               SizedBox(
  //                 height: 50,
  //               ),
  //               Image(image: AssetImage('assets/nodataimg.png')),
  //               SizedBox(
  //                 height: 20,
  //               ),
  //               Text(
  //                 'No data Available',
  //                 textAlign: TextAlign.center,
  //                 style: TextStyle(
  //                   color: Colors.black,
  //                   fontSize: 20,
  //                   fontFamily: 'Montserrat',
  //                   fontWeight: FontWeight.w600,
  //                   height: 0,
  //                 ),
  //               )
  //             ],
  //           )
  //               :  ListView.builder(
  //               itemCount: SelfPickdata.length,
  //               itemBuilder: (context, index) {
  //                 final data = SelfPickdata[index];
  //                 return  Padding(
  //                   padding: const EdgeInsets.only(bottom: 15),
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Padding(
  //                         padding: const EdgeInsets.only(left: 16,right: 16),
  //                         child: Container(
  //                             width: double.infinity,
  //                             decoration: ShapeDecoration(
  //                               color: Colors.white,
  //                               shape: RoundedRectangleBorder(
  //                                 side: BorderSide(width: 1, color: Color(0xFFE1E1E1)),
  //                                 borderRadius: BorderRadius.circular(14),
  //                               ),
  //                             ),
  //                             child: Column(
  //                               crossAxisAlignment: CrossAxisAlignment.start,
  //                               children: [
  //                                 Padding(
  //                                   padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
  //                                   child: Row(
  //                                     children: [
  //                                       Text(
  //                                         '${data['start_date']}',
  //                                         style: TextStyle(
  //                                           color: Colors.black,
  //                                           fontSize: 20,
  //                                           fontFamily: 'Montserrat',
  //                                           fontWeight: FontWeight.w600,
  //                                           height: 0,
  //                                         ),
  //                                       ),
  //                                       Text(
  //                                         '  -  ${data['end_date']}',
  //                                         style: TextStyle(
  //                                           color: Colors.black,
  //                                           fontSize: 20,
  //                                           fontFamily: 'Montserrat',
  //                                           fontWeight: FontWeight.w600,
  //                                           height: 0,
  //                                         ),
  //                                       ),
  //                                     ],
  //                                   ),
  //                                 ),
  //                                 Container(
  //                                   margin: EdgeInsets.fromLTRB(13, 0, 13, 9),
  //                                   width: double.infinity,
  //                                   height: 1,
  //                                   decoration: BoxDecoration(
  //                                     color: Color(0xffe1e1e1),
  //                                   ),
  //                                 ),
  //                                 Row(
  //                                   children: [
  //                                     Column(
  //                                       crossAxisAlignment: CrossAxisAlignment.start,
  //                                       children: [
  //                                         Padding(
  //                                           padding: const EdgeInsets.fromLTRB(10, 5, 0, 10),
  //                                           child: Text(
  //                                             '${data['child_name']}',
  //                                             style: TextStyle(
  //                                               color: Colors.black,
  //                                               fontSize: 14,
  //                                               fontFamily: 'Montserrat',
  //                                               fontWeight: FontWeight.w600,
  //                                               height: 0,
  //                                             ),
  //                                           ),
  //                                         ),
  //                                         Padding(
  //                                           padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
  //                                           child: Text(
  //                                             '${data['self_pickup_drop_type']}',
  //                                             style: TextStyle(
  //                                               color: Color(0xFF747474),
  //                                               fontSize: 14,
  //                                               fontFamily: 'Montserrat',
  //                                               fontWeight: FontWeight.w600,
  //                                               height: 0,
  //                                             ),
  //                                           ),
  //                                         ),
  //                                       ],
  //                                     ),
  //                                     Spacer(),
  //                                     Padding(
  //                                       padding:
  //                                       const EdgeInsets.only(left: 8, right: 16),
  //                                       child: ElevatedButton(
  //                                         onPressed: () {
  //                                           // showalertBox(data['self_pickup_drop_id']);
  //                                           delete(data['self_pickup_drop_id']);
  //                                         },
  //                                         style: ElevatedButton.styleFrom(
  //                                           primary: Color(0xFFFF6600),
  //                                           shape: RoundedRectangleBorder(
  //                                             borderRadius: BorderRadius.circular(14),
  //                                           ),
  //                                         ),
  //                                         child: Container(
  //                                           // width: double.infinity,
  //                                           padding: EdgeInsets.symmetric(vertical: 14),
  //                                           child: Text(
  //                                             'delete',
  //                                             textAlign: TextAlign.center,
  //                                             style: TextStyle(
  //                                               color: Colors.white,
  //                                               fontSize: 14,
  //                                               fontFamily: 'Montserrat',
  //                                               fontWeight: FontWeight.w600,
  //                                             ),
  //                                           ),
  //                                         ),
  //                                       ),
  //                                     ),
  //                                   ],
  //                                 )
  //                               ],
  //                             )
  //                         ),
  //                       )
  //                     ],
  //                   ),
  //                 );
  //               }
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget buildPickdropList() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Self Pickup Drop List',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          _isLoading
              ? Padding(
            padding: const EdgeInsets.all(16.0),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6600)),
              strokeWidth: 5.0,
            ),
          )
              : SelfPickdata.isEmpty
              ? Column(
            children: [
              SizedBox(height: 50),
              Image(image: AssetImage('assets/nodataimg.png')),
              SizedBox(height: 20),
              Text(
                'No Data Available',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                ),
              )
            ],
          )
              : Column(
            children: SelfPickdata.map((data) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      child: Container(
                        width: double.infinity,
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(width: 1, color: Color(0xFFE1E1E1)),
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
                              child: Row(
                                children: [
                                  Text(
                                    '${data['start_date']} - ${data['end_date']}',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(13, 0, 13, 9),
                              width: double.infinity,
                              height: 1,
                              decoration: BoxDecoration(
                                color: Color(0xffe1e1e1),
                              ),
                            ),
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(10, 5, 0, 10),
                                      child: Text(
                                        '${data['child_name']}',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
                                      child: Text(
                                        '${data['self_pickup_drop_type']}',
                                        style: TextStyle(
                                          color: Color(0xFF747474),
                                          fontSize: 14,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8, right: 16),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // showalertBox(data['leave_id']);
                                      delete(data['self_pickup_drop_id']);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFFFF6600),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: Container(
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
                              ],
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // void showalertBox(String LeaveId) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Delete applied self pick drop date'),
  //         content: Text('Do you want to delete applied self pick drop date ?'),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //             },
  //             child: Text('No'),
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               Navigator.pop(context); // Close the alert box
  //               delete(LeaveId);
  //               print(LeaveId);
  //             },
  //             child: Text('Yes'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void delete(String SelfPickupid) async {
    try {
      Response response = await post(
        Uri.parse(
            '${ApiConfige.BASE_URL}/parent_delete_child_self_pickup_drop.php'),
        body: {
          'parent_id': Constants.parentId,
          'child_id': widget.childId,
          'self_pickup_drop_id': SelfPickupid
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
                content: Text('Delete Succesfully', textAlign: TextAlign.center,),
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
        SelfPickdropData();
      } else {
        print('Failed to Delete');
      }
    } catch (e) {
      print(e.toString());
    }
  }

}
