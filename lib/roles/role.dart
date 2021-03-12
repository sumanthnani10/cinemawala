import 'package:flutter/cupertino.dart';

class Role {
  String project, userId, name, addedBy, lastEditBy, role;
  DateTime created, lastEditOn;
  Map<String, dynamic> permissions;

  Role(
      {@required this.project,
      @required this.userId,
      @required this.role,
      @required this.addedBy,
      @required this.name,
      @required this.created,
      @required this.lastEditBy,
      @required this.lastEditOn,
      @required this.permissions});

  factory Role.fromJson(Map<dynamic, dynamic> i) {
    return Role(
        project: i['project'],
        userId: i['user_id'],
        name: i['name'],
        addedBy: i['added_by'],
        created: DateTime.fromMillisecondsSinceEpoch(i['created']),
        lastEditBy: i['last_edit_by'],
        lastEditOn: DateTime.fromMillisecondsSinceEpoch(i['last_edit_on']),
        permissions: i['permissions'],
        role: i['role']);
  }

  Map<dynamic, dynamic> toJson() {
    return <dynamic, dynamic>{
      "added_by": this.addedBy,
      "name": this.name,
      "project": this.project,
      "permissions": this.permissions,
      "user_id": this.userId,
      "role": this.role,
      "last_edit_by": this.lastEditBy,
      "last_edit_on": this.lastEditOn.millisecondsSinceEpoch,
      "created": this.created.millisecondsSinceEpoch
    };
  }
}
