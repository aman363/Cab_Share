import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iitj_travel/services/notification_services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  final String? selectedSource;
  final String? selectedDestination;
  final DateTime? selectedDate;
  final bool? isDateSelected;

  const HomeScreen({
    Key? key,
    this.selectedSource,
    this.selectedDestination,
    this.selectedDate,
    this.isDateSelected,
  }) : super(key: key);


  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<Map<String, dynamic>> matchingUsers = [];
  late String currentUserUid;
  NotificationServices notificationServices= NotificationServices();
  late String? selectedSource;
  late String? selectedDestination;
  late DateTime? selectedDate;
  late bool? isDateSelected;
  late Timer updateTimer;

  @override
  void initState() {
    super.initState();
    selectedSource = widget.selectedSource; // Assign the values here
    selectedDestination = widget.selectedDestination; // Assign the values here
    selectedDate = widget.selectedDate; // Assign the values here
    isDateSelected = widget.isDateSelected;
    // Create a Timer that checks for updates periodically (e.g., every minute)
    updateTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      // Get the current date and time
      DateTime now = DateTime.now();

      // Iterate through the matchingUsers list and check each user's matchingConditions
      for (var user in matchingUsers) {
        // Parse the user's matchingConditions date and time into DateTime objects
        if (user['matchingConditions']['date'] != "" && user['matchingConditions']['time'] != "") {
          // Parse the user's matchingConditions date and time into DateTime objects
          DateTime matchingDate = DateFormat("dd-MM-yyyy hh:mm a").parse(
            "${user['matchingConditions']['date']} ${user['matchingConditions']['time']}",
          );

          // Compare the current date and time with the user's matchingConditions
          if (now.isAfter(matchingDate)) {
            // Perform the update for this user
            updateMatchingConditions(user);
          }
        }
      }
      FirebaseFirestore.instance.collection("Profile").doc(currentUserUid).get().then((userDoc) {
        if (userDoc.exists) {
          // Extract the user data
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

          // Parse the current user's matchingConditions date and time into DateTime objects

          if (userData['matchingConditions']['date'] != "" && userData['matchingConditions']['time'] != "") {
            // Parse the current user's matchingConditions date and time into DateTime objects
            DateTime currentUserMatchingDate = DateFormat("dd-MM-yyyy hh:mm a").parse(
              "${userData['matchingConditions']['date']} ${userData['matchingConditions']['time']}",
            );

            // Compare the current date and time with the current user's matchingConditions
            if (now.isAfter(currentUserMatchingDate)) {
              // Perform the update for the current user
              updateMatchingConditions(userData);
            }
          }
        }
      });
    });
    currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    notificationServices.requestNotificationPermission();
    notificationServices.firebaseInit(context);
    notificationServices.setupInteractMessage(context);
    notificationServices.getDeviceToken().then((value) async{
      await FirebaseFirestore.instance.collection("Profile").doc(currentUserUid).update({
        'fcmToken': value.toString(),
      });
    });
  }
  @override
  void dispose() {
    super.dispose();
    // Cancel the Timer when the widget is disposed to prevent memory leaks
    updateTimer.cancel();
  }

  void updateMatchingConditions(Map<String, dynamic> user) {
    // Extract the user's ID
    String userId = user['uid'];
    List<String> requestEstablished = List<String>.from(user['requestEstablished'] ?? []);
    List<String> requestReceived = List<String>.from(user['requestReceived'] ?? []);
    // Update Firestore document for the specific user
    FirebaseFirestore.instance.collection("Profile").doc(userId).update({
      'matchingConditions': {
        'date': "", // Update with the new date
        'time': "", // Update with the new time
        'source': "", // Update with the new source
        'destination': "", // Update with the new destination
        'autoBooked': 0, // Update with the new autoBooked value
        'vacantSeats': 0, // Update with the new vacantSeats value
        'seatsFilled': 0, // Update with the new seatsFilled value
        'modeOfTravel': "", // Update with the new modeOfTravel
      },
      'requestReceived':[],
      'requestEstablished':[],
    }).then((_) {
      // Successfully updated the document
      print('MatchingConditions updated for user with ID: $userId');
      for (String uid in requestEstablished) {
        FirebaseFirestore.instance.collection("Profile").doc(uid).update({
          'requestEstablished': FieldValue.arrayRemove([userId]), // Update the source to ""
        }).then((_) {
          print('Source updated to "" for user with ID: $uid');
        }).catchError((error) {
          print('Error updating source for user with ID: $uid - Error: $error');
        });
      }
      for (String uid in requestReceived) {
        FirebaseFirestore.instance.collection("Profile").doc(uid).update({
          'requestSent': FieldValue.arrayRemove([userId]), // Update the source to ""
        }).then((_) {
          print('Source updated to "" for user with ID: $uid');
        }).catchError((error) {
          print('Error updating source for user with ID: $uid - Error: $error');
        });
      }
    }).catchError((error) {
      // Handle any errors that occur during the update
      print('Error updating MatchingConditions: $error');
    });
  }

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("Profile")
          .doc(currentUserUid)
          .snapshots(),
      builder: (context, userSnapshot) {
        if (userSnapshot.hasData) {
          Map<String, dynamic> userData = userSnapshot.data!.data() as Map<String, dynamic>;
          List<String> requestSent = List<String>.from(userData['requestSent'] ?? []);
          List<String> requestReceived = List<String>.from(userData['requestReceived'] ?? []);
          List<String> requestEstablished = List<String>.from(userData['requestEstablished'] ?? []);
          String loggedInUserName=userData['basicInfo']['name'];

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("Profile")
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                matchingUsers = snapshot.data!.docs
                    .map((doc) => doc.data() as Map<String, dynamic>)
                    .where((user) =>
                user['uid'] != currentUserUid && // Exclude current user
                    !requestSent.contains(user['uid']) && // Exclude users in requestSent
                    !requestReceived.contains(user['uid']) && // Exclude users in requestReceived
                    !requestEstablished.contains(user['uid']) &&
                    user['matchingConditions'] != null &&// Exclude users in requestEstablished
                user['matchingConditions']['source'] != '' && // Source is not empty
                    user['matchingConditions']['seatsFilled'] <
                        user['matchingConditions']['vacantSeats'])
                    .toList();
                String formattedSelectedDate = "${selectedDate?.day.toString().padLeft(2, '0')}-${selectedDate?.month.toString().padLeft(2, '0')}-${selectedDate?.year}";
                // Sorting matchingUsers by date and time in ascending order
                matchingUsers.sort((user1, user2) {
                  String dateStr1 = user1['matchingConditions']['date'];
                  String timeStr1 = user1['matchingConditions']['time'];
                  String dateStr2 = user2['matchingConditions']['date'];
                  String timeStr2 = user2['matchingConditions']['time'];

                  // Parse the date strings into DateTime objects
                  DateTime date1 = DateTime.parse(
                      "${dateStr1.split('-')[2]}-${dateStr1.split('-')[1]}-${dateStr1.split('-')[0]}");
                  DateTime date2 = DateTime.parse(
                      "${dateStr2.split('-')[2]}-${dateStr2.split('-')[1]}-${dateStr2.split('-')[0]}");

                  // Manually parse the time strings into DateTime objects
                  DateTime dateTime1 = DateTime(
                    date1.year,
                    date1.month,
                    date1.day,
                    int.parse(timeStr1.split(':')[0]), // Hours
                    int.parse(timeStr1.split(':')[1].split(' ')[0]), // Minutes
                  );

                  if (timeStr1.split(' ')[1] == 'PM' && timeStr1 != '12:00 PM') {
                    dateTime1 = dateTime1.add(Duration(hours: 12)); // Add 12 hours for PM
                  }

                  DateTime dateTime2 = DateTime(
                    date2.year,
                    date2.month,
                    date2.day,
                    int.parse(timeStr2.split(':')[0]), // Hours
                    int.parse(timeStr2.split(':')[1].split(' ')[0]), // Minutes
                  );

                  if (timeStr2.split(' ')[1] == 'PM' && timeStr2 != '12:00 PM') {
                    dateTime2 = dateTime2.add(Duration(hours: 12)); // Add 12 hours for PM
                  }

                  // Compare by date and time
                  int dateComparison = dateTime1.compareTo(dateTime2);

                  // If the dates are the same, compare by AM/PM
                  if (dateComparison == 0) {
                    return timeStr1.split(' ')[1].compareTo(timeStr2.split(' ')[1]);
                  }

                  return dateComparison;
                });
                print('Selected Source: $selectedSource');
                print('Selected Destination: $selectedDestination');
                print('Selected Date: $selectedDate');
                print('Is Date Selected: $isDateSelected');
                if (selectedSource != null && selectedDestination != null && isDateSelected!= false) {
                  matchingUsers = matchingUsers.where((user) =>
                  user['matchingConditions']['source'] == selectedSource &&
                      user['matchingConditions']['destination'] == selectedDestination &&
                      user['matchingConditions']['date'] == formattedSelectedDate).toList();
                } else if (selectedSource != null && selectedDestination != null) {
                  matchingUsers = matchingUsers.where((user) =>
                  user['matchingConditions']['source'] == selectedSource &&
                      user['matchingConditions']['destination'] == selectedDestination).toList();
                } else if (selectedSource != null && isDateSelected != false) {
                  matchingUsers = matchingUsers.where((user) =>
                  user['matchingConditions']['source'] == selectedSource &&
                      user['matchingConditions']['date'] == formattedSelectedDate).toList();
                } else if (selectedDestination != null && isDateSelected != false) {
                  matchingUsers = matchingUsers.where((user) =>
                  user['matchingConditions']['destination'] == selectedDestination &&
                      user['matchingConditions']['date'] == formattedSelectedDate).toList();
                } else if (selectedSource != null) {
                  matchingUsers = matchingUsers.where((user) =>
                  user['matchingConditions']['source'] == selectedSource).toList();
                } else if (selectedDestination != null) {
                  matchingUsers = matchingUsers.where((user) =>
                  user['matchingConditions']['destination'] == selectedDestination).toList();
                } else if (isDateSelected!= false) {
                  matchingUsers = matchingUsers.where((user) =>
                  user['matchingConditions']['date'] == formattedSelectedDate).toList();
                }
                if (matchingUsers.isEmpty) {
                  // Display a centered message when there are no cards to show
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20), // Add horizontal padding
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.groups, // People icon
                            size: 100,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Here you will see all the travel cards,\nYou can make your own with the My Card button",
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
                  itemCount: matchingUsers.length,
                  itemBuilder: (context, index) {
                    var user = matchingUsers[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(169, 210, 255, 1.0),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Display circular avatar based on user's image availability
                                  buildAvatar(user),
                                  SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${user['basicInfo']['name'].toUpperCase()}",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromRGBO(14, 77, 141, 1.0),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Text(
                                            "${user['matchingConditions']['source'].toUpperCase()}",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Icon(Icons.arrow_forward, color: Colors.grey),
                                          Text(
                                            "${user['matchingConditions']['destination'].toUpperCase()}",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Date: ${formatDateString(user['matchingConditions']['date'])} at ${user['matchingConditions']['time']}",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  if (user['matchingConditions']['modeOfTravel'] != null && user['matchingConditions']['modeOfTravel'].isNotEmpty)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [

                                        Row(
                                          children: [
                                            user['matchingConditions']['modeOfTravel'] == "Auto"
                                                ? Image.asset('assets/auto.png', width: 35, height: 35) // Use the correct path to the auto.png asset
                                                : Image.asset('assets/taxi.png', width: 35, height: 35), // Use the correct path to the taxi.png asset
                                            SizedBox(width: 5),
                                            Text(
                                              user['matchingConditions']['modeOfTravel'] == "Auto"
                                                  ? user['matchingConditions']['autoBooked'] == 1
                                                  ? "Auto booked"
                                                  : "Auto not booked"
                                                  : user['matchingConditions']['autoBooked'] == 1
                                                  ? "Cab booked"
                                                  : "Cab not booked",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: user['matchingConditions']['autoBooked'] == 1
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: List.generate(
                                                user['matchingConditions']['vacantSeats'],
                                                    (index) {
                                                  int reversedIndex = user['matchingConditions']['vacantSeats'] - index - 1;
                                                  return ColorFiltered(
                                                    colorFilter: ColorFilter.mode(
                                                      reversedIndex < user['matchingConditions']['seatsFilled'] ? Colors.red : Colors.green,
                                                      BlendMode.srcIn,
                                                    ),
                                                    child: Image.asset('assets/seat.png', width: 25, height: 25),
                                                  );
                                                },
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                _showVacantSeatsInfo(context, user['matchingConditions']['vacantSeats'] - user['matchingConditions']['seatsFilled']);
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.only(left: 2), // Adjust this value as needed
                                                child: Icon(
                                                  Icons.info,
                                                  size: 20,
                                                  color: Color.fromRGBO(14, 77, 141, 1.0),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )

                                      ],
                                    ),

                                  SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.center,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        String loggedInUserUid = FirebaseAuth.instance.currentUser!.uid;
                                        String pressedUserUid = user['uid'];
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text("Request sent to ${user['basicInfo']['name']}"),
                                            backgroundColor: Colors.lightBlue,
                                          ),
                                        );
                                        notificationServices.getDeviceToken().then((value) async{
                                          var data={
                                            'to': user['fcmToken'],
                                            'priority': 'high',
                                            'notification': {
                                              'title': 'New Request',
                                              'body': 'New Request from $loggedInUserName',
                                            }
                                          };
                                          await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
                                            body:jsonEncode(data),
                                            headers:{
                                            'Content-Type': 'application/json; charset=UTF-8',
                                              'Authorization': 'key=AAAAVq17HoU:APA91bFv4d1jHUoVmyxb6HWgsbtp-6VNmNPYNyMgBKJhgV0I84FQSpzOoY60hecKTpxsKz0T7v73FY-JZ6jb13BErboRrD_x0B0YKfCniXmoI_fMtM6gF0W5q3NeNjuayvhwFArOIgXB'
                                            }
                                          );

                                        });

                                        // Update requestSent array of logged-in user
                                        await FirebaseFirestore.instance
                                            .collection('Profile')
                                            .doc(loggedInUserUid)
                                            .update({
                                          'requestSent': FieldValue.arrayUnion([pressedUserUid])
                                        });

                                        // Update requestReceived array of pressed user
                                        await FirebaseFirestore.instance
                                            .collection('Profile')
                                            .doc(pressedUserUid)
                                            .update({
                                          'requestReceived': FieldValue.arrayUnion([loggedInUserUid])
                                        });

                                      },
                                      child: Text("Request"),
                                      style: ElevatedButton.styleFrom(
                                        primary: const Color.fromRGBO(17, 86, 149, 1),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 13,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else {
                return CircularProgressIndicator(); // Loading indicator
              }
            },
          );
        } else {
          return CircularProgressIndicator(); // Loading indicator
        }
      },
    );
  }
  Widget buildAvatar(Map<String, dynamic> user) {
    String imageUrl = user['basicInfo']['image'];
    return GestureDetector(
      onTap: () {
        if (imageUrl != null && imageUrl.isNotEmpty) {
          _showLargerImage(imageUrl); // Show larger image when tapped
        }
      },
      child: imageUrl != null && imageUrl.isNotEmpty
          ? CircleAvatar(
        radius: 40,
        backgroundImage: NetworkImage(imageUrl),
      )
          : CircleAvatar(
        radius: 40,
        backgroundColor: Colors.grey,
        child: Icon(
          Icons.person,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }

  void _showLargerImage(String imageUrl) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the bottom sheet
                },
                child: Text(
                  'Close',
                  style: TextStyle(
                    color: Color.fromRGBO(17, 86, 149, 1), // Desired color
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  String formatDateString(String dateStr) {
    // Split the date string into day, month, and year
    List<String> parts = dateStr.split('-');

    if (parts.length >= 3) {
      // Create a map to map month numbers to month names
      Map<String, String> monthMap = {
        '01': 'Jan', '02': 'Feb', '03': 'Mar', '04': 'Apr', '05': 'May', '06': 'Jun',
        '07': 'Jul', '08': 'Aug', '09': 'Sep', '10': 'Oct', '11': 'Nov', '12': 'Dec'
      };

      // Format the date
      String formattedDate = "${monthMap[parts[1]]} ${parts[0]}, ${parts[2]}";
      return formattedDate;
    } else {
      // Return the original date string if it couldn't be split correctly
      return dateStr;
    }
  }

  void _showVacantSeatsInfo(BuildContext context, int vacantSeats) {
    String message;
    if (vacantSeats == 1) {
      message = "There is currently $vacantSeats vacant seat available.";
    } else if (vacantSeats <= 0) {
      message = "There is currently no vacant seat available.";
    } else {
      message = "There are currently $vacantSeats vacant seats available.";
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(message),
          contentPadding: EdgeInsets.all(16), // Adjust padding as needed
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "OK",
                  style: TextStyle(
                    color: Color.fromRGBO(14, 77, 141, 1.0), // Your app's button color
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

}

