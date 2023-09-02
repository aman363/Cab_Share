import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iitj_travel/screens/base/contact_us.dart';
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
      contentPadding: EdgeInsets.zero, // Remove content padding
      titlePadding: EdgeInsets.zero, // Remove title padding
      title: SizedBox.shrink(), // Empty title
      content: SizedBox.shrink(), // Empty content
      contentTextStyle: TextStyle(fontSize: 0), // Hide content text
      buttonPadding: EdgeInsets.zero, // Remove button padding
      actions: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          width: double.infinity, // Make the container take up the full width
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.grey), // Add a top border
              bottom: BorderSide(color: Colors.grey), // Add a bottom border
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () async {
                  // Take a photo using the camera
                  Navigator.of(context).pop();
                  final pickedFile = await _picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 30,
                  );
                  if (pickedFile != null) {
                    _uploadAndSetImage(File(pickedFile.path));
                  }
                },
                child: Text('Upload from Camera',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ),
              Divider(
                color: Colors.grey, // Add a line divider between buttons
                height: 0, // Standard height for divider
                thickness: 1, // Thickness of the line
              ),
              TextButton(
                onPressed: () async {
                  // Choose an image from the gallery
                  Navigator.of(context).pop();
                  final pickedFile = await _picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 30,
                  );
                  if (pickedFile != null) {
                    _uploadAndSetImage(File(pickedFile.path));
                  }
                },
                child: Text('Upload from Gallery',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ),
              if (imageUrl != "")
                Column(
                  children: [
                    Divider(
                      color: Colors.grey, // Add a line divider between buttons
                      height: 0, // Standard height for divider
                      thickness: 1, // Thickness of the line
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _removeImage();
                      },
                      child: Text('Remove Photo',
                          style: TextStyle(color: Colors.red, fontSize: 16)),
                    ),
                  ],
                ),
            ],
          ),
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

    final uploadTask = storageRef.putFile(
      imageFile,
      firebase_storage.SettableMetadata(
        contentType: 'image/jpeg', // Set the content type to JPEG
      ),
    );
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

  void _removeImage() async {
    // Remove the image from Firebase Storage
    String uid = FirebaseAuth.instance.currentUser!.uid;
    String imageName = 'profile_image_$uid.jpg';
    firebase_storage.Reference storageRef =
    firebase_storage.FirebaseStorage.instance.ref().child('ProfileImage').child(imageName);

    await storageRef.delete();

    // Update the user's data to remove the image URL
    await FirebaseFirestore.instance
        .collection("Profile")
        .doc(uid)
        .update({'basicInfo.image': ""});

    imageUrl = "";

    setState(() {}); // Refresh the UI
  }

  CircleAvatar buildCircleAvatar(String imageUrl, String currentUserName) {
    if (imageUrl == "" || imageUrl.isEmpty) {
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
                          GestureDetector(
                            onTap: () {
                              // Display the upload dialog when the person icon is pressed
                              showDialog(
                                context: context,
                                builder: (context) => _buildUploadDialog(context),
                              );
                            },
                            child: buildCircleAvatar(
                              userData['basicInfo']['image'] ?? '',
                              currentUserName,
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
                    label: "College",
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
                      "Set/Update Travel Details",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to ContactUsPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ContactUsPage()),
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
                    icon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.email,
                          //color: Colors.white,
                        ),
                      ],
                    ),
                    label: Text(
                      "Contact Us",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
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
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color.fromRGBO(17, 86, 149, 1),
                      ),
                    ),
                  ),
                  Spacer(),
                  Center(
                    child: Text(
                      "v1.0.0",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      "Developed by: Aman Srivastava & Dr. Arpit Khandelwal",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
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


