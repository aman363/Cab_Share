import 'package:flutter/material.dart';
import './home_screen.dart';
import './mypage.dart';

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

class RequestManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: 'Requests Received'),
              Tab(text: 'Requests Sent'),
            ],
            labelColor: Color.fromRGBO(17, 86, 149, 1), // Selected tab text color
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Widget for "Requests Received" tab
                Center(child: Text('Requests Received Page')),

                // Widget for "Requests Sent" tab
                Center(child: Text('Requests Sent Page')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class MessagesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                Center(child: Text('Established Travel Page')),

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


