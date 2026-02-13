import 'package:flutter/material.dart';
import 'package:hypersdkflutter/hypersdkflutter.dart';

import '../menu_pages/menubar.dart';

AppBar customAppBar({
  required String text,
  required BuildContext context,
  VoidCallback? backButtonAction,
}) {
  return AppBar(
    title: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: TextStyle(fontSize: 18),
        ),
      ],
    ),
    // backgroundColor: const Color(0xFF2E2B2C),
    leading: text == "Home Screen"
        ? null
        : IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => {
          Navigator.pop(context),
          if (text == "Payment Status") Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Menubar()), (route) => false),
        }),
  );
}
