import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinemawala/artists/actor.dart';
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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils.dart';
import 'select_actors.dart';

class ScenePage extends StatefulWidget {
  final Project project;
  final Scene scene;
  bool popUp;
  ScenePage({Key key, @required this.project, @required this.scene, this.popUp})
      : super(key: key);

  @override
  _ScenePage createState() => _ScenePage(this.project, this.scene, this.popUp);
}

class _ScenePage extends State<ScenePage> with SingleTickerProviderStateMixin {
  final Project project;
  Scene scene;
  bool popUp;
  _ScenePage(this.project, this.scene, this.popUp);
  Color background, background1, color;
  List<Actor> selectedArtists = [];
  List<Prop> selectedProps = [];
  List<Costume> selectedCostumes = [];
  int selectedLanguage = 0;
  Location selectedLocation;
  List<TextEditingController> titleControllers = [], gistControllers = [];
  List<dynamic> languages,
      langsInLang = Utils.langsInLang,
      artistsImages = [],
      propsImages = [],
      costumesImages = [];
  bool loading = true;
  ScrollController cardScrollController = new ScrollController();
  TextEditingController specialEquipmentTextController,
      makeUpTextController,
      sfxTextController,
      vfxTextController,
      choreographerTextController,
      fighterTextController;

  int minus = 0;

  @override
  void initState() {
    popUp = popUp ?? false;
    if (popUp) {
      minus = 48;
    }
    languages = project.languages;

    setScene();

    super.initState();
  }

