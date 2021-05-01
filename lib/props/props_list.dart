import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinemawala/projects/project.dart';
import 'package:cinemawala/props/add_prop.dart';
import 'package:cinemawala/props/prop.dart';
import 'package:cinemawala/props/prop_page.dart';
import 'package:cinemawala/scenes/scene.dart';
import 'package:cinemawala/scenes/select_props.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

class PropsList extends StatefulWidget {
  final Project project;

  PropsList({Key key, @required this.project}) : super(key: key);

  @override
  _PropsList createState() => _PropsList(project);
}

class _PropsList extends State<PropsList> with SingleTickerProviderStateMixin {
  final Project project;
  Color background, background1, color;

  List<Scene> scenes;
  List<Prop> props = [];
  var propTitleStyle = TextStyle(color: Colors.black);
  var propDescriptionStyle = TextStyle(fontSize: 14, color: Colors.black54);
  var usedByStyle = TextStyle(fontSize: 10, color: Colors.black54);
  bool loading = false;

  _PropsList(this.project);

  @override
  void initState() {
    loading = true;
    props = Utils.props ?? [];
    scenes = Utils.scenes ?? [];
    if (Utils.props == null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        getProps();
      });
    }
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
    return DefaultTabController(
      length: 2,
      initialIndex: 1,
      child: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          automaticallyImplyLeading: !kIsWeb,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: Utils.linearGradient,
            ),
          ),
          backgroundColor: color,
          actions: [
            TextButton.icon(
              onPressed: () {
                getProps();
              },
              label: Text(
                "Reload",
                style: TextStyle(color: Colors.indigo),
                textAlign: TextAlign.right,
              ),
              icon: Icon(
                Icons.refresh_rounded,
                size: 18,
                color: Colors.indigo,
              ),
            )
          ],
          bottom: TabBar(
            labelColor: background1,
            indicatorColor: background1,
            tabs: <Widget>[
              Tab(
                text: 'Scene Wise',
              ),
              Tab(
                text: 'Property Wise',
              ),
            ],
          ),
          iconTheme: IconThemeData(color: background1),
          title: Text(
            "Properties",
            style: TextStyle(color: background1),
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            SingleChildScrollView(
                child: Column(
                    children: List<Widget>.generate(scenes.length, (i) {
              Scene scene = scenes[i];
              return ListTile(
                title: Text('${scene.titles['en']}'),
                subtitle: Text(
                    '${scene.props.length} ${scene.props.length == 1 ? "Prop" : "Props"}'),
                onTap: () {
                  Navigator.push(
                      context,
                      Utils.createRoute(
                          SelectedProps(
                              project: project,
                              selectedProps: List<Prop>.generate(
                                  scene.props.length,
                                  (p) => Utils.propsMap[scene.props[p]])),
                          Utils.DTU));
                },
              );
            }))),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List<Widget>.generate(props.length, (i) {
                  var prop = props[i];
                  return InkWell(
                    onTap: () async {
                      await Navigator.push(
                          context,
                          Utils.createRoute(
                              PropPage(
                                prop: prop,
                                project: project,
                              ),
                              Utils.DTU));
                      setState(() {
                        props = Utils.props.sublist(0);
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                              bottom:
                                  BorderSide(color: background1, width: 1))),
                      padding: EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: AspectRatio(
                              aspectRatio: 3 / 2,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: prop.referenceImage == ''
                                    ? Container(
                                        width: 50,
                                        height: 50 * (2 / 3),
                                        color: Colors.grey,
                                        child: Center(
                                            child: Text(
                                          'No Image',
                                          style: TextStyle(color: background),
                                        )),
                                      )
                                    : CachedNetworkImage(
                                        width: 50,
                                        height: 50 * (2 / 3),
                                        fit: BoxFit.cover,
                                        imageUrl: '${prop.referenceImage}',
                                      ),
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 2,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${prop.title}',
                                    style: propTitleStyle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${prop.usedIn.length} scenes',
                                    style: propDescriptionStyle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddProp(project: project)));
            setState(() {
              props = Utils.props.sublist(0);
            });
          },
          backgroundColor: color,
          child: Icon(
            Icons.add,
            color: background,
            size: 36,
          ),
        ),
      ),
    );
  }

  getProps() async {
    loading = true;
    Utils.showLoadingDialog(context, 'Getting Properties');
    props = await Utils.getProps(context, project.id);
    Navigator.pop(context);
    setState(() {
      loading = false;
    });
  }
}
