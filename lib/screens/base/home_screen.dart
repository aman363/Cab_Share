import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iitj_travel/services/notification_services.dart';
import 'package:http/http.dart' as http;

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

  @override
  void initState() {
    super.initState();
    currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    notificationServices.requestNotificationPermission();
    notificationServices.firebaseInit(context);
    notificationServices.setupInteractMessage(context);
    notificationServices.getDeviceToken().then((value) async{
      await FirebaseFirestore.instance.collection("Profile").doc(currentUserUid).update({
        'fcmToken': value.toString(),
      });
    });
    selectedSource = widget.selectedSource; // Assign the values here
    selectedDestination = widget.selectedDestination; // Assign the values here
    selectedDate = widget.selectedDate; // Assign the values here
    isDateSelected = widget.isDateSelected;
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
                            "Here you will see all the travel cards,\nYou can make your own with the addition button",
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
                              color: Color.fromRGBO(169, 210, 255, 1.0), // Blue color
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 15),
                              width: double.infinity, // Make the color strip extend to full width
                              child: Text(
                                "${user['basicInfo']['name'].toUpperCase()}",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(14, 77, 141, 1.0),// White text color
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 8),
                                  Center(
                                    child:Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "${user['matchingConditions']['source'].toUpperCase()}",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Icon(Icons.arrow_forward, color: Colors.grey), // Arrow icon
                                        Text(
                                          "${user['matchingConditions']['destination'].toUpperCase()}",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Date: ${user['matchingConditions']['date']}",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Time: ${user['matchingConditions']['time']}",
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
                                                  ? "Auto is booked"
                                                  : "Auto not booked yet"
                                                  : user['matchingConditions']['autoBooked'] == 1
                                                  ? "Taxi is booked"
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
                                          children: [
                                            Icon(Icons.person, size: 24), // Person icon
                                            SizedBox(width: 5),
                                            Text(
                                              "${user['matchingConditions']['seatsFilled'].toString()}/${user['matchingConditions']['vacantSeats'].toString()}", // Display the vacant seats count
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
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
}

