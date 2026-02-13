import 'package:flutter/material.dart';
import 'package:gala_travels_app/menu_pages/Broadcasts.dart';
import 'package:gala_travels_app/menu_pages/Profiles/parentprofile.dart';
import 'package:gala_travels_app/menu_pages/homescreen/homepage.dart';
import 'package:gala_travels_app/menu_pages/offerspage/offers.dart';

class Menubar extends StatefulWidget {
  @override
  _MenubarState createState() => _MenubarState();
}

class _MenubarState extends State<Menubar> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    HomePage(),
    broadcasts(),
    Offers(),
    profile(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xfffffff2),
        body: _children[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: Colors.orange,
          // Set the active item color
          unselectedItemColor: Colors.grey,
          // Set the inactive item color
          selectedFontSize: 14.0,
          // Set the font size for selected item
          unselectedFontSize: 14.0,
          // Set the font size for unselected items
          showSelectedLabels: true,
          // Set to true to show selected item label
          showUnselectedLabels: true,
          // Set to true to show unselected item label
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage('assets/home.png'),
                size: 40,
              ),
              // Use ImageIcon
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage('assets/megaphone.png'),
                size: 40,
              ),
              label: 'Broadcasts',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage('assets/Calendar.png'),
                size: 40,
              ),
              label: 'Offers',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage('assets/User Rounded.png'),
                size: 40,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

