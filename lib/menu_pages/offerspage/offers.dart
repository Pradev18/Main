import 'package:flutter/material.dart';
import 'package:gala_travels_app/menu_pages/menubar.dart';

class Offers extends StatefulWidget {

  @override
  State<Offers> createState() => _OffersState();
}

class _OffersState extends State<Offers> {

  @override
  Widget build(BuildContext context) {
    // Extract notification date and time from the message data


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
    child: Material(
      child: Scaffold(
        backgroundColor: Color(0xffFAF9F6),
        body: Column(
          children: [
            buildHeaderSection(context),
            Expanded(child: _buildBrodcastList())
          ],
        ),
      ),
    ),
    );
  }

  Widget buildHeaderSection(BuildContext context) {

    return Container(
      padding: EdgeInsets.only(top: 46, left: 16, right: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => Menubar(),));
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
                  'Offers',
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

  Widget _buildBrodcastList() {
    return Column(
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
    );
  }
}
