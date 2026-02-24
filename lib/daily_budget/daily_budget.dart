import 'package:flutter/foundation.dart';

class DailyBudget {
  String project, id, lastEditBy, addedBy;
  DateTime lastEditOn, created;
  int year, month, day;
  Map<dynamic, dynamic> budget, scenesBudget;

  DailyBudget({@required this.project,
    @required this.id,
    @required this.lastEditBy,
    @required this.addedBy,
    @required this.created,
    @required this.lastEditOn,
    @required this.year,
    @required this.month,
    @required this.day,
    @required this.budget,
    @required this.scenesBudget,
  });

  factory DailyBudget.fromJson(Map<dynamic, dynamic> i) {
    return DailyBudget(
      project: i['project_id'],
      id: i['id'],
      lastEditBy: i['last_edit_by'],
      addedBy: i['added_by'],
      budget: i['budget'],
      scenesBudget: i['scenes_budget'],
      created: DateTime.fromMillisecondsSinceEpoch(i['created'] ?? 0),
      lastEditOn: DateTime.fromMillisecondsSinceEpoch(i['last_edit_on'] ?? 0),
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
      "scenes_budget": this.scenesBudget,
      "last_edit_by": this.lastEditBy,
      "last_edit_on": this.lastEditOn.millisecondsSinceEpoch,
      "created": this.created.millisecondsSinceEpoch
    };
  }
}