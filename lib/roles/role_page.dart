import 'package:cinemawala/projects/project.dart';
import 'package:flutter/material.dart';

import '../utils.dart';
import 'add_role.dart';
import 'role.dart';

class RolePage extends StatefulWidget {
  final Project project;
  final Role role;

  RolePage({Key key, @required this.project, this.role}) : super(key: key);

  @override
  _RolePage createState() => _RolePage(this.project, this.role);
}

class _RolePage extends State<RolePage> with SingleTickerProviderStateMixin {
  Project project;
  Color background, background1, color;
  Role role;
  Map<dynamic, dynamic> permissions;
  List<String> permissionsKeys;
  String catName = "";
  TextEditingController roleTitleController, nameController;

  _RolePage(this.project, this.role);

  @override
  void initState() {
    permissions = role.permissions;
    permissionsKeys = permissions.keys.toList();
    roleTitleController = new TextEditingController(text: role.role);
    nameController = new TextEditingController(text: role.name);
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
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: Utils.linearGradient,
          ),
        ),
        backgroundColor: color,
        iconTheme: IconThemeData(color: background1),
        title: Text(
          "Role",
          style: TextStyle(color: background1),
        ),
        actions: [
          TextButton.icon(
            onPressed: () async {
              var back = await Navigator.push(
                  context,
                  Utils.createRoute(
                      AddRole(
                        project: project,
                        role: role.toJson(),
                      ),
                      Utils.RTL));
              if (back != null) {
                if (back[0]) {
                  Navigator.pop(context, back);
                }
              }
            },
            label: Text(
              "Edit",
              style: TextStyle(color: Colors.indigo),
              textAlign: TextAlign.right,
            ),
            icon: Icon(
              Icons.edit,
              size: 18,
              color: Colors.indigo,
            ),
          )
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
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
                        disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: background)),
                        enabled: false,
                        labelText: 'Role Title',
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
                        disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: background)),
                        enabled: false,
                        labelText: 'Name',
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
                    var keysVal = ["view", "add", "edit"];
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
                                    Checkbox(
                                      value: permissions[permissionsKeys[i]]
                                                  [keysVal[0]] ==
                                              true
                                          ? permissions[permissionsKeys[i]]
                                              [keysVal[j]]
                                          : false,
                                      activeColor: color,
                                      onChanged: (bool value) {},
                                    ),
                                    Text("${permission}"),
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
      ),
    );
  }
}
