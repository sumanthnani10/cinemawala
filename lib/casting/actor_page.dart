import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinemawala/casting/add_actor.dart';
import 'package:cinemawala/costumes/costume_page.dart';
import 'package:cinemawala/projects/project.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../utils.dart';
import 'actor.dart';

class ActorPage extends StatefulWidget {
  final Actor actor;
  final Project project;

  const ActorPage({Key key, @required this.actor, @required this.project})
      : super(key: key);

  @override
  _ActorPage createState() => _ActorPage(actor: actor, project: project);
}

class _ActorPage extends State<ActorPage> {
  final Project project;
  Color background, color, background1;
  int selectedLanguage = 0;

  List<dynamic> langsInLang = ['English', 'తెలుగు', 'हिंदी', 'தமிழ்'],
      languages;

  TextStyle headingStyle;
  ScrollController cardScrollController = new ScrollController();
  List<TextEditingController> nameControllers = [], characterControllers = [];
  Set<String> costumes = {};
  Actor actor;

  _ActorPage({@required this.actor, @required this.project});

  @override
  void initState() {
    languages = project.languages;
    for (var i in languages) {
      nameControllers.add(new TextEditingController(
          text: '${actor.names[i] != "" ? actor.names[i] : "-"}'));
      characterControllers.add(new TextEditingController(
          text: '${actor.characters[i] != "" ? actor.characters[i] : "-"}'));
    }
    actor.costumes.forEach((key, value) {
      costumes.addAll(Iterable.castFrom(value));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    color = Color(0xff6fd8a8);
    background = Colors.white;
    headingStyle = TextStyle(
        color: background1, fontSize: 20, fontWeight: FontWeight.bold);
    if (background == Colors.white) {
      background1 = Colors.black;
    } else {
      background1 = Colors.white;
    }
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: color,
        title: Text(
          'Actor Info',
          style: TextStyle(color: background1),
        ),
        iconTheme: IconThemeData(color: background1),
        actions: [
          TextButton.icon(
            onPressed: () async {
              await Navigator.push(
                  context,
                  Utils.createRoute(
                      AddActor(
                        project: project,
                        actor: actor.toJson(),
                      ),
                      Utils.RTL));
              actor = Utils.artistsMap[actor.id];
              setState(() {});
            },
            label: Text(
              "Edit",
              style: TextStyle(color: Colors.indigo),
              textAlign: TextAlign.right,
            ),
            icon: Icon(
              Icons.edit,
              size: 16,
              color: Colors.indigo,
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 24),
              height: 200,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Positioned(
                    child: actor.image == ''
                        ? CircleAvatar(
                            backgroundColor: Colors.grey,
                            radius: 100,
                            child: Text(
                              'No Image',
                              style: TextStyle(color: background),
                            ),
                          )
                        : CachedNetworkImage(
                            width: 200,
                            height: 200,
                            imageBuilder: (context, imageProvider) => Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover),
                                  ),
                                ),
                            fit: BoxFit.cover,
                            progressIndicatorBuilder:
                                (context, url, progress) =>
                                    LinearProgressIndicator(
                                      value: progress.progress,
                                    ),
                            errorWidget: (context, url, error) => Center(
                                    child: Text(
                                  'Image',
                                  style: const TextStyle(color: Colors.grey),
                                )),
                            useOldImageOnUrlChange: true,
                            imageUrl: actor.image),
                  ),
                ],
              ),
            ),
          ),
          SizedBox.expand(
            child: DraggableScrollableSheet(
              initialChildSize: 310 / MediaQuery.of(context).size.height,
              minChildSize: 310 / MediaQuery.of(context).size.height,
              maxChildSize: 1,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x26000000),
                          offset: Offset(0, -1),
                          blurRadius: 10,
                        ),
                      ]),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 16),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children:
                                  List<Widget>.generate(languages.length, (i) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: i == selectedLanguage
                                        ? color
                                        : color.withOpacity(10 / 16),
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
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
                                                text: '\n${languages[i]}',
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
                        Container(
                          padding: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.black26, width: 0.5))),
                          width: MediaQuery.of(context).size.width,
                          child: SingleChildScrollView(
                            controller: cardScrollController,
                            physics: NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children:
                                  List<Widget>.generate(languages.length, (i) {
                                return Container(
                                  width: MediaQuery.of(context).size.width - 24,
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  padding: EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: background,
                                    borderRadius: BorderRadius.circular(16.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: color,
                                        offset: Offset(0, 0.2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      TextField(
                                        controller: nameControllers[i],
                                        decoration: InputDecoration(
                                          enabled: false,
                                          disabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: background)),
                                          labelText: 'Artist/Talent',
                                          labelStyle: TextStyle(
                                              color: background1, fontSize: 14),
                                          contentPadding: EdgeInsets.all(8),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 24,
                                      ),
                                      TextField(
                                        controller: characterControllers[i],
                                        decoration: InputDecoration(
                                          enabled: false,
                                          disabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: background)),
                                          labelText: 'Character Name',
                                          labelStyle: TextStyle(
                                              color: background1, fontSize: 14),
                                          focusColor: Colors.white,
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
                            ),
                          ),
                        ),
                        Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: Colors.black26, width: 0.5))),
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '${actor.days} days',
                                  style: TextStyle(
                                      color: background1,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      decoration: TextDecoration.underline,
                                      decorationThickness: 1),
                                ))),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.black26, width: 0.5))),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text('Scenes', style: headingStyle),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: actor.scenes.length < 1
                                    ? Text(
                                        'No Scenes',
                                        style: TextStyle(color: background1),
                                      )
                                    : Wrap(
                                        direction: Axis.horizontal,
                                        spacing: 4,
                                        children: List<Widget>.generate(
                                          actor.scenes.length,
                                          (i) {
                                            return InkWell(
                                              onTap: () {},
                                              child: Container(
                                                margin: EdgeInsets.all(2),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: color,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          300),
                                                ),
                                                child: Text(
                                                    '${Utils.scenesMap[actor.scenes[i]].titles[languages[selectedLanguage]]}'),
                                              ),
                                            );
                                          },
                                        )),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.black26, width: 0.5))),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Costumes',
                                  style: headingStyle,
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              costumes.length < 1
                                  ? Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'No Costumes',
                                        style: TextStyle(color: background1),
                                      ),
                                    )
                                  : Align(
                                      alignment: Alignment.centerLeft,
                                      child: Wrap(
                                          spacing: 4,
                                          direction: Axis.horizontal,
                                          children: List<Widget>.generate(
                                            costumes.length,
                                            (i) {
                                              return InkWell(
                                                onLongPress: () async {
                                                  await Navigator.push(
                                                      context,
                                                      Utils.createRoute(
                                                          CostumesPage(
                                                            project: project,
                                                            costume: Utils
                                                                    .costumesMap[
                                                                costumes
                                                                    .elementAt(
                                                                        i)],
                                                          ),
                                                          Utils.DTU));
                                                  setState(() {});
                                                },
                                                child: Container(
                                                  margin: EdgeInsets.all(2),
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: color,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            300),
                                                  ),
                                                  child: Text(
                                                      '${Utils.costumesMap[costumes.elementAt(i)].title}'),
                                                ),
                                              );
                                            },
                                          )),
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class ActorPopUp extends StatefulWidget {
  final Actor actor;
  final Project project;

  const ActorPopUp({Key key, @required this.actor, @required this.project})
      : super(key: key);

  @override
  _ActorPopUpState createState() =>
      _ActorPopUpState(actor: actor, project: project);
}

