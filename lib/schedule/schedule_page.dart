import 'dart:convert';

import 'package:cinemawala/artists/actor.dart';
import 'package:cinemawala/costumes/costume.dart';
import 'package:cinemawala/costumes/costume_page.dart';
import 'package:cinemawala/locations/location.dart';
import 'package:cinemawala/pdf_generator.dart';
import 'package:cinemawala/projects/project.dart';
import 'package:cinemawala/props/prop.dart';
import 'package:cinemawala/props/prop_page.dart';
import 'package:cinemawala/scenes/scene.dart';
import 'package:cinemawala/scenes/scene_page.dart';
import 'package:cinemawala/schedule/add_schedule.dart';
import 'package:cinemawala/schedule/schedule.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils.dart';

class SchedulePage extends StatefulWidget {
  final Project project;
  final Schedule schedule;
  final Map<dynamic, Schedule> scheduless;
  final DateTime date;
  final String id;
  final int workingDay;
  final VoidCallback nextDate, prevDate, getAll;
  final bool isPopUp;

  const SchedulePage(
      {Key key,
        @required this.project,
        @required this.schedule,
        this.scheduless,
        @required this.date,
        @required this.id,
        @required this.getAll,
        @required this.nextDate,
        @required this.prevDate,
        @required this.workingDay,
        this.isPopUp})
      : super(key: key);

  @override
  _SchedulePageState createState() => _SchedulePageState(
    this.nextDate,
    this.prevDate,
    this.project,
    this.schedule,
    this.date,
    this.id,
    this.getAll,
    this.workingDay,
    this.isPopUp,
    this.scheduless,
  );
}

