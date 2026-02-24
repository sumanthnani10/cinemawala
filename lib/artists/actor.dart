import 'package:flutter/cupertino.dart';

class Actor {
  String image, project, id, addedBy, lastEditBy;
  DateTime created, lastEditOn;
  int days;
  Map<dynamic, dynamic> names, characters, costumes, by;
  List<dynamic> scenes;

  Actor(
      {@required this.image,
      @required this.names,
      @required this.characters,
      @required this.project,
      @required this.id,
      @required this.addedBy,a
      @required this.by,
      @required this.created,
      @required this.days,
      @required this.lastEditBy,
      @required this.lastEditOn,
      @required this.costumes,
      @required this.scenes});

  factory Actor.fromJson(Map<dynamic, dynamic> i) {
    return Actor(
        project: i['project_id'],
        id: i['id'],
        image: i['image'],
        characters: i['characters'],
        names: i['names'],
        addedBy: i['added_by'],
        by: i['by'],
        created: DateTime.fromMillisecondsSinceEpoch(i['created'] ?? 0),
        days: i['days'],
        lastEditBy: i['last_edit_by'],
        lastEditOn: DateTime.fromMillisecondsSinceEpoch(i['last_edit_on'] ?? 0),
        scenes: i['scenes'],
        costumes: i['costumes']);
  }

  Map<dynamic, dynamic> toJson() {
    return <dynamic, dynamic>{
      "added_by": this.addedBy,
      "names": this.names,
      "costumes": this.costumes,
      "days": this.days,
      "project_id": this.project,
      "scenes": this.scenes,
      "image": this.image,
      "id": this.id,
      "characters": this.characters,
      "by": this.by,
      "last_edit_by": this.lastEditBy,
      "last_edit_on": this.lastEditOn.millisecondsSinceEpoch,
      "created": this.created.millisecondsSinceEpoch
    };
  }
}