import 'package:cinemawala/casting/actors_list.dart';
import 'package:cinemawala/costumes/costumes_list.dart';
import 'package:cinemawala/daily_budget/daily_budget.dart';
import 'package:cinemawala/locations/locations_list.dart';
import 'package:cinemawala/props/props_list.dart';
import 'package:cinemawala/scenes/scenes_list.dart';
import 'package:cinemawala/schedule/schedules.dart';
import 'package:flutter/material.dart';

import '../utils.dart';
import 'project.dart';

class ProjectHome extends StatefulWidget {
  final Project project;

  const ProjectHome({Key key, this.project}) : super(key: key);

  @override
  _ProjectHome createState() => _ProjectHome(project: project);
}

class _ProjectHome extends State<ProjectHome> {
  final Project project;

  _ProjectHome({@required this.project});

  Color background, color, background1;
  bool loading = false;
  int rowCount = 3;
  List<Map> categories;

  @override
  void initState() {
    categories = [
      {
        "title": "Casting",
        "key": "casting",
        "image": "assets/images/casting.png",
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
        "title": "One Line Order",
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
        "onClick": /*Roles(project: project,)*/ null,
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
        "onClick": /*PropsList(project: project,)*/ null,
        "color": Colors.cyanAccent[100],
      },
      {
        "title": "Daily Budget",
        "key": "budget",
        "image": "assets/images/dailybudget.png",
        "onClick": DailyBudget(),
        "color": Colors.green[100],
      },
    ];
    loading = true;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getProject();
    });
    super.initState();
  }

  getProject() async {
    loading = true;
    Utils.showLoadingDialog(context, 'Getting Project');
    await Utils.getArtists(context, project.id);
    await Utils.getCostumes(context, project.id);
    await Utils.getProps(context, project.id);
    await Utils.getLocations(context, project.id);
    await Utils.getScenes(context, project.id);
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
    var margin = EdgeInsets.all(2);
    var padding = EdgeInsets.all(8);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: color,
        title: Text(
          "${project.name}",
          style: TextStyle(color: background1),
        ),
        iconTheme: IconThemeData(color: background1),
      ),
      body: Padding(
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
                        if (project.role['permissions'][categories[ind]['key']]
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
                                              bottomLeft: Radius.circular(24))
                                          : ind == categories.length - 1
                                              ? BorderRadius.only(
                                                  topRight: Radius.circular(24))
                                              : BorderRadius.only(),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AspectRatio(
                                    aspectRatio: 4 / 3,
                                    child: Image(
                                        image: AssetImage(
                                            '${categories[ind]['image']}')),
                                  ),
                                  Text(
                                    "${categories[ind]['title']}",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (!project.role['permissions']
                              [categories[ind]['key']]['view'])
                            Center(
                              child: AspectRatio(
                                aspectRatio: 4 / 3,
                                child: Image(
                                    image:
                                        AssetImage('assets/images/lock.png')),
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
                      onTap: () {
                        if (project.role['permissions'][categories[ind]['key']]
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
                                              bottomLeft: Radius.circular(24))
                                          : ind == categories.length - 1
                                              ? BorderRadius.only(
                                                  topRight: Radius.circular(24))
                                              : BorderRadius.only(),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AspectRatio(
                                    aspectRatio: 4 / 3,
                                    child: Image(
                                        image: AssetImage(
                                            '${categories[ind]['image']}')),
                                  ),
                                  Text(
                                    "${categories[ind]['title']}",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (!project.role['permissions']
                              [categories[ind]['key']]['view'])
                            Center(
                              child: AspectRatio(
                                aspectRatio: 4 / 3,
                                child: Image(
                                    image:
                                        AssetImage('assets/images/lock.png')),
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
                        if (project.role['permissions'][categories[ind]['key']]
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
                                              bottomLeft: Radius.circular(24))
                                          : ind == categories.length - 1
                                              ? BorderRadius.only(
                                                  bottomRight:
                                                      Radius.circular(24))
                                              : BorderRadius.only(),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AspectRatio(
                                    aspectRatio: 4 / 3,
                                    child: Image(
                                        image: AssetImage(
                                            '${categories[ind]['image']}')),
                                  ),
                                  Text(
                                    "${categories[ind]['title']}",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (!project.role['permissions']
                              [categories[ind]['key']]['view'])
                            Center(
                              child: AspectRatio(
                                aspectRatio: 4 / 3,
                                child: Image(
                                    image:
                                        AssetImage('assets/images/lock.png')),
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
      ),
    );
  }
}
