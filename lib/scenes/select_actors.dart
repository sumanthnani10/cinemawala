import 'dart:convert';

import 'package:cinemawala/artists/actor.dart';
import 'package:cinemawala/artists/actor_page.dart';
import 'package:cinemawala/artists/add_actor.dart';
import 'package:cinemawala/costumes/costume.dart';
import 'package:cinemawala/projects/project.dart';
import 'package:cinemawala/scenes/scene.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils.dart';

class SelectActors extends StatefulWidget {
  final Project project;
  final List<Actor> selectedActors;

  SelectActors({Key key, @required this.project, this.selectedActors})
      : super(key: key);

  @override
  _SelectActors createState() =>
      _SelectActors(this.project, this.selectedActors);
}

class _SelectActors extends State<SelectActors>
    with SingleTickerProviderStateMixin {
  final Project project;
  Color background, background1, color;
  List<Actor> actors = [], selectedActors;
  ScrollController cardScrollController = new ScrollController();

  TextEditingController searchController = new TextEditingController();
  String search = '';

  _SelectActors(this.project, this.selectedActors);

  @override
  void initState() {
    actors = Utils.artists.sublist(0).toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var showActors = actors
        .where((e) =>
        e.names.toString().toLowerCase().contains(search.toLowerCase()))
        .toList();
    showActors.sort((a, b) {
      int x, y;
      x = selectedActors.contains(a) ? 1 : 0;
      y = selectedActors.contains(b) ? 1 : 0;
      return y - x;
    });
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
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              height: MediaQuery.of(context).size.height - (48 * 2),
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
                        "Artists",
                        style: TextStyle(fontSize: 20, color: background1),
                        textAlign: TextAlign.center,
                      ),
                      Spacer(),
                      InkWell(
                        onTap: () {
                          if(
                          project.role.permissions["casting"]["add"] || project.role.permissions["schedule"]["add"] ||
                              project.role.permissions["scenes"]["add"]
                          ){
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddActor(
                                    project: project,
                                  ),
                                ));
                          }
                          else{
                            Utils.notAllowed(context);
                          }
                        },
                        child: Container(
                          //color: color,
                          margin: EdgeInsets.all(2),
                          padding: EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          child: Text('+ Add Artist'),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          List<dynamic> selected = [];
                          for (Actor a in selectedActors) {
                            selected.add(a.id);
                          }
                          Navigator.pop(context, [selected, selectedActors]);
                        },
                        label: Text(
                          "Save",
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
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          //direction: Axis.vertical,
                          children: <Widget>[
                          ] +
                              List<Widget>.generate(showActors.length, (i) {
                                Actor actor = actors[i];
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      if(
                                      project.role.permissions["casting"]["add"] || project.role.permissions["schedule"]["add"] ||
                                          project.role.permissions["scenes"]["add"] ||
                                          project.role.permissions["casting"]["edit"] || project.role.permissions["schedule"]["edit"] ||
                                          project.role.permissions["scenes"]["edit"]
                                      ){
                                        if (selectedActors
                                            .contains(showActors[i])) {
                                          selectedActors.remove(showActors[i]);
                                        } else {
                                          selectedActors.add(showActors[i]);
                                        }
                                      }
                                      else{
                                        Utils.notAllowed(context);
                                      }
                                    });
                                  },
                                  onLongPress: () {
                                    if(
                                    project.role.permissions["casting"]["view"] || project.role.permissions["schedule"]["view"] ||
                                        project.role.permissions["scenes"]["view"]){
                                      Navigator.push(
                                          context,
                                          Utils.createRoute(
                                              ActorPage(
                                                  popUp: true,
                                                  actor: actor,
                                                  project: project),
                                              Utils.DTU));
                                    }else{
                                      Utils.notAllowed(context);
                                    }
                                  },
                                  splashColor: background1.withOpacity(0.2),
                                  child: Container(
                                    //color: color,
                                    margin: EdgeInsets.all(2),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color:
                                      selectedActors.contains(showActors[i])
                                          ? color
                                          : color.withOpacity(8 / 16),
                                      borderRadius: BorderRadius.circular(300),
                                    ),
                                    child: Text('${ showActors[i].names['en']!=null ? showActors[i].names['en'] : '-'} as ${showActors[i].characters['en']}'),
                                  ),
                                );
                              }),
                        ),
                      ),
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

class SelectedActors extends StatefulWidget {
  final Project project;
  final List<Actor> selectedArtists;
  final Scene scene;
  final bool isPopUp;

  SelectedActors({Key key,
    @required this.project,
    @required this.selectedArtists,
    @required this.scene,
    this.isPopUp})
      : super(key: key);

  @override
  _SelectedActors createState() => _SelectedActors(
      this.project, this.selectedArtists, this.scene, this.isPopUp);
}

