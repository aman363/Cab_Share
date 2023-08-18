import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:iitj_travel/screens/base/chat.dart';
import 'package:iitj_travel/screens/base/request_established.dart';
import './home_screen.dart';
import './mypage.dart';
import './request_management.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BottomNavigationScreen extends StatefulWidget {
  final bool clearButton;

  BottomNavigationScreen({required this.clearButton});
  @override
  _BottomNavigationScreenState createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  int _selectedIndex = 0;
  bool clearButton=false;
  static final List<Widget> _widgetOptions = <Widget>[
    HomeScreen(selectedSource: null,
        selectedDestination: null,
        selectedDate: null,
        isDateSelected: false),
    RequestManagementPage(),
    MessagesPage(),
    MyPage(),
  ];

  static final List<String> _appBarTitles = <String>[
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

  void clearFilters() {
    setState(() {
      _widgetOptions[0] = HomeScreen(
        selectedSource: null,
        selectedDestination: null,
        selectedDate: null,
        isDateSelected: false,
      );
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BottomNavigationScreen(clearButton: false),
      ),
    );
  }

  String? selectedSource;
  String? selectedDestination;
  DateTime selectedDate = DateTime.now();
  bool isDateSelected = false;

  // Add this method to show a filter dialog
  void _showFilterDialog() {
    // Define variables to store selected values


    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Filter Options'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    hint: Text('Source'),
                    value: selectedSource,
                    onChanged: (newValue) {
                      setState(() {
                        selectedSource = newValue;
                      });
                    },
                    items: ['IIT Jodhpur', 'Station', 'Airport', 'City']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  DropdownButton<String>(
                    hint: Text('Destination'),
                    value: selectedDestination,
                    onChanged: (newValue) {
                      setState(() {
                        selectedDestination = newValue;
                      });
                    },
                    items: ['IIT Jodhpur', 'Station', 'Airport', 'City']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null && pickedDate != selectedDate) {
                        setState(() {
                          selectedDate = pickedDate;
                          isDateSelected = true;
                        });
                      }
                    },
                    child: Text(
                      isDateSelected ? "${selectedDate?.day.toString().padLeft(
                          2, '0')}-${selectedDate?.month.toString().padLeft(
                          2, '0')}-${selectedDate?.year}" : 'Select Date',
                      style: TextStyle(
                        color: Colors.white, // Text color
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromRGBO(17, 86, 149, 1), // Button color
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text(
                    'Close',
                    style: TextStyle(
                      color: Color.fromRGBO(17, 86, 149, 1), // Text color
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Use the selected values as needed
                    // Pass the selected filter values to the HomeScreen
                    print('Selected Source: $selectedSource');
                    print('Selected Destination: $selectedDestination');
                    if (isDateSelected) {
                      print('Selected Date: $selectedDate');
                    } else {
                      print('Date not selected');
                    }
                    Navigator.of(context).pop();
                    setState(() {
                      _widgetOptions[0] = HomeScreen(
                        selectedSource: selectedSource,
                        selectedDestination: selectedDestination,
                        selectedDate: selectedDate,
                        isDateSelected: isDateSelected,
                      );
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BottomNavigationScreen(clearButton:true),
                      ),
                    );

                    // Close the dialog
                  },
                  child: Text(
                    'Apply',
                    style: TextStyle(
                      color: Color.fromRGBO(17, 86, 149, 1), // Text color
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }


  @override
  void initState() {
    super.initState();
    this.clearButton = widget.clearButton;
  }
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // If on the home screen, exit the app directly
        if (_selectedIndex == 0) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          // This will pop all routes until the first screen (home screen)
        }
        // For other screens, allow normal back navigation
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // Disable back button
          title: Text(_appBarTitles[_selectedIndex]),
          backgroundColor: Color.fromRGBO(17, 86, 149, 1),
          actions: [
            if (_selectedIndex == 0)
              if (clearButton == true)
                  ElevatedButton.icon(
                    onPressed: clearFilters,
                    icon: Icon(Icons.clear, color: Colors.white),
                    label: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: const Color.fromRGBO(10, 66, 121, 1.0),
                      padding: EdgeInsets.symmetric(
                        horizontal: 1,
                        vertical: 0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      shadowColor: Colors.black26,
                      elevation: 4, // Shadow elevation
                    ),
                  )
              else
                IconButton(
                  onPressed: _showFilterDialog,
                  icon: Icon(Icons.filter_list),
                ),
          ],
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
              icon: Icon(Icons.perm_contact_calendar),
              label: 'Request Manage',
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
                CommunicationTab(),
              ],
            ),
          ),
        ],
      ),
    );

  }
}

class CommunicationTab extends StatelessWidget {
  String getChatRoomId(String uid1, String uid2) {
    List<String> uids = [uid1, uid2];
    uids.sort(); // Sort the UIDs to ensure consistency
    return "${uids[0]}@${uids[1]}";
  }

  Future<List<Map<String, dynamic>>> getUserDataFromChatRooms(QuerySnapshot chatRoomsSnapshot) async {
    List<Map<String, dynamic>> userDataList = [];

    for (var doc in chatRoomsSnapshot.docs) {
      List<String> users = List<String>.from(doc['users'] ?? []);
      users.remove(FirebaseAuth.instance.currentUser!.uid);
      if (users.isNotEmpty) {
        String userId = users[0];
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection("Profile").doc(userId).get();
        if (userSnapshot.exists) {
          Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
          String userName = userData['basicInfo']['name'];
          userDataList.add({
            'userName': userName,
            'userId': userId,
          });
        }
      }
    }

    return userDataList;
  }

  @override
  Widget build(BuildContext context) {
    String currentUserUid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("ChatRooms")
          .where('users', arrayContains: currentUserUid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: getUserDataFromChatRooms(snapshot.data!),
            builder: (context, userDataSnapshot) {
              if (userDataSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator()); // Loading indicator
              } else if (userDataSnapshot.hasData) {
                List<Map<String, dynamic>> userDataList = userDataSnapshot.data!;
                if (userDataList.isEmpty) {
                  return Center(child: Text('No Communication Established'));
                }
                return ListView.builder(
                  itemCount: userDataList.length,
                  itemBuilder: (context, index) {
                    String userName = userDataList[index]['userName'];
                    String userId = userDataList[index]['userId'];
                    return ListTile(
                      title: Text(userName),
                      // Add onTap logic to open the communication with the selected user
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              chatRoomId: getChatRoomId(currentUserUid, userId),
                              userName: userName,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              } else {
                return Center(child: Text('Error fetching user names'));
              }
            },
          );
        } else {
          return Center(child: CircularProgressIndicator()); // Loading indicator
        }
      },
    );
  }
}







