import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinemawala/artists/actor.dart';
import 'package:cinemawala/costumes/costume.dart';
import 'package:cinemawala/locations/location.dart';
import 'package:cinemawala/projects/project.dart';
import 'package:cinemawala/props/prop.dart';
import 'package:cinemawala/scenes/additional_artists.dart';
import 'package:cinemawala/scenes/select_costumes.dart';
import 'package:cinemawala/scenes/select_location.dart';
import 'package:cinemawala/scenes/select_props.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils.dart';
import 'scene.dart';
import 'select_actors.dart';

class AddScene extends StatefulWidget {
  final Project project;
  final Map<dynamic, dynamic> scene;
  final bool isPopUp;

  AddScene({Key key, @required this.project, @required this.scene,this.isPopUp})
      : super(key: key);

  @override
  _AddScene createState() => _AddScene(this.project, this.scene,this.isPopUp);
}

class _AddScene extends State<AddScene> with SingleTickerProviderStateMixin {
  final Project project;
  Map<dynamic, dynamic> scene;
  bool isPopUp;
  _AddScene(this.project, this.scene, this.isPopUp);

  Color background, background1, color;
  List<Actor> selectedArtists = [], oldArtists = [];
  List<Prop> selectedProps = [], oldProps = [];
  List<Costume> selectedCostumes = [], oldCostumes = [];
  int selectedLanguage = 0;
  Location selectedLocation, oldLocation;
  List<TextEditingController> titleControllers = [], gistControllers = [];
  List<dynamic> languages,
      langsInLang = Utils.langsInLang,
      specialEquipments = [],
      artistsImages = [],
      propsImages = [],
      costumesImages = [];
  bool loading = true, edit = false;
  ScrollController cardScrollController = new ScrollController();
  TextEditingController specialEquipmentTextController,
      makeUpTextController,
      sfxTextController,
      vfxTextController,
      choreographerTextController,
      fighterTextController;

