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
