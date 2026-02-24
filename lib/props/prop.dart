import 'package:flutter/cupertino.dart';

class Prop {
  String title, referenceImage, project, id, description, addedBy, lastEditBy;
  DateTime created, lastEditOn;
  List<dynamic> usedIn;

  Prop(
      {@required this.title,
      @required this.referenceImage,
      @required this.usedIn,
      @required this.project,
      @required this.id,
      @required this.description,
      @required this.created,
      @required this.lastEditOn,
      @required this.lastEditBy,
      @required this.addedBy});

  factory Prop.fromJson(Map<dynamic, dynamic> i) {
    return Prop(
        project: i['project_id'],
        id: i['id'],
        referenceImage: i['reference_image'],
        description: i['description'],
        usedIn: i['used_in'],
        title: i['title'],
        addedBy: i['added_by'],
        lastEditBy: i['last_edit_by'],
        created: DateTime.fromMillisecondsSinceEpoch(i['created'] ?? 0),
        lastEditOn:
            DateTime.fromMillisecondsSinceEpoch(i['last_edit_on'] ?? 0));
  }

  Map<dynamic, dynamic> toJson() {
    return <dynamic, dynamic>{
      "added_by": this.addedBy,
      "title": this.title,
      "used_in": this.usedIn,
      "project_id": this.project,
      "description": this.description,
      "reference_image": this.referenceImage,
      "id": this.id,
      "last_edit_by": this.lastEditBy,
      "last_edit_on": this.lastEditOn.millisecondsSinceEpoch,
      "created": this.created.millisecondsSinceEpoch
    };
  }
}
