import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinemawala/projects/project.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils.dart';

class AddLocation extends StatefulWidget {
  final Project project;
  final Map<dynamic, dynamic> location;

  AddLocation({Key key, @required this.project, this.location})
      : super(key: key);

  @override
  _AddLocation createState() {
    return _AddLocation(project, location);
  }
}

class _AddLocation extends State<AddLocation>
    with SingleTickerProviderStateMixin {
  final Project project;
  Color background, background1, color;
  var locationController, shootLocationController, descriptionController;
  Map<dynamic, dynamic> location;
  List<File> locationImages = [];
  bool loading = true, edit = false;

  _AddLocation(this.project, this.location);

  @override
  void initState() {
    locationImages = [null, null, null, null];
    if (location == null) {
      location = {
        "added_by": '${Utils.USER_ID}',
        "location": "",
        "shoot_location": "",
        "used_in": [],
        "project_id": "${project.id}",
        "description": "",
        "images": [],
        "id": '${Utils.generateId('location_')}',
        "last_edit_by": '${Utils.USER_ID}',
      };
      location['created'] = DateTime.now().millisecondsSinceEpoch;
      location['last_edit_on'] = location['created'];
    } else {
      edit = true;
      location['last_edit_on'] = DateTime.now().millisecondsSinceEpoch;
      location['last_edit_by'] = "${Utils.USER_ID}";
    }
    locationController = new TextEditingController(text: location['location']);
    shootLocationController =
        new TextEditingController(text: location['shoot_location']);
    descriptionController =
        new TextEditingController(text: location['description']);
    for (int i = location['images'].length; i < 4; i++) {
      location['images'].add('');
    }
    // // debugPrint("${location}");

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // // debugPrint("${location}");
    // // debugPrint("${locationImages}");
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
          edit ? "Edit Location" : "Add Location",
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
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
                child: Wrap(
                  children: List<Widget>.generate(4, (i) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () async {
                              String image_path =
                                  await Utils.askSource(context);
                              if (image_path != null) {
                                locationImages[i] = File(image_path);
                              }
                              setState(() {});
                            },
                            child: SizedBox(
                              width: 100,
                              height: 75,
                              child: AspectRatio(
                                  aspectRatio: 4 / 3,
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: locationImages[i] == null
                                          ? location['images'][i] == ''
                                              ? ColoredBox(
                                                  color: Colors.grey,
                                                  child: Center(
                                                    child: Text(
                                                      'Add Image',
                                                      style: TextStyle(
                                                          color: background,
                                                          fontSize: 12),
                                                    ),
                                                  ),
                                                )
                                              : CachedNetworkImage(
                                                  progressIndicatorBuilder:
                                                      (context, url,
                                                              progress) =>
                                                          LinearProgressIndicator(
                                                    value: progress.progress,
                                                  ),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Center(
                                                              child: Text(
                                                    'Image',
                                                    style: const TextStyle(
                                                        color: Colors.grey),
                                                  )),
                                                  useOldImageOnUrlChange: true,
                                                  imageUrl: location['images']
                                                      [i],
                                                  fit: BoxFit.cover,
                                                )
                                          : Image(
                                              image:
                                                  FileImage(locationImages[i]),
                                              fit: BoxFit.cover,
                                            ))),
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              if (location['images'][i] != '' ||
                                  locationImages[i] != null)
                                CircleAvatar(
                                  backgroundColor: color,
                                  maxRadius: 14,
                                  child: IconButton(
                                    onPressed: () async {
                                      location['images'][i] = '';
                                      locationImages[i] = null;
                                      setState(() {});
                                    },
                                    color: background,
                                    splashColor: background1.withOpacity(0.2),
                                    icon: Icon(
                                      Icons.close,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              SizedBox(
                                height: 8,
                              ),
                              CircleAvatar(
                                backgroundColor: color,
                                maxRadius: 14,
                                child: IconButton(
                                  onPressed: () async {
                                    String image_path =
                                        await Utils.askSource(context);
                                    if (image_path != null) {
                                      locationImages[i] = File(image_path);
                                    }
                                    setState(() {});
                                  },
                                  color: background,
                                  splashColor: background1.withOpacity(0.2),
                                  icon: Icon(
                                    Icons.edit,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  }),
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
                          controller: locationController,
                          onChanged: (v) {
                            location['location'] = v;
                          },
                          maxLines: 1,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: background1)
                                //borderSide: const BorderSide(color: Colors.white)
                                ),
                            labelText: 'Location',
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
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          controller: shootLocationController,
                          onChanged: (v) {
                            location['shoot_location'] = v;
                          },
                          maxLines: 1,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: background1)),
                            labelText: 'Shoot Location',
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
                            location['description'] = v;
                          },
                          controller: descriptionController,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: background1)
                                //borderSide: const BorderSide(color: Colors.white)
                                ),
                            labelText: 'Description',
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
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                        child: FlatButton(
                            color: color,
                            splashColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            onPressed: () async {
                              if (edit) {
                                editLocation();
                              } else {
                                addLocation();
                              }
                            },
                            child: Text(
                              'Save',
                              style: TextStyle(
                                  color: background1,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16),
                            )),
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

  addLocation() async {
    Utils.showLoadingDialog(context, 'Adding Location');

    bool imageUploaded = true;
    var back = false;

    var imagesLinks = [];

    for (int i = 0; i < 4; i++) {
      File locationImage = locationImages[i];
      if (locationImage != null) {
        try {
          final metadata = SettableMetadata(
              contentType: 'image/png',
              customMetadata: {'picked-file-path': locationImage.path});

          if (kIsWeb) {
            await FirebaseStorage.instance
                .ref()
                .child(
                    'projects/${project.id}/locations/${location['id']}/${location['id']}_${imagesLinks.length}.png')
                .putData(await locationImage.readAsBytes(), metadata);
          } else {
            await FirebaseStorage.instance
                .ref()
                .child(
                    'projects/${project.id}/locations/${location['id']}/${location['id']}_${imagesLinks.length}.png')
                .putFile(locationImage, metadata);
          }

          imagesLinks.add(await FirebaseStorage.instance
              .ref()
              .child(
                  'projects/${project.id}/locations/${location['id']}/${location['id']}_${imagesLinks.length}.png')
              .getDownloadURL());
        } catch (e) {
          imageUploaded = false;
          // // debugPrint(e.message);
        }
      }
    }

    location['images'] = imagesLinks;

    // // debugPrint("${location}");

    try {
      if (imageUploaded) {
        var resp = await http.post(Utils.ADD_LOCATION,
            body: jsonEncode(location),
            headers: {"Content-Type": "application/json"});
        // // // debugPrint(resp.body);
        var r = jsonDecode(resp.body);
        Navigator.pop(context);
        if (resp.statusCode == 200) {
          if (r['status'] == 'success') {
            back = true;
            await Utils.showSuccessDialog(
                context,
                'Location Added',
                'Location has been added successfully.',
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
      // // debugPrint(e);
      Navigator.pop(context);
      await Utils.showErrorDialog(
          context, 'Something went wrong.', 'Please try again after sometime.');
    }
    Navigator.pop(context, back);
  }

  editLocation() async {
    Utils.showLoadingDialog(context, 'Editing Location');

    bool imageUploaded = true;
    var back = false;

    var imagesLinks = [];

    for (int i = 0; i < 4; i++) {
      File locationImage = locationImages[i];
      if (locationImage != null) {
        try {
          final metadata = SettableMetadata(
              contentType: 'image/png',
              customMetadata: {'picked-file-path': locationImage.path});

          if (kIsWeb) {
            await FirebaseStorage.instance
                .ref()
                .child(
                    'projects/${project.id}/locations/${location['id']}/${location['id']}_${imagesLinks.length}.png')
                .putData(await locationImage.readAsBytes(), metadata);
          } else {
            await FirebaseStorage.instance
                .ref()
                .child(
                    'projects/${project.id}/locations/${location['id']}/${location['id']}_${imagesLinks.length}.png')
                .putFile(locationImage, metadata);
          }

          imagesLinks.add(await FirebaseStorage.instance
              .ref()
              .child(
                  'projects/${project.id}/locations/${location['id']}/${location['id']}_${imagesLinks.length}.png')
              .getDownloadURL());
        } catch (e) {
          imageUploaded = false;
          // // debugPrint(e.message);
        }
      } else {
        if (i < location['images'].length) {
          if (location['images'][i] != '') {
            imagesLinks.add(location['images'][i]);
          }
        }
      }
    }

    location['images'] = imagesLinks;

    // // debugPrint("${location}");

    try {
      if (imageUploaded) {
        var resp = await http.post(Utils.EDIT_LOCATION,
            body: jsonEncode(location),
            headers: {"Content-Type": "application/json"});
        // // // debugPrint(resp.body);
        var r = jsonDecode(resp.body);
        Navigator.pop(context);
        if (resp.statusCode == 200) {
          if (r['status'] == 'success') {
            back = true;
            await Utils.showSuccessDialog(
                context,
                'Location Edited',
                'Location has been added successfully.',
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
}
