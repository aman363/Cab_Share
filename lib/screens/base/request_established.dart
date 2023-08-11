import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RequestsEstablishedPage extends StatelessWidget {
  final String currentUserUid;

  RequestsEstablishedPage({required this.currentUserUid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection("Profile").doc(currentUserUid).snapshots(),
      builder: (context, userSnapshot) {
        if (userSnapshot.hasData) {
          List<String> requestsEstablished = List<String>.from(userSnapshot.data!['requestEstablished'] ?? []);

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
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        // Add your button logic here
                                      },
                                      child: Text("Message"),
                                      style: ElevatedButton.styleFrom(
                                        primary: const Color.fromRGBO(17, 86, 149, 1),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 15,
                                          vertical: 10,
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