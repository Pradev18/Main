import 'dart:async';
import 'package:flutter/material.dart';

class HomeProvider with ChangeNotifier {
  int _refreshCount = 0;
  late Timer _timer; // Declare the timer

  int get refreshCount => _refreshCount;

  HomeProvider() {
    _startRefreshing(); // ✅ Automatically starts when provider is created
  }

  void _startRefreshing() {
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      _refreshCount++;
      notifyListeners(); // ✅ Notify listeners to rebuild
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // ✅ Stop the timer when provider is disposed
    super.dispose();
  }
}
