import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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

  void _sendMessage(String message) async {
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
      } else {
        print('Server timestamp is null');
        return;
      }

      _messageController.clear();
    } catch (e) {
      print('Error sending message: $e');
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
                  final List<Widget> reversedMessages = documents.reversed.map((document) {
                    final chat = document.data() as Map<String, dynamic>;
                    final String message = chat['message'];
                    final Timestamp timestamp = chat['time'];
                    final DateTime dateTime = timestamp.toDate();
                    final String formattedTime = _formatTimestamp(timestamp);
                    final String from = chat['from'];
                    final bool isCurrentUser = from == FirebaseAuth.instance.currentUser!.uid;

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
                  }).toList();

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