class _ActorPopUpState extends State<ActorPopUp> {
  final Project project;
  Color background, color, background1;
  int selectedLanguage = 0;

  List<dynamic> langsInLang = ['English', 'తెలుగు', 'हिंदी', 'தமிழ்'],
      languages;

  TextStyle headingStyle;
  ScrollController cardScrollController = new ScrollController();
  List<TextEditingController> nameControllers = [], characterControllers = [];
  final Actor actor;
  Set<String> costumes = {};

  _ActorPopUpState({@required this.actor, @required this.project});

  @override
  void initState() {
    languages = project.languages;
    for (var i in languages) {
      nameControllers.add(new TextEditingController(
          text: '${actor.names[i] != "" ? actor.names[i] : "-"}'));
      characterControllers.add(new TextEditingController(
          text: '${actor.characters[i] != "" ? actor.characters[i] : "-"}'));
    }
    actor.costumes.forEach((key, value) {
      costumes.addAll(Iterable.castFrom(value));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    color = Color(0xff6fd8a8);
    background = Colors.white;
    headingStyle = TextStyle(
        color: background1, fontSize: 20, fontWeight: FontWeight.bold);
    if (background == Colors.white) {
      background1 = Colors.black;
    } else {
      background1 = Colors.white;
    }
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: Colors.black26,
        body: GestureDetector(
          onTap: () {},
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: Stack(
              children: [
                Positioned(
                    left: 0,
                    child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: background1,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        })),
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    margin: const EdgeInsets.only(top: 24),
                    height: 200,
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Positioned(
                          child: actor.image == ''
                              ? CircleAvatar(
                                  backgroundColor: Colors.grey,
                                  radius: 100,
                                  child: Text(
                                    'No Image',
                                    style: TextStyle(color: background),
                                  ),
                                )
                              : CachedNetworkImage(
                                  width: 200,
                                  height: 200,
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                        width: 200,
                                        height: 200,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover),
                                        ),
                                      ),
                                  fit: BoxFit.cover,
                                  progressIndicatorBuilder:
                                      (context, url, progress) =>
                                          LinearProgressIndicator(
                                            value: progress.progress,
                                          ),
                                  errorWidget: (context, url, error) => Center(
                                          child: Text(
                                        'Image',
                                        style:
                                            const TextStyle(color: Colors.grey),
                                      )),
                                  useOldImageOnUrlChange: true,
                                  imageUrl: actor.image),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox.expand(
                  child: DraggableScrollableSheet(
                    initialChildSize: 310 / MediaQuery.of(context).size.height,
                    minChildSize: 310 / MediaQuery.of(context).size.height,
                    maxChildSize: 1,
                    builder: (context, scrollController) {
                      return Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16)),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0x26000000),
                                offset: Offset(0, -1),
                                blurRadius: 10,
                              ),
                            ]),
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 16),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: List<Widget>.generate(
                                        languages.length, (i) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: i == selectedLanguage
                                              ? color
                                              : color.withOpacity(10 / 16),
                                          borderRadius:
                                              BorderRadius.circular(32),
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 4),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 2),
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              selectedLanguage = i;
                                              cardScrollController.animateTo(
                                                  (MediaQuery.of(context)
                                                              .size
                                                              .width -
                                                          48) *
                                                      i,
                                                  duration: Duration(
                                                      milliseconds: 400),
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
                                                    )),
                                                TextSpan(
                                                    text: '\n${languages[i]}',
                                                    style: TextStyle(
                                                        fontSize: 10,
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
                                padding: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Colors.black26,
                                            width: 0.5))),
                                width: MediaQuery.of(context).size.width - 48,
                                child: SingleChildScrollView(
                                  controller: cardScrollController,
                                  physics: NeverScrollableScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: List<Widget>.generate(
                                        languages.length, (i) {
                                      return Container(
                                        width:
                                            MediaQuery.of(context).size.width -
                                                24 -
                                                48,
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 10),
                                        padding: EdgeInsets.all(24),
                                        decoration: BoxDecoration(
                                          color: background,
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color: color,
                                              offset: Offset(0, 0.2),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            TextField(
                                              controller: nameControllers[i],
                                              decoration: InputDecoration(
                                                enabled: false,
                                                disabledBorder:
                                                    OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: background)),
                                                labelText: 'Artist/Talent',
                                                labelStyle: TextStyle(
                                                    color: background1,
                                                    fontSize: 14),
                                                contentPadding:
                                                    EdgeInsets.all(8),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 24,
                                            ),
                                            TextField(
                                              controller:
                                                  characterControllers[i],
                                              decoration: InputDecoration(
                                                enabled: false,
                                                disabledBorder:
                                                    OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: background)),
                                                labelText: 'Character Name',
                                                labelStyle: TextStyle(
                                                    color: background1,
                                                    fontSize: 14),
                                                focusColor: Colors.white,
                                                contentPadding:
                                                    EdgeInsets.all(8),
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
                                  ),
                                ),
                              ),
                              Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: Colors.black26,
                                              width: 0.5))),
                                  child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        '${actor.days} days',
                                        style: TextStyle(
                                            color: background1,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationThickness: 1),
                                      ))),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Colors.black26,
                                            width: 0.5))),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child:
                                          Text('Scenes', style: headingStyle),
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: actor.scenes.length < 1
                                          ? Text(
                                              'No Scenes',
                                              style:
                                                  TextStyle(color: background1),
                                            )
                                          : Wrap(
                                              direction: Axis.horizontal,
                                              spacing: 4,
                                              children: List<Widget>.generate(
                                                actor.scenes.length,
                                                (i) {
                                                  return InkWell(
                                                    onTap: () {},
                                                    child: Container(
                                                      margin: EdgeInsets.all(2),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: color,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(300),
                                                      ),
                                                      child: Text(
                                                          '${Utils.scenesMap[actor.scenes[i]].titles[languages[selectedLanguage]]}'),
                                                    ),
                                                  );
                                                },
                                              )),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Colors.black26,
                                            width: 0.5))),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Costumes',
                                        style: headingStyle,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    costumes.length < 1
                                        ? Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'No Costumes',
                                              style:
                                                  TextStyle(color: background1),
                                            ),
                                          )
                                        : Align(
                                            alignment: Alignment.centerLeft,
                                            child: Wrap(
                                                spacing: 4,
                                                direction: Axis.horizontal,
                                                children: List<Widget>.generate(
                                                  costumes.length,
                                                  (i) {
                                                    return InkWell(
                                                      onLongPress: () async {
                                                        await Navigator.push(
                                                            context,
                                                            Utils.createRoute(
                                                                CostumesPage(
                                                                  project:
                                                                      project,
                                                                  costume: Utils
                                                                          .costumesMap[
                                                                      costumes
                                                                          .elementAt(
                                                                              i)],
                                                                ),
                                                                Utils.DTU));
                                                        setState(() {});
                                                      },
                                                      child: Container(
                                                        margin:
                                                            EdgeInsets.all(2),
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 8,
                                                                vertical: 2),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: color,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      300),
                                                        ),
                                                        child: Text(
                                                            '${Utils.costumesMap[costumes.elementAt(i)].title}'),
                                                      ),
                                                    );
                                                  },
                                                )),
                                          ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
