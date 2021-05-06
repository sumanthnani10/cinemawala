import 'package:cinemawala/casting/actor.dart';
import 'package:cinemawala/casting/actor_page.dart';
import 'package:cinemawala/casting/add_actor.dart';
import 'package:cinemawala/projects/project.dart';
import 'package:cinemawala/scenes/add_scene.dart';
import 'package:cinemawala/scenes/scene.dart';
import 'package:flutter/material.dart';

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
                      TextButton.icon(
                        onPressed: () {
                          List<dynamic> selected = [];
                          for (Actor a in selectedActors) {
                            selected.add(a.id);
                          }
                          Navigator.pop(context, [selected, selectedActors]);
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
                        child: Wrap(
                          direction: Axis.horizontal,
                          children: <Widget>[
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AddActor(
                                            project: project,
                                          ),
                                        ));
                                  },
                                  splashColor: background1.withOpacity(0.2),
                                  child: Container(
                                    //color: color,
                                    margin: EdgeInsets.all(2),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(300),
                                    ),
                                    child: Text('+ Add Artist'),
                                  ),
                                )
                              ] +
                              List<Widget>.generate(showActors.length, (i) {
                                Actor actor = actors[i];
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (selectedActors
                                          .contains(showActors[i])) {
                                        selectedActors.remove(showActors[i]);
                                      } else {
                                        selectedActors.add(showActors[i]);
                                      }
                                    });
                                  },
                                  onLongPress: () {
                                    Navigator.push(
                                        context,
                                        Utils.createRoute(
                                            ActorPage(
                                                popUp: true,
                                                actor: actor,
                                                project: project),
                                            Utils.DTU));
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
    );
  }
}

class SelectedActors extends StatefulWidget {
  final Project project;
  final List<Actor> selectedArtists;
  final Scene scene;
  final bool isPopUp;

  SelectedActors(
      {Key key,
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
  final List<Actor> selectedArtists;
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
        body: Center(
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
                        child: Wrap(
                          direction: Axis.horizontal,
                          children: <Widget>[
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AddScene(
                                              project: project,
                                              scene: scene.toJson()),
                                        ));
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
                                    child: Text('+ Add Artist'),
                                  ),
                                )
                              ] +
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
    );
  }
}
