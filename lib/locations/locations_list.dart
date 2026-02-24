
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinemawala/locations/add_location.dart';
import 'package:cinemawala/locations/location.dart';
import 'package:cinemawala/locations/location_page.dart';
import 'package:cinemawala/projects/project.dart';
import 'package:cinemawala/scenes/scene.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

class LocationsList extends StatefulWidget {
  final Project project;

  LocationsList({Key key, @required this.project}) : super(key: key);

  @override
  _LocationsList createState() => _LocationsList(project);
}

class _LocationsList extends State<LocationsList>
    with SingleTickerProviderStateMixin {
  final Project project;
  Color background, background1, color;
  List<Location> locations = [];
  List<Scene> scenes = [];
  Widget sideWidget;
  var locationTitleStyle = TextStyle(color: Colors.black);
  var locationDescriptionStyle = TextStyle(fontSize: 16);
  var usedByStyle = TextStyle(fontSize: 12);
  bool loading = false;

  _LocationsList(this.project);

  @override
  void initState() {
    loading = true;
    locations = Utils.locations.sublist(0) ?? [];
    scenes = Utils.scenes ?? [];
    if (Utils.locations == null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        getLocations();
      });
    }
    super.initState();
  }

  getLocations() async {
    loading = true;
    Utils.showLoadingDialog(context, 'Getting Locations');
    locations = await Utils.getLocations(context, project.id);
    Navigator.pop(context);
    setState(() {
      loading = false;
    });
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
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          var maxWidth = constraints.maxWidth;
      return Row(
      children: [
        Flexible(
          flex: 6,
          child: DefaultTabController(
            length: 2,
            initialIndex: 1,
            child: Scaffold(
              backgroundColor: background,
              appBar: AppBar(
                flexibleSpace: Container(
                  decoration: maxWidth>Utils.mobileWidth ? BoxDecoration(
                    color: Colors.white,
                  ): BoxDecoration(
                    gradient: Utils.linearGradient,
                  ),
                ),
                backgroundColor: color,
                actions: [
                  TextButton.icon(
                    onPressed: () {
                      getLocations();
                    },
                    label: Text(
                      "",
                        style: TextStyle(color: Colors.indigo),
                        textAlign: TextAlign.right,
                      ),
                    icon: Icon(
                      Icons.refresh_rounded,
                        size: 32,
                        color: Colors.indigo,
                      ),
                  )
                ],
                bottom: TabBar(
                  labelColor: background1,
                  indicatorColor: background1,
                  tabs: <Widget>[
                    Tab(
                      text: 'Scene Wise',
                    ),
                    Tab(
                      text: 'Location Wise',
                    ),
                  ],
                ),
                iconTheme: IconThemeData(color: background1),
                title: Text(
                  "Locations",
                  style: TextStyle(color: background1),
                ),
              ),
              body: TabBarView(
                children: <Widget>[
                  SingleChildScrollView(
                      child: Column(
                          children: List<Widget>.generate(scenes.length, (i) {
                    Scene scene = scenes[i];
                    Location location = Utils.locationsMap[scene.location];
                    return ListTile(
                      title: Text('${scene.titles['en']}'),
                        subtitle: Text(
                            '${location.location} @ ${location.shootLocation}'),
                        onTap: () {
                          if (maxWidth > Utils.mobileWidth) {
                            setState(() {
                              sideWidget = LocationPage(
                                key: UniqueKey(),
                                isPopUp: false,
                                project: project,
                                location: location,
                              );
                          });
                        }
                        else{
                          Navigator.push(
                              context,
                              Utils.createRoute(
                                  LocationPage(
                                    project: project,
                                    location: location,
                                  ),
                                  Utils.DTU));
                        }

                      },
                    );
                  }))),
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: List<Widget>.generate(locations.length, (i) {
                        var location = locations[i];
                        return InkWell(
                          onTap: () async {
                            if(maxWidth>Utils.mobileWidth){
                              setState(() {
                                sideWidget = LocationPage(
                                  key: UniqueKey(),
                                  isPopUp: false,
                                  project: project,
                                  location: location,
                                );
                              });
                            }else{
                              await Navigator.push(
                                  context,
                                  Utils.createRoute(
                                      LocationPage(
                                        project: project,
                                        location: location,
                                      ),
                                      Utils.DTU));
                              setState(() {
                                locations = Utils.locations.sublist(0);
                              });
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border(
                                    bottom:
                                        BorderSide(color: background1, width: 1))),
                            padding: EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: AspectRatio(
                                    aspectRatio: 3 / 2,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: location.images.length < 1
                                          ? Container(
                                              width: 50,
                                              height: 50 * (2 / 3),
                                              color: Colors.grey,
                                              child: Center(
                                                  child: Text(
                                                'No Images',
                                                style: TextStyle(color: background),
                                              )),
                                            )
                                          : CachedNetworkImage(
                                              width: 50,
                                              height: 50 * (2 / 3),
                                              fit: BoxFit.cover,
                                              progressIndicatorBuilder:
                                                  (context, url, progress) =>
                                                        Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            SizedBox(
                                                              width: 40,
                                                              child:
                                                                  LinearProgressIndicator(
                                                                value: progress
                                                                    .progress,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                              errorWidget: (context, url, error) =>
                                                  Center(
                                                      child: Text(
                                                    'Image',
                                                    style: const TextStyle(
                                                        color: Colors.grey),
                                                  )),
                                              useOldImageOnUrlChange: true,
                                              imageUrl: '${location.images[0]}'),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  flex: 2,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 8),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${location.location}',
                                          style: locationTitleStyle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '@ ${location.shootLocation}',
                                          style: locationTitleStyle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
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
              floatingActionButton: FloatingActionButton(
                onPressed: () async {
                  if(project.role.permissions["locations"]["add"]||
                      project.role.permissions["scenes"]["add"]||
                      project.role.permissions["schedule"]["add"]){
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddLocation(
                              isPopUp: maxWidth>Utils.mobileWidth ? false : true,
                              project: project,
                            )));
                    setState(() {
                      locations = Utils.locations.sublist(0);
                    });
                  }else{
                    Utils.notAllowed(context);
                  }
                },
                backgroundColor:project.role.permissions["locations"]["add"]||
                    project.role.permissions["scenes"]["add"]||
                    project.role.permissions["schedule"]["add"]?
                color : Utils.notPermitted,
                child: Icon(
                  Icons.add,
                  color: background,
                  size: 36,
                ),
              ),
            ),
          ),
        ),
        if(maxWidth>Utils.mobileWidth)
          Flexible(
            flex: 4,
            child: Scaffold(body: sideWidget ?? SizedBox.expand(child: Container(
              decoration: BoxDecoration(
                  border: Border(left: BorderSide(color: Colors.black))
              ),
              child: Center(child: Text("No Field Selected")),)),),
          )
      ],
    );});
  }
}
