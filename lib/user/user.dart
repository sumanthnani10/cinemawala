import 'package:flutter/foundation.dart';

class User {
  final String id, email, mobile, name, username;
  final List<dynamic> projects;

  User(
      {@required this.id,
      @required this.email,
      @required this.mobile,
      @required this.name,
      @required this.username,
      @required this.projects});

  factory User.fromJson(Map<dynamic, dynamic> i) {
    return User(
      id: i['id'],
      username: i['username'],
      name: i['name'],
      email: i['email'],
      mobile: i['mobile'],
      projects: i['projects'].values.toList(),
    );
  }
}