class _SchedulePageState extends State<SchedulePage>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  bool isPopUp;
  final String id;
  final Project project;
  Schedule schedule;
  Map<dynamic, Schedule> scheduless;
  final int workingDay;
  final DateTime date;
  final VoidCallback nextDate, prevDate, getAll;
  bool dayCrossed = false;

  _SchedulePageState(
      this.nextDate,
      this.prevDate,
      this.project,
      this.schedule,
      this.date,
      this.id,
      this.getAll,
      this.workingDay,
      this.isPopUp,
      this.scheduless);

  List<String> weeksDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  List<Scene> selectedScenes = [];
  Set<Actor> selectedArtists = {};
  Set<Costume> selectedCostumes = {};
  Actor selectedArtist;
  Map<dynamic, dynamic> artistTimings = {},
      addlTimings = {},
      callSheetTimings = {},
      sfxTimings = {},
      vfxTimings = {};
  List scheduleNames = [];
  bool shouldUpdate = false;
  bool showDates;
  List selectedScheduleIndex;
  Map<dynamic, List<dynamic>> test = {};
  List name = [];

  ScrollPhysics scroll = AlwaysScrollableScrollPhysics(),
      noScroll = NeverScrollableScrollPhysics();
  var bottomSheetHeadingStyle =
  TextStyle(fontWeight: FontWeight.bold, fontSize: 16);
  var bottomSheetSubheadingStyle =
  TextStyle(fontWeight: FontWeight.bold, fontSize: 12);
  var addlKeys = Utils.addlKeys;
  BorderSide selectedIndicator = BorderSide(width: 3),
      unselectedIndicator = BorderSide(width: 3);
  int selectedSceneIndex = 0;
  Scene selectedScene;
  Location sceneLoc;
  Color background, background1, color;

  Future<String> createAlertDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Select Actor"),
            content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(selectedArtists.length, (i) {
                  var setIterator = selectedArtists.elementAt(i);
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    child: TextButton(
                      onPressed: () async {
                        selectedArtist = selectedArtists.elementAt(i);
                        Navigator.of(context).pop();
                        Utils.showLoadingDialog(context, "Generating PDF");
                        var d =
                            "${date.day > 9 ? date.day : "0${date.day}"}-${date.month > 9 ? date.month : "0${date.month}"}-${date.year}, ${weeksDays[date.weekday - 1]}";
                        await PdfGenerator.artistCallSheet(
                          project,
                          context,
                          selectedScene,
                          schedule,
                          d,
                          "en",
                          selectedArtist,
                        );
                        Navigator.of(context).pop();
                      },
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text("${setIterator.names["en"]}"),
                      ),
                    ),
                  );
                })),
          );
        });
  }

  @override
  void initState() {
    isPopUp = isPopUp ?? true;
    setContent();
    selectedScheduleIndex = [];
    if (schedule != null)
      dayCrossed = DateTime(schedule.year, schedule.month, schedule.day)
          .isBefore(DateTime.now());
    showDates = false;
    super.initState();
    animationController = AnimationController(vsync: this);
    scheduleNames = project.schedules;
  }

  setContent() async {
    if (schedule != null) {
      addlTimings = schedule.additionalTimings;
      artistTimings = schedule.artistTimings;
      callSheetTimings = schedule.callSheetTimings;
      sfxTimings = schedule.sfxTimings;
      vfxTimings = schedule.vfxTimings;
      schedule.scenes.forEach((s) {
        Scene scene = Utils.scenesMap[s];
        selectedScenes.add(scene);
        scene.artists.forEach((a) {
          selectedArtists.add(Utils.artistsMap[a]);
        });
      });
      selectedScenes.sort((a, b) => a.titles['en'].compareTo(b.titles['en']));
      if (schedule.scenes.length != 0) {
        selectedScene = selectedScenes[0];
        selectedSceneIndex = 0;
        selectedCostumes.clear();
        for (var i in selectedScene.costumes) {
          for (var j in i['costumes']) {
            selectedCostumes.add(Utils.costumesMap[j]);
          }
        }
      } else {
        schedule = null;
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (shouldUpdate) {
        editSchedule();
      }
    });
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

  Widget widget2(scrollController, scheduless) {
    if (selectedScenes.length != 0) {
      selectedScene = selectedScenes[selectedSceneIndex];
      sceneLoc = Utils.locationsMap[selectedScene.location];
    }
    List<dynamic> schelist;
    test = {};
    if (schedule == null) {
      schelist = scheduless.keys.toList();
      for (int j = 0; j < schelist.length; j++) {
        Schedule check = scheduless[schelist[j]];
        if (!test.containsKey(check.name)) {
          test[check.name] = [];
        }
        DateTime dt = DateTime.parse(
            '${schelist[j].substring(0, 4)}-${schelist[j].substring(4, 6)}-${schelist[j].substring(6, 8)} 03:04:05');
        test[check.name].add(
            "WD: ${j + 1}   ${schelist[j].substring(6, 8)}-${schelist[j].substring(4, 6)}-${schelist[j].substring(0, 4)},  ${weeksDays[dt.weekday - 1]}");
      }
      for (int j = 0; j < scheduleNames.length; j++) {
        if (!test.containsKey(scheduleNames[j])) {
          test[scheduleNames[j]] = [];
        }
      }
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
              blurRadius: 4,
            ),
          ]),
      child: schedule != null
          ? NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (OverscrollIndicatorNotification overscroll) {
          overscroll.disallowGlow();
          return;
        },
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: scrollController,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(CupertinoIcons.back),
                          onPressed: () {},
                        ),
                        Text(
                          "${date.day > 9 ? date.day : "0${date.day}"}-${date.month > 9 ? date.month : "0${date.month}"}-${date.year}, ${weeksDays[date.weekday - 1]}",
                          style: TextStyle(fontSize: 18),
                        ),
                        IconButton(
                          icon: Icon(CupertinoIcons.forward),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    thickness: 2,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            'WD: $workingDay',
                            style: bottomSheetHeadingStyle,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () async {},
                          label: Text("Edit"),
                          icon: Icon(
                            Icons.edit,
                            size: 14,
                          ),
                        )
                      ],
                    ),
                  ),
                  Text(
                    "Schedule: ${schedule.name}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: background1),
                  ),
                  SizedBox(
                    height: 8,
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
                          children: List<Widget>.generate(
                            selectedScenes.length,
                                (i) => Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 8),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: selectedSceneIndex == i
                                            ? BorderSide(
                                            color: Colors.lightGreen,
                                            width: 3)
                                            : BorderSide(
                                            color: background,
                                            width: 3))),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.white,
                                      radius: 4,
                                    ),
                                    Text(
                                      '${selectedScenes[i].titles['en']}',
                                      style: selectedSceneIndex == i
                                          ? TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: background1)
                                          : TextStyle(color: background1),
                                    ),
                                  ],
                                )),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // CALL SHEET TIMING
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            //Text("Call Sheet Timing (${sceneLoc.location})"),
                            Text("Call Sheet Timing"),
                            Builder(
                              builder: (context) {
                                var timings =
                                callSheetTimings[selectedScene.id];
                                return Row(
                                  children: [
                                    InkWell(
                                        onTap: () async {},
                                        child: Text(
                                          "${oneDigitToTwo(timings['start'][0])}:${timings['start'][1] == 0 ? "00" : oneDigitToTwo(timings['start'][1])} ${timings['start'][2] == 0 ? "AM" : "PM"}",
                                          style: TextStyle(
                                              color: Colors.indigo),
                                        )),
                                    Text(
                                      " to ",
                                      style:
                                      TextStyle(color: background1),
                                    ),
                                    InkWell(
                                        onTap: () async {},
                                        child: Text(
                                          "${oneDigitToTwo(timings['end'][0])}:${timings['end'][1] == 0 ? "00" : oneDigitToTwo(timings['end'][1])} ${timings['end'][2] == 0 ? "AM" : "PM"}",
                                          style: TextStyle(
                                              color: Colors.indigo),
                                        )),
                                  ],
                                );
                              },
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 8.0, right: 8, bottom: 8),
                        child: Text(
                            "(${sceneLoc.location} @${sceneLoc.shootLocation})"),
                      ),
                    ],
                  ),
                  // Scene Status
                  if (project.role.permissions["scenes"]["add"] ||
                      project.role.permissions["scenes"]["edit"] ||
                      project.role.permissions["schedule"]["add"] ||
                      project.role.permissions["schedule"]["edit"])
                    Divider(
                      thickness: 2,
                      height: 1,
                    ),
                  if (project.role.permissions["schedule"]["edit"] &&
                      selectedScene.completedOn[0] == 0 &&
                      dayCrossed)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Scene Status",
                            style: bottomSheetHeadingStyle,
                          ),
                          Spacer(),
                          InkWell(
                            onTap: () async {
                              await updateSceneStatus(
                                  false, selectedScene.id);
                            },
                            child: Container(
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.deepOrange,
                                    child: Center(
                                        child: Icon(
                                          Icons.close_rounded,
                                          color: Colors.white,
                                        )),
                                  ),
                                  Text(
                                    "Not Done",
                                    style: TextStyle(
                                        color: Colors.deepOrangeAccent,
                                        fontSize: 8),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 24,
                          ),
                          InkWell(
                            onTap: () async {
                              await updateSceneStatus(
                                  true, selectedScene.id);
                            },
                            child: Container(
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.green,
                                    child: Center(
                                        child: Icon(
                                          Icons.done_rounded,
                                          color: Colors.white,
                                        )),
                                  ),
                                  Text(
                                    "Done",
                                    style: TextStyle(
                                        color: Colors.green, fontSize: 8),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 16,
                          )
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Spacer(),
                        Text(
                          selectedScene.completed ? "From" : "On Loc",
                          style: TextStyle(fontSize: 14, decoration: TextDecoration.underline),),
                        SizedBox(
                          width: selectedScene.completed ? 64 : 18,
                        ),
                        Text(
                          selectedScene.completed ? "To" : "On Set",
                          style: TextStyle(
                              fontSize: 14,
                              decoration: TextDecoration.underline),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                      ],
                    ),
                  ),
                  if (project.role.permissions["casting"]["view"])
                    Divider(
                      thickness: 2,
                      height: 1,
                    ),
                  // Artists
                  if (project.role.permissions["casting"]["view"])
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Artists",
                                style: bottomSheetHeadingStyle,
                              ),
                              Spacer(),
                              TextButton.icon(
                                onPressed: () async {
                                  createAlertDialog(context);
                                },
                                label: Text("Call Sheet"),
                                icon: Icon(Icons.picture_as_pdf_outlined,
                                    size: 14),
                              ),
                            ],
                          )),
                    ),
                  if (project.role.permissions["casting"]["view"])
                    Align(
                      alignment: Alignment.centerLeft,
                      child: selectedArtists.length == 0
                          ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('No Artists'),
                      )
                          : Column(
                        children: List<Widget>.generate(
                            selectedScene.artists.length, (j) {
                          Actor artist = Utils
                              .artistsMap[selectedScene.artists[j]];
                          if (artistTimings[selectedScene.id]
                          [selectedScene.artists[j]] ==
                              null) {
                            artistTimings[selectedScene.id]
                            [selectedScene.artists[j]] = {
                              "start": [8, 0, 0],
                              "end": [9, 0, 1]
                            };
                            schedule.artistTimings[selectedScene.id]
                            [selectedScene.artists[j]] = {
                              "start": [8, 0, 0],
                              "end": [9, 0, 1]
                            };
                            shouldUpdate = true;
                          }
                          var timings =
                          artistTimings[selectedScene.id]
                          [selectedScene.artists[j]];
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text("${artist.names['en']}"),
                                Row(
                                  children: [
                                    Text(
                                      "${oneDigitToTwo(timings['start'][0])}:${timings['start'][1] == 0 ? "00" : oneDigitToTwo(timings['start'][1])} ${timings['start'][2] == 0 ? "AM" : "PM"}",
                                      style: TextStyle(
                                          color: Colors.indigo),
                                    ),
                                    Text(
                                      "    ",
                                      style: TextStyle(
                                          color: background1),
                                    ),
                                    Text(
                                      "${oneDigitToTwo(timings['end'][0])}:${timings['end'][1] == 0 ? "00" : oneDigitToTwo(timings['end'][1])} ${timings['end'][2] == 0 ? "AM" : "PM"}",
                                      style: TextStyle(
                                          color: Colors.indigo),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  if (project.role.permissions["casting"]["view"])
                    Divider(
                      thickness: 2,
                    ),
                  // ADDITIONAL ARTISTS
                  if (project.role.permissions["casting"]["view"])
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Additional Artists",
                            style: bottomSheetHeadingStyle,
                          )),
                    ),
                  if (project.role.permissions["casting"]["view"])
                    Align(
                      alignment: Alignment.centerLeft,
                      child: selectedScenes.length == 0
                          ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('No Additional Artists'),
                      )
                          : Column(
                        children: List<Widget>.generate(
                            selectedScene.addlArtists.length,
                                (keyj) {
                              var key = addlKeys[keyj];
                              if (!Utils.additionalArtists[key]
                              ['addable']) {
                                var artist = {"Name": '$key'};
                                var timings =
                                addlTimings[selectedScene.id][key];
                                return Column(
                                  children: [
                                    Padding(
                                      padding:
                                      const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                        children: [
                                          Text(
                                            "${artist['Name']}",
                                            style:
                                            bottomSheetSubheadingStyle,
                                          ),
                                          Row(
                                            children: [
                                              InkWell(
                                                  onTap: () async {},
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
                                                  onTap: () async {},
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
                                    ),
                                    if (keyj + 1 != addlKeys.length)
                                      Divider(
                                        thickness: 1,
                                      ),
                                  ],
                                );
                              } else {
                                return selectedScene.addlArtists['$key']
                                    .length ==
                                    0
                                    ? Container()
                                    : Column(
                                  children: <Widget>[
                                    Text(
                                      "$key",
                                      style:
                                      bottomSheetSubheadingStyle,
                                    )
                                  ] +
                                      List<Widget>.generate(
                                          selectedScene
                                              .addlArtists['$key']
                                              .length, (ind) {
                                        var artist = selectedScene
                                            .addlArtists[
                                        '$key'][ind];
                                        if (addlTimings[
                                        selectedScene
                                            .id]["$key"]
                                        [artist['id']] ==
                                            null) {
                                          addlTimings[
                                          selectedScene
                                              .id]["$key"]
                                          [artist['id']] = {
                                            "start": [8, 0, 0],
                                            "end": [9, 0, 1]
                                          };
                                          schedule.additionalTimings[
                                          selectedScene
                                              .id]["$key"]
                                          [artist['id']] = {
                                            "start": [8, 0, 0],
                                            "end": [9, 0, 1]
                                          };
                                          shouldUpdate = true;
                                        }
                                        var timings = addlTimings[
                                        selectedScene
                                            .id]["$key"]
                                        [artist['id']];
                                        return Padding(
                                          padding:
                                          const EdgeInsets
                                              .all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              Text(
                                                  "${artist['Name']}"),
                                              Row(
                                                children: [
                                                  InkWell(
                                                      onTap:
                                                          () async {},
                                                      child: Text(
                                                        "${oneDigitToTwo(timings['start'][0])}:${timings['start'][1] == 0 ? "00" : oneDigitToTwo(timings['start'][1])} ${timings['start'][2] == 0 ? "AM" : "PM"}",
                                                        style: TextStyle(
                                                            color:
                                                            Colors.indigo),
                                                      )),
                                                  Text(
                                                    "    ",
                                                    style: TextStyle(
                                                        color:
                                                        background1),
                                                  ),
                                                  InkWell(
                                                      onTap:
                                                          () async {},
                                                      child: Text(
                                                        "${oneDigitToTwo(timings['end'][0])}:${timings['end'][1] == 0 ? "00" : oneDigitToTwo(timings['end'][1])} ${timings['end'][2] == 0 ? "AM" : "PM"}",
                                                        style: TextStyle(
                                                            color:
                                                            Colors.indigo),
                                                      )),
                                                ],
                                              )
                                            ],
                                          ),
                                        );
                                      }) +
                                      [
                                        if (keyj + 1 !=
                                            addlKeys.length)
                                          Divider(
                                            thickness: 1,
                                          ),
                                      ],
                                );
                              }
                            }),
                      ),
                    ),
                  if (project.role.permissions["costumes"]["view"])
                    Divider(
                      thickness: 2,
                    ),
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
                                      onTap: () async {},
                                      child: Text(
                                        "${oneDigitToTwo(timings['start'][0])}:${timings['start'][1] == 0 ? "00" : oneDigitToTwo(timings['start'][1])} ${timings['start'][2] == 0 ? "AM" : "PM"}",
                                        style: TextStyle(
                                            color: Colors.indigo),
                                      )),
                                  Text(
                                    "    ",
                                    style: TextStyle(color: background1),
                                  ),
                                  InkWell(
                                      onTap: () async {},
                                      child: Text(
                                        "${oneDigitToTwo(timings['end'][0])}:${timings['end'][1] == 0 ? "00" : oneDigitToTwo(timings['end'][1])} ${timings['end'][2] == 0 ? "AM" : "PM"}",
                                        style: TextStyle(
                                            color: Colors.indigo),
                                      )),
                                ],
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  // SFX TIMING
                  if (selectedScenes.length > 0 && selectedScene.sfx.isNotEmpty)
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
                                      onTap: () async {},
                                      child: Text(
                                        "${oneDigitToTwo(timings['start'][0])}:${timings['start'][1] == 0 ? "00" : oneDigitToTwo(timings['start'][1])} ${timings['start'][2] == 0 ? "AM" : "PM"}",
                                        style: TextStyle(
                                            color: Colors.indigo),
                                      )),
                                  Text(
                                    "    ",
                                    style: TextStyle(color: background1),
                                  ),
                                  InkWell(
                                      onTap: () async {},
                                      child: Text(
                                        "${oneDigitToTwo(timings['end'][0])}:${timings['end'][1] == 0 ? "00" : oneDigitToTwo(timings['end'][1])} ${timings['end'][2] == 0 ? "AM" : "PM"}",
                                        style: TextStyle(
                                            color: Colors.indigo),
                                      )),
                                ],
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  if (project.role.permissions["costumes"]["view"])
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Costumes",
                                style: bottomSheetHeadingStyle.copyWith(
                                    color: background1),
                              )),
                          Spacer(),
                          TextButton.icon(
                            onPressed: () async {
                                Utils.showLoadingDialog(
                                    context, "Generating PDF");
                              var d =
                                  "${date.day > 9 ? date.day : "0${date.day}"}-${date.month > 9 ? date.month : "0${date.month}"}-${date.year}, ${weeksDays[date.weekday - 1]}";
                              await PdfGenerator.costumeCallSheet(
                                project,
                                context,
                                selectedScene,
                                schedule,
                                d,
                                "en",
                                selectedArtists,
                                //{selectedArtists.elementAt(0)},
                              );
                              Navigator.pop(context);
                            },
                            label: Text("Call Sheet"),
                            icon: Icon(Icons.picture_as_pdf_outlined,
                                size: 14),
                          ),
                        ],
                      ),
                    ),
                  if (project.role.permissions["costumes"]["view"])
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: selectedScene.costumes.length == 0
                            ? Text('No Costumes')
                            : Wrap(
                          direction: Axis.horizontal,
                          children: List<Widget>.generate(
                              selectedCostumes.length, (i) {
                            Costume costume =
                            selectedCostumes.elementAt(i);
                            return InkWell(
                              onLongPress: () {
                                Navigator.push(
                                    context,
                                    Utils.createRoute(
                                        CostumesPage(
                                          costume: costume,
                                          project: project,
                                        ),
                                        Utils.DTU));
                              },
                              splashColor:
                              background1.withOpacity(0.2),
                              child: Container(
                                margin: EdgeInsets.all(2),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius:
                                  BorderRadius.circular(300),
                                ),
                                child: Text("${costume.title}"),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  if (project.role.permissions["props"]["view"])
                    Divider(
                      thickness: 2,
                    ),
                  if (project.role.permissions["props"]["view"])
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Props",
                                style: bottomSheetHeadingStyle.copyWith(
                                    color: background1),
                              )),
                          Spacer(),
                          TextButton.icon(
                            onPressed: () async {
                              Utils.showLoadingDialog(
                                  context, "Generating PDF");
                              var d =
                                  "${date.day > 9 ? date.day : "0${date.day}"}-${date.month > 9 ? date.month : "0${date.month}"}-${date.year}, ${weeksDays[date.weekday - 1]}";
                              await PdfGenerator.propertiesCallSheet(
                                project,
                                context,
                                selectedScene,
                                schedule,
                                d,
                                "en",
                                selectedArtists,
                              );
                              Navigator.pop(context);
                            },
                            label: Text("Call Sheet"),
                            icon: Icon(Icons.picture_as_pdf_outlined,
                                size: 14),
                          ),
                        ],
                      ),
                    ),
                  if (project.role.permissions["props"]["view"])
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: selectedScene.props.length == 0
                            ? Text('No Props')
                            : Wrap(
                          direction: Axis.horizontal,
                          children: List<Widget>.generate(
                              selectedScene.props.length, (i) {
                            Prop prop = Utils
                                .propsMap[selectedScene.props[i]];
                            return InkWell(
                              onLongPress: () {
                                Navigator.push(
                                    context,
                                    Utils.createRoute(
                                        PropPage(
                                          prop: prop,
                                          project: project,
                                        ),
                                        Utils.DTU));
                              },
                              splashColor:
                              background1.withOpacity(0.2),
                              child: Container(
                                margin: EdgeInsets.all(2),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius:
                                  BorderRadius.circular(300),
                                ),
                                child: Text("${prop.title}"),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  if (project.role.permissions["props"]["view"])
                    SizedBox(
                      height: 16,
                    )
                ],
              ),
            ),
            SingleChildScrollView(
              controller: scrollController,
              child: Container(
                color: background,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(CupertinoIcons.back),
                            onPressed: prevDate,
                          ),
                          Text(
                            "${date.day > 9 ? date.day : "0${date.day}"}-${date.month > 9 ? date.month : "0${date.month}"}-${date.year}, ${weeksDays[date.weekday - 1]}",
                            style: TextStyle(fontSize: 18),
                          ),
                          IconButton(
                            icon: Icon(CupertinoIcons.forward),
                            onPressed: nextDate,
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      thickness: 2,
                    ),
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Text(
                              'WD: $workingDay',
                              style: bottomSheetHeadingStyle,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () async {
                              Utils.showLoadingDialog(
                                  context, "Generating PDF");
                              var d =
                                  "${date.day > 9 ? date.day : "0${date.day}"}-${date.month > 9 ? date.month : "0${date.month}"}-${date.year}, ${weeksDays[date.weekday - 1]}";
                              await PdfGenerator.sceneCallSheet(
                                project,
                                context,
                                selectedScene,
                                schedule,
                                d,
                                "en",
                                selectedArtists,
                                //{selectedArtists.elementAt(0)},
                              );
                              Navigator.pop(context);
                            },
                            label: Text("Call Sheet"),
                            icon: Icon(Icons.picture_as_pdf_outlined,
                                size: 14),
                          ),
                          TextButton.icon(
                            onPressed: () async {
                              await Navigator.push(
                                  context,
                                  Utils.createRoute(
                                      AddSchedule(
                                        project: project,
                                        schedule: schedule.toJson(),
                                        edit: true,
                                      ),
                                      Utils.RTL));
                              getAll();
                            },
                            label: Text("Edit"),
                            icon: Icon(Icons.edit, size: 14),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "Schedule: ${schedule.name}",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: background1),
                    ),
                    SizedBox(
                      height: 8,
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
                            children: List<Widget>.generate(
                              selectedScenes.length,
                                  (i) => InkWell(
                                onLongPress: () async {
                                  await Navigator.push(
                                      context,
                                      Utils.createRoute(
                                          ScenePage(
                                            project: project,
                                            popUp: true,
                                            scene: selectedScenes
                                                .elementAt(i),
                                          ),
                                          Utils.DTU));
                                  getAll();
                                },
                                onTap: () async {
                                  selectedSceneIndex = i;
                                  selectedScene = selectedScenes[i];
                                  sceneLoc = Utils.locationsMap[
                                  selectedScene.location];
                                  selectedCostumes.clear();
                                  for (var i in selectedScene.costumes) {
                                    for (var j in i['costumes']) {
                                      selectedCostumes
                                          .add(Utils.costumesMap[j]);
                                    }
                                  }
                                  setState(() {});
                                },
                                child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 8),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom:
                                            selectedSceneIndex == i
                                                ? BorderSide(
                                                color: color,
                                                width: 3)
                                                : BorderSide(
                                                color: background,
                                                width: 3))),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: selectedScenes[
                                          i]
                                              .completed
                                              ? Colors.green
                                              : selectedScenes[i]
                                              .completedOn[
                                          0] ==
                                              0
                                              ? Colors.grey
                                              : Colors.deepOrange,
                                          radius: 4,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          '${selectedScenes[i].titles['en']}',
                                          style: selectedSceneIndex == i
                                              ? TextStyle(
                                              fontWeight:
                                              FontWeight.bold,
                                              color: background1)
                                              : TextStyle(
                                              color: background1),
                                        ),
                                      ],
                                    )),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: [
            SizedBox(
              height: 8,
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(CupertinoIcons.back),
                    onPressed: prevDate,
                  ),
                  Text(
                    "${date.day > 9 ? date.day : "0${date.day}"}-${date.month > 9 ? date.month : "0${date.month}"}-${date.year}, ${weeksDays[date.weekday - 1]}",
                    style: TextStyle(fontSize: 18),
                  ),
                  IconButton(
                    icon: Icon(CupertinoIcons.forward),
                    onPressed: nextDate,
                  ),
                ],
              ),
            ),
            Divider(
              thickness: 2,
            ),
            SizedBox(
              height: 50,
            ),
            Text(
              "No Schedule.",
              style: TextStyle(fontSize: 20),
            ),
            ElevatedButton(
              onPressed: () async {
                var now = DateTime.now();
                Map<dynamic, dynamic> schedule = {
                  "day": date.day,
                  "project_id": project.id,
                  "scenes": [],
                  "name": "None",
                  "month": date.month,
                  "artist_timings": {},
                  "addl_timings": {},
                  "call_timings": {},
                  "sfx_timings": {},
                  "vfx_timings": {},
                  "added_by": Utils.USER_ID,
                  "id": id,
                  "year": date.year,
                  "last_edit_by": Utils.USER_ID,
                  "last_edit_on": now.millisecondsSinceEpoch,
                  "created": now.millisecondsSinceEpoch
                };
                await Navigator.push(
                    context,
                    Utils.createRoute(
                        AddSchedule(schedule: schedule, project: project),
                        Utils.DTU));
                getAll();
              },
              child: Text("+ Add Schedule"),
              style: ElevatedButton.styleFrom(primary: color),
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                "Other Schedules",
                style:
                TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
              ),
            ),
            Column(
              children: List.generate(scheduleNames.length, (i) {
                return Column(
                  children: [
                    InkWell(
                        onTap: () {
                          if (selectedScheduleIndex.contains(i)) {
                            selectedScheduleIndex.remove(i);
                          } else {
                            selectedScheduleIndex.add(i);
                          }
                          if (showDates &&
                              !selectedScheduleIndex.contains(i)) {
                            showDates = false;
                          } else {
                            showDates = true;
                          }
                          setState(() {});
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(
                              vertical: 4, horizontal: 12),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: color = Color(0xff6fd8a8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text("${scheduleNames[i]}"),
                              Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                      BorderRadius.circular(16)),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  child: Text(
                                    "${test[scheduleNames[i]].length}",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold),
                                  )),
                            ],
                          ),
                        )),
                    if ((showDates || selectedScheduleIndex != null) &&
                        test.containsKey(scheduleNames[i]))
                      Column(
                        children: test[scheduleNames[i]].length == 0
                            ? selectedScheduleIndex.contains(i)
                            ? <Widget>[Text("No Schedules")]
                            : <Widget>[Container()]
                            : List<Widget>.generate(
                            test[scheduleNames[i]].length, (j) {
                          return selectedScheduleIndex.contains(i)
                              ? Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              margin: EdgeInsets.symmetric(
                                  vertical: 2),
                              decoration: BoxDecoration(
                                color: color =
                                    Color(0xff6fd8a8),
                                borderRadius:
                                BorderRadius.circular(300),
                              ),
                              child: Text(
                                  "${test[scheduleNames[i]][j]}"))
                              : Container();
                        }),
                      ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    for (int i = 0; i < scheduleNames.length; i++) {
      for (int j = 0; j < scheduless.keys.length; j++) {}
    }
    background = Colors.white;
    color = Color(0xff6fd8a8);
    if (background == Colors.white) {
      background1 = Colors.black;
    } else {
      background1 = Colors.white;
    }
    selectedIndicator.copyWith(color: color);
    unselectedIndicator.copyWith(color: background);
    return isPopUp
        ? SizedBox.expand(
      child: DraggableScrollableSheet(
        initialChildSize: 300 / MediaQuery.of(context).size.height,
        minChildSize: 300 / MediaQuery.of(context).size.height,
        maxChildSize: 1,
        builder: (context, scrollController) {
          return widget2(scrollController, scheduless);
        },
      ),
    )
        : widget2(ScrollController(), scheduless);
  }

  updateSceneStatus(bool completed, String sceneID) async {
    Utils.showLoadingDialog(context, 'Updating Scene Status');
    DateTime now = DateTime.now();

    try {
      var resp = await http.post(Utils.UPDATE_SCENE_STATUS,
          body: jsonEncode({
            "last_edit_on": now.millisecondsSinceEpoch,
            "project_id": "${schedule.project}",
            "id": sceneID,
            "last_edit_by": Utils.USER_ID,
            "completed": completed,
            "completed_on": [
              schedule.day,
              schedule.month,
              schedule.year,
              workingDay
            ]
          }),
          headers: {"Content-Type": "application/json"});
      // debugPrint(resp.body);
      var r = jsonDecode(resp.body);
      Navigator.pop(context);
      if (resp.statusCode == 200) {
        if (r['status'] == 'success') {
          var scene = Utils.scenesMap[sceneID].toJson();
          scene['completed'] = completed;
          scene['completed_on'] = [
            schedule.day,
            schedule.month,
            schedule.year,
            workingDay
          ];
          Utils.scenesMap[sceneID] = Scene.fromJson(scene);
          Utils.scenes = Utils.scenesMap.values.toList();

          int i = selectedScenes.indexWhere((element) => element.id == sceneID);
          selectedScenes[i] = Utils.scenesMap[sceneID];
          setState(() {});

          await Utils.showSuccessDialog(
              context,
              'Scene Status Updated',
              'Scene status has been updated successfully.',
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
    } catch (e) {
      // debugPrint(e);
      Navigator.pop(context);
      await Utils.showErrorDialog(
          context, 'Something went wrong.', 'Please try again after sometime.');
    }
    // Navigator.pop(context, back);
  }

  editSchedule() async {
    Utils.showLoadingDialog(context, 'Updating Schedule');

    try {
      var resp = await http.post(Utils.EDIT_SCHEDULE,
          body: jsonEncode(schedule.toJson()),
          headers: {"Content-Type": "application/json"});
      // // debugPrint(resp.body);
      var r = jsonDecode(resp.body);
      Navigator.pop(context);
      if (resp.statusCode == 200) {
        if (r['status'] == 'success') {
          Utils.schedulesMap[schedule.id] = schedule;
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
    } catch (e) {
      // debugPrint(e);
      Navigator.pop(context);
      await Utils.showErrorDialog(
          context, 'Something went wrong.', 'Please try again after sometime.');
    }
    // Navigator.pop(context, back);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}

//Artists List
/*Wrap(
                                  direction: Axis.horizontal,
                                  children: List<Widget>.generate(
                                      selectedArtists.length, (i) {
                                    return InkWell(
                                      onLongPress: () {
                                        Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                                pageBuilder: (_, __, ___) =>
                                                    ActorPopUp(
                                                      actor: selectedArtists
                                                          .elementAt(i),
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
                    )*/

/*Column(
                    children: [
                      SizedBox(
                        height: 8,
                      ),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: Icon(CupertinoIcons.back),
                                onPressed: prevDate,
                              ),
                              Text(
                                "${date.day > 9 ? date.day : "0${date.day}"}-${date.month > 9 ? date.month : "0${date.month}"}-${date.year}, ${weeksDays[date.weekday-1]}",
                                style: TextStyle(fontSize: 18),
                              ),
                              IconButton(
                                icon: Icon(CupertinoIcons.forward),
                                onPressed: nextDate,
                              ),
                            ],
                          ),
                        ),
                      Divider(
                        thickness: 2,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Scenes", style: bottomSheetHeadingStyle),
                            CircleAvatar(
                              backgroundColor: color,
                              child: IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: background,
                                    size: 18,
                                  ),
                                  color: color,
                                  onPressed: () async {
                                    var back = await Navigator.push(
                                            context,
                                            Utils.createRoute(
                                                AddSchedule(
                                                  project: project,
                                                  schedule: schedule.toJson(),
                                                  edit: true,
                                                ),
                                                Utils.RTL)) ??
                                        false;
                                    if (back) {
                                      getAll();
                                    }
                                  }),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: selectedScenes.length == 0
                              ? Text('No Scenes')
                              : Wrap(
                                  direction: Axis.horizontal,
                                  children: List<Widget>.generate(
                                      selectedScenes.length, (i) {
                                    return InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            Utils.createPopUpRoute(ScenePopUp(
                                                project: project,
                                                scene: selectedScenes[i])));
                                      },
                                      child: Container(
                                        margin: EdgeInsets.all(2),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: color,
                                          borderRadius:
                                              BorderRadius.circular(300),
                                        ),
                                        child: Text(
                                            '${selectedScenes[i].titles['English']}'),
                                      ),
                                    );
                                  }),
                                ),
                        ),
                      ),
                      SizedBox(height: 8,),
                      Divider(color: Colors.black,height: 2,),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8,8,8,0),
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
                            ? Text('No Artists')
                            : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: List<Widget>.generate(
                                      selectedArtists.length, (i) {
                                    return InkWell(
                                      onLongPress: () {
                                        Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                                pageBuilder: (_, __, ___) =>
                                                    ActorPopUp(
                                                      actor: selectedArtists
                                                          .elementAt(i),
                                                      project: project,
                                                    ),
                                                opaque: false));
                                      },
                                      splashColor:
                                          background1.withOpacity(0.2),
                                      child: Container(
                                        width: 50,
                                        margin: EdgeInsets.symmetric(horizontal: 8),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            selectedArtists.elementAt(i).image == ''
                                                ? CircleAvatar(
                                              backgroundColor: Colors.grey,
                                              radius: 50,
                                              child: Text(
                                                'No Image',
                                                style: TextStyle(color: background, fontSize: 12),
                                              ),
                                            )
                                                : CachedNetworkImage(
                                                width: 100,
                                                height: 100,
                                                imageBuilder: (context, imageProvider) => Container(
                                                  width: 100,
                                                  height: 100,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    image: DecorationImage(
                                                        image: imageProvider, fit: BoxFit.cover),
                                                  ),
                                                ),
                                                fit: BoxFit.cover,
                                                progressIndicatorBuilder: (context, url, progress) =>
                                                    LinearProgressIndicator(
                                                      value: progress.progress,
                                                    ),
                                                errorWidget: (context, url, error) => Center(
                                                    child: Text(
                                                      'Image',
                                                      style: const TextStyle(color: Colors.grey),
                                                    )),
                                                useOldImageOnUrlChange: true,
                                                imageUrl: selectedArtists.elementAt(i).image),
                                            Text('${selectedArtists.elementAt(i).names['English']}',
                                                maxLines: 2,
                                                softWrap: true,
                                                style: const TextStyle(fontSize: 12),
                                                overflow: TextOverflow.ellipsis),
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
                                                      costume: selectedCostumes
                                                          .elementAt(i),
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
                                          borderRadius:
                                              BorderRadius.circular(300),
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
                                  children: List<Widget>.generate(
                                      selectedProps.length, (i) {
                                    return InkWell(
                                      onLongPress: () {
                                        Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                                pageBuilder: (_, __, ___) =>
                                                    PropPage(
                                                      prop: selectedProps
                                                          .elementAt(i),
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
                                          borderRadius:
                                              BorderRadius.circular(300),
                                        ),
                                        child: Text(
                                            "${selectedProps.elementAt(i).title}"),
                                      ),
                                    );
                                  }),
                                ),
                        ),
                      ),
                    ],
                  )*/