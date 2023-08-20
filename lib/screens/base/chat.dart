import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:iitj_travel/services/notification_services.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

class ChatPage extends StatefulWidget {
  final String chatRoomId;
  final String userName;

  ChatPage({required this.chatRoomId, required this.userName});


  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  NotificationServices notificationServices= NotificationServices();
  String currentUserUid=FirebaseAuth.instance.currentUser!.uid;
  DateTime _currentDay = DateTime.now();
  DateTime _previousDay = DateTime.now().subtract(Duration(days: 1));

  void _sendMessage(String message) async {
    _messageController.clear();
    if (message.trim().isEmpty) {
      return;
    }
    try {
      final serverTimestamp = Timestamp.now();
      if (serverTimestamp != null) {
        await _firestore.collection('ChatRooms').doc(widget.chatRoomId).collection('chats').add({
          'from': FirebaseAuth.instance.currentUser!.uid,
          'message': message,
          'status': false,
          'time': serverTimestamp,
        });
        final oppositeUserId = getOppositeUserId(widget.chatRoomId, currentUserUid);
        if (oppositeUserId.isNotEmpty) {
          final oppositeUserFCMToken = await getOppositeUserFCMToken(oppositeUserId);
          final currentUserDoc = await FirebaseFirestore.instance.collection("Profile").doc(currentUserUid).get();
          final currentUserName = currentUserDoc['basicInfo']['name'] ?? 'Unknown User'; // Get the current user's name
          if (oppositeUserFCMToken != null) {
            notificationServices.getDeviceToken().then((value) async{
              var data={
                'to': oppositeUserFCMToken,
                'priority': 'high',
                'notification': {
                  'title': 'New Message',
                  'body': '$currentUserName: $message',
                }
              };
              await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
                  body:jsonEncode(data),
                  headers:{
                    'Content-Type': 'application/json; charset=UTF-8',
                    'Authorization': 'key=AAAAVq17HoU:APA91bFv4d1jHUoVmyxb6HWgsbtp-6VNmNPYNyMgBKJhgV0I84FQSpzOoY60hecKTpxsKz0T7v73FY-JZ6jb13BErboRrD_x0B0YKfCniXmoI_fMtM6gF0W5q3NeNjuayvhwFArOIgXB'
                  }
              );

            });
          }
        }
      } else {
        print('Server timestamp is null');
        return;
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  String getOppositeUserId(String chatRoomId, String currentUserUid) {
    final uids = chatRoomId.split('@');
    if (uids.length == 2) {
      if (uids[0] == currentUserUid) {
        return uids[1];
      } else if (uids[1] == currentUserUid) {
        return uids[0];
      }
    }
    return '';
  }

  Future<String?> getOppositeUserFCMToken(String oppositeUserId) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection("Profile").doc(oppositeUserId).get();
      if (userSnapshot.exists) {
        Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
        return userData['fcmToken'] as String?;
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching opposite user FCM token: $e');
      return null;
    }
  }


  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) {
      return ''; // Return an empty string or a default value
    }
    DateTime dateTime = timestamp.toDate();
    String formattedTime = DateFormat.jm().format(dateTime); // Format time
    return formattedTime;
  }

  String _formatDateHeader(DateTime date) {
    final DateTime now = DateTime.now();
    final DateTime yesterday = now.subtract(Duration(days: 1));

    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    } else if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }
  Widget _buildDateHeader(DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: Text(
          _formatDateHeader(date),
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(17, 86, 149, 1), // Set app bar color
        elevation: 8,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.userName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('ChatRooms')
                  .doc(widget.chatRoomId)
                  .collection('chats')
                  .orderBy('time')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final List<DocumentSnapshot> documents = snapshot.data!.docs;
                  Widget _buildMessageWidget(DocumentSnapshot document) {
                    final chat = document.data() as Map<String, dynamic>;
                    final String message = chat['message'];
                    final Timestamp timestamp = chat['time'];
                    final DateTime dateTime = timestamp.toDate();
                    String formattedTime = _formatTimestamp(timestamp);
                    final String from = chat['from'];
                    final bool isCurrentUser = from == FirebaseAuth.instance.currentUser!.uid;

                    if (dateTime.day == _currentDay.day &&
                        dateTime.month == _currentDay.month &&
                        dateTime.year == _currentDay.year) {
                      formattedTime = "Today, $formattedTime";
                    } else if (dateTime.day == _previousDay.day &&
                        dateTime.month == _previousDay.month &&
                        dateTime.year == _previousDay.year) {
                      formattedTime = "Yesterday, $formattedTime";
                    } else {
                      // Update the previous day if the date is different
                      formattedTime = "${DateFormat('MMM dd').format(dateTime)}, $formattedTime";
                    }

                    return Align(
                      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        child: Column(
                          crossAxisAlignment: isCurrentUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isCurrentUser ? Color.fromRGBO(17, 86, 149, 1) : Colors.grey,
                                borderRadius: BorderRadius.circular(10),
                                // Add arrow-like decoration to speech bubble
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Text(
                                message,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            // Add arrow-like shape for speech bubble
                            Container(
                              width: 20,
                              height: 20,
                              transform: isCurrentUser
                                  ? Matrix4.translationValues(0, -10, 0)
                                  : Matrix4.translationValues(0, -10, 0),
                              child: Transform.rotate(
                                angle: isCurrentUser ? 3.1415 : 0,
                                child: Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.rotationY(isCurrentUser ? 3.1415 : 0),
                              child: CustomPaint(
                                painter: ArrowPainter(
                                  color: isCurrentUser ? Color.fromRGBO(17, 86, 149, 1) : Colors.grey,
                                  isCurrentUser: isCurrentUser,
                                ),
                              ),
                                ),
                              ),
                            ),
                            Text(
                              formattedTime,
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  final List<Widget> reversedMessages = [];
                  DateTime lastMessageDate = DateTime.now().add(Duration(days: 1)); // Initialize with a date in the future

                  for (int i = documents.length - 1; i >= 0; i--) {
                    final chat = documents[i].data() as Map<String, dynamic>;
                    final Timestamp timestamp = chat['time'];
                    final DateTime dateTime = timestamp.toDate();

                    if (dateTime.day != lastMessageDate.day ||
                        dateTime.month != lastMessageDate.month ||
                        dateTime.year != lastMessageDate.year) {
                      lastMessageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
                      //reversedMessages.add(_buildDateHeader(lastMessageDate));
                    }

                    reversedMessages.add(_buildMessageWidget(documents[i]));
                  }

                  return ListView(
                    reverse: true, // Reverse the list to have newest messages at the bottom
                    children: reversedMessages,
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    _sendMessage(_messageController.text);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ArrowPainter extends CustomPainter {
  final Color color;
  final bool isCurrentUser;

  ArrowPainter({required this.color, required this.isCurrentUser});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    final path = Path();
    if (isCurrentUser) {
      path.moveTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(0, size.height);
      path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
