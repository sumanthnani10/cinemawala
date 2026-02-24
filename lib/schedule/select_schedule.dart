import 'dart:convert';

import 'package:cinemawala/projects/project.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils.dart';

class SelectScheduleNames extends StatefulWidget {
  final Project project;
  final String selectedScheduleName;
  final bool viewOnly;

  SelectScheduleNames(
      {Key key,
      @required this.project,
      this.selectedScheduleName,
      this.viewOnly})
      : super(key: key);

  @override
  _SelectScheduleNames createState() => _SelectScheduleNames(this.project,
      this.selectedScheduleName ?? "None", this.viewOnly ?? false);
}

class _SelectScheduleNames extends State<SelectScheduleNames>
    with SingleTickerProviderStateMixin {
  Project project;
  Color background, background1, color;
  List<dynamic> allScheduleNames = [];
  String selectedScheduleName;
  final bool viewOnly;

  TextEditingController searchController = new TextEditingController();
  String search = '';

  _SelectScheduleNames(this.project, this.selectedScheduleName, this.viewOnly);

  @override
  void initState() {
    allScheduleNames = project.schedules.sublist(0).toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var showScheduleNames = allScheduleNames
        .where((e) => e.toLowerCase().contains(search.toLowerCase()))
        .toList();
    background = Colors.white;
    color = Color(0xff6fd8a8);
    if (background == Colors.white) {
      background1 = Colors.black;
    } else {
      background1 = Colors.white;
    }
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop(selectedScheduleName);
      },
      child: Scaffold(
        backgroundColor: Colors.black26,
        body: Center(
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 48, horizontal: 24),
              constraints: BoxConstraints(maxWidth: 480),
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              height: MediaQuery.of(context).size.height - (48 * 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                          icon: Icon(Icons.arrow_back_rounded),
                          onPressed: () {
                            Navigator.pop(context, selectedScheduleName);
                          }),
                      Text(
                        "Schedules",
                        style: TextStyle(fontSize: 20, color: background1),
                        textAlign: TextAlign.center,
                      ),
                      Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(context, selectedScheduleName);
                        },
                        label: Text(
                          "Done",
                          style: TextStyle(color: Colors.indigo),
                          textAlign: TextAlign.right,
                        ),
                        icon: Icon(
                          Icons.done,
                          size: 18,
                          color: Colors.indigo,
                        ),
                      ),
                    ],
                  ),
                  TextField(
                    controller: searchController,
                    maxLines: 1,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (v) {
                      setState(() {
                        search = v;
                      });
                    },
                    decoration: InputDecoration(
                        suffixIcon: InkWell(
                          onTap: () {
                            setState(() {
                              searchController.text = '';
                              search = '';
                            });
                          },
                          child: Icon(
                            Icons.clear,
                            color: search == '' ? Colors.white : Colors.black,
                            size: 16,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.black)),
                        labelStyle: TextStyle(color: Colors.black),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 8),
                        labelText: 'Search Schedule',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.black)),
                        fillColor: Colors.white),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                                InkWell(
                                  onTap: () async {
                                    await askScheduleName("");
                                    setState(() {
                                      project = Utils.project;
                                      allScheduleNames =
                                          project.schedules.toList();
                                    });
                                  },
                                  splashColor: background1.withOpacity(0.2),
                                  child: Container(
                                    //color: color,
                                    margin: EdgeInsets.all(2),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(300),
                                    ),
                                    child: Text('+ Create Schedule'),
                                  ),
                                )
                              ] +
                              List<Widget>.generate(showScheduleNames.length,
                                  (i) {
                                String scheduleName = showScheduleNames[i];
                                return InkWell(
                                  onTap: () {
                                    if (!viewOnly) {
                                      setState(() {
                                        selectedScheduleName = scheduleName;
                                      });
                                      Navigator.pop(
                                          context, selectedScheduleName);
                                    }
                                  },
                                  splashColor: background1.withOpacity(0.2),
                                  child: Container(
                                    //color: color,
                                    margin: EdgeInsets.all(2),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color:
                                          selectedScheduleName == scheduleName
                                              ? color
                                              : color.withOpacity(8 / 16),
                                      borderRadius: BorderRadius.circular(300),
                                    ),
                                    child: Text('$scheduleName'),
                                  ),
                                );
                              }),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  askScheduleName(String name) async {
    TextEditingController nameController =
        new TextEditingController(text: name);
    GlobalKey<FormState> formKey = new GlobalKey<FormState>();
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Schedule"),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: nameController,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(labelText: "Schedule"),
              validator: (v) {
                if (v.length == 0) {
                  return 'Please enter schedule title';
                } else {
                  return null;
                }
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop([false, name]);
              },
            ),
            TextButton(
              child: Text("Add"),
              onPressed: () async {
                if (formKey.currentState.validate()) {
                  return await addScheduleName(nameController.text);
                }
              },
            ),
          ],
        );
      },
    );
  }

  addScheduleName(String name) async {
    Utils.showLoadingDialog(context, 'Adding');

    try {
      var resp = await http.post(Utils.ADD_SCHEDULE_NAME,
          body: jsonEncode({
            "project_id": project.id,
            "added_by": Utils.user.id,
            "schedule": name
          }),
          headers: {"Content-Type": "application/json"});
      var r = jsonDecode(resp.body);
      Navigator.pop(context);
      if (resp.statusCode == 200) {
        if (r['status'] == 'success') {
          if (!Utils.project.schedules.contains(name)) {
            Utils.project.schedules.add(name);
          }
        } else {
          await Utils.showErrorDialog(context, 'Unsuccessful', '${r['msg']}');
        }
      } else {
        await Utils.showErrorDialog(context, 'Something went wrong.',
            'Please try again after sometime.');
      }
    } catch (e) {
      // debugPrint(e);
      Navigator.pop(context);
      await Utils.showErrorDialog(
          context, 'Something went wrong.', 'Please try again after sometime.');
    }
    Navigator.pop(context);
  }
}
