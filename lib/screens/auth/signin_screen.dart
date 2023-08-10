
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iitj_travel/screens/onboarding/onboarding.dart';
import '../base/home_screen.dart';
import '../reusable_widgets.dart';
import './signup_screen.dart';
import './reset_password.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  String sr = "";

  Map<String, dynamic>? fetchedData;
  bool flag = false;

  // @override
  // void initState() {
  //   String uid = getCurrentUID();
  //   if (uid != ""){
  //     Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //             builder: (context) => flag
  //                 ? const SignUpOnboard()
  //                 : HomeScreen(
  //               uid: uid,
  //             )));
  //   }
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height * 0, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(

                  child: Text(
                    "Enter login Info",
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                  ),

                ),
                const SizedBox(
                  height: 30,
                ),
                Text(
                  "Email Address",
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                reusableTextField("Enter Email Address",
                    Icons.person_outline, false, _emailTextController),
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
                reusableTextField("Enter Password", Icons.lock_outline, true,
                    _passwordTextController),
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

                forgetPassword(context),
                const SizedBox(height: 333),


                firebaseUIButton(context, "Login", ()  {
                  String username = _emailTextController.text;
                  String password = _passwordTextController.text;
                  FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                      email: username, password: password)
                      .then((value) async {
                    if (!FirebaseAuth.instance.currentUser!.emailVerified) {
                      var snackBar = SnackBar(
                        content: Text("Email not verified"),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      FirebaseAuth.instance.signOut();
                    }

                    if (FirebaseAuth.instance.currentUser!.emailVerified) {
                      //SharedPreferencesService.updateBoolValue(true);
                      final FirebaseAuth auth = FirebaseAuth.instance;
                      final User? user = auth.currentUser;
                      final uid = user?.uid;
                      DocumentSnapshot snapshot = await FirebaseFirestore
                          .instance
                          .collection("Profile")
                          .doc(uid)
                          .get();
                      if (snapshot.exists) {
                        setState(() {
                          fetchedData =
                          snapshot.data() as Map<String, dynamic>?;
                        });
                      }
                      if(fetchedData!['basicInfo']['name'].isEmpty){
                        flag=true;
                      }
                      // ignore: use_build_context_synchronously
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => flag
                                  ? OnboardingScreen() : HomeScreen()));
                    }
                  }).onError((error, stackTrace) {
                    print(error.toString());
                    if (error.toString() ==
                        "[firebase_auth/wrong-password] The password is invalid or the user does not have a password.") {
                      setState(() {
                        sr = "*Password does not match";
                      });
                    }
                    if (error.toString() ==
                        "[firebase_auth/user-not-found] There is no user record corresponding to this identifier. The user may have been deleted.") {
                      setState(() {
                        sr = "*User Not Found";
                      });
                    }
                  });
                }),
                signUpOption()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Don't Have Account",
            style: TextStyle(color: Colors.black)),
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const SignUpScreen()));
          },
          child: Text(
            "Sign Up",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }

  Widget forgetPassword(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 35,
      alignment: Alignment.bottomLeft,
      child: TextButton(
        child: Text(
          "Forget Password",
          style: const TextStyle(color: Colors.black87),
          textAlign: TextAlign.left,
        ),
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ResetPassword())),
      ),
    );
  }
}
