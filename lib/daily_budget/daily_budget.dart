import 'package:flutter/foundation.dart';

class DailyBudget {
  String project, id, lastEditBy, addedBy;
  DateTime lastEditOn, created;
  int year, month, day;
  Map<String, dynamic> budget;

  DailyBudget(
      {@required this.project,
      @required this.id,
      @required this.lastEditBy,
      @required this.addedBy,
      @required this.created,
      @required this.lastEditOn,
      @required this.year,
      @required this.month,
      @required this.day,
      @required this.budget});

  factory DailyBudget.fromJson(Map<dynamic, dynamic> i) {
    return DailyBudget(
      project: i['project_id'],
      id: i['id'],
      lastEditBy: i['last_edit_by'],
      addedBy: i['added_by'],
      budget: i['budget'],
      created: DateTime.fromMillisecondsSinceEpoch(i['created']),
      lastEditOn: DateTime.fromMillisecondsSinceEpoch(i['last_edit_on']),
      day: i['day'],
      month: i['month'],
      year: i['year'],
    );
  }

  Map<dynamic, dynamic> toJson() {
    return <dynamic, dynamic>{
      "day": this.day,
      "project_id": this.project,
      "month": this.month,
      "added_by": this.addedBy,
      "id": this.id,
      "year": this.year,
      "budget": this.budget,
      "last_edit_by": this.lastEditBy,
      "last_edit_on": this.lastEditOn.millisecondsSinceEpoch,
      "created": this.created.millisecondsSinceEpoch
    };
  }
}