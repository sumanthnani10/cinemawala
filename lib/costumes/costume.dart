import 'package:flutter/cupertino.dart';

class Costume {
  String title, referenceImage, project, id, description, addedBy, lastEditBy;
  DateTime created, lastEditOn;
  Map<dynamic, dynamic> usedBy;
  List<dynamic> scenes;
  int changed;

  Costume(
      {@required this.title,
      @required this.referenceImage,
      @required this.usedBy,
      @required this.changed,
      @required this.scenes,
      @required this.project,
      @required this.id,
      @required this.description,
      @required this.lastEditOn,
      @required this.lastEditBy,
      @required this.created,
      @required this.addedBy});

  factory Costume.fromJson(Map<dynamic, dynamic> i) {
    return Costume(
        project: i['project_id'],
        id: i['id'],
        referenceImage: i['reference_image'],
        description: i['description'],
        usedBy: i['used_by'],
        title: i['title'],
        scenes: i['scenes'],
        addedBy: i['added_by'],
        created: DateTime.fromMillisecondsSinceEpoch(i['created'] ?? 0),
        changed: i['changed'],
        lastEditBy: i['last_edit_by'],
        lastEditOn:
            DateTime.fromMillisecondsSinceEpoch(i['last_edit_on'] ?? 0));
  }

  Map<dynamic, dynamic> toJson() {
    return <dynamic, dynamic>{
      "added_by": this.addedBy,
      "title": this.title,
      "used_by": this.usedBy,
      "project_id": this.project,
      "scenes": this.scenes,
      "changed": this.changed,
      "description": this.description,
      "reference_image": this.referenceImage,
      "id": this.id,
      "last_edit_by": this.lastEditBy,
      "last_edit_on": this.lastEditOn.millisecondsSinceEpoch,
      "created": this.created.millisecondsSinceEpoch
    };
  }

/*String usedByString(){
    String s = '';
    for(String t in usedBy){
      s+=t;
      s+=', ';
    }
    return s.substring(0,s.length-2);
  }

  String scenesString(){
    String s = '';
    for(String t in scenes){
      s+=t;
      s+=', ';
    }
    return s.substring(0,s.length-2);
  }*/

}
