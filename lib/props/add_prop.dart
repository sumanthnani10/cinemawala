import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinemawala/projects/project.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../utils.dart';
import 'prop.dart';

class AddProp extends StatefulWidget {
  final Map<dynamic, dynamic> prop;
  final Project project;
  final bool isPopUp;
  const AddProp({Key key, @required this.project, this.prop,this.isPopUp}) : super(key: key);

  @override
  _AddProp createState() => _AddProp(this.project, this.prop,this.isPopUp);
}

class _AddProp extends State<AddProp> with SingleTickerProviderStateMixin {
  Color background, background1, color;
  var nameController, descriptionController;
  bool isPopUp;
  Map<dynamic, dynamic> prop;
  final Project project;
  XFile fImage;
  bool loading = true, edit = false;

  _AddProp(this.project, this.prop, this.isPopUp);

  Widget widget1() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              InkWell(
                onTap: () async {
                  pickImageFile();
                },
                child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: fImage == null
                            ? prop['reference_image'] == ''
                                ? ColoredBox(
                                    color: Colors.grey,
                                    child: Center(
                                      child: Text(
                                        'Add Image',
                                        style: TextStyle(
                                            color: background, fontSize: 16),
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
                          imageUrl: prop['reference_image'],
                          fit: BoxFit.cover,
                        )
                            : Image(
                          image: kIsWeb
                                    ? NetworkImage(fImage.path)
                                    : FileImage(File(fImage.path)),
                                fit: BoxFit.cover,
                              ))),
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (prop['reference_image'] != '' || fImage != null)
                    ElevatedButton.icon(
                        style: Utils.elevatedButtonStyle,
                        label: Text(
                          'Remove',
                          style: TextStyle(color: background1, fontSize: 20),
                        ),
                        icon: Icon(
                          Icons.close,
                          color: background1,
                          size: 20,
                        ),
                        onPressed: () async {
                          prop['reference_image'] = '';
                          fImage = null;
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
                        pickImageFile();
                      }),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget widget2(){
    return Align(
      alignment: isPopUp ? Alignment.bottomCenter : Alignment.center,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:isPopUp ? BorderRadius.only(
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
                  controller: nameController,
                  onChanged: (v) {
                    prop['title'] = v;
                  },
                  maxLines: 1,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: background1)
                      //borderSide: const BorderSide(color: Colors.white)
                    ),
                    labelText: 'Property Name',
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
                    prop['description'] = v;
                  },
                  controller: descriptionController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: background1)
                      //borderSide: const BorderSide(color: Colors.white)
                    ),
                    labelText: 'Property Description',
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
                    editProp();
                  } else {
                    addProp();
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

  @override
  void initState() {
    fImage = null;
    isPopUp = isPopUp ?? true;
    if (prop == null) {
      prop = {
        "added_by": '${Utils.USER_ID}',
        "title": "",
        "used_in": [],
        "project_id": "${project.id}",
        "description": "",
        "reference_image": "",
        "id": '${Utils.generateId('prop_')}',
        "last_edit_by": '${Utils.USER_ID}',
      };
      prop['created'] = DateTime.now().millisecondsSinceEpoch;
      prop['last_edit_on'] = prop['created'];
    } else {
      edit = true;
      prop['last_edit_on'] = DateTime.now().millisecondsSinceEpoch;
      prop['last_edit_by'] = "${Utils.USER_ID}";
    }
    nameController = new TextEditingController(text: prop['title']);
    descriptionController =
        new TextEditingController(text: prop['description']);
    // debugPrint("${prop}");
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
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: Utils.linearGradient,
          ),
        ),
        backgroundColor: color,
        iconTheme: IconThemeData(color: background1),
        title: Text(
          edit ? "Edit Property" : "Add Property",
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
            widget2(),
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

  pickImageFile() async {
    fImage = await Utils.askSource(context) ?? fImage;
    setState(() {});
  }

  addProp() async {
    Utils.showLoadingDialog(context, 'Adding Property');

    bool imageUploaded = true;

    if (fImage != null) {
      try {
        prop['reference_image'] = "";
        var r = await Utils.uploadImage(context,
            file: fImage,
            projectId: "${project.id}",
            userId: "${Utils.USER_ID}",
            id: "${prop["id"]}",
            type: "props",
            process: "add");
        imageUploaded = r[0];
        if (r[0]) {
          prop['reference_image'] = r[1];
        }
      } catch (e) {
        imageUploaded = false;
        // debugPrint(e.message);
      }
    }

    // debugPrint("${prop}");

    try {
      if (imageUploaded) {
        var resp = await http.post(Utils.ADD_PROP,
            body: jsonEncode(prop),
            headers: {"Content-Type": "application/json"});
        // // debugPrint(resp.body);
        var r = jsonDecode(resp.body);
        Navigator.pop(context);
        if (resp.statusCode == 200) {
          if (r['status'] == 'success') {
            Utils.propsMap[prop['id']] = Prop.fromJson(prop);
            Utils.props = Utils.propsMap.values.toList();

            await Utils.showSuccessDialog(
                context,
                'Property Added',
                'Property has been added successfully.',
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

  editProp() async {
    Utils.showLoadingDialog(context, 'Editing Property');

    bool imageUploaded = true;

    if (fImage != null) {
      try {
        prop['reference_image'] = "";
        var r = await Utils.uploadImage(context,
            file: fImage,
            projectId: "${project.id}",
            userId: "${Utils.USER_ID}",
            id: "${prop["id"]}",
            type: "props",
            process: "edit");
        imageUploaded = r[0];
        if (r[0]) {
          prop['reference_image'] = r[1];
        }
      } catch (e) {
        imageUploaded = false;
        // debugPrint(e.message);
      }
    }

    // debugPrint("${prop}");

    try {
      if (imageUploaded) {
        var resp = await http.post(Utils.EDIT_PROP,
            body: jsonEncode(prop),
            headers: {"Content-Type": "application/json"});
        // // debugPrint(resp.body);
        var r = jsonDecode(resp.body);
        Navigator.pop(context);
        if (resp.statusCode == 200) {
          if (r['status'] == 'success') {
            Utils.propsMap[prop['id']] = Prop.fromJson(prop);
            Utils.props = Utils.propsMap.values.toList();

            await Utils.showSuccessDialog(
                context,
                'Property Edited',
                'Property has been edited successfully.',
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
