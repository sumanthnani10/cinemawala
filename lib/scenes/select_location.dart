import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinemawala/locations/add_location.dart';
import 'package:cinemawala/locations/location.dart';
import 'package:cinemawala/locations/location_page.dart';
import 'package:cinemawala/projects/project.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../utils.dart';

class SelectLocation extends StatefulWidget {
  final Project project;

  SelectLocation({Key key, @required this.project}) : super(key: key);

  @override
  _SelectLocation createState() => _SelectLocation(this.project);
}

class _SelectLocation extends State<SelectLocation>
    with SingleTickerProviderStateMixin {
  Color background, background1, color;
  final Project project;
  TextEditingController searchController = new TextEditingController();
  String search = '';

  List<Location> locations = [];

  _SelectLocation(this.project);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    locations = Utils.locations.sublist(0);
    var showLocations = locations
        .where((e) =>
            e.location
                .toString()
                .toLowerCase()
                .contains(search.toLowerCase()) ||
            e.shootLocation
                .toString()
                .toLowerCase()
                .contains(search.toLowerCase()))
        .toList();
    background = Colors.white;
    color = Color(0xff6fd8a8);
    if (background == Colors.white) {
      background1 = Colors.black;
    } else {
      background1 = Colors.white;
    }
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: Colors.black26,
        body: Center(
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 48, horizontal: 24),
              constraints: BoxConstraints(maxWidth: Utils.mobileWidth),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                          icon: Icon(Icons.arrow_back_rounded),
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                      Text(
                        "Locations",
                        style: TextStyle(fontSize: 20, color: background1),
                        textAlign: TextAlign.center,
                      ),
                      Spacer(),
                      Material(
                        child: InkWell(
                          onTap: () {
                            if(project.role.permissions["locations"]["add"] ||project.role.permissions["scenes"]["add"]||
                                project.role.permissions["schedule"]["add"]){
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddLocation(
                                      project: project,
                                    ),
                                  ));
                            }else{
                              Utils.notAllowed(context);
                            }
                          },
                          splashColor: background1.withOpacity(0.2),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "+ Add Location",
                              style: TextStyle(color:
                              project.role.permissions["locations"]["add"] ||project.role.permissions["scenes"]["add"]||
                                  project.role.permissions["schedule"]["add"] ?
                              Colors.indigo : Colors.grey),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  TextField(
                    controller: searchController,
                    maxLines: 1,
                    textInputAction: TextInputAction.search,
                    onChanged: (s) {},
                    onSubmitted: (v) {
                      setState(() {
                        search = v;
                      });
                    },
                    decoration: InputDecoration(
                        suffixIcon: InkWell(
                          onTap: () {
                            setState(() {
                              searchController.text = '';
                              search = '';
                            });
                          },
                          child: Icon(
                            Icons.clear,
                            color: search == '' ? Colors.white : Colors.black,
                            size: 16,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.black)),
                        labelStyle: TextStyle(color: Colors.black),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 8),
                        labelText: 'Search Location',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.black)),
                        fillColor: Colors.white),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children:
                            List<Widget>.generate(showLocations.length, (i) {
                          Location location = showLocations[i];
                          return InkWell(
                            onTap: () {
                              if(project.role.permissions["locations"]["add"] || project.role.permissions["locations"]["edit"]
                              ||project.role.permissions["scenes"]["add"] || project.role.permissions["scenes"]["edit"] ||
                                  project.role.permissions["schedule"]["add"] || project.role.permissions["schedule"]["edit"]
                              ){
                                Navigator.of(context).pop(location);
                              }else{
                                Utils.notAllowed(context);
                              }
                            },
                            onLongPress: () async {
                              await Navigator.push(
                                  context,
                                  Utils.createRoute(
                                      LocationPage(
                                        project: project,
                                        location: location,
                                      ),
                                      Utils.DTU));
                              locations = Utils.locations;
                              setState(() {});
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 0, vertical: 0),
                                tileColor: color,
                                leading: Container(
                                  margin: EdgeInsets.only(left: 4),
                                  width: 45,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      width: 45,
                                      height: 45,
                                      imageUrl:
                                          "${location.images.length > 0 ? location.images[0] : ''}",
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons
                                              .image_not_supported_outlined),
                                    ),
                                  ),
                                ),
                                title: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "${location.location}",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )),
                                subtitle: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "@ ${location.shootLocation}",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
