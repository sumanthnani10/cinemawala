import 'package:flutter/cupertino.dart';

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
}
