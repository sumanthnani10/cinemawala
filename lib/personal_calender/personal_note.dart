import 'package:flutter/foundation.dart';

class PersonalNotes {
  String id;
  int year, month, day;
  List<dynamic> notes;

  PersonalNotes(
      {@required this.id,
      @required this.year,
      @required this.month,
      @required this.day,
      @required this.notes});

  factory PersonalNotes.fromJson(Map<dynamic, dynamic> i) {
    return PersonalNotes(
      id: i['id'],
      day: i['day'],
      notes: i['notes'],
      month: i['month'],
      year: i['year'],
    );
  }

  Map<dynamic, dynamic> toJson() {
    return <dynamic, dynamic>{
      "day": this.day,
      "notes": this.notes,
      "month": this.month,
      "id": this.id,
      "year": this.year,
    };
  }
}
