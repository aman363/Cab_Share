
import './signin_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../reusable_widgets.dart';
import '../utils/color_utils.dart';

import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() {
    return _SignUpScreenState();
  }
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _psdTextController = TextEditingController();
  String sr = "";
  void createUserDataStructure(String uid) {
    FirebaseFirestore.instance.collection("Profile").doc(uid).set({
      'uid': uid,
      'fcmToken':"",
      'requestSent':[],
      'requestReceived':[],
      'requestEstablished':[],
      'basicInfo': {
        'name': "",
        'contact': "",
        'hostel':"",
        'image':"",
      },
      'matchingConditions': {
        'date': "",
        'time':"",
        'source':"",
        'destination':"",
        'autoBooked':0,
        'vacantSeats':0,
        'seatsFilled':0,
        'modeOfTravel':"",
      },
  });}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,

      ),
      body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
              child: Padding(
                padding:  EdgeInsets.fromLTRB(20, MediaQuery.of(context).size.height * 0.1, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(

                      child:  Text(
                        "New Registration",
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                      ),

                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Email",
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    reusableTextField("Enter Email Address", Icons.person_outline,
                        false, _emailTextController),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Password",
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    reusableTextField("Enter Password", Icons.lock_outlined, true,
                        _passwordTextController),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Confirm Password",
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    reusableTextField("Enter Password Again", Icons.lock_outlined, true,
                        _psdTextController),
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        sr,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          // fontFamily: 'Arial',
                          // fontSize: 18,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          height: 2,
                          // textAlign:
                        ),
                      ),
                    ),
                    const SizedBox(height: 290),
                    firebaseUIButton(context, "Send Confirmation link",
                            () async {

                          if (!_emailIsValid(_emailTextController.text)) {
                              setState(() {
                              sr = "*Signup with your IITJ account";
                              });
                              }
                          else if (_passwordTextController.text.length < 6) {
                            setState(() {
                              sr = "*Password should be atleast 6 letters";
                            });
                          } else if (_psdTextController.text !=
                              _passwordTextController.text) {
                            setState(() {
                              sr = "*Password Don't Match";
                            });
                          } else {
                           UserCredential user= await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                                email: _emailTextController.text,
                                password: _passwordTextController.text);

                              // final user = FirebaseAuth.instance.currentUser!;
                              print(user);
                              FirebaseAuth.instance.currentUser?.sendEmailVerification();
                           try {
                             createUserDataStructure(FirebaseAuth.instance.currentUser!.uid);
                             print("User data structure created successfully");
                           } catch (e) {
                             print("Error creating user data structure: $e");
                           }

                              var snackBar = SnackBar(
                                content:
                                Text("Check Mailbox for verification"),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                               //createUserDataStructure(FirebaseAuth.instance.currentUser!.uid); // Create the data structure
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SignInScreen()),
                              );

                          }
                        })
                  ],
                ),
              ))),
    );
  }
  bool _emailIsValid(String email) {
    final emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@iitj\.ac\.in$');
    return emailRegExp.hasMatch(email);
  }
}