  @override
  void initState() {
    isPopUp = isPopUp ?? true;
    languages = project.languages;
    if (scene == null) {
      scene = {
        "project_id": "${project.id}",
        "added_by": "${Utils.USER_ID}",
        "id": "${Utils.generateId('scene_')}",
        "last_edit_by": "${Utils.USER_ID}",
        "costumes": [],
        "artists": [],
        "props": [],
        "day": 0,
        "interior": 0,
        "location": "",
        "addl_artists": {
          'Juniors': [
            {
              'Male': 0,
              'Female': 0,
              'Kids': 0,
              'Contact': "",
              'Notes': '',
            }
          ],
          'Models': [
            {
              'Male': 0,
              'Female': 0,
              'Kids': 0,
              'Contact': "",
              'Notes': '',
            }
          ],
          'Dancers': [
            {
              'Male': 0,
              'Female': 0,
              'Kids': 0,
              'Contact': "",
              'Notes': '',
            }
          ],
          'Fighters': [
            {
              'Male': 0,
              'Female': 0,
              'Kids': 0,
              'Contact': "",
              'Notes': '',
            }
          ],
          'Gang Members': [],
          'Additional Artists': [],
        },
        "special_equipment": "",
        "make_up": "",
        "sfx": "",
        "vfx": "",
        "titles": {},
        "gists": {},
        "completed": false,
        "completed_on": [0, 0, 0, 0],
      };
      scene['created'] = DateTime.now().millisecondsSinceEpoch;
      scene['last_edit_on'] = scene['created'];
      for (var i in languages) {
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
      for (var i in languages) {
        titleControllers.add(
            new TextEditingController(text: "${scene["titles"][i] ?? ""}"));
        gistControllers
            .add(new TextEditingController(text: "${scene["gists"][i] ?? ""}"));
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
    vfxTextController = new TextEditingController(text: scene['vfx']);
    sfxTextController = new TextEditingController(text: scene['sfx']);
    choreographerTextController =
        new TextEditingController(text: scene['choreographer']);
    fighterTextController = new TextEditingController(text: scene['fighter']);

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
    // Navigator.pop(context);
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: Utils.linearGradient,
          ),
        ),
        backgroundColor: color,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(45),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List<Widget>.generate(languages.length, (i) {
                return Container(
                  decoration: BoxDecoration(
                    color: i == selectedLanguage ? Colors.white : color,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  margin:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedLanguage = i;
                        cardScrollController.animateTo(
                            MediaQuery.of(context).size.width * i,
                            duration: Duration(milliseconds: 400),
                            curve: Curves.decelerate);
                      });
                    },
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                              text: '${langsInLang[i]}',
                              style: TextStyle(
                                  color: background1,
                                  fontSize: 14,
                                  fontFamily: 'Poppins')),
                          TextSpan(
                              text:
                                  '\n${Utils.codeToLanguagesInEnglish[languages[i]]}',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontFamily: 'Poppins',
                                  color: background1)),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        iconTheme: IconThemeData(color: background1),
        title: Text(
          edit ? "Edit Strip Board" : "Add Strip Board",
          style: TextStyle(color: background1),
        ),
        actions: [
          TextButton.icon(
            onPressed: () async {
              if (edit) {
                editScene();
              } else {
                addScene();
              }
            },
            label: Container(
              padding: kIsWeb ? EdgeInsets.only(right: 12):EdgeInsets.only(right: 2),
              child: Text(
                edit ? "Save" : "Add",
                style: TextStyle(color: Colors.indigo),
                textAlign: TextAlign.right,
              ),
            ),
            icon: Icon(
              edit ? Icons.done : Icons.add,
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
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    constraints: BoxConstraints(maxWidth: Utils.mobileWidth),
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
                                constraints:
                                    BoxConstraints(maxWidth: Utils.mobileWidth),
                                color: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 16),
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  children: [
                                    TextField(
                                      textInputAction: TextInputAction.done,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      onChanged: (v) {
                                        scene['titles'][languages[i]] = v;
                                      },
                                      controller: titleControllers[i],
                                      decoration: InputDecoration(
                                        enabled: (edit && project.role.permissions["scenes"]["edit"] ||
                                            project.role.permissions["schedule"]["edit"]) ||
                                            (!edit && project.role.permissions["scenes"]["add"] || project.role.permissions["schedule"]["add"]) ?
                                        true : false,
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
                                        scene['gists'][languages[i]] = v;
                                      },
                                      maxLines: null,
                                      controller: gistControllers[i],
                                      decoration: InputDecoration(
                                        enabled: (edit && project.role.permissions["scenes"]["edit"] ||
                                            project.role.permissions["schedule"]["edit"]) ||
                                            (!edit && project.role.permissions["scenes"]["add"] || project.role.permissions["schedule"]["add"]) ?
                                        true : false,
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
                        if(project.role.permissions["locations"]["view"] ||project.role.permissions["scenes"]["view"]||
                            project.role.permissions["schedule"]["view"]){
                          Utils.showLoadingDialog(context, 'Loading');
                          var selected = await Navigator.push(
                              context,
                              Utils.createRoute(
                                  SelectLocation(
                                    project: project,
                                  ),
                                  Utils.DTU)) ??
                              null;
                          if (selected != null) {
                            scene["location"] = selected.id;
                            selectedLocation = selected;
                            setState(() {});
                          }
                          Navigator.pop(context);
                        }else{
                          Utils.notAllowed(context);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: project.role.permissions["locations"]["view"] ||project.role.permissions["scenes"]["view"]||
                              project.role.permissions["schedule"]["view"] ? color : Colors.grey,
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
                                    imageUrl: selectedLocation.images.length > 0
                                        ? selectedLocation.images[0]
                                        : '',
                                    width: 60,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Icon(
                                        Icons.image_not_supported_outlined),
                                    errorWidget: (context, url, error) =>
                                        const Icon(
                                            Icons.image_not_supported_outlined),
                                  ),
                          ),
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
                  // Day/Night
                  Container(
                    decoration: BoxDecoration(
                      color: project.role.permissions["scenes"]["view"] || project.role.permissions["schedule"]["view"] ? color : Colors.grey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: isPopUp ? 0 : 4),
                            child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  primary:
                                      scene['day'] == 0 ? Colors.white : color,
                                  elevation: isPopUp
                                      ? scene['day'] == 0
                                          ? 4
                                          : 0
                                      : scene['day'] == 0
                                          ? 2
                                          : 0,
                                ),
                                onPressed: () {
                                  if(
                                  (edit && (project.role.permissions["schedule"]["edit"] ||project.role.permissions["scenes"]["edit"])) ||
                                      (!edit && project.role.permissions["schedule"]["add"] ||project.role.permissions["scenes"]["add"])
                                  )
                                  {
                                  setState(() {
                                    scene['day'] = 0;
                                    });
                                  }else{
                                    Utils.notAllowed(context);
                                  }
                                },
                                icon: Icon(Icons.wb_sunny_outlined,
                                    size: 22, color: background1),
                                label: Text(
                                  "Day",
                                  style: TextStyle(
                                      fontWeight: scene['day'] == 0
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: background1),
                                )),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding:  EdgeInsets.symmetric(
                                horizontal: 6, vertical: isPopUp ? 0 : 4),
                            child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  primary:
                                      scene['day'] == 1 ? Colors.white : color,
                                  elevation: isPopUp
                                      ? scene['day'] == 1
                                          ? 4
                                          : 0
                                      : scene['day'] == 1
                                          ? 2
                                          : 0,
                                ),
                                onPressed: () {
                                  if(
                                  (edit && (project.role.permissions["schedule"]["edit"] ||project.role.permissions["scenes"]["edit"])) ||
                                      (!edit && project.role.permissions["schedule"]["add"] ||project.role.permissions["scenes"]["add"])
                                  ){
                                    setState(() {
                                      scene['day'] = 1;
                                    });
                                  }else{
                                    Utils.notAllowed(context);
                                  }
                                },
                                icon: Icon(Icons.nightlight_round,
                                    size: 22, color: background1),
                                label: Text(
                                  "Night",
                                  style: TextStyle(
                                      fontWeight: scene['day'] == 1
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: background1),
                                )),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: isPopUp ? 0 : 4),
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  primary:
                                      scene['day'] == 2 ? Colors.white : color,
                                  elevation: isPopUp
                                      ? scene['day'] == 2
                                          ? 4
                                          : 0
                                      : scene['day'] == 2
                                          ? 2
                                          : 0,
                                ),
                                onPressed: () {
                                  if ((edit &&
                                          (project.role.permissions["schedule"]
                                                  ["edit"] ||
                                              project.role.permissions["scenes"]
                                                  ["edit"])) ||
                                      (!edit &&
                                              project.role
                                                      .permissions["schedule"]
                                                  ["add"] ||
                                          project.role.permissions["scenes"]
                                              ["add"])) {
                                    setState(() {
                                      scene['day'] = 2;
                                    });
                                  } else {
                                    Utils.notAllowed(context);
                                  }
                                },
                                child: Text(
                                  "Both",
                                  style: TextStyle(
                                      fontWeight: scene['day'] == 2
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: background1),
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Interior/Exterior
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: project.role.permissions["scenes"]["view"] || project.role.permissions["schedule"]["view"] ? color : Colors.grey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding:  EdgeInsets.symmetric(
                                horizontal: 6, vertical: isPopUp ? 0 : 4),
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  primary: scene['interior'] == 0
                                      ? Colors.white
                                      : color,
                                  elevation: isPopUp
                                      ? scene['interior'] == 0
                                          ? 4
                                          : 0
                                      : scene['interior'] == 0
                                          ? 2
                                          : 0,
                                ),
                                onPressed: () {
                                  if(
                                  (edit && (project.role.permissions["schedule"]["edit"] ||project.role.permissions["scenes"]["edit"])) ||
                                      (!edit && project.role.permissions["schedule"]["add"] ||project.role.permissions["scenes"]["add"])
                                  ){
                                    setState(() {
                                      scene['interior'] = 0;
                                    });
                                  }
                                  else{
                                    Utils.notAllowed(context);
                                  }
                                },
                                child: Text(
                                  "Interior",
                                  style: TextStyle(
                                      fontWeight: scene['interior'] == 0
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: background1),
                                )),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: isPopUp ? 0 : 4),
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  primary: scene['interior'] == 1
                                      ? Colors.white
                                      : color,
                                  elevation: isPopUp
                                      ? scene['interior'] == 1
                                          ? 4
                                          : 0
                                      : scene['interior'] == 1
                                          ? 2
                                          : 0,
                                ),
                                onPressed: () {
                                  if(
                                  (edit && (project.role.permissions["schedule"]["edit"] ||project.role.permissions["scenes"]["edit"])) ||
                                      (!edit && project.role.permissions["schedule"]["add"] ||project.role.permissions["scenes"]["add"])
                                  ){
                                    setState(() {
                                      scene['interior'] = 1;
                                    });
                                  }else{
                                    Utils.notAllowed(context);
                                  }
                                },
                                child: Text(
                                  "Exterior",
                                  style: TextStyle(
                                      fontWeight: scene['interior'] == 1
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: background1),
                                )),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: isPopUp ? 0 : 4),
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  primary: scene['interior'] == 2
                                      ? Colors.white
                                      : color,
                                  elevation: isPopUp
                                      ? scene['interior'] == 2
                                          ? 4
                                          : 0
                                      : scene['interior'] == 2
                                          ? 2
                                          : 0,
                                ),
                                onPressed: () {
                                  if ((edit &&
                                          (project.role.permissions["schedule"]
                                                  ["edit"] ||
                                              project.role.permissions["scenes"]
                                                  ["edit"])) ||
                                      (!edit &&
                                              project.role
                                                      .permissions["schedule"]
                                                  ["add"] ||
                                          project.role.permissions["scenes"]
                                              ["add"])) {
                                    setState(() {
                                      scene['interior'] = 2;
                                    });
                                  } else {
                                    Utils.notAllowed(context);
                                  }
                                },
                                child: Text(
                                  "Both",
                                  style: TextStyle(
                                      fontWeight: scene['interior'] == 2
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: background1),
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Artists
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: InkWell(
                      onTap: () async {
                        if(
                        project.role.permissions["casting"]["view"] || project.role.permissions["schedule"]["view"] ||
                            project.role.permissions["scenes"]["view"]
                        ){
                          Utils.showLoadingDialog(context, 'Loading');
                          var selected = await Navigator.push(
                              context,
                              Utils.createRoute(
                                  SelectActors(
                                    project: project,
                                    selectedActors: selectedArtists.sublist(0),
                                  ),
                                  Utils.DTU));
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
                                costumes[ind]['costumes'] =
                                    oldCostume["costumes"];
                              } else {
                                costumes[ind]['costumes'] = [];
                              }
                              ind++;
                            });
                            scene['costumes'] = costumes;

                            costumesImages = [];
                            selectedCostumes = [];

                            for (var i in scene['costumes']) {
                              for (var j in i['costumes']) {
                                Costume costume = Utils.costumesMap[j];
                                selectedCostumes.add(costume);
                                costumesImages
                                    .add(costume.referenceImage ?? '');
                              }
                            }
                            costumesImages = costumesImages.toSet().toList();
                            selectedCostumes =
                                selectedCostumes.toSet().toList();

                            Navigator.pop(context);
                            setState(() {});
                          } else {
                            Navigator.pop(context);
                          }
                        }else{
                          Utils.notAllowed(context);
                        }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color:
                        project.role.permissions["casting"]["view"] || project.role.permissions["schedule"]["view"] ||
                        project.role.permissions["scenes"]["view"]
                          ? color : Colors.grey,
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
                        if(
                        (project.role.permissions["scenes"]["view"] &&
                            project.role.permissions["scenes"]["add"]) ||
                            (project.role.permissions["schedule"]["view"] &&
                                project.role.permissions["schedule"]["add"])
                        ){
                          var addlArtists = Utils.additionalArtists;
                          for (var k in addlArtists.keys) {
                            addlArtists['$k']['field_values'] =
                            scene['addl_artists']['$k'];
                          }
                          var selected = await Navigator.push(
                              context,
                              Utils.createRoute(
                                  AddCompanyArtists(
                                    additionalArtists: addlArtists,
                                  ),
                                  Utils.DTU));
                          print(selected);
                          if (selected != null) {
                            for (var k in selected.keys) {
                              scene['addl_artists']['$k'] =
                              selected['$k']['field_values'];
                            }
                            setState(() {});
                          }
                        }else{
                          Utils.notAllowed(context);
                        }
                      },
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: project.role.permissions["scenes"]["view"] || project.role.permissions["schedule"]["view"]
                            ? color : Colors.grey,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          child: Text(
                            'Additional Artists',
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
                        if(project.role.permissions["scenes"]["view"] || project.role.permissions["schedule"]["view"] ||
                            project.role.permissions["costumes"]["view"]){
                          Utils.showLoadingDialog(context, "Loading");
                          var selected = await Navigator.push(
                              context,
                              Utils.createRoute(
                                  SelectCostumes(
                                    project: project,
                                    selectedActors: selectedArtists,
                                    costumes: scene['costumes'],
                                  ),
                                  Utils.DTU));
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
                        }else{
                          Utils.notAllowed(context);
                        }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: project.role.permissions["scenes"]["view"] || project.role.permissions["schedule"]["view"] ||
                          project.role.permissions["costumes"]["view"] ?
                          color : Colors.grey,
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
                        if(project.role.permissions["props"]["view"] ||
                            project.role.permissions["scenes"]["view"] ||
                            project.role.permissions["schedule"]["view"]
                        ){
                          Utils.showLoadingDialog(context, 'Loading');
                          var selected = await Navigator.push(
                              context,
                              Utils.createRoute(
                                  SelectProps(
                                    project: project,
                                    selectedProps: selectedProps,
                                  ),
                                  Utils.DTU));
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
                        }else{
                          Utils.notAllowed(context);
                        }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color:  project.role.permissions["props"]["view"] ||
                              project.role.permissions["scenes"]["view"] ||
                              project.role.permissions["schedule"]["view"] ?
                          color : Colors.grey,
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
                  // Makeup & Hair
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
                        enabled: (edit && project.role.permissions["scenes"]["edit"] ||
                            project.role.permissions["schedule"]["edit"]) ||
                            (!edit && project.role.permissions["scenes"]["add"] || project.role.permissions["schedule"]["add"]) ?
                        true : false,
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
                  // Spl Equipments
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
                  // SFX
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: TextField(
                      textInputAction: TextInputAction.newline,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (v) {
                        scene['sfx'] = v;
                      },
                      controller: sfxTextController,
                      maxLines: null,
                      decoration: InputDecoration(
                        enabled: (edit && project.role.permissions["scenes"]["edit"] ||
                            project.role.permissions["schedule"]["edit"]) ||
                            (!edit && project.role.permissions["scenes"]["add"] || project.role.permissions["schedule"]["add"]) ?
                        true : false,
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: background1)),
                        labelText: 'SFX',
                        labelStyle: TextStyle(color: background1, fontSize: 14),
                        contentPadding: EdgeInsets.all(8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  // VFX
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: TextField(
                      textInputAction: TextInputAction.newline,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (v) {
                        scene['vfx'] = v;
                      },
                      controller: vfxTextController,
                      maxLines: null,
                      decoration: InputDecoration(
                        enabled: (edit && project.role.permissions["scenes"]["edit"] ||
                            project.role.permissions["schedule"]["edit"]) ||
                            (!edit && project.role.permissions["scenes"]["add"] || project.role.permissions["schedule"]["add"]) ?
                        true : false,
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: background1)),
                        labelText: 'VFX',
                        labelStyle: TextStyle(color: background1, fontSize: 14),
                        contentPadding: EdgeInsets.all(8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  // Choreographer
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: TextField(
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (v) {
                        scene['choreographer'] = v;
                      },
                      controller: choreographerTextController,
                      maxLines: 1,
                      decoration: InputDecoration(
                        enabled: (edit && project.role.permissions["scenes"]["edit"] ||
                            project.role.permissions["schedule"]["edit"]) ||
                            (!edit && project.role.permissions["scenes"]["add"] || project.role.permissions["schedule"]["add"]) ?
                        true : false,
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: background1)),
                        labelText: 'Choreographer',
                        labelStyle: TextStyle(color: background1, fontSize: 14),
                        contentPadding: EdgeInsets.all(8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  // Fighter
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: TextField(
                      textInputAction: TextInputAction.done,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (v) {
                        scene['fighter'] = v;
                      },
                      controller: fighterTextController,
                      maxLines: 1,
                      decoration: InputDecoration(
                        enabled: (edit && project.role.permissions["scenes"]["edit"] ||
                            project.role.permissions["schedule"]["edit"]) ||
                            (!edit && project.role.permissions["scenes"]["add"] || project.role.permissions["schedule"]["add"]) ?
                        true : false,
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: background1)),
                        labelText: 'Action Director',
                        labelStyle: TextStyle(color: background1, fontSize: 14),
                        contentPadding: EdgeInsets.all(8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
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

  addScene() async {
    Utils.showLoadingDialog(context, 'Adding Scene');

    if (selectedLocation == null) {
      Navigator.pop(context);
      Utils.showErrorDialog(context, "Location", "Select a Location");
      return;
    }

    if (!selectedLocation.usedIn.contains(scene['id'])) {
      selectedLocation.usedIn.add(scene['id']);
    }

    Map<dynamic, dynamic> body = {
      "scene": scene,
      "artists": [],
      "costumes": [],
      "props": [],
      "locations": [selectedLocation.toJson()]
    };

    Map<dynamic, dynamic> costumesOfArtists = {};
    Map<dynamic, dynamic> artistsOfCostumes = {};

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

    try {
      var resp = await http.post(Utils.ADD_SCENE,
          body: jsonEncode(body),
          headers: {"Content-Type": "application/json"});
      var r = jsonDecode(resp.body);
      if (resp.statusCode == 200) {
        if (r['status'] == 'success') {
          Utils.scenesMap[scene['id']] = Scene.fromJson(scene);
          Utils.scenes = Utils.scenesMap.values.toList();

          body['artists'].forEach((a) {
            Utils.artistsMap[a['id']] = Actor.fromJson(a);
          });
          Utils.artists = Utils.artistsMap.values.toList();

          body['costumes'].forEach((c) {
            Utils.costumesMap[c['id']] = Costume.fromJson(c);
          });
          Utils.costumes = Utils.costumesMap.values.toList();

          body['props'].forEach((c) {
            Utils.propsMap[c['id']] = Prop.fromJson(c);
          });
          Utils.props = Utils.propsMap.values.toList();

          body['locations'].forEach((c) {
            Utils.locationsMap[c['id']] = Location.fromJson(c);
          });
          Utils.locations = Utils.locationsMap.values.toList();

          Navigator.pop(context);

          await Utils.showSuccessDialog(
              context,
              'Scene Added',
              'Scene has been added successfully.',
              Colors.green,
              background, () {
                if(!kIsWeb){
                  print("hello");
                  Navigator.pop(context);
                }
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
    Navigator.pop(context);
  }

  editScene() async {
    Utils.showLoadingDialog(context, 'Editing Scene');
    Map<dynamic, dynamic> body = {
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

    Map<dynamic, dynamic> costumesOfArtists = {};
    Map<dynamic, dynamic> artistsOfCostumes = {};

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
        if (a.scenes.contains(scene['id'])) {
          a.scenes.remove(scene['id']);
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

    Set selectedCostumesIds = {};
    selectedCostumes = selectedCostumes.toSet().toList();

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

    oldProps.forEach((p) {
      if (!scene['props'].contains(p.id)) {
        p = Prop.fromJson(p.toJson());
        if (p.usedIn.contains(scene['id'])) {
          p.usedIn.remove(scene['id']);
        }
        body['props'].add(p.toJson());
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

    try {
      var resp = await http.post(Utils.EDIT_SCENE,
          body: jsonEncode(body),
          headers: {"Content-Type": "application/json"});
      // // debugPrint(resp.body);
      var r = jsonDecode(resp.body);
      if (resp.statusCode == 200) {
        if (r['status'] == 'success') {
          Utils.scenesMap[scene['id']] = Scene.fromJson(scene);
          Utils.scenes = Utils.scenesMap.values.toList();

          body['artists'].forEach((a) {
            Utils.artistsMap[a['id']] = Actor.fromJson(a);
          });
          Utils.artists = Utils.artistsMap.values.toList();

          body['costumes'].forEach((c) {
            Utils.costumesMap[c['id']] = Costume.fromJson(c);
          });
          Utils.costumes = Utils.costumesMap.values.toList();

          body['props'].forEach((c) {
            Utils.propsMap[c['id']] = Prop.fromJson(c);
          });
          Utils.props = Utils.propsMap.values.toList();

          body['locations'].forEach((c) {
            Utils.locationsMap[c['id']] = Location.fromJson(c);
          });
          Utils.locations = Utils.locationsMap.values.toList();

          Navigator.pop(context);

          await Utils.showSuccessDialog(
              context,
              'Scene Edited',
              'Scene has been edited successfully.',
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
    Navigator.pop(context);
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
