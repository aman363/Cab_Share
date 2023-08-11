import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/main_screen.dart';
import '../auth/shared_preference_services.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevent back navigation from the My Page screen
        return false;
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                SharedPreferencesService.updateBoolValue(false);
                FirebaseAuth.instance.signOut().then((value) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                  );
                });
              },
              child: Text(
                "Logout",
                style: TextStyle(
                  fontSize: 20, // Increase the font size as needed
                  fontWeight: FontWeight.w600,
                  color: Colors.blue, // Change the text color as needed
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                SharedPreferencesService.updateBoolValue(false);
                FirebaseAuth.instance.signOut().then((value) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                  );
                });
              },
              icon: Icon(
                Icons.arrow_forward_ios,
                color: Colors.blue, // Change the icon color as needed
              ),
            ),
          ],
        ),
      ),
    );
  }
  
}
