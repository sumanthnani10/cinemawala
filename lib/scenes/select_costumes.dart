import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinemawala/artists/actor.dart';
import 'package:cinemawala/artists/actor_page.dart';
import 'package:cinemawala/costumes/costume.dart';
import 'package:cinemawala/costumes/costume_page.dart';
import 'package:cinemawala/projects/project.dart';
import 'package:cinemawala/scenes/select_costume.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils.dart';
import 'scene.dart';

class SelectCostumes extends StatefulWidget {
  final Project project;
  final Scene scene;
  final List<Actor> selectedActors;
  final List<dynamic> costumes;

  SelectCostumes(
      {Key key,
         this.scene,
      @required this.project,
      @required this.selectedActors,
      @required this.costumes})
      : super(key: key);

  @override
  _SelectCostumes createState() =>
      _SelectCostumes(this.project, this.selectedActors, this.costumes,this.scene);
}

class _SelectCostumes extends State<SelectCostumes>
    with SingleTickerProviderStateMixin {
  final Project project;
  final List<Actor> selectedActors;
  List<dynamic> costumes;
  Scene scene;
  Color background, background1, color;
  TextEditingController searchController = new TextEditingController();
  String search = '';

  TextStyle nameStyle, characterStyle;

  _SelectCostumes(this.project, this.selectedActors, this.costumes,this.scene);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var showActors = costumes
        .where((e) => Utils.artistsMap[e['id']].names
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
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Center(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 48, horizontal: 24),
              constraints: BoxConstraints(maxWidth: Utils.mobileWidth),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              height: MediaQuery.of(context).size.height - (48 * 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                        "Costumes",
                        style: TextStyle(fontSize: 20, color: background1),
                        textAlign: TextAlign.center,
                      ),
                      Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(context, costumes);
                        },
                        label: Text(
                          "Done",
                          style: TextStyle(color: Colors.indigo),
                          textAlign: TextAlign.right,
                        ),
                        icon: Icon(
                          Icons.done,
                          size: 18,
                          color: Colors.indigo,
                        ),
                      ),
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
                        labelText: 'Search Artist',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.black)),
                        fillColor: Colors.white),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children:
                          List<Widget>.generate(showActors.length, (i) {
                            var actor = Utils.artistsMap[showActors[i]['id']];
                            var actorCostumes = showActors[i];
                            return ListTile(
                              onTap: () async {
                                if (project.role.permissions["costumes"]
                                        ["view"] ||
                                    project.role.permissions["scenes"]
                                        ["view"] ||
                                    project.role.permissions["schedule"]
                                        ["view"]) {
                                  List<Costume> selectedCostumes = [];
                                  actorCostumes['costumes'].forEach((c) {
                                    selectedCostumes
                                        .add(Utils.costumesMap['$c']);
                                  });
                                  var costs = await Navigator.push(
                                      context,
                                      Utils.createRoute(
                                          SelectCostume(
                                            actor: '${actor.names['en']}',
                                            character:
                                                '${actor.characters['en']}',
                                            project: project,
                                            selectedCostumes: selectedCostumes,
                                            sceneTitle: '',
                                          ),
                                          Utils.DTU));
                                  if (costs != null) {
                                    costumes[costumes.indexWhere((element) =>
                                            element['id'] == actor.id)]
                                        ['costumes'] = costs;
                                  }
                                  setState(() {});
                                } else {
                                  Utils.notAllowed(context);
                                }
                              },
                              onLongPress: () async {
                                if (project.role.permissions["casting"]
                                        ["view"] ||
                                    project.role.permissions["scenes"]
                                        ["view"] ||
                                    project.role.permissions["schedule"]
                                        ["view"]) {
                                  Navigator.push(
                                      context,
                                      Utils.createRoute(
                                          ActorPage(
                                            popUp: true,
                                            actor: actor,
                                            project: project,
                                          ),
                                          Utils.DTU));
                                } else {
                                  Utils.notAllowed(context);
                                }
                              },
                              title: Text(
                                "${actor.names['en']}",
                              ),
                              subtitle: Text("${actor.characters['en']}",
                                  style: characterStyle),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List<Widget>.generate(
                                        actorCostumes['costumes'].length, (j) {
                                      Costume costume = Utils.costumesMap[
                                          '${actorCostumes['costumes'][j]}'];
                                      return Container(
                                        margin: EdgeInsets.only(left: 4),
                                        padding: EdgeInsets.all(1),
                                        width: 25,
                                        height: 25,
                                        decoration: BoxDecoration(
                                          color: project.role.permissions[
                                                      "costumes"]["view"] ||
                                                  project.role
                                                          .permissions["scenes"]
                                                      ["view"] ||
                                                  project.role.permissions[
                                                      "schedule"]["view"]
                                              ? color
                                              : Colors.grey,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: CachedNetworkImage(
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
                                              errorWidget: (context, url,
                                                      error) =>
                                                  Container(
                                                    color: background,
                                                    child: Center(
                                                        child: Text(
                                                      '${costume.title}',
                                                      style: TextStyle(
                                                          color: background1,
                                                          fontSize: 8),
                                                    )),
                                                  ),
                                              useOldImageOnUrlChange: true,
                                              imageUrl:
                                                  costume.referenceImage ?? ''),
                                        ),
                                      );
                                    }) +
                                    [
                                      Container(
                                        margin: EdgeInsets.only(left: 4),
                                        width: 25,
                                        height: 25,
                                        decoration: BoxDecoration(
                                          color: project.role.permissions[
                                                      "costumes"]["view"] ||
                                                  project.role
                                                          .permissions["scenes"]
                                                      ["view"] ||
                                                  project.role.permissions[
                                                      "schedule"]["view"]
                                              ? color
                                              : Colors.grey,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Icon(Icons.edit),
                                      )
                                    ],
                              ),
                            );
                          })),
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

class SelectedCostumes extends StatefulWidget {
  final Project project;
  final List<dynamic> costumes;
  final bool isPopUp;
  final Scene scene;

  SelectedCostumes(
      {Key key,
      @required this.project,
      @required this.costumes,
      @required this.scene,
      this.isPopUp})
      : super(key: key);

  @override
  _SelectedCostumes createState() =>
      _SelectedCostumes(this.project, this.costumes, this.scene, this.isPopUp);
}

class _SelectedCostumes extends State<SelectedCostumes>
    with SingleTickerProviderStateMixin {
  final Project project;
  bool isPopUp;
  List<dynamic> costumes;
  Color background, background1, color;
  final Scene scene;
  TextEditingController searchController = new TextEditingController();
  String search = '';

  TextStyle nameStyle, characterStyle;

  _SelectedCostumes(this.project, this.costumes, this.scene, this.isPopUp);

  @override
  void initState() {
    isPopUp = isPopUp ?? true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Navigator.pop(context);
    var showActors = costumes
        .where((e) => Utils.artistsMap[e['id']].names
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
        if (isPopUp) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: isPopUp ? Colors.black26 : Colors.white,
        body: Container(
          decoration: BoxDecoration(
              border: Border(left: BorderSide(color: Colors.black))),
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Center(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                constraints: BoxConstraints(maxWidth: 480),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                height: MediaQuery.of(context).size.height - (48 * 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        isPopUp
                            ? IconButton(
                                icon: Icon(Icons.arrow_back_rounded),
                                onPressed: () {
                                  Navigator.pop(context);
                                })
                            : Container(),
                        Text(
                          "Selected Costumes",
                          style: TextStyle(fontSize: 20, color: background1),
                          textAlign: TextAlign.center,
                        ),
                        Spacer(),
                        IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () async {
                              Utils.showLoadingDialog(context, "Loading");
                              Set oldCostumes = {};

                              for (Map i in costumes) {
                                for (String j in i['costumes']) {
                                  oldCostumes.add(Utils.costumesMap[j]);
                                }
                              }

                              List selectedArtists = List<Actor>.generate(
                                  scene.artists.length,
                                  (ar) => Utils.artistsMap[scene.artists[ar]]);
                              var selected = await Navigator.push(
                                  context,
                                  Utils.createRoute(
                                      SelectCostumes(
                                        project: project,
                                        selectedActors: selectedArtists,
                                        costumes: scene.costumes,
                                      ),
                                      Utils.DTU));

                              if (selected != null) {
                                List sceneCostumesMap = selected;
                                Map body = {
                                  "artists": [],
                                  "costumes": [],
                                  "last_edit_on":
                                      DateTime.now().millisecondsSinceEpoch,
                                  "project_id": "${project.id}",
                                  "id": scene.id,
                                  "last_edit_by": Utils.USER_ID,
                                };

                                sceneCostumesMap = selected;

                                Set selectedCostumes = {};
                                for (var i in sceneCostumesMap) {
                                  for (var j in i['costumes']) {
                                    selectedCostumes.add(Utils.costumesMap[j]);
                                  }
                                }

                                Map<dynamic, dynamic> costumesOfArtists = {};
                                Map<dynamic, dynamic> artistsOfCostumes = {};

                                sceneCostumesMap.forEach((cl) {
                                  costumesOfArtists['${cl['id']}'] =
                                      cl['costumes'];
                                  cl['costumes'].forEach((c) {
                                    if (!artistsOfCostumes.containsKey(c)) {
                                      artistsOfCostumes[c] = [cl['id']];
                                    } else {
                                      if (!artistsOfCostumes[c]
                                          .contains(cl['id'])) {
                                        artistsOfCostumes[c].add(cl['id']);
                                      }
                                    }
                                  });
                                });

                                selectedArtists.forEach((a) {
                                  a = Actor.fromJson(a.toJson());
                                  a.costumes['${scene.id}'] =
                                      costumesOfArtists[a.id];
                                  body['artists'].add(a.toJson());
                                });

                                Set selectedCostumesIds = {};

                                selectedCostumes.forEach((c) {
                                  selectedCostumesIds.add(c.id);
                                  c = Costume.fromJson(c.toJson());
                                  if (!c.scenes.contains(scene.id)) {
                                    c.scenes.add(scene.id);
                                  }
                                  c.usedBy['${scene.id}'] =
                                      artistsOfCostumes[c.id];
                                  c.changed = c.scenes.length;
                                  body['costumes'].add(c.toJson());
                                });

                                oldCostumes.forEach((c) {
                                  if (!selectedCostumesIds.contains(c.id)) {
                                    c = Costume.fromJson(c.toJson());
                                    c.scenes.remove(scene.id);
                                    c.usedBy.remove('${scene.id}');
                                    c.changed = c.scenes.length;
                                    body['costumes'].add(c.toJson());
                                  }
                                });
                                body['scene_costumes'] = sceneCostumesMap;

                                try {
                                  var resp = await http.post(
                                      Utils.EDIT_SCENE_COSTUMES,
                                      body: jsonEncode(body),
                                      headers: {
                                        "Content-Type": "application/json"
                                      });
                                  // debugPrint(resp.body);
                                  var r = jsonDecode(resp.body);
                                  if (resp.statusCode == 200) {
                                    if (r['status'] == 'success') {
                                      scene.costumes = sceneCostumesMap;
                                      Utils.scenesMap[scene.id] = scene;
                                      Utils.scenes =
                                          Utils.scenesMap.values.toList();

                                      body['artists'].forEach((a) {
                                        Utils.artistsMap[a['id']] =
                                            Actor.fromJson(a);
                                      });
                                      Utils.artists =
                                          Utils.artistsMap.values.toList();

                                      body['costumes'].forEach((c) {
                                        Utils.costumesMap[c['id']] =
                                            Costume.fromJson(c);
                                      });
                                      Utils.costumes =
                                          Utils.costumesMap.values.toList();

                                      Navigator.pop(context);

                                      await Utils.showSuccessDialog(
                                          context,
                                          'Costumes Updated',
                                          'Costumes has been updated successfully.',
                                          Colors.green,
                                          background, () {
                                        Navigator.pop(context);
                                      });
                                    } else {
                                      Navigator.pop(context);
                                      await Utils.showErrorDialog(context,
                                          'Unsuccessful', '${r['msg']}');
                                    }
                                  } else {
                                    Navigator.pop(context);
                                    await Utils.showErrorDialog(
                                        context,
                                        'Something went wrong.',
                                        'Please try again after sometime.');
                                  }
                                } catch (e) {
                                  // debugPrint(e);
                                  Navigator.pop(context);
                                  await Utils.showErrorDialog(
                                      context,
                                      'Something went wrong.',
                                      'Please try again after sometime.');
                                }
                                Navigator.pop(context);
                                setState(() {});
                              } else {
                                Navigator.pop(context);
                              }
                            })
                      ],
                    ),
                    TextField(
                      controller: searchController,
                      maxLines: 1,
                      textInputAction: TextInputAction.search,
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
                          labelText: 'Search Artist',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.black)),
                          fillColor: Colors.white),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children:
                            List<Widget>.generate(showActors.length, (i) {
                              var actor = Utils.artistsMap[showActors[i]['id']];
                              var actorCostumes = showActors[i];
                              return ListTile(
                                onLongPress: () async {
                                  Navigator.push(
                                      context,
                                      Utils.createRoute(
                                          ActorPage(
                                            popUp: true,
                                            actor: actor,
                                            project: project,
                                          ),
                                          Utils.DTU));
                                },
                                title: Text(
                                  "${actor.names['en']}",
                                ),
                                subtitle: Text("${actor.characters['en']}",
                                    style: characterStyle),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List<Widget>.generate(
                                      actorCostumes['costumes'].length, (j) {
                                    Costume costume = Utils.costumesMap[
                                        '${actorCostumes['costumes'][j]}'];
                                    return InkWell(
                                      onTap: () async {
                                        await Navigator.push(
                                            context,
                                            Utils.createRoute(
                                                CostumesPage(
                                                  project: project,
                                                  costume: costume,
                                                ),
                                                Utils.DTU));
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(left: 4),
                                        padding: EdgeInsets.all(1),
                                        width: 35,
                                        height: 35,
                                        decoration: BoxDecoration(
                                          color: color,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: CachedNetworkImage(
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
                                              errorWidget: (context, url,
                                                      error) =>
                                                  Container(
                                                    color: background,
                                                    child: Center(
                                                        child: Text(
                                                      '${costume.title}',
                                                      style: TextStyle(
                                                          color: background1,
                                                          fontSize: 8),
                                                    )),
                                                  ),
                                              useOldImageOnUrlChange: true,
                                              imageUrl:
                                                  costume.referenceImage ?? ''),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              );
                            })),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
