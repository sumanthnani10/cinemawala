import "package:flutter/cupertino.dart";

import "../utils.dart";

class Project {
  String id,
      name,
      ownerID,
      productionName,
      producer,
      director,
      dop,
      artDirector,
      image,
      addedBy,
      lastEditBy;
  int productionNumber;
  DateTime created, lastEditOn;
  List<dynamic> languages, rolesIDs;
  Map<String, dynamic> role, roles;

  Project(
      {@required this.id,
      @required this.name,
      @required this.languages,
      @required this.roles,
      @required this.rolesIDs,
      @required this.ownerID,
      @required this.role,
      @required this.productionName,
      @required this.productionNumber,
      @required this.producer,
      @required this.director,
      @required this.dop,
      @required this.artDirector,
      @required this.image,
      @required this.created,
      @required this.lastEditOn,
      @required this.lastEditBy,
      @required this.addedBy});

  Map<dynamic, dynamic> toJson() {
    return <dynamic, dynamic>{
      "id": id,
      "languages": languages,
      "name": name,
      "owner_id": ownerID,
      "roles": roles,
      "roles_ids": rolesIDs,
      "production_name": productionName,
      "production_number": productionNumber,
      "producer": producer,
      "director": director,
      "dop": dop,
      "art_director": artDirector,
      "image": image,
      "added_by": addedBy,
      "last_edit_by": lastEditBy,
      "last_edit_on": this.lastEditOn.millisecondsSinceEpoch,
      "created": this.created.millisecondsSinceEpoch
    };
  }

  factory Project.fromJson(Map<dynamic, dynamic> i) {
    return Project(
        id: i["id"],
        languages: i["languages"],
        name: i["name"],
        ownerID: i["owner_id"],
        roles: i["roles"],
        rolesIDs: i["roles_ids"],
        role: i["roles"]["${Utils.USER_ID}"],
        productionName: i["production_name"],
        productionNumber: i["production_number"],
        producer: i["producer"],
        director: i["director"],
        dop: i["dop"],
        artDirector: i["art_director"],
        image: i["image"],
        addedBy: i["added_by"],
        lastEditBy: i["last_edit_by"],
        created: DateTime.fromMillisecondsSinceEpoch(i["created"]),
        lastEditOn: DateTime.fromMillisecondsSinceEpoch(i["last_edit_on"]));
  }
}
