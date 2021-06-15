import 'dart:convert';

import 'package:async/async.dart';
import 'package:cinemawala/projects/projects_list.dart';
import 'package:cinemawala/utils.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class Register extends StatefulWidget {
  Register({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _Register createState() => _Register();
}

class _Register extends State<Register> {
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  final _formKey = GlobalKey<FormState>();
  TextEditingController passwordController,
      confirmPasswordController,
      eMailController,
      nameController,
      phoneController,
      userNameController;
  String newPassword = "",
      confirmPassword = "",
      eMail = "",
      name = "",
      username = "",
      phone = "",
      countryCode = "+91";
  int usernameValid = 0, gender = 1;
  Color background, color, background1;
  CancelableOperation cancellableOperation;

  @override
  void initState() {
    passwordController = new TextEditingController();
    confirmPasswordController = new TextEditingController();
    eMailController = new TextEditingController();
    nameController = new TextEditingController();
    phoneController = new TextEditingController();
    userNameController = new TextEditingController();
    super.initState();
  }

  validateUsername() async {
    cancellableOperation?.cancel();
    cancellableOperation = CancelableOperation.fromFuture(
        validateUsernameMethod(),
        onCancel: () {});
    return cancellableOperation.value;
  }

  Future<dynamic> validateUsernameMethod() async {
    setState(() {
      usernameValid = 2;
    });

    if (username.length < 6) {
      usernameValid = -1;
      return false;
    }

    try {
      var resp = await http.post(Utils.VALIDATE_USERNAME,
          body: jsonEncode({"username": username}),
          headers: {"Content-Type": "application/json"});
      // debugPrint(resp.body);
      var r = jsonDecode(resp.body);
      if (resp.statusCode == 200) {
        setState(() {
          usernameValid = (r['valid'] ?? false) ? 1 : -1;
        });
      }
    } catch (e) {
      setState(() {
        usernameValid = -1;
      });
    }
    return usernameValid == 1;
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
        backgroundColor: Colors.white,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 30, 16, 0),
                        child: Image(image: AssetImage('assets/images/logo.png')),
                      ),
                    ],
                  ),
                  Container(
                    constraints: BoxConstraints(maxWidth: 480),
                    child: Column(
                      children: [
                        Padding(
                          padding:
                          const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                          child: Text(
                            "Register",
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline),
                          ),
                        ),
                        //Username
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 0),
                          child: TextFormField(
                            textInputAction: TextInputAction.next,
                            controller: userNameController,
                            textCapitalization: TextCapitalization.none,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^[a-z0-9_]+'),
                                  replacementString: ""),
                            ],
                            onChanged: (v) {
                              username = v;
                              validateUsername();
                            },
                            onFieldSubmitted: (v) {
                              validateUsername();
                            },
                            validator: (v) {
                              if (v.length < 6) {
                                return "Username must be at least 6 characters.";
                              } else if (usernameValid != 1) {
                                return "Choose different username.";
                              } else {
                                return null;
                              }
                            },
                            decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: background1)),
                                labelText: "Username",
                                contentPadding: EdgeInsets.all(8),
                                labelStyle:
                                TextStyle(color: background1, fontSize: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                helperStyle: usernameValid == 2
                                    ? TextStyle(fontSize: 12, color: background1)
                                    : usernameValid == 1
                                    ? TextStyle(fontSize: 12, color: Colors.green)
                                    : usernameValid == -1
                                    ? TextStyle(
                                    fontSize: 12, color: Colors.red)
                                    : TextStyle(
                                    fontSize: 12, color: background1),
                                helperText: usernameValid == 2
                                    ? "Checking.."
                                    : usernameValid == 1
                                    ? "$username is valid"
                                    : usernameValid == -1
                                    ? "$username is already used."
                                    : "",
                                suffixIcon: usernameValid == 2
                                    ? Icon(
                                  Icons.refresh_rounded,
                                  color: background1,
                                )
                                    : usernameValid == 1
                                    ? InkWell(
                                  onTap: () {
                                    validateUsername();
                                  },
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  ),
                                )
                                    : usernameValid == -1
                                    ? InkWell(
                                  onTap: () {
                                    validateUsername();
                                  },
                                  child: Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                  ),
                                )
                                    : InkWell(
                                  onTap: () {
                                    validateUsername();
                                  },
                                  child: Icon(
                                    Icons.repeat,
                                    color: Colors.blue,
                                  ),
                                )),
                          ),
                        ),
                        //Name
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: TextFormField(
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            controller: nameController,
                            onChanged: (v) {
                              name = v;
                            },
                            validator: (v) {
                              if (v.isEmpty) {
                                return "Enter your name";
                              } else {
                                return null;
                              }
                            },
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^[a-zA-Z ]+$'),
                                  replacementString: "${name}"),
                            ],
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: background1)),
                              labelText: 'Name',
                              labelStyle: TextStyle(color: background1, fontSize: 14),
                              contentPadding: EdgeInsets.all(8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        //Email
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: TextFormField(
                            textInputAction: TextInputAction.next,
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
                            controller: eMailController,
                            onChanged: (value) {
                              eMail = value;
                            },
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: background1)),
                              labelText: "Email",
                              labelStyle: TextStyle(color: background1, fontSize: 14),
                              contentPadding: EdgeInsets.all(8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        //Mobile
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 3,
                                child: CountryCodePicker(
                                  initialSelection: 'IN',
                                  showDropDownButton: true,
                                  showFlag: true,
                                  showCountryOnly: true,
                                  favorite: ['+91', 'IN'],
                                  onChanged: (c) {
                                    countryCode = c.dialCode;
                                  },
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: TextFormField(
                                  textCapitalization: TextCapitalization.none,
                                  textInputAction: TextInputAction.next,
                                  controller: phoneController,
                                  onChanged: (v) {
                                    phone = v;
                                  },
                                  validator: (v) {
                                    if (v.isEmpty) {
                                      return "Enter your phone number";
                                    } else {
                                      if (v.length != 10) {
                                        return "Phone Number must be 10 digits";
                                      } else {
                                        return null;
                                      }
                                    }
                                  },
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^[0-9]+$'),
                                        replacementString: "${phone}"),
                                  ],
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: background1)),
                                    labelText: "Phone Number",
                                    labelStyle:
                                    TextStyle(color: background1, fontSize: 14),
                                    contentPadding: EdgeInsets.all(8),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        //Gender
                        Padding(
                          padding:  EdgeInsets.symmetric(vertical: 4),
                          child: Container(
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 6),
                                    child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16)),
                                          primary: gender == 1 ? Colors.white : color,
                                          elevation: gender == 1 ? 4 : 0,
                                        ),
                                        icon: Icon(Icons.person,size: 22,color: background1,),
                                        onPressed: () {
                                          setState(() {
                                            gender = 1;
                                          });
                                        },
                                        label: Text(
                                          "Male",
                                          style: TextStyle(
                                              fontWeight: gender == 1
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                              color: background1),
                                        )),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 6),
                                    child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16)),
                                          primary: gender == 2 ? Colors.white : color,
                                          elevation: gender == 2 ? 4 : 0,
                                        ),
                                        icon: Icon(Icons.person,size: 22,color: background1,),
                                        onPressed: () {
                                          setState(() {
                                            gender = 2;
                                          });
                                        },
                                        label: Text(
                                          "Female",
                                          style: TextStyle(
                                              fontWeight: gender == 2
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                              color: background1),
                                        )),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        //Password
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: TextFormField(
                            obscureText: obscurePassword,
                            controller: passwordController,
                            textInputAction: TextInputAction.next,
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
                            onChanged: (v) {
                              newPassword = v;
                            },
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: background1)),
                              labelText: "New Password",
                              labelStyle: TextStyle(color: background1, fontSize: 14),
                              contentPadding: EdgeInsets.all(8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              suffixIcon: InkWell(
                                onTap: () {
                                  setState(() {
                                    obscurePassword = !obscurePassword;
                                  });
                                },
                                child: Icon(
                                  Icons.remove_red_eye,
                                  color: background1,
                                ),
                              ),
                            ),
                          ),
                        ),
                        //Confirm Password
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: TextFormField(
                            obscureText: obscureConfirmPassword,
                            controller: confirmPasswordController,
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.text,
                            validator: (v) {
                              if (v.length == 0) {
                                return 'Please enter password.';
                              } else if (v.length < 8) {
                                return 'Password must be minimum 8 characters';
                              } else if (v != newPassword) {
                                return 'Passwords doesn\'t match';
                              } else {
                                return null;
                              }
                            },
                            onChanged: (v) {
                              confirmPassword = v;
                            },
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: background1)),
                              labelText: "Confirm New Password",
                              labelStyle: TextStyle(color: background1, fontSize: 14),
                              contentPadding: EdgeInsets.all(8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              suffixIcon: InkWell(
                                onTap: () {
                                  setState(() {
                                    obscureConfirmPassword = !obscureConfirmPassword;
                                  });
                                },
                                child: Icon(
                                  Icons.remove_red_eye,
                                  color: background1,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 16),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: color,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () async {
                                  Utils.showLoadingDialog(context, "Signing Up");
                                  if (await validateUsername()) {
                                    if (_formKey.currentState.validate()) {
                                      await addUser();
                                    } else {
                                      Navigator.pop(context);
                                    }
                                  } else {
                                    Navigator.pop(context);
                                    Utils.showErrorDialog(context, "Username",
                                        "Username you have chosen is aleady used. Please choose a different username.");
                                  }
                                },
                                child: Text(
                                  "Join Us",
                                  style: TextStyle(
                                      color: background1,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16),
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
          ),
        ));
  }

  addUser() async {
    var user = {
      "email": "$eMail",
      "mobile": "$countryCode$phone",
      "username": "$username",
      "password": "$newPassword",
      "name": "$name",
      "id": "${Utils.generateId("user_")}",
      "projects": {},
      "notes": {},
      "acts_in": {},
      "codes": {},
      "gender": 1
    };

    try {
      var resp = await http.post(Utils.ADD_USER,
          body: jsonEncode(user),
          headers: {"Content-Type": "application/json"});
      var r = jsonDecode(resp.body);
      if (resp.statusCode == 200) {
        if (r['status'] == 'success') {
          await FirebaseAuth.instance
              .signInWithEmailAndPassword(email: eMail, password: newPassword)
              .then((value) async {
            await Utils.getUser(context, value.user.uid);
            Navigator.pushAndRemoveUntil(context,
                Utils.createRoute(ProjectsList(), Utils.RTL), (r) => false);
          });
        } else {
          Navigator.pop(context);
          await Utils.showErrorDialog(context, 'Unsuccessful', '${r['msg']}');
        }
      } else {
        Navigator.pop(context);
        await Utils.showErrorDialog(context, 'Something went wrong.',
            'Please try again after sometime.');
      }
    } catch (e) {
      // debugPrint(e);
      Navigator.pop(context);
      await Utils.showErrorDialog(
          context, 'Something went wrong.', 'Please try again after sometime.');
    }
  }
}
