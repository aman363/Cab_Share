import 'package:firebase_auth/firebase_auth.dart';
import 'package:iitj_travel/screens/auth/signin_screen.dart';
import '../reusable_widgets.dart';
import 'package:flutter/material.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({Key? key}) : super(key: key);

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final TextEditingController _emailTextController = TextEditingController();
  String sr = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: const BackButton(
            color: Colors.black
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,


      ),
      body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,

          child: SingleChildScrollView(
              child: Padding(
                padding:  EdgeInsets.fromLTRB(20, MediaQuery.of(context).size.height * 0.06, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(

                      child:  Text(
                        "Reset Password",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                      ),

                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      "Email address",
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    reusableTextField("Enter Email address", Icons.person_outline, false,
                        _emailTextController),
                    const SizedBox(
                      height: 10,
                    ),
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
                          // height: 0,
                          // textAlign:
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 560,
                    ),
                    firebaseUIButton(context, "Reset Password", () {
                      if (_emailTextController.text.isNotEmpty) {
                        FirebaseAuth.instance
                            .sendPasswordResetEmail(email: _emailTextController.text)
                            .then((value) {
                          final snackBar = SnackBar(
                            content: Text('Reset Password Email Sent! Check your Inbox'),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignInScreen()),
                          );
                        }).catchError((error) {
                          print(error);
                          if (error.toString() ==
                              "[firebase_auth/user-not-found] There is no user record corresponding to this identifier. The user may have been deleted.") {
                            setState(() {
                              sr = "*User Not Found";
                            });
                          } else if(error.toString() =="[firebase_auth/invalid-email] The email address is badly formatted."){
                            setState(() {
                              sr = "*The email address is badly formatted";
                            });
                          }
                        });
                      } else {
                        setState(() {
                          sr = "*Please Enter an Email Address";
                        });
                      }
                    }),
                  ],
                ),
              ))),
    );
  }
}