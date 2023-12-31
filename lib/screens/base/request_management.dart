import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iitj_travel/services/notification_services.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

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

Widget buildAvatar(BuildContext context, Map<String, dynamic> user) {
  String imageUrl = user['basicInfo']['image'];
  return GestureDetector(
    onTap: () {
      if (imageUrl != null && imageUrl.isNotEmpty) {
        _showLargerImage(context, imageUrl); // Pass context here
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

void _showLargerImage(BuildContext context, String imageUrl) {
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

class RequestManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String currentUserUid = FirebaseAuth.instance.currentUser!.uid;

    return DefaultTabController(
      length: 2, // Number of tabs
      child: Column(
        children:[
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
            RequestsReceivedPage(currentUserUid: currentUserUid),

            // Widget for "Requests Sent" tab
            RequestsSentPage(currentUserUid: currentUserUid),
          ],
        ),
          ),
        ],
      ),
    );
  }
}

class RequestsReceivedPage extends StatelessWidget {
  final String currentUserUid;

  RequestsReceivedPage({required this.currentUserUid});
  NotificationServices notificationServices= NotificationServices();

  Future<void> updateSeatsFilled(String userId, int newValue) async {
    await FirebaseFirestore.instance.collection("Profile").doc(userId).update({
      'matchingConditions.seatsFilled': newValue,
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection("Profile").doc(currentUserUid).snapshots(),
      builder: (context, userSnapshot) {
        if (userSnapshot.hasData) {
          List<String> requestsReceived = List<String>.from(userSnapshot.data!['requestReceived'] ?? []);
          String loggedInUserName=userSnapshot.data!['basicInfo']['name'];
          if (requestsReceived.isEmpty) {
            // Display a centered message when there are no cards to show
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.mark_email_read_sharp, // People icon
                    size: 100,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Here you will see request from other travellers",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              ),
            );
          }

          return ListView.builder(
            itemCount: requestsReceived.length,
            itemBuilder: (context, index) {
              String userId = requestsReceived[index];
              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection("Profile").doc(userId).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var user = snapshot.data!.data() as Map<String, dynamic>;
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
                                  buildAvatar(context,user),
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
                                  SizedBox(height: 8),
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
                                                  ? "I have booked an Auto"
                                                  : "Auto not booked yet"
                                                  : user['matchingConditions']['autoBooked'] == 1
                                                  ? "I have booked a Taxi"
                                                  : "Taxi not booked yet",
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
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () async {
                                            // Add your accept button logic here
                                            String pressedUserId = userId; // Get the pressed user's ID
                                            String currentUserId = currentUserUid; // Get the current user's ID
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text("Request from ${user['basicInfo']['name']} accepted"),
                                                backgroundColor: Colors.lightBlue,
                                              ),
                                            );
                                            notificationServices.getDeviceToken().then((value) async{
                                              var data={
                                                'to': user['fcmToken'],
                                                'priority': 'high',
                                                'notification': {
                                                  'title': 'Request Accepted',
                                                  'body': '$loggedInUserName accepted your request',
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
                                            // Update the requestEstablished arrays for both users
                                            await FirebaseFirestore.instance.collection("Profile").doc(pressedUserId).update({
                                              'requestEstablished': FieldValue.arrayUnion([currentUserId]),
                                            });
                                            await FirebaseFirestore.instance.collection("Profile").doc(currentUserId).update({
                                              'requestEstablished': FieldValue.arrayUnion([pressedUserId]),
                                            });

                                            // Remove the pressed user's ID from current user's requestReceived array
                                            await FirebaseFirestore.instance.collection("Profile").doc(currentUserId).update({
                                              'requestReceived': FieldValue.arrayRemove([pressedUserId]),
                                            });
                                            await FirebaseFirestore.instance.collection("Profile").doc(pressedUserId).update({
                                              'requestSent': FieldValue.arrayRemove([currentUserId]),
                                            });
                                            String chatRoomId = generateChatRoomId(currentUserId, pressedUserId);

                                            // Create a new document in the ChatRooms collection
                                            await FirebaseFirestore.instance.collection("ChatRooms").doc(chatRoomId).set({
                                              'users': [currentUserId, pressedUserId],
                                            });

                                            // Create the "chats" subcollection within the newly created document
                                            await FirebaseFirestore.instance.collection("ChatRooms").doc(chatRoomId).collection("chats").doc().set({});

                                            int currentSeatsFilledCurrentUser = userSnapshot.data!['matchingConditions']['seatsFilled'] + 1;
                                            await updateSeatsFilled(currentUserUid, currentSeatsFilledCurrentUser);

                                            // Update seatsFilled for the opposite user
                                            int currentSeatsFilledOppositeUser = user['matchingConditions']['seatsFilled'] + 1;
                                            await updateSeatsFilled(userId, currentSeatsFilledOppositeUser);

                                          },
                                          child: Row(
                                            children: [
                                              Icon(Icons.check_circle), // Message icon
                                              SizedBox(width: 8), // Add spacing between icon and text
                                              Text("Accept"),
                                            ],
                                          ),
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
                                        SizedBox(width: 15), // Add some spacing between buttons
                                        ElevatedButton(
                                          onPressed: () async {
                                            String pressedUserId = userId; // Get the pressed user's ID
                                            String currentUserId = currentUserUid; // Get the current user's ID

                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text("Request from ${user['basicInfo']['name']} declined"),
                                                backgroundColor: Colors.red,
                                              ),
                                            );

                                            // Remove the pressed user's ID from current user's requestReceived array
                                            await FirebaseFirestore.instance.collection("Profile").doc(currentUserId).update({
                                              'requestReceived': FieldValue.arrayRemove([pressedUserId]),
                                            });

                                            // Remove the current user's ID from pressed user's requestSent array
                                            await FirebaseFirestore.instance.collection("Profile").doc(pressedUserId).update({
                                              'requestSent': FieldValue.arrayRemove([currentUserId]),
                                            });
                                          },
                                          child: Row(
                                            children: [
                                              Icon(Icons.cancel), // Message icon
                                              SizedBox(width: 8), // Add spacing between icon and text
                                              Text("Decline"),
                                            ],
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            primary: Colors.red, // Use a different color for the decline button
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 13,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(5),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return CircularProgressIndicator(); // Loading indicator
                  }
                },
              );
            },
          );
        } else {
          return CircularProgressIndicator(); // Loading indicator
        }
      },
    );
  }
  String generateChatRoomId(String uid1, String uid2) {
    List<String> uids = [uid1, uid2];
    uids.sort(); // Sort the UIDs to ensure consistency
    return "${uids[0]}@${uids[1]}";
  }
}



