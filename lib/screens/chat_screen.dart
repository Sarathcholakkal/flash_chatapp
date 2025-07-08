import 'package:flash_chat/constants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  static const id = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  late User loggedInUser;
  String? messageText;

  void getCurrentUser() {
    try {
      final user = _auth.currentUser; // No await needed
      if (user != null) {
        loggedInUser = user;
        print('Logged in user: ${loggedInUser.email}');
      } else {
        print('No user is currently signed in.');
      }
    } catch (e) {
      print('Error retrieving user: $e');
    }
  }

  // void getMessages() async {
  //   final messages = await _firestore.collection('messages').get();
  //   for (var message in messages.docs) {
  //     print(message.data());
  //   }
  // }'

  void messagesStream() async {
    await for (var snapshot in _firestore.collection('messages').snapshots()) {
      for (var message in snapshot.docs) {
        print(message.data());
      }
    }
  }

  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.message),
            onPressed: () {
              // getMessages();

              messagesStream();
              //
            },
          ),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              //Implement logout functionality
              _auth.signOut();
              Navigator.pop(context);
            },
          ),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection("messages").snapshots(),
              builder: (context, snapshot) {
                List<Text> messageWidgets = [];
                if (snapshot.hasData) {
                  final messages = snapshot.data!.docs;
                  for (var message in messages) {
                    Map<String, dynamic> data =
                        message.data() as Map<String, dynamic>;
                    final messageText = data['text'];
                    final messageSender = data['sender'];
                    final messagewidget = Text(
                      '$messageText from $messageSender',
                    );
                    messageWidgets.add(messagewidget);
                  }
                }
                return Column(children: messageWidgets);
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        //Do something with the user input.
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      //Implement send functionality.
                      if (messageText != null) {
                        try {
                          await _firestore.collection('messages').add({
                            'text': messageText,
                            'sender': loggedInUser.email,
                            'timestamp':
                                FieldValue.serverTimestamp(), // Add this for sorting
                          });
                          print("Message sent: $messageText");
                        } catch (e) {
                          print("Error sending message: $e");
                        }
                      }
                    },
                    child: Text('Send', style: kSendButtonTextStyle),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
