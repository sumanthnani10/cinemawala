import 'package:flutter/foundation.dart';

class Schedule {
  String project, id, lastEditBy, addedBy;
  DateTime lastEditOn, created;
  int year, month, day;
  List<dynamic> scenes;

  Schedule(
      {@required this.project,
      @required this.id,
      @required this.lastEditBy,
      @required this.addedBy,
      @required this.created,
      @required this.lastEditOn,
      @required this.year,
      @required this.month,
      @required this.day,
      @required this.scenes});

  factory Schedule.fromJson(Map<dynamic, dynamic> i) {
    return Schedule(
      project: i['project_id'],
      id: i['id'],
      lastEditBy: i['last_edit_by'],
      addedBy: i['added_by'],
      created: DateTime.fromMillisecondsSinceEpoch(i['created']),
      lastEditOn: DateTime.fromMillisecondsSinceEpoch(i['last_edit_on']),
      day: i['day'],
      scenes: i['scenes'],
      month: i['month'],
      year: i['year'],
    );
  }

  Map<dynamic, dynamic> toJson() {
    return <dynamic, dynamic>{
      "day": this.day,
      "project_id": this.project,
      "scenes": this.scenes,
      "month": this.month,
      "added_by": this.addedBy,
      "id": this.id,
      "year": this.year,
      "last_edit_by": this.lastEditBy,
      "last_edit_on": this.lastEditOn.millisecondsSinceEpoch,
      "created": this.created.millisecondsSinceEpoch
    };
  }
}
