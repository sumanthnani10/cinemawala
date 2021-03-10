import 'package:cinemawala/casting/actor.dart';
import 'package:cinemawala/casting/actor_page.dart';
import 'package:cinemawala/costumes/costume.dart';
import 'package:cinemawala/costumes/costume_page.dart';
import 'package:cinemawala/locations/location.dart';
import 'package:cinemawala/projects/project.dart';
import 'package:cinemawala/props/prop.dart';
import 'package:cinemawala/props/prop_page.dart';
import 'package:cinemawala/scenes/scene.dart';
import 'package:cinemawala/schedule/add_schedule.dart';
import 'package:cinemawala/schedule/schedule.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

class SchedulePage extends StatefulWidget {
  final Project project;
  final Schedule schedule;
  final DateTime date;
  final String id;

  SchedulePage(
      {@required this.project,
      @required this.schedule,
      @required this.date,
      @required this.id});

  @override
  _SchedulePageState createState() => _SchedulePageState(
      project: project, id: id, date: date, schedule: schedule);
}

class _SchedulePageState extends State<SchedulePage>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;

  final String id;
  final Project project;
  Schedule schedule;
  final DateTime date;

  _SchedulePageState({this.project, this.schedule, this.date, this.id});

  List<Scene> selectedScenes = [];
  Set<Actor> selectedArtists = {};
  Set<Prop> selectedProps = {};
  Set<Location> selectedLocations = {};
  Set<Costume> selectedCostumes = {};
  var bottomSheetHeadingStyle =
      TextStyle(fontWeight: FontWeight.bold, fontSize: 16);

  Color background, background1, color;

  @override
  void initState() {
    if (schedule != null) {
      schedule.scenes.forEach((s) {
        Scene scene = Utils.scenesMap[s];
        selectedScenes.add(scene);
        scene.artists.forEach((a) {
          selectedArtists.add(Utils.artistsMap[a]);
        });
        for (var i in scene.costumes) {
          for (var j in i['costumes']) {
            selectedCostumes.add(Utils.costumesMap[j]);
          }
        }
        scene.props.forEach((p) {
          selectedProps.add(Utils.propsMap[p]);
        });
        selectedLocations.add(Utils.locationsMap[scene.location]);
      });
    }
    super.initState();
    animationController = AnimationController(vsync: this);
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
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16), topRight: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff6fd8a8),
              offset: Offset(0, -0.5),
              blurRadius: 1,
            ),
          ]),
      child: schedule != null
          ? Column(
              children: [
                /*Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: InkWell(
              onTap: () {},
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xff6fd8a8),
                        offset: Offset(0, 0.5),
                        blurRadius: 1,
                      ),
                    ]),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add),
                      Text("Generate Call Sheet"),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Divider(
            thickness: 2,
          ),*/
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Scenes", style: bottomSheetHeadingStyle)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      direction: Axis.horizontal,
                      children:
                          List<Widget>.generate(selectedScenes.length, (i) {
                        return InkWell(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) => null));
                          },
                          child: Container(
                            margin: EdgeInsets.all(2),
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(300),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${selectedScenes[i].titles['English']}'),
                                SizedBox(
                                  width: 2,
                                ),
                                InkWell(
                                    onTap: () {
                                      setState(() {
                                        selectedScenes.removeAt(i);
                                      });
                                    },
                                    child: Container(
                                        child: Icon(
                                      Icons.highlight_remove_outlined,
                                      color: Colors.red,
                                    ))),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Artists",
                        style: bottomSheetHeadingStyle,
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      direction: Axis.horizontal,
                      children:
                          List<Widget>.generate(selectedArtists.length, (i) {
                        return InkWell(
                          onLongPress: () {
                            Navigator.push(
                                context,
                                PageRouteBuilder(
                                    pageBuilder: (_, __, ___) => ActorPopUp(
                                          actor: selectedArtists.elementAt(i),
                                          project: project,
                                        ),
                                    opaque: false));
                          },
                          splashColor: background1.withOpacity(0.2),
                          child: Container(
                            margin: EdgeInsets.all(2),
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(300),
                            ),
                            child: Text(
                                "${selectedArtists.elementAt(i).names['English']}"),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Costumes",
                        style: bottomSheetHeadingStyle,
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      direction: Axis.horizontal,
                      children:
                          List<Widget>.generate(selectedCostumes.length, (i) {
                        return InkWell(
                          onLongPress: () {
                            Navigator.push(
                                context,
                                PageRouteBuilder(
                                    pageBuilder: (_, __, ___) => CostumesPage(
                                          costume:
                                              selectedCostumes.elementAt(i),
                                          project: project,
                                        ),
                                    opaque: false));
                          },
                          splashColor: background1.withOpacity(0.2),
                          child: Container(
                            margin: EdgeInsets.all(2),
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(300),
                            ),
                            child:
                                Text("${selectedCostumes.elementAt(i).title}"),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Props",
                        style: bottomSheetHeadingStyle,
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      direction: Axis.horizontal,
                      children:
                          List<Widget>.generate(selectedProps.length, (i) {
                        return InkWell(
                          onLongPress: () {
                            Navigator.push(
                                context,
                                PageRouteBuilder(
                                    pageBuilder: (_, __, ___) => PropPage(
                                          prop: selectedProps.elementAt(i),
                                          project: project,
                                        ),
                                    opaque: false));
                          },
                          splashColor: background1.withOpacity(0.2),
                          child: Container(
                            margin: EdgeInsets.all(2),
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(300),
                            ),
                            child: Text("${selectedProps.elementAt(i).title}"),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                SizedBox(
                  height: 100,
                ),
                Text(
                  "No Schedule.",
                  style: TextStyle(fontSize: 20),
                ),
                ElevatedButton(
                  onPressed: () async {
                    var now = DateTime.now();
                    Map<String, dynamic> schedule = {
                      "day": date.day,
                      "project_id": project.id,
                      "scenes": [],
                      "month": date.month,
                      "added_by": Utils.USER_ID,
                      "id": id,
                      "year": date.year,
                      "last_edit_by": Utils.USER_ID,
                      "last_edit_on": now.millisecondsSinceEpoch,
                      "created": now.millisecondsSinceEpoch
                    };
                    var back = await Navigator.push(
                            context,
                            Utils.createRoute(
                                AddSchedule(
                                    schedule: schedule, project: project),
                                Utils.DTU)) ??
                        false;
                    if (back) {
                      Utils.getSchedules(context, project.id);
                    }
                  },
                  child: Text("+ Add Schedule"),
                  style: ElevatedButton.styleFrom(primary: color),
                )
              ],
            ),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}

/*import 'package:cinemawala/casting/actor.dart';
import 'package:cinemawala/casting/actor_page.dart';
import 'package:cinemawala/costumes/costume.dart';
import 'package:cinemawala/costumes/costume_page.dart';
import 'package:cinemawala/locations/location.dart';
import 'package:cinemawala/projects/project.dart';
import 'package:cinemawala/props/prop.dart';
import 'package:cinemawala/props/prop_page.dart';
import 'package:cinemawala/scenes/scene.dart';
import 'package:cinemawala/schedule/add_schedule.dart';
import 'package:cinemawala/schedule/schedule.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

class SchedulePage extends StatelessWidget {
  final String id;
  final Project project;
  Schedule schedule;
  final DateTime date;

  SchedulePage(this.project, this.schedule, this.date, this.id);

  List<Scene> selectedScenes = [];
  Set<Actor> selectedArtists = {};
  Set<Prop> selectedProps = {};
  Set<Location> selectedLocations = {};
  Set<Costume> selectedCostumes = {};
  var bottomSheetHeadingStyle =
      TextStyle(fontWeight: FontWeight.bold, fontSize: 16);

  Color background, background1, color;

  @override
  Widget build(BuildContext context) {
    selectedScenes = [];
    selectedArtists = {};
    selectedProps = {};
    selectedLocations = {};
    selectedCostumes = {};
    if (schedule != null) {
      schedule.scenes.forEach((s) {
        Scene scene = Utils.scenesMap[s];
        selectedScenes.add(scene);
        scene.artists.forEach((a) {
          selectedArtists.add(Utils.artistsMap[a]);
        });
        for (var i in scene.costumes) {
          for (var j in i['costumes']) {
            selectedCostumes.add(Utils.costumesMap[j]);
          }
        }
        scene.props.forEach((p) {
          selectedProps.add(Utils.propsMap[p]);
        });
        selectedLocations.add(Utils.locationsMap[scene.location]);
      });
    }
    background = Colors.white;
    color = Color(0xff6fd8a8);
    if (background == Colors.white) {
      background1 = Colors.black;
    } else {
      background1 = Colors.white;
    }
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16), topRight: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff6fd8a8),
              offset: Offset(0, -0.5),
              blurRadius: 1,
            ),
          ]),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: schedule != null
            ? Column(
                children: [
                  /*Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: InkWell(
                onTap: () {},
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xff6fd8a8),
                          offset: Offset(0, 0.5),
                          blurRadius: 1,
                        ),
                      ]),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add),
                        Text("Generate Call Sheet"),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Divider(
              thickness: 2,
            ),*/
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Scenes", style: bottomSheetHeadingStyle)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        direction: Axis.horizontal,
                        children:
                            List<Widget>.generate(selectedScenes.length, (i) {
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => null));
                            },
                            child: Container(
                              margin: EdgeInsets.all(2),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(300),
                              ),
                              child: Text(
                                  '${selectedScenes[i].titles['English']}'),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Artists",
                          style: bottomSheetHeadingStyle,
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        direction: Axis.horizontal,
                        children:
                            List<Widget>.generate(selectedArtists.length, (i) {
                          return InkWell(
                            onLongPress: () {
                              Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                      pageBuilder: (_, __, ___) => ActorPopUp(
                                            actor: selectedArtists.elementAt(i),
                                            project: project,
                                          ),
                                      opaque: false));
                            },
                            splashColor: background1.withOpacity(0.2),
                            child: Container(
                              margin: EdgeInsets.all(2),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(300),
                              ),
                              child: Text(
                                  "${selectedArtists.elementAt(i).names['English']}"),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Costumes",
                          style: bottomSheetHeadingStyle,
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        direction: Axis.horizontal,
                        children:
                            List<Widget>.generate(selectedCostumes.length, (i) {
                          return InkWell(
                            onLongPress: () {
                              Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                      pageBuilder: (_, __, ___) => CostumesPage(
                                            costume:
                                                selectedCostumes.elementAt(i),
                                            project: project,
                                          ),
                                      opaque: false));
                            },
                            splashColor: background1.withOpacity(0.2),
                            child: Container(
                              margin: EdgeInsets.all(2),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(300),
                              ),
                              child: Text(
                                  "${selectedCostumes.elementAt(i).title}"),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Props",
                          style: bottomSheetHeadingStyle,
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        direction: Axis.horizontal,
                        children:
                            List<Widget>.generate(selectedProps.length, (i) {
                          return InkWell(
                            onLongPress: () {
                              Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                      pageBuilder: (_, __, ___) => PropPage(
                                            prop: selectedProps.elementAt(i),
                                            project: project,
                                          ),
                                      opaque: false));
                            },
                            splashColor: background1.withOpacity(0.2),
                            child: Container(
                              margin: EdgeInsets.all(2),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(300),
                              ),
                              child:
                                  Text("${selectedProps.elementAt(i).title}"),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  SizedBox(
                    height: 100,
                  ),
                  Text(
                    "No Schedule.",
                    style: TextStyle(fontSize: 20),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      var now = DateTime.now();
                      Map<String, dynamic> schedule = {
                        "day": date.day,
                        "project_id": project.id,
                        "scenes": [],
                        "month": date.month,
                        "added_by": Utils.USER_ID,
                        "id": id,
                        "year": date.year,
                        "last_edit_by": Utils.USER_ID,
                        "last_edit_on": now.millisecondsSinceEpoch,
                        "created": now.millisecondsSinceEpoch
                      };
                      var back = await Navigator.push(
                              context,
                              Utils.createRoute(
                                  AddSchedule(
                                      schedule: schedule, project: project),
                                  Utils.DTU)) ??
                          false;
                      if (back) {
                        Utils.getSchedules(context, project.id);
                      }
                    },
                    child: Text("+ Add Schedule"),
                    style: ElevatedButton.styleFrom(primary: color),
                  )
                ],
              ),
      ),
    );
  }
}
*/
