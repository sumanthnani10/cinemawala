import 'package:flutter/cupertino.dart';

class Role {
  String project, userId, name, username, addedBy, lastEditBy, role;
  DateTime created, lastEditOn;
  bool owner, accepted;
  Map<dynamic, dynamic> permissions;

  Role(
      {@required this.project,
      @required this.userId,
      @required this.role,
      @required this.addedBy,
      @required this.name,
      @required this.username,
      @required this.owner,
      @required this.accepted,
      @required this.created,
      @required this.lastEditBy,
      @required this.lastEditOn,
      @required this.permissions});

  factory Role.fromJson(Map<dynamic, dynamic> i) {
    return Role(
        project: i['project_id'],
        userId: i['user_id'],
        name: i['name'],
        username: i['username'],
        addedBy: i['added_by'],
        owner: i['owner'],
        accepted: i['accepted'],
        created: DateTime.fromMillisecondsSinceEpoch(i['created'] ?? 0),
        lastEditBy: i['last_edit_by'],
        lastEditOn: DateTime.fromMillisecondsSinceEpoch(i['last_edit_on'] ?? 0),
        permissions: i['permissions'],
        role: i['role']);
  }

  Map<dynamic, dynamic> toJson() {
    return <dynamic, dynamic>{
      "added_by": this.addedBy,
      "name": this.name,
      "username": this.username,
      "project_id": this.project,
      "permissions": this.permissions,
      "user_id": this.userId,
      "role": this.role,
      "owner": this.owner,
      "accepted": this.accepted,
      "last_edit_by": this.lastEditBy,
      "last_edit_on": this.lastEditOn.millisecondsSinceEpoch,
      "created": this.created.millisecondsSinceEpoch
    };
  }
}
