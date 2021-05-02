import 'dart:convert';

import 'package:cinemawala/personal_calendar.dart';
import 'package:cinemawala/projects/project.dart';
import 'package:cinemawala/projects/project_card.dart';
import 'package:cinemawala/projects/project_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../main.dart';
import '../utils.dart';
import 'add_project.dart';

class ProjectsList extends StatefulWidget {
  ProjectsList({Key key}) : super(key: key);

  @override
  _ProjectsList createState() => _ProjectsList();
}

class _ProjectsList extends State<ProjectsList> {
  Color background, color, background1;
  List<Project> allProjects = [],
      ownProjects = [],
      otherProjects = [],
      requestProjects = [];
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
    allProjects = await Utils.getProjects(context);
    ownProjects = allProjects.where((e) => e.role.owner).toList();
    otherProjects =
        allProjects.where((e) => !e.role.owner && e.role.accepted).toList();
    requestProjects = allProjects.where((e) => !e.role.accepted).toList();
    setState(() {
      loading = false;
    });
    Navigator.pop(context);
  }

  getProject(Project proj) async {
    loading = true;
    Utils.showLoadingDialog(context, 'Getting ${proj.name}');
    Utils.project = await Utils.getProject(context, proj.id);
    project = Utils.project;
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
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: Utils.linearGradient,
          ),
        ),
        backgroundColor: color,
        iconTheme: IconThemeData(color: background1),
        automaticallyImplyLeading: false,
        title: Text(
          "Projects",
          style: TextStyle(color: background1),
        ),
        actions: [
          TextButton.icon(
            onPressed: () async {
              getProjects();
            },
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
          ),
          TextButton.icon(
            onPressed: () async {
              Utils.showLoadingDialog(context, "Signing Out");
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(context,
                  Utils.createRoute(SplashScreen(), Utils.LTR), (r) => false);
            },
            label: Text(
              "Sign Out",
              style: TextStyle(color: Colors.indigo),
              textAlign: TextAlign.right,
            ),
            icon: Icon(
              Icons.person,
              size: 18,
              color: Colors.indigo,
            ),
          ),
        ],
      ),
      body: allProjects.length > 0
          ? SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Text(
                      "My Projects",
                      style: TextStyle(
                        fontSize: 20,
                        color: const Color(0xff309f86),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Spacer(),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: InkWell(
                        onTap: (){
                          Navigator.push(
                              context,
                              Utils.createRoute(
                                  PersonalCalendar(),
                                  Utils.DTU));
                        },
                        child: Icon(Icons.calendar_today)),
                  ),
                ),
              ],
            ),
            Flexible(
              child: Align(
                alignment: Alignment.centerLeft,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(ownProjects.length, (i) {
                      project = ownProjects[i];
                      return ProjectCard(
                        project: project,
                        onTap: () async {
                          Project proj = ownProjects[i];
                                if (Utils.project == null ||
                                    Utils.project.id != proj.id) {
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

                                  await getProject(proj);

                                  Utils.languages = [];
                                  Utils.langsInLang = [];

                                  proj.languages.forEach((l) {
                                    Utils.languages
                                        .add(Utils.codeToLanguagesInEnglish[l]);
                                    Utils.langsInLang.add(
                                        Utils.codeToLanguagesInLanguage[l]);
                                  });
                                }

                          Navigator.push(
                              context,
                              Utils.createRoute(
                                  ProjectHome(
                                    project: proj,
                                        ),
                                  Utils.RTL));
                        },
                      );
                    }),
                  ),
                ),
              ),
            ),
            if (otherProjects.length > 0)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Text(
                    "Other Projects",
                    style: TextStyle(
                      fontSize: 20,
                      color: const Color(0xff309f86),
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            Flexible(
              child: Align(
                alignment: Alignment.centerLeft,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(otherProjects.length, (i) {
                      project = otherProjects[i];
                      return ProjectCard(
                        project: project,
                        onTap: () async {
                          Project proj = otherProjects[i];
                                if (Utils.project == null ||
                                    Utils.project.id != proj.id) {
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

                                  await getProject(proj);
                                }

                          Navigator.push(
                              context,
                              Utils.createRoute(
                                  ProjectHome(
                                    project: proj,
                                        ),
                                  Utils.RTL));
                        },
                      );
                    }),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(
                  "Requests",
                  style: TextStyle(
                    fontSize: 20,
                    color: const Color(0xff309f86),
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            requestProjects.length == 0
                ? Text("No Requests")
                : Flexible(
              child: Align(
                alignment: Alignment.centerLeft,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                    List.generate(requestProjects.length, (i) {
                      project = requestProjects[i];
                      return ProjectCard(
                        project: project,
                                    onTap: () async {
                                      Project proj = requestProjects[i];
                                      if (await Navigator.push(
                                              context,
                                              Utils.createRoute(
                                                  RespondRequest(project: proj),
                                                  Utils.UTD)) ??
                                          false) {
                                        getProjects();
                                      }
                                    },
                                  );
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),
      )
          : Center(
        child: Text(loading ? '' : 'No Projects.'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: color,
        onPressed: () async {
          await Navigator.push(
              context, Utils.createRoute(AddProject(), Utils.DTU));
          setState(() {
            allProjects = Utils.projects;
            ownProjects = allProjects.where((e) => e.role.owner).toList();
            otherProjects = allProjects.where((e) => !e.role.owner).toList();
            requestProjects =
                allProjects.where((e) => !e.role.accepted).toList();
          });
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

class RespondRequest extends StatefulWidget {
  final Project project;
  final bool isPopUp;

  const RespondRequest({Key key, @required this.project, this.isPopUp})
      : super(key: key);

  @override
  _RespondRequestState createState() =>
      _RespondRequestState(this.project, this.isPopUp ?? true);
}

class _RespondRequestState extends State<RespondRequest> {
  final Project project;
  Color background, background1, color;
  bool isPopUp;

  _RespondRequestState(this.project, this.isPopUp);

  @override
  Widget build(BuildContext context) {
    background = Colors.white;
    color = Color(0xff6fd8a8);
    if (background == Colors.white) {
      background1 = Colors.black;
    } else {
      background1 = Colors.white;
    }
    var permissions = project.role.permissions;
    var permissionsKeys = permissions.keys.toList();

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: isPopUp ? Colors.black26 : Colors.white,
        body: Center(
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Container(
              margin: EdgeInsets.symmetric(
                  vertical: isPopUp ? 48 : 8, horizontal: isPopUp ? 24 : 4),
              constraints: BoxConstraints(maxWidth: Utils.mobileWidth),
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (isPopUp)
                        IconButton(
                            icon: Icon(Icons.arrow_back_rounded),
                            onPressed: () {
                              Navigator.pop(context);
                            }),
                      Text(
                        "Request",
                        style: TextStyle(fontSize: 20, color: background1),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "${project.name}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            RichText(
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                text: TextSpan(
                                    text: "by ${project.ownerName}",
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                        fontFamily: 'Poppins'),
                                    children: [
                                      TextSpan(
                                          text: "\n @${project.ownerUsername}",
                                          style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 12))
                                    ])),
                            SizedBox(
                              height: 4,
                            ),
                            Text(
                              "Your Role: ${project.role.role}",
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            Table(
                                border: TableBorder(
                                    horizontalInside: BorderSide(
                                        color: background1, width: 0.4)),
                                children: [
                                  TableRow(children: [
                                    TableCell(
                                      child: Center(
                                        child: Padding(
                                          padding:
                                          const EdgeInsets.symmetric(
                                              vertical: 8),
                                          child: FittedBox(
                                            child: Text(
                                              "Permission",
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight:
                                                  FontWeight.bold,
                                                  decoration: TextDecoration
                                                      .underline),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      child: Center(
                                        child: Padding(
                                          padding:
                                          const EdgeInsets.symmetric(
                                              vertical: 8),
                                          child: Text(
                                            "View",
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                decoration: TextDecoration
                                                    .underline),
                                          ),
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      child: Center(
                                        child: Padding(
                                          padding:
                                          const EdgeInsets.symmetric(
                                              vertical: 8),
                                          child: Text(
                                            "Add",
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                decoration: TextDecoration
                                                    .underline),
                                          ),
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      child: Center(
                                        child: Padding(
                                          padding:
                                          const EdgeInsets.symmetric(
                                              vertical: 8),
                                          child: Text(
                                            "Edit",
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                decoration: TextDecoration
                                                    .underline),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ])
                                ] +
                                    List.generate(permissionsKeys.length, (i) {
                                      var keysVal = ["view", "add", "edit"];
                                      var catName = permissionsKeys[i]
                                          .replaceAll("_", " ");
                                      int flag = 0;
                                      String category = "";
                                      for (int i = 0; i < catName.length; i++) {
                                        if (flag == 0) {
                                          category = category +
                                              catName[i].toUpperCase();
                                          flag = 1;
                                        } else if (catName[i] == " ") {
                                          category = category + catName[i];
                                          flag = 0;
                                        } else {
                                          category = category + catName[i];
                                        }
                                      }
                                      return TableRow(
                                        children: [
                                          TableCell(
                                            child: Padding(
                                              padding: const EdgeInsets
                                                  .symmetric(vertical: 8),
                                              child: Text(
                                                "$category ",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight:
                                                    FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ] +
                                            List.generate(keysVal.length, (j) {
                                              String permission = "";
                                              String val = keysVal[j];
                                              permission = permission +
                                                  val[0].toUpperCase() +
                                                  val.substring(1);
                                              bool value = permissions[
                                              permissionsKeys[
                                              i]][keysVal[0]] ==
                                                  true
                                                  ? permissions[
                                              permissionsKeys[i]]
                                              [keysVal[j]]
                                                  : false;
                                              return TableCell(
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 8),
                                                  child: value
                                                      ? Icon(
                                                    Icons.done,
                                                    color: Colors.green,
                                                    size: 20,
                                                  )
                                                      : Icon(
                                                    Icons.cancel,
                                                    color:
                                                    Colors.deepOrange,
                                                    size: 20,
                                                  ),
                                                ),
                                              );
                                            }),
                                      );
                                    })),
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        await respondRole(false);
                                      },
                                      icon: Icon(Icons.close),
                                      label: Text("Reject"),
                                      style: ElevatedButton.styleFrom(
                                          primary: Colors.deepOrange),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        await respondRole(true);
                                      },
                                      icon: Icon(Icons.done),
                                      label: Text("Accept"),
                                      style: ElevatedButton.styleFrom(
                                          primary: Colors.green),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ]),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  respondRole(bool response) async {
    Utils.showLoadingDialog(context, "Responding");

    var back = false;

    try {
      var resp = await http.post(Utils.RESPOND_ROLE,
          body: jsonEncode({
            "project_id": project.id,
            "user_id": Utils.user.id,
            "accepted": response
          }),
          headers: {"Content-Type": "application/json"});
      // // debugPrint(resp.body);
      var r = jsonDecode(resp.body);
      Navigator.pop(context);
      if (resp.statusCode == 200) {
        if (r["status"] == "success") {
          back = true;
          await Utils.showSuccessDialog(
              context,
              "Role ${response ? "Accepted" : "Rejected"}",
              "Role has been ${response ? "accepted" : "rejected"} successfully.",
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
    } catch (e) {
      // debugPrint(e);
      Navigator.pop(context);
      await Utils.showErrorDialog(
          context, "Something went wrong.", "Please try again after sometime.");
    }
    Navigator.pop(context, back);
  }
}

/*
Padding(
        padding: const EdgeInsets.fromLTRB(4,12,4,12),
        child: InkWell(
          splashColor: Colors.black.withOpacity(0.01),
          borderRadius: BorderRadius.circular(16),
          onTap: (){
          },
          child: Container(
            width: 158,
            color: Colors.yellow,
            // height: 158*4.9/3,
            // constraints: BoxConstraints.tightFor(),
            padding: const EdgeInsets.fromLTRB(0,4,0,0),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  top: 24,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 150,
                      margin: const EdgeInsets.fromLTRB(4,0,4,8),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment(0.0, 0.9),
                            end: Alignment(0.0, 1.0),
                            colors: [
                              const Color(0xff25f1c3),
                              const Color(0xff96EFDB),
                            ],
                            stops: [0.5,1.0],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0x55000000),
                              offset: Offset(0, 3),
                              blurRadius: 4,
                            ),
                          ]),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AspectRatio(aspectRatio: 3/3.7,),
                          Text(
                            "${project.name}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "${project.role['role']}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(8,0,8,8),
                      width: 142,
                      height: 142*4/3,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(project.image),
                            fit: BoxFit.cover,
                            onError: (_, __) => Container(
                              color: Colors.white,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xbf000000),
                              offset: Offset(0, 4),
                              blurRadius: 4,
                            ),
                          ]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ) SingleChildScrollView(
              child: Container(
                height: 1000,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                        child: Text(
                          "My Projects",
                          style: TextStyle(
                            fontSize: 20,
                            color: const Color(0xff309f86),
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(
                              10, (i) => ProjectCard(project: projects[0], onTap: () async {
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
                          },)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ) ProjectCard(project: projects[0], onTap: () async {
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
      },)*/
