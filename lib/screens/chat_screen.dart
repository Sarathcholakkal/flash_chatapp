import 'package:flash_chat/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  static const id = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
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
            //
            MessageStream(firestore: _firestore),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
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
                      messageTextController.clear();
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

class MessageStream extends StatelessWidget {
  const MessageStream({super.key, required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection("messages").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(backgroundColor: Colors.lightBlue),
          );
        }
        List<MessageBubble> messageWidgets = [];
        if (snapshot.hasData) {
          final messages = snapshot.data!.docs;
          for (var message in messages) {
            Map<String, dynamic> data = message.data() as Map<String, dynamic>;
            final messageText = data['text'];
            final messageSender = data['sender'];
            final messagewidget = MessageBubble(
              sender: messageSender,
              text: messageText,
            );
            messageWidgets.add(messagewidget);
          }
        }
        return Expanded(child: ListView(children: messageWidgets));
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  const MessageBubble({required this.sender, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: [
          Text(sender),
          Material(
            borderRadius: BorderRadius.circular(30.0),
            elevation: 5.0,
            color: Colors.lightBlue,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 20.0,
              ),
              child: Text(
                '$text ',
                style: TextStyle(fontSize: 15.0, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
