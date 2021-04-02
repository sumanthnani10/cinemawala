import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:cinemawala/locations/add_location.dart';
import 'package:cinemawala/projects/project.dart';
import 'package:flutter/material.dart';

import '../utils.dart';
import 'location.dart';

class LocationPage extends StatefulWidget {
  final Location location;
  final Project project;

  const LocationPage({Key key, @required this.project, this.location})
      : super(key: key);

  @override
  _LocationPageState createState() => _LocationPageState(project, location);
}

class _LocationPageState extends State<LocationPage> {
  Color background, background1, color;

  Location location;
  final Project project;

  _LocationPageState(this.project, this.location);

  @override
  Widget build(BuildContext context) {
    background = Colors.white;
    color = Color(0xff6fd8a8);
    if (background == Colors.white) {
      background1 = Colors.black;
    } else {
      background1 = Colors.white;
    }

    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: Colors.black26,
        body: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(8)),
              child: Column(
                children: [
                  SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.width * 3 / 4,
                          child: Stack(
                            children: [
                              Carousel(
                                dotBgColor: Colors.transparent,
                                dotColor: background1,
                                dotIncreasedColor: background1,
                                autoplay: false,
                                dotSpacing: 16,
                                dotPosition: DotPosition.bottomLeft,
                                dotIncreaseSize: 1.5,
                                defaultImage: AspectRatio(
                                  aspectRatio: 4 / 3,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      color: Colors.grey,
                                      child: Center(
                                          child: Text(
                                        'No Images',
                                        style: TextStyle(color: background),
                                      )),
                                    ),
                                  ),
                                ),
                                images: List<Widget>.generate(
                                    location.images.length, (i) {
                                  return AspectRatio(
                                      aspectRatio: 4 / 3,
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: CachedNetworkImage(
                                              progressIndicatorBuilder:
                                                  (context, url, progress) =>
                                                      LinearProgressIndicator(
                                                        value:
                                                            progress.progress,
                                                      ),
                                              errorWidget: (context, url,
                                                      error) =>
                                                  Center(child: Text('Image')),
                                              useOldImageOnUrlChange: true,
                                              imageUrl: location.images[i])));
                                }),
                              ),
                              Positioned(
                                  top: 4,
                                  right: 4,
                                  child: CircleAvatar(
                                    backgroundColor: color,
                                    child: IconButton(
                                      onPressed: () async {
                                        await Navigator.push(
                                            context,
                                            Utils.createRoute(
                                                AddLocation(
                                                  project: project,
                                                  location: location.toJson(),
                                                ),
                                                Utils.RTL));
                                        location =
                                            Utils.locationsMap[location.id];
                                        setState(() {});
                                      },
                                      icon: Icon(
                                        Icons.edit,
                                        size: 20,
                                      ),
                                    ),
                                  ))
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.black26, width: 0.5))),
                          child: Text(
                            '${location.location}',
                            style: TextStyle(
                                color: background1,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.black26, width: 0.5))),
                          child: Text(
                            '@ ${location.shootLocation}',
                            style: TextStyle(
                                color: background1,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.black26, width: 0.5))),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Description :',
                                  style: TextStyle(
                                      color: background1, fontSize: 14),
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '${location.description}',
                                  style: TextStyle(
                                      color: background1, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.black26, width: 0.5))),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Scenes :',
                                  style: TextStyle(
                                      color: background1, fontSize: 14),
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: location.usedIn.length < 1
                                    ? Text(
                                        'No Scenes',
                                        style: TextStyle(
                                            color: background1, fontSize: 12),
                                      )
                                    : Wrap(
                                        direction: Axis.horizontal,
                                        spacing: 4,
                                        children: List<Widget>.generate(
                                          location.usedIn.length,
                                          (i) {
                                            return InkWell(
                                              onTap: () {
                                                // debugPrint('In scenes');
                                              },
                                              child: Container(
                                                margin: EdgeInsets.all(2),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: color,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          300),
                                                ),
                                                child: Text(
                                                    '${Utils.scenesMap[location.usedIn[i]].titles['English']}'),
                                              ),
                                            );
                                          },
                                        )),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