class RequestsSentPage extends StatelessWidget {
  final String currentUserUid;

  RequestsSentPage({required this.currentUserUid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection("Profile").doc(currentUserUid).snapshots(),
      builder: (context, userSnapshot) {
        if (userSnapshot.hasData) {
          List<String> requestsSent = List<String>.from(userSnapshot.data!['requestSent'] ?? []);
          if (requestsSent.isEmpty) {
            // Display a centered message when there are no cards to show
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.send, // People icon
                    size: 100,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "The travellers you requested to travel with will be displayed here",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              ),
            );
          }

          return ListView.builder(
            itemCount: requestsSent.length,
            itemBuilder: (context, index) {
              String userId = requestsSent[index];
              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection("Profile").doc(userId).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var user = snapshot.data!.data() as Map<String, dynamic>;
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
                                  buildAvatar(context, user),
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
                                  SizedBox(height: 8),
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
                                                  ? "I have booked an Auto"
                                                  : "Auto not booked yet"
                                                  : user['matchingConditions']['autoBooked'] == 1
                                                  ? "I have booked a Taxi"
                                                  : "Taxi not booked yet",
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
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text("Request to ${user['basicInfo']['name']} cancelled"),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        String pressedUserId = userId; // Get the pressed user's ID
                                        String currentUserId = currentUserUid; // Get the current user's ID

                                        // Remove the pressed user's ID from current user's requestReceived array
                                        await FirebaseFirestore.instance.collection("Profile").doc(currentUserId).update({
                                          'requestSent': FieldValue.arrayRemove([pressedUserId]),
                                        });

                                        // Remove the current user's ID from pressed user's requestSent array
                                        await FirebaseFirestore.instance.collection("Profile").doc(pressedUserId).update({
                                          'requestReceived': FieldValue.arrayRemove([currentUserId]),
                                        });
                                    },
                                      child: Text("Cancel"),
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.red,
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
                  } else {
                    return CircularProgressIndicator(); // Loading indicator
                  }
                },
              );
            },
          );
        } else {
          return CircularProgressIndicator(); // Loading indicator
        }
      },
    );
  }
}

