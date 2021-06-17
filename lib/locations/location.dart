import 'package:flutter/material.dart';

class Location {
  String location, shootLocation, project, id, description, addedBy, lastEditBy;
  DateTime created, lastEditOn;
  List<dynamic> images, usedIn;

  Location(
      {@required this.location,
      @required this.shootLocation,
      @required this.images,
      @required this.usedIn,
      @required this.project,
      @required this.addedBy,
      @required this.lastEditBy,
      @required this.lastEditOn,
      @required this.created,
      @required this.description,
      @required this.id});

  factory Location.fromJson(Map<dynamic, dynamic> i) {
    return Location(
        location: i['location'],
        shootLocation: i['shoot_location'],
        project: i['project_id'],
        id: i['id'],
        images: i['images'],
        description: i['description'],
        usedIn: i['used_in'],
        addedBy: i['added_by'],
        lastEditBy: i['last_edit_by'],
        created: DateTime.fromMillisecondsSinceEpoch(i['created'] ?? 0),
        lastEditOn:
            DateTime.fromMillisecondsSinceEpoch(i['last_edit_on'] ?? 0));
  }

  Map<dynamic, dynamic> toJson() {
    Map<dynamic, dynamic> json = new Map<dynamic, dynamic>();
    json = {
      "added_by": this.addedBy,
      "location": this.location,
      "shoot_location": this.shootLocation,
      "used_in": this.usedIn,
      "project_id": this.project,
      "description": this.description,
      "images": this.images,
      "id": this.id,
      "last_edit_by": this.lastEditBy,
      "last_edit_on": this.lastEditOn.millisecondsSinceEpoch,
      "created": this.created.millisecondsSinceEpoch
    };
    return json;
  }
}
