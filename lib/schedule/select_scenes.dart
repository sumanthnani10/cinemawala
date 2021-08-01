import 'package:cinemawala/projects/project.dart';
import 'package:cinemawala/scenes/add_scene.dart';
import 'package:cinemawala/scenes/scene.dart';
import 'package:cinemawala/scenes/scene_page.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

class SelectScenes extends StatefulWidget {
  final Project project;
  final List<Scene> selectedScenes;

  SelectScenes({Key key, @required this.project, this.selectedScenes})
      : super(key: key);

  @override
  _SelectScenes createState() =>
      _SelectScenes(this.project, this.selectedScenes);
}

class _SelectScenes extends State<SelectScenes>
    with SingleTickerProviderStateMixin {
  final Project project;
  Color background, background1, color;
  List<Scene> allScenes = [], selectedScenes;

  TextEditingController searchController = new TextEditingController();
  String search = '';

  _SelectScenes(this.project, this.selectedScenes);

  @override
  void initState() {
    allScenes = Utils.scenes.sublist(0).toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var showScenes = allScenes
        .where((e) =>
            e.titles.toString().toLowerCase().contains(search.toLowerCase()))
        .toList();
    showScenes.sort((a, b) {
      int x, y;
      x = selectedScenes.contains(a) ? 1 : 0;
      y = selectedScenes.contains(b) ? 1 : 0;
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
                        "Scenes",
                        style: TextStyle(fontSize: 20, color: background1),
                        textAlign: TextAlign.center,
                      ),
                      Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          List<dynamic> selected = [];
                          for (Scene a in selectedScenes) {
                            selected.add(a.id);
                          }
                          Navigator.pop(context, selected);
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
                        labelText: 'Search Scene',
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
                          children: <Widget>[
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AddScene(
                                            project: project,
                                            scene: null,
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
                                    child: Text('+ Create Scene'),
                                  ),
                                )
                              ] +
                              List<Widget>.generate(showScenes.length, (i) {
                                Scene scene = showScenes[i];
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (selectedScenes.contains(scene)) {
                                        selectedScenes.remove(scene);
                                      } else {
                                        selectedScenes.add(scene);
                                      }
                                    });
                                  },
                                  onLongPress: () {
                                    Navigator.push(
                                        context,
                                        Utils.createRoute(
                                            ScenePage(
                                              project: project,
                                              scene: scene,
                                              popUp: true,
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
                                      color: selectedScenes.contains(scene)
                                          ? color
                                          : color.withOpacity(8 / 16),
                                      borderRadius: BorderRadius.circular(300),
                                    ),
                                    child: Text('${scene.titles['en']}'),
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

class SelectedScenes extends StatefulWidget {
  final Project project;
  final List<Scene> selectedScenes;

  SelectedScenes(
      {Key key, @required this.project, @required this.selectedScenes})
      : super(key: key);

  @override
  _SelectedScenes createState() =>
      _SelectedScenes(this.project, this.selectedScenes);
}

class _SelectedScenes extends State<SelectedScenes>
    with SingleTickerProviderStateMixin {
  final Project project;
  Color background, background1, color;
  final List<Scene> selectedScenes;
  TextEditingController searchController = new TextEditingController();
  String search = '';

  _SelectedScenes(this.project, this.selectedScenes);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var showScenes = selectedScenes
        .where((e) =>
            e.titles.toString().toLowerCase().contains(search.toLowerCase()))
        .toList();
    /*showScenes.sort((a,b) {
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
                        "Selected Scenes",
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
                        labelText: 'Search Scene',
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
                          children:
                              List<Widget>.generate(showScenes.length, (i) {
                            Scene scene = showScenes[i];
                            return InkWell(
                              onLongPress: () {
                                Navigator.push(context, null);
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
                                child: Text('${scene.titles['en']}'),
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
