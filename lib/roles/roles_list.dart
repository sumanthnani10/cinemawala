import 'dart:convert';

import 'package:cinemawala/projects/project.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils.dart';

class RolesList extends StatefulWidget {
  final Project project;

  const RolesList({Key key, @required this.project}) : super(key: key);

  @override
  _RolesList createState() => _RolesList(this.project);
}

class _RolesList extends State<RolesList> {
  final Project project;
  Color background, color, background1;
  List<dynamic> roles = [];
  bool loading = false;

  _RolesList(this.project);

  @override
  void initState() {
    loading = true;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getRoles();
    });
    super.initState();
  }

  getRoles() async {
    loading = true;
    Utils.showLoadingDialog(context, 'Getting Roles');
    var resp = await http
        .post(Utils.GET_PROJECTS, body: {"user_id": "${Utils.USER_ID}"});
    // // debugPrint(resp.body);
    if (resp.statusCode == 200) {
      var r = jsonDecode(resp.body);
      if (r['status'] == 'success') {
        r['roles'].forEach((i) {
          roles.add(Project(
              id: i['id'],
              languages: i['languages'],
              name: i['name'],
              ownerID: i['owner_id'],
              roles: i['roles'],
              rolesIDs: i['roles_ids'],
              role: i['roles']['${Utils.USER_ID}']));
        });
      } else {
        roles = [];
      }
    } else {
      roles = [];
    }
    setState(() {
      loading = false;
    });
    Navigator.pop(context);
  }

  getProject(project) async {
    loading = true;
    Utils.showLoadingDialog(context, 'Getting Project');
    await Utils.getArtists(context, project.id);
    await Utils.getCostumes(context, project.id);
    await Utils.getProps(context, project.id);
    await Utils.getLocations(context, project.id);
    await Utils.getScenes(context, project.id);
    await Utils.getSchedules(context, project.id);
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
        backgroundColor: color,
        iconTheme: IconThemeData(color: background1),
        title: Text(
          "Your Roles",
          style: TextStyle(color: background1),
        ),
      ),
      body: roles.length > 0
          ? Column(
              children: List<Widget>.generate(roles.length, (i) {
              var project = roles[i];
              return InkWell(
                onTap: () async {
                  Utils.artists = null;
                  Utils.artistsMap = null;
                  Utils.costumes = null;
                  Utils.props = null;
                  Utils.costumes = null;
                  Utils.propsMap = null;
                  Utils.locations = null;
                  Utils.scenes = null;
                  Utils.locations = null;
                  Utils.scenesMap = null;

                  await getProject(project);

                  Navigator.push(
                      context,
                      Utils.createRoute(
                          null /*ProjectHome(
                          project: project,
                        )*/
                          ,
                          Utils.RTL));
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(width: 1),
                    ),
                  ),
                  child: ListTile(
                    title: Text("${project.name}"),
                    subtitle: Text("${project.role['role']}"),
                  ),
                ),
              );
            }))
          : Center(
              child: Text(loading ? '' : 'No Roles.'),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: color,
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => null /*AddProject()*/));
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
