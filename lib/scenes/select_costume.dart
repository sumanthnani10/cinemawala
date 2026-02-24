import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinemawala/costumes/add_costume.dart';
import 'package:cinemawala/costumes/costume.dart';
import 'package:cinemawala/costumes/costume_page.dart';
import 'package:cinemawala/projects/project.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

class SelectCostume extends StatefulWidget {
  final String sceneTitle, actor, character;
  final Project project;
  final List<Costume> selectedCostumes;

  SelectCostume(
      {Key key,
      this.sceneTitle,
      this.actor,
      this.character,
      @required this.project,
      @required this.selectedCostumes})
      : super(key: key);

  @override
  _SelectCostume createState() => _SelectCostume(this.sceneTitle, this.actor,
      this.character, this.project, this.selectedCostumes);
}

class _SelectCostume extends State<SelectCostume>
    with SingleTickerProviderStateMixin {
  final String sceneTitle, actor, character;
  Color background, background1, color;
  final Project project;
  List<Costume> costumes, selectedCostumes;

  TextEditingController search_controller = new TextEditingController();
  String search = '';

  _SelectCostume(this.sceneTitle, this.actor, this.character, this.project,
      this.selectedCostumes);

  @override
  void initState() {
    costumes = Utils.costumes;
    super.initState();
  }

  setCostumes() async {
    costumes = Utils.costumes;
    if (costumes == null) {
      Utils.showLoadingDialog(context, 'Getting Costumes');
      costumes = await Utils.getCostumes(context, project.id);
      Navigator.pop(context);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var showCostumes = costumes.where((c) => c.title.contains(search)).toList();
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
                        "Costume",
                        style: TextStyle(fontSize: 20, color: background1),
                        textAlign: TextAlign.left,
                      ),
                      Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          List<dynamic> selectedCosts = [];
                          selectedCostumes.forEach((c) {
                            selectedCosts.add(c.id);
                          });
                          Navigator.pop(context, selectedCosts);
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
                    controller: search_controller,
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
                              search_controller.text = '';
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
                        labelText: 'Search Costume',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.black)),
                        fillColor: Colors.white),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      if(project.role.permissions["costumes"]["add"] ||
                          project.role.permissions["scenes"]["add"] ||
                          project.role.permissions["schedule"]["add"]||
                          project.role.permissions["costumes"]["edit"] ||
                          project.role.permissions["scenes"]["edit"] ||
                          project.role.permissions["schedule"]["edit"]
                      ){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddCostume(
                                  project: project,
                                  )));
                      }
                      else{
                        Utils.notAllowed(context);
                      }
                    },
                    label: Text(
                      "Add Costume",
                      style: TextStyle(
                          color:project.role.permissions["costumes"]["add"] ||
                      project.role.permissions["scenes"]["add"] ||
                      project.role.permissions["schedule"]["add"]||
                      project.role.permissions["costumes"]["edit"] ||
                      project.role.permissions["scenes"]["edit"] ||
                      project.role.permissions["schedule"]["edit"]
                      ? Colors.indigo : Colors.grey),
                      textAlign: TextAlign.right,
                    ),
                    icon: Icon(
                      Icons.add,
                      size: 18,
                      color: Colors.indigo,
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                      child: Wrap(
                        direction: Axis.horizontal,
                        children:
                            List<Widget>.generate(showCostumes.length, (i) {
                          Costume costume = showCostumes[i];
                          return InkWell(
                            splashColor: background1.withOpacity(0.2),
                            onTap: () {
                              if(project.role.permissions["costumes"]["add"] ||
                                  project.role.permissions["scenes"]["add"] ||
                                  project.role.permissions["schedule"]["add"]||
                                  project.role.permissions["costumes"]["edit"] ||
                                  project.role.permissions["scenes"]["edit"] ||
                                  project.role.permissions["schedule"]["edit"]
                              ){
                                setState(() {
                                  if (selectedCostumes.contains(costume)) {
                                    selectedCostumes.remove(costume);
                                  } else {
                                    if (selectedCostumes.length < 3) {
                                      selectedCostumes.add(costume);
                                    } else {}
                                  }
                                });
                              }
                              else{
                                Utils.notAllowed(context);
                              }
                            },
                            onLongPress: () {
                              Navigator.push(
                                  context,
                                  Utils.createRoute(
                                      CostumesPage(
                                        costume: costume,
                                        project: project,
                                      ),
                                      Utils.DTU));
                            },
                            child: Container(
                              height: 70,
                              width: 70,
                              padding: EdgeInsets.all(
                                  selectedCostumes.contains(costume) ? 2 : 1),
                              margin: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: selectedCostumes.contains(costume)
                                    ? Colors.indigo
                                    : background1,
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
                                    errorWidget: (context, url, error) =>
                                        Container(
                                          color: background,
                                          child: Center(
                                              child: Text(
                                            '${costume.title}',
                                            style:
                                                TextStyle(color: background1),
                                          )),
                                        ),
                                    useOldImageOnUrlChange: true,
                                    imageUrl: costume.referenceImage),
                              ),
                            ),
                          );
                        }),
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
