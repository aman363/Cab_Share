import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iitj_travel/screens/onboarding/matching_condition.dart';
import '../auth/main_screen.dart';
import '../auth/shared_preference_services.dart';

class MyPage extends StatelessWidget {
  Future<Map<String, dynamic>> fetchUserData(String uid) async {
    DocumentSnapshot userSnapshot =
    await FirebaseFirestore.instance.collection("Profile").doc(uid).get();
    if (userSnapshot.exists) {
      return userSnapshot.data() as Map<String, dynamic>;
    } else {
      return {}; // Return an empty map if user doesn't exist
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    String? currentUserEmail = FirebaseAuth.instance.currentUser?.email;

    return FutureBuilder<Map<String, dynamic>>(
      future: fetchUserData(currentUserUid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Display a loading indicator while fetching data
        } else if (snapshot.hasError) {
          return const Text("Error fetching user data");
        } else {
          Map<String, dynamic> userData = snapshot.data!;

          return WillPopScope(
            onWillPop: () async {
              // Prevent back navigation from the My Page screen
              return false;
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey,
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor:
                              Colors.white,
                              child: Icon(
                                Icons.camera_alt,
                                color: Color.fromRGBO(17, 86, 149, 1),
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  UserInfoItem(
                    icon: Icons.email,
                    label: "Email",
                    value: currentUserEmail,
                  ),
                  const SizedBox(height: 10),
                  UserInfoItem(
                    icon: Icons.phone,
                    label: "Contact",
                    value: userData['basicInfo']['contact'],
                  ),
                  const SizedBox(height: 10),
                  UserInfoItem(
                    icon: Icons.home,
                    label: "Hostel",
                    value: userData['basicInfo']['hostel'],
                  ),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to MatchingCondition screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MatchingCondition(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      primary: const Color.fromRGBO(17, 86, 149, 1),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Set Travel Details",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Logout functionality
                      SharedPreferencesService.updateBoolValue(false);
                      FirebaseAuth.instance.signOut().then((value) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MainScreen()),
                        );
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(
                      Icons.exit_to_app,
                      color: Color.fromRGBO(17, 86, 149, 1),
                    ),
                    label: const Text(
                      "Logout",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color.fromRGBO(17, 86, 149, 1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}

class UserInfoItem extends StatelessWidget {
  final IconData icon;
  final String? label;
  final String? value;

   UserInfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          padding: EdgeInsets.all(8),
          child: Icon(
            icon,
            color: Color.fromRGBO(17, 86, 149, 1),
            size: 26,
          ),
        ),
        SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$label",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            Text(
              "$value",
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }
}


