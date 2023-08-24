import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:iitj_travel/services/notification_services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:iitj_travel/screens/base/chat.dart';

class RequestsEstablishedPage extends StatelessWidget {

  String getChatRoomId(String uid1, String uid2) {
    List<String> uids = [uid1, uid2];
    uids.sort(); // Sort the UIDs to ensure consistency
    return "${uids[0]}@${uids[1]}";
  }

  final String currentUserUid;

  RequestsEstablishedPage({required this.currentUserUid});
  NotificationServices notificationServices= NotificationServices();

  Future<void> updateSeatsFilled(String userId, int newValue) async {
    int finalValue = newValue >= 0 ? newValue : 0;
    await FirebaseFirestore.instance.collection("Profile").doc(userId).update({
      'matchingConditions.seatsFilled': finalValue,
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection("Profile").doc(currentUserUid).snapshots(),
      builder: (context, userSnapshot) {
        if (userSnapshot.hasData) {
          List<String> requestsEstablished = List<String>.from(userSnapshot.data!['requestEstablished'] ?? []);
          String loggedInUserName=userSnapshot.data!['basicInfo']['name'];
          if (requestsEstablished.isEmpty) {
            // Display a centered message when there are no cards to show
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20), // Add horizontal padding
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.handshake, // People icon
                      size: 100,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "The travellers with whom the travel is establised will be displayed here",
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
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ChatPage(
                                                  chatRoomId: getChatRoomId(currentUserUid, userId),
                                                  userName: user['basicInfo']['name'],
                                                ),
                                              ),
                                            );
                                          },
                                          child: Row(
                                            children: [
                                              Icon(Icons.message), // Message icon
                                              SizedBox(width: 8), // Add spacing between icon and text
                                              Text("Chat"),
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
                                              int currentSeatsFilledCurrentUser = userSnapshot.data!['matchingConditions']['seatsFilled'] - 1;
                                              await updateSeatsFilled(currentUserUid, currentSeatsFilledCurrentUser);

                                              // Update seatsFilled for the opposite user
                                              int currentSeatsFilledOppositeUser = user['matchingConditions']['seatsFilled'] - 1;
                                              await updateSeatsFilled(userId, currentSeatsFilledOppositeUser);
                                            }

                                          },
                                          child: Row(
                                            children: [
                                              Icon(Icons.cancel), // Call icon
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
  Widget buildAvatar(Map<String, dynamic> user) {
    String imageUrl = user['basicInfo']['image'];
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 40,
        backgroundImage: NetworkImage(imageUrl),
      );
    } else {
      return CircleAvatar(
        radius: 40,
        backgroundColor: Colors.grey,
        child: Icon(
          Icons.person,
          color: Colors.white,
          size: 40,
        ),
      );
    }
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
}