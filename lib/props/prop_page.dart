import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinemawala/projects/project.dart';
import 'package:flutter/material.dart';

import '../utils.dart';
import 'add_prop.dart';
import 'prop.dart';

class PropPage extends StatefulWidget {
  final Prop prop;
  final Project project;
  final bool isPopUp;
  const PropPage({Key key, @required this.project, this.prop,this.isPopUp})
      : super(key: key);

  @override
  _PropPageState createState() => _PropPageState(project, prop,isPopUp);
}

class _PropPageState extends State<PropPage> {
  Color background, background1, color;
  bool isPopUp;
  Prop prop;
  final Project project;

  _PropPageState(this.project, this.prop,this.isPopUp);

  @override
  void initState() {
    isPopUp = isPopUp ?? true;
    // TODO: implement initState
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

    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: isPopUp ? Colors.black26 : Colors.white,
        body: Container(
          decoration: BoxDecoration(border: Border(left: BorderSide(color: Colors.black))),
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        AspectRatio(
                            aspectRatio: 4 / 3,
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: prop.referenceImage == ''
                                    ? Container(
                                        color: Colors.grey,
                                        child: Center(
                                            child: Text(
                                          'No Image',
                                          style: TextStyle(color: background),
                                        )),
                                      )
                                    : CachedNetworkImage(
                                        progressIndicatorBuilder:
                                            (context, url, progress) =>
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 40,
                                                  child:
                                                      LinearProgressIndicator(
                                                    value: progress.progress,
                                                  ),
                                                ),
                                              ],
                                            ),
                                        errorWidget: (context, url, error) =>
                                            Center(child: Text('Image')),
                                        useOldImageOnUrlChange: true,
                                        imageUrl: prop.referenceImage))),
                        Positioned(
                            top: 4,
                            right: 4,
                            child: CircleAvatar(
                              backgroundColor: project.role.permissions["props"]["edit"]||
                                  project.role.permissions["scenes"]["edit"]||
                                  project.role.permissions["schedule"]["edit"] ?
                              color : Utils.notPermitted,
                              child: IconButton(
                                onPressed: () async {
                                  if(project.role.permissions["props"]["edit"]||
                                      project.role.permissions["scenes"]["edit"]||
                                      project.role.permissions["schedule"]["edit"]){
                                    await Navigator.push(
                                        context,
                                        Utils.createRoute(
                                            AddProp(
                                              project: project,
                                              prop: prop.toJson(),
                                            ),
                                            Utils.RTL));
                                    prop = Utils.propsMap[prop.id];
                                    setState(() {});
                                  }else{
                                    Utils.notAllowed(context);
                                  }
                                },
                                icon: Icon(
                                  Icons.edit,
                                  size: 20,
                                ),
                              ),
                            ))
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom:
                                  BorderSide(color: Colors.black26, width: 0.5))),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${prop.title}',
                          style: TextStyle(
                              color: background1,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom:
                                  BorderSide(color: Colors.black26, width: 0.5))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Description :',
                              style: TextStyle(color: background1, fontSize: 14),
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${prop.description}',
                              style: TextStyle(color: background1, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom:
                                  BorderSide(color: Colors.black26, width: 0.5))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Assigned In :',
                              style: TextStyle(color: background1, fontSize: 14),
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: prop.usedIn.length < 1
                                ? Text(
                                    'No Scenes',
                                    style: TextStyle(
                                        color: background1, fontSize: 12),
                                  )
                                : Wrap(
                                    direction: Axis.horizontal,
                                    spacing: 4,
                                    children: List<Widget>.generate(
                                      prop.usedIn.length,
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
                                                  BorderRadius.circular(300),
                                            ),
                                            child: Text(
                                                '${Utils.scenesMap[prop.usedIn[i]].titles['en']}'),
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
            ),
          ),
        ),
      ),
    );
  }
}
