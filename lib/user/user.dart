import 'package:flutter/foundation.dart';

class User {
  String id, email, mobile, name, username;
  List<dynamic> projects;
  Map<dynamic, dynamic> notes, actsIn;

  User(
      {@required this.id,
      @required this.email,
      @required this.mobile,
      @required this.name,
      @required this.notes,
      @required this.actsIn,
      @required this.username,
      @required this.projects});

  factory User.fromJson(Map<dynamic, dynamic> i) {
    return User(
      id: i['id'],
      username: i['username'],
      name: i['name'],
      notes: i['notes'],
      actsIn: i['acts_in'],
      email: i['email'],
      mobile: i['mobile'],
      projects: i['projects'].values.toList(),
    );
  }
}
