import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
class Register extends StatefulWidget {
  Register({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _Register createState() => _Register();
}
class _Register extends State<Register>{
  bool _obscureTextpass = true;
  bool _obscureTextconfPass = true;
  final _formKey = GlobalKey<FormState>();
  TextEditingController password,confirmPassword,gmail;
  var _newpassword,_confirmpassword,_gmail;
  Color background,color,background1;
  @override
  Widget build(BuildContext context){
    color = Color(0xff6fd8a8);
    background = Colors.white;
    if (background == Colors.white) {
      background1 = Colors.black;
    } else {
      background1 = Colors.white;
    }
    return Scaffold(
        backgroundColor: Colors.white,
        body:SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 50),
                  child: Image(image: AssetImage('assets/images/logo.png')),
                ),
                // Expanded(child: Container(),),
                /*Container(
                  margin: EdgeInsets.all(8),
                  child: TextField(
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: background1)),
                      labelText: "Username",
                      contentPadding: EdgeInsets.all(8),
                      labelStyle: TextStyle(
                          color: background1, fontSize: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(8),
                  child: TextField(
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: background1)
                      ),
                      labelText: 'Name',
                      labelStyle: TextStyle(
                          color: background1, fontSize: 14),
                      contentPadding: EdgeInsets.all(8),
                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                */Container(
                  margin: EdgeInsets.all(8),
                  child: Form(
                    key : _formKey,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: TextField(
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: background1)),
                              labelText: "Username",
                              contentPadding: EdgeInsets.all(8),
                              labelStyle: TextStyle(
                                  color: background1, fontSize: 14),
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
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide:
                                  BorderSide(color: background1)
                              ),
                              labelText: 'Name',
                              labelStyle: TextStyle(
                                  color: background1, fontSize: 14),
                              contentPadding: EdgeInsets.all(8),
                              border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: TextFormField(
                            validator: (val){
                              print(val.runtimeType);
                              print(val.substring(val.length-10,val.length));
                              if(val.substring(val.length-10,val.length)!="@gmail.com"){
                                return "enter valid gmail";
                              }
                              return null;
                            },
                            controller: gmail,
                            onChanged: (value){
                              _gmail = value;
                            },
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: background1)
                              ),
                              labelText: "Gmail",
                              labelStyle:
                              TextStyle(color: background1, fontSize: 14),
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
                              flex : 1,
                              child: CountryCodePicker(
                                initialSelection: 'IN',
                                showDropDownButton: true,
                                showFlag: false,
                                showCountryOnly: true,
                                favorite: ['+91','IN'],
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: background1)
                                  ),
                                  labelText: "Phone Number",
                                  labelStyle:
                                  TextStyle(color: background1, fontSize: 14),
                                  contentPadding: EdgeInsets.all(8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onChanged: (value) {
                                  // this.phoneNo=value;
                                  print(value);
                                },
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: TextFormField(
                            validator: (v){
                              return v.length<8 ? "length must be greater than 8" : null;
                            },
                            controller: password,
                            onChanged: (value){
                              _newpassword = value;
                            },
                            obscureText: _obscureTextpass,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: background1)
                              ),
                              labelText: "new password",
                              labelStyle:
                              TextStyle(color: background1, fontSize: 14),
                              contentPadding: EdgeInsets.all(8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              suffix: InkWell(
                                onTap: (){
                                  setState(() {
                                    _obscureTextpass = !_obscureTextpass;
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
                            validator: (v){
                              if(_newpassword!=_confirmpassword){
                                return "Password's dosen't match";
                              }
                              return null;
                            },
                            controller: confirmPassword,
                            onChanged: (value){
                              _confirmpassword = value;
                            },
                            obscureText: _obscureTextconfPass,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: background1)
                              ),
                              labelText: "confirm new password",
                              labelStyle:
                              TextStyle(color: background1, fontSize: 14),
                              contentPadding: EdgeInsets.all(8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              suffix: InkWell(
                                onTap: (){
                                  setState(() {
                                    _obscureTextconfPass = !_obscureTextconfPass;
                                  });
                                },
                                child: Icon(Icons.remove_red_eye),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 32,bottom: 16),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: FlatButton(
                                color: color,
                                splashColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                onPressed: () async {
                                  if(_formKey.currentState.validate()){
                                    // insert data into database here
                                  }
                                },
                                child: Text(
                                  "Join Us" ,
                                  style: TextStyle(
                                      color: background1, fontWeight: FontWeight.w600,fontSize: 16),
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),],
            ),
          ),
        )
    );
  }
}