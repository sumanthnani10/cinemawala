import 'package:flutter/cupertino.dart';

import '../utils.dart';

class Project {
  String id, name, ownerID;
  List<dynamic> languages, rolesIDs;
  Map<String, dynamic> role, roles;

  Project(
      {@required this.id,
      @required this.name,
      @required this.languages,
      @required this.roles,
      @required this.rolesIDs,
      @required this.ownerID,
      @required this.role});

  factory Project.fromJson(Map<dynamic, dynamic> i) {
    return Project(
        id: i['id'],
        languages: i['languages'],
        name: i['name'],
        ownerID: i['owner_id'],
        roles: i['roles'],
        rolesIDs: i['roles_ids'],
        role: i['roles']['${Utils.USER_ID}']);
  }
}
