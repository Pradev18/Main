import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gala_travels_app/menu_pages/constants/constants.dart';
import 'package:http/http.dart' as http;

import '../../../api_confige.dart';

class report extends StatefulWidget {
  final String childId;

  const report({super.key, required this.childId});

  @override
  State<report> createState() => _reportState();
}

class _reportState extends State<report> {
  List<Map<String, dynamic>> reportData = [];

  Future<void> fetchData() async {
    final startDateFormatted = '${_startDate.toLocal()}'.split(' ')[0];
    final endDateFormatted = '${_endDate.toLocal()}'.split(' ')[0];

    final response = await http.get(Uri.parse(
        '${ApiConfige.BASE_URL}/view_parent_child_report.php?parent_id=${Constants.parentId}&child_id=${widget.childId}&start_date=$startDateFormatted&end_date=$endDateFormatted'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final reportDetail = jsonData['report_detail'];

      setState(() {
        reportData = List<Map<String, dynamic>>.from(reportDetail);
      });
    } else {
      throw Exception('Failed to load data');
    }

  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        backgroundColor: Color(0xffFAF9F6),
        body: SingleChildScrollView(
          child: Column(
            children: [
              buildHeaderSection(),
              DateSection(),
              buildReportList(),
              Padding(
                padding: const EdgeInsets.only(left: 16,right: 16),
                child: Container(height: 5,color: Colors.orange,),
              )
            ],
          ),
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
                  'Attendants Report',
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
    _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
    _endDate = DateTime.now();
    _startDateController =
        TextEditingController(text: '${_startDate.day.toString().padLeft(2, '0')}/${_startDate.month.toString().padLeft(2, '0')}/${_startDate.year}');
    _endDateController =
        TextEditingController(text: '${_endDate.day.toString().padLeft(2, '0')}/${_endDate.month.toString().padLeft(2, '0')}/${_endDate.year}');
    fetchData();
    print(widget.childId);
  }


  Future<void> _selectStartDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000), // Allow only past and present dates
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        _startDateController.text = '${_startDate.day.toString().padLeft(2, '0')}/${_startDate.month.toString().padLeft(2, '0')}/${_startDate.year}';
      });

      _selectEndDate(context);
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime(2000), // Allow only past and present dates
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
        _endDateController.text = '${_endDate.day.toString().padLeft(2, '0')}/${_endDate.month.toString().padLeft(2, '0')}/${_endDate.year}';
      });
    }
  }

  void handleSearch() {
    String formattedStartDate = '${_startDate.toLocal()}'.split(' ')[0];
    String formattedEndDate = '${_endDate.toLocal()}'.split(' ')[0];

    print('Selected Start Date: $formattedStartDate');
    print('Selected End Date: $formattedEndDate');

    fetchData();
  }

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
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 16),
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
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 16),
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
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
          child: ElevatedButton(
            onPressed: () {
              handleSearch();
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
                'Search',
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

  Widget buildReportList() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6, // Adjust the height as needed
      child: (reportData.isEmpty)
          ? Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6600)),
                  strokeWidth: 5.0),
            )
          : ListView.builder(
              itemCount: reportData.length,
              itemBuilder: (context, index) {
                final data = reportData[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 5),
                        child: Text(
                          data['date'],
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            height: 0,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        child: Container(
                          width: double.infinity,
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  width: 1, color: Color(0xFFE1E1E1)),
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 10, right: 5, top: 7,bottom: 5),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: ShapeDecoration(
                                        shape: OvalBorder(
                                          side: BorderSide(
                                            width: 2,
                                            color: Color(0xFFFF6600),
                                          ),
                                        ),
                                      ),
                                      child: Center(
                                        child: Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage(
                                                  'assets/Rhome.png'),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: ShapeDecoration(
                                        shape: OvalBorder(
                                          side: BorderSide(
                                            width: 2,
                                            color: Color(0xFFFF6600),
                                          ),
                                        ),
                                      ),
                                      child: Center(
                                        child: Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage(
                                                  'assets/Rschool.png'),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 12,bottom: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'From Home',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: MediaQuery.of(context).size.width * 0.036,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w600,
                                        height: 0,
                                      ),
                                    ),
                                    Text(
                                      '${data['pickup_home_time'].isEmpty ? 'Absent' : 'Present ${data['pickup_home_time']}'}',
                                      style: TextStyle(
                                        color: data['pickup_home_time'].isEmpty
                                            ? Color(0xFFDD1D1C)
                                            : Color(0xFF2AB154),
                                        fontSize: MediaQuery.of(context).size.width * 0.025,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w500,
                                        height: 0,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Text(
                                      'From School',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: MediaQuery.of(context).size.width * 0.036,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w600,
                                        height: 0,
                                      ),
                                    ),
                                    Text(
                                      '${data['pickup_school_time'].isEmpty ? 'Absent' : 'Present ${data['pickup_school_time']}'}',
                                      style: TextStyle(
                                        color:
                                            data['pickup_school_time'].isEmpty
                                                ? Color(0xFFDD1D1C)
                                                : Color(0xFF2AB154),
                                        fontSize: MediaQuery.of(context).size.width * 0.025,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w500,
                                        height: 0,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              // Spacer(),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 20, left: 20),
                                child: Column(
                                  children: [
                                    Image.asset('assets/arrow-right.png'),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    Image.asset('assets/arrow-right.png'),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 15, right: 5, top: 7,bottom: 5),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: ShapeDecoration(
                                        shape: OvalBorder(
                                          side: BorderSide(
                                            width: 2,
                                            color: Color(0xFFFF6600),
                                          ),
                                        ),
                                      ),
                                      child: Center(
                                        child: Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage(
                                                  'assets/Rschool.png'),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: ShapeDecoration(
                                        shape: OvalBorder(
                                          side: BorderSide(
                                            width: 2,
                                            color: Color(0xFFFF6600),
                                          ),
                                        ),
                                      ),
                                      child: Center(
                                        child: Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage(
                                                  'assets/Rhome.png'),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 12, right: 20,bottom: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'To School',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: MediaQuery.of(context).size.width * 0.036,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w600,
                                        height: 0,
                                      ),
                                    ),
                                    Text(
                                      '${data['drop_school_time'].isEmpty ? 'Absent' : 'Present ${data['drop_school_time']}'}',
                                      style: TextStyle(
                                        color: data['drop_school_time'].isEmpty
                                            ? Color(0xFFDD1D1C)
                                            : Color(0xFF2AB154),
                                        fontSize: MediaQuery.of(context).size.width * 0.025,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w500,
                                        height: 0,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Text(
                                      'To Home',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: MediaQuery.of(context).size.width * 0.036,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w600,
                                        height: 0,
                                      ),
                                    ),
                                    Text(
                                      '${data['drop_home_time'].isEmpty ? 'Absent' : 'Present ${data['drop_home_time']}'}',
                                      style: TextStyle(
                                        color: data['drop_home_time'].isEmpty
                                            ? Color(0xFFDD1D1C)
                                            : Color(0xFF2AB154),
                                        fontSize: MediaQuery.of(context).size.width * 0.025,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w500,
                                        height: 0,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                );
              }),
    );
  }
}
