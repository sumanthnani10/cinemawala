import 'package:cinemawala/projects/projects_list.dart';
import 'package:cinemawala/user/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

class Login extends StatefulWidget {
  Login({Key key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool obscureText = true;

  Color background, color, background1;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController emailFieldController = new TextEditingController(),
      passwordFieldController = new TextEditingController();

  login() async {
    if (formKey.currentState.validate()) {
      Utils.showLoadingDialog(context, "Logging In");
      String email = emailFieldController.text;
      String password = passwordFieldController.text;
      try {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password)
            .then((value) async {
          await Utils.getUser(context, value.user.uid);
          Navigator.pop(context);
          Navigator.pushReplacement(
              context, Utils.createRoute(ProjectsList(), Utils.RTL));
        });
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);
        if (e.code == "user-not-found") {
          await Utils.showErrorDialog(context, "New User",
              "You are not registered yet. Please Register and Login again.");
        } else if (e.code == "wrong-password") {
          await Utils.showErrorDialog(context, "Wrong Password",
              "The password you have entered is wrong. Please check and try again.");
        } else if (e.code == "user-disabled") {
          await Utils.showErrorDialog(
              context, "Sorry", "Your account has been disabled.");
        } else if (e.code == "invalid-email") {
          await Utils.showErrorDialog(context, "Invalid Email",
              "The email you have entered is invalid. Please check and try again.");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    color = Color(0xff6fd8a8);
    background = Colors.white;
    if (background == Colors.white) {
      background1 = Colors.black;
    } else {
      background1 = Colors.white;
    }
    return Scaffold(
        backgroundColor: background,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 120),
                      child: Image(image: AssetImage('assets/images/logo.png')),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 4, vertical: 16),
                      child: Container(
                            constraints: BoxConstraints(maxWidth: 400),
                        child: TextFormField(
                          controller: emailFieldController,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            Pattern pattern =
                                r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                            RegExp regex = new RegExp(pattern);
                            if (v.length == 0) {
                              return 'Please enter email id';
                            } else {
                              if (!regex.hasMatch(v)) {
                                return 'Enter valid email';
                              } else {
                                return null;
                              }
                            }
                          },
                          decoration: InputDecoration(
                            labelText: "Email",
                            prefixIcon: Icon(Icons.person),
                            contentPadding: EdgeInsets.all(8),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Container(
                        constraints: BoxConstraints(maxWidth: 400),
                        child: TextFormField(
                          obscureText: obscureText,
                          controller: passwordFieldController,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.text,
                          validator: (v) {
                            if (v.length == 0) {
                              return 'Please enter password.';
                            } else if (v.length < 8) {
                              return 'Password must be minimum 8 characters';
                            } else {
                              return null;
                            }
                          },
                          decoration: InputDecoration(
                            labelText: "Password",
                            contentPadding: EdgeInsets.all(4),
                            prefixIcon: Icon(Icons.lock),
                            suffix: InkWell(
                              onTap: () {
                                setState(() {
                                  obscureText = !obscureText;
                                });
                              },
                              child: Container(child: Icon(Icons.remove_red_eye)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 16),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: color,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8))),
                          onPressed: () async {
                            login();
                          },
                          child: Text(
                            "Let's go",
                            style: TextStyle(
                                color: background1,
                                fontWeight: FontWeight.w600,
                                fontSize: 16),
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: color,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8))),
                          onPressed: () async {
                            Navigator.push(context,
                                Utils.createRoute(Register(), Utils.LTR));
                          },
                          child: Text(
                            "Register",
                            style: TextStyle(
                                color: background1,
                                fontWeight: FontWeight.w600,
                                fontSize: 16),
                          )),
                    ),
                    Text(
                      "Forgot password?",
                      style: TextStyle(color: Colors.indigo),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
