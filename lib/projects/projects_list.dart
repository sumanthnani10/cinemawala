import 'package:cinemawala/personal_calendar.dart';
import 'package:cinemawala/projects/project.dart';
import 'package:cinemawala/projects/project_card.dart';
import 'package:cinemawala/projects/project_home.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

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
    otherProjects = allProjects.where((e) => !e.role.owner).toList();
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
          )
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
                                if (Utils.project == null ||
                                    Utils.project.id != project.id) {
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

                                  Utils.languages = [];
                                  Utils.langsInLang = [];

                                  project.languages.forEach((l) {
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
                                          project: project,
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
                                if (Utils.project == null ||
                                    Utils.project.id != project.id) {
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
                                }

                                Navigator.push(
                                    context,
                                    Utils.createRoute(
                                        ProjectHome(
                                          project: project,
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
                                    onTap: () async {},
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

/*Padding(
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
      )*/ /*SingleChildScrollView(
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
            )*/ /*ProjectCard(project: projects[0], onTap: () async {
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