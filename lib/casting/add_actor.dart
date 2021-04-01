import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinemawala/projects/project.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils.dart';

class AddActor extends StatefulWidget {
  final Project project;
  final Map<dynamic, dynamic> actor;

  const AddActor({Key key, @required this.project, this.actor})
      : super(key: key);

  @override
  _AddActorState createState() => _AddActorState(project, actor);
}

class _AddActorState extends State<AddActor>
    with SingleTickerProviderStateMixin {
  final Project project;

  Color background, background1, color;
  int selectedLanguage = 0;
  bool loading = true, edit = false;

  List<TextEditingController> nameControllers = [], characterControllers = [];

  List<String> languages = ['English', 'తెలుగు', 'हिंदी', 'தமிழ்'];
  List<dynamic> langsInEnglish = [];
  Map<dynamic, dynamic> actor;
  File actorImage;

  ScrollController cardScrollController = new ScrollController();

  _AddActorState(this.project, this.actor);

  @override
  void initState() {
    actorImage = null;
    langsInEnglish = project.languages;
    if (actor == null) {
      actor = {
        "added_by": "${Utils.USER_ID}",
        "names": {},
        "costumes": {},
        "days": 0,
        "project_id": "${project.id}",
        "scenes": [],
        "image": "",
        "id": "${Utils.generateId('cast_')}",
        "characters": {},
        "last_edit_by": "${Utils.USER_ID}"
      };
      actor['created'] = DateTime.now().millisecondsSinceEpoch;
      actor['last_edit_on'] = actor['created'];
      for (var i in langsInEnglish) {
        nameControllers.add(new TextEditingController());
        characterControllers.add(new TextEditingController());
        actor["names"][i] = "";
        actor["characters"][i] = "";
      }
    } else {
      edit = true;
      actor['last_edit_on'] = DateTime.now().millisecondsSinceEpoch;
      actor['last_edit_by'] = "${Utils.USER_ID}";
      for (var i in langsInEnglish) {
        nameControllers.add(new TextEditingController(text: actor["names"][i]));
        characterControllers
            .add(new TextEditingController(text: actor["characters"][i]));
      }
    }
    // debugPrint('${actor}');
    super.initState();
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
        iconTheme: IconThemeData(color: background1),
        title: Text(
          edit ? "Edit Artist" : "Add Artist",
          style: TextStyle(color: background1),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
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
                        child: InkWell(
                      onTap: () async {
                        String imagePath = await Utils.askSource(context);
                        if (imagePath != null) {
                          actorImage = File(imagePath);
                        } else {
                          actorImage = null;
                        }
                        setState(() {});
                      },
                      child: actorImage == null
                          ? actor['image'] == ''
                              ? CircleAvatar(
                                  backgroundColor: Colors.grey,
                                  radius: 100,
                                  child: Text(
                                    'Add Image',
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
                                      (context, url, progress) => Center(
                                              child: LinearProgressIndicator(
                                            value: progress.progress,
                                          )),
                                  errorWidget: (context, url, error) => Center(
                                          child: Text(
                                        'Image',
                                        style:
                                            const TextStyle(color: Colors.grey),
                                      )),
                                  useOldImageOnUrlChange: true,
                                  imageUrl: actor['image'])
                          : CircleAvatar(
                              backgroundImage: FileImage(actorImage),
                              radius: 100,
                            ),
                    )),
                    if (actor['image'] != '' || actorImage != null)
                      Positioned(
                        bottom: 10,
                        left: 10,
                        child: InkWell(
                          onTap: () async {
                            actor['image'] = '';
                            actorImage = null;
                            setState(() {});
                          },
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.close,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: InkWell(
                        onTap: () async {
                          String imagePath = await Utils.askSource(context);
                          if (imagePath != null) {
                            actorImage = File(imagePath);
                          } else {
                            actorImage = null;
                          }
                          setState(() {});
                        },
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.edit,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 24,
                      ),
                      Container(
                        color: background,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: List<Widget>.generate(
                                langsInEnglish.length, (i) {
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
                                            text:
                                                '${languages[i] ?? langsInEnglish[i]}',
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
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 14),
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
                                      color: const Color(0xff6fd8a8),
                                      offset: Offset(0, 0.2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    TextField(
                                      textInputAction: TextInputAction.next,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      controller: nameControllers[i],
                                      onChanged: (v) {
                                        actor['names'][langsInEnglish[i]] = v;
                                      },
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: background1)
                                            //borderSide: const BorderSide(color: Colors.white)
                                            ),
                                        labelText: 'Artist Name',
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
                                      textInputAction: TextInputAction.done,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      controller: characterControllers[i],
                                      onChanged: (v) {
                                        actor['characters'][langsInEnglish[i]] =
                                            v;
                                      },
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: background1)
                                            // borderSide: const BorderSide(color: Colors.white)
                                            ),
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
                      InkWell(
                        onTap: () {
                          if (edit) {
                            editArtist();
                          } else {
                            addArtist();
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(32),
                          ),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Center(
                            child: Text(
                              'Save',
                              style: TextStyle(
                                  color: background1,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  addArtist() async {
    Utils.showLoadingDialog(context, 'Adding Artist');

    bool imageUploaded = true;
    var back = false;

    if (actorImage != null) {
      try {
        final metadata = SettableMetadata(
            contentType: 'image/png',
            customMetadata: {'picked-file-path': actorImage.path});

        if (kIsWeb) {
          await FirebaseStorage.instance
              .ref()
              .child('projects/${project.id}/casting/${actor['id']}.png')
              .putData(await actorImage.readAsBytes(), metadata);
        } else {
          await FirebaseStorage.instance
              .ref()
              .child('projects/${project.id}/casting/${actor['id']}.png')
              .putFile(actorImage, metadata);
        }

        actor['image'] = await FirebaseStorage.instance
            .ref()
            .child('projects/${project.id}/casting/${actor['id']}.png')
            .getDownloadURL();
      } catch (e) {
        imageUploaded = false;
        // debugPrint(e.message);
      }
    }

    // debugPrint("${actor}");

    try {
      if (imageUploaded) {
        var resp = await http.post(Utils.ADD_ARTIST,
            body: jsonEncode(actor),
            headers: {"Content-Type": "application/json"});
        // // debugPrint(resp.body);
        var r = jsonDecode(resp.body);
        Navigator.pop(context);
        if (resp.statusCode == 200) {
          back = true;
          if (r['status'] == 'success') {
            await Utils.showSuccessDialog(
                context,
                'Artist Added',
                'Artist has been added successfully.',
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
      } else {
        Navigator.pop(context);
        await Utils.showErrorDialog(context, 'Something went wrong.',
            'Please try again after sometime.');
      }
    } catch (e) {
      // debugPrint(e);
      Navigator.pop(context);
      await Utils.showErrorDialog(
          context, 'Something went wrong.', 'Please try again after sometime.');
    }
    Navigator.pop(context, back);
  }

  editArtist() async {
    Utils.showLoadingDialog(context, 'Editing Artist');

    bool imageUploaded = true;
    var back = false;

    if (actorImage != null) {
      try {
        final metadata = SettableMetadata(
            contentType: 'image/png',
            customMetadata: {'picked-file-path': actorImage.path});

        if (kIsWeb) {
          await FirebaseStorage.instance
              .ref()
              .child('projects/${project.id}/casting/${actor['id']}.png')
              .putData(await actorImage.readAsBytes(), metadata);
        } else {
          await FirebaseStorage.instance
              .ref()
              .child('projects/${project.id}/casting/${actor['id']}.png')
              .putFile(actorImage, metadata);
        }

        actor['image'] = await FirebaseStorage.instance
            .ref()
            .child('projects/${project.id}/casting/${actor['id']}.png')
            .getDownloadURL();
      } catch (e) {
        imageUploaded = false;
        // debugPrint(e.message);
      }
    }

    // debugPrint("${actor}");

    try {
      if (imageUploaded) {
        var resp = await http.post(Utils.EDIT_ARTIST,
            body: jsonEncode(actor),
            headers: {"Content-Type": "application/json"});
        // // debugPrint(resp.body);
        var r = jsonDecode(resp.body);
        Navigator.pop(context);
        if (resp.statusCode == 200) {
          back = true;
          if (r['status'] == 'success') {
            back = true;
            await Utils.showSuccessDialog(
                context,
                'Artist Edited',
                'Artist has been edited successfully.',
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
      } else {
        Navigator.pop(context);
        await Utils.showErrorDialog(context, 'Something went wrong.',
            'Please try again after sometime.');
      }
    } catch (e) {
      // debugPrint(e);
      Navigator.pop(context);
      await Utils.showErrorDialog(
          context, 'Something went wrong.', 'Please try again after sometime.');
    }
    Navigator.pop(context, back);
  }

  uploadArtistImage() async {
    var req = http.MultipartRequest(
        'POST', Uri.parse('${Utils.UPLOAD_ARTIST_IMAGE}'));
    Map<String, String> headers = {"Content-type": "multipart/form-data"};

    req.headers.addAll(headers);
    req.fields
        .addAll({"name": "test", "email": "test@gmail.com", "id": "12345"});

    req.files.add(
      http.MultipartFile(
        'image',
        actorImage.readAsBytes().asStream(),
        actorImage.lengthSync(),
        filename: 'image',
      ),
    );
    // debugPrint("request: " + req.toString());
    // var res = await req.send();
    // debugPrint("${res}");
    // debugPrint("${res.statusCode}");
  }
}