class _SelectedActors extends State<SelectedActors>
    with SingleTickerProviderStateMixin {
  final Project project;
  Color background, background1, color;
  final Scene scene;
  bool isPopUp;
  List<Actor> selectedArtists;
  TextEditingController searchController = new TextEditingController();
  String search = '';

  _SelectedActors(this.project, this.selectedArtists, this.scene, this.isPopUp);

  @override
  void initState() {
    isPopUp = isPopUp ?? true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var showActors = selectedArtists
        .where((e) =>
        e.names.toString().toLowerCase().contains(search.toLowerCase()))
        .toList();
    /*showActors.sort((a,b) {
      int x, y;
      x = count.contains(a)?1:0;
      y = count.contains(b)?1:0;
      return y-x;
    });*/
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
        backgroundColor: isPopUp ? Colors.black26 : Colors.white,
        body: Container(
          decoration: isPopUp ? BoxDecoration(
            border: Border(left: BorderSide(color: Colors.white))
          ):
          BoxDecoration(
              border: Border(left: BorderSide(color: Colors.black))
          ),
          child: Center(
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Container(
                margin: EdgeInsets.symmetric(
                    vertical: isPopUp ? 48 : 8, horizontal: isPopUp ? 24 : 4),
                constraints: BoxConstraints(maxWidth: Utils.mobileWidth),
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                height: MediaQuery.of(context).size.height - (48 * 2),
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
                        if (isPopUp)
                          IconButton(
                              icon: Icon(Icons.arrow_back_rounded),
                              onPressed: () {
                                Navigator.pop(context);
                              }),
                        Text(
                          "Selected Artists",
                          style: TextStyle(fontSize: 20, color: background1),
                          textAlign: TextAlign.center,
                        ),
                        Spacer(),
                        IconButton(
                            icon: Icon(Icons.edit_rounded),
                            onPressed: () async {
                              Utils.showLoadingDialog(context, 'Loading');

                              var selected = await Navigator.push(
                                  context,
                                  Utils.createRoute(
                                      SelectActors(
                                        project: project,
                                        selectedActors:
                                            selectedArtists.sublist(0),
                                      ),
                                      Utils.DTU));

                              Map sceneMap = {};
                              if (selected != null) {
                                Set selectedCostumes = {};
                                List oldArtists = selectedArtists.sublist(0);
                                Set oldCostumes = {};

                                for (Map i in scene.costumes) {
                                  for (String j in i['costumes']) {
                                    oldCostumes.add(Utils.costumesMap[j]);
                                  }
                                }

                                Map body = {
                                  "artists": [],
                                  "costumes": [],
                                  "last_edit_on":
                                      DateTime.now().millisecondsSinceEpoch,
                                  "project_id": "${project.id}",
                                  "id": scene.id,
                                  "last_edit_by": Utils.USER_ID,
                                };

                                sceneMap['artists'] = selected[0];
                                List _selectedArtists = selected[1];
                                List costumes = [];
                                int ind = 0;

                                sceneMap['artists'].forEach((a) {
                                  costumes.add({"id": a});
                                  var oldCostume = scene.costumes.firstWhere(
                                      (e) => e['id'] == a,
                                      orElse: () => null);
                                  if (oldCostume != null) {
                                    costumes[ind]['costumes'] =
                                        oldCostume["costumes"];
                                  } else {
                                    costumes[ind]['costumes'] = [];
                                  }
                                  ind++;
                                });
                                sceneMap['costumes'] = costumes;

                                for (var i in sceneMap['costumes']) {
                                  for (var j in i['costumes']) {
                                    selectedCostumes.add(Utils.costumesMap[j]);
                                  }
                                }

                                Map<dynamic, dynamic> costumesOfArtists = {};
                                Map<dynamic, dynamic> artistsOfCostumes = {};

                                costumes.forEach((cl) {
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

                                oldArtists.forEach((a) {
                                  if (!sceneMap['artists'].contains(a.id)) {
                                    a = Actor.fromJson(a.toJson());
                                    if (a.scenes.contains(scene.id)) {
                                      a.scenes.remove(scene.id);
                                    }
                                    a.costumes.remove('${scene.id}');
                                    body['artists'].add(a.toJson());
                                  }
                                });

                                _selectedArtists.forEach((a) {
                                  a = Actor.fromJson(a.toJson());
                                  if (!a.scenes.contains(scene.id)) {
                                    a.scenes.add(scene.id);
                                  }
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

                                body['scene_costumes'] = sceneMap['costumes'];
                                body['scene_artists'] = sceneMap['artists'];

                                try {
                                  var resp = await http.post(
                                      Utils.EDIT_SCENE_ARTISTS,
                                      body: jsonEncode(body),
                                      headers: {
                                        "Content-Type": "application/json"
                                      });
                                  // debugPrint(resp.body);
                                  var r = jsonDecode(resp.body);
                                  if (resp.statusCode == 200) {
                                    if (r['status'] == 'success') {
                                      scene.costumes = sceneMap['costumes'];
                                      scene.artists = sceneMap['artists'];
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
                                          'Artists Updated',
                                          'Artists has been updated successfully.',
                                          Colors.green,
                                          background, () {
                                        Navigator.pop(context);
                                      });
                                    } else {
                                      Navigator.pop(context);
                                      await Utils.showErrorDialog(
                                          context, 'Unsuccessful', '${r['msg']}');
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
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children:
                            List<Widget>.generate(showActors.length, (i) {
                              Actor actor = showActors[i];
                              return InkWell(
                                onLongPress: () {
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
                                splashColor: background1.withOpacity(0.2),
                                child: Container(
                                  //color: color,
                                  margin: EdgeInsets.all(2),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(300),
                                  ),
                                  child: Text('${showActors[i].names['en']}'),
                                ),
                              );
                            }),
                          ),
                        ),
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
