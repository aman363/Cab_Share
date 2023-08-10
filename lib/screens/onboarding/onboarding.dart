import 'package:flutter/material.dart';
import 'package:iitj_travel/screens/onboarding/matching_condition.dart';
import '../reusable_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iitj_travel/screens/base/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  String? _selectedHostel;

  List<String> _hostelOptions = [
    'G1', 'G2', 'G3', 'G4', 'G5', 'G6', 'B1', 'B2', 'B3', 'B4', 'B5',
    'I2', 'I3', 'Y4', 'O3', 'O4', 'Other'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Onboarding'),
        backgroundColor: const Color.fromRGBO(17, 86, 149, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to our app!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: const Color.fromRGBO(17, 86, 149, 1)),
              ),
              SizedBox(height: 20),
              Text(
                'Please provide your basic information:',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Expanded(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: const Color.fromRGBO(17, 86, 149, 1)),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _mobileController,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your mobile number';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Mobile Number',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: const Color.fromRGBO(17, 86, 149, 1)),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _selectedHostel,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedHostel = newValue;
                        });
                      },
                      items: _hostelOptions.map((hostel) {
                        return DropdownMenuItem<String>(
                          value: hostel,
                          child: Text(hostel),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'Select Hostel',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: const Color.fromRGBO(17, 86, 149, 1)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              firebaseUIButton(context, 'Continue', () async {
                if (_formKey.currentState!.validate()) {
                  String name = _nameController.text;
                  String mobileNumber = _mobileController.text;
                  String? selectedHostel = _selectedHostel;

                  try {
                    String uid = FirebaseAuth.instance.currentUser!.uid;

                    await FirebaseFirestore.instance.collection("Profile").doc(uid).update({
                      'basicInfo.name': name,
                      'basicInfo.contact': mobileNumber,
                      'basicInfo.hostel': selectedHostel,
                    });

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MatchingCondition(),
                      ),
                    );
                  } catch (e) {
                    print("Error updating user profile: $e");
                  }
                }
              }),
            ],
          ),
        ),
      ),
    );
  }
}
