import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinemawala/casting/actor_page.dart';
import 'package:cinemawala/projects/project.dart';
import 'package:cinemawala/projects/select_languages.dart';
import 'package:cinemawala/scenes/scene.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils.dart';
import 'actor.dart';
import 'add_actor.dart';

class ActorsList extends StatefulWidget {
  final Project project;

  ActorsList({Key key, @required this.project}) : super(key: key);

  @override
  _ActorsListState createState() => _ActorsListState(project: project);
}

class _ActorsListState extends State<ActorsList>
    with SingleTickerProviderStateMixin {
  final Project project;
  Color background, background1, color;
  List<String> languages;
  ScrollController cardScrollController = new ScrollController();
  List<Actor> artists = [];
  bool loading = false;
  List<Scene> scenes = [];
  Widget sideWidget;
  _ActorsListState({@required this.project});

  @override
  void initState() {
    loading = true;
    artists = Utils.artists.sublist(0) ?? [];
    scenes = [];
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getScenes();
    });
    if (Utils.artists == null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        getArtists();
      });
    }
    print(artists);
    super.initState();
  }

  getArtists() async {
    loading = true;
    Utils.showLoadingDialog(context, 'Getting Artists');
    artists = await Utils.getArtists(context, project.id);
    Navigator.pop(context);
    setState(() {
      loading = false;
    });
  }

  getScenes() async {
    print("getscenes");
    loading = true;
    Utils.showLoadingDialog(context, 'Getting Scenes');
    if (Utils.artists == null) {
      await Utils.getArtists(context, project.id);
    }
    if (Utils.scenes == null) {
      scenes = await Utils.getScenes(context, project.id);
    } else {
      scenes = Utils.scenes ?? [];
    }
    print(scenes);
    Navigator.pop(context);
    setState(() {
      loading = false;
    });
  }
  Widget imagesInCircles(List images, double radius, int max, double textSize) {
    return Stack(
      children: List<Widget>.generate(images.length > max ? max : images.length,
              (i) {
            return Padding(
              padding: EdgeInsets.only(left: i.toDouble() * (radius * 6 / 4)),
              child: CircleAvatar(
                radius: radius,
                backgroundColor: Colors.white,
                child: images[i] == ''
                    ? Container(
                  width: (radius - 1) * 2,
                  height: (radius - 1) * 2,
                  color: background,
                )
                    : CachedNetworkImage(
                    width: (radius - 1) * 2,
                    height: (radius - 1) * 2,
                    imageBuilder: (context, imageProvider) => Container(
                      width: (radius - 1) * 2,
                      height: (radius - 1) * 2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: imageProvider, fit: BoxFit.cover),
                      ),
                    ),
                    fit: BoxFit.cover,
                    progressIndicatorBuilder: (context, url, progress) =>
                        LinearProgressIndicator(
                          value: progress.progress,
                        ),
                    errorWidget: (context, url, error) => Center(
                        child: Text(
                          'Image',
                          style: const TextStyle(color: Colors.grey),
                        )),
                    useOldImageOnUrlChange: true,
                    imageUrl: images[i]),
              ),
            );
          }) +
          [
            Padding(
              padding: EdgeInsets.only(
                  left: (((images.length > max ? max : images.length) *
                      (radius * 6 / 4)) +
                      radius / 2),
                  top: radius / 4),
              child: Text(
                '${images.length > max ? '+${images.length - max} more' : ''}',
                style: TextStyle(fontSize: textSize),
              ),
            ),
          ],
    );
  }
  @override
  Widget build(BuildContext context) {
    // print(Utils.artistsMap);
    // print(Utils.artists);
    background = Colors.white;
    color = Color(0xff6fd8a8);
    if (background == Colors.white) {
      background1 = Colors.black;
    } else {
      background1 = Colors.white;
    }
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !kIsWeb,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: Utils.linearGradient,
          ),
        ),
        backgroundColor: Color(0xff6fd8a8),
        title: Text(
          'Casting',
          style: TextStyle(color: background1),
        ),
        iconTheme: IconThemeData(color: background1),
        actions: [
          TextButton.icon(
            onPressed: () {
              getArtists();
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
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
        child: SingleChildScrollView(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.start,
            alignment: WrapAlignment.spaceAround,
            runAlignment: WrapAlignment.start,
            children: List<Widget>.generate(artists.length, (i) {
              i = 1;
              return InkWell(
                onTap: () async {
                  await Navigator.push(
                      context,
                      Utils.createRoute(
                          ActorPage(
                            actor: artists[i],
                            project: project,
                          ),
                          Utils.DTU));
                  setState(() {
                    artists = Utils.artists.sublist(0);
                  });
                },
                child: Container(
                  width: 110,
                  constraints: BoxConstraints(maxWidth: 110),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      artists[i].image == ''
                          ? CircleAvatar(
                              backgroundColor: Colors.grey,
                              radius: 50,
                              child: Text(
                                'No Image',
                                style:
                                    TextStyle(color: background, fontSize: 12),
                              ),
                            )
                          : CachedNetworkImage(
                              width: 100,
                              height: 100,
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                              fit: BoxFit.cover,
                              progressIndicatorBuilder:
                                  (context, url, progress) =>
                                      LinearProgressIndicator(
                                        value: progress.progress,
                                      ),
                              errorWidget: (context, url, error) => Center(
                                      child: Text(
                                    'Image',
                                    style: const TextStyle(color: Colors.grey),
                                  )),
                              useOldImageOnUrlChange: true,
                              imageUrl: artists[i].image),
                      SizedBox(
                        height: 4,
                      ),
                      FittedBox(
                        child: Text('${artists[i].names['en']}',
                            maxLines: 2,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis),
                      ),
                      FittedBox(
                        child: Text(
                          '${artists[i].characters['en']}',
                          maxLines: 1,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.black45),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
              context,
              Utils.createRoute(
                  AddActor(
                    project: project,
                  ),
                  Utils.DTU));
          setState(() {
            artists = Utils.artists.sublist(0);
          });
        },
        backgroundColor: Color(0xff6fd8a8),
        child: Icon(
          Icons.add,
          color: background,
          size: 36,
        ),
      ),
    );
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
              appBar: AppBar(
                flexibleSpace: Container(
                  decoration: maxWidth>Utils.mobileWidth ?
                      BoxDecoration(color: Colors.white)
                      : BoxDecoration(
                    gradient: Utils.linearGradient,
                  ),
                ),
                backgroundColor: Color(0xff6fd8a8),
                title: Text(
                  'Casting',
                  style: TextStyle(color: background1),
                ),
                iconTheme: IconThemeData(color: background1),
                actions: [
                  TextButton.icon(
                    onPressed: () {
                      getArtists();
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
                      text: 'Artist Wise',
                    ),
                  ],
                ),
              ),
              body:
                  TabBarView(
                    children:<Widget>[
                    SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    physics: BouncingScrollPhysics(),
                    child: Container(
                      child: Column(
                          children: List.generate(scenes.length, (i){
                            print("${i},${scenes[i]}");
                            Scene scene = scenes[i];
                            print(scene.artists.length);
                            return InkWell(
                              onTap: () async{
                                if(maxWidth>Utils.mobileWidth){
                                  setState(() {
                                    sideWidget = SelectedActors(
                                      project: project,
                                      key: UniqueKey(),
                                      isPopUp: maxWidth>Utils.mobileWidth ? false : true,
                                      selectedArtists:
                                      List<Actor>.generate(
                                          scene.artists.length,
                                              (a) => Utils.artistsMap[
                                          scene.artists[a]]),
                                    );
                                  });
                                }else{
                                  Navigator.push(
                                      context,
                                      Utils.createRoute(
                                          SelectedActors(
                                            project: project,
                                            selectedArtists:
                                            List<Actor>.generate(
                                                scene.artists.length,
                                                    (a) => Utils.artistsMap[
                                                scene.artists[a]]),
                                          ),
                                          Utils.DTU));
                                }
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(width: 2, color: Colors.black26),
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical:4,horizontal: 4),
                                      child: Text(
                                        '${scene.titles['en']}',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical:4,horizontal: 4),
                                      child: Container(
                                          padding: EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: color,
                                            borderRadius:
                                            BorderRadius.circular(300),
                                          ),
                                          child: imagesInCircles(
                                              List<String>.generate(
                                                  scene.artists.length,
                                                      (index) {
                                                    String r = Utils
                                                        .artistsMap[
                                                    '${scene.artists[index]}']
                                                        .image;
                                                    return r;
                                                  }),
                                              10,
                                              3,
                                              10)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 4),
                                      child: Text(
                                        "Artists",
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          })
                      ),
                    ),
                  ),
                   GridView.count(
                  crossAxisCount: maxWidth>Utils.mobileWidth ? 4 : 3,
                  childAspectRatio: 0.7,
                  children: List<Widget>.generate(artists.length, (i) {
                    return InkWell(
                      onTap: () async {
                        if(maxWidth>Utils.mobileWidth){
                          setState(() {
                            sideWidget =
                                    ActorPage(
                                      actor: artists[i],
                                      isPopUp: maxWidth>Utils.mobileWidth? false : true,
                                      project: project,
                                    );
                            artists = Utils.artists.sublist(0);
                          });
                        }
                        else{
                          await Navigator.push(
                              context,
                              Utils.createRoute(
                                  ActorPage(
                                    actor: artists[i],
                                    project: project,
                                  ),
                                  Utils.DTU));
                          setState(() {
                            artists = Utils.artists.sublist(0);
                          });
                        }
                      },
                      child: Container(
                        width: 50,
                        margin: EdgeInsets.only(top: 10),
                        child: Column(
                          children: [
                            artists[i].image == ''
                                ? CircleAvatar(
                              backgroundColor: Colors.grey,
                              radius: 50,
                              child: Text(
                                'No Image',
                                style: TextStyle(color: background, fontSize: 12),
                              ),
                            )
                                : CachedNetworkImage(
                                width: 100,
                                height: 100,
                                imageBuilder: (context, imageProvider) => Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: imageProvider, fit: BoxFit.cover),
                                  ),
                                ),
                                fit: BoxFit.cover,
                                progressIndicatorBuilder: (context, url, progress) =>
                                    LinearProgressIndicator(
                                      value: progress.progress,
                                    ),
                                errorWidget: (context, url, error) => Center(
                                    child: Text(
                                      'Image',
                                      style: const TextStyle(color: Colors.grey),
                                    )),
                                useOldImageOnUrlChange: true,
                                imageUrl: artists[i].image),
                            SizedBox(
                              height: 4,
                            ),
                            Text('${artists[i].names['en']}',
                                maxLines: 2,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis),
                            Text(
                              '${artists[i].characters['en']}',
                              maxLines: 1,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.black45),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
                    ]),
              floatingActionButton: FloatingActionButton(
                onPressed: () async {
                  await Navigator.push(
                      context,
                      Utils.createRoute(
                          AddActor(
                            project: project,
                            isPopUp: maxWidth>Utils.mobileWidth ? false : true,
                          ),
                          Utils.DTU));
                  setState(() {
                    artists = Utils.artists.sublist(0);
                  });
                },
                backgroundColor: Color(0xff6fd8a8),
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
