import 'package:cinemawala/artists/actors_list.dart';
import 'package:cinemawala/costumes/costumes_list.dart';
import 'package:cinemawala/daily_budget/daily_budgets.dart';
import 'package:cinemawala/locations/locations_list.dart';
import 'package:cinemawala/props/props_list.dart';
import 'package:cinemawala/roles/roles_list.dart';
import 'package:cinemawala/scenes/scenes_list.dart';
import 'package:cinemawala/schedule/schedules.dart';
import 'package:cinemawala/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'add_project.dart';
import 'project.dart';

class ProjectHome extends StatefulWidget {
  final Project project;

  const ProjectHome({Key key, this.project}) : super(key: key);

  @override
  _ProjectHome createState() => _ProjectHome(project: project);
}

class _ProjectHome extends State<ProjectHome> {
  Project project;

  _ProjectHome({@required this.project});

  Color background, color, background1;
  bool loading = false;
  int rowCount = 3;
  List<Map> categories;

  @override
  void initState() {
    loading = false;
    setCategories();
    super.initState();
  }

  setCategories() async {
    categories = [
      {
        "title": "Casting",
        "key": "casting",
        "image": "assets/images/artists.png",
        "onClick": ActorsList(
          project: project,
        ),
        "color": Colors.green[100],
      },
      {
        "title": "Costumes",
        "key": "costumes",
        "image": "assets/images/costumes.png",
        "onClick": CostumesList(
          project: project,
        ),
        "color": Colors.yellow[300],
      },
      {
        "title": "Art Department",
        "key": "props",
        "image": "assets/images/art_department.png",
        "onClick": PropsList(
          project: project,
        ),
        "color": Colors.red[100],
      },
      {
        "title": "Strip Board",
        "key": "scenes",
        "image": "assets/images/scene.png",
        "onClick": ScenesList(
          project: project,
        ),
        "color": Colors.blue[100],
      },
      {
        "title": "Roles",
        "key": "roles",
        "image": "assets/images/roles.png",
        "onClick": RolesList(
          project: project,
        ),
        "color": Colors.orange[300],
      },
      {
        "title": "Schedule",
        "key": "schedule",
        "image": "assets/images/schedule.png",
        "onClick": Schedules(
          project: project,
        ),
        "color": Colors.lime[400],
      },
      {
        "title": "Locations",
        "key": "locations",
        "image": "assets/images/location.png",
        "onClick": LocationsList(
          project: project,
        ),
        "color": Colors.redAccent[100],
      },
      {
        "title": "Daily Reports",
        "key": "report",
        "image": "assets/images/dailyreport.png",
        "onClick": /*PropsList(project: project,)*/ Center(
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.all(16),
            child: Text("Yet to be added."),
          ),
        ),
        "color": Colors.cyanAccent[100],
      },
      {
        "title": "Daily Budget",
        "key": "budget",
        "image": "assets/images/dailybudget.png",
        "onClick": DailyBudgets(project: project),
        "color": Colors.green[100],
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Utils.showScrollingDialog(context, "", "${Utils.languages}", (){Navigator.pop(context);}, (){});
    color = Color(0xff6fd8a8);
    background = Colors.white;
    if (background == Colors.white) {
      background1 = Colors.black;
    } else {
      background1 = Colors.white;
    }
    var margin = EdgeInsets.all(2);
    var padding = EdgeInsets.all(8);
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: Utils.linearGradient,
          ),
        ),
        backgroundColor: color,
        title: Text(
          "${project.name}",
          style: TextStyle(color: background1),
        ),
        iconTheme: IconThemeData(color: background1),
        actions: [
          if (project.role.owner)
            TextButton.icon(
              onPressed: () async {
                await Navigator.push(
                    context,
                    Utils.createRoute(
                        AddProject(
                          project: project.toJson(),
                        ),
                        Utils.RTL));
                Utils.project = Utils.projectsMap[project.id];
                project = Utils.project;

                Utils.languages = [];
                Utils.langsInLang = [];

                project.languages.forEach((l) {
                  Utils.languages.add(Utils.codeToLanguagesInEnglish[l]);
                  Utils.langsInLang.add(Utils.codeToLanguagesInLanguage[l]);
                });

                setCategories();
                setState(() {});
              },
              label: Container(
                padding: kIsWeb ? EdgeInsets.only(right: 12):EdgeInsets.only(right: 2),
                child: Text(
                  "Edit Project",
                  style: TextStyle(color: Colors.indigo),
                  textAlign: TextAlign.right,
                ),
              ),
              icon: Icon(
                Icons.edit,
                size: 18,
                color: Colors.indigo,
              ),
            )
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          var width = constraints.maxWidth;
          return Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Row(
                    children: List<Widget>.generate(rowCount, (i) {
                      int ind = i;
                      return Expanded(
                        child: InkWell(
                          onTap: () {
                            if (project.role.permissions[categories[ind]['key']]
                                ['view']) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          categories[ind]['onClick']));
                            }
                          },
                          child: Stack(
                            children: [
                              Container(
                                padding: padding,
                                margin: margin,
                                decoration: BoxDecoration(
                                  color: categories[ind]['color'],
                                  //borderRadius: BorderRadius.circular(12.0)
                                  borderRadius: ind == 0
                                      ? BorderRadius.only(
                                          topLeft: Radius.circular(24))
                                      : ind == 2
                                          ? BorderRadius.only(
                                              topRight: Radius.circular(24))
                                          : ind == categories.length - rowCount
                                              ? BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(24))
                                              : ind == categories.length - 1
                                                  ? BorderRadius.only(
                                                      topRight:
                                                          Radius.circular(24))
                                                  : BorderRadius.only(),
                                ),
                                child: Center(
                                  child: width > Utils.mobileWidth
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            AspectRatio(
                                              aspectRatio: 4 / 3,
                                              child: FittedBox(
                                                child: Image(
                                                    image: AssetImage(
                                                        '${categories[ind]['image']}')),
                                              ),
                                            ),
                                            FittedBox(
                                              child: Text(
                                                "${categories[ind]['title']}",
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            AspectRatio(
                                              aspectRatio: 4 / 3,
                                              child: FittedBox(
                                                child: Image(
                                                    image: AssetImage(
                                                        '${categories[ind]['image']}')),
                                              ),
                                            ),
                                            FittedBox(
                                              child: Text(
                                                "${categories[ind]['title']}",
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                              if (!project.role
                                  .permissions[categories[ind]['key']]['view'])
                                Center(
                                  child: AspectRatio(
                                    aspectRatio: 4 / 3,
                                    child: Image(
                                        image: AssetImage(
                                            'assets/images/lock.png')),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                Expanded(
                  child: Row(
                    children: List<Widget>.generate(rowCount, (i) {
                      int ind = i + 3;
                      return Expanded(
                        child: InkWell(
                          onTap: () async {
                            if (project.role.permissions[categories[ind]['key']]
                                ['view']) {
                              var back = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          categories[ind]['onClick']));
                              if (back != null) {
                                if (back.runtimeType == Project) {
                                  project = back;
                                }
                              }
                            }
                          },
                          child: Stack(
                            children: [
                              Container(
                                padding: padding,
                                margin: margin,
                                decoration: BoxDecoration(
                                  color: categories[ind]['color'],
                                  //borderRadius: BorderRadius.circular(12.0)
                                  borderRadius: ind == 0
                                      ? BorderRadius.only(
                                          topLeft: Radius.circular(24))
                                      : ind == 2
                                          ? BorderRadius.only(
                                              topRight: Radius.circular(24))
                                          : ind == categories.length - rowCount
                                              ? BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(24))
                                              : ind == categories.length - 1
                                                  ? BorderRadius.only(
                                                      topRight:
                                                          Radius.circular(24))
                                                  : BorderRadius.only(),
                                ),
                                child: Center(
                                  child: width > Utils.mobileWidth
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            AspectRatio(
                                              aspectRatio: 4 / 3,
                                              child: FittedBox(
                                                child: Image(
                                                    image: AssetImage(
                                                        '${categories[ind]['image']}')),
                                              ),
                                            ),
                                            FittedBox(
                                              child: Text(
                                                "${categories[ind]['title']}",
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            AspectRatio(
                                              aspectRatio: 4 / 3,
                                              child: FittedBox(
                                                child: Image(
                                                    image: AssetImage(
                                                        '${categories[ind]['image']}')),
                                              ),
                                            ),
                                            FittedBox(
                                              child: Text(
                                                "${categories[ind]['title']}",
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                              if (!project.role
                                  .permissions[categories[ind]['key']]['view'])
                                Center(
                                  child: AspectRatio(
                                    aspectRatio: 4 / 3,
                                    child: Image(
                                        image: AssetImage(
                                            'assets/images/lock.png')),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                Expanded(
                  child: Row(
                    children: List<Widget>.generate(rowCount, (i) {
                      int ind = i + 6;
                      return Expanded(
                        child: InkWell(
                          onTap: () {
                            if (project.role.permissions[categories[ind]['key']]
                                ['view']) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          categories[ind]['onClick']));
                            }
                          },
                          child: Stack(
                            children: [
                              Container(
                                padding: padding,
                                margin: margin,
                                decoration: BoxDecoration(
                                  color: categories[ind]['color'],
                                  //borderRadius: BorderRadius.circular(12.0)
                                  borderRadius: ind == 0
                                      ? BorderRadius.only(
                                          topLeft: Radius.circular(24))
                                      : ind == 2
                                          ? BorderRadius.only(
                                              topRight: Radius.circular(24))
                                          : ind == categories.length - rowCount
                                              ? BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(24))
                                              : ind == categories.length - 1
                                                  ? BorderRadius.only(
                                                      bottomRight:
                                                          Radius.circular(24))
                                                  : BorderRadius.only(),
                                ),
                                child: Center(
                                  child: width > Utils.mobileWidth
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            AspectRatio(
                                              aspectRatio: 4 / 3,
                                              child: FittedBox(
                                                child: Image(
                                                    image: AssetImage(
                                                        '${categories[ind]['image']}')),
                                              ),
                                            ),
                                            FittedBox(
                                              child: Text(
                                                "${categories[ind]['title']}",
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            AspectRatio(
                                              aspectRatio: 4 / 3,
                                              child: FittedBox(
                                                child: Image(
                                                    image: AssetImage(
                                                        '${categories[ind]['image']}')),
                                              ),
                                            ),
                                            FittedBox(
                                              child: Text(
                                                "${categories[ind]['title']}",
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                              if (!project.role
                                  .permissions[categories[ind]['key']]['view'])
                                Center(
                                  child: AspectRatio(
                                    aspectRatio: 4 / 3,
                                    child: Image(
                                        image: AssetImage(
                                            'assets/images/lock.png')),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
