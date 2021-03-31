import 'package:flutter/material.dart';
//import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
class Login extends StatefulWidget {
  Login({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _Login createState() => _Login();
}
class _Login extends State<Login> {
  int _counter = 0;
  bool _obscureText = true;
  void _incrementCounter(){
    setState((){
      _counter++;
    });
  }
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
                padding: const EdgeInsets.symmetric(vertical: 150),
                child: Image(image: AssetImage('assets/images/logo.png')),
              ),
             // Expanded(child: Container(),),
              Container(
                margin: EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                        alignment:Alignment.bottomCenter,
                        child: Icon(Icons.person)),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: TextField(
                          decoration: InputDecoration(
                              labelText: "Email",
                            contentPadding: EdgeInsets.all(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: TextField(
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          labelText: "Password",
                          contentPadding: EdgeInsets.all(4),
                          suffix: InkWell(
                            onTap: (){
                              setState(() {
                                _obscureText = !_obscureText;
                                print(_obscureText);
                              });
                            },
                            child: Icon(Icons.remove_red_eye),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 32,bottom: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: FlatButton(
                          color: color,
                          splashColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          onPressed: () async {

                          },
                          child: Text(
                            "Let's go" ,
                            style: TextStyle(
                                color: background1, fontWeight: FontWeight.w600,fontSize: 16),
                          )),
                    ),
                  ],
                ),
              ),
              Text("Forgot password?",style: TextStyle(color: Colors.indigo),),
            ],
          ),
        ),
      )
    );
  }
}