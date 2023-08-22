import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iitj_travel/screens/onboarding/matching_condition.dart';
import '../auth/main_screen.dart';
import '../auth/shared_preference_services.dart';
import 'package:image_picker/image_picker.dart'; // Add this import
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
//import 'package:image_cropper/image_cropper.dart';
import 'dart:io';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final ImagePicker _picker = ImagePicker();
  String? imageUrl;

  Widget _buildUploadDialog(BuildContext context) {
    return AlertDialog(
      title: Text('Upload Profile Picture'),
      content: Text('Select an option to upload a profile picture:'),
      actions: [
        TextButton(
          onPressed: () async {
            // Take a photo using the camera
            Navigator.of(context).pop();
            final pickedFile = await _picker.pickImage(
              source: ImageSource.camera,
            );
            if (pickedFile != null) {
              _uploadAndSetImage(File(pickedFile.path));
            }
          },
          child: Text('Upload from Camera'),
        ),
        TextButton(
          onPressed: () async {
            // Choose an image from the gallery
            Navigator.of(context).pop();
            final pickedFile = await _picker.pickImage(
              source: ImageSource.gallery,
            );
            if (pickedFile != null) {
              _uploadAndSetImage(File(pickedFile.path));
            }
          },
          child: Text('Upload from Gallery'),
        ),
      ],
    );
  }

  Future<void> _uploadAndSetImage(File imageFile) async {
    // Upload the image to Firebase Storage
    String uid = FirebaseAuth.instance.currentUser!.uid;
    String imageName = 'profile_image_$uid.jpg';
    firebase_storage.Reference storageRef =
    firebase_storage.FirebaseStorage.instance.ref().child('ProfileImage').child(imageName);

    final uploadTask = storageRef.putFile(imageFile);
    await uploadTask;

    imageUrl = await storageRef.getDownloadURL();

    // Update the user's data with the image URL
    await FirebaseFirestore.instance
        .collection("Profile")
        .doc(uid)
        .update({'basicInfo.image': imageUrl});

    setState(() {}); // Refresh the UI
  }

  Future<Map<String, dynamic>> fetchUserData(String uid) async {
    DocumentSnapshot userSnapshot =
    await FirebaseFirestore.instance.collection("Profile").doc(uid).get();
    if (userSnapshot.exists) {
      return userSnapshot.data() as Map<String, dynamic>;
    } else {
      return {}; // Return an empty map if user doesn't exist
    }
  }

  CircleAvatar buildCircleAvatar(String imageUrl, String currentUserName) {
    if (imageUrl.isEmpty) {
      return CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey,
        child: Icon(
          Icons.person,
          color: Colors.white,
          size: 40,
        ),
      );
    } else {
      return CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey,
        backgroundImage: NetworkImage(imageUrl),
      );
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
          String currentUserName = userData['basicInfo']['name'];

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
                          buildCircleAvatar(
                            userData['basicInfo']['image'] ?? '',
                            currentUserName,
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
                              child: GestureDetector(
                                onTap: () {
                                  // Display the upload dialog when the camera icon is pressed
                                  showDialog(
                                    context: context,
                                    builder: (context) => _buildUploadDialog(context),
                                  );
                                },
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Color.fromRGBO(17, 86, 149, 1),
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        currentUserName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color.fromRGBO(17, 86, 149, 1),
                        ),
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


