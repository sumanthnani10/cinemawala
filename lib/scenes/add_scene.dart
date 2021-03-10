import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinemawala/casting/actor.dart';
import 'package:cinemawala/costumes/costume.dart';
import 'package:cinemawala/locations/location.dart';
import 'package:cinemawala/projects/project.dart';
import 'package:cinemawala/props/prop.dart';
import 'package:cinemawala/scenes/additional_artists.dart';
import 'package:cinemawala/scenes/select_costumes.dart';
import 'package:cinemawala/scenes/select_location.dart';
import 'package:cinemawala/scenes/select_props.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils.dart';
import 'select_actors.dart';

class AddScene extends StatefulWidget {
  final Project project;
  final Map<dynamic, dynamic> scene;

  AddScene({Key key, @required this.project, @required this.scene})
      : super(key: key);

  @override
  _AddScene createState() => _AddScene(this.project, this.scene);
}

class _AddScene extends State<AddScene> with SingleTickerProviderStateMixin {
  final Project project;
  Map<dynamic, dynamic> scene;

  _AddScene(this.project, this.scene);

  Color background, background1, color;
  List<Actor> selectedArtists = [], oldArtists = [];
  List<Prop> selectedProps = [], oldProps = [];
  List<Costume> selectedCostumes = [], oldCostumes = [];
  int selectedLanguage = 0;
  Location selectedLocation, oldLocation;
  List<TextEditingController> titleControllers = [], gistControllers = [];
  List<dynamic> langsInEnglish,
      languages = ['English', 'తెలుగు', 'हिंदी', 'தமிழ்'],
      specialEquipments = [],
      artistsImages = [],
      propsImages = [],
      costumesImages = [];
  bool loading = true, edit = false;
  ScrollController cardScrollController = new ScrollController();
  TextEditingController specialEquipmentTextController, makeUpTextController;

  @override
  void initState() {
    langsInEnglish = project.languages;
    if (scene == null) {
      scene = {
        "project_id": "${project.id}",
        "added_by": "${Utils.USER_ID}",
        "id": "${Utils.generateId('scene_')}",
        "last_edit_by": "${Utils.USER_ID}",
        "costumes": [],
        "artists": [],
        "props": [],
        "day": true,
        "interior": true,
        "location": "",
        "addl_artists": {
          'Juniors': [
            {
              'Male': 0,
              'Female': 0,
              'Kids': 0,
              'Notes': '',
            }
          ],
          'Models': [
            {
              'Male': 0,
              'Female': 0,
              'Kids': 0,
              'Notes': '',
            }
          ],
          'Gang Members': [
            {
              'Name': '',
              'Contact': '',
            }
          ],
          'Additional Artists': [
            {
              'Name': '',
              'Contact': '',
            }
          ],
        },
        "special_equipment": "",
        "make_up": "",
        "titles": {},
        "gists": {},
      };
      scene['created'] = DateTime.now().millisecondsSinceEpoch;
      scene['last_edit_on'] = scene['created'];
      for (var i in langsInEnglish) {
        titleControllers.add(new TextEditingController());
        gistControllers.add(new TextEditingController());
        scene["titles"][i] = "";
        scene["gists"][i] = "";
      }
    } else {
      edit = true;
      scene['last_edit_on'] = DateTime.now().millisecondsSinceEpoch;
      scene['last_edit_by'] = "${Utils.USER_ID}";
      selectedLocation = Utils.locationsMap[scene["location"]];
      oldLocation = Utils.locationsMap[scene["location"]];
      for (var i in langsInEnglish) {
        titleControllers
            .add(new TextEditingController(text: scene["titles"][i]));
        gistControllers.add(new TextEditingController(text: scene["gists"][i]));
      }
      for (var i in scene['artists']) {
        selectedArtists.add(Utils.artistsMap[i]);
        artistsImages.add(selectedArtists.last.image ?? '');
      }
      oldArtists = selectedArtists.sublist(0);
      for (var i in scene['props']) {
        selectedProps.add(Utils.propsMap[i]);
        propsImages.add(selectedProps.last.referenceImage ?? '');
      }
      oldProps = selectedProps.sublist(0);

      for (var i in scene['costumes']) {
        for (var j in i['costumes']) {
          selectedCostumes.add(Utils.costumesMap[j]);
          costumesImages.add(selectedCostumes.last.referenceImage ?? '');
        }
      }
      oldCostumes = selectedCostumes.sublist(0);
    }
    specialEquipmentTextController =
        new TextEditingController(text: scene['special_equipment']);
    makeUpTextController = new TextEditingController(text: scene['make_up']);

    specialEquipments = [
      'Gimmy',
      'Drone',
      'Tripod',
    ];

    super.initState();
  }

