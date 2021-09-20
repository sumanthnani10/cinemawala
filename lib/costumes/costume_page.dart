import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinemawala/artists/actor_page.dart';
import 'package:cinemawala/costumes/add_costume.dart';
import 'package:cinemawala/projects/project.dart';
import 'package:flutter/material.dart';

import '../utils.dart';
import 'costume.dart';

class CostumesPage extends StatefulWidget {
  final Costume costume;
  final Project project;
  final bool isPopUp;
  const CostumesPage({Key key, @required this.project, this.costume,this.isPopUp})
      : super(key: key);

  @override
  _CostumesPageState createState() => _CostumesPageState(project, costume,isPopUp);
}

class _CostumesPageState extends State<CostumesPage> {
  Color background, background1, color;
  bool isPopUp;
  Costume costume;
  final Project project;
  Set<String> artists = {};

  _CostumesPageState(this.project, this.costume,this.isPopUp);

  @override
  void initState() {
    isPopUp = isPopUp ?? true;
    super.initState();
    costume.usedBy.forEach((key, value) {
      artists.addAll(Iterable.castFrom(value));
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
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: isPopUp ? Colors.black26 : Colors.white,
        body: Container(
          decoration: isPopUp ? BoxDecoration() : BoxDecoration(
            border: Border(left: BorderSide(color: Colors.black))
          ),
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(8)),
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          AspectRatio(
                              aspectRatio: 4 / 3,
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: costume.referenceImage == ''
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
                                                        value:
                                                            progress.progress,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                          errorWidget: (context, url, error) =>
                                              Center(child: Text('Image')),
                                          useOldImageOnUrlChange: true,
                                          imageUrl: costume.referenceImage))),
                          Positioned(
                              top: 4,
                              right: 4,
                              child: CircleAvatar(
                                backgroundColor: project.role.permissions["casting"]["edit"]||
                                    project.role.permissions["scenes"]["edit"]||
                                    project.role.permissions["schedule"]["edit"] ?
                                color : Utils.notPermitted,
                                child: IconButton(
                                  onPressed: () async {
                                    if(project.role.permissions["costumes"]["edit"] ||
                                        project.role.permissions["schedule"]["edit"] ||
                                        project.role.permissions["scenes"]["edit"]
                                    ){
                                      await Navigator.push(
                                          context,
                                          Utils.createRoute(
                                              AddCostume(
                                                isPopUp: constraints.maxWidth>Utils.mobileWidth ? false : true,
                                                project: project,
                                                costume: costume.toJson(),
                                              ),
                                              Utils.RTL));
                                      setState(() {
                                        costume = Utils.costumesMap[costume.id];
                                      });
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
                                bottom: BorderSide(
                                    color: Colors.black26, width: 0.5))),
                        child: Text(
                          '${costume.title}',
                          style: TextStyle(
                              color: background1,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: Colors.black26, width: 0.5))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Description :',
                                style:
                                    TextStyle(color: background1, fontSize: 14),
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '${costume.description}',
                                style:
                                    TextStyle(color: background1, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: Colors.black26, width: 0.5))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Used By :',
                                style:
                                    TextStyle(color: background1, fontSize: 14),
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: artists.length < 1
                                  ? Text(
                                      'Not used yet',
                                      style: TextStyle(
                                          color: background1, fontSize: 12),
                                    )
                                  : Wrap(
                                      direction: Axis.horizontal,
                                      spacing: 4,
                                      children: List<Widget>.generate(
                                        artists.length,
                                        (i) {
                                          return InkWell(
                                            onLongPress: () async {
                                              await Navigator.push(
                                                  context,
                                                  Utils.createRoute(
                                                      ActorPage(
                                                        actor: Utils.artistsMap[
                                                            artists
                                                                .elementAt(i)],
                                                        project: project,
                                                        popUp: true,
                                                      ),
                                                      Utils.DTU));
                                              setState(() {});
                                            },
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
                                                  '${Utils.artistsMap[artists.elementAt(i)].names['en']}'),
                                            ),
                                          );
                                        },
                                      )),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: Colors.black26, width: 0.5))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Scenes :',
                                style:
                                    TextStyle(color: background1, fontSize: 14),
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: costume.scenes.length < 1
                                  ? Text(
                                      'No Scenes',
                                      style: TextStyle(
                                          color: background1, fontSize: 12),
                                    )
                                  : Wrap(
                                      direction: Axis.horizontal,
                                      spacing: 4,
                                      children: List<Widget>.generate(
                                        costume.scenes.length,
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
                                                  '${Utils.scenesMap[costume.scenes[i]].titles['en']}'),
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
      ),
    );});
  }
}
