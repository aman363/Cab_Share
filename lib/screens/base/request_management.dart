import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection("Profile").doc(currentUserUid).snapshots(),
      builder: (context, userSnapshot) {
        if (userSnapshot.hasData) {
          List<String> requestsReceived = List<String>.from(userSnapshot.data!['requestReceived'] ?? []);

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

                                          },
                                          child: Text("Accept"),
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
                                          child: Text("Decline"),
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

