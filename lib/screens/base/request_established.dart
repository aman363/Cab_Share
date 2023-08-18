import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:iitj_travel/services/notification_services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RequestsEstablishedPage extends StatelessWidget {
  final String currentUserUid;

  RequestsEstablishedPage({required this.currentUserUid});
  NotificationServices notificationServices= NotificationServices();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection("Profile").doc(currentUserUid).snapshots(),
      builder: (context, userSnapshot) {
        if (userSnapshot.hasData) {
          List<String> requestsEstablished = List<String>.from(userSnapshot.data!['requestEstablished'] ?? []);
          String loggedInUserName=userSnapshot.data!['basicInfo']['name'];

          return ListView.builder(
            itemCount: requestsEstablished.length,
            itemBuilder: (context, index) {
              String userId = requestsEstablished[index];
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
                              color: Color.fromRGBO(169, 210, 255, 1.0), // Blue color
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 15),
                              width: double.infinity, // Make the color strip extend to full width
                              child: Text(
                                "${user!['basicInfo']['name'].toUpperCase()}",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(14, 77, 141, 1.0), // White text color
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
                                    child: Row(
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
                                  Text(
                                    user['matchingConditions']['autoBooked'] == 1
                                        ? "Auto is booked"
                                        : "Auto not booked yet",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: user['matchingConditions']['autoBooked'] == 1
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.center,
                                    child: SingleChildScrollView( // Wrap the buttons in a SingleChildScrollView
                                      scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () async {
                                            String contactNumber = user['basicInfo']['contact'];

                                            // Generate a URL with the 'tel:' scheme to initiate a call
                                            String url = 'tel:$contactNumber';

                                            // Check if the URL can be launched
                                            if (await canLaunch(url)) {
                                              // Launch the URL
                                              await launch(url);
                                            } else {
                                              // Handle if the URL can't be launched (e.g., no phone app available)
                                              print('Could not launch $url');
                                            }

                                          },
                                          child: Row(
                                            children: [
                                              Icon(Icons.call), // Call icon
                                              SizedBox(width: 8), // Add spacing between icon and text
                                              Text("Call"),
                                            ],
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            primary: const Color.fromRGBO(17, 86, 149, 1),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 10,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(5),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 15), // Add some spacing between buttons
                                        ElevatedButton(
                                          onPressed: () async {
                                          },
                                          child: Row(
                                            children: [
                                              Icon(Icons.message), // Message icon
                                              SizedBox(width: 8), // Add spacing between icon and text
                                              Text("Message"),
                                            ],
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            primary: const Color.fromRGBO(17, 86, 149, 1),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 10,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(5),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 15),
                                        ElevatedButton(
                                          onPressed: () async {
                                            bool shouldCancel = await showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text("Confirm Cancel"),
                                                  content: Text("Are you sure you want to cancel travel with ${user['basicInfo']['name']}?"),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop(false); // Don't cancel
                                                      },
                                                      child: Text("No",style: TextStyle(color: const Color.fromRGBO(17, 86, 149, 1)),),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop(true); // Confirm cancel
                                                      },
                                                      child: Text("Yes",style: TextStyle(color: Colors.red,),)
                                                    ),
                                                  ],
                                                );
                                              },
                                            );

                                            if(shouldCancel==true) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text("Established Travel with ${user['basicInfo']['name']} is cancelled"),
                                                  backgroundColor: Colors.lightBlue,
                                                ),
                                              );
                                              notificationServices.getDeviceToken().then((value) async{
                                                var data={
                                                  'to': user['fcmToken'],
                                                  'priority': 'high',
                                                  'notification': {
                                                    'title': 'Travel Cancelled',
                                                    'body': '$loggedInUserName cancelled travel with you',
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
                                              await FirebaseFirestore.instance
                                                  .collection("Profile").doc(
                                                  currentUserUid).update({
                                                'requestEstablished': FieldValue
                                                    .arrayRemove([userId]),
                                              });
                                              await FirebaseFirestore.instance
                                                  .collection("Profile").doc(
                                                  userId).update({
                                                'requestEstablished': FieldValue
                                                    .arrayRemove(
                                                    [currentUserUid]),
                                              });
                                              String chatRoomId1 = '${currentUserUid}@${userId}';
                                              String chatRoomId2 = '${userId}@${currentUserUid}';

                                              // Check if the document exists with the first possible ID
                                              var chatRoomDoc1 = await FirebaseFirestore
                                                  .instance.collection(
                                                  "ChatRooms")
                                                  .doc(chatRoomId1)
                                                  .get();
                                              if (chatRoomDoc1.exists) {
                                                await FirebaseFirestore.instance
                                                    .collection("ChatRooms")
                                                    .doc(chatRoomId1)
                                                    .delete();
                                              } else {
                                                // If the document doesn't exist with the first ID, check the second ID
                                                var chatRoomDoc2 = await FirebaseFirestore
                                                    .instance.collection(
                                                    "ChatRooms").doc(
                                                    chatRoomId2).get();
                                                if (chatRoomDoc2.exists) {
                                                  await FirebaseFirestore
                                                      .instance.collection(
                                                      "ChatRooms").doc(
                                                      chatRoomId2).delete();
                                                } else {
                                                  // Handle if the document doesn't exist with either ID
                                                  print(
                                                      "Chat room document doesn't exist");
                                                }
                                              }

                                            }

                                          },
                                          child: Row(
                                            children: [
                                              Icon(Icons.clear), // Call icon
                                              SizedBox(width: 8), // Add spacing between icon and text
                                              Text("Cancel"),
                                            ],
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            primary: Colors.red,
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 10,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(5),
                                            ),
                                          ),
                                        ),
                                      ],
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