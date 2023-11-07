
import 'package:flutter/material.dart';
import 'package:iitj_travel/screens/base/chat.dart';
import 'package:iitj_travel/screens/base/mycard.dart';
import 'package:iitj_travel/screens/base/request_established.dart';
import 'package:intl/intl.dart';
import './home_screen.dart';
import './mypage.dart';
import './request_management.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class BottomNavigationScreen extends StatefulWidget {
  final bool clearButton;
  final int selectedIndex; // Add this parameter
  BottomNavigationScreen({required this.clearButton, required this.selectedIndex});
  @override
  _BottomNavigationScreenState createState() => _BottomNavigationScreenState();

}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  late final String currentUserUid;
  bool clearButton=false;
  late int selectedIndex;
  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    this.clearButton = widget.clearButton;
    currentUserUid = FirebaseAuth.instance.currentUser!.uid; // Assign it here
    this.selectedIndex = widget.selectedIndex;
    _widgetOptions = <Widget>[
      HomeScreen(
        selectedSource: null,
        selectedDestination: null,
        selectedDate: null,
        isDateSelected: false,
      ),
      RequestManagementPage(),
      RequestsEstablishedPage(currentUserUid: currentUserUid), // Use it here
      CommunicationTab(),
      MyPage(),
    ];
  }

  static final List<String> _appBarTitles = <String>[
    'Commuters',
    'Request Management',
    'Confirmed Travels',
    'Messages',
    'Profile',
  ];

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
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
        builder: (context) => BottomNavigationScreen(clearButton: false,selectedIndex: 0),
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
                    items: ['IIT Jodhpur', 'NIFT','Ayurveda', 'Station', 'Airport', 'City']
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
                    items: ['IIT Jodhpur','NIFT','Ayurveda', 'Station', 'Airport', 'City']
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
                        builder: (context) => BottomNavigationScreen(clearButton:true,selectedIndex: 0),
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

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (selectedIndex != 0) {
          // If not in the "Commuters" tab, navigate to the "Commuters" tab
          setState(() {
            selectedIndex = 0;
          });
          return false; // Prevent default back button behavior
        }else {
          SystemNavigator.pop();
          return true;
        }
         // Allow default back button behavior
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // Disable back button
          title: Text(_appBarTitles[selectedIndex]),
          backgroundColor: Color.fromRGBO(17, 86, 149, 1),
          actions: [
            if (selectedIndex == 0)
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
          child: _widgetOptions.elementAt(selectedIndex),
        ),
        floatingActionButton: selectedIndex == 0
            ? ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyCard(),
              ),
            );
            // Handle the action when the button is pressed
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "My Card",
              style: TextStyle(fontSize: 16),
            ),
          ),
          style: ElevatedButton.styleFrom(
            primary:Color.fromRGBO(14, 77, 141, 1.0), // Button color
            elevation: 15,
            padding: EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 10,
            ),// Elevation for the button
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30), // Rounded corners
            ),
          ),
        )
            : null,

        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.groups),
              label: 'Commuters',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.mark_email_read_sharp),
              label: 'Requests',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.done),
              label: 'My Trips',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: selectedIndex,
          selectedItemColor: Color.fromRGBO(17, 86, 149, 1),
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          showUnselectedLabels: true,
        ),
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
          String userImage = userData['basicInfo']['image'];
          userDataList.add({
            'userName': userName,
            'userId': userId,
            'userImage': userImage,
          });
        }
      }
    }

    return userDataList;
  }
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) {
      return ''; // Return an empty string or a default value
    }

    DateTime now = DateTime.now();
    DateTime messageTime = timestamp.toDate();
    String formattedTime = DateFormat.jm().format(messageTime); // Format time

    if (messageTime.year == now.year &&
        messageTime.month == now.month &&
        messageTime.day == now.day) {
      // Today's message
      return "Today, $formattedTime";
    } else if (messageTime.year == now.year &&
        messageTime.month == now.month &&
        messageTime.day == now.day - 1) {
      // Yesterday's message
      return "Yesterday, $formattedTime";
    } else {
      // Custom date
      return DateFormat('MMM dd, yyyy').format(messageTime) + ", $formattedTime";
    }
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
                  // Display a centered message when there are no cards to show
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20), // Add horizontal padding
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.message, // People icon
                            size: 100,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "The interaction with other travellers with whom the travel is established will be displayed here",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center, // Center align the text
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: userDataList.length,
                  itemBuilder: (context, index) {
                    String userName = userDataList[index]['userName'];
                    String userId = userDataList[index]['userId'];
                    String userImage = userDataList[index]['userImage'] ?? '';

                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("ChatRooms")
                          .doc(getChatRoomId(currentUserUid, userId))
                          .collection('chats')
                          .orderBy('time', descending: true)
                          .limit(1)
                          .snapshots(),
                      builder: (context, messageSnapshot) {
                        String mostRecentMessage = 'No messages';
                        Timestamp? mostRecentMessageTime;

                        if (messageSnapshot.hasData && messageSnapshot.data!.docs.isNotEmpty) {
                          var messageData = messageSnapshot.data!.docs[0].data() as Map<String, dynamic>;
                          mostRecentMessage = messageData['message'];
                          mostRecentMessageTime = messageData['time'];
                        }

                        String formattedTime = _formatTimestamp(mostRecentMessageTime);

                        return Card( // Wrap the ListTile with a Card
                            elevation: 2, // Set the elevation for the shadow
                            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            child: ListTile(
                          title: Text(userName),
                          subtitle: Text(mostRecentMessage),
                          trailing: Text(formattedTime),
                          leading: CircleAvatar(
                            backgroundImage: userImage.isNotEmpty ? NetworkImage(userImage) : null,
                            backgroundColor: userImage.isEmpty ? Colors.grey : null,
                            child: userImage.isEmpty ? Icon(Icons.person, color: Colors.white) : null,
                          ),
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







