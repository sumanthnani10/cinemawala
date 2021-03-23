import 'package:cinemawala/casting/actor.dart';
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
  final Map artistTimings;
  final String id;
  final VoidCallback nextDate, prevDate, getAll;

  const SchedulePage(
      {Key key,
      @required this.project,
      @required this.artistTimings,
      @required this.schedule,
      @required this.date,
      @required this.id,
      @required this.getAll,
      @required this.nextDate,
      @required this.prevDate})
      : super(key: key);

  @override
  _SchedulePageState createState() => _SchedulePageState(
      this.nextDate,
      this.prevDate,
      this.project,
      this.schedule,
      this.artistTimings,
      this.date,
      this.id,
      this.getAll);
}

class _SchedulePageState extends State<SchedulePage>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;

  final String id;
  final Project project;
  Schedule schedule;
  final DateTime date;
  Map artistTimings;
  final VoidCallback nextDate, prevDate, getAll;

  _SchedulePageState(this.nextDate, this.prevDate, this.project, this.schedule,
      this.artistTimings, this.date, this.id, this.getAll);

  List<String> weeksDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
  List<Scene> selectedScenes = [];
  Set<Actor> selectedArtists = {};
  Set<Prop> selectedProps = {};
  Set<Location> selectedLocations = {};
  Set<Costume> selectedCostumes = {};
  ScrollPhysics scroll = AlwaysScrollableScrollPhysics(),
      noScroll = NeverScrollableScrollPhysics();
  var bottomSheetHeadingStyle =
      TextStyle(fontWeight: FontWeight.bold, fontSize: 16);
  BorderSide selectedIndicator = BorderSide(width: 3),
      unselectedIndicator = BorderSide(width: 3);
  int selectedSceneIndex = 0;
  Scene selectedScene;

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
      if (schedule.scenes.length != 0) {
        selectedScene = selectedScenes[0];
        selectedSceneIndex = 0;
      } else {
        schedule = null;
      }
    }
    super.initState();
    animationController = AnimationController(vsync: this);
  }

  String oneDigitToTwo(int i) {
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
    selectedIndicator.copyWith(color: color);
    unselectedIndicator.copyWith(color: background);
    return DraggableScrollableSheet(
      initialChildSize: 300 / MediaQuery.of(context).size.height,
      minChildSize: 300 / MediaQuery.of(context).size.height,
      maxChildSize: 1,
      builder: (context, scrollController) {
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: Icon(CupertinoIcons.back),
                                    onPressed: () {},
                                  ),
                                  Text(
                                    "${date.day > 9 ? date.day : "0${date.day}"}-${date.month > 9 ? date.month : "0${date.month}"}-${date.year}, ${weeksDays[date.weekday]}",
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Scenes',
                                    style: bottomSheetHeadingStyle,
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
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                color: color.withOpacity(0.2),
                                width: MediaQuery.of(context).size.width,
                                child: SingleChildScrollView(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 0, 0, 8),
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
                                                  bottom:
                                                      selectedSceneIndex == i
                                                          ? BorderSide(
                                                              color: color,
                                                              width: 3)
                                                          : BorderSide(
                                                              color: background,
                                                              width: 3))),
                                          child: Text(
                                            '${selectedScenes[i].titles['English']}',
                                            style: selectedSceneIndex == i
                                                ? TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: background1)
                                                : TextStyle(color: background1),
                                          )),
                                    ),
                                  ),
                                ),
                              ),
                            ),
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
                                  ? Text('No Artists')
                                  : Column(
                                      children: List<Widget>.generate(
                                          selectedScene.artists.length, (j) {
                                        Actor artist = Utils.artistsMap[
                                            selectedScene.artists[j]];
                                        var timings =
                                            artistTimings[selectedScene.id]
                                                [selectedScene.artists[j]];
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                  "${artist.names['English']}"),
                                              Row(
                                                children: [
                                                  InkWell(
                                                      onTap: () async {
                                                        TimeOfDay pickedTime =
                                                            await showTimePicker(
                                                                context:
                                                                    context,
                                                                initialTime:
                                                                    TimeOfDay
                                                                        .now());
                                                        print(pickedTime);
                                                      },
                                                      child: Text(
                                                        "${oneDigitToTwo(timings['start'][0])}:${oneDigitToTwo(timings['start'][1])} ${timings['start'][2] == 0 ? "AM" : "PM"}",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.indigo),
                                                      )),
                                                  Text(
                                                    " to ",
                                                    style: TextStyle(
                                                        color: background1),
                                                  ),
                                                  InkWell(
                                                      onTap: () async {
                                                        TimeOfDay pickedTime =
                                                            await showTimePicker(
                                                                context:
                                                                    context,
                                                                initialTime:
                                                                    TimeOfDay
                                                                        .now());
                                                        print(pickedTime);
                                                      },
                                                      child: Text(
                                                        "${oneDigitToTwo(timings['end'][0])}:${oneDigitToTwo(timings['end'][1])} ${timings['end'][2] == 0 ? "AM" : "PM"}",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.indigo),
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
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: RichText(
                                    text: TextSpan(
                                        text: "Costumes ",
                                        style: bottomSheetHeadingStyle.copyWith(
                                            color: background1),
                                        children: [
                                          TextSpan(
                                              text: "(All Scenes)",
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight:
                                                      FontWeight.normal))
                                        ]),
                                  )),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
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
                                                      pageBuilder: (_, __,
                                                              ___) =>
                                                          CostumesPage(
                                                            costume:
                                                                selectedCostumes
                                                                    .elementAt(
                                                                        i),
                                                            project: project,
                                                          ),
                                                      opaque: false));
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
                                  child: RichText(
                                    text: TextSpan(
                                        text: "Props ",
                                        style: bottomSheetHeadingStyle.copyWith(
                                            color: background1),
                                        children: [
                                          TextSpan(
                                              text: "(All Scenes)",
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight:
                                                      FontWeight.normal))
                                        ]),
                                  )),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
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
                                                      pageBuilder: (_, __,
                                                              ___) =>
                                                          PropPage(
                                                            prop: selectedProps
                                                                .elementAt(i),
                                                            project: project,
                                                          ),
                                                      opaque: false));
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
                                              child: Text(
                                                  "${selectedProps.elementAt(i).title}"),
                                            ),
                                          );
                                        }),
                                      ),
                              ),
                            ),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: Icon(CupertinoIcons.back),
                                      onPressed: prevDate,
                                    ),
                                    Text(
                                      "${date.day > 9 ? date.day : "0${date.day}"}-${date.month > 9 ? date.month : "0${date.month}"}-${date.year}, ${weeksDays[date.weekday]}",
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Scenes',
                                      style: bottomSheetHeadingStyle,
                                    ),
                                    TextButton.icon(
                                      onPressed: () async {
                                        var back = await Navigator.push(
                                                context,
                                                Utils.createRoute(
                                                    AddSchedule(
                                                      project: project,
                                                      schedule:
                                                          schedule.toJson(),
                                                      edit: true,
                                                    ),
                                                    Utils.RTL)) ??
                                            false;
                                        if (back) {
                                          getAll();
                                        }
                                      },
                                      label: Text("Edit"),
                                      icon: Icon(Icons.edit, size: 14),
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
                                    padding:
                                        const EdgeInsets.fromLTRB(8, 0, 0, 8),
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.max,
                                      children: List<Widget>.generate(
                                        selectedScenes.length,
                                        (i) => InkWell(
                                          onTap: () async {
                                            selectedSceneIndex = i;
                                            selectedScene = selectedScenes[i];
                                            setState(() {});
                                          },
                                          child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                      horizontal: 8),
                                              decoration: BoxDecoration(
                                                  border: Border(
                                                      bottom:
                                                          selectedSceneIndex ==
                                                                  i
                                                              ? BorderSide(
                                                                  color: color,
                                                                  width: 3)
                                                              : BorderSide(
                                                                  color:
                                                                      background,
                                                                  width: 3))),
                                              child: Text(
                                                '${selectedScenes[i].titles['English']}',
                                                style: selectedSceneIndex == i
                                                    ? TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: background1)
                                                    : TextStyle(
                                                        color: background1),
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
              : Column(
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
                            "${date.day > 9 ? date.day : "0${date.day}"}-${date.month > 9 ? date.month : "0${date.month}"}-${date.year}, ${weeksDays[date.weekday]}",
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
                        Map<String, dynamic> schedule = {
                          "day": date.day,
                          "project_id": project.id,
                          "scenes": [],
                          "month": date.month,
                          "artist_timings": {},
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
      },
    );
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
                                "${date.day > 9 ? date.day : "0${date.day}"}-${date.month > 9 ? date.month : "0${date.month}"}-${date.year}, ${weeksDays[date.weekday]}",
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