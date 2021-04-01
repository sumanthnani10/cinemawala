import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinemawala/utils.dart';
import 'package:flutter/material.dart';
import 'dart:io';
class AddProject1 extends StatefulWidget {
  AddProject1({Key key}) : super(key: key);

  @override
  _AddProject1 createState() => _AddProject1();
}

class _AddProject1 extends State<AddProject1> with SingleTickerProviderStateMixin{
  Color background, background1, color;
  int selected_language = 0;
  Map<dynamic, dynamic> project;
  File projectImage;
  TextEditingController projectNameController,productionNameController,productionNumberController,producerNameController,directorNameController,dopNameController
  ,artDirectorNameController;
  String projectName,productionName,producerName,directorName,dopName,artDirectorName;
  int productionNumber;
  @override
  void initState() {
    project = {
      "project_name":"",
      "production_name": "",
      "production_number": "",
      "producer": "",
      "director": "",
      "dop": "",
      "art_director": "",
      "image": "",
    };
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
          "Add Project",
          style: TextStyle(color: background1),
        ),
      ),
      body: GestureDetector(
        onTap: (){FocusScope.of(context).unfocus();},
        child: Container(
          child:
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              String image_path = await Utils.askSource(context);
                              if (image_path != null) {
                                projectImage = File(image_path);
                              } else {
                                projectImage = null;
                              }
                              setState(() {});
                            },
                            child: AspectRatio(
                                aspectRatio: 4 / 3,
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: projectImage==null ?
                                    ColoredBox(
                                      color: Colors.grey,
                                      child: Center(
                                        child: Text(
                                          'Add Image',
                                          style: TextStyle(
                                              color: background,
                                              fontSize: 16),
                                        ),
                                      ),
                                    ) : Image(
                                      image: FileImage(projectImage),
                                      fit: BoxFit.cover,
                                    )
                                )),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              if (projectImage != null)
                                RaisedButton.icon(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16)),
                                    label: Text(
                                      'Remove',
                                      style: TextStyle(
                                          color: background1, fontSize: 20),
                                    ),
                                    color: color,
                                    icon: Icon(
                                      Icons.close,
                                      color: background1,
                                      size: 20,
                                    ),
                                    onPressed: () async {
                                      setState(() {});
                                    }),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 32),
                                child: RaisedButton.icon(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16)),
                                    label: Text(
                                      'Edit',
                                      style:
                                      TextStyle(color: background1, fontSize: 20),
                                    ),
                                    color: color,
                                    icon: Icon(
                                      Icons.edit,
                                      color: background1,
                                      size: 20,
                                    ),
                                    onPressed: () async {
                                      String image_path =
                                      await Utils.askSource(context);
                                      if (image_path != null) {
                                        projectImage = File(image_path);
                                      } else {
                                        projectImage = null;
                                      }
                                      setState(() {});
                                    }),
                              )

                            ],
                          ),
                        ),
                            ],
                    ),
                    SizedBox(height: 32,),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 4,horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical : 12),
                            child: Text("Project Details",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: TextField(
                              textInputAction: TextInputAction.next,
                              controller: projectNameController,
                              textCapitalization: TextCapitalization.none,
                              onChanged: (v) {
                                project['project_name'] = v;
                                setState(() {});
                              },
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: background1)),
                                labelText: "Project Name",
                                contentPadding: EdgeInsets.all(8),
                                labelStyle: TextStyle(color: background1, fontSize: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
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
                                  child: TextField(
                                    textInputAction: TextInputAction.next,
                                    controller: productionNameController,
                                    textCapitalization: TextCapitalization.none,
                                    onChanged: (v) {
                                      project['production_name'] = v;
                                      setState(() {});
                                    },
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: background1)),
                                      labelText: "Production Name",
                                      contentPadding: EdgeInsets.all(8),
                                      labelStyle: TextStyle(color: background1, fontSize: 14),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 6,bottom: 6,left: 4),
                                  child: TextField(
                                    textInputAction: TextInputAction.next,
                                    controller: productionNumberController,
                                    textCapitalization: TextCapitalization.none,
                                    onChanged: (v) {
                                      productionNumber = int.parse(v);
                                      project['production_number'] = productionNumber;
                                      setState(() {});
                                    },
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: background1)),
                                      labelText: "Production Number",
                                      contentPadding: EdgeInsets.all(8),
                                      labelStyle: TextStyle(color: background1, fontSize: 14),
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
                            child: TextField(
                              textInputAction: TextInputAction.next,
                              controller: producerNameController,
                              textCapitalization: TextCapitalization.none,
                              onChanged: (v) {
                                project['producer'] = v;
                                setState(() {});
                              },
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: background1)),
                                labelText: "Producer Name",
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
                            child: TextField(
                              textInputAction: TextInputAction.next,
                              controller: directorNameController,
                              textCapitalization: TextCapitalization.none,
                              onChanged: (v) {
                                project['director'] = v;
                                setState(() {});
                              },
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: background1)),
                                labelText: "Director Name",
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
                            child: TextField(
                              textInputAction: TextInputAction.next,
                              controller: dopNameController,
                              textCapitalization: TextCapitalization.none,
                              onChanged: (v) {
                                project['dop'] = v;
                                setState(() {});
                              },
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: background1)),
                                labelText: "D.O.P Name",
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
                            child: TextField(
                              textInputAction: TextInputAction.next,
                              controller: artDirectorNameController,
                              textCapitalization: TextCapitalization.none,
                              onChanged: (v) {
                                project['art_director'] = v;
                                setState(() {});
                              },
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: background1)),
                                labelText: "Art Director Name",
                                contentPadding: EdgeInsets.all(8),
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
                                  onPressed: () async {},
                                  child: Text(
                                    "Save Details",
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}