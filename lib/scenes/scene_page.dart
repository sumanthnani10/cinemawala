import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinemawala/casting/actor.dart';
import 'package:cinemawala/costumes/costume.dart';
import 'package:cinemawala/locations/location.dart';
import 'package:cinemawala/locations/location_page.dart';
import 'package:cinemawala/projects/project.dart';
import 'package:cinemawala/props/prop.dart';
import 'package:cinemawala/scenes/add_scene.dart';
import 'package:cinemawala/scenes/additional_artists.dart';
import 'package:cinemawala/scenes/scene.dart';
import 'package:cinemawala/scenes/select_costumes.dart';
import 'package:cinemawala/scenes/select_props.dart';
import 'package:flutter/material.dart';

import '../utils.dart';
import 'select_actors.dart';

class ScenePage extends StatefulWidget {
  final Project project;
  final Scene scene;

  ScenePage({Key key, @required this.project, @required this.scene})
      : super(key: key);

  @override
  _ScenePage createState() => _ScenePage(this.project, this.scene);
}

class _ScenePage extends State<ScenePage> with SingleTickerProviderStateMixin {
  final Project project;
  Scene scene;

  _ScenePage(this.project, this.scene);

  Color background, background1, color;
  List<Actor> selectedArtists = [];
  List<Prop> selectedProps = [];
  List<Costume> selectedCostumes = [];
  int selectedLanguage = 0;
  Location selectedLocation;
  List<TextEditingController> titleControllers = [], gistControllers = [];
  List<dynamic> langsInEnglish,
      languages = ['English', 'తెలుగు', 'हिंदी', 'தமிழ்'],
      artistsImages = [],
      propsImages = [],
      costumesImages = [];
  bool loading = true;
  ScrollController cardScrollController = new ScrollController();
  TextEditingController specialEquipmentTextController, makeUpTextController;

  @override
  void initState() {
    langsInEnglish = project.languages;

    selectedLocation = Utils.locationsMap[scene.location];

    for (var i in langsInEnglish) {
      titleControllers.add(new TextEditingController(text: scene.titles[i]));
      gistControllers.add(new TextEditingController(text: scene.gists[i]));
    }

    for (var i in scene.artists) {
      selectedArtists.add(Utils.artistsMap[i]);
      artistsImages.add(selectedArtists.last.image ?? '');
    }

    for (var i in scene.props) {
      selectedProps.add(Utils.propsMap[i]);
      propsImages.add(selectedProps.last.referenceImage ?? '');
    }

    for (var i in scene.costumes) {
      for (var j in i['costumes']) {
        selectedCostumes.add(Utils.costumesMap[j]);
        costumesImages.add(selectedCostumes.last.referenceImage ?? '');
      }
    }
    specialEquipmentTextController = new TextEditingController(
        text: scene.specialEquipment == "" ? " -" : scene.specialEquipment);
    makeUpTextController = new TextEditingController(
        text: scene.makeUp != "" ? " -" : scene.makeUp);

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
          "1 Line Order",
          style: TextStyle(color: background1),
        ),
        actions: [
          FlatButton.icon(
            onPressed: () async {
              var back = await Navigator.push(
                      context,
                      Utils.createRoute(
                          AddScene(project: project, scene: scene.toJson()),
                          Utils.RTL)) ??
                  false;
              // debugPrint("${location.toJson()}");
              Navigator.pop(context, back);
            },
            color: color,
            splashColor: background1.withOpacity(0.2),
            label: Text(
              "Edit",
              style: TextStyle(color: Colors.indigo),
              textAlign: TextAlign.right,
            ),
            icon: Icon(
              Icons.edit,
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
                                  controller: titleControllers[i],
                                  decoration: InputDecoration(
                                    enabled: false,
                                    disabledBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: background)),
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
                                  maxLines: null,
                                  controller: gistControllers[i],
                                  decoration: InputDecoration(
                                    enabled: false,
                                    disabledBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: background)),
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
                    var back = await Navigator.push(
                            context,
                            PageRouteBuilder(
                                pageBuilder: (_, __, ___) => LocationPage(
                                      project: project,
                                      location: selectedLocation,
                                    ),
                                opaque: false)) ??
                        false;
                    if (back) {
                      Utils.showLoadingDialog(context, 'Getting Locations');
                      await Utils.getLocations(context, project.id);
                      Navigator.pop(context);
                      setState(() {});
                    }
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
                          child: CachedNetworkImage(
                            imageUrl: selectedLocation.images[0] ?? '',
                            width: 60,
                            height: 50,
                            fit: BoxFit.cover,
                          )),
                      title: Text("${selectedLocation.location}",
                          style: TextStyle(
                              color: background1, fontWeight: FontWeight.bold),
                          maxLines: 1),
                      subtitle: Text(
                        "@ ${selectedLocation.shootLocation}",
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
                            onPressed: () {},
                            color: Colors.white,
                            elevation: 4,
                            icon: Icon(
                              Icons.wb_sunny_outlined,
                              size: 22,
                            ),
                            label: Text(
                              scene.day ? "Day" : "Night",
                              style: TextStyle(fontWeight: FontWeight.bold),
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
                            onPressed: () {},
                            color: Colors.white,
                            elevation: 4,
                            child: Text(
                              scene.interior ? "Interior" : "Exterior",
                              style: TextStyle(fontWeight: FontWeight.bold),
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
                  controller: makeUpTextController,
                  maxLines: null,
                  decoration: InputDecoration(
                    enabled: false,
                    disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: background)),
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
                        controller: specialEquipmentTextController,
                        maxLines: 1,
                        decoration: InputDecoration(
                          enabled: false,
                          disabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: background)),
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
                  ],
                ),
              ),
              // Artists
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: InkWell(
                  onTap: () async {
                    Navigator.push(
                        context,
                        PageRouteBuilder(
                            pageBuilder: (_, __, ___) => SelectedActors(
                                  project: project,
                                  selectedArtists: List<Actor>.generate(
                                      scene.artists.length,
                                      (a) =>
                                          Utils.artistsMap[scene.artists[a]]),
                                ),
                            opaque: false));
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
                          scene.addlArtists['$k'];
                    }
                    var selected = await Navigator.push(
                        context,
                        PageRouteBuilder(
                            pageBuilder: (_, __, ___) => ViewCompanyArtists(
                                  additionalArtists: addlArtists,
                                ),
                            opaque: false));
                    if (selected != null) {
                      for (var k in addlArtists.keys) {
                        scene.addlArtists['$k'] =
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
                    Navigator.push(
                        context,
                        PageRouteBuilder(
                            pageBuilder: (_, __, ___) => SelectedCostumes(
                                project: project, costumes: scene.costumes),
                            opaque: false));
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
                  onTap: () {
                    Navigator.push(
                        context,
                        PageRouteBuilder(
                            pageBuilder: (_, __, ___) => SelectedProps(
                                project: project,
                                selectedProps: List<Prop>.generate(
                                    scene.artists.length,
                                    (p) => Utils.propsMap[scene.props[p]])),
                            opaque: false));
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
}
