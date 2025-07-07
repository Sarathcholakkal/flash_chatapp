import 'package:firebase_core/firebase_core.dart';
import 'package:flash_chat/constants.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class LoginScreen extends StatefulWidget {
  static const id = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _auth = FirebaseAuth.instance;
  String? email;
  String? password;
  bool showspinner = false;

  late AnimationController _controller;
  late Animation _animation;

  @override
  void initState() {
    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    // _animation.addStatusListener((status) {
    //   if (status == AnimationStatus.completed) {
    //     _controller.reverse(from: 1.0);
    //   } else if (status == AnimationStatus.dismissed) {
    //     _controller.forward();
    //   }
    // });
    _controller.addListener(() {
      setState(() {
        _animation.value;
      });
    });
    _controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showspinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Hero(
                tag: 'logo',
                child: Container(
                  height: _animation.value * 100,
                  child: Image.asset('image/logo.png'),
                ),
              ),
              SizedBox(height: 48.0),
              TextField(
                onChanged: (value) {
                  email = value;
                },
                style: const TextStyle(color: Colors.black),
                textAlign: TextAlign.center,
                keyboardType: TextInputType.emailAddress,
                decoration: kinputDecoration.copyWith(
                  hintText: 'Enter your email',
                ),
              ),
              SizedBox(height: 8.0),
              TextField(
                onChanged: (value) {
                  password = value;
                },
                style: const TextStyle(color: Colors.black),

                textAlign: TextAlign.center,
                obscureText: true,
                decoration: kinputDecoration.copyWith(
                  hintText: 'Enter your password',
                  focusColor: Colors.black,
                ),
              ),
              SizedBox(height: 24.0),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Material(
                  color: Colors.lightBlueAccent,
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  elevation: 5.0,
                  child: MaterialButton(
                    onPressed: () async {
                      //Implement login functionality.
                      setState(() {
                        showspinner = true;
                      });

                      if (email != null && password != null) {
                        try {
                          final user = await _auth.signInWithEmailAndPassword(
                            email: email!,
                            password: password!,
                          );
                          if (user != null) {
                            Navigator.of(context).pushNamed(ChatScreen.id);
                          }
                          setState(() {
                            showspinner = false;
                          });
                        } catch (e) {
                          print(e);
                        }
                      }
                    },
                    minWidth: 200.0,
                    height: 42.0,
                    child: Text('Log In'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
