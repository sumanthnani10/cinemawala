import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinemawala/projects/project.dart';
import 'package:cinemawala/props/add_prop.dart';
import 'package:cinemawala/props/prop.dart';
import 'package:cinemawala/props/prop_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../utils.dart';
import 'scene.dart';

class SelectProps extends StatefulWidget {
  final Project project;
  final List<Prop> selectedProps;

  const SelectProps(
      {Key key, @required this.project, @required this.selectedProps})
      : super(key: key);

  @override
  _SelectProps createState() => _SelectProps(project, selectedProps);
}

class _SelectProps extends State<SelectProps> {
  final Project project;
  Color background, background1, color;
  List<Prop> props = [], selectedProps;
  ScrollController cardScrollController = new ScrollController();

  TextEditingController searchController = new TextEditingController();
  String search = '';

  _SelectProps(this.project, this.selectedProps);

  @override
  void initState() {
    props = Utils.props.sublist(0).toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var showProps = props
        .where((e) =>
        e.title.toString().toLowerCase().contains(search.toLowerCase()))
        .toList();
    showProps.sort((a, b) {
      int x, y;
      x = selectedProps.contains(a) ? 1 : 0;
      y = selectedProps.contains(b) ? 1 : 0;
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
                        "Properties",
                        style: TextStyle(fontSize: 20, color: background1),
                        textAlign: TextAlign.center,
                      ),
                      Spacer(),
                      InkWell(
                        onTap: () {
                          if(project.role.permissions["props"]["add"] ||
                              project.role.permissions["scenes"]["add"] ||
                              project.role.permissions["schedule"]["add"] ||
                              project.role.permissions["props"]["edit"] ||
                              project.role.permissions["scenes"]["edit"] ||
                              project.role.permissions["schedule"]["edit"]){
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddProp(
                                    project: project,
                                  ),
                                ));
                          }
                          else{
                            Utils.notAllowed(context);
                          }
                        },
                        child: Container(
                          margin: EdgeInsets.all(2),
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          child: Icon(
                            Icons.add,
                            size: 24,
                            color: Colors.indigo,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          List<dynamic> selected = [];
                          for (Prop a in selectedProps) {
                            selected.add(a.id);
                          }
                          Navigator.pop(context, [selected, selectedProps]);
                        },
                        label: Text(
                          "",
                          style: TextStyle(color: Colors.indigo),
                          textAlign: TextAlign.right,
                        ),
                        icon: Icon(
                          Icons.done,
                          size: 24,
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
                        labelText: 'Search Property',
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
                          spacing: 4,
                          runSpacing: 4,
                          children: <Widget>[
                          ] +
                              List<Widget>.generate(showProps.length, (i) {
                                Prop prop = showProps[i];
                                return InkWell(
                                  onTap: () {
                                    if (project.role.permissions["props"]
                                            ["add"] ||
                                        project.role.permissions["props"]
                                            ["edit"] ||
                                        project.role.permissions["scenes"]
                                            ["edit"] ||
                                        project.role.permissions["scenes"]
                                            ["add"] ||
                                        project.role.permissions["schedule"]
                                            ["edit"] ||
                                        project.role.permissions["schedule"]
                                            ["add"]) {
                                      setState(() {
                                        if (selectedProps
                                            .contains(showProps[i])) {
                                          selectedProps.remove(showProps[i]);
                                        } else {
                                          selectedProps.add(showProps[i]);
                                        }
                                      });
                                    }else{
                                      Utils.notAllowed(context);
                                    }
                                  },
                                  onLongPress: () {
                                    Navigator.push(
                                        context,
                                        Utils.createRoute(
                                            PropPage(
                                              project: project,
                                              prop: showProps[i],
                                            ),
                                            Utils.DTU));
                                  },
                                  splashColor: background1.withOpacity(0.2),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        height: 70,
                                        width: 70,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: selectedProps
                                                      .contains(showProps[i])
                                                  ? Colors.blue
                                                  : Colors.white,
                                              width: 2),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: prop.referenceImage == ''
                                            ? Container(
                                                height: 70,
                                                width: 70,
                                                color: Colors.grey,
                                                child: Center(
                                                    child: Text(
                                                  'No Image',
                                                  style: TextStyle(
                                                      color: background),
                                                )),
                                              )
                                            : ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: CachedNetworkImage(
                                                    fit: BoxFit.cover,
                                                    progressIndicatorBuilder:
                                                        (context, url,
                                                                progress) =>
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
                                                        Center(
                                                            child:
                                                                Text('Image')),
                                                    useOldImageOnUrlChange:
                                                        true,
                                                    imageUrl:
                                                        prop.referenceImage),
                                              ),
                                      )),
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

class SelectedProps extends StatefulWidget {
  final Project project;
  final List<Prop> selectedProps;
  final bool isPopUp;
  final Scene scene;

  SelectedProps({Key key,
    @required this.project,
    @required this.selectedProps,
    @required this.scene,
    this.isPopUp})
      : super(key: key);

  @override
  _SelectedProps createState() => _SelectedProps(
      this.project, this.selectedProps, this.isPopUp, this.scene);
}

class _SelectedProps extends State<SelectedProps>
    with SingleTickerProviderStateMixin {
  final Project project;
  bool isPopUp;
  final Scene scene;
  Color background, background1, color;
  final List<Prop> selectedProps;
  TextEditingController searchController = new TextEditingController();
  String search = '';

  _SelectedProps(this.project, this.selectedProps, this.isPopUp, this.scene);

  @override
  void initState() {
    isPopUp = isPopUp ?? true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var showProps = selectedProps
        .where((e) =>
        e.title.toString().toLowerCase().contains(search.toLowerCase()))
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
        if(isPopUp){
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: isPopUp ? Colors.black26 : Colors.white,
        body: Container(
          decoration: BoxDecoration(border: Border(left: BorderSide(color: Colors.black))),
          child: Center(
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                constraints: BoxConstraints(maxWidth: 480),
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
                        isPopUp ? IconButton(
                                icon: Icon(Icons.arrow_back_rounded),
                                onPressed: () {
                                  Navigator.pop(context);
                                })
                            : Container(),
                        Text(
                          "Selected Props",
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
                                      SelectProps(
                                        project: project,
                                        selectedProps: selectedProps.sublist(0),
                                      ),
                                      Utils.DTU));

                              if (selected != null) {
                                Map sceneMap = {};
                                List oldProps = selectedProps.sublist(0);

                                Map body = {
                                  "props": [],
                                  "last_edit_on":
                                      DateTime.now().millisecondsSinceEpoch,
                                  "project_id": "${project.id}",
                                  "id": scene.id,
                                  "last_edit_by": Utils.USER_ID,
                                };

                                sceneMap['props'] = selected[0];
                                List _selectedProps = selected[1];

                                oldProps.forEach((p) {
                                  if (!sceneMap['props'].contains(p.id)) {
                                    p = Prop.fromJson(p.toJson());
                                    if (p.usedIn.contains(scene.id)) {
                                      p.usedIn.remove(scene.id);
                                    }
                                    body['props'].add(p.toJson());
                                  }
                                });

                                _selectedProps.forEach((p) {
                                  p = Prop.fromJson(p.toJson());
                                  if (!p.usedIn.contains(scene.id)) {
                                    p.usedIn.add(scene.id);
                                  }
                                  body['props'].add(p.toJson());
                                });

                                body['scene_props'] = sceneMap['props'];

                                try {
                                  var resp = await http.post(
                                      Utils.EDIT_SCENE_PROPS,
                                      body: jsonEncode(body),
                                      headers: {
                                        "Content-Type": "application/json"
                                      });
                                  // debugPrint(resp.body);
                                  var r = jsonDecode(resp.body);
                                  if (resp.statusCode == 200) {
                                    if (r['status'] == 'success') {
                                      scene.props = sceneMap['props'];
                                      Utils.scenesMap[scene.id] = scene;
                                      Utils.scenes =
                                          Utils.scenesMap.values.toList();

                                      body['props'].forEach((a) {
                                        Utils.propsMap[a['id']] =
                                            Prop.fromJson(a);
                                      });
                                      Utils.props =
                                          Utils.propsMap.values.toList();

                                      Navigator.pop(context);

                                      await Utils.showSuccessDialog(
                                          context,
                                          'Props Updated',
                                          'Props has been updated successfully.',
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
                          labelText: 'Search Prop',
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
                            spacing: 4,
                            runSpacing: 4,
                            children: <Widget>[
                            ] +
                                List<Widget>.generate(showProps.length, (i) {
                                  Prop prop = showProps[i];
                                  return InkWell(
                                    onLongPress: () async {
                                      await Navigator.push(
                                          context,
                                          Utils.createRoute(
                                              PropPage(
                                                prop: prop,
                                                project: project,
                                              ),
                                              Utils.DTU));
                                    },
                                    splashColor: background1.withOpacity(0.2),
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child:
                                        prop.referenceImage == ''
                                            ? Container(
                                          color: Colors.grey,
                                          child: Center(
                                              child: Text(
                                                'No Image',
                                                style: TextStyle(color: background),
                                              )),
                                        )
                                            : Container(
                                          height: 70,
                                                width: 70,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color:
                                                          Utils.notPermitted),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: CachedNetworkImage(
                                                      fit: BoxFit.cover,
                                                      progressIndicatorBuilder:
                                                          (context, url,
                                                                  progress) =>
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
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Center(
                                                              child: Text(
                                                                  'Image')),
                                                      useOldImageOnUrlChange:
                                                          true,
                                                      imageUrl:
                                                          prop.referenceImage),
                                                ),
                                              )),
                                    /*Container(
                                  //color: color,
                                  margin: EdgeInsets.all(2),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(300),
                                  ),
                                  child: Text('${prop.title}'),
                                ),*/
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
