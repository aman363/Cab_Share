
import './signup_screen.dart';
import './signin_screen.dart';
import 'package:flutter/material.dart';
import '../reusable_widgets.dart';
import '../auth/shared_preference_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iitj_travel/screens/base/bottom_navigation_screen.dart';
import 'package:flutter/services.dart';



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
        MaterialPageRoute(builder: (context) => BottomNavigationScreen(clearButton:false)),
      );
    }
  }
  @override

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Handle the mobile back button press
        SystemNavigator.pop();
        return true; // Allow the app to exit
      },
      child: Scaffold(
        body: Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  20, MediaQuery.of(context).size.height * 0.30, 20, 0),
              child: Column(
                children: <Widget>[
                  Image.asset('assets/cab-share-logo.png', scale: 2.1),
                  const SizedBox(height: 120),
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
      ),
    );
  }
}