import 'dart:ui';

import 'package:flash_chat/constants.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flash_chat/widget/rounded_button.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class RegistrationScreen extends StatefulWidget {
  static const id = 'registration_screen';

  @override
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  String? email;
  String? password;
  bool showSpinner = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('image/logo.png'),
                  ),
                ),
              ),
              SizedBox(height: 48.0),
              TextField(
                onChanged: (value) {
                  email = value;
                },
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black),
                keyboardType: TextInputType.emailAddress,
                decoration: kinputDecoration.copyWith(
                  hintText: 'enter your email',
                ),
              ),
              SizedBox(height: 8.0),
              TextField(
                onChanged: (value) {
                  password = value;
                },
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black),
                obscureText: true,

                decoration: kinputDecoration.copyWith(
                  hintText: 'enter your password',
                ),
              ),
              SizedBox(height: 24.0),
              RoundedButton(
                onpressed: () async {
                  print(email);
                  print(password);
                  setState(() {
                    showSpinner = true;
                  });

                  if (email != null && password != null) {
                    try {
                      final newUser = await _auth
                          .createUserWithEmailAndPassword(
                            email: email!,
                            password: password!,
                          );
                      if (newUser != null) {
                        Navigator.pushNamed(context, ChatScreen.id);
                      }
                      setState(() {
                        showSpinner = false;
                      });
                    } catch (e) {
                      print(e);
                    }
                  }
                },
                color: Colors.blueAccent,
                text: 'Register',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
