
import './signup_screen.dart';
import './signin_screen.dart';
import 'package:flutter/material.dart';
import '../reusable_widgets.dart';
import '../auth/shared_preference_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iitj_travel/screens/base/bottom_navigation_screen.dart';



class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}
class _MainScreenState extends State<MainScreen> {
  bool _isBoolValue =false;
  @override

  void initState() {
    super.initState();
    initializeSharedPreferences();
  }

  void initializeSharedPreferences() async {
    _isBoolValue = await SharedPreferencesService.getBoolValue('_isBoolValue');


    if (_isBoolValue) {
      // User is already logged in, navigate to home screen
      final FirebaseAuth auth = FirebaseAuth.instance;
      final User? user = auth.currentUser;
      final uid = user?.uid;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BottomNavigationScreen()),
      );
    }
  }
  @override

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        //decoration: const BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/front_new.png"), fit: BoxFit.cover),),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height * 0.30, 20, 0),
            child: Column(
              children: <Widget>[

                const Text(
                  "AI",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 36.8, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  "Welcome",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 36.8, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                //Image.asset(
                //  'assets/images/hand.png',
                 // scale: 2.1,),

                const SizedBox(height: 120),

                Text(
                  "IITJ Travel",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                firebaseUIButton(context, "Register", () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen()));
                }),
                Btn(context, "Login", () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SignInScreen()));



                }),
              ],


            ),
          ),
        ),
      ),
    );

  }
}