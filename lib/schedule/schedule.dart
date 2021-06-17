import 'package:flutter/foundation.dart';

class Schedule {
  String project, id, lastEditBy, addedBy, name;
  DateTime lastEditOn, created;
  int year, month, day;
  List<dynamic> scenes;
  Map<dynamic, dynamic> artistTimings,
      additionalTimings,
      callSheetTimings,
      vfxTimings,
      sfxTimings;

  Schedule({
    @required this.project,
    @required this.id,
    @required this.lastEditBy,
    @required this.addedBy,
    @required this.created,
    @required this.lastEditOn,
    @required this.year,
    @required this.month,
    @required this.day,
    @required this.scenes,
    @required this.artistTimings,
    @required this.additionalTimings,
    @required this.callSheetTimings,
    @required this.vfxTimings,
    @required this.sfxTimings,
    @required this.name,
  });

  factory Schedule.fromJson(Map<dynamic, dynamic> i) {
    return Schedule(
      project: i['project_id'],
      id: i['id'],
      name: i['name'],
      lastEditBy: i['last_edit_by'],
      addedBy: i['added_by'],
      artistTimings: i['artist_timings'],
      additionalTimings: i['addl_timings'],
      callSheetTimings: i['call_timings'],
      sfxTimings: i['sfx_timings'],
      vfxTimings: i['vfx_timings'],
      created: DateTime.fromMillisecondsSinceEpoch(i['created'] ?? 0),
      lastEditOn: DateTime.fromMillisecondsSinceEpoch(i['last_edit_on'] ?? 0),
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
      "name": this.name,
      "year": this.year,
      "artist_timings": this.artistTimings,
      "addl_timings": this.additionalTimings,
      "call_timings": this.callSheetTimings,
      "sfx_timings": this.sfxTimings,
      "vfx_timings": this.vfxTimings,
      "last_edit_by": this.lastEditBy,
      "last_edit_on": this.lastEditOn.millisecondsSinceEpoch,
      "created": this.created.millisecondsSinceEpoch
    };
  }
}