  setScene() async {
    selectedLocation = Utils.locationsMap[scene.location];
    for (var i in languages) {
      titleControllers.add(new TextEditingController(
          text:
              "${(scene.titles[i] != null && scene.titles[i] != "") ? scene.titles[i] : "-"}"));
      gistControllers.add(new TextEditingController(
          text:
              "${(scene.gists[i] != null && scene.gists[i] != "") ? scene.gists[i] : "-"}"));
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
        text: scene.makeUp == "" ? " -" : scene.makeUp);

    sfxTextController =
        new TextEditingController(text: scene.sfx == "" ? " -" : scene.sfx);
    vfxTextController =
        new TextEditingController(text: scene.vfx == "" ? " -" : scene.vfx);

    choreographerTextController =
        new TextEditingController(text: scene.choreographer);
    fighterTextController = new TextEditingController(text: scene.fighter);
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

    return GestureDetector(
      onTap: () {
        if (popUp) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: popUp ? Colors.black26 : background,
        appBar: popUp
            ? PreferredSize(
                preferredSize: Size.fromHeight(0),
                child: Container(),
              )
            : AppBar(
                flexibleSpace: Container(
                  decoration: popUp ? BoxDecoration(
                    gradient: Utils.linearGradient,
                  ) : BoxDecoration(
                      border: Border(left:BorderSide(color: Colors.black)),
                      color: Colors.white),
                ),
                backgroundColor: color,
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(45),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: List<Widget>.generate(langsInLang.length, (i) {
                        return Container(
                          decoration: BoxDecoration(
                            color: i != selectedLanguage ? background : color,
                            borderRadius: BorderRadius.circular(32),
                          ),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 2),
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
            "Strip Board",
            style: TextStyle(color: background1),
          ),
          actions: [
            TextButton.icon(
              onPressed: () async {
                      await Navigator.push(
                          context,
                          Utils.createRoute(
                              AddScene(project: project, scene: scene.toJson()),
                              Utils.RTL));
                      if(!kIsWeb) {
                        Navigator.pop(context);
                      }
                    },
                    label: Container(
                      padding: kIsWeb ? EdgeInsets.only(right: 12):EdgeInsets.only(right: 2),
                      child: Text(
                        "Edit",
                        style: TextStyle(color: Colors.indigo),
                        textAlign: TextAlign.right,
                      ),
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
          onTap: () {},
          child: Container(
            margin: popUp
                ? const EdgeInsets.symmetric(horizontal: 24, vertical: 40)
                : const EdgeInsets.all(0),
            decoration: popUp
                ? BoxDecoration(
                    color: background, borderRadius: BorderRadius.circular(8))
                : BoxDecoration(border: Border(left: BorderSide(color: Colors.black)),),
            child: Column(
              children: [
                if (popUp)
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
                        "Strip Board",
                        style: TextStyle(fontSize: 20, color: background1),
                        textAlign: TextAlign.center,
                      ),
                      Spacer(),
                      TextButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                              context,
                              Utils.createRoute(
                                  AddScene(
                                      project: project, scene: scene.toJson()),
                                  Utils.RTL));
                          setState(() {
                            scene = Utils.scenesMap[scene.id];
                          });
                        },
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
                Flexible(
                  child: SingleChildScrollView(
                    padding: popUp
                        ? const EdgeInsets.all(0)
                        : const EdgeInsets.symmetric(vertical: 16),
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        if (popUp)
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 0),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: List<Widget>.generate(
                                    langsInLang.length, (i) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: i != selectedLanguage
                                          ? background
                                          : color,
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 4),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 2),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          selectedLanguage = i;
                                          cardScrollController.animateTo(
                                              MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  i,
                                              duration:
                                                  Duration(milliseconds: 400),
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
                        Container(
                          margin: EdgeInsets.only(bottom: 2),
                          child: scene.completedOn[0]!=0 ? Container(
                            color: scene.completed ? Color(0xFFC5E1A5) : Color(0xFFFFAB91),
                            child: Center(child:Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("WD: ${scene.completedOn[3]} / ${scene.completedOn[0]}-${scene.completedOn[1]}-${scene.completedOn[2]}",
                                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                            ),),
                          ):Container(),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width - minus,
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
                                  children: List<Widget>.generate(
                                      langsInLang.length, (i) {
                                    return Container(
                                      color: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                          vertical: 16, horizontal: 16),
                                      width: MediaQuery.of(context).size.width -
                                          minus,
                                      child: Column(
                                        children: [
                                          TextField(
                                            textInputAction:
                                                TextInputAction.done,
                                            textCapitalization:
                                                TextCapitalization.words,
                                            controller: titleControllers[i],
                                            decoration: InputDecoration(
                                              enabled: false,
                                              disabledBorder:
                                                  OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: background)),
                                              labelText: 'Scene Title',
                                              labelStyle: TextStyle(
                                                  color: background1,
                                                  fontSize: 14),
                                              contentPadding: EdgeInsets.all(8),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 16,
                                          ),
                                          TextField(
                                            textInputAction:
                                                TextInputAction.done,
                                            textCapitalization:
                                                TextCapitalization.words,
                                            maxLines: null,
                                            controller: gistControllers[i],
                                            decoration: InputDecoration(
                                              enabled: false,
                                              disabledBorder:
                                                  OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: background)),
                                              labelText: 'Gist/Synopsis',
                                              labelStyle: TextStyle(
                                                  color: background1,
                                                  fontSize: 14),
                                              contentPadding: EdgeInsets.all(8),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
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
                        InkWell(
                          onTap: () async {

                              await Navigator.push(
                                  context,
                                  Utils.createRoute(
                                      LocationPage(
                                        project: project,
                                        location: selectedLocation,
                                      ),
                                      Utils.DTU));
                              setState(() {});
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 8,horizontal: 16),
                            decoration: BoxDecoration(
                              gradient: Utils.linearGradient,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 0),
                              leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: CachedNetworkImage(
                                    imageUrl: selectedLocation.images.length > 0
                                        ? selectedLocation.images[0]
                                        : '',
                                    width: 60,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  )),
                              title: Text("${selectedLocation.location}",
                                  style: TextStyle(
                                      color: background1,
                                      fontWeight: FontWeight.bold),
                                  maxLines: 1),
                              subtitle: Text(
                                "@ ${selectedLocation.shootLocation}",
                                style: TextStyle(color: background1),
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ),
                        // Day/Night
                        Container(
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          margin:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 6, vertical: popUp ? 0 : 4),
                                  child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(32)),
                                        primary: Colors.white,
                                        elevation: popUp ? 4 : 2,
                                      ),
                                      onPressed: () {},
                                      icon: Icon(Icons.wb_sunny_outlined,
                                          size: 22, color: background1),
                                      label: Text(
                                        scene.day == 0
                                            ? "Day"
                                            : scene.interior == 1
                                                ? "Night"
                                                : "Day & Night",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: background1),
                                      )),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 6, vertical: popUp ? 0 : 4),
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16)),
                                        primary: Colors.white,
                                        elevation: popUp ? 4 : 2,
                                      ),
                                      onPressed: () {},
                                      child: Text(
                                        scene.interior == 0
                                            ? "Interior"
                                            : scene.interior == 1
                                                ? "Exterior"
                                                : "Interior & Exterior",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: background1),
                                      )),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Artists
                        Padding(
                          padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: InkWell(
                            onTap: () async {
                              await Navigator.push(
                                  context,
                                  Utils.createRoute(
                                      SelectedActors(
                                        project: project,
                                        selectedArtists: List<Actor>.generate(
                                            scene.artists.length,
                                                (a) => Utils
                                                .artistsMap[scene.artists[a]]),
                                        scene: scene,
                                      ),
                                      Utils.DTU));
                              setState(() {
                                setScene();
                              });
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Artists",
                                    style: TextStyle(
                                        color: background1,
                                        fontWeight: FontWeight.bold),
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
                          padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: InkWell(
                            onTap: () async {
                              var addlArtists = Utils.additionalArtists;
                              for (var k in addlArtists.keys) {
                                addlArtists['$k']['field_values'] =
                                scene.addlArtists['$k'];
                              }
                              await Navigator.push(
                                  context,
                                  Utils.createRoute(
                                      ViewCompanyArtists(
                                        additionalArtists: addlArtists,
                                      ),
                                      Utils.DTU));
                              setState(() {});
                            },
                            child: Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                child: Text(
                                  'Additional Artists',
                                  style: TextStyle(
                                      color: background1,
                                      fontWeight: FontWeight.bold),
                                )),
                          ),
                        ),
                        // Costumes
                        Padding(
                          padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: InkWell(
                            onTap: () async {
                              await Navigator.push(
                                  context,
                                  Utils.createRoute(
                                      SelectedCostumes(
                                          project: project,
                                          scene: scene,
                                          costumes: scene.costumes),
                                      Utils.DTU));
                              setState(() {
                                setScene();
                              });
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "Costumes",
                                    style: TextStyle(
                                        color: background1,
                                        fontWeight: FontWeight.bold),
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
                          padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: InkWell(
                            onTap: () async {
                              await Navigator.push(
                                  context,
                                  Utils.createRoute(
                                      SelectedProps(
                                          project: project,
                                          scene: scene,
                                          selectedProps: List<Prop>.generate(
                                              scene.artists.length,
                                              (p) => Utils
                                                  .propsMap[scene.props[p]])),
                                      Utils.DTU));
                              setState(() {
                                setScene();
                              });
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Props",
                                    style: TextStyle(
                                        color: background1,
                                        fontWeight: FontWeight.bold),
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
                          margin: EdgeInsets.fromLTRB(16, 16, 16, 8),
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
                              labelStyle:
                                  TextStyle(color: background1, fontSize: 14),
                              contentPadding: EdgeInsets.all(8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        Divider(
                          color: color,
                          thickness: 2,
                          height: 0,
                        ),
                        // Spl. Equipments
                        Container(
                          margin: EdgeInsets.fromLTRB(16, 16, 16, 8),
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
                        Divider(
                          color: color,
                          thickness: 2,
                          height: 0,
                        ),
                        // SFX
                        Container(
                          margin: EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: TextField(
                            textInputAction: TextInputAction.newline,
                            textCapitalization: TextCapitalization.words,
                            onChanged: (v) {
                              scene.sfx = v;
                            },
                            controller: sfxTextController,
                            maxLines: null,
                            decoration: InputDecoration(
                              enabled: false,
                              disabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: background)),
                              labelText: 'SFX',
                              labelStyle:
                                  TextStyle(color: background1, fontSize: 14),
                              contentPadding: EdgeInsets.all(8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        Divider(
                          color: color,
                          thickness: 2,
                          height: 0,
                        ),
                        //VFX
                        Container(
                          margin: EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: TextField(
                            textInputAction: TextInputAction.newline,
                            textCapitalization: TextCapitalization.words,
                            onChanged: (v) {
                              scene.vfx = v;
                            },
                            controller: vfxTextController,
                            maxLines: null,
                            decoration: InputDecoration(
                              enabled: false,
                              disabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: background)),
                              labelText: 'VFX',
                              labelStyle:
                                  TextStyle(color: background1, fontSize: 14),
                              contentPadding: EdgeInsets.all(8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        Divider(
                          color: color,
                          thickness: 2,
                          height: 0,
                        ),
                        // Choreographer
                        if (scene.choreographer != "")
                          Container(
                            margin: EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: TextField(
                              textInputAction: TextInputAction.next,
                              textCapitalization: TextCapitalization.words,
                              controller: choreographerTextController,
                              maxLines: 1,
                              decoration: InputDecoration(
                                enabled: false,
                                disabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: background)),
                                labelText: 'Choreographer',
                                labelStyle:
                                    TextStyle(color: background1, fontSize: 14),
                                contentPadding: EdgeInsets.all(8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        if (scene.choreographer != "")
                          Divider(
                            color: color,
                            thickness: 2,
                            height: 0,
                          ),
                        // Fighter
                        if (scene.fighter != "")
                          Container(
                            margin: EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: TextField(
                              textInputAction: TextInputAction.done,
                              textCapitalization: TextCapitalization.words,
                              controller: fighterTextController,
                              maxLines: 1,
                              decoration: InputDecoration(
                                enabled: false,
                                disabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: background)),
                                labelText: 'Action Director',
                                labelStyle:
                                    TextStyle(color: background1, fontSize: 14),
                                contentPadding: EdgeInsets.all(8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        /*if (scene.fighter != "")
                          Divider(
                            color: color,
                            thickness: 2,
                            height: 0,
                          ),*/
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/*class ScenePageContent extends StatelessWidget {

  final Scene scene;
  final Project project;
  final VoidCallback viewLocation();

  const ScenePageContent({Key key, this.scene, this.project}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: InkWell(
            onTap: () async {
              viewLocation();
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
        // Day/Night
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
        // Makeup & Hair
        Container(
          margin: EdgeInsets.fromLTRB(16, 16, 16, 8),
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
        Divider(
          color: color,
          thickness: 2,
          height: 0,
        ),
        // Spl. Equipments
        Container(
          margin: EdgeInsets.fromLTRB(16, 16, 16, 8),
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
        Divider(
          color: color,
          thickness: 2,
          height: 0,
        ),
        // SFX
        Container(
          margin: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            textInputAction: TextInputAction.newline,
            textCapitalization: TextCapitalization.words,
            onChanged: (v) {
              scene.sfx = v;
            },
            controller: sfxTextController,
            maxLines: null,
            decoration: InputDecoration(
              enabled: false,
              disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: background)),
              labelText: 'SFX',
              labelStyle: TextStyle(color: background1, fontSize: 14),
              contentPadding: EdgeInsets.all(8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        Divider(
          color: color,
          thickness: 2,
          height: 0,
        ),
        //VFX
        Container(
          margin: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            textInputAction: TextInputAction.newline,
            textCapitalization: TextCapitalization.words,
            onChanged: (v) {
              scene.vfx = v;
            },
            controller: vfxTextController,
            maxLines: null,
            decoration: InputDecoration(
              enabled: false,
              disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: background)),
              labelText: 'VFX',
              labelStyle: TextStyle(color: background1, fontSize: 14),
              contentPadding: EdgeInsets.all(8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        Divider(
          color: color,
          thickness: 2,
          height: 0,
        ),
        // Choreographer
        if (scene.choreographer != "")
          Container(
            margin: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              controller: choreographerTextController,
              maxLines: 1,
              decoration: InputDecoration(
                enabled: false,
                disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: background)),
                labelText: 'Choreographer',
                labelStyle: TextStyle(color: background1, fontSize: 14),
                contentPadding: EdgeInsets.all(8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        if (scene.choreographer != "")
          Divider(
            color: color,
            thickness: 2,
            height: 0,
          ),
        // Fighter
        if (scene.fighter != "")
          Container(
            margin: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.words,
              controller: fighterTextController,
              maxLines: 1,
              decoration: InputDecoration(
                enabled: false,
                disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: background)),
                labelText: 'Fighter',
                labelStyle: TextStyle(color: background1, fontSize: 14),
                contentPadding: EdgeInsets.all(8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        if (scene.fighter != "")
          Divider(
            color: color,
            thickness: 2,
            height: 0,
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
              var addlArtists = Utils.additionalArtists;
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
    );
  }
}*/
