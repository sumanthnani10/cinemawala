import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinemawala/projects/select_languages.dart';
import 'package:cinemawala/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'project.dart';

class AddProject extends StatefulWidget {
  final Map<dynamic, dynamic> project;

  AddProject({Key key, this.project}) : super(key: key);

  @override
  _AddProject createState() => _AddProject(this.project);
}

class _AddProject extends State<AddProject>
    with SingleTickerProviderStateMixin {
  Color background, background1, color;
  Map<dynamic, dynamic> project;
  XFile fImage;
  GlobalKey<FormState> formKey = new GlobalKey<FormState>();
  TextEditingController nameController,
      productionNameController,
      productionNumberController,
      producerNameController,
      directorNameController,
      dopNameController,
      artDirectorNameController;
  String projectID = "";
  bool loading = true, edit = false;

  _AddProject(this.project);

  @override
  void initState() {
    if (project == null) {
      var now = DateTime.now();
      projectID = "${Utils.generateId("proj_")}";
      project = {
        "id": projectID,
        "languages": ['en'],
        "name": "",
        "owner_id": "${Utils.USER_ID}",
        "owner_username": "${Utils.user.username}",
        "owner_name": "${Utils.user.name}",
        "artists": {},
        "artist_ids": [],
        "schedules": ["None"],
        "roles": {
          "${Utils.USER_ID}": {
            "last_edit_on": now.millisecondsSinceEpoch,
            "created": now.millisecondsSinceEpoch,
            "last_edit_by": "${Utils.USER_ID}",
            "added_by": "${Utils.USER_ID}",
            "name": "${Utils.user.name}",
            "username": "${Utils.user.username}",
            "user_id": "${Utils.USER_ID}",
            "role": "Producer",
            "owner": true,
            "accepted": true,
            "project_id": projectID,
            "permissions": {
              "roles": {
                "view": true,
                "add": true,
                "edit": true,
              },
              "casting": {
                "view": true,
                "add": true,
                "edit": true,
              },
              "costumes": {
                "view": true,
                "add": true,
                "edit": true,
              },
              "props": {
                "view": true,
                "add": true,
                "edit": true,
              },
              "scenes": {
                "view": true,
                "add": true,
                "edit": true,
              },
              "schedule": {
                "view": true,
                "add": true,
                "edit": true,
              },
              "locations": {
                "view": true,
                "add": true,
                "edit": true,
              },
              "report": {
                "view": true,
                "add": true,
                "edit": true,
              },
              "budget": {
                "view": true,
                "add": true,
                "edit": true,
              },
            }
          }
        },
        "roles_ids": ["${Utils.USER_ID}"],
        "production_name": "",
        "production_number": 0,
        "producer": "",
        "director": "",
        "dop": "",
        "art_director": "",
        "image": "",
        "added_by": "${Utils.USER_ID}",
        "last_edit_by": "${Utils.USER_ID}",
        "last_edit_on": now.millisecondsSinceEpoch,
        "created": now.millisecondsSinceEpoch,
      };
    } else {
      edit = true;
      project['last_edit_on'] = DateTime.now().millisecondsSinceEpoch;
      project['last_edit_by'] = "${Utils.USER_ID}";
    }
    nameController = new TextEditingController(text: project['name']);
    productionNameController =
        new TextEditingController(text: project['production_name']);
    productionNumberController =
        new TextEditingController(text: "${project['production_number']}");
    producerNameController =
        new TextEditingController(text: project['producer']);
    directorNameController =
        new TextEditingController(text: project['director']);
    dopNameController = new TextEditingController(text: project['dop']);
    artDirectorNameController =
        new TextEditingController(text: project['art_director']);

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
          edit ? "Edit Project" : "Add Project",
          style: TextStyle(color: background1),
        ),
        actions: [
          TextButton.icon(
            onPressed: () async {
              if (formKey.currentState.validate()) {
                if (edit) {
                  editProject();
                } else {
                  addProject();
                }
              }
            },
            label: Text(
              edit ? "Edit" : "Add",
              style: TextStyle(color: Colors.indigo),
              textAlign: TextAlign.right,
            ),
            icon: Icon(
              edit ? Icons.edit : Icons.add,
              size: 18,
              color: Colors.indigo,
            ),
          )
        ],
      ),
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
      return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: constraints.maxWidth>Utils.mobileWidth ?
              Container(
                constraints: BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          height: 12,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: Container(
                                child: InkWell(
                                  onTap: () async {
                                    pickImageFile();
                                          },
                                  child: AspectRatio(
                                      aspectRatio: 4 / 2,
                                      child: ClipRRect(
                                          borderRadius: BorderRadius.circular(16),
                                          child: fImage == null
                                                      ? project['image'] == ''
                                                          ? ColoredBox(
                                                              color:
                                                                  Colors.grey,
                                                              child: Center(
                                                                child: Text(
                                                                  'Add Image',
                                                                  style: TextStyle(
                                                                      color:
                                                                          background,
                                                                      fontSize:
                                                                          16),
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
                                                (context, url, error) =>
                                                Center(
                                                    child: Text(
                                                      'Image',
                                                      style: const TextStyle(
                                                          color: Colors.grey),
                                                    )),
                                            useOldImageOnUrlChange: true,
                                            imageUrl: project['image'],
                                            fit: BoxFit.cover,
                                          )
                                              : Image(
                                            image: kIsWeb
                                                              ? NetworkImage(
                                                                  fImage.path)
                                                              : FileImage(File(
                                                                  fImage.path)),
                                                          fit: BoxFit.cover,
                                                        ))),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (fImage != null)
                                            ElevatedButton.icon(
                                              onPressed: () async {
                                                setState(() {
                                                  fImage = null;
                                                  project['image'] = "";
                                                });
                                              },
                                              style: Utils.elevatedButtonStyle,
                                              label: Text(
                                                'Remove',
                                                style: TextStyle(color: background1),
                                      ),
                                      icon: Icon(
                                        Icons.close,
                                        color: background1,
                                        size: 14,
                                      ),
                                    ),
                                  ElevatedButton.icon(
                                      onPressed: () async {
                                        pickImageFile();
                                              },
                                      style: Utils.elevatedButtonStyle,
                                      label: Text(
                                        'Edit',
                                        style: TextStyle(color: background1),
                                      ),
                                      icon: Icon(
                                        Icons.edit,
                                        color: background1,
                                        size: 14,
                                      ))
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 24,bottom: 12),
                          child: Text(
                            "Project Details",
                            style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: TextFormField(
                            textInputAction: TextInputAction.next,
                            controller: nameController,
                            textCapitalization: TextCapitalization.words,
                            onChanged: (v) {
                              project['name'] = v;
                            },
                            validator: (v) {
                              if (v.isEmpty) {
                                return "Enter Project Name";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: background1)),
                              labelText: "Project Name *",
                              contentPadding: EdgeInsets.all(8),
                              labelStyle: TextStyle(color: background1, fontSize: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            project['languages'] = await Navigator.push(
                                context,
                                Utils.createRoute(
                                    SelectLanguages(
                                      selectedLanguages:
                                      project['languages'].toList(),
                                    ),
                                    Utils.UTD)) ??
                                project['languages'];
                            setState(() {});
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                gradient: Utils.linearGradient,
                              ),
                              padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Languages",
                                    style: TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: List<Widget>.generate(
                                            project['languages'].length,
                                                (i) => Text(
                                                "${Utils.codeToLanguagesInEnglish[project['languages'][i]]}${i + 1 != project['languages'].length ? ", " : ""}")),
                                      ))
                                ],
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Flexible(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: TextFormField(
                                  textInputAction: TextInputAction.next,
                                  controller: productionNameController,
                                  textCapitalization: TextCapitalization.words,
                                  onChanged: (v) {
                                    project['production_name'] = v;
                                  },
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: background1)),
                                    labelText: "Production Name",
                                    prefixIcon: Icon(
                                      Icons.home_filled,
                                      color: color,
                                    ),
                                    contentPadding: EdgeInsets.all(8),
                                    labelStyle:
                                    TextStyle(color: background1, fontSize: 14),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: Padding(
                                padding:
                                const EdgeInsets.only(top: 6, bottom: 6, left: 4),
                                child: TextFormField(
                                  textInputAction: TextInputAction.next,
                                  controller: productionNumberController,
                                  textCapitalization: TextCapitalization.words,
                                  onChanged: (v) {
                                    if (v.isEmpty) v = "0";
                                    project['production_number'] = int.parse(v);
                                  },
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: background1)),
                                    labelText: "Number",
                                    contentPadding: EdgeInsets.all(8),
                                    labelStyle:
                                    TextStyle(color: background1, fontSize: 14),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: TextFormField(
                            textInputAction: TextInputAction.next,
                            controller: producerNameController,
                            textCapitalization: TextCapitalization.words,
                            onChanged: (v) {
                              project['producer'] = v;
                            },
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: background1)),
                              labelText: "Producer",
                              contentPadding: EdgeInsets.all(8),
                              prefixIcon: Icon(
                                FontAwesome.rupee,
                                color: color,
                              ),
                              labelStyle: TextStyle(color: background1, fontSize: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: TextFormField(
                            textInputAction: TextInputAction.next,
                            controller: directorNameController,
                            textCapitalization: TextCapitalization.words,
                            onChanged: (v) {
                              project['director'] = v;
                            },
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: background1)),
                              labelText: "Director",
                              prefixIcon: Icon(
                                Ionicons.ios_megaphone,
                                color: color,
                              ),
                              contentPadding: EdgeInsets.all(8),
                              labelStyle: TextStyle(color: background1, fontSize: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: TextFormField(
                            textInputAction: TextInputAction.next,
                            controller: dopNameController,
                            textCapitalization: TextCapitalization.words,
                            onChanged: (v) {
                              project['dop'] = v;
                            },
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: background1)),
                              prefixIcon: Icon(
                                Ionicons.ios_videocam,
                                color: color,
                              ),
                              labelText: "D.O.P",
                              contentPadding: EdgeInsets.all(8),
                              labelStyle: TextStyle(color: background1, fontSize: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: TextFormField(
                            textInputAction: TextInputAction.next,
                            controller: artDirectorNameController,
                            textCapitalization: TextCapitalization.words,
                            onChanged: (v) {
                              project['art_director'] = v;
                            },
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: background1)),
                              labelText: "Art Director",
                              contentPadding: EdgeInsets.all(8),
                              prefixIcon: Icon(
                                Ionicons.ios_brush,
                                color: color,
                              ),
                              labelStyle: TextStyle(color: background1, fontSize: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 16),
                          child: Center(
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: color,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8))),
                                onPressed: () async {
                                  if (formKey.currentState.validate()) {
                                    if (edit) {
                                      editProject();
                                    } else {
                                      addProject();
                                    }
                                  }
                                },
                                child: Text(
                                  edit ? "Edit Project" : "Add Project",
                                  style: TextStyle(
                                      color: background1,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16),
                                )),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
                  : Column(
                children: [
                  SizedBox(
                    height: 12,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Container(
                          child: InkWell(
                            onTap: () async {
                              pickImageFile();
                                    },
                            child: AspectRatio(
                                aspectRatio: 4 / 2,
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: fImage == null
                                                ? project['image'] == ''
                                                    ? ColoredBox(
                                                        color: Colors.grey,
                                                        child: Center(
                                                          child: Text(
                                                            'Add Image',
                                                            style: TextStyle(
                                                                color:
                                                                    background,
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
                                                    (context, url, error) =>
                                                        Center(
                                                            child: Text(
                                                  'Image',
                                                  style: const TextStyle(
                                                      color: Colors.grey),
                                                )),
                                                useOldImageOnUrlChange: true,
                                                imageUrl: project['image'],
                                                fit: BoxFit.cover,
                                              )
                                        : Image(
                                      image: kIsWeb
                                                        ? NetworkImage(
                                                            fImage.path)
                                                        : FileImage(
                                                            File(fImage.path)),
                                                    fit: BoxFit.cover,
                                                  ))),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (fImage != null)
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          setState(() {
                                            fImage = null;
                                            project['image'] = "";
                                          });
                                        },
                                        style: Utils.elevatedButtonStyle,
                                        label: Text(
                                          'Remove',
                                          style: TextStyle(color: background1),
                                ),
                                icon: Icon(
                                  Icons.close,
                                  color: background1,
                                  size: 14,
                                ),
                              ),
                            ElevatedButton.icon(
                                onPressed: () async {
                                  pickImageFile();
                                        },
                                style: Utils.elevatedButtonStyle,
                                label: Text(
                                  'Edit',
                                  style: TextStyle(color: background1),
                                ),
                                icon: Icon(
                                  Icons.edit,
                                  color: background1,
                                  size: 14,
                                ))
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      "Project Details",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      controller: nameController,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (v) {
                        project['name'] = v;
                      },
                      validator: (v) {
                        if (v.isEmpty) {
                          return "Enter Project Name";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: background1)),
                        labelText: "Project Name *",
                        contentPadding: EdgeInsets.all(8),
                        labelStyle: TextStyle(color: background1, fontSize: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      project['languages'] = await Navigator.push(
                              context,
                              Utils.createRoute(
                                  SelectLanguages(
                                    selectedLanguages:
                                        project['languages'].toList(),
                                  ),
                                  Utils.UTD)) ??
                          project['languages'];
                      setState(() {});
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: Utils.linearGradient,
                        ),
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Languages",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: List<Widget>.generate(
                                      project['languages'].length,
                                      (i) => Text(
                                          "${Utils.codeToLanguagesInEnglish[project['languages'][i]]}${i + 1 != project['languages'].length ? ", " : ""}")),
                                ))
                          ],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Flexible(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: TextFormField(
                            textInputAction: TextInputAction.next,
                            controller: productionNameController,
                            textCapitalization: TextCapitalization.words,
                            onChanged: (v) {
                              project['production_name'] = v;
                            },
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: background1)),
                              labelText: "Production Name",
                              prefixIcon: Icon(
                                Icons.home_filled,
                                color: color,
                              ),
                              contentPadding: EdgeInsets.all(8),
                              labelStyle:
                                  TextStyle(color: background1, fontSize: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Padding(
                          padding:
                              const EdgeInsets.only(top: 6, bottom: 6, left: 4),
                          child: TextFormField(
                            textInputAction: TextInputAction.next,
                            controller: productionNumberController,
                            textCapitalization: TextCapitalization.words,
                            onChanged: (v) {
                              if (v.isEmpty) v = "0";
                              project['production_number'] = int.parse(v);
                            },
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: background1)),
                              labelText: "Number",
                              contentPadding: EdgeInsets.all(8),
                              labelStyle:
                                  TextStyle(color: background1, fontSize: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      controller: producerNameController,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (v) {
                        project['producer'] = v;
                      },
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: background1)),
                        labelText: "Producer",
                        contentPadding: EdgeInsets.all(8),
                        prefixIcon: Icon(
                          FontAwesome.rupee,
                          color: color,
                        ),
                        labelStyle: TextStyle(color: background1, fontSize: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      controller: directorNameController,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (v) {
                        project['director'] = v;
                      },
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: background1)),
                        labelText: "Director",
                        prefixIcon: Icon(
                          Ionicons.ios_megaphone,
                          color: color,
                        ),
                        contentPadding: EdgeInsets.all(8),
                        labelStyle: TextStyle(color: background1, fontSize: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      controller: dopNameController,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (v) {
                        project['dop'] = v;
                      },
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: background1)),
                        prefixIcon: Icon(
                          Ionicons.ios_videocam,
                          color: color,
                        ),
                        labelText: "D.O.P",
                        contentPadding: EdgeInsets.all(8),
                        labelStyle: TextStyle(color: background1, fontSize: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      controller: artDirectorNameController,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (v) {
                        project['art_director'] = v;
                      },
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: background1)),
                        labelText: "Art Director",
                        contentPadding: EdgeInsets.all(8),
                        prefixIcon: Icon(
                          Ionicons.ios_brush,
                          color: color,
                        ),
                        labelStyle: TextStyle(color: background1, fontSize: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 0, bottom: 16),
                    child: Center(
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: color,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8))),
                          onPressed: () async {
                            if (formKey.currentState.validate()) {
                              if (edit) {
                                editProject();
                              } else {
                                addProject();
                              }
                            }
                          },
                          child: Text(
                            edit ? "Edit Project" : "Add Project",
                            style: TextStyle(
                                color: background1,
                                fontWeight: FontWeight.w600,
                                fontSize: 16),
                          )),
                    ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      }),
    );
  }

  pickImageFile() async {
    fImage = await Utils.askSource(context) ?? fImage;
    setState(() {});
  }

  addProject() async {
    Utils.showLoadingDialog(context, 'Adding Project');

    bool imageUploaded = true;

    if (fImage != null) {
      try {
        project['image'] = "";
        var r = await Utils.uploadImage(context,
            file: fImage,
            projectId: "${project["id"]}",
            userId: "${Utils.USER_ID}",
            id: "${project["id"]}",
            type: "projects",
            process: "add");
        imageUploaded = r[0];
        if (r[0]) {
          project['image'] = r[1];
        }
      } catch (e) {
        imageUploaded = false;
        debugPrint("$e");
      }
    }

    debugPrint("${project}");

    try {
      if (imageUploaded) {
        // project['owner'] = project['owner_id'];
        var resp = await http.post(Utils.ADD_PROJECT,
            body: jsonEncode(project),
            headers: {"Content-Type": "application/json"});
        debugPrint(resp.body);
        var r = jsonDecode(resp.body);
        Navigator.pop(context);
        if (resp.statusCode == 200) {
          if (r['status'] == 'success') {
            Utils.projectsMap[project['id']] = Project.fromJson(project);
            Utils.projects = Utils.projectsMap.values.toList();

            await Utils.showSuccessDialog(
                context,
                'Project Added',
                'Project has been added successfully.',
                Colors.green,
                background, () {
              Navigator.pop(context);
            });
          } else {
            await Utils.showErrorDialog(context, 'Unsuccessful', '${r['msg']}');
          }
        } else {
          debugPrint("$r");
          await Utils.showErrorDialog(context, 'Something went wrong.',
              'Please try again after sometime.');
        }
        setState(() {
          loading = false;
        });
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("$e");
      Navigator.pop(context);
      await Utils.showErrorDialog(
          context, 'Something went wrong.', 'Please try again after sometime.');
    }
    Navigator.pop(context);
  }

  editProject() async {
    Utils.showLoadingDialog(context, 'Editing Project');

    bool imageUploaded = true;

    if (fImage != null) {
      try {
        project['image'] = "";
        var r = await Utils.uploadImage(context,
            file: fImage,
            projectId: "${project["id"]}",
            userId: "${Utils.USER_ID}",
            id: "${project["id"]}",
            type: "projects",
            process: "edit");
        imageUploaded = r[0];
        if (r[0]) {
          project['image'] = r[1];
        }
      } catch (e) {
        imageUploaded = false;
        debugPrint("$e");
      }
    }

    // debugPrint("${project}");

    try {
      if (imageUploaded) {
        var bdy = {};
        bdy.addAll(project);
        /*bdy.remove("roles");
        bdy.remove("roles_ids");
        bdy.remove("artists");
        bdy.remove("artist_ids");*/
        var resp = await http.post(Utils.EDIT_PROJECT,
            body: jsonEncode(bdy),
            headers: {"Content-Type": "application/json"});
        // debugPrint(resp.body);
        var r = jsonDecode(resp.body);
        Navigator.pop(context);
        if (resp.statusCode == 200) {
          if (r['status'] == 'success') {
            Utils.projectsMap[project['id']] = Project.fromJson(project);
            Utils.projects = Utils.projectsMap.values.toList();

            await Utils.showSuccessDialog(
                context,
                'Project Edited',
                'Project has been edited successfully.',
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
