import 'package:flutter/foundation.dart';

class Scene {
  String project, id, addedBy, lastEditBy, makeUp, specialEquipment, location;
  DateTime created, lastEditOn;
  Map<String, dynamic> titles, gists, addlArtists;
  bool day, interior;
  List<dynamic> artists, costumes, props;

  Scene(
      {@required this.project,
      @required this.id,
      @required this.addedBy,
      @required this.lastEditBy,
      @required this.makeUp,
      @required this.specialEquipment,
      @required this.created,
      @required this.lastEditOn,
      @required this.titles,
      @required this.gists,
      @required this.location,
      @required this.addlArtists,
      @required this.day,
      @required this.interior,
      @required this.artists,
      @required this.costumes,
      @required this.props});

  factory Scene.fromJson(Map<dynamic, dynamic> i) {
    return Scene(
        project: i['project_id'],
        id: i['id'],
        addedBy: i['added_by'],
        lastEditBy: i['last_edit_by'],
        makeUp: i['make_up'],
        specialEquipment: i['special_equipment'],
        created: DateTime.fromMillisecondsSinceEpoch(i['created']),
        lastEditOn: DateTime.fromMillisecondsSinceEpoch(i['last_edit_on']),
        titles: i['titles'],
        gists: i['gists'],
        location: i['location'],
        addlArtists: i['addl_artists'],
        day: i['day'],
        interior: i['interior'],
        artists: i['artists'],
        costumes: i['costumes'],
        props: i['props']);
  }

  Map<dynamic, dynamic> toJson() {
    return <dynamic, dynamic>{
      "added_by": this.addedBy,
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
      "last_edit_by": this.lastEditBy,
      "last_edit_on": this.lastEditOn.millisecondsSinceEpoch,
      "created": this.created.millisecondsSinceEpoch
    };
  }
}
