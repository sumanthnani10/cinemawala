import "dart:convert";

import "package:cinemawala/projects/project.dart";
import "package:flutter/material.dart";
import "package:http/http.dart" as http;

import "../utils.dart";

class AddRole extends StatefulWidget {
  final Project project;
  final Map<dynamic, dynamic> role;

  AddRole({Key key, @required this.project, this.role}) : super(key: key);

  @override
  _AddRole createState() => _AddRole(this.project, this.role);
}

class _AddRole extends State<AddRole> with SingleTickerProviderStateMixin {
  Project project;
  Color background, background1, color;
  Map<dynamic, dynamic> role;
  List<String> permissionsKeys;
  String catName = "";
  bool loading = true, edit = false;
  TextEditingController roleTitleController, nameController;

  _AddRole(this.project, this.role);

  @override
  void initState() {
    if (role != null) {
      edit = true;
      permissionsKeys = role["permissions"].keys.toList();
      roleTitleController = new TextEditingController(text: role["role"]);
      nameController = new TextEditingController(text: role["name"]);
    } else {
      var now = DateTime.now();
      role = {
        "last_edit_on": now.millisecondsSinceEpoch,
        "created": now.millisecondsSinceEpoch,
        "last_edit_by": "${Utils.USER_ID}",
        "added_by": "${Utils.USER_ID}",
        "name": "",
        "role": "",
        "user_id": "qwerty",
        "project_id": project.id,
        "permissions": {
          "casting": {
            "view": false,
            "add": false,
            "edit": false,
          },
          "costumes": {
            "view": false,
            "add": false,
            "edit": false,
          },
          "art_department": {
            "view": false,
            "add": false,
            "edit": false,
          },
          "one_line_order": {
            "view": false,
            "add": false,
            "edit": false,
          },
          "schedule": {
            "view": false,
            "add": false,
            "edit": false,
          },
          "location": {
            "view": false,
            "add": false,
            "edit": false,
          },
          "daily_report": {
            "view": false,
            "add": false,
            "edit": false,
          },
          "daily_budget": {
            "view": false,
            "add": false,
            "edit": false,
          },
        }
      };
      permissionsKeys = role["permissions"].keys.toList();
      roleTitleController = new TextEditingController(text: "");
      nameController = new TextEditingController(text: "");
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    background = Colors.white;
    color = Color(0xff6fd8a8);
    if (background == Colors.white) {
      background1 = Colors.black;
    } else {
      background1 = Colors.white;
    }
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: color,
        iconTheme: IconThemeData(color: background1),
        title: Text(
          edit ? "Edit Role" : "Add Role",
          style: TextStyle(color: background1),
        ),
        actions: [
          FlatButton.icon(
            onPressed: () async {
              if (edit) {
                editRole();
              } else {
                addRole();
              }
            },
            color: color,
            splashColor: background1.withOpacity(0.2),
            label: Text(
              edit ? "Edit" : "Add",
              style: TextStyle(color: Colors.indigo),
              textAlign: TextAlign.right,
            ),
            icon: Icon(
              edit ? Icons.edit : Icons.add,
              size: 18,
              color: Colors.indigo,
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: TextField(
                    controller: roleTitleController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: background1)),
                      labelText: "Role Title",
                      labelStyle: TextStyle(color: background1, fontSize: 14),
                      contentPadding: EdgeInsets.all(8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: background1)),
                      labelText: "Name",
                      labelStyle: TextStyle(color: background1, fontSize: 14),
                      contentPadding: EdgeInsets.all(8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                Column(
                    children: List.generate(permissionsKeys.length, (i) {
                  var keysVal =
                      role["permissions"][permissionsKeys[i]].keys.toList();
                  catName = permissionsKeys[i].replaceAll("_", " ");
                  int flag = 0;
                  String category = "";
                  for (int i = 0; i < catName.length; i++) {
                    if (flag == 0) {
                      category = category + catName[i].toUpperCase();
                      flag = 1;
                    } else if (catName[i] == " ") {
                      category = category + catName[i];
                      flag = 0;
                    } else {
                      category = category + catName[i];
                    }
                  }
                  return Column(
                    children: [
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "${category}",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          )),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(keysVal.length, (j) {
                            String permission = "";
                            String val = keysVal[j];
                            permission = permission +
                                val[0].toUpperCase() +
                                val.substring(1);
                            return Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Checkbox(
                                        value: role["permissions"]
                                                        [permissionsKeys[i]]
                                                    [keysVal[0]] ==
                                                true
                                            ? role["permissions"]
                                                [permissionsKeys[i]][keysVal[j]]
                                            : false,
                                        activeColor: color,
                                        onChanged: (value) {
                                          setState(() {
                                            if (role["permissions"]
                                                            [permissionsKeys[i]]
                                                        [keysVal[0]] ==
                                                    true &&
                                                j != 0) {
                                              role["permissions"]
                                                      [permissionsKeys[i]]
                                                  [keysVal[j]] = value;
                                            } else if (j == 0) {
                                              role["permissions"]
                                                      [permissionsKeys[i]]
                                                  [keysVal[j]] = value;
                                            }
                                          });
                                        }),
                                  ),
                                  Expanded(child: Text("${permission}")),
                                  //Text(keysVal[j]),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  );
                })),
              ],
            )),
      ),
    );
  }

  addRole() async {
    Utils.showLoadingDialog(context, "Adding Role");

    var back = false;

    try {
      var resp = await http.post(Utils.ADD_ROLE,
          body: jsonEncode(role),
          headers: {"Content-Type": "application/json"});
      // // debugPrint(resp.body);
      var r = jsonDecode(resp.body);
      Navigator.pop(context);
      if (resp.statusCode == 200) {
        if (r["status"] == "success") {
          back = true;
          await Utils.showSuccessDialog(
              context,
              "Role Added",
              "Role has been added successfully.",
              Colors.green,
              background, () {
            Navigator.pop(context);
          });
        } else {
          await Utils.showErrorDialog(context, "Unsuccessful", "${r["msg"]}");
        }
      } else {
        await Utils.showErrorDialog(context, "Something went wrong.",
            "Please try again after sometime.");
      }
      setState(() {
        loading = false;
      });
    } catch (e) {
      // debugPrint(e);
      Navigator.pop(context);
      await Utils.showErrorDialog(
          context, "Something went wrong.", "Please try again after sometime.");
    }
    Navigator.pop(context, back);
  }

  editRole() async {
    Utils.showLoadingDialog(context, "Editing Role");

    var back = false;

    try {
      var resp = await http.post(Utils.EDIT_ROLE,
          body: jsonEncode(role),
          headers: {"Content-Type": "application/json"});
      // // debugPrint(resp.body);
      var r = jsonDecode(resp.body);
      Navigator.pop(context);
      if (resp.statusCode == 200) {
        if (r["status"] == "success") {
          back = true;
          await Utils.showSuccessDialog(
              context,
              "Role Edited",
              "Role has been edited successfully.",
              Colors.green,
              background, () {
            Navigator.pop(context);
          });
        } else {
          await Utils.showErrorDialog(context, "Unsuccessful", "${r["msg"]}");
        }
      } else {
        await Utils.showErrorDialog(context, "Something went wrong.",
            "Please try again after sometime.");
      }
      setState(() {
        loading = false;
      });
    } catch (e) {
      // debugPrint(e);
      Navigator.pop(context);
      await Utils.showErrorDialog(
          context, "Something went wrong.", "Please try again after sometime.");
    }
    Navigator.pop(context, back);
  }
}
