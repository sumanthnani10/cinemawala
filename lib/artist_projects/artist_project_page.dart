import 'package:cinemawala/casting/actor.dart';
import 'package:cinemawala/costumes/costume.dart';
import 'package:cinemawala/projects/project.dart';
import 'package:cinemawala/scenes/scene.dart';
import 'package:cinemawala/schedule/schedule.dart';
import 'package:flutter/cupertino.dart';

import 'artist_project.dart';

class ArtistProjectPage extends StatefulWidget {
  final ArtistProject artistProject;

  const ArtistProjectPage({Key key, @required this.artistProject})
      : super(key: key);

  @override
  _ArtistProjectPageState createState() =>
      _ArtistProjectPageState(this.artistProject);
}

class _ArtistProjectPageState extends State<ArtistProjectPage>
    with SingleTickerProviderStateMixin {
  final ArtistProject artistProject;
  AnimationController _controller;
  Project project;
  Actor artist;
  List<Scene> scenes;
  List<Costume> costumes;
  List<Schedule> schedules;

  _ArtistProjectPageState(this.artistProject);

  @override
  void initState() {
    project = artistProject.project;
    artist = artistProject.artist;
    scenes = artistProject.scenes;
    costumes = artistProject.costumes;
    schedules = artistProject.schedules;
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(child: Text("SSSS")),
    );
  }
}
