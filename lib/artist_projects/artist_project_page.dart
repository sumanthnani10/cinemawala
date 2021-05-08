import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinemawala/casting/actor.dart';
import 'package:cinemawala/costumes/costume.dart';
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
  var selectedDayScenes;
  Map<dynamic,dynamic> callSheetTimings = {};
  Map<dynamic,dynamic> artistTiming = {};
  var timings;
  Actor artist;
  int flag = 0;
  List<Scene> scenes;
  List<Costume> costumes;
  List<Schedule> schedules;
  int cday,cmonth,cyear,tempday,tempmonth,tempyear;
  int selectedIndex = 0,selectedScene = 0;
  Map<String,Scene> scene;
  Map<String,Costume> costume;
  Scene sceneDetails;
  Costume costumeDetails;
  List<dynamic> temp = [];
  Schedule selectedSchedule;
  Color background, color, background1;
  _ArtistProjectPageState(this.artistProject);

  @override
  void initState() {
    scene = {};
    costume = {};
    project = artistProject.project;
    artist = artistProject.artist;
    scenes = artistProject.scenes;
    costumes = artistProject.costumes;
    schedules = artistProject.schedules;
    selectedSchedule = selectedSchedule ?? schedules.first;
    super.initState();
    months = ["","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
    _controller = AnimationController(vsync: this);
    scenes.forEach((element) {
      scene[element.id] = element;
    });
    costumes.forEach((element) {
      costume[element.id] = element;
    });
    cday = schedules[0].day;
    cmonth = schedules[0].month;
    cyear = schedules[0].year;
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
  Widget actorProfileWidget(){
    return Padding(
      padding: const EdgeInsets.all(8),
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
                  width: 100,
                  height: 150,
                  progressIndicatorBuilder:
                      (context, url, progress) =>
                      LinearProgressIndicator(
                        value: progress.progress,
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
              Text("${artist.names['en']}",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
              SizedBox(height: 2,),
              Text("as"),
              SizedBox(height: 2,),
              Text("${artist.characters['en']}",style: TextStyle(color: Colors.black54,fontSize: 16,fontWeight: FontWeight.bold),)
            ],
          )
        ],
      ),
    );
  }
  Widget scheduleDateWidget(){
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(schedules.length, (i){
          if(tempday==null || cday!=tempday || cmonth!=tempmonth || cyear!=tempyear){
            if(tempday==null){
              tempday = schedules[0].day;
              tempmonth = schedules[0].month;
              tempyear = schedules[0].year;
            }
            cday = tempday;
            cmonth = tempmonth;
            cyear = tempyear;
            callSheetTimings = selectedSchedule.callSheetTimings;
            timings = callSheetTimings[selectedSchedule.scenes[0]];
            artistTiming = selectedSchedule.artistTimings[selectedSchedule.scenes[0]][artist.id];
            sceneDetails = scene[selectedSchedule.scenes[0]];
            for(int j=0;j<sceneDetails.costumes.length;j++){
              if(sceneDetails.costumes[j]["id"]==artist.id){
                temp = [];
                for(int k=0;k<sceneDetails.costumes[j]["costumes"].length;k++){

                  temp.add(sceneDetails.costumes[j]["costumes"][k]);
                }
              }
            }
          }
          return InkWell(
            onTap: (){
            setState(() {
              selectedIndex = i;
              selectedScene = 0;
              selectedSchedule = schedules[i];
              tempday = schedules[i].day;
              tempmonth = schedules[i].month;
              tempyear = schedules[i].year;
            });
            },
            child: Container(
              padding: EdgeInsets.all(8),
              margin: EdgeInsets.all(4),
              decoration: BoxDecoration(
                  border: Border.all(color: i==selectedIndex ? color : Colors.white),
                  color: i==selectedIndex ? color : Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              child: Column(
                children: [
                  Text("${months[schedules[i].month]}",style: TextStyle(color: i==selectedIndex ? Colors.white : Colors.black,fontSize: 12),),
                  Text("${schedules[i].day}",style: TextStyle(color: i==selectedIndex ? Colors.white : Colors.black,fontWeight: FontWeight.bold
                      ,fontSize: 16),),
                  Text("${schedules[i].year}",style: TextStyle(color: i==selectedIndex ? Colors.white : Colors.black,fontSize: 12),),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
  Widget scenesWidget(){
    return Container(
      width: MediaQuery.of(context).size.width,
      color: color.withOpacity(0.2),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: List.generate(selectedSchedule.scenes.length,(i){
            return InkWell(
              onTap: (){
                setState((){
                  selectedScene = i;
                  callSheetTimings = selectedSchedule.callSheetTimings;
                  timings = callSheetTimings[selectedSchedule.scenes[i]];
                  artistTiming = selectedSchedule.artistTimings[selectedSchedule.scenes[i]][artist.id];
                  sceneDetails = scene[selectedSchedule.scenes[i]];
                  for(int j=0;j<sceneDetails.costumes.length;j++){
                    if(sceneDetails.costumes[j]["id"]==artist.id){
                      temp = [];
                      for(int k=0;k<sceneDetails.costumes[j]["costumes"].length;k++){
                        temp.add(sceneDetails.costumes[j]["costumes"][k]);
                      }
                    }
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 8, horizontal: 8),
                decoration: BoxDecoration(border: Border(
                    bottom: BorderSide(color: i==selectedScene ? color : color.withOpacity(0.1),width: 3))),
                child: Text("${scene[selectedSchedule.scenes[i]].titles['en']}"),
                //child: Text("${selectedSchedule.scenes[i]}"),
              ),
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(text: 'Gist : ', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black)),
                    TextSpan(text: '${sceneDetails.gists['en']}',style: TextStyle(color: Colors.black)),
                  ],
                ),
              ),
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
                        style:
                        TextStyle(color: Colors.indigo),
                      )),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Align(
                      alignment:Alignment.centerLeft,
                      child: Text("On Shoot  ")),
                  Row(
                    children: [
                      Text(
                        "    ",
                        style: TextStyle(
                            color: background1),
                      ),
                      Text("On Set  ")
                    ],
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${artist.names['en']}",style: TextStyle(),overflow: TextOverflow.ellipsis,maxLines: 1,),
                  Row(
                    children: [
                      Text(
                        "${oneDigitToTwo(artistTiming['start'][0])}:${artistTiming['start'][1] == 0 ? "00" : oneDigitToTwo(artistTiming['start'][1])} ${artistTiming['start'][2] == 0 ? "AM" : "PM"}",
                        style: TextStyle(
                            color: Colors.indigo),
                      ),
                      Text(
                        "    ",
                        style: TextStyle(
                            color: background1),
                      ),
                      Text(
                        "${oneDigitToTwo(artistTiming['end'][0])}:${artistTiming['end'][1] == 0 ? "00" : oneDigitToTwo(artistTiming['end'][1])} ${artistTiming['end'][2] == 0 ? "AM" : "PM"}",
                        style: TextStyle(
                            color: Colors.indigo),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text("Costumes",style: TextStyle(fontWeight: FontWeight.bold),),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: List.generate(temp.length, (i){
                  costumeDetails = costume[temp[i]];
                  return Container(
                    padding: EdgeInsets.all(8),
                    margin: EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      gradient: Utils.linearGradient,
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    constraints: MediaQuery.of(context).size.width>Utils.mobileWidth ? BoxConstraints(minWidth: Utils.mobileWidth) :
                    BoxConstraints(minWidth: MediaQuery.of(context).size.width),
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
                                fit: BoxFit.fill,
                                progressIndicatorBuilder:
                                    (context, url, progress) =>
                                    LinearProgressIndicator(
                                      value: progress.progress,
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
          //kept seperately for background image in web
          Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: Utils.mobileWidth),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                actorProfileWidget(),
                scheduleDateWidget(),
                scenesWidget(),
                sceneDetailWidget()
              ]),
            ),
          )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          actorProfileWidget(),
          scheduleDateWidget(),
          scenesWidget(),
          sceneDetailWidget()
        ],
      ),
    );});
  }
}
