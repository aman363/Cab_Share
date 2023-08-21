import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iitj_travel/screens/onboarding/matching_condition.dart';

class MyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String currentUserUid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text("My Card"),
        backgroundColor: Color.fromRGBO(17, 86, 149, 1), // Change app bar color
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection("Profile").doc(currentUserUid).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var user = snapshot.data!.data() as Map<String, dynamic>;
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView( // Wrap the card content in SingleChildScrollView
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Container(
                        color: Color.fromRGBO(169, 210, 255, 1.0),
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 15),
                        width: double.infinity,
                        child: Text(
                          "${user['basicInfo']['name'].toUpperCase()}",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(14, 77, 141, 1.0),
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
                                  Icon(Icons.arrow_forward, color: Colors.grey),
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
                            if (user['matchingConditions']['modeOfTravel'] != null &&
                                user['matchingConditions']['modeOfTravel'].isNotEmpty)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      user['matchingConditions']['modeOfTravel'] == "Auto"
                                          ? Image.asset('assets/auto.png', width: 35, height: 35)
                                          : Image.asset('assets/taxi.png', width: 35, height: 35),
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
                                      Icon(Icons.person, size: 24),
                                      SizedBox(width: 5),
                                      Text(
                                        "${user['matchingConditions']['seatsFilled'].toString()}/${user['matchingConditions']['vacantSeats'].toString()}",
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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => MatchingCondition()
                                        ),
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Icon(Icons.update), // Message icon
                                        SizedBox(width: 8), // Add spacing between icon and text
                                        Text("Update"),
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
                                      await FirebaseFirestore.instance
                                          .collection("Profile")
                                          .doc(currentUserUid)
                                          .update({
                                        'matchingConditions': {
                                          'date': "",
                                          'time': "",
                                          'source': "",
                                          'destination': "",
                                          'autoBooked': 0,
                                          'vacantSeats': 0,
                                          'seatsFilled': 0,
                                          'modeOfTravel': "",
                                        },
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("Matching conditions discarded"),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Icon(Icons.cancel), // Message icon
                                        SizedBox(width: 8), // Add spacing between icon and text
                                        Text("Discard"),
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
                      // Rest of your card content
                      // ...
                    ],
                  ),
                ),
              );
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
