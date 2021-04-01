import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinemawala/casting/actor.dart';
import 'package:cinemawala/casting/actor_page.dart';
import 'package:cinemawala/costumes/costume.dart';
import 'package:cinemawala/costumes/costume_page.dart';
import 'package:cinemawala/projects/project.dart';
import 'package:cinemawala/scenes/select_actors.dart';
import 'package:cinemawala/scenes/select_costume.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

class SelectCostumes extends StatefulWidget {
  final Project project;
  final List<Actor> selectedActors;
  final List<dynamic> costumes;

  SelectCostumes(
      {Key key,
      @required this.project,
      @required this.selectedActors,
      @required this.costumes})
      : super(key: key);

  @override
  _SelectCostumes createState() =>
      _SelectCostumes(this.project, this.selectedActors, this.costumes);
}

class _SelectCostumes extends State<SelectCostumes>
    with SingleTickerProviderStateMixin {
  final Project project;
  final List<Actor> selectedActors;
  List<dynamic> costumes;
  Color background, background1, color;
  TextEditingController searchController = new TextEditingController();
  String search = '';

  TextStyle nameStyle, characterStyle;

  _SelectCostumes(this.project, this.selectedActors, this.costumes);

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
                  Material(
                    color: background,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            PageRouteBuilder(
                                pageBuilder: (_, __, ___) => SelectActors(
                                      project: project,
                                    ),
                                opaque: false));
                      },
                      splashColor: background1.withOpacity(0.2),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "+ Add Artist",
                          style: TextStyle(color: Colors.indigo),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
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
                                List<Costume> selectedCostumes = [];
                                actorCostumes['costumes'].forEach((c) {
                                  selectedCostumes.add(Utils.costumesMap['$c']);
                                });
                                var costs = await Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                        pageBuilder: (_, __, ___) =>
                                            SelectCostume(
                                              actor:
                                                  '${actor.names['English']}',
                                              character:
                                                  '${actor.characters['English']}',
                                              project: project,
                                              selectedCostumes:
                                                  selectedCostumes,
                                              sceneTitle: '',
                                            ),
                                        opaque: false));
                                if (costs != null) {
                                  costumes[costumes.indexWhere((element) =>
                                          element['id'] == actor.id)]
                                      ['costumes'] = costs;
                                }
                                setState(() {});
                              },
                              onLongPress: () async {
                                Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                        pageBuilder: (_, __, ___) => ActorPopUp(
                                              actor: actor,
                                              project: project,
                                            ),
                                        opaque: false));
                              },
                              title: Text(
                                "${actor.names['English']}",
                              ),
                              subtitle: Text("${actor.characters['English']}",
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
                                                      LinearProgressIndicator(
                                                        value:
                                                            progress.progress,
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
                                          color: color,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Icon(Icons.add),
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

  SelectedCostumes({Key key, @required this.project, @required this.costumes})
      : super(key: key);

  @override
  _SelectedCostumes createState() =>
      _SelectedCostumes(this.project, this.costumes);
}

class _SelectedCostumes extends State<SelectedCostumes>
    with SingleTickerProviderStateMixin {
  final Project project;
  List<dynamic> costumes;
  Color background, background1, color;
  TextEditingController searchController = new TextEditingController();
  String search = '';

  TextStyle nameStyle, characterStyle;

  _SelectedCostumes(this.project, this.costumes);

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
                        "Selected Costumes",
                        style: TextStyle(fontSize: 20, color: background1),
                        textAlign: TextAlign.center,
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
                                    PageRouteBuilder(
                                        pageBuilder: (_, __, ___) => ActorPopUp(
                                              actor: actor,
                                              project: project,
                                            ),
                                        opaque: false));
                              },
                              title: Text(
                                "${actor.names['English']}",
                              ),
                              subtitle: Text("${actor.characters['English']}",
                                  style: characterStyle),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List<Widget>.generate(
                                    actorCostumes['costumes'].length, (j) {
                                  Costume costume = Utils.costumesMap[
                                      '${actorCostumes['costumes'][j]}'];
                                  return InkWell(
                                    onTap: () async {
                                      var back = await Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                  pageBuilder: (_, __, ___) =>
                                                      CostumesPage(
                                                        project: project,
                                                        costume: costume,
                                                      ),
                                                  opaque: false)) ??
                                          false;
                                      if (back) {
                                        Utils.showLoadingDialog(
                                            context, 'Getting Costumes');
                                        await Utils.getCostumes(
                                            context, project.id);
                                        Navigator.pop(context);
                                        setState(() {});
                                      }
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(left: 4),
                                      padding: EdgeInsets.all(1),
                                      width: 35,
                                      height: 35,
                                      decoration: BoxDecoration(
                                        color: color,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: CachedNetworkImage(
                                            fit: BoxFit.cover,
                                            progressIndicatorBuilder:
                                                (context, url, progress) =>
                                                    LinearProgressIndicator(
                                                      value: progress.progress,
                                                    ),
                                            errorWidget:
                                                (context, url, error) =>
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
    );
  }
}