  Widget imagesInCircles(images) {
    return Stack(
      children: List<Widget>.generate(images.length > 4 ? 4 : images.length,
              (i) {
            return Padding(
                padding: EdgeInsets.only(left: i.toDouble() * 18),
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.white,
                  child: images[i] == ''
                      ? Container(
                          width: 22,
                          height: 22,
                          color: background,
                        )
                      : CachedNetworkImage(
                          width: 22,
                          height: 22,
                          imageBuilder: (context, imageProvider) => Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: imageProvider, fit: BoxFit.cover),
                                ),
                              ),
                          fit: BoxFit.cover,
                          progressIndicatorBuilder: (context, url, progress) =>
                              LinearProgressIndicator(
                                value: progress.progress,
                              ),
                          errorWidget: (context, url, error) => Center(
                                  child: Text(
                                'Image',
                                style: const TextStyle(color: Colors.grey),
                              )),
                          useOldImageOnUrlChange: true,
                          imageUrl: images[i]),
                ));
          }) +
          [
            Padding(
              padding: EdgeInsets.only(
                  left: (((images.length > 4 ? 4.0 : images.length) * 18.0) +
                      12.0),
                  top: 4),
              child: Text(
                ' ${images.length > 4 ? '+${images.length - 4} more' : ''}',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
    );
  }

  Widget imagesInSquares(images) {
    return Row(
      children:
          List<Widget>.generate(images.length > 3 ? 3 : images.length, (i) {
                return Container(
                  margin: EdgeInsets.only(left: 4),
                  width: 23,
                  height: 23,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: images[i] == ''
                        ? Container(
                            width: 22,
                            height: 22,
                            color: background,
                          )
                        : CachedNetworkImage(
                            fit: BoxFit.cover,
                            width: 22,
                            height: 22,
                            imageUrl: images[i],
                          ),
                  ),
                );
              }) +
              [
                Text(
                  ' ${images.length > 3 ? '+${images.length - 3} more' : ''}',
                  style: TextStyle(fontSize: 12),
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
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: color,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(45),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List<Widget>.generate(languages.length, (i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FlatButton(
                      onPressed: () {
                        setState(() {
                          selectedLanguage = i;
                          cardScrollController.animateTo(
                              MediaQuery.of(context).size.width * i,
                              duration: Duration(milliseconds: 400),
                              curve: Curves.decelerate);
                        });
                      },
                      color: i == selectedLanguage ? Colors.white : color,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32)),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                                text: '${languages[i]}',
                                style: TextStyle(
                                    color: background1,
                                    fontSize: 14,
                                    fontFamily: 'Poppins')),
                            TextSpan(
                                text: '\n${langsInEnglish[i]}',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontFamily: 'Poppins',
                                    color: background1)),
                          ],
                        ),
                      )),
                );
              }),
            ),
          ),
        ),
        iconTheme: IconThemeData(color: background1),
        title: Text(
          edit ? "Edit 1 Line Order" : "Add 1 Line Order",
          style: TextStyle(color: background1),
        ),
        actions: [
          FlatButton.icon(
            onPressed: () async {
              if (edit) {
                editScene();
              } else {
                addScene();
              }
            },
            color: color,
            splashColor: background1.withOpacity(0.2),
            label: Text(
              edit ? "Edit" : "Add",
              style: TextStyle(color: Colors.indigo),
              textAlign: TextAlign.right,
            ),
            icon: Icon(
              edit ? Icons.edit : Icons.add,
              size: 18,
              color: Colors.indigo,
            ),
          )
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.grey.shade400,
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Container(
                  color: Colors.white,
                  child: SingleChildScrollView(
                      controller: cardScrollController,
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: List<Widget>.generate(languages.length, (i) {
                          return Container(
                            color: Colors.white,
                            padding: EdgeInsets.symmetric(
                                vertical: 16, horizontal: 16),
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              children: [
                                TextField(
                                  textInputAction: TextInputAction.done,
                                  textCapitalization: TextCapitalization.words,
                                  onChanged: (v) {
                                    scene['titles'][langsInEnglish[i]] = v;
                                  },
                                  controller: titleControllers[i],
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: background1)),
                                    labelText: 'Scene Title',
                                    labelStyle: TextStyle(
                                        color: background1, fontSize: 14),
                                    contentPadding: EdgeInsets.all(8),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                TextField(
                                  textInputAction: TextInputAction.done,
                                  textCapitalization: TextCapitalization.words,
                                  onChanged: (v) {
                                    scene['gists'][langsInEnglish[i]] = v;
                                  },
                                  maxLines: null,
                                  controller: gistControllers[i],
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: background1)
                                        //borderSide: const BorderSide(color: Colors.white)
                                        ),
                                    labelText: 'Gist/Synopsis',
                                    labelStyle: TextStyle(
                                        color: background1, fontSize: 14),
                                    contentPadding: EdgeInsets.all(8),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      )),
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: InkWell(
                  onTap: () async {
                    Utils.showLoadingDialog(context, 'Loading');
                    Location selected = await Navigator.push(
                            context,
                            PageRouteBuilder(
                                pageBuilder: (_, __, ___) => SelectLocation(
                                      project: project,
                                    ),
                                opaque: false)) ??
                        null;
                    if (selected != null) {
                      scene["location"] = selected.id;
                      selectedLocation = selected;
                      setState(() {});
                    }
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                      leading: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: scene['location'] == ""
                              ? Container(
                                  width: 60,
                                  height: 50,
                                  color: color,
                                  child: Text('',
                                      style: TextStyle(
                                          color: background, fontSize: 12)),
                                )
                              : CachedNetworkImage(
                                  imageUrl: selectedLocation.images[0] ?? '',
                                  width: 60,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )),
                      title: Text(
                          scene['location'] == ""
                              ? ""
                              : "${selectedLocation.location}",
                          style: TextStyle(
                              color: background1, fontWeight: FontWeight.bold),
                          maxLines: 1),
                      subtitle: Text(
                        scene['location'] == ""
                            ? "Select Location"
                            : "@ ${selectedLocation.shootLocation}",
                        style: TextStyle(color: background1),
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 0),
                        child: RaisedButton.icon(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            onPressed: () {
                              setState(() {
                                scene['day'] = true;
                              });
                            },
                            color: scene['day'] ? Colors.white : color,
                            elevation: scene['day'] ? 4 : 0,
                            icon: Icon(
                              Icons.wb_sunny_outlined,
                              size: 22,
                            ),
                            label: Text(
                              "Day",
                              style: TextStyle(
                                  fontWeight: scene['day']
                                      ? FontWeight.bold
                                      : FontWeight.normal),
                            )),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 0),
                        child: RaisedButton.icon(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            onPressed: () {
                              setState(() {
                                scene['day'] = false;
                              });
                            },
                            color: !scene['day'] ? Colors.white : color,
                            elevation: !scene['day'] ? 4 : 0,
                            icon: Icon(
                              Icons.nightlight_round,
                              size: 22,
                            ),
                            label: Text(
                              "Night",
                              style: TextStyle(
                                  fontWeight: !scene['day']
                                      ? FontWeight.bold
                                      : FontWeight.normal),
                            )),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 0),
                        child: RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            onPressed: () {
                              setState(() {
                                scene['interior'] = true;
                              });
                            },
                            color: scene['interior'] ? Colors.white : color,
                            elevation: scene['interior'] ? 4 : 0,
                            child: Text(
                              "Interior",
                              style: TextStyle(
                                  fontWeight: scene['interior']
                                      ? FontWeight.bold
                                      : FontWeight.normal),
                            )),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 0),
                        child: RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            onPressed: () {
                              setState(() {
                                scene['interior'] = false;
                              });
                            },
                            color: !scene['interior'] ? Colors.white : color,
                            elevation: !scene['interior'] ? 4 : 0,
                            child: Text(
                              "Exterior",
                              style: TextStyle(
                                  fontWeight: !scene['interior']
                                      ? FontWeight.bold
                                      : FontWeight.normal),
                            )),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: TextField(
                  textInputAction: TextInputAction.newline,
                  textCapitalization: TextCapitalization.words,
                  onChanged: (v) {
                    scene['make_up'] = v;
                  },
                  controller: makeUpTextController,
                  maxLines: null,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: background1)),
                    labelText: 'Makeup/Hair',
                    labelStyle: TextStyle(color: background1, fontSize: 14),
                    contentPadding: EdgeInsets.all(8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  border: Border.symmetric(
                      horizontal: BorderSide(color: color, width: 2)),
                  // borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: TextField(
                        textInputAction: TextInputAction.newline,
                        textCapitalization: TextCapitalization.words,
                        onChanged: (v) {
                          scene['special_equipment'] = v;
                        },
                        controller: specialEquipmentTextController,
                        maxLines: 1,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: background1)),
                          labelText: 'Special Equipment',
                          labelStyle:
                              TextStyle(color: background1, fontSize: 14),
                          contentPadding: EdgeInsets.all(8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: List<Widget>.generate(
                            specialEquipments.length, (i) {
                          return InkWell(
                            onTap: () {
                              if (specialEquipmentTextController.text != "" &&
                                  !specialEquipmentTextController.text
                                      .endsWith(",")) {
                                specialEquipmentTextController.text =
                                    specialEquipmentTextController.text + ",";
                              }
                              specialEquipmentTextController.text =
                                  specialEquipmentTextController.text +
                                      " ${specialEquipments[i]},";
                              specialEquipmentTextController.selection =
                                  TextSelection.fromPosition(TextPosition(
                                      offset: specialEquipmentTextController
                                          .text.length));
                              scene['special_equipment'] =
                                  specialEquipmentTextController.text;
                            },
                            splashColor: background1.withOpacity(0.2),
                            child: Container(
                              margin: EdgeInsets.all(2),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(300),
                              ),
                              child: Text('${specialEquipments[i]}'),
                            ),
                          );
                        }),
                      ),
                    )
                  ],
                ),
              ),
              // Artists
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: InkWell(
                  onTap: () async {
                    Utils.showLoadingDialog(context, 'Loading');
                    var selected = await Navigator.push(
                        context,
                        PageRouteBuilder(
                            pageBuilder: (_, __, ___) => SelectActors(
                                  project: project,
                                  selectedActors: selectedArtists,
                                ),
                            opaque: false));
                    if (selected != null) {
                      scene['artists'] = selected[0];
                      selectedArtists = selected[1];
                      artistsImages = [];
                      var costumes = [];
                      for (var i in selectedArtists) {
                        artistsImages.add(i.image ?? '');
                      }
                      int ind = 0;
                      scene['artists'].forEach((a) {
                        costumes.add({"id": a});
                        var oldCostume = scene['costumes'].firstWhere(
                            (e) => e['id'] == a,
                            orElse: () => null);
                        if (oldCostume != null) {
                          costumes[ind]['costumes'] = oldCostume["costumes"];
                        } else {
                          costumes[ind]['costumes'] = [];
                        }
                        ind++;
                      });
                      scene['costumes'] = costumes;

                      for (var i in scene['costumes']) {
                        for (var j in i['costumes']) {
                          Costume costume = Utils.costumesMap[j];
                          selectedCostumes.add(costume);
                          costumesImages.add(costume.referenceImage ?? '');
                        }
                      }

                      Navigator.pop(context);
                      setState(() {});
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Artists",
                          style: TextStyle(
                              color: background1, fontWeight: FontWeight.bold),
                        ),
                        Spacer(),
                        imagesInCircles(artistsImages)
                      ],
                    ),
                  ),
                ),
              ),
              // Additional Artists
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: InkWell(
                  onTap: () async {
                    var addlArtists = {
                      'Juniors': {
                        'field_values': [
                          {
                            'Male': 0,
                            'Female': 0,
                            'Kids': 0,
                            'Notes': '',
                          }
                        ],
                        'fields': {
                          'Male': 0,
                          'Female': 0,
                          'Kids': 0,
                          'Notes': '',
                        },
                        'addable': false
                      },
                      'Models': {
                        'field_values': [
                          {
                            'Male': 0,
                            'Female': 0,
                            'Kids': 0,
                            'Notes': '',
                          }
                        ],
                        'fields': {
                          'Male': 0,
                          'Female': 0,
                          'Kids': 0,
                          'Notes': '',
                        },
                        'addable': false
                      },
                      'Gang Members': {
                        'field_values': [
                          {
                            'Name': '',
                            'Contact': '',
                          }
                        ],
                        'fields': {
                          'Name': '',
                          'Contact': '',
                        },
                        'addable': true
                      },
                      'Additional Artists': {
                        'field_values': [
                          {
                            'Name': '',
                            'Contact': '',
                          }
                        ],
                        'fields': {
                          'Name': '',
                          'Contact': '',
                        },
                        'addable': true
                      },
                    };
                    for (var k in addlArtists.keys) {
                      addlArtists['$k']['field_values'] =
                          scene['addl_artists']['$k'];
                    }
                    var selected = await Navigator.push(
                        context,
                        PageRouteBuilder(
                            pageBuilder: (_, __, ___) => AddCompanyArtists(
                                  additionalArtists: addlArtists,
                                ),
                            opaque: false));
                    if (selected != null) {
                      for (var k in addlArtists.keys) {
                        scene['addl_artists']['$k'] =
                            selected['$k']['field_values'];
                      }
                      setState(() {});
                    }
                  },
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      child: Text(
                        'Company/Additional Artists',
                        style: TextStyle(
                            color: background1, fontWeight: FontWeight.bold),
                      )),
                ),
              ),
              // Costumes
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: InkWell(
                  onTap: () async {
                    Utils.showLoadingDialog(context, "Loading");
                    var selected = await Navigator.push(
                        context,
                        PageRouteBuilder(
                            pageBuilder: (_, __, ___) => SelectCostumes(
                                  project: project,
                                  selectedActors: selectedArtists,
                                  costumes: scene['costumes'],
                                ),
                            opaque: false));
                    if (selected != null) {
                      scene['costumes'] = selected;
                      selectedCostumes.clear();
                      selectedCostumes = [];
                      costumesImages.clear();
                      costumesImages = [];
                      for (var i in scene['costumes']) {
                        for (var j in i['costumes']) {
                          Costume costume = Utils.costumesMap[j];
                          selectedCostumes.add(costume);
                          costumesImages.add(costume.referenceImage ?? '');
                        }
                      }

                      Navigator.pop(context);
                      setState(() {});
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Costumes",
                          style: TextStyle(
                              color: background1, fontWeight: FontWeight.bold),
                        ),
                        Spacer(),
                        imagesInSquares(costumesImages),
                      ],
                    ),
                  ),
                ),
              ),
              // Props
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: InkWell(
                  onTap: () async {
                    Utils.showLoadingDialog(context, 'Loading');
                    var selected = await Navigator.push(
                        context,
                        PageRouteBuilder(
                            pageBuilder: (_, __, ___) => SelectProps(
                                  project: project,
                                  selectedProps: selectedProps,
                                ),
                            opaque: false));
                    if (selected != null) {
                      scene['props'] = selected[0];
                      selectedProps = selected[1];
                      propsImages = [];
                      for (var i in selectedProps) {
                        propsImages.add(i.referenceImage ?? '');
                      }
                      Navigator.pop(context);
                      setState(() {});
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Props",
                          style: TextStyle(
                              color: background1, fontWeight: FontWeight.bold),
                        ),
                        Spacer(),
                        imagesInSquares(propsImages),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  addScene() async {
    Utils.showLoadingDialog(context, 'Adding Scene');

    if (!selectedLocation.usedIn.contains(scene['id'])) {
      selectedLocation.usedIn.add(scene['id']);
    }

    Map<String, dynamic> body = {
      "scene": scene,
      "artists": [],
      "costumes": [],
      "props": [],
      "locations": [selectedLocation.toJson()]
    };

    Map<String, dynamic> costumesOfArtists = {};
    Map<String, dynamic> artistsOfCostumes = {};

    scene['costumes'].forEach((cl) {
      costumesOfArtists['${cl['id']}'] = cl['costumes'];
      cl['costumes'].forEach((c) {
        if (!artistsOfCostumes.containsKey(c)) {
          artistsOfCostumes[c] = [cl['id']];
        } else {
          if (!artistsOfCostumes[c].contains(cl['id'])) {
            artistsOfCostumes[c].add(cl['id']);
          }
        }
      });
    });

    // print(costumesOfArtists);
    // print(artistsOfCostumes);

    selectedArtists.forEach((a) {
      a = Actor.fromJson(a.toJson());

      if (!a.scenes.contains(scene['id'])) {
        a.scenes.add(scene['id']);
      }

      a.costumes['${scene['id']}'] = costumesOfArtists[a.id];

      body['artists'].add(a.toJson());
    });

    selectedCostumes.forEach((c) {
      c = Costume.fromJson(c.toJson());

      if (!c.scenes.contains(scene['id'])) {
        c.scenes.add(scene['id']);
      }

      c.usedBy['${scene['id']}'] = artistsOfCostumes[c.id];
      c.changed = c.scenes.length;

      body['costumes'].add(c.toJson());
    });

    selectedProps.forEach((p) {
      p = Prop.fromJson(p.toJson());
      if (!p.usedIn.contains(scene['id'])) {
        p.usedIn.add(scene['id']);
      }
      body['props'].add(p.toJson());
    });

    // print(body);

    var back = false;

    try {
      var resp = await http.post(Utils.ADD_SCENE,
          body: jsonEncode(body),
          headers: {"Content-Type": "application/json"});
      var r = jsonDecode(resp.body);
      Navigator.pop(context);
      if (resp.statusCode == 200) {
        if (r['status'] == 'success') {
          await Utils.showSuccessDialog(
              context,
              'Scene Added',
              'Scene has been added successfully.',
              Colors.green,
              background, () {
            Navigator.pop(context);
          });
        } else {
          await Utils.showErrorDialog(context, 'Unsuccessful', '${r['msg']}');
        }
      } else {
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
    Navigator.pop(context, back);
    Utils.showScrollingDialog(context, "", body.toString(), null, null);
  }

  editScene() async {
    Utils.showLoadingDialog(context, 'Editing Scene');

    Map<String, dynamic> body = {
      "scene": scene,
      "artists": [],
      "costumes": [],
      "props": [],
      "locations": []
    };

    if (oldLocation != selectedLocation) {
      var old = oldLocation.toJson();
      old['used_in'].remove(scene['id']);
      // print(old);
      body['locations'].add(old);
    }

    Location l = Location.fromJson(selectedLocation.toJson());
    if (!l.usedIn.contains(scene['id'])) {
      l.usedIn.add(scene['id']);
    }
    body['locations'].add(l.toJson());

    Map<String, dynamic> costumesOfArtists = {};
    Map<String, dynamic> artistsOfCostumes = {};

    scene['costumes'].forEach((cl) {
      costumesOfArtists['${cl['id']}'] = cl['costumes'];
      cl['costumes'].forEach((c) {
        if (!artistsOfCostumes.containsKey(c)) {
          artistsOfCostumes[c] = [cl['id']];
        } else {
          if (!artistsOfCostumes[c].contains(cl['id'])) {
            artistsOfCostumes[c].add(cl['id']);
          }
        }
      });
    });

    // print(costumesOfArtists);
    // print(artistsOfCostumes);

    oldArtists.forEach((a) {
      if (!scene['artists'].contains(a.id)) {
        a = Actor.fromJson(a.toJson());
        if (!a.scenes.contains(scene['id'])) {
          a.scenes.add(scene['id']);
        }
        a.costumes.remove('${scene['id']}');
        body['artists'].add(a.toJson());
      }
    });

    selectedArtists.forEach((a) {
      a = Actor.fromJson(a.toJson());
      if (!a.scenes.contains(scene['id'])) {
        a.scenes.add(scene['id']);
      }
      a.costumes['${scene['id']}'] = costumesOfArtists[a.id];
      body['artists'].add(a.toJson());
    });

    var selectedCostumesIds = [];

    selectedCostumes.forEach((c) {
      selectedCostumesIds.add(c.id);
      c = Costume.fromJson(c.toJson());
      if (!c.scenes.contains(scene['id'])) {
        c.scenes.add(scene['id']);
      }
      c.usedBy['${scene['id']}'] = artistsOfCostumes[c.id];
      c.changed = c.scenes.length;
      body['costumes'].add(c.toJson());
    });

    oldCostumes.forEach((c) {
      if (!selectedCostumesIds.contains(c.id)) {
        c = Costume.fromJson(c.toJson());
        c.scenes.remove(scene['id']);
        c.usedBy.remove('${scene['id']}');
        c.changed = c.scenes.length;
        body['costumes'].add(c.toJson());
      }
    });

    selectedProps.forEach((p) {
      p = Prop.fromJson(p.toJson());
      if (!p.usedIn.contains(scene['id'])) {
        p.usedIn.add(scene['id']);
      }
      body['props'].add(p.toJson());
    });

    // print(body['locations']);

    var back = false;

    try {
      var resp = await http.post(Utils.EDIT_SCENE,
          body: jsonEncode(body),
          headers: {"Content-Type": "application/json"});
      // // debugPrint(resp.body);
      var r = jsonDecode(resp.body);
      Navigator.pop(context);
      if (resp.statusCode == 200) {
        if (r['status'] == 'success') {
          back = true;
          await Utils.showSuccessDialog(
              context,
              'Scene Edited',
              'Scene has been edited successfully.',
              Colors.green,
              background, () {
            Navigator.pop(context);
          });
        } else {
          await Utils.showErrorDialog(context, 'Unsuccessful', '${r['msg']}');
        }
      } else {
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
    Navigator.pop(context, back);
  }
}

/*
Padding(
                padding: EdgeInsets.symmetric(vertical: 8,horizontal: 16),
                child: InkWell(
                  onTap: (){
                    Navigator.push(context, PageRouteBuilder(pageBuilder: (_,__,___) => SelectLocation(),opaque: false));
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ListTile(
                      // contentPadding: EdgeInsets.symmetric(horizontal: 8),
                      tileColor: color,
                      leading: ClipRRect(
                          borderRadius: BorderRadius.circular(4),child: Image(image: NetworkImage(images[0],),width: 40,height: 40,fit: BoxFit.cover,)),
                      shootimg==null?ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image(image: NetworkImage(img),width: 40,height: 40,)):shootimg,
                      title: Text("Location Name"),
                      subtitle: Text("Shoot Location Name"),
                    ),
                  ),
                ),
              ),
Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Location',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),)),
              ),
Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: background1)
                        //borderSide: const BorderSide(color: Colors.white)
                        ),
                    labelText: 'Location Name',
                    labelStyle: TextStyle(color: background1, fontSize: 14),
                    contentPadding: EdgeInsets.all(8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Shoot Location',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: background1)
                        //borderSide: const BorderSide(color: Colors.white)
                        ),
                    labelText: 'Shoot Location Name',
                    labelStyle: TextStyle(color: background1, fontSize: 14),
                    contentPadding: EdgeInsets.all(8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),*/
