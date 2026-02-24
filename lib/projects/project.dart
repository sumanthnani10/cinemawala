import 'package:cinemawala/roles/role.dart';
import "package:flutter/cupertino.dart";

import "../utils.dart";

class Project {
  String id,
      name,
      ownerID,
      ownerUsername,
      ownerName,
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
  List<dynamic> languages, rolesIDs, schedules, artistIDs;
  Map<dynamic, dynamic> roles, artists;
  Role role;

  Project(
      {@required this.id,
      @required this.name,
      @required this.languages,
      @required this.roles,
      @required this.rolesIDs,
      @required this.artists,
      @required this.artistIDs,
      @required this.schedules,
      @required this.ownerID,
      @required this.ownerUsername,
      @required this.ownerName,
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
      "owner_username": ownerUsername,
      "owner_name": ownerName,
      "roles": roles,
      "roles_ids": rolesIDs,
      "artists": artists,
      "artist_ids": artistIDs,
      "schedules": schedules,
      "production_name": productionName,
      "production_number": productionNumber,
      "producer": producer,
      "director": director,
      "dop": dop,
      "art_director": artDirector,
      "image": image == Utils.ImagePlaceholderLink ? "" : image,
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
        ownerUsername: i["owner_username"],
        ownerName: i["owner_name"],
        roles: i["roles"],
        rolesIDs: i["roles_ids"],
        artists: i["artists"],
        artistIDs: i["artist_ids"],
        schedules: i["schedules"],
        role: i["roles"] != null
            ? Role.fromJson(i["roles"]["${Utils.USER_ID}"])
            : null,
        productionName: i["production_name"],
        productionNumber: i["production_number"],
        producer: i["producer"],
        director: i["director"],
        dop: i["dop"],
        artDirector: i["art_director"],
        image: i["image"] == "" ? Utils.ImagePlaceholderLink : i["image"],
        addedBy: i["added_by"],
        lastEditBy: i["last_edit_by"],
        created: DateTime.fromMillisecondsSinceEpoch(i["created"]),
        lastEditOn: DateTime.fromMillisecondsSinceEpoch(i["last_edit_on"]));
  }
}
