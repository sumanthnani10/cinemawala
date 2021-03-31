import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      userNameController;
  String newPassword = "",
      confirmPassword = "",
      eMail = "",
      name = "",
      username = "",
      phone = "";
  Color background, color, background1;

  @override
  void initState() {
    passwordController = new TextEditingController();
    confirmPasswordController = new TextEditingController();
    eMailController = new TextEditingController();
    nameController = new TextEditingController();
    userNameController = new TextEditingController();
    super.initState();
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
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 50),
                  child: Image(image: AssetImage('assets/images/logo.png')),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: TextFormField(
                    textInputAction: TextInputAction.next,
                    controller: userNameController,
                    textCapitalization: TextCapitalization.none,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^[a-z_.]+'),
                          replacementString: "${username}"),
                    ],
                    onChanged: (v) {
                      username = v;
                    },
                    validator: (v) {},
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: background1)),
                      labelText: "Username",
                      contentPadding: EdgeInsets.all(8),
                      labelStyle: TextStyle(color: background1, fontSize: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
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
                      FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z]+$'),
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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
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
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: CountryCodePicker(
                        initialSelection: 'IN',
                        showDropDownButton: true,
                        showFlag: true,
                        showCountryOnly: true,
                        favorite: ['+91', 'IN'],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        textCapitalization: TextCapitalization.none,
                        textInputAction: TextInputAction.next,
                        controller: nameController,
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
                          FilteringTextInputFormatter.allow(RegExp(r'^[0-9]+$'),
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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
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
                      suffix: InkWell(
                        onTap: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                        child: Icon(Icons.remove_red_eye),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
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
                      suffix: InkWell(
                        onTap: () {
                          setState(() {
                            obscureConfirmPassword = !obscureConfirmPassword;
                          });
                        },
                        child: Icon(Icons.remove_red_eye),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 32, bottom: 16),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: color,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            // insert data into database here
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
        ));
  }
}
