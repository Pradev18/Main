import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../api_confige.dart';

class EtaScreen extends StatefulWidget {
  final String? childId;

  const EtaScreen({Key? key, this.childId}) : super(key: key);

  @override
  _EtaScreenState createState() => _EtaScreenState();
}

class _EtaScreenState extends State<EtaScreen> {
  String displayText = "ETA\n00:00:00"; // Default text
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchEtaAndUpdate(); // Fetch initial data

    // Set up periodic updates
    _timer = Timer.periodic(Duration(seconds: 30), (_) {
      _fetchEtaAndUpdate();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  Future<void> _fetchEtaAndUpdate() async {
    if (widget.childId == null || widget.childId!.isEmpty) return;

    final data = await _fetchEta(widget.childId);
    if (data is Map && data['success_code'] == 1) {
      setState(() {
        displayText = "ETA\n${data['eta_time']}";
      });
    } else {
      setState(() {
        displayText = "ETA\nUnavailable"; // Handle no data scenario
      });
    }
  }

  Future<dynamic> _fetchEta(String? id) async {
    if (id == null || id.isEmpty) return null;

    try {
      final response = await http.post(
        Uri.parse("${ApiConfige.BASE_URL}/eta.php"),
        body: {'child_id': id},
      );
      print("===${response.body.toString()}");
      if (response.statusCode == 200) {
        return jsonDecode(response.body.toString());
      }
      print("---"+response.body.toString());
      return null;
    } catch (e) {
      print("Error fetching ETA: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      displayText,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color(0xFFFF6600), // Default color
        fontSize: 10,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
    );
  }
}
