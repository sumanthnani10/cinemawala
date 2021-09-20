import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinemawala/artists/add_actor.dart';
import 'package:cinemawala/costumes/costume_page.dart';
import 'package:cinemawala/projects/project.dart';
import 'package:cinemawala/roles/select_user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../utils.dart';
import 'actor.dart';

class ActorPage extends StatefulWidget {
  final Actor actor;
  final Project project;
  final bool popUp;

  const ActorPage({Key key, @required this.actor, @required this.project, this.popUp})
      : super(key: key);

  @override
  _ActorPage createState() =>
      _ActorPage(actor: actor, project: project, popUp: this.popUp);
}

class _ActorPage extends State<ActorPage> {
  final Project project;
  Color background, color, background1;
  int selectedLanguage = 0;
  bool popUp;
  List<dynamic> langsInLang = Utils.langsInLang, languages;

  TextStyle headingStyle;
  ScrollController cardScrollController = new ScrollController();
  List<TextEditingController> nameControllers = [], characterControllers = [];
  Set<String> costumes = {};
  Actor actor;
  bool loading = false;

  _ActorPage({@required this.actor, @required this.project, this.popUp});

  @override
  void initState() {
    popUp = popUp ?? false;
    languages = project.languages;
    for (var i in languages) {
      nameControllers.add(new TextEditingController(
          text:
              '${(actor.names[i] != null && actor.names[i] != "") ? actor.names[i] : "-"}'));
      characterControllers.add(new TextEditingController(
          text:
          '${(actor.characters[i] != null && actor.characters[i] != "") ? actor.characters[i] : "-"}'));
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
            automaticallyImplyLeading: !popUp ? true : false,
            flexibleSpace: Container(
              decoration: !popUp
                  ? BoxDecoration(
                  border: Border(left: BorderSide(color: Colors.black)),
                  color: Colors.white)
                  : BoxDecoration(
                gradient: Utils.linearGradient,
              ),
            ),
            backgroundColor: color,
            title: Text(
              'Actor Info',
              style: TextStyle(color: background1),
            ),
            iconTheme: IconThemeData(color: background1),
            actions: [
              TextButton.icon(
                onPressed: () async {
                  if(project.role.permissions["casting"]["edit"]||
                      project.role.permissions["scenes"]["edit"]||
                      project.role.permissions["schedule"]["edit"]||
                      project.role.permissions["casting"]["add"]||
                      project.role.permissions["scenes"]["add"]||
                      project.role.permissions["schedule"]["add"]
                  ){
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
                  }else{
                    Utils.notAllowed(context);
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
                  size: 16,
                  color: Colors.indigo,
                ),
              )
            ],
          ),
          body: GestureDetector(
            onTap: () {},
            child: Container(
              margin: popUp
                  ? const EdgeInsets.symmetric(horizontal: 24, vertical: 48)
                  : const EdgeInsets.all(0),
              decoration: popUp
                  ? BoxDecoration(
                  color: background, borderRadius: BorderRadius.circular(8))
                  : BoxDecoration(
                border: Border(left: BorderSide(color: Colors.black)),
                color: background,
              ),
              child: Stack(
                children: [
                  if (popUp)
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
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 40,
                                              child: LinearProgressIndicator(
                                                value: progress.progress,
                                              ),
                                            ),
                                          ],
                                        ),
                                errorWidget: (context, url, error) =>
                                    Center(
                                        child: Text(
                                          'Image',
                                          style: const TextStyle(
                                              color: Colors.grey),
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
                      initialChildSize: popUp ? 318 / MediaQuery.of(context).size.height : 428 / MediaQuery.of(context).size.height ,
                      minChildSize: 318 / MediaQuery.of(context).size.height,
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
                                )
                              ]),
                          child: SingleChildScrollView(
                            controller: scrollController,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 16, 0, 4),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
                                                          (popUp
                                                              ? 48
                                                              : 0)) *
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
                                                        text:
                                                        '${langsInLang[i]}',
                                                        style: TextStyle(
                                                            color: background1,
                                                            fontSize: 14,
                                                            fontFamily:
                                                            'Poppins')),
                                                    TextSpan(
                                                        text:
                                                        '\n${Utils.codeToLanguagesInEnglish[languages[i]]}',
                                                        style: TextStyle(
                                                            fontSize: 10,
                                                            fontFamily:
                                                            'Poppins',
                                                            color:
                                                            background1)),
                                                  ],
                                                ),
                                              )),
                                        );
                                      }),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: Colors.black26,
                                              width: 0.5))),
                                  width: MediaQuery.of(context).size.width,
                                  child: SingleChildScrollView(
                                    controller: cardScrollController,
                                    physics: NeverScrollableScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: List<Widget>.generate(
                                          languages.length, (i) {
                                        return Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              24 -
                                              (popUp ? 48 : 0),
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 10),
                                          padding: EdgeInsets.all(16),
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
                                                          color:
                                                          background)),
                                                  labelText: 'Artist/Talent:',
                                                  labelStyle: TextStyle(
                                                      color: background1,
                                                      fontSize: 14),
                                                  contentPadding:
                                                  EdgeInsets.all(8),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        8),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 12,
                                              ),
                                              TextField(
                                                controller:
                                                characterControllers[i],
                                                decoration: InputDecoration(
                                                  enabled: false,
                                                  disabledBorder:
                                                  OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color:
                                                          background)),
                                                  labelText: 'Character Name:',
                                                  labelStyle: TextStyle(
                                                      color: background1,
                                                      fontSize: 14),
                                                  focusColor: Colors.white,
                                                  contentPadding:
                                                  EdgeInsets.all(8),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        8),
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
                                InkWell(
                                  child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  color: Colors.black26,
                                                  width: 0.5))),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Username: ${actor.by['username'] == "" ? "Not Assigned" : "@${actor.by['username']}"}',
                                            style: TextStyle(
                                                color: background1,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                decorationThickness: 1),
                                          ),
                                          if (actor.by['user_id'] != "")
                                            TextButton(
                                                onPressed: () async {
                                                  removeCast();
                                                },
                                                child: Text(
                                                  "Remove",
                                                  style: TextStyle(
                                                      color: Colors.deepOrange),
                                                )),
                                          if (actor.by['user_id'] == "")
                                            TextButton(
                                                onPressed: () async {
                                                  if(project.role.permissions["casting"]["edit"]||
                                                      project.role.permissions["scenes"]["edit"]||
                                                      project.role.permissions["schedule"]["edit"]||
                                                      project.role.permissions["casting"]["add"]||
                                                      project.role.permissions["scenes"]["add"]||
                                                      project.role.permissions["schedule"]["add"]
                                                  ){
                                                    askCastCredentials();
                                                  }
                                                  else{
                                                    Utils.notAllowed(context);
                                                  }
                                                },
                                                child: Text(
                                                  "Assign",
                                                  style: TextStyle(
                                                      color:project.role.permissions["casting"]["edit"]||
                                                          project.role.permissions["scenes"]["edit"]||
                                                          project.role.permissions["schedule"]["edit"]||
                                                          project.role.permissions["casting"]["add"]||
                                                          project.role.permissions["scenes"]["add"]||
                                                          project.role.permissions["schedule"]["add"] ?
                                                      Colors.blue : Utils.notPermitted),
                                                ))
                                        ],
                                      )),
                                ),
                                /*Container(
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
                                        ))),*/
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
                                          style: TextStyle(
                                              color: background1),
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
                                          style: TextStyle(
                                              color: background1),
                                        ),
                                      )
                                          : Align(
                                        alignment: Alignment.centerLeft,
                                            child: Wrap(
                                                //spacing: 4,
                                                direction: Axis.horizontal,
                                                children:
                                                List<Widget>.generate(
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
                                                                      .elementAt(i)],
                                                                ),
                                                                Utils.DTU));
                                                        setState(() {});
                                                      },
                                                      child:Container(
                                                        height: 70,
                                                        width: 70,
                                                        padding: EdgeInsets.all(2),
                                                        margin: EdgeInsets.all(2),
                                                        decoration: BoxDecoration(
                                                          color: Colors.grey,
                                                          borderRadius: BorderRadius.circular(4),
                                                        ),
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius.circular(4),
                                                          child: CachedNetworkImage(
                                                              fit: BoxFit.cover,
                                                              progressIndicatorBuilder:
                                                                  (context, url, progress) =>
                                                                        Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            SizedBox(
                                                                              width: 40,
                                                                              child: LinearProgressIndicator(
                                                                                value: progress.progress,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                              errorWidget: (context, url, error) =>
                                                                  Container(
                                                                    color: background,
                                                                    child: Center(
                                                                        child: Text(
                                                                          '${Utils.costumesMap[costumes.elementAt(i)].title}',
                                                                          style:
                                                                          TextStyle(color: background1),
                                                                        )),
                                                                  ),
                                                              useOldImageOnUrlChange: true,
                                                              imageUrl: Utils.costumesMap[costumes.elementAt(i)].referenceImage),
                                                        ),
                                                      ),
                                                      /*Container(
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
                                                      ),*/
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
            ),
          )),
    );
  }

  askCastCredentials() async {
    Map selectedUser;
    bool showError = false;
    TextEditingController codeController = new TextEditingController(text: "");
    GlobalKey<FormState> formKey = new GlobalKey<FormState>();
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setDState) {
          return AlertDialog(
            title: Text("Assign Cast"),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () async {
                      var r = await Navigator.push(
                          context,
                          Utils.createRoute(
                              SelectUser(
                                project: project,
                                selectedUser: selectedUser,
                                showSelf: true,
                              ),
                              Utils.DTU));
                      setDState(() {
                        selectedUser = r ?? selectedUser;
                      });
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: selectedUser==null ? 8 : 16),
                      decoration: BoxDecoration(
                          gradient: Utils.linearGradient,
                          borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          selectedUser==null ? Text("${"Select User"}",style: TextStyle(color: Colors.black,
                              fontSize: 14,
                          ),):Container(),
                          Text("${selectedUser == null ? "Tap to choose." : "@ ${selectedUser['username']}"}",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: selectedUser==null ? 10 : 14,
                              fontWeight: selectedUser==null ? FontWeight.normal : FontWeight.bold,
                              )),
                        ],
                      ),
                    ),
                  ),
                  if (showError)
                    Text(
                      "Select User",
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  SizedBox(
                    height: 16,
                  ),
                  TextFormField(
                    controller: codeController,
                    textCapitalization: TextCapitalization.none,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.black)),
                        labelStyle: TextStyle(color: Colors.black),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        labelText: 'Code',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.black)),
                        fillColor: Colors.white),
                    maxLines: 1,
                    validator: (v) {
                      if (v.length == 0) {
                        return 'Code is mandatory';
                      } else if (v.split(" ").length > 1) {
                        return "Spaces Not Allowed";
                      } else if (v.split(" ").first.length != 10) {
                        return "Code must be 10 characters";
                      } else {
                        return null;
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text("Assign"),
                onPressed: () async {
                  if (selectedUser != null) {
                    if (showError) {
                      setDState(() {
                        showError = false;
                      });
                    }
                    if (formKey.currentState.validate()) {
                      if (await validateCode(
                              selectedUser['id'], codeController.text) ??
                          false) {
                        await assignCast(selectedUser, codeController.text);
                      }
                    }
                  } else {
                    setDState(() {
                      showError = true;
                    });
                  }
                },
              ),
            ],
          );
        });
      },
    );
  }

  validateCode(String userId, String code) async {
    Utils.showLoadingDialog(context, "Validating Code");
    var valid = false;

    try {
      var resp = await http.post(Utils.VALIDATE_CAST_CODE,
          body: jsonEncode({"user_id": userId, "code": code}),
          headers: {"Content-Type": "application/json"});
      debugPrint(resp.body);
      var r = jsonDecode(resp.body);
      Navigator.pop(context);
      if (resp.statusCode == 200) {
        if (r['status'] == 'success') {
          valid = r['valid'] ?? false;
          if (!valid) {
            await Utils.showErrorDialog(
                context, 'Invalid', '${r['msg'] ?? "Code is Invalid"}');
          }
        } else {
          await Utils.showErrorDialog(context, 'Invalid', '${r['msg']}');
        }
      } else {
        await Utils.showErrorDialog(context, 'Something went wrong.',
            'Please try again after sometime.');
      }
      setState(() {
        loading = false;
      });
    } catch (e) {
      debugPrint("$e");
      Navigator.pop(context);
      await Utils.showErrorDialog(
          context, 'Something went wrong.', 'Please try again after sometime.');
    }

    return valid;
  }

  removeCast() async {
    Utils.showLoadingDialog(context, "Removing");

    try {
      var resp = await http.post(Utils.REMOVE_CAST,
          body: jsonEncode({
            "project_id": project.id,
            "id": actor.id,
            "last_edit_by": Utils.USER_ID,
            "user_id": actor.by['user_id']
          }),
          headers: {"Content-Type": "application/json"});
      // // debugPrint(resp.body);
      var r = jsonDecode(resp.body);
      Navigator.pop(context);
      if (resp.statusCode == 200) {
        if (r['status'] == 'success') {
          var ar = actor.toJson();
          ar["by"] = {"username": "", "user_id": ""};
          Utils.artistsMap[actor.id] = Actor.fromJson(ar);
          Utils.artists = Utils.artistsMap.values.toList();
          actor = Utils.artistsMap[actor.id];
          setState(() {});
          await Utils.showSuccessDialog(
              context,
              'Cast Removed',
              'Cast has been removed successfully.',
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
      debugPrint("$e");
      Navigator.pop(context);
      await Utils.showErrorDialog(
          context, 'Something went wrong.', 'Please try again after sometime.');
    }
  }

  assignCast(Map selectedUser, String code) async {
    Utils.showLoadingDialog(context, "Assigning");
    try {
      var resp = await http.post(Utils.ASSIGN_CAST,
          body: jsonEncode({
            "project_id": project.id,
            "id": actor.id,
            "last_edit_by": Utils.USER_ID,
            "user_id": selectedUser["id"],
            "username": selectedUser["username"],
            "code": code
          }),
          headers: {"Content-Type": "application/json"});
      // debugPrint(resp.body);
      var r = jsonDecode(resp.body);
      Navigator.pop(context);
      if (resp.statusCode == 200) {
        if (r['status'] == 'success') {
          var ar = actor.toJson();
          ar["by"] = {
            "user_id": selectedUser["id"],
            "username": selectedUser["username"],
          };
          actor = Actor.fromJson(ar);
          Utils.artistsMap[actor.id] = actor;
          Utils.artists = Utils.artistsMap.values.toList();
          setState(() {});
          await Utils.showSuccessDialog(
              context,
              'Cast Assigned',
              'Cast has been assigned successfully.',
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
      debugPrint("$e");
      Navigator.pop(context);
      await Utils.showErrorDialog(
          context, 'Something went wrong.', 'Please try again after sometime.');
    }
    Navigator.pop(context);
  }
}

/*class ActorPopUp extends StatefulWidget {
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

  List<dynamic> langsInLang = Utils.langsInLang, languages;

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
          text: '${(actor.names[i]!=null && actor.names[i] != "") ? actor.names[i] : "-"}'));
      characterControllers.add(new TextEditingController(
          text: '${(actor.characters[i]!=null && actor.characters[i] != "") ? actor.characters[i] : "-"}'));
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
                                                    text:
                                                        '\n${Utils.codeToLanguagesInEnglish[languages[i]]}',
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
}*/
/*

scene_Oswlgw1z
scene_OswlTz1z
scene_OswlTaCz
scene_OswlPv0z

* */