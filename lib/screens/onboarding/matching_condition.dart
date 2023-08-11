import 'package:flutter/material.dart';
import 'package:iitj_travel/screens/base/bottom_navigation_screen.dart';
import 'package:iitj_travel/screens/base/home_screen.dart';
import '../reusable_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';


class MatchingCondition extends StatefulWidget {
  const MatchingCondition({Key? key}) : super(key: key);

  @override
  State<MatchingCondition> createState() => _MatchingConditionState();
}

class _MatchingConditionState extends State<MatchingCondition> {
  String? _selectedSource;
  String? _selectedDestination;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _autoBooked = false;

  bool get canContinue =>
      _selectedSource != null &&
          _selectedDestination != null &&
          _selectedDate != null &&
          _selectedTime != null;

  void updateUserMatchingConditions(String uid) {
    String formattedDate = _selectedDate == null
        ? ""
        : DateFormat('dd-MM-yyyy').format(_selectedDate!);

    String formattedTime = _selectedTime == null
        ? ""
        : TimeOfDay.fromDateTime(
      DateTime(0, 1, 1, _selectedTime!.hour, _selectedTime!.minute),
    ).format(context); // Format the time

    FirebaseFirestore.instance.collection("Profile").doc(uid).update({
      'matchingConditions': {
        'date': formattedDate,
        'time': formattedTime, // Use the formatted time
        'source': _selectedSource ?? "",
        'destination': _selectedDestination ?? "",
        'autoBooked': _autoBooked ? 1 : 0,
      },
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('I have to Travel'),
        backgroundColor: const Color.fromRGBO(17, 86, 149, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text(
              'Please provide your Travelling information:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedSource,
                    hint: Text('Source'),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedSource = newValue;
                      });
                    },
                    items: ['IIT Jodhpur', 'Station', 'Airport', 'City']
                        .map((location) {
                      return DropdownMenuItem<String>(
                        value: location,
                        child: Text(location),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Source',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.swap_horiz),
                  onPressed: () {
                    setState(() {
                      final temp = _selectedSource;
                      _selectedSource = _selectedDestination;
                      _selectedDestination = temp;
                    });
                  },
                ),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedDestination,
                    hint: Text('Destination'),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedDestination = newValue;
                      });
                    },
                    items: ['IIT Jodhpur', 'Station', 'Airport', 'City']
                        .map((location) {
                      return DropdownMenuItem<String>(
                        value: location,
                        child: Text(location),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Destination',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: const Color.fromRGBO(17, 86, 149, 1),
                padding: EdgeInsets.symmetric(horizontal: 35, vertical: 20), // Adjust padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3), // Add rounded corners
                ),
              ),
              onPressed: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                );
                if (selectedDate != null) {
                  setState(() {
                    _selectedDate = selectedDate;
                  });
                }
              },
              child: Text(
                _selectedDate == null
                    ? 'Select Date'
                    : 'Date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                style: TextStyle(fontSize: 16), // Adjust font size
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: const Color.fromRGBO(17, 86, 149, 1),
                padding: EdgeInsets.symmetric(horizontal: 35, vertical: 20), // Adjust padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3), // Add rounded corners
                ),
              ),
              onPressed: () async {
                final selectedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (selectedTime != null) {
                  setState(() {
                    _selectedTime = selectedTime;
                  });
                }
              },
              child: Text(
                _selectedTime == null
                    ? 'Select Time'
                    : 'Time: ${_selectedTime!.hour}:${_selectedTime!.minute}',
                style: TextStyle(fontSize: 16), // Adjust font size
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text(
                  'Auto/Taxi Booked:',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(width: 10),
                Switch(
                  value: _autoBooked,
                  onChanged: (newValue) {
                    setState(() {
                      _autoBooked = newValue;
                    });
                  },
                  activeColor: const Color.fromRGBO(17, 86, 149, 1),
                ),
              ],
            ),
            SizedBox(height: 20),
            Spacer(),
            firebaseUIButton(context, 'Find Partners', () {
              if (canContinue) {
                String userId = FirebaseAuth.instance.currentUser!.uid;
                updateUserMatchingConditions(userId);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BottomNavigationScreen(),
                  ),
                );

                // Do something with the entered data
                // You can navigate to the next screen or perform other actions here
              } else {
                String source = _selectedSource ?? 'Data not given';
                String destination = _selectedDestination ?? 'Data not given';
                String selectedDate = _selectedDate == null
                    ? 'No date selected'
                    : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}';
                String selectedTime = _selectedTime == null
                    ? 'No time selected'
                    : '${_selectedTime!.hour}:${_selectedTime!.minute}';

                // Do something with the entered data
                // You can show an error message or handle it accordingly
              }
            }),
            SizedBox(height: 5),
            Btn(context, 'Later', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BottomNavigationScreen(),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
