import 'dart:convert';

import 'package:cinemawala/casting/actor.dart';
import 'package:cinemawala/casting/actor_page.dart';
import 'package:cinemawala/costumes/costume.dart';
import 'package:cinemawala/costumes/costume_page.dart';
import 'package:cinemawala/locations/location.dart';
import 'package:cinemawala/projects/project.dart';
import 'package:cinemawala/props/prop.dart';
import 'package:cinemawala/props/prop_page.dart';
import 'package:cinemawala/scenes/scene.dart';
import 'package:cinemawala/schedule/schedule.dart';
import 'package:cinemawala/schedule/select_scenes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils.dart';

class AddSchedule extends StatefulWidget {
  final Project project;
  final Map<String, dynamic> schedule;

  const AddSchedule({Key key, this.project, this.schedule}) : super(key: key);

  @override
  _AddScheduleState createState() =>
      _AddScheduleState(this.project, this.schedule);
}

class _AddScheduleState extends State<AddSchedule> {
  final Project project;
  Map<String, dynamic> schedule;

  _AddScheduleState(this.project, this.schedule);

  Color background, background1, color;
  bool loading = true, edit = false;
  List<Scene> selectedScenes = [];
  Set<Actor> selectedArtists = {};
  Set<Prop> selectedProps = {};
  Set<Location> selectedLocations = {};
  Set<Costume> selectedCostumes = {};

  var bottomSheetHeadingStyle =
      TextStyle(fontWeight: FontWeight.bold, fontSize: 16);

  @override
  void initState() {
    schedule['scenes'].forEach((s) {
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
          edit ? "Edit Schedule" : "Add Schedule",
          style: TextStyle(color: background1),
        ),
        actions: [
          FlatButton.icon(
            onPressed: () async {
              if (edit) {
                editSchedule();
              } else {
                addSchedule();
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
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
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
                    children: <Widget>[
                          InkWell(
                            onTap: () async {
                              var selected = await Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                          pageBuilder: (_, __, ___) =>
                                              SelectScenes(
                                                project: project,
                                                selectedScenes: selectedScenes,
                                              ),
                                          opaque: false)) ??
                                  null;

                              if (selected != null) {
                                schedule['scenes'] = selected;

                                selectedScenes = [];
                                selectedArtists = {};
                                selectedProps = {};
                                selectedLocations = {};
                                selectedCostumes = {};

                                selected.forEach((s) {
                                  Scene scene = Utils.scenesMap[s];
                                  selectedScenes.add(scene);
                                  scene.artists.forEach((a) {
                                    selectedArtists.add(Utils.artistsMap[a]);
                                  });
                                  for (var i in scene.costumes) {
                                    for (var j in i['costumes']) {
                                      selectedCostumes
                                          .add(Utils.costumesMap[j]);
                                    }
                                  }
                                  scene.props.forEach((p) {
                                    selectedProps.add(Utils.propsMap[p]);
                                  });
                                  selectedLocations
                                      .add(Utils.locationsMap[scene.location]);
                                });
                                setState(() {});
                              }
                            },
                            child: Container(
                              margin: EdgeInsets.all(2),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(300),
                              ),
                              child: Text('+ Add Scene'),
                            ),
                          ),
                        ] +
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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                      '${selectedScenes[i].titles['English']}'),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  InkWell(
                                      onTap: () {
                                        selectedScenes.removeAt(i);

                                        schedule['scenes'] = [];
                                        selectedArtists = {};
                                        selectedProps = {};
                                        selectedLocations = {};
                                        selectedCostumes = {};
                                        selectedScenes.forEach((scene) {
                                          schedule['scenes'].add(scene.id);
                                          scene.artists.forEach((a) {
                                            selectedArtists
                                                .add(Utils.artistsMap[a]);
                                          });
                                          for (var i in scene.costumes) {
                                            for (var j in i['costumes']) {
                                              selectedCostumes
                                                  .add(Utils.costumesMap[j]);
                                            }
                                          }
                                          scene.props.forEach((p) {
                                            selectedProps
                                                .add(Utils.propsMap[p]);
                                          });
                                          selectedLocations.add(Utils
                                              .locationsMap[scene.location]);
                                        });
                                        setState(() {});
                                      },
                                      child: Container(
                                          child: Icon(
                                        Icons.cancel_outlined,
                                        color: Colors.red,
                                        size: 18,
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
                  child: selectedArtists.length == 0
                      ? Text('No Artists')
                      : Wrap(
                          direction: Axis.horizontal,
                          children: List<Widget>.generate(
                              selectedArtists.length, (i) {
                            return InkWell(
                              onLongPress: () {
                                Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                        pageBuilder: (_, __, ___) => ActorPopUp(
                                              actor:
                                                  selectedArtists.elementAt(i),
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
                  child: selectedCostumes.length == 0
                      ? Text('No Costumes')
                      : Wrap(
                          direction: Axis.horizontal,
                          children: List<Widget>.generate(
                              selectedCostumes.length, (i) {
                            return InkWell(
                              onLongPress: () {
                                Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                        pageBuilder: (_, __, ___) =>
                                            CostumesPage(
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
                  child: selectedProps.length == 0
                      ? Text('No Props')
                      : Wrap(
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
          )),
    );
  }

  addSchedule() async {
    Utils.showLoadingDialog(context, 'Adding Schedule');

    var back = false;

    try {
      var resp = await http.post(Utils.ADD_SCHEDULE,
          body: jsonEncode(schedule),
          headers: {"Content-Type": "application/json"});
      var r = jsonDecode(resp.body);
      Navigator.pop(context);
      if (resp.statusCode == 200) {
        if (r['status'] == 'success') {
          await Utils.showSuccessDialog(
              context,
              'Schedule Added',
              'Schedule has been added successfully.',
              Colors.green,
              background, () {
            Navigator.pop(context);
          });
        } else {
          await Utils.showErrorDialog(context, 'Unsuccessful', '${r['msg']}');
        }
      } else {
        await Utils.showErrorDialog(context, 'Something went wrong.',
            'Please try again after sometime.');
      }
      setState(() {
        loading = false;
      });
    } catch (e) {
      // debugPrint(e);
      Navigator.pop(context);
      await Utils.showErrorDialog(
          context, 'Something went wrong.', 'Please try again after sometime.');
    }
    Navigator.pop(context, back);
  }

  editSchedule() async {
    Utils.showLoadingDialog(context, 'Editing Schedule');

    var back = false;

    try {
      var resp = await http.post(Utils.EDIT_SCHEDULE,
          body: jsonEncode(schedule),
          headers: {"Content-Type": "application/json"});
      // // debugPrint(resp.body);
      var r = jsonDecode(resp.body);
      Navigator.pop(context);
      if (resp.statusCode == 200) {
        if (r['status'] == 'success') {
          back = true;
          await Utils.showSuccessDialog(
              context,
              'Schedule Edited',
              'Schedule has been edited successfully.',
              Colors.green,
              background, () {
            Navigator.pop(context);
          });
        } else {
          await Utils.showErrorDialog(context, 'Unsuccessful', '${r['msg']}');
        }
      } else {
        await Utils.showErrorDialog(context, 'Something went wrong.',
            'Please try again after sometime.');
      }
      setState(() {
        loading = false;
      });
    } catch (e) {
      // debugPrint(e);
      Navigator.pop(context);
      await Utils.showErrorDialog(
          context, 'Something went wrong.', 'Please try again after sometime.');
    }
    Navigator.pop(context, back);
  }
}
