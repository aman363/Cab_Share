import 'package:flutter/material.dart';
import '../auth/signin_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> matchingUsers = [];
  late String currentUserUid;

  @override
  void initState() {
    super.initState();
    currentUserUid = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Matching Users'),
        backgroundColor: const Color.fromRGBO(17, 86, 149, 1),
      ),
      body: Center(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("Profile")
              .where('matchingConditions.source', isNotEqualTo: '')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              matchingUsers = snapshot.data!.docs
                  .map((doc) => doc.data() as Map<String, dynamic>)
                  .where((user) => user['uid'] != currentUserUid)
                  .toList();

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
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
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${user['basicInfo']['name']} from ${user['basicInfo']['hostel']} is travelling from ${user['matchingConditions']['source']} to ${user['matchingConditions']['destination']} on ${user['matchingConditions']['date']} at ${user['matchingConditions']['time']}.",
                                    style: TextStyle(
                                      fontSize: 18,
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
                                    onPressed: () {
                                      // Handle request button press
                                      print("Request button pressed for ${user['basicInfo']['name']}");
                                    },
                                    child: Text("Request"),
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
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut().then((value) {
                        print("Signed Out");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignInScreen(),
                          ),
                        );
                      });
                    },
                    child: Text("Logout"),
                    style: ElevatedButton.styleFrom(
                      primary: const Color.fromRGBO(17, 86, 149, 1),
                      padding: EdgeInsets.symmetric(
                        horizontal: 35,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              );
            } else {
              return CircularProgressIndicator(); // Loading indicator
            }
          },
        ),
      ),
    );
  }
}
