import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:iitj_travel/screens/auth/main_screen.dart';
import './screens/auth/shared_preference_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp( options: const FirebaseOptions( apiKey: "AIzaSyDr3Nt7EFGiWsloHF7n0Go8MjFGgCQ-fLU",
    appId: "1:372277714565:android:15d444a918dff6a65453ec",
    messagingSenderId: "372277714565",
    projectId: "iitj-travel-e12d2", ), );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Check if the flag is not set (first time install)
  bool isFirstTimeInstall = prefs.getBool('firstTimeInstall') ?? true;

  if (isFirstTimeInstall) {
    // Set the initial value to false
    await prefs.setBool('firstTimeInstall', false);
    SharedPreferencesService.updateBoolValue(false);
    // Set any other initial values if needed
  }
  runApp(const MyApp());
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async{
  await Firebase.initializeApp( options: const FirebaseOptions( apiKey: "AIzaSyDr3Nt7EFGiWsloHF7n0Go8MjFGgCQ-fLU",
    appId: "1:372277714565:android:15d444a918dff6a65453ec",
    messagingSenderId: "372277714565",
    projectId: "iitj-travel-e12d2", ), );
  print(message.notification!.title.toString());
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



