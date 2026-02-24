import 'package:flutter/foundation.dart';

class Scene {
  String project,
      id,
      addedBy,
      lastEditBy,
      makeUp,
      specialEquipment,
      location,
      choreographer,
      fighter,
      sfx,
      vfx;
  DateTime created, lastEditOn;
  Map<dynamic, dynamic> titles, gists, addlArtists;
  bool completed;
  int interior, day;
  List<dynamic> artists, costumes, props, completedOn;

  Scene(
      {@required this.project,
      @required this.id,
      @required this.addedBy,
      @required this.lastEditBy,
      @required this.makeUp,
      @required this.sfx,
      @required this.vfx,
      @required this.specialEquipment,
      @required this.created,
      @required this.lastEditOn,
      @required this.titles,
      @required this.gists,
      @required this.location,
      @required this.choreographer,
      @required this.fighter,
      @required this.addlArtists,
      @required this.day,
      @required this.interior,
      @required this.artists,
      @required this.costumes,
      @required this.completed,
      @required this.completedOn,
      @required this.props});

  factory Scene.fromJson(Map<dynamic, dynamic> i) {
    return Scene(
        project: i['project_id'],
        id: i['id'],
      makeUp: i['make_up'],
      specialEquipment: i['special_equipment'],
      titles: i['titles'],
      gists: i['gists'],
      location: i['location'],
      addlArtists: i['addl_artists'],
      day: i['day'],
      interior: i['interior'],
      artists: i['artists'],
      costumes: i['costumes'],
      choreographer: i['choreographer'],
      fighter: i['fighter'],
      props: i['props'],
      sfx: i['sfx'],
      vfx: i['vfx'],
      completed: i['completed'],
      completedOn: i['completed_on'],
      addedBy: i['added_by'],
      lastEditBy: i['last_edit_by'],
      created: DateTime.fromMillisecondsSinceEpoch(i['created'] ?? 0),
      lastEditOn: DateTime.fromMillisecondsSinceEpoch(i['last_edit_on'] ?? 0),
    );
  }

  Map<dynamic, dynamic> toJson() {
    return <dynamic, dynamic>{
      "titles": this.titles,
      "costumes": this.costumes,
      "day": this.day,
      "project_id": this.project,
      "props": this.props,
      "artists": this.artists,
      "id": this.id,
      "gists": this.gists,
      "location": this.location,
      "interior": this.interior,
      "addl_artists": this.addlArtists,
      "special_equipment": this.specialEquipment,
      "make_up": this.makeUp,
      "sfx": this.sfx,
      "vfx": this.vfx,
      "completed": this.completed,
      "completed_on": this.completedOn,
      "choreographer": this.choreographer,
      "fighter": this.fighter,
      "added_by": this.addedBy,
      "last_edit_by": this.lastEditBy,
      "last_edit_on": this.lastEditOn.millisecondsSinceEpoch,
      "created": this.created.millisecondsSinceEpoch
    };
  }
}
