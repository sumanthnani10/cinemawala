import 'dart:convert';

import 'package:cinemawala/artists/actor.dart';
import 'package:cinemawala/costumes/costume.dart';
import 'package:cinemawala/costumes/costume_page.dart';
import 'package:cinemawala/locations/location.dart';
import 'package:cinemawala/projects/project.dart';
import 'package:cinemawala/props/prop.dart';
import 'package:cinemawala/props/prop_page.dart';
import 'package:cinemawala/scenes/add_scene.dart';
import 'package:cinemawala/scenes/scene.dart';
import 'package:cinemawala/schedule/select_scenes.dart';
import 'package:cinemawala/schedule/select_schedule.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils.dart';
import 'schedule.dart';

class AddSchedule extends StatefulWidget {
  final Project project;
  final Map<dynamic, dynamic> schedule;
  final bool edit;

  const AddSchedule(
      {Key key, @required this.project, @required this.schedule, this.edit})
      : super(key: key);

  @override
  _AddScheduleState createState() =>
      _AddScheduleState(this.project, this.schedule, this.edit);
}

class _AddScheduleState extends State<AddSchedule> {
  Project project;
  Map<dynamic, dynamic> schedule;

  Scene selectedScene;

  _AddScheduleState(this.project, this.schedule, this.edit);

  Color background, background1, color;
  bool loading = true;
  bool edit;
  List<String> weeksDays = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];
  List<Scene> selectedScenes = [];
  Set<Actor> selectedArtists = {};
  Set<Prop> selectedProps = {};
  Set<Location> selectedLocations = {};
  List<Scene> editScene = [];//assigned on 8 june
  Set<Costume> selectedCostumes = {};
  Map<dynamic, dynamic> artistTimings = {},
      addlTimings = {},
      callSheetTimings = {},
      sfxTimings = {},
      vfxTimings = {};
  DateTime selectedDate;
  int selectedSceneIndex = 0;

  var bottomSheetHeadingStyle =
      TextStyle(fontWeight: FontWeight.bold, fontSize: 16);
  var bottomSheetSubheadingStyle =
      TextStyle(fontWeight: FontWeight.bold, fontSize: 12);
  var addlKeys = Utils.addlKeys;

  @override
  void initState() {
    edit = edit ?? false;
    selectedDate =
        DateTime(schedule['year'], schedule['month'], schedule['day']);
    artistTimings = schedule['artist_timings'];
    addlTimings = schedule['addl_timings'];
    callSheetTimings = schedule['call_timings'];
    sfxTimings = schedule['sfx_timings'];
    vfxTimings = schedule['vfx_timings'];
    schedule['scenes'].forEach((s) {
      Scene scene = Utils.scenesMap[s];
      editScene.add(scene);//added now
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

    selectedSceneIndex = 0;
    if (selectedScenes.length > 0) {
      selectedScene = selectedScenes.elementAt(selectedSceneIndex);
    }
    super.initState();
  }

  String oneDigitToTwo(int i) {
    if (i == 0) {
      return "12";
    }
    if (i > 9) {
      return "$i";
    } else {
      return "0$i";
    }
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
          edit ? "Edit Schedule" : "Add Schedule",
          style: TextStyle(color: background1),
        ),
        actions: [
          TextButton.icon(
            onPressed: () async {
              await Navigator.push(
                  context,
                  Utils.createRoute(
                      AddScene(project: project, scene: editScene[selectedSceneIndex].toJson()),
                      Utils.RTL));
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
          ),
          SizedBox(width: 4,),
          TextButton.icon(
            onPressed: () async {
              if (edit) {
                editSchedule();
              } else {
                addSchedule();
              }
            },
            label: Container(
              padding: kIsWeb ? EdgeInsets.only(right: 12):EdgeInsets.only(right: 2),
              child: Text(
                "Save",
                style: TextStyle(color: Colors.indigo),
                textAlign: TextAlign.right,
              ),
            ),
            icon: Icon(
              Icons.save,
              size: 18,
              color: Colors.indigo,
            ),
          ),
          SizedBox(width: 4,),
          /*TextButton.icon(
            onPressed: () async {
              if (edit) {
                editSchedule();
              } else {
                addSchedule();
              }
            },
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
          ),*/
        ],
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: Colors.black12),right: BorderSide(color: Colors.black12)),
          ),
          constraints: BoxConstraints(maxWidth: Utils.mobileWidth),
          child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(
                    height: 8,
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${selectedDate.day > 9 ? selectedDate.day : "0${selectedDate.day}"}-${selectedDate.month > 9 ? selectedDate.month : "0${selectedDate.month}"}-${selectedDate.year}, ${weeksDays[selectedDate.weekday - 1]}",
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  InkWell(
                      onTap: () async {
                        var r = await Navigator.push(
                                context,
                                Utils.createRoute(
                                    SelectScheduleNames(
                                      project: project,
                                      selectedScheduleName: schedule['name'],
                                    ),
                                    Utils.DTU)) ??
                            schedule['name'];
                        setState(() {
                          schedule['name'] = r;
                          project = Utils.project;
                        });
                      },
                      child: Text(
                        "Schedule: ${schedule['name']}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blue),
                      )),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Scenes',
                          style: bottomSheetHeadingStyle,
                        ),
                        TextButton(
                          onPressed: () async {
                            var selected = await Navigator.push(
                                    context,
                                    Utils.createRoute(
                                        SelectScenes(
                                          project: project,
                                          selectedScenes: selectedScenes,
                                        ),
                                        Utils.DTU)) ??
                                null;

                            if (selected != null) {
                              schedule['scenes'] = selected;

                              selectedScenes = [];
                              selectedArtists = {};
                              selectedProps = {};
                              selectedLocations = {};
                              selectedCostumes = {};
                              Map<dynamic, dynamic> timings = {},
                                  vTimings = {},
                                  sTimings = {},
                                  csTimings = {},
                                  aTimings = {};
                              // print(addlTimings);
                              // print(sfxTimings);
                              // print(vfxTimings);
                              // print(callSheetTimings);

                              selected.forEach((s) {
                                Scene scene = Utils.scenesMap[s];
                                selectedScenes.add(scene);
                                timings[s] = {};
                                aTimings[s] = {};
                                vTimings[s] = {};
                                sTimings[s] = {};
                                csTimings[s] = {};
                                scene.artists.forEach((a) {
                                  selectedArtists.add(Utils.artistsMap[a]);
                                  if (artistTimings.containsKey(s)) {
                                    if (artistTimings[s].containsKey(a)) {
                                      timings[s][a] = artistTimings[s][a];
                                    } else {
                                      timings[s][a] = {
                                        "start": [8, 0, 0],
                                        "end": [9, 0, 1],
                                      };
                                    }
                                  } else {
                                    timings[s][a] = {
                                      "start": [8, 0, 0],
                                      "end": [9, 0, 1],
                                    };
                                  }
                                });

                                if (vfxTimings.containsKey(s)) {
                                  vTimings[s] = vfxTimings[s];
                                } else {
                                  vTimings[s] = {
                                    "start": [8, 0, 0],
                                    "end": [9, 0, 1],
                                  };
                                }

                                if (sfxTimings.containsKey(s)) {
                                  sTimings[s] = sfxTimings[s];
                                } else {
                                  sTimings[s] = {
                                    "start": [8, 0, 0],
                                    "end": [9, 0, 1],
                                  };
                                }

                                if (callSheetTimings.containsKey(s)) {
                                  csTimings[s] = callSheetTimings[s];
                                } else {
                                  csTimings[s] = {
                                    "start": [8, 0, 0],
                                    "end": [9, 0, 1],
                                  };
                                }

                                scene.addlArtists.forEach((cat, value) {
                                  // print(cat);
                                  if (!Utils.additionalArtists[cat]['addable']) {
                                    // print('not addable');
                                    if (addlTimings.containsKey(s)) {
                                      if (addlTimings[s].containsKey(cat)) {
                                        aTimings[s][cat] = addlTimings[s][cat];
                                      } else {
                                        aTimings[s][cat] = {
                                          "start": [8, 0, 0],
                                          "end": [9, 0, 1],
                                        };
                                      }
                                    } else {
                                      if (!aTimings.containsKey(s))
                                        aTimings[s] = {};
                                      aTimings[s][cat] = {
                                        "start": [8, 0, 0],
                                        "end": [9, 0, 1],
                                      };
                                    }
                                  } else {
                                    // print('addable');
                                    if (addlTimings.containsKey(s)) {
                                      if (addlTimings[s].containsKey(cat)) {
                                        if (!aTimings[s].containsKey(cat))
                                          aTimings[s][cat] = {};
                                        for (var i in value) {
                                          if (addlTimings[s][cat]
                                              .containsKey(i['id'])) {
                                            aTimings[s][cat][i['id']] =
                                                addlTimings[s][cat][i['id']];
                                          } else {
                                            aTimings[s][cat][i['id']] = {
                                              "start": [8, 0, 0],
                                              "end": [9, 0, 1],
                                            };
                                          }
                                        }
                                      } else {
                                        if (!aTimings[s].containsKey(cat))
                                          aTimings[s][cat] = {};
                                        for (var i in value) {
                                          aTimings[s][cat][i['id']] = {
                                            "start": [8, 0, 0],
                                            "end": [9, 0, 1],
                                          };
                                        }
                                      }
                                    } else {
                                      if (!aTimings.containsKey(s))
                                        aTimings[s] = {};
                                      if (!aTimings[s].containsKey(cat))
                                        aTimings[s][cat] = {};
                                      for (var i in value) {
                                        aTimings[s][cat][i['id']] = {
                                          "start": [8, 0, 0],
                                          "end": [9, 0, 1],
                                        };
                                      }
                                    }
                                  }
                                });

                                for (var i in scene.costumes) {
                                  for (var j in i['costumes']) {
                                    selectedCostumes.add(Utils.costumesMap[j]);
                                  }
                                }
                                scene.props.forEach((p) {
                                  selectedProps.add(Utils.propsMap[p]);
                                });
                                selectedLocations
                                    .add(Utils.locationsMap[scene.location]);
                              });
                              schedule["artist_timings"] = timings;
                              artistTimings = timings;
                              addlTimings = aTimings;
                              schedule['addl_timings'] = aTimings;
                              sfxTimings = sTimings;
                              schedule['sfx_timings'] = sTimings;
                              vfxTimings = vTimings;
                              schedule['vfx_timings'] = vTimings;
                              callSheetTimings = csTimings;
                              schedule['call_timings'] = csTimings;

                              // print(addlTimings);
                              // print(sfxTimings);
                              // print(vfxTimings);
                              // print(callSheetTimings);

                              selectedSceneIndex = 0;
                              if (selectedScenes.length > 0) {
                                selectedScene =
                                    selectedScenes.elementAt(selectedSceneIndex);
                              }
                              setState(() {});
                            }
                          },
                          child: Text("+Add Scene"),
                        )
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      color: color.withOpacity(0.2),
                      width: MediaQuery.of(context).size.width,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(8, 0, 0, 8),
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: selectedScenes.length == 0
                              ? <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(8, 8, 0, 0),
                                    child: Text('No Scenes Added'),
                                  )
                                ]
                              : List<Widget>.generate(
                                  selectedScenes.length,
                                  (i) => InkWell(
                                    onTap: () async {
                                      selectedSceneIndex = i;
                                      selectedScene = selectedScenes.elementAt(i);
                                      setState(() {});
                                    },
                                    child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 8),
                                        decoration: BoxDecoration(
                                            border: Border(
                                                bottom: selectedSceneIndex == i
                                                    ? BorderSide(
                                                        color: color, width: 3)
                                                    : BorderSide(
                                                        color: background,
                                                        width: 3))),
                                        child: Row(
                                          children: [
                                            Text(
                                              '${selectedScenes[i].titles['en']}',
                                              style: selectedSceneIndex == i
                                                  ? TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: background1)
                                                  : TextStyle(color: background1),
                                            ),
                                            SizedBox(
                                              width: 4,
                                            ),
                                            InkWell(
                                                child: Icon(
                                                  Icons.clear,
                                                  size: 14,
                                                ),
                                                onTap: () async {
                                                  selectedScenes.removeAt(i);

                                                  schedule['scenes'] = [];
                                                  selectedArtists = {};
                                                  selectedProps = {};
                                                  selectedLocations = {};
                                                  selectedCostumes = {};
                                                  Map<dynamic, dynamic> timings =
                                                          {},
                                                      vTimings = {},
                                                      sTimings = {},
                                                      csTimings = {},
                                                      aTimings = {};

                                                  // print(addlTimings);
                                                  // print(sfxTimings);
                                                  // print(vfxTimings);
                                                  // print(callSheetTimings);

                                                  selectedScenes.forEach((scene) {
                                                    String s = scene.id;
                                                    schedule['scenes'].add(s);
                                                    timings[s] = {};
                                                    aTimings[s] = {};
                                                    vTimings[s] = {};
                                                    sTimings[s] = {};
                                                    csTimings[s] = {};
                                                    scene.artists.forEach((a) {
                                                      selectedArtists
                                                          .add(Utils.artistsMap[a]);
                                                      if (artistTimings
                                                          .containsKey(s)) {
                                                        if (artistTimings[s]
                                                            .containsKey(a)) {
                                                          timings[s][a] =
                                                              artistTimings[s][a];
                                                        } else {
                                                          timings[s][a] = {
                                                            "start": [8, 0, 0],
                                                            "end": [9, 0, 1],
                                                          };
                                                        }
                                                      } else {
                                                        timings[s][a] = {
                                                          "start": [8, 0, 0],
                                                          "end": [9, 0, 1],
                                                        };
                                                      }
                                                    });

                                                    if (vfxTimings.containsKey(s)) {
                                                      vTimings[s] = vfxTimings[s];
                                                    } else {
                                                      vTimings[s] = {
                                                        "start": [8, 0, 0],
                                                        "end": [9, 0, 1],
                                                      };
                                                    }

                                                    if (sfxTimings.containsKey(s)) {
                                                      sTimings[s] = sfxTimings[s];
                                                    } else {
                                                      sTimings[s] = {
                                                        "start": [8, 0, 0],
                                                        "end": [9, 0, 1],
                                                      };
                                                    }

                                                    if (callSheetTimings
                                                        .containsKey(s)) {
                                                      csTimings[s] =
                                                          callSheetTimings[s];
                                                    } else {
                                                      csTimings[s] = {
                                                        "start": [8, 0, 0],
                                                        "end": [9, 0, 1],
                                                      };
                                                    }

                                                    scene.addlArtists
                                                        .forEach((cat, value) {
                                                      // print(cat);
                                                      if (!Utils.additionalArtists[
                                                          cat]['addable']) {
                                                        // print('not addable');
                                                        if (addlTimings
                                                            .containsKey(s)) {
                                                          if (addlTimings[s]
                                                              .containsKey(cat)) {
                                                            aTimings[s][cat] =
                                                                addlTimings[s][cat];
                                                          } else {
                                                            aTimings[s][cat] = {
                                                              "start": [8, 0, 0],
                                                              "end": [9, 0, 1],
                                                            };
                                                          }
                                                        } else {
                                                          if (!aTimings.containsKey(
                                                              s)) aTimings[s] = {};
                                                          aTimings[s][cat] = {
                                                            "start": [8, 0, 0],
                                                            "end": [9, 0, 1],
                                                          };
                                                        }
                                                      } else {
                                                        // print('addable');
                                                        if (addlTimings
                                                            .containsKey(s)) {
                                                          if (addlTimings[s]
                                                              .containsKey(cat)) {
                                                            if (!aTimings[s]
                                                                .containsKey(cat))
                                                              aTimings[s][cat] = {};
                                                            for (var i in value) {
                                                              if (addlTimings[s]
                                                                      [cat]
                                                                  .containsKey(
                                                                      i['id'])) {
                                                                aTimings[s][cat]
                                                                        [i['id']] =
                                                                    addlTimings[s]
                                                                            [cat]
                                                                        [i['id']];
                                                              } else {
                                                                aTimings[s][cat]
                                                                    [i['id']] = {
                                                                  "start": [
                                                                    8,
                                                                    0,
                                                                    0
                                                                  ],
                                                                  "end": [9, 0, 1],
                                                                };
                                                              }
                                                            }
                                                          } else {
                                                            if (!aTimings[s]
                                                                .containsKey(cat))
                                                              aTimings[s][cat] = {};
                                                            for (var i in value) {
                                                              aTimings[s][cat]
                                                                  [i['id']] = {
                                                                "start": [8, 0, 0],
                                                                "end": [9, 0, 1],
                                                              };
                                                            }
                                                          }
                                                        } else {
                                                          if (!aTimings.containsKey(
                                                              s)) aTimings[s] = {};
                                                          if (!aTimings[s]
                                                              .containsKey(cat))
                                                            aTimings[s][cat] = {};
                                                          for (var i in value) {
                                                            aTimings[s][cat]
                                                                [i['id']] = {
                                                              "start": [8, 0, 0],
                                                              "end": [9, 0, 1],
                                                            };
                                                          }
                                                        }
                                                      }
                                                    });

                                                    for (var i in scene.costumes) {
                                                      for (var j in i['costumes']) {
                                                        selectedCostumes.add(
                                                            Utils.costumesMap[j]);
                                                      }
                                                    }
                                                    scene.props.forEach((p) {
                                                      selectedProps
                                                          .add(Utils.propsMap[p]);
                                                    });
                                                    selectedLocations.add(
                                                        Utils.locationsMap[
                                                            scene.location]);
                                                  });
                                                  schedule["artist_timings"] =
                                                      timings;
                                                  artistTimings = timings;
                                                  addlTimings = aTimings;
                                                  schedule['addl_timings'] =
                                                      aTimings;
                                                  sfxTimings = sTimings;
                                                  schedule['sfx_timings'] =
                                                      sTimings;
                                                  vfxTimings = vTimings;
                                                  schedule['vfx_timings'] =
                                                      vTimings;
                                                  callSheetTimings = csTimings;
                                                  schedule['call_timings'] =
                                                      csTimings;

                                                  // print(addlTimings);
                                                  // print(sfxTimings);
                                                  // print(vfxTimings);
                                                  // print(callSheetTimings);

                                                  selectedSceneIndex = 0;
                                                  if (selectedScenes.length > 0) {
                                                    selectedScene =
                                                        selectedScenes.elementAt(
                                                            selectedSceneIndex);
                                                  }

                                                  setState(() {});
                                                })
                                          ],
                                        )),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                  // CALL SHEET TIMING
                  if (selectedScenes.length > 0)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Call Sheet Timing"),
                          Builder(
                            builder: (context) {
                              var timings = callSheetTimings[selectedScene.id];
                              return Row(
                                children: [
                                  InkWell(
                                      onTap: () async {
                                        TimeOfDay pickedTime = await showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay.fromDateTime(
                                                DateTime(
                                                    selectedDate.year,
                                                    selectedDate.month,
                                                    selectedDate.day,
                                                    timings['start'][2] == 1
                                                        ? timings['start'][0] + 12
                                                        : timings['start'][0],
                                                    timings['start'][1])));
                                        if (pickedTime != null) {
                                          timings['start'][0] =
                                              pickedTime.hourOfPeriod;
                                          timings['start'][1] = pickedTime.minute;

                                          if (pickedTime.hourOfPeriod ==
                                              pickedTime.hour) {
                                            timings['start'][2] = 0;
                                          } else {
                                            timings['start'][2] = 1;
                                          }

                                          callSheetTimings[selectedScene.id] =
                                              timings;
                                          schedule['call_timings'] =
                                              callSheetTimings;

                                          setState(() {});
                                        }
                                      },
                                      child: Text(
                                        "${oneDigitToTwo(timings['start'][0])}:${timings['start'][1] == 0 ? "00" : oneDigitToTwo(timings['start'][1])} ${timings['start'][2] == 0 ? "AM" : "PM"}",
                                        style: TextStyle(color: Colors.indigo),
                                      )),
                                  Text(
                                    " to ",
                                    style: TextStyle(color: background1),
                                  ),
                                  InkWell(
                                      onTap: () async {
                                        Scene selectedScene = selectedScenes
                                            .elementAt(selectedSceneIndex);
                                        TimeOfDay pickedTime = await showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay.fromDateTime(
                                                DateTime(
                                                    selectedDate.year,
                                                    selectedDate.month,
                                                    selectedDate.day,
                                                    timings['end'][2] == 1
                                                        ? timings['end'][0] + 12
                                                        : timings['end'][0],
                                                    timings['end'][1])));
                                        if (pickedTime != null) {
                                          timings['end'][0] =
                                              pickedTime.hourOfPeriod;
                                          timings['end'][1] = pickedTime.minute;

                                          if (pickedTime.hourOfPeriod ==
                                              pickedTime.hour) {
                                            timings['end'][2] = 0;
                                          } else {
                                            timings['end'][2] = 1;
                                          }

                                          callSheetTimings[selectedScene.id] =
                                              timings;
                                          schedule['call_timings'] =
                                              callSheetTimings;

                                          setState(() {});
                                        }
                                      },
                                      child: Text(
                                        "${oneDigitToTwo(timings['end'][0])}:${timings['end'][1] == 0 ? "00" : oneDigitToTwo(timings['end'][1])} ${timings['end'][2] == 0 ? "AM" : "PM"}",
                                        style: TextStyle(color: Colors.indigo),
                                      )),
                                ],
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  Divider(
                    thickness: 2,
                  ),

                  if (selectedScenes.length > 0)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Spacer(),
                          Text(
                            selectedScene.completed ? "From" : "On Loc",
                            style: TextStyle(
                                fontSize: 14,
                                decoration: TextDecoration.underline),
                          ),
                          SizedBox(
                            width: selectedScene.completed ? 64 : 18,
                          ),
                          Text(
                            selectedScene.completed ? "To" : "On Set",
                            style: TextStyle(
                                fontSize: 14, decoration: TextDecoration.underline),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                        ],
                      ),
                    ),
                  // ARTISTS
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Artists",
                          style: bottomSheetHeadingStyle,
                        )),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: selectedArtists.length == 0
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('No Artists'),
                          )
                        : Column(
                            children: List<Widget>.generate(
                                selectedScenes[selectedSceneIndex].artists.length,
                                (j) {
                              Scene selectedScene =
                                  selectedScenes[selectedSceneIndex];
                              Actor artist =
                                  Utils.artistsMap[selectedScene.artists[j]];
                              var timings = artistTimings[selectedScene.id]
                                  [selectedScene.artists[j]];
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("${artist.names['en']}"),
                                    Row(
                                      children: [
                                        InkWell(
                                            onTap: () async {
                                              TimeOfDay pickedTime =
                                                  await showTimePicker(
                                                      context: context,
                                                      initialTime: TimeOfDay
                                                          .fromDateTime(DateTime(
                                                              selectedDate.year,
                                                              selectedDate.month,
                                                              selectedDate.day,
                                                              timings['start'][2] ==
                                                                      1
                                                                  ? timings['start']
                                                                          [0] +
                                                                      12
                                                                  : timings['start']
                                                                      [0],
                                                              timings['start']
                                                                  [1])));
                                              if (pickedTime != null) {
                                                timings['start'][0] =
                                                    pickedTime.hourOfPeriod;
                                                timings['start'][1] =
                                                    pickedTime.minute;

                                                if (pickedTime.hourOfPeriod ==
                                                    pickedTime.hour) {
                                                  timings['start'][2] = 0;
                                                } else {
                                                  timings['start'][2] = 1;
                                                }

                                                artistTimings[selectedScene.id]
                                                        [selectedScene.artists[j]] =
                                                    timings;
                                                schedule['artist_timings'] =
                                                    artistTimings;

                                                setState(() {});
                                              }
                                            },
                                            child: Text(
                                              "${oneDigitToTwo(timings['start'][0])}:${timings['start'][1] == 0 ? "00" : oneDigitToTwo(timings['start'][1])} ${timings['start'][2] == 0 ? "AM" : "PM"}",
                                              style:
                                                  TextStyle(color: Colors.indigo),
                                            )),
                                        Text(
                                          "    ",
                                          style: TextStyle(color: background1),
                                        ),
                                        InkWell(
                                            onTap: () async {
                                              TimeOfDay pickedTime =
                                                  await showTimePicker(
                                                      context: context,
                                                      initialTime: TimeOfDay
                                                          .fromDateTime(DateTime(
                                                              selectedDate.year,
                                                              selectedDate.month,
                                                              selectedDate.day,
                                                              timings['end']
                                                                          [2] ==
                                                                      1
                                                                  ? timings['end']
                                                                          [0] +
                                                                      12
                                                                  : timings['end']
                                                                      [0],
                                                              timings['end'][1])));
                                              if (pickedTime != null) {
                                                timings['end'][0] =
                                                    pickedTime.hourOfPeriod;
                                                timings['end'][1] =
                                                    pickedTime.minute;

                                                if (pickedTime.hourOfPeriod ==
                                                    pickedTime.hour) {
                                                  timings['end'][2] = 0;
                                                } else {
                                                  timings['end'][2] = 1;
                                                }

                                                artistTimings[selectedScene.id]
                                                        [selectedScene.artists[j]] =
                                                    timings;
                                                schedule['artist_timings'] =
                                                    artistTimings;

                                                setState(() {});
                                              }
                                            },
                                            child: Text(
                                              "${oneDigitToTwo(timings['end'][0])}:${timings['end'][1] == 0 ? "00" : oneDigitToTwo(timings['end'][1])} ${timings['end'][2] == 0 ? "AM" : "PM"}",
                                              style:
                                                  TextStyle(color: Colors.indigo),
                                            )),
                                      ],
                                    )
                                  ],
                                ),
                              );
                            }),
                          ),
                  ),
                  Divider(
                    thickness: 2,
                  ),
                  // ADDITIONAL ARTISTS
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Additional Artists",
                          style: bottomSheetHeadingStyle,
                        )),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: selectedScenes.length == 0
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('No Additional Artists'),
                          )
                        : Column(
                            children:
                                List<Widget>.generate(addlKeys.length, (keyj) {
                              var key = addlKeys[keyj];
                              if (!Utils.additionalArtists[key]['addable']) {
                                var artist = {"Name": '$key'};
                                var timings = addlTimings[selectedScene.id][key];
                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "${artist['Name']}",
                                            style: bottomSheetSubheadingStyle,
                                          ),
                                          Row(
                                            children: [
                                              InkWell(
                                                  onTap: () async {
                                                    TimeOfDay pickedTime = await showTimePicker(
                                                        context: context,
                                                        initialTime: TimeOfDay
                                                            .fromDateTime(DateTime(
                                                                selectedDate.year,
                                                                selectedDate.month,
                                                                selectedDate.day,
                                                                timings['start']
                                                                            [2] ==
                                                                        1
                                                                    ? timings['start']
                                                                            [0] +
                                                                        12
                                                                    : timings[
                                                                        'start'][0],
                                                                timings['start']
                                                                    [1])));
                                                    if (pickedTime != null) {
                                                      timings['start'][0] =
                                                          pickedTime.hourOfPeriod;
                                                      timings['start'][1] =
                                                          pickedTime.minute;

                                                      if (pickedTime.hourOfPeriod ==
                                                          pickedTime.hour) {
                                                        timings['start'][2] = 0;
                                                      } else {
                                                        timings['start'][2] = 1;
                                                      }

                                                      addlTimings[selectedScene.id]
                                                          [key] = timings;
                                                      schedule['addl_timings'] =
                                                          addlTimings;

                                                      setState(() {});
                                                    }
                                                  },
                                                  child: Text(
                                                    "${oneDigitToTwo(timings['start'][0])}:${timings['start'][1] == 0 ? "00" : oneDigitToTwo(timings['start'][1])} ${timings['start'][2] == 0 ? "AM" : "PM"}",
                                                    style: TextStyle(
                                                        color: Colors.indigo),
                                                  )),
                                              Text(
                                                "    ",
                                                style:
                                                    TextStyle(color: background1),
                                              ),
                                              InkWell(
                                                  onTap: () async {
                                                    TimeOfDay pickedTime =
                                                        await showTimePicker(
                                                            context: context,
                                                            initialTime: TimeOfDay
                                                                .fromDateTime(DateTime(
                                                                    selectedDate
                                                                        .year,
                                                                    selectedDate
                                                                        .month,
                                                                    selectedDate
                                                                        .day,
                                                                    timings['end'][
                                                                                2] ==
                                                                            1
                                                                        ? timings['end']
                                                                                [
                                                                                0] +
                                                                            12
                                                                        : timings[
                                                                                'end']
                                                                            [0],
                                                                    timings['end']
                                                                        [1])));
                                                    if (pickedTime != null) {
                                                      timings['end'][0] =
                                                          pickedTime.hourOfPeriod;
                                                      timings['end'][1] =
                                                          pickedTime.minute;

                                                      if (pickedTime.hourOfPeriod ==
                                                          pickedTime.hour) {
                                                        timings['end'][2] = 0;
                                                      } else {
                                                        timings['end'][2] = 1;
                                                      }

                                                      addlTimings[selectedScene.id]
                                                          [key] = timings;
                                                      schedule['addl_timings'] =
                                                          addlTimings;

                                                      setState(() {});
                                                    }
                                                  },
                                                  child: Text(
                                                    "${oneDigitToTwo(timings['end'][0])}:${timings['end'][1] == 0 ? "00" : oneDigitToTwo(timings['end'][1])} ${timings['end'][2] == 0 ? "AM" : "PM"}",
                                                    style: TextStyle(
                                                        color: Colors.indigo),
                                                  )),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    if (keyj + 1 != addlKeys.length)
                                      Divider(
                                        thickness: 1,
                                      ),
                                  ],
                                );
                              } else {
                                return selectedScene.addlArtists['$key'].length == 0
                                    ? Container()
                                    : Column(
                                        children: <Widget>[
                                              Text(
                                                "$key",
                                                style: bottomSheetSubheadingStyle,
                                              )
                                            ] +
                                            List<Widget>.generate(
                                                selectedScene.addlArtists['$key']
                                                    .length, (ind) {
                                              var artist = selectedScene
                                                  .addlArtists['$key'][ind];
                                              var timings =
                                                  addlTimings[selectedScene.id]
                                                      ["$key"][artist['id']];
                                              return Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text("${artist['Name']}"),
                                                    Row(
                                                      children: [
                                                        InkWell(
                                                            onTap: () async {
                                                              TimeOfDay pickedTime = await showTimePicker(
                                                                  context: context,
                                                                  initialTime: TimeOfDay.fromDateTime(DateTime(
                                                                      selectedDate
                                                                          .year,
                                                                      selectedDate
                                                                          .month,
                                                                      selectedDate
                                                                          .day,
                                                                      timings['start']
                                                                                  [
                                                                                  2] ==
                                                                              1
                                                                          ? timings['start']
                                                                                  [
                                                                                  0] +
                                                                              12
                                                                          : timings[
                                                                                  'start']
                                                                              [0],
                                                                      timings['start']
                                                                          [1])));
                                                              if (pickedTime !=
                                                                  null) {
                                                                timings['start']
                                                                        [0] =
                                                                    pickedTime
                                                                        .hourOfPeriod;
                                                                timings['start']
                                                                        [1] =
                                                                    pickedTime
                                                                        .minute;

                                                                if (pickedTime
                                                                        .hourOfPeriod ==
                                                                    pickedTime
                                                                        .hour) {
                                                                  timings['start']
                                                                      [2] = 0;
                                                                } else {
                                                                  timings['start']
                                                                      [2] = 1;
                                                                }

                                                                addlTimings[selectedScene
                                                                                .id]
                                                                            [key]
                                                                        [
                                                                        artist[
                                                                            'id']] =
                                                                    timings;
                                                                schedule[
                                                                        'addl_timings'] =
                                                                    addlTimings;

                                                                setState(() {});
                                                              }
                                                            },
                                                            child: Text(
                                                              "${oneDigitToTwo(timings['start'][0])}:${timings['start'][1] == 0 ? "00" : oneDigitToTwo(timings['start'][1])} ${timings['start'][2] == 0 ? "AM" : "PM"}",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .indigo),
                                                            )),
                                                        Text(
                                                          "    ",
                                                          style: TextStyle(
                                                              color: background1),
                                                        ),
                                                        InkWell(
                                                            onTap: () async {
                                                              TimeOfDay pickedTime = await showTimePicker(
                                                                  context: context,
                                                                  initialTime: TimeOfDay.fromDateTime(DateTime(
                                                                      selectedDate
                                                                          .year,
                                                                      selectedDate
                                                                          .month,
                                                                      selectedDate
                                                                          .day,
                                                                      timings['end']
                                                                                  [
                                                                                  2] ==
                                                                              1
                                                                          ? timings['end']
                                                                                  [
                                                                                  0] +
                                                                              12
                                                                          : timings[
                                                                                  'end']
                                                                              [0],
                                                                      timings['end']
                                                                          [1])));
                                                              if (pickedTime !=
                                                                  null) {
                                                                timings['end'][0] =
                                                                    pickedTime
                                                                        .hourOfPeriod;
                                                                timings['end'][1] =
                                                                    pickedTime
                                                                        .minute;

                                                                if (pickedTime
                                                                        .hourOfPeriod ==
                                                                    pickedTime
                                                                        .hour) {
                                                                  timings['end']
                                                                      [2] = 0;
                                                                } else {
                                                                  timings['end']
                                                                      [2] = 1;
                                                                }

                                                                addlTimings[selectedScene
                                                                                .id]
                                                                            [key]
                                                                        [
                                                                        artist[
                                                                            'id']] =
                                                                    timings;
                                                                schedule[
                                                                        'addl_timings'] =
                                                                    addlTimings;

                                                                setState(() {});
                                                              }
                                                            },
                                                            child: Text(
                                                              "${oneDigitToTwo(timings['end'][0])}:${timings['end'][1] == 0 ? "00" : oneDigitToTwo(timings['end'][1])} ${timings['end'][2] == 0 ? "AM" : "PM"}",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .indigo),
                                                            )),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              );
                                            }) +
                                            [
                                              if (keyj + 1 != addlKeys.length)
                                                Divider(
                                                  thickness: 1,
                                                ),
                                            ],
                                      );
                              }
                            }),
                          ),
                  ),
                  Divider(
                    thickness: 2,
                  ),
                  // VFX TIMING
                  if (selectedScenes.length > 0 && selectedScene.vfx.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("VFX Timing"),
                          Builder(
                            builder: (context) {
                              var timings = vfxTimings[selectedScene.id];
                              return Row(
                                children: [
                                  InkWell(
                                      onTap: () async {
                                        TimeOfDay pickedTime = await showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay.fromDateTime(
                                                DateTime(
                                                    selectedDate.year,
                                                    selectedDate.month,
                                                    selectedDate.day,
                                                    timings['start'][2] == 1
                                                        ? timings['start'][0] + 12
                                                        : timings['start'][0],
                                                    timings['start'][1])));
                                        if (pickedTime != null) {
                                          timings['start'][0] =
                                              pickedTime.hourOfPeriod;
                                          timings['start'][1] = pickedTime.minute;

                                          if (pickedTime.hourOfPeriod ==
                                              pickedTime.hour) {
                                            timings['start'][2] = 0;
                                          } else {
                                            timings['start'][2] = 1;
                                          }

                                          vfxTimings[selectedScene.id] = timings;
                                          schedule['vfx_timings'] = vfxTimings;

                                          setState(() {});
                                        }
                                      },
                                      child: Text(
                                        "${oneDigitToTwo(timings['start'][0])}:${timings['start'][1] == 0 ? "00" : oneDigitToTwo(timings['start'][1])} ${timings['start'][2] == 0 ? "AM" : "PM"}",
                                        style: TextStyle(color: Colors.indigo),
                                      )),
                                  Text(
                                    "    ",
                                    style: TextStyle(color: background1),
                                  ),
                                  InkWell(
                                      onTap: () async {
                                        TimeOfDay pickedTime = await showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay.fromDateTime(
                                                DateTime(
                                                    selectedDate.year,
                                                    selectedDate.month,
                                                    selectedDate.day,
                                                    timings['end'][2] == 1
                                                        ? timings['end'][0] + 12
                                                        : timings['end'][0],
                                                    timings['end'][1])));
                                        if (pickedTime != null) {
                                          timings['end'][0] =
                                              pickedTime.hourOfPeriod;
                                          timings['end'][1] = pickedTime.minute;

                                          if (pickedTime.hourOfPeriod ==
                                              pickedTime.hour) {
                                            timings['end'][2] = 0;
                                          } else {
                                            timings['end'][2] = 1;
                                          }

                                          vfxTimings[selectedScene.id] = timings;
                                          schedule['vfx_timings'] = vfxTimings;

                                          setState(() {});
                                        }
                                      },
                                      child: Text(
                                        "${oneDigitToTwo(timings['end'][0])}:${timings['end'][1] == 0 ? "00" : oneDigitToTwo(timings['end'][1])} ${timings['end'][2] == 0 ? "AM" : "PM"}",
                                        style: TextStyle(color: Colors.indigo),
                                      )),
                                ],
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  // SFX TIMING
                  if (selectedScenes.length > 0 && selectedScene.vfx.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("SFX Timing"),
                          Builder(
                            builder: (context) {
                              var timings = sfxTimings[selectedScene.id];
                              return Row(
                                children: [
                                  InkWell(
                                      onTap: () async {
                                        TimeOfDay pickedTime = await showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay.fromDateTime(
                                                DateTime(
                                                    selectedDate.year,
                                                    selectedDate.month,
                                                    selectedDate.day,
                                                    timings['start'][2] == 1
                                                        ? timings['start'][0] + 12
                                                        : timings['start'][0],
                                                    timings['start'][1])));
                                        if (pickedTime != null) {
                                          timings['start'][0] =
                                              pickedTime.hourOfPeriod;
                                          timings['start'][1] = pickedTime.minute;

                                          if (pickedTime.hourOfPeriod ==
                                              pickedTime.hour) {
                                            timings['start'][2] = 0;
                                          } else {
                                            timings['start'][2] = 1;
                                          }

                                          sfxTimings[selectedScene.id] = timings;
                                          schedule['sfx_timings'] = sfxTimings;

                                          setState(() {});
                                        }
                                      },
                                      child: Text(
                                        "${oneDigitToTwo(timings['start'][0])}:${timings['start'][1] == 0 ? "00" : oneDigitToTwo(timings['start'][1])} ${timings['start'][2] == 0 ? "AM" : "PM"}",
                                        style: TextStyle(color: Colors.indigo),
                                      )),
                                  Text(
                                    "    ",
                                    style: TextStyle(color: background1),
                                  ),
                                  InkWell(
                                      onTap: () async {
                                        TimeOfDay pickedTime = await showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay.fromDateTime(
                                                DateTime(
                                                    selectedDate.year,
                                                    selectedDate.month,
                                                    selectedDate.day,
                                                    timings['end'][2] == 1
                                                        ? timings['end'][0] + 12
                                                        : timings['end'][0],
                                                    timings['end'][1])));
                                        if (pickedTime != null) {
                                          timings['end'][0] =
                                              pickedTime.hourOfPeriod;
                                          timings['end'][1] = pickedTime.minute;

                                          if (pickedTime.hourOfPeriod ==
                                              pickedTime.hour) {
                                            timings['end'][2] = 0;
                                          } else {
                                            timings['end'][2] = 1;
                                          }

                                          sfxTimings[selectedScene.id] = timings;
                                          schedule['sfx_timings'] = sfxTimings;

                                          setState(() {});
                                        }
                                      },
                                      child: Text(
                                        "${oneDigitToTwo(timings['end'][0])}:${timings['end'][1] == 0 ? "00" : oneDigitToTwo(timings['end'][1])} ${timings['end'][2] == 0 ? "AM" : "PM"}",
                                        style: TextStyle(color: Colors.indigo),
                                      )),
                                ],
                              );
                            },
                          )
                        ],
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
                                        Utils.createRoute(
                                            CostumesPage(
                                              costume:
                                                  selectedCostumes.elementAt(i),
                                              project: project,
                                            ),
                                            Utils.DTU));
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
                  Divider(
                    thickness: 2,
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
                                        Utils.createRoute(
                                            PropPage(
                                              prop: selectedProps.elementAt(i),
                                              project: project,
                                            ),
                                            Utils.DTU));
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
        ),
      ),
    );
  }

  addSchedule() async {
    Utils.showLoadingDialog(context, 'Adding Schedule');

    try {
      var resp = await http.post(Utils.ADD_SCHEDULE,
          body: jsonEncode(schedule),
          headers: {"Content-Type": "application/json"});
      var r = jsonDecode(resp.body);
      Navigator.pop(context);
      if (resp.statusCode == 200) {
        if (r['status'] == 'success') {
          Utils.schedulesMap[schedule['id']] = Schedule.fromJson(schedule);
          Utils.schedules = Utils.schedulesMap.values.toList();

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
    Navigator.pop(context);
  }

  editSchedule() async {
    Utils.showLoadingDialog(context, 'Editing Schedule');

    try {
      var resp = await http.post(Utils.EDIT_SCHEDULE,
          body: jsonEncode(schedule),
          headers: {"Content-Type": "application/json"});
      // // debugPrint(resp.body);
      var r = jsonDecode(resp.body);
      Navigator.pop(context);
      if (resp.statusCode == 200) {
        if (r['status'] == 'success') {
          Utils.schedulesMap[schedule['id']] = Schedule.fromJson(schedule);
          Utils.schedules = Utils.schedulesMap.values.toList();

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
    Navigator.pop(context);
  }
}
/*Padding(
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
                                Map<dynamic, dynamic> timings = {};

                                selected.forEach((s) {
                                  Scene scene = Utils.scenesMap[s];
                                  selectedScenes.add(scene);
                                  timings[s] = {};
                                  scene.artists.forEach((a) {
                                    selectedArtists.add(Utils.artistsMap[a]);
                                    if (artistTimings.containsKey(s)) {
                                      if (artistTimings[s].containsKey(a)) {
                                        timings[s][a] = artistTimings[s][a];
                                      } else {
                                        timings[s][a] = {
                                          "start": [8, 0, 0],
                                          "end": [9, 0, 1],
                                        };
                                      }
                                    } else {
                                      timings[s][a] = {
                                        "start": [8, 0, 0],
                                        "end": [9, 0, 1],
                                      };
                                    }
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
                                schedule["artist_timings"] = timings;
                                artistTimings = timings;

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
                                        Map<dynamic, dynamic> timings = {};

                                        selectedScenes.forEach((scene) {
                                          schedule['scenes'].add(scene.id);
                                          var s = scene.id;
                                          timings[s] = {};
                                          scene.artists.forEach((a) {
                                            selectedArtists
                                                .add(Utils.artistsMap[a]);
                                            if (artistTimings.containsKey(s)) {
                                              if (artistTimings[s]
                                                  .containsKey(a)) {
                                                timings[s][a] =
                                                    artistTimings[s][a];
                                              } else {
                                                timings[s][a] = {
                                                  "start": [8, 0, 0],
                                                  "end": [9, 0, 1],
                                                };
                                              }
                                            } else {
                                              timings[s][a] = {
                                                "start": [8, 0, 0],
                                                "end": [9, 0, 1],
                                              };
                                            }
                                          });
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
                                        schedule["artist_timings"] = timings;
                                        artistTimings = timings;
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
              */

/*schedule['scenes'] = [];
                                              selectedArtists = {};
                                              selectedProps = {};
                                              selectedLocations = {};
                                              selectedCostumes = {};
                                              Map<dynamic, dynamic> timings = {};

                                              selectedScenes.forEach((scene) {
                                                schedule['scenes']
                                                    .add(scene.id);
                                                var s = scene.id;
                                                timings[s] = {};
                                                scene.artists.forEach((a) {
                                                  selectedArtists
                                                      .add(Utils.artistsMap[a]);
                                                  if (artistTimings
                                                      .containsKey(s)) {
                                                    if (artistTimings[s]
                                                        .containsKey(a)) {
                                                      timings[s][a] =
                                                          artistTimings[s][a];
                                                    } else {
                                                      timings[s][a] = {
                                                        "start": [8, 0, 0],
                                                        "end": [9, 0, 1],
                                                      };
                                                    }
                                                  } else {
                                                    timings[s][a] = {
                                                      "start": [8, 0, 0],
                                                      "end": [9, 0, 1],
                                                    };
                                                  }
                                                });
                                                scene.artists.forEach((a) {
                                                  selectedArtists
                                                      .add(Utils.artistsMap[a]);
                                                });
                                                for (var i in scene.costumes) {
                                                  for (var j in i['costumes']) {
                                                    selectedCostumes.add(
                                                        Utils.costumesMap[j]);
                                                  }
                                                }
                                                scene.props.forEach((p) {
                                                  selectedProps
                                                      .add(Utils.propsMap[p]);
                                                });
                                                selectedLocations.add(
                                                    Utils.locationsMap[
                                                        scene.location]);
                                              });
                                              schedule["artist_timings"] =
                                                  timings;
                                              artistTimings = timings;

                                              setState(() {});*/