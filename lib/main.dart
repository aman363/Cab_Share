import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:iitj_travel/screens/auth/main_screen.dart';
import 'package:iitj_travel/screens/onboarding/matching_condition.dart';
import 'package:iitj_travel/screens/onboarding/onboarding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp( options: const FirebaseOptions( apiKey: "AIzaSyDr3Nt7EFGiWsloHF7n0Go8MjFGgCQ-fLU",
    appId: "1:372277714565:android:15d444a918dff6a65453ec",
    messagingSenderId: "372277714565",
    projectId: "iitj-travel-e12d2", ), );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MainScreen(),
    );
  }
}


