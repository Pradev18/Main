import 'package:flutter/material.dart';
import '../notification/notification_screen.dart';
import 'package:flutter/material.dart';
import '../notification/notification_screen.dart';
import 'homescreen/homepage.dart';
import 'menubar.dart';

class broadcasts extends StatefulWidget {
  @override
  State<broadcasts> createState() => _broadcastsState();
}

class _broadcastsState extends State<broadcasts> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigate to the home page (Menubar)
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Menubar()),
          (route) => false, // Clears all previous routes
        );
        return false; // Prevent default back button behavior
      },
      child: Material(
        child: Scaffold(
          backgroundColor: Color(0xffFAF9F6),
          body: Column(
            children: [
              buildHeaderSection(context),
              Expanded(child: _buildBroadcastList()),
            ],
          ),
        ),
      ),
    );
  }
  Widget buildHeaderSection(BuildContext context) {
    double Width = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.only(top: 46, left: 16, right: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => Menubar()),
                    (route) => false, // Clears all previous routes
              );
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
                  width: Width*0.13,
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
                  'Broadcasts',
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
              height: 52,
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
  }

  Widget _buildBroadcastList() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image(image: AssetImage('assets/nodataimg.png')),
        SizedBox(
          height: MediaQuery.of(context).size.width*0.050,
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
    );
  }
}
