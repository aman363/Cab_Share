import 'package:flutter/material.dart';
import 'package:iitj_travel/screens/base/request_established.dart';
import './home_screen.dart';
import './mypage.dart';
import './request_management.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class BottomNavigationScreen extends StatefulWidget {
  @override
  _BottomNavigationScreenState createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  int _selectedIndex = 0;
  static List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    RequestManagementPage(),
    MessagesPage(),
    MyPage(),
  ];

  static List<String> _appBarTitles = <String>[
    'Matching Users',
    'Request Management',
    'Messages',
    'My Page',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevent back navigation when at the home screen
        if (_selectedIndex == 0) {
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // Disable back button
          title: Text(_appBarTitles[_selectedIndex]),
          backgroundColor: Color.fromRGBO(17, 86, 149, 1),
        ),
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Matching Users',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.request_page),
              label: 'Request Management',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'My Page',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Color.fromRGBO(17, 86, 149, 1),
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}



class MessagesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: 'Established Travel'),
              Tab(text: 'Communication'),
            ],
            labelColor: Color.fromRGBO(17, 86, 149, 1), // Selected tab text color
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Widget for "Established Travel" tab
                RequestsEstablishedPage(currentUserUid: currentUserUid),

                // Widget for "Communication" tab
                Center(child: Text('Communication Page')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


