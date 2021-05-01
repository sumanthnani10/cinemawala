import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinemawala/projects/project.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils.dart';
import 'costume.dart';

class AddCostume extends StatefulWidget {
  final Project project;
  final Map<dynamic, dynamic> costume;

  AddCostume({Key key, @required this.project, this.costume}) : super(key: key);

  @override
  _AddCostume createState() => _AddCostume(project, costume);
}

class _AddCostume extends State<AddCostume>
    with SingleTickerProviderStateMixin {
  final Project project;
  Color background, background1, color;
  var nameController, descriptionController;
  Map<dynamic, dynamic> costume;
  File costumeImage;
  bool loading = true, edit = false;

  _AddCostume(this.project, this.costume);

  @override
  void initState() {
    costumeImage = null;
    if (costume == null) {
      costume = {
        "added_by": '${Utils.USER_ID}',
        "title": "",
        "used_by": {},
        "project_id": "${project.id}",
        "scenes": [],
        "changed": 0,
        "description": "",
        "reference_image": "",
        "id": '${Utils.generateId('costume_')}',
        "last_edit_by": '${Utils.USER_ID}',
      };
      costume['created'] = DateTime.now().millisecondsSinceEpoch;
      costume['last_edit_on'] = costume['created'];
    } else {
      edit = true;
      costume['last_edit_on'] = DateTime.now().millisecondsSinceEpoch;
      costume['last_edit_by'] = "${Utils.USER_ID}";
    }
    nameController = new TextEditingController(text: costume['title']);
    descriptionController =
        new TextEditingController(text: costume['description']);
    // debugPrint("${costume}");

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
        automaticallyImplyLeading: !kIsWeb,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: Utils.linearGradient,
          ),
        ),
        backgroundColor: color,
        iconTheme: IconThemeData(color: background1),
        title: Text(
          edit ? "Edit Costume" : "Add Costume",
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
                padding:
                    const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () async {
                          var imagePath = await Utils.askSource(context);
                          if (imagePath != null) {
                            costumeImage = File(imagePath);
                          }
                          setState(() {});
                        },
                        child: AspectRatio(
                            aspectRatio: 4 / 3,
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: costumeImage == null
                                    ? costume['reference_image'] == ''
                                        ? ColoredBox(
                                            color: Colors.grey,
                                            child: Center(
                                              child: Text(
                                                'Add Image',
                                                style: TextStyle(
                                                    color: background,
                                                    fontSize: 16),
                                              ),
                                            ),
                                          )
                                        : CachedNetworkImage(
                                            progressIndicatorBuilder:
                                                (context, url, progress) =>
                                                    LinearProgressIndicator(
                                              value: progress.progress,
                                            ),
                                            errorWidget:
                                                (context, url, error) => Center(
                                                    child: Text(
                                              'Image',
                                              style: const TextStyle(
                                                  color: Colors.grey),
                                            )),
                                            useOldImageOnUrlChange: true,
                                            imageUrl:
                                                costume['reference_image'],
                                            fit: BoxFit.cover,
                                          )
                                    : Image(
                                        image: FileImage(costumeImage),
                                        fit: BoxFit.cover,
                                      ))),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          if (costume['reference_image'] != '' ||
                              costumeImage != null)
                            ElevatedButton.icon(
                                style: Utils.elevatedButtonStyle,
                                label: Text(
                                  'Remove',
                                  style: TextStyle(
                                      color: background1, fontSize: 20),
                                ),
                                icon: Icon(
                                  Icons.close,
                                  color: background1,
                                  size: 20,
                                ),
                                onPressed: () async {
                                  costume['reference_image'] = '';
                                  costumeImage = null;
                                  setState(() {});
                                }),
                          ElevatedButton.icon(
                              style: Utils.elevatedButtonStyle,
                              label: Text(
                                'Edit',
                                style:
                                    TextStyle(color: background1, fontSize: 20),
                              ),
                              icon: Icon(
                                Icons.edit,
                                color: background1,
                                size: 20,
                              ),
                              onPressed: () async {
                                String imagePath =
                                    await Utils.askSource(context);
                                if (imagePath != null) {
                                  costumeImage = File(imagePath);
                                }
                                setState(() {});
                              }),
                        ],
                      )
                    ],
                  ),
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
                        height: 8,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: TextField(
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          controller: nameController,
                          onChanged: (v) {
                            costume['title'] = v;
                          },
                          maxLines: 1,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: background1)
                                //borderSide: const BorderSide(color: Colors.white)
                                ),
                            labelText: 'Costume Title',
                            labelStyle:
                                TextStyle(color: background1, fontSize: 14),
                            contentPadding: EdgeInsets.all(8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: TextField(
                          textInputAction: TextInputAction.done,
                          textCapitalization: TextCapitalization.words,
                          maxLines: null,
                          onChanged: (v) {
                            costume['description'] = v;
                          },
                          controller: descriptionController,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: background1)
                                //borderSide: const BorderSide(color: Colors.white)
                                ),
                            labelText: 'Costume Description',
                            labelStyle:
                                TextStyle(color: background1, fontSize: 14),
                            contentPadding: EdgeInsets.all(8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          if (edit) {
                            editCostume();
                          } else {
                            addCostume();
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

  addCostume() async {
    Utils.showLoadingDialog(context, 'Adding Costume');

    bool imageUploaded = true;

    if (costumeImage != null) {
      try {
        final metadata = SettableMetadata(
            contentType: 'image/png',
            customMetadata: {'picked-file-path': costumeImage.path});

        if (kIsWeb) {
          await FirebaseStorage.instance
              .ref()
              .child('projects/${project.id}/costumes/${costume['id']}.png')
              .putData(await costumeImage.readAsBytes(), metadata);
        } else {
          await FirebaseStorage.instance
              .ref()
              .child('projects/${project.id}/costumes/${costume['id']}.png')
              .putFile(costumeImage, metadata);
        }

        costume['reference_image'] = await FirebaseStorage.instance
            .ref()
            .child('projects/${project.id}/costumes/${costume['id']}.png')
            .getDownloadURL();
      } catch (e) {
        imageUploaded = false;
        // debugPrint(e.message);
      }
    }

    // debugPrint("${costume}");

    try {
      if (imageUploaded) {
        var resp = await http.post(Utils.ADD_COSTUME,
            body: jsonEncode(costume),
            headers: {"Content-Type": "application/json"});
        // debugPrint(resp.body);
        var r = jsonDecode(resp.body);
        Navigator.pop(context);
        if (resp.statusCode == 200) {
          if (r['status'] == 'success') {
            Utils.costumesMap[costume['id']] = Costume.fromJson(costume);
            Utils.costumes = Utils.costumesMap.values.toList();

            await Utils.showSuccessDialog(
                context,
                'Costume Added',
                'Costume has been added successfully.',
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
    Navigator.pop(context);
  }

  editCostume() async {
    Utils.showLoadingDialog(context, 'Editing Costume');

    bool imageUploaded = true;

    if (costumeImage != null) {
      try {
        final metadata = SettableMetadata(
            contentType: 'image/png',
            customMetadata: {'picked-file-path': costumeImage.path});

        if (kIsWeb) {
          await FirebaseStorage.instance
              .ref()
              .child('projects/${project.id}/costumes/${costume['id']}.png')
              .putData(await costumeImage.readAsBytes(), metadata);
        } else {
          await FirebaseStorage.instance
              .ref()
              .child('projects/${project.id}/costumes/${costume['id']}.png')
              .putFile(costumeImage, metadata);
        }

        costume['reference_image'] = await FirebaseStorage.instance
            .ref()
            .child('projects/${project.id}/costumes/${costume['id']}.png')
            .getDownloadURL();
      } catch (e) {
        imageUploaded = false;
        // debugPrint(e.message);
      }
    }

    // debugPrint("${costume}");

    try {
      if (imageUploaded) {
        var resp = await http.post(Utils.EDIT_COSTUME,
            body: jsonEncode(costume),
            headers: {"Content-Type": "application/json"});
        // // debugPrint(resp.body);
        var r = jsonDecode(resp.body);
        Navigator.pop(context);
        if (resp.statusCode == 200) {
          if (r['status'] == 'success') {
            Utils.costumesMap[costume['id']] = Costume.fromJson(costume);
            Utils.costumes = Utils.costumesMap.values.toList();

            await Utils.showSuccessDialog(
                context,
                'Costume Edited',
                'Costume has been edited successfully.',
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
    Navigator.pop(context);
  }
}
