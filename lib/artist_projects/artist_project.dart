import 'package:cinemawala/artists/actor.dart';
import 'package:cinemawala/costumes/costume.dart';
import 'package:cinemawala/locations/location.dart';
import 'package:cinemawala/projects/project.dart';
import 'package:cinemawala/scenes/scene.dart';
import 'package:cinemawala/schedule/schedule.dart';
import 'package:flutter/foundation.dart';

class ArtistProject {
  final Project project;
  final Actor artist;
  final List<Scene> scenes;
  final List<Costume> costumes;
  final List<Schedule> schedules;
  final List<Location> locations;

  ArtistProject(
      {@required this.project,
      @required this.artist,
      @required this.scenes,
      @required this.costumes,
      @required this.locations,
      @required this.schedules});

  Map<dynamic, dynamic> toJson() {
    return <dynamic, dynamic>{
      "project": this.project,
      "artist": this.artist,
      "scenes": this.scenes,
      "costumes": this.costumes,
      "locations": this.locations,
      "schedules": this.schedules,
    };
  }

  factory ArtistProject.fromJson(Map<dynamic, dynamic> i) {
    return ArtistProject(
      project: Project.fromJson(i["project"]),
      artist: Actor.fromJson(i["actor"]),
      scenes: List<Scene>.generate(
          i["scenes"].length, (ind) => Scene.fromJson(i["scenes"][ind])),
      costumes: List<Costume>.generate(
          i["costumes"].length, (ind) => Costume.fromJson(i["costumes"][ind])),
      locations: List<Location>.generate(i["locations"].length,
          (ind) => Location.fromJson(i["locations"][ind])),
      schedules: List<Schedule>.generate(i["schedules"].length,
          (ind) => Schedule.fromJson(i["schedules"][ind])),
    );
  }
}
