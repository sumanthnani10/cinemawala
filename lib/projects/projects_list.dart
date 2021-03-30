import 'dart:convert';

import 'package:cinemawala/projects/add_project.dart';
import 'package:cinemawala/projects/project.dart';
import 'package:cinemawala/projects/project_home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils.dart';

class ProjectsList extends StatefulWidget {
  ProjectsList({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _ProjectsList createState() => _ProjectsList();
}

class _ProjectsList extends State<ProjectsList> {
  Color background, color, background1;
  List<Project> projects = [];
  bool loading = false;
  Project project;

  @override
  void initState() {
    loading = true;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getProjects();
    });
    super.initState();
  }

  getProjects() async {
    loading = true;
    Utils.showLoadingDialog(context, 'Getting Projects');
    var resp = await http
        .post(Utils.GET_PROJECTS, body: {"user_id": "${Utils.USER_ID}"});
    // // debugPrint(resp.body);
    projects = [];
    if (resp.statusCode == 200) {
      var r = jsonDecode(resp.body);
      if (r['status'] == 'success') {
        r['projects'].forEach((i) {
          projects.add(Project.fromJson(i));
        });
      } else {
        projects = [];
      }
    } else {
      projects = [];
    }
    setState(() {
      loading = false;
    });
    Navigator.pop(context);
  }

  getProject(proj) async {
    loading = true;
    Utils.showLoadingDialog(context, 'Getting Project');
    project = await Utils.getProject(context, proj.id);
    await Utils.getArtists(context, proj.id);
    await Utils.getCostumes(context, proj.id);
    await Utils.getProps(context, proj.id);
    await Utils.getLocations(context, proj.id);
    await Utils.getScenes(context, proj.id);
    await Utils.getSchedules(context, proj.id);
    await Utils.getDailyBudgets(context, proj.id);
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
          "Your Projects",
          style: TextStyle(color: background1),
        ),
        actions: [
          FlatButton.icon(
            onPressed: () async {
              getProjects();
            },
            color: color,
            splashColor: background1.withOpacity(0.2),
            label: Text(
              "Reload",
              style: TextStyle(color: Colors.indigo),
              textAlign: TextAlign.right,
            ),
            icon: Icon(
              Icons.refresh_rounded,
              size: 18,
              color: Colors.indigo,
            ),
          )
        ],
      ),
      body: projects.length > 0
          ? Column(
              children: List<Widget>.generate(projects.length, (i) {
                project = projects[i];
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
                          ProjectHome(
                            project: project,
                          ),
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
              child: Text(loading ? '' : 'No Projects.'),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: color,
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddProject()));
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
