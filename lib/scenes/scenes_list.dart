import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinemawala/artists/actor.dart';
import 'package:cinemawala/props/prop.dart';
import 'package:cinemawala/scenes/add_scene.dart';
import 'package:cinemawala/scenes/scene.dart';
import 'package:cinemawala/scenes/scene_page.dart';
import 'package:cinemawala/scenes/select_actors.dart';
import 'package:cinemawala/scenes/select_costumes.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils.dart';
import 'select_props.dart';

class ScenesList extends StatefulWidget {
  final project;

  ScenesList({Key key, @required this.project}) : super(key: key);

  @override
  _ScenesList createState() => _ScenesList(this.project);
}

class _ScenesList extends State<ScenesList>
    with SingleTickerProviderStateMixin {
  final project;
  Color background, background1, color;
  bool loading = false;
  List<Scene> scenes = [];
  Widget sideWidget;

  _ScenesList(this.project);

  @override
  void initState() {
    loading = true;
    scenes = [];
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getScenes();
    });
    super.initState();
  }

  getScenes() async {
    loading = true;
    Utils.showLoadingDialog(context, 'Getting Scenes');
    if (Utils.artists == null) {
      await Utils.getArtists(context, project.id);
    }
    if (Utils.costumes == null) {
      await Utils.getCostumes(context, project.id);
    }
    if (Utils.props == null) {
      await Utils.getProps(context, project.id);
    }
    if (Utils.locations == null) {
      await Utils.getLocations(context, project.id);
    }
    if (Utils.scenes == null) {
      scenes = await Utils.getScenes(context, project.id);
    } else {
      scenes = Utils.scenes ?? [];
    }
    Navigator.pop(context);
    setState(() {
      loading = false;
    });
  }

  getAll() async {
    setState(() {
      loading = true;
    });
    ;
    Utils.showLoadingDialog(context, 'Getting Scenes');
    await Utils.getArtists(context, project.id);
    await Utils.getCostumes(context, project.id);
    await Utils.getProps(context, project.id);
    await Utils.getLocations(context, project.id);
    scenes = await Utils.getScenes(context, project.id);
    Navigator.pop(context);
    setState(() {
      loading = false;
    });
  }

  Widget imagesInCircles(List images, double radius, int max, double textSize) {
    return Stack(
      children: List<Widget>.generate(images.length > max ? max : images.length,
              (i) {
            return Padding(
              padding: EdgeInsets.only(left: i.toDouble() * (radius * 6 / 4)),
              child: CircleAvatar(
                radius: radius,
                backgroundColor: Colors.white,
                child: images[i] == ''
                    ? Container(
                  width: (radius - 1) * 2,
                  height: (radius - 1) * 2,
                  color: background,
                )
                    : CachedNetworkImage(
                    width: (radius - 1) * 2,
                    height: (radius - 1) * 2,
                    imageBuilder: (context, imageProvider) => Container(
                      width: (radius - 1) * 2,
                      height: (radius - 1) * 2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: imageProvider, fit: BoxFit.cover),
                      ),
                    ),
                    fit: BoxFit.cover,
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
                    errorWidget: (context, url, error) => Center(
                        child: Text(
                          'Image',
                          style: const TextStyle(color: Colors.grey),
                        )),
                    useOldImageOnUrlChange: true,
                    imageUrl: images[i]),
              ),
            );
          }) +
          [
            Padding(
              padding: EdgeInsets.only(
                  left: (((images.length > max ? max : images.length) *
                      (radius * 6 / 4)) +
                      radius / 2),
                  top: radius / 4),
              child: Text(
                '${images.length > max ? '+${images.length - max} more' : ''}',
                style: TextStyle(fontSize: textSize),
              ),
            ),
          ],
    );
  }

  Widget imagesInSquares(List images, double size, int max, double textSize) {
    return Row(
      children:
      List<Widget>.generate(images.length > max ? max : images.length, (i) {
        return Container(
          margin: EdgeInsets.only(left: 1),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: images[i] == ''
                ? Container(
              width: size - 1,
              height: size - 1,
              color: background,
            )
                : CachedNetworkImage(
              fit: BoxFit.cover,
              width: size - 1,
              height: size - 1,
              imageUrl: images[i],
            ),
          ),
        );
      }) +
          [
            Text(
              ' ${images.length > max ? '+${images.length - max} more' : ''}',
              style: TextStyle(fontSize: textSize),
            ),
          ],
    );
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
            child: Scaffold(
              appBar: AppBar(
                flexibleSpace: Container(
                  decoration: maxWidth > Utils.mobileWidth
                      ? BoxDecoration(
                          color: Colors.white,
                        )
                      : BoxDecoration(
                          gradient: Utils.linearGradient,
                        ),
                ),
                    title: Text(
                      "Scenes",
                      style: TextStyle(color: background1),
                    ),
                    iconTheme: IconThemeData(color: background1),
                    backgroundColor: color,
                    actions: [
                      TextButton.icon(
                        onPressed: () {
                          getAll();
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
                  ),
                  body: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: List<Widget>.generate(scenes.length, (i) {
                        Scene scene = scenes[i];
                        return InkWell(
                          onTap: () async {
                            if (maxWidth > Utils.mobileWidth) {
                              setState(() {
                                sideWidget = ScenePage(
                                  project: project,
                                  scene: scene,
                                  key: UniqueKey(),
                                );
                              });
                            } else {
                              await Navigator.push(
                                  context,
                                  Utils.createRoute(
                                      ScenePage(project: project, scene: scene),
                                      Utils.RTL));
                              setState(() {
                                scenes = Utils.scenes;
                              });
                            }
                            //..............setstate moved from here to else
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border(
                                top:
                                    BorderSide(width: 2, color: Colors.black26),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '${scene.titles['en']}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Spacer(),
                                    (scene.day == 0 || scene.day == 2)
                                        ? Icon(
                                            Icons.wb_sunny,
                                            color: Colors.orange,
                                          )
                                        : Container(),
                                    (scene.day == 1 || scene.day == 2)
                                        ? Icon(
                                            Icons.nightlight_round,
                                            color: Colors.black,
                                          )
                                        : Container(),
                                    Text(
                                      scene.interior == 0
                                          ? "IN"
                                          : scene.interior == 1
                                              ? "EX"
                                              : "IN&EX",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w800),
                                    ),
                                    PopupMenuButton(
                                      onSelected: (s) {
                                        if (s == 0) {
                                          deleteScene(scene);
                                        }
                                      },
                                      itemBuilder: (context) {
                                        return [
                                          PopupMenuItem<int>(
                                              value: 0,
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .delete_outline_rounded,
                                                    size: 18,
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(4, 0, 0, 0),
                                                    child: Text("Delete"),
                                                  )
                                                ],
                                              ))
                                        ];
                                      },
                                    )
                                  ],
                                ),
                                Text(
                                  "${scene.gists['en']}",
                                  style: TextStyle(fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                RichText(
                                  text: TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(
                                          text:
                                              "${Utils.locationsMap['${scene.location}'].shootLocation}",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                              fontFamily: 'Poppins')),
                                      TextSpan(
                                          text:
                                              " (${Utils.locationsMap['${scene.location}'].location})",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54,
                                              fontFamily: 'Poppins')),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                Utils.createRoute(
                                                    SelectedActors(
                                                        project: project,
                                                        selectedArtists: List<
                                                                Actor>.generate(
                                                            scene
                                                                .artists.length,
                                                            (a) => Utils
                                                                    .artistsMap[
                                                                scene.artists[
                                                                    a]]),
                                                        scene: scene),
                                                    Utils.DTU));
                                          },
                                          child: Column(
                                            children: [
                                              Container(
                                                  padding: EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color: color,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            300),
                                                  ),
                                                  child: imagesInCircles(
                                                      List<String>.generate(
                                                          scene.artists.length,
                                                          (index) {
                                                        String r = Utils
                                                            .artistsMap[
                                                                '${scene.artists[index]}']
                                                            .image;
                                                        return r;
                                                      }),
                                                      10,
                                                      3,
                                                      10)),
                                              Text(
                                                "Artists",
                                                style: TextStyle(fontSize: 10),
                                              ),
                                            ],
                                          )),
                                      InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                Utils.createRoute(
                                                    SelectedCostumes(
                                                        project: project,
                                                        scene: scene,
                                                        costumes:
                                                            scene.costumes),
                                                    Utils.DTU));
                                          },
                                          child: Column(
                                            children: [
                                              Container(
                                                  padding: EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color: color,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            300),
                                                  ),
                                                  child: imagesInSquares(
                                                      List.generate(
                                                          scene.costumes.length,
                                                          (index) {
                                                        return scene
                                                                    .costumes[
                                                                        index][
                                                                        'costumes']
                                                                    .length >
                                                                0
                                                            ? Utils
                                                                .costumesMap[
                                                                    '${scene.costumes[index]['costumes'][0]}']
                                                                .referenceImage
                                                            : "";
                                                      }),
                                                      20,
                                                      3,
                                                      10)),
                                              Text(
                                                "Costumes",
                                                style: TextStyle(fontSize: 10),
                                              ),
                                            ],
                                          )),
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              Utils.createRoute(
                                                  SelectedProps(
                                                      project: project,
                                                      scene: scene,
                                                      selectedProps: List<
                                                              Prop>.generate(
                                                          scene.artists.length,
                                                          (p) => Utils.propsMap[
                                                              scene.props[p]])),
                                                  Utils.DTU));
                                        },
                                        child: Column(
                                          children: [
                                            Container(
                                                padding: EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: color,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          300),
                                                ),
                                                child: imagesInSquares(
                                                    List.generate(
                                                        scene.props.length,
                                                        (index) =>
                                                            Utils
                                                                .propsMap[
                                                                    '${scene.props[index]}']
                                                                .referenceImage ??
                                                            ""),
                                                    20,
                                                    3,
                                                    10)),
                                            Text(
                                              "Props",
                                              style: TextStyle(fontSize: 10),
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
                        );
                      }) +
                      [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 2,
                          color: Colors.black26,
                        )
                      ],
                    ),
                  ),
                  floatingActionButton: FloatingActionButton(
                    onPressed: () async {
                      await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddScene(
                                project: project,
                                isPopUp:
                                    maxWidth > Utils.mobileWidth ? false : true,
                                scene: null,
                              )));
                  setState(() {
                    scenes = Utils.scenes;
                  });
                },
                    backgroundColor: color,
                    child: Icon(
                      Icons.add,
                      color: background,
                      size: 36,
                    ),
                  ),
                ),
              ),
              if (maxWidth > Utils.mobileWidth)
                Flexible(
                  flex: 4,
                  child: Scaffold(
                    body: sideWidget ??
                        SizedBox.expand(
                            child: Container(
                              decoration: BoxDecoration(
                                  border:
                                  Border(left: BorderSide(
                                      color: Colors.black))),
                              child: Center(child: Text("No Field Selected")),
                            )),
                  ),
                )
            ],
          );
        });
  }

  deleteScene(Scene scene) async {
    Utils.showLoadingDialog(context, 'Deleting Scene');
    Map<dynamic, dynamic> body = {
      "id": "${scene.id}",
      "last_edit_by": "${scene.lastEditBy}",
      "project_id": "${scene.project}"
    };

    try {
      var resp = await http.post(Utils.DELETE_SCENE,
          body: jsonEncode(body),
          headers: {"Content-Type": "application/json"});
      // debugPrint(resp.body);
      var r = jsonDecode(resp.body);
      if (resp.statusCode == 200) {
        if (r['status'] == 'success') {
          await getAll();

          Navigator.pop(context);

          await Utils.showSuccessDialog(
              context,
              'Scene Deleted',
              'Scene has been deleted successfully.',
              Colors.green,
              background, () {
            Navigator.pop(context);
          });
        } else {
          Navigator.pop(context);
          await Utils.showErrorDialog(context, 'Unsuccessful', '${r['msg']}');
        }
      } else {
        Navigator.pop(context);
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
    // Navigator.pop(context);
  }
}
