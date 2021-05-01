import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinemawala/casting/actor_page.dart';
import 'package:cinemawala/projects/project.dart';
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

  _ActorsListState({@required this.project});

  @override
  void initState() {
    loading = true;
    artists = Utils.artists.sublist(0) ?? [];
    if (Utils.artists == null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        getArtists();
      });
    }
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
  }
}
