
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinemawala/projects/project.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../utils.dart';
import 'location.dart';

class AddLocation extends StatefulWidget {
  final Project project;
  final Map<dynamic, dynamic> location;
  final bool isPopUp;
  AddLocation({Key key, @required this.project, this.location,this.isPopUp})
      : super(key: key);

  @override
  _AddLocation createState() {
    return _AddLocation(project, location,isPopUp);
  }
}

class _AddLocation extends State<AddLocation>
    with SingleTickerProviderStateMixin {
  final Project project;
  bool isPopUp;
  Color background, background1, color;
  var locationController, shootLocationController, descriptionController;
  Map<dynamic, dynamic> location;
  List<XFile> locationImages = [];
  bool loading = true, edit = false;

  _AddLocation(this.project, this.location, this.isPopUp);

  @override
  void initState() {
    isPopUp = isPopUp ?? true;
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

  Widget widget1(){
    return Align(
      alignment: isPopUp ? Alignment.topCenter : Alignment.center,
      child: Padding(
        padding:
        const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
        child:  Wrap(
          direction: Axis.horizontal,
          children: List<Widget>.generate(4, (i) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () async {
                      pickImageFile(i);
                    },
                    child: SizedBox(
                      width: isPopUp ? 100 : 200,
                      height: isPopUp ? 75 : 150,
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
                                image: kIsWeb
                                    ? NetworkImage(locationImages[i].path)
                                    : FileImage(
                                    File(locationImages[i].path)),
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
                            pickImageFile(i);
                          },
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
        ) ,
      ),
    );
  }

  Widget widget2(){
    return Align(
      alignment: isPopUp ? Alignment.bottomCenter : Alignment.center,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: isPopUp ? BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16)): BorderRadius.all(Radius.circular(16)),
            boxShadow: [
              isPopUp ?
              BoxShadow(
                color: const Color(0x26000000),
                offset: Offset(0, -1),
                blurRadius: 10,
              ):BoxShadow(
                color: Colors.white,
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
              InkWell(
                onTap: () {
                  if (edit) {
                    editLocation();
                  } else {
                    addLocation();
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
    );
  }

  pickImageFile(int i) async {
    locationImages[i] = await Utils.askSource(context) ?? locationImages[i];
    setState(() {});
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
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: Utils.linearGradient,
          ),
        ),
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
        child: isPopUp ? Stack(
          children: [
            widget1(),
            widget2()
          ],
        ) : Row(
          children: [
            Flexible(
              flex: 6,
              child: widget1(),
            ),
            Flexible(
              flex: 4,
              child: widget2(),
            )
          ],
        ),
      ),
    );
  }

  addLocation() async {
    Utils.showLoadingDialog(context, 'Adding Location');

    bool imageUploaded = true;

    var imagesLinks = [];
    Map<String, XFile> tempLocImages = {};

    var i = 0;

    locationImages.forEach((file) {
      if (file != null) {
        tempLocImages["image_files_${i + 1}"] = locationImages[i];
        i += 1;
      }
    });

    if (tempLocImages.length > 0) {
      try {
        imagesLinks = [];

        var r = await Utils.uploadImages(context,
            files: tempLocImages,
            projectId: "${project.id}",
            userId: "${Utils.USER_ID}",
            id: "${location["id"]}",
            type: "locations",
            process: "add");

        imageUploaded = r[0];
        if (r[0]) {
          imagesLinks = r[1];
        }
      } catch (e) {
        imageUploaded = false;
        debugPrint("$e");
      }
    }

    try {
      if (imageUploaded) {
        location['images'] = imagesLinks;

        var resp = await http.post(Utils.ADD_LOCATION,
            body: jsonEncode(location),
            headers: {"Content-Type": "application/json"});
        // debugPrint(resp.body);
        var r = jsonDecode(resp.body);
        Navigator.pop(context);
        if (resp.statusCode == 200) {
          if (r['status'] == 'success') {
            Utils.locationsMap[location['id']] = Location.fromJson(location);
            Utils.locations = Utils.locationsMap.values.toList();

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
    Navigator.pop(context);
  }

  editLocation() async {
    Utils.showLoadingDialog(context, 'Editing Location');

    bool imageUploaded = true;

    var imagesLinks = [];
    Map<String, XFile> tempLocImages = {};
    int j = 1;

    for (int i = 0; i < 4; i++) {
      if (location['images'][i] != "") {
        imagesLinks.add(location['images'][i]);
        j++;
      } else if (locationImages[i] != null) {
        tempLocImages["image_files_$j"] = locationImages[i];
        j++;
      }
    }

    if (tempLocImages.length > 0) {
      try {
        var r = await Utils.uploadImages(context,
            files: tempLocImages,
            projectId: "${project.id}",
            userId: "${Utils.USER_ID}",
            id: "${location["id"]}",
            type: "locations",
            process: "add");

        imageUploaded = r[0];
        if (r[0]) {
          imagesLinks += r[1];
          if (imagesLinks.length > 4) {
            imagesLinks = imagesLinks.sublist(0, 4);
          }
        }
      } catch (e) {
        imageUploaded = false;
        debugPrint("$e");
      }
    }

    try {
      if (imageUploaded) {
        location['images'] = imagesLinks;

        var resp = await http.post(Utils.EDIT_LOCATION,
            body: jsonEncode(location),
            headers: {"Content-Type": "application/json"});
        // // // debugPrint(resp.body);
        var r = jsonDecode(resp.body);
        Navigator.pop(context);
        if (resp.statusCode == 200) {
          if (r['status'] == 'success') {
            Utils.locationsMap[location['id']] = Location.fromJson(location);
            Utils.locations = Utils.locationsMap.values.toList();

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
    Navigator.pop(context);
  }
}