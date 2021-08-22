import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinemawala/costumes/costume.dart';
import 'package:cinemawala/costumes/costume_page.dart';
import 'package:cinemawala/projects/project.dart';
import 'package:cinemawala/scenes/scene.dart';
import 'package:cinemawala/scenes/select_costumes.dart';
import 'package:flutter/material.dart';

import '../utils.dart';
import 'add_costume.dart';

class CostumesList extends StatefulWidget {
  final Project project;

  CostumesList({Key key, @required this.project}) : super(key: key);

  @override
  _CostumesListState createState() => _CostumesListState(project);
}

class _CostumesListState extends State<CostumesList>
    with SingleTickerProviderStateMixin {
  final Project project;
  Color background, background1, color;
  List<Costume> costumes = [];

  List<Scene> scenes;

  var costumeTitleStyle = TextStyle(color: Colors.black);
  var costumeDescriptionStyle = TextStyle(fontSize: 14, color: Colors.black54);
  var usedByStyle = TextStyle(fontSize: 10, color: Colors.black54);
  bool loading = false;
  _CostumesListState(this.project);
  Widget sideWidget;
  @override
  void initState() {
    loading = true;
    costumes = Utils.costumes.sublist(0) ?? [];
    scenes = Utils.scenes ?? [];
    if (Utils.costumes == null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        getCostumes();
      });
    }
    super.initState();
  }

  getCostumes() async {
    loading = true;
    Utils.showLoadingDialog(context, 'Getting Costumes');
    costumes = await Utils.getCostumes(context, project.id);
    Navigator.pop(context);
    setState(() {
      loading = false;
    });
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
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          var maxWidth = constraints.maxWidth;
      return Row(
      children: [
        Flexible(
          flex: 6,
          child: DefaultTabController(
            length: 2,
            initialIndex: 1,
            child: Scaffold(
              backgroundColor: background,
              appBar: AppBar(
                flexibleSpace: Container(
                  decoration: maxWidth>Utils.mobileWidth ? BoxDecoration(
                    color: Colors.white,
                  ):BoxDecoration(
                    gradient: Utils.linearGradient,
                  ),
                ),
                backgroundColor: color,
                actions: [
                  TextButton.icon(
                    onPressed: () {
                      getCostumes();
                    },
                    label: Text(
                      "",
                        style: TextStyle(color: Colors.indigo),
                        textAlign: TextAlign.right,
                      ),
                    icon: Icon(
                      Icons.refresh_rounded,
                        size: 32,
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
                    Tab(text: 'Costume Wise',),
                  ],
                ),
                iconTheme: IconThemeData(color: background1),
                title: Text(
                  "Costumes",
                  style: TextStyle(color: background1),
                ),
              ),
              body: TabBarView(
                children: <Widget>[
                  SingleChildScrollView(
                      child: Column(
                          children: List<Widget>.generate(scenes.length, (i) {
                    Scene scene = scenes[i];
                    int count = 0;
                    scene.costumes.forEach((c) {
                      count += c['costumes'].length;
                    });
                    return ListTile(
                      title: Text('${scene.titles['en']}'),
                        subtitle: Text(
                          '$count ${count == 1 ? "Costume" : "Costumes"}',
                        ),
                        onTap: () async {
                          if (maxWidth > Utils.mobileWidth) {
                            setState(() {
                              sideWidget = SelectedCostumes(
                                key: UniqueKey(),
                                isPopUp: false,
                                project: project,
                                scene: scene,
                                costumes: scene.costumes,
                              );
                          });
                        }
                        else{
                          await Navigator.push(
                              context,
                              Utils.createRoute(
                                  SelectedCostumes(
                                    project: project,
                                      costumes: scene.costumes,
                                      scene: scene,
                                    ),
                                  Utils.DTU));
                          setState(() {
                            costumes = Utils.costumes.sublist(0);
                          });
                        }

                      },
                    );
                  }))),
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: List<Widget>.generate(costumes.length, (i) {
                        var costume = costumes[i];
                          print("${costume.id}: ${costume.referenceImage}");
                          return InkWell(
                            onTap: () async {
                              if (maxWidth > Utils.mobileWidth) {
                                setState(() {
                                  sideWidget = CostumesPage(
                                    project: project,
                                    costume: costume,
                                    key: UniqueKey(),
                                    isPopUp: false,
                                  );
                                });
                            }else{
                              await Navigator.push(
                                  context,
                                  Utils.createRoute(
                                      CostumesPage(
                                        project: project,
                                        costume: costume,
                                      ),
                                      Utils.DTU));
                              setState(() {
                                costumes = Utils.costumes.sublist(0);
                              });
                            }
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
                                      child: costume.referenceImage == ''
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
                                              progressIndicatorBuilder:
                                                  (context, url, progress) =>
                                                      LinearProgressIndicator(
                                                        value: progress.progress,
                                                      ),
                                              errorWidget: (context, url, error) =>
                                                  Center(
                                                      child: Text(
                                                    'Image',
                                                    style: const TextStyle(
                                                        color: Colors.grey),
                                                  )),
                                              useOldImageOnUrlChange: true,
                                              imageUrl: '${costume.referenceImage}'),
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
                                          '${costume.title}',
                                          style: costumeTitleStyle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '${costume.changed} ${costume.changed == 1 ? "scene" : "scenes"}',
                                          style: costumeDescriptionStyle,
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
                  if(project.role.permissions["casting"]["add"]||
                      project.role.permissions["scenes"]["add"]||
                      project.role.permissions["schedule"]["add"]){
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddCostume(
                              isPopUp: maxWidth>Utils.mobileWidth ? false : true,
                              project: project,
                            )));
                    setState(() {
                      costumes = Utils.costumes.sublist(0);
                    });
                  }else{
                    Utils.notAllowed(context);
                  }
                },
                backgroundColor:project.role.permissions["casting"]["add"]||
                    project.role.permissions["scenes"]["add"]||
                    project.role.permissions["schedule"]["add"] ?
                color : Utils.notPermitted,
                child: Icon(
                  Icons.add,
                  color: background,
                  size: 36,
                ),
              ),
            ),
          ),
        ),
        if(maxWidth>Utils.mobileWidth)
          Flexible(
            flex: 4,
            child: Scaffold(body: sideWidget ?? SizedBox.expand(child: Container(
              decoration: BoxDecoration(
                  border: Border(left: BorderSide(color: Colors.black))
              ),
              child: Center(child: Text("No Field Selected")),)),),
          )
      ],
    ); });
  }
}

/*
                    Container(
                      constraints: BoxConstraints(maxHeight: 300),
                      child: SingleChildScrollView(
                        child: Wrap(
                          alignment: WrapAlignment.start,
                          crossAxisAlignment: WrapCrossAlignment.start,
                          runAlignment: WrapAlignment.start,
                          children: <Widget>[
                                InkWell(
                                  onTap:(){},
                                  child: Container(
                                    constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width /
                                                4),
                                    margin: EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(color: background1.withOpacity(0.5),
                                      borderRadius:
                                      BorderRadius.circular(16)),
                                    child: Icon(Icons.add,color: background,size: MediaQuery.of(context).size.width/5,)
                                  ),
                                )
                              ] +
                              List<Widget>.generate(costumes.length, (j) {
                                return InkWell(
                                  child: Container(
                                    constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width /
                                                4),
                                    margin: EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        AspectRatio(
                                          aspectRatio: 4 / 3,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            child: CachedNetworkImage(
                                              fit: BoxFit.cover,
            progressIndicatorBuilder: (context, url, progress) => LinearProgressIndicator(value: progress.progress,),
          errorWidget: (context, url, error) => Center(child: Text('Image',style: const TextStyle(color: Colors.grey),)),
          useOldImageOnUrlChange: true,
          imageUrl:
                                                  "https://i.pinimg.com/474x/20/62/69/20626905851e066e66764c3385fa4352.jpg"),

                                          ),
                                        ),
                                        Flexible(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                4, 4, 4, 0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${costumes[i].title}',
                                                  style: costumeTitleStyle,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  '${costumes[i].usedBy}',
                                                  style: usedByStyle,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  onTap: () {
                                    /*Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Costumes()));*/
                                  },
                                );
                              }),
                        ),
                      ),
                    )*/
