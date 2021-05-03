import 'package:cinemawala/projects/project.dart';
import 'package:cinemawala/roles/role.dart';
import 'package:flutter/material.dart';

import '../utils.dart';
import 'add_role.dart';
import 'role_page.dart';

class RolesList extends StatefulWidget {
  Project project;

  RolesList({Key key, @required this.project}) : super(key: key);

  @override
  _RolesList createState() => _RolesList(this.project);
}

class _RolesList extends State<RolesList> {
  Project project;
  Color background, color, background1;
  List<Role> roles = [];
  bool loading = false;

  _RolesList(this.project);

  @override
  void initState() {
    loading = true;
    project.roles.forEach((key, value) {
      roles.add(Role.fromJson(value));
    });
    super.initState();
  }

  getProject(project) async {
    loading = true;
    Utils.showLoadingDialog(context, 'Getting Project');
    project = Utils.getProject(context, project.id);
    Navigator.pop(context);
    setState(() {
      loading = false;
    });
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
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: Utils.linearGradient,
          ),
        ),
        backgroundColor: color,
        iconTheme: IconThemeData(color: background1),
        title: Text(
          "Roles",
          style: TextStyle(color: background1),
        ),
      ),
      body: roles.length > 0
          ? Column(
              children: List<Widget>.generate(roles.length, (i) {
                Role role = roles[i];
                if (role.owner) return Container();
              return InkWell(
                onTap: () async {
                  var back = await Navigator.push(
                      context,
                      Utils.createRoute(
                          RolePage(
                            role: role,
                            project: project,
                          ),
                          Utils.DTU));
                  if (back != null) {
                    if (back[0]) {
                      Navigator.pop(context, back[1]);
                    }
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(width: 1),
                    ),
                  ),
                  child: ListTile(
                    title: Text("${role.name}"),
                    subtitle: Text("${role.role}"),
                  ),
                ),
              );
            }))
          : Center(
              child: Text(loading ? '' : 'No Roles.'),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: color,
        onPressed: () async {
          var back = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddRole(
                        project: project,
                        role: null,
                      )));
          if (back != null) {
            if (back[0]) {
              Navigator.pop(context, back[1]);
            }
          }
        },
        child: Icon(
          Icons.add,
          color: background1,
          size: 32,
        ),
      ),
    );
  }
}
