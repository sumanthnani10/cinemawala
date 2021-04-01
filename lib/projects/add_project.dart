import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils.dart';

class AddProject extends StatefulWidget {
  @override
  _AddProject createState() => _AddProject();
}

class _AddProject extends State<AddProject> {
  Color background, color, background1;
  List<String> languages = ['Telugu', 'Hindi', 'Tamil'];
  var selectedLanguages = [];
  bool loading = false;

  @override
  void initState() {
    loading = true;
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
      appBar: AppBar(
        backgroundColor: color,
        iconTheme: IconThemeData(color: background1),
        title: Text(
          "Add Project",
          style: TextStyle(color: background1),
        ),
        actions: [
          TextButton(
              onPressed: () {
                addProject();
              },
              child: Text(
                'Add',
                style: TextStyle(color: Colors.indigo),
              ))
        ],
      ),
      //
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
            spacing: 4,
            runSpacing: 2,
            children: <Widget>[
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: TextField(
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: background1)
                                //borderSide: const BorderSide(color: Colors.white)
                                ),
                            labelText: 'Project Name',
                            labelStyle:
                                TextStyle(color: background1, fontSize: 14),
                            contentPadding: EdgeInsets.all(8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Languages",
                              style: TextStyle(fontSize: 18),
                            )),
                      ),
                    ],
                  ),
                ] +
                List<Widget>.generate(languages.length, (i) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        if (selectedLanguages.contains(i)) {
                          selectedLanguages.remove(i);
                        } else {
                          selectedLanguages.add(i);
                        }
                      });
                    },
                    child: Container(
                      //color: color,
                      margin: EdgeInsets.all(2),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: selectedLanguages.contains(i)
                            ? color
                            : color.withOpacity(10 / 16),
                        borderRadius: BorderRadius.circular(300),
                      ),
                      child: Text('${languages[i]}'),
                    ),
                  );
                })),
      ),
    );
  }

  // TODO : addProject()
  addProject() async {
    Utils.showLoadingDialog(context, 'Loading');
    var resp = await http
        .post(Utils.ADD_PROJECT, body: {"user_id": "${Utils.USER_ID}"});
    // // debugPrint(resp.body);
    if (resp.statusCode == 200) {
      var r = jsonDecode(resp.body);
      if (r['status'] == 'success') {
      } else {}
    } else {}
    setState(() {
      loading = false;
    });
    Navigator.pop(context);
    Utils.showSuccessDialog(context, 'Successful', 'Project Added Successfully',
        background1, background, () {
      Navigator.of(context).pop(true);
    });
  }
}
