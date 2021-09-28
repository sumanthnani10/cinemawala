import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinemawala/artists/actor.dart';
import 'package:cinemawala/costumes/costume.dart';
import 'package:cinemawala/locations/location.dart';
import 'package:cinemawala/pdf_generator.dart';
import 'package:cinemawala/projects/project.dart';
import 'package:cinemawala/scenes/scene.dart';
import 'package:cinemawala/schedule/schedule.dart';
import 'package:cinemawala/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'artist_project.dart';

class ArtistProjectPage extends StatefulWidget {
  final ArtistProject artistProject;

  const ArtistProjectPage({Key key, @required this.artistProject})
      : super(key: key);

  @override
  _ArtistProjectPageState createState() =>
      _ArtistProjectPageState(this.artistProject);
}

class _ArtistProjectPageState extends State<ArtistProjectPage>
    with SingleTickerProviderStateMixin {
  final ArtistProject artistProject;
  AnimationController _controller;
  Project project;
  List months = [];
  Map<dynamic, dynamic> callSheetTimings = {};
  Map<dynamic, dynamic> artistTiming = {};
  var timings;
  Actor artist;
  int flag = 0;
  List<Scene> scenes;
  List<Costume> costumes;
  List<Schedule> schedules;
  List<Location> locations;
  int cday, cmonth, cyear, tempday, tempmonth, tempyear;
  int selectedIndex = 0;
  Scene selectedScene;
  Map<String, Scene> scenesMap;
  Map<String, Costume> costumesMap;
  Map<String, Location> locationsMap;
  Scene sceneDetails;
  Costume costumeDetails;
  List<dynamic> temp = [];
  Location selectedLocation;
  Schedule selectedSchedule;
  Color background, color, background1;
  List<dynamic> scenesId = [];
  var sceneIndex = 0;
  _ArtistProjectPageState(this.artistProject);

  @override
  void initState() {
    scenesMap = {};
    costumesMap = {};
    locationsMap = {};
    project = artistProject.project;
    artist = artistProject.artist;
    scenes = artistProject.scenes;
    costumes = artistProject.costumes;
    locations = artistProject.locations;
    schedules = artistProject.schedules;
    selectedSchedule = null;
    months = [
      "",
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    _controller = AnimationController(vsync: this);
    scenes.forEach((element) {
      scenesMap[element.id] = element;
      scenesId.add(element.id);
    });
    print(scenesMap);
    costumes.forEach((element) {
      costumesMap[element.id] = element;
    });
    locations.forEach((element) {
      print(element);
      locationsMap[element.id] = element;
    });
    print("location Map ${locationsMap}");
    //var name = Utils.artistsMap[artist.id];
    //print(name);
    PdfGenerator.artistWise(scenesMap,locationsMap,schedules,artist);
    if (schedules.length > 0) {
      selectedSchedule = schedules.first;
      cday = selectedSchedule.day;
      cmonth = selectedSchedule.month;
      cyear = selectedSchedule.year;
      print(selectedSchedule);
      print(scenesMap);
      print(selectedSchedule.scenes);
      List<dynamic> temp = selectedSchedule.scenes;
      selectedSchedule.scenes = [];
      for(int i=0;i<temp.length;i++){
        if(scenesMap[temp[i]]!=null){
          //selectedScene = scenesMap[selectedSchedule.scenes[i]];
          selectedSchedule.scenes.add(temp[i]);
          //print(selectedScene.location);
        }
      }
      print(selectedSchedule.scenes);
      selectedScene = scenesMap[selectedSchedule.scenes[0]];
      selectedLocation = locationsMap[selectedScene.location];
    }
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

  Widget actorProfileWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: artist.image == ''
                  ? Container(
                      color: Colors.grey,
                      child: Center(
                          child: Text(
                      'No Image',
                      style: TextStyle(color: background),
                    )),
              )
                  : CachedNetworkImage(
                  fit: BoxFit.cover,
                      width: 120,
                      height: 180,
                      progressIndicatorBuilder: (context, url, progress) =>
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 40,
                                child: LinearProgressIndicator(
                                  value: progress.progress,
                                ),
                              ),
                            ],
                          ),
                      errorWidget: (context, url, error) =>
                          Center(child: Text('Image')),
                      useOldImageOnUrlChange: true,
                      imageUrl: artist.image)),
          Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "${artist.names['en']}",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 2,
              ),
              Text("as"),
              SizedBox(
                height: 0,
              ),
              Text(
                "${artist.characters['en']}",
                style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget scheduleDateWidget() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(schedules.length, (i) {
                if (tempday == null ||
                    cday != tempday ||
                    cmonth != tempmonth ||
                    cyear != tempyear) {
                  if (tempday == null) {
                    tempday = schedules[0].day;
                    tempmonth = schedules[0].month;
                    tempyear = schedules[0].year;
                  }
                  cday = tempday;
                  cmonth = tempmonth;
                  cyear = tempyear;
                  /*for(int i=0;i<selectedSchedule.scenes.length;i++){
                    if(scenesMap[selectedSchedule.scenes[i]]!=null){
                      selectedScene = scenesMap[selectedSchedule.scenes[i]];
                      print(selectedScene.location);
                    }
                  }*/
                  selectedScene = scenesMap[selectedSchedule.scenes[0]];
                  selectedLocation = locationsMap[selectedScene.location];
                  callSheetTimings = selectedSchedule.callSheetTimings;
                  timings = callSheetTimings[selectedSchedule.scenes[0]];
                  artistTiming = selectedSchedule
                      .artistTimings[selectedSchedule.scenes[0]][artist.id];
                  sceneDetails = scenesMap[selectedSchedule.scenes[0]];
                  for (int j = 0; j < sceneDetails.costumes.length; j++) {
                    if (sceneDetails.costumes[j]["id"] == artist.id) {
                      temp = [];
                      for (int k = 0;
                          k < sceneDetails.costumes[j]["costumes"].length;
                          k++) {
                        temp.add(sceneDetails.costumes[j]["costumes"][k]);
                      }
                    }
                  }
                }
                return InkWell(
                  onTap: () {
                    setState(() {
                      sceneIndex = 0;
                      selectedIndex = i;
                      selectedSchedule = schedules[i];
                      print(schedules);
                      selectedScene = scenesMap[selectedSchedule.scenes[0]];
                      tempday = schedules[i].day;
                      tempmonth = schedules[i].month;
                      tempyear = schedules[i].year;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    margin: EdgeInsets.all(4),
                    decoration: i == selectedIndex
                        ? BoxDecoration(
                            gradient: Utils.linearGradient,
                            borderRadius: BorderRadius.all(Radius.circular(8)))
                        : BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                    child: Column(
                      children: [
                        Text(
                          "${months[schedules[i].month]}",
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                        Text(
                          "${schedules[i].day}",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        Text(
                          "${schedules[i].year}",
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        if (schedules.length > 0)
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              decoration: BoxDecoration(
                // gradient: Utils.linearGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              // padding: const EdgeInsets.all(4),
              margin: const EdgeInsets.all(4),
              child: Text(
                'Working Day: ${selectedIndex + 1}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
      ],
    );
  }

  Widget scenesWidget() {
    return Container(
      width: MediaQuery.of(context).size.width,
      constraints: BoxConstraints(maxWidth: Utils.mobileWidth),
      margin: const EdgeInsets.fromLTRB(0, 8, 0, 0),
      color: color.withOpacity(0.2),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: List.generate(selectedSchedule.scenes.length, (i) {

            if(i==0){
              selectedScene = scenesMap[selectedSchedule.scenes[0]];
            }
            print("Selected Scene ${selectedScene}");
            return InkWell(
              onTap: () {
                setState(() {
                  sceneIndex = i;
                  selectedScene = scenesMap[selectedSchedule.scenes[i]];
                  selectedLocation = locationsMap[selectedScene.location];
                  callSheetTimings = selectedSchedule.callSheetTimings;
                  timings = callSheetTimings[selectedSchedule.scenes[i]];
                  print("yep");
                  print(selectedSchedule.scenes[i]);
                  print(scenesMap[selectedSchedule.scenes[i]].titles['en']);
                  print(selectedSchedule.artistTimings[selectedSchedule.scenes[i]]);
                  print(artist.id);
                  print("yep");
                  artistTiming = selectedSchedule
                      .artistTimings[selectedSchedule.scenes[i]][artist.id];
                  sceneDetails = scenesMap[selectedSchedule.scenes[i]];
                  for (int j = 0; j < sceneDetails.costumes.length; j++) {
                    if (sceneDetails.costumes[j]["id"] == artist.id) {
                      temp = [];
                      for (int k = 0;
                          k < sceneDetails.costumes[j]["costumes"].length;
                          k++) {
                        temp.add(sceneDetails.costumes[j]["costumes"][k]);
                      }
                    }
                  }
                });
              },
              child: scenesId.contains(selectedSchedule.scenes[i]) ?
                  /*print(scenesId.contains(selectedSchedule.scenes[i]));
                  print(scenesMap[selectedSchedule.scenes[i]].titles['en']);
                  print(timings);
                  print(artistTiming);//----> null
                  print(artist.names);*/
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                //color: scenesMap[selectedSchedule.scenes[i]].id ==
                                  //  selectedScene.id ?
                                color: sceneIndex==i ?  color
                                    : color.withOpacity(0.1),
                                width: 3))),
                    child: Text(
                        "${scenesMap[selectedSchedule.scenes[i]].titles['en']}"),
                    //child: Text("${selectedSchedule.scenes[i]}"),
                  )
              :Container(child: Text("${selectedSchedule.scenes[i]}"),),
            );
          }),
        ),
      ),
    );
  }

  Widget sceneDetailWidget(){
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(
              color: Colors.black45,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(fontFamily: "Poppins"),
                  children: <TextSpan>[
                    TextSpan(
                        text: 'Gist : ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black)),
                    TextSpan(
                        text: '${sceneDetails.gists['en']}',
                        style: TextStyle(color: Colors.black)),
                  ],
                ),
              ),
            ),
            Divider(
              color: Colors.black45,
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                gradient: Utils.linearGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                leading: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: CachedNetworkImage(
                      imageUrl: selectedLocation.images.length > 0
                          ? selectedLocation.images[0]
                          : '',
                      width: 60,
                      height: 50,
                      fit: BoxFit.cover,
                    )),
                title: Text("${selectedLocation.location}",
                    style: TextStyle(
                        color: background1, fontWeight: FontWeight.bold),
                    maxLines: 1),
                subtitle: Text(
                  "@ ${selectedLocation.shootLocation}",
                  style: TextStyle(color: background1),
                  maxLines: 1,
                ),
              ),
            ),
            Divider(
              color: Colors.black45,
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("Call Sheet Timing"),
                  Spacer(),
                  InkWell(
                      onTap: () async {},
                      child: Text(
                        "${oneDigitToTwo(timings['start'][0])}:${timings['start'][1] == 0 ? "00" : oneDigitToTwo(timings['start'][1])} ${timings['start'][2] == 0 ? "AM" : "PM"}",
                        style:
                        TextStyle(color: Colors.indigo),
                      )),
                  Text(
                    " to ",
                    style: TextStyle(color: background1),
                  ),
                  InkWell(
                      onTap: () async {},
                      child: Text(
                        "${oneDigitToTwo(timings['end'][0])}:${timings['end'][1] == 0 ? "00" : oneDigitToTwo(timings['end'][1])} ${timings['end'][2] == 0 ? "AM" : "PM"}",
                        style: TextStyle(color: Colors.indigo),
                      )),
                ],
              ),
            ),
            Divider(
              color: Colors.black45,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Align(
                      alignment: Alignment.centerLeft, child: Text(" On Loc ")),
                  Row(
                    children: [
                      Text(
                        "    ",
                        style: TextStyle(color: background1),
                      ),
                      Text("On Set  ")
                    ],
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${artist.names['en']}",
                    style: TextStyle(),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  if(artistTiming!=null)
                  Row(
                    children: [
                      Text(
                        "${oneDigitToTwo(artistTiming['start'][0])}:${artistTiming['start'][1] == 0 ? "00" : oneDigitToTwo(artistTiming['start'][1])} ${artistTiming['start'][2] == 0 ? "AM" : "PM"}",
                        style: TextStyle(color: Colors.indigo),
                      ),
                      Text(
                        "    ",
                        style: TextStyle(
                            color: background1),
                      ),
                      Text(
                        "${oneDigitToTwo(artistTiming['end'][0])}:${artistTiming['end'][1] == 0 ? "00" : oneDigitToTwo(artistTiming['end'][1])} ${artistTiming['end'][2] == 0 ? "AM" : "PM"}",
                        style: TextStyle(color: Colors.indigo),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Divider(
              color: Colors.black45,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "Costumes",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: List.generate(temp.length, (i){
                  print("hello ${temp}");
                  costumeDetails = costumesMap[temp[i]];
                  return Container(
                    padding: EdgeInsets.all(8),
                    margin: EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      gradient: Utils.linearGradient,
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    constraints: BoxConstraints(minWidth: Utils.mobileWidth),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: costumeDetails.referenceImage == ''
                                ? Container(
                                    color: Colors.grey,
                                    child: Center(
                                        child: Text(
                                      'No Image',
                                    style: TextStyle(color: background),
                                  )),
                            )
                                : CachedNetworkImage(
                                width: 60,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    progressIndicatorBuilder:
                                        (context, url, progress) =>
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 40,
                                              child: LinearProgressIndicator(
                                                value: progress.progress,
                                              ),
                                            ),
                                          ],
                                        ),
                                    errorWidget: (context, url, error) =>
                                        Center(child: Text('Image')),
                                    useOldImageOnUrlChange: true,
                                    imageUrl: costumeDetails.referenceImage)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Align(
                            alignment:Alignment.centerLeft,
                            child: Column(
                              children:[
                                Container(
                                    width:Utils.mobileWidth/2,
                                    child: Text('${costumeDetails.title}\n',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontFamily: "Poppins"),overflow: TextOverflow.ellipsis,maxLines: 1,)),
                                Container(
                                    width : Utils.mobileWidth/2,
                                    child: Text('${costumeDetails.description}',style: TextStyle(color: Colors.black54),overflow: TextOverflow.ellipsis,maxLines: 1,)),
                              ],
                            ),
                          ),
                        ),
                      ],
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

  @override
  Widget build(BuildContext context) {
    color = Color(0xff6fd8a8);
    background = Colors.white;
    if (background == Colors.white) {
      background1 = Colors.black;
    } else {
      background1 = Colors.white;
    }
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: Utils.linearGradient,
          )
        ),
        backgroundColor: color,
        title: Text(
          '${project.name}',
          style: TextStyle(color: background1),
        ),
        iconTheme: IconThemeData(color: background1),
        actions: [],
      ),
      body: constraints.maxWidth>Utils.mobileWidth ?
          Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: Utils.mobileWidth),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                            actorProfileWidget(),
                          ] +
                          (schedules.length > 0
                              ? <Widget>[
                                  scheduleDateWidget(),
                                  scenesWidget(),
                                  sceneDetailWidget()
                                ]
                              : <Widget>[Text("No Schedules")])),
                ),
          )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                      actorProfileWidget(),
                    ] +
                    (schedules.length > 0
                        ? <Widget>[
                            scheduleDateWidget(),
                            scenesWidget(),
                            sceneDetailWidget()
                          ]
                        : <Widget>[Text("No Schedules")])),
    );});
  }
}
