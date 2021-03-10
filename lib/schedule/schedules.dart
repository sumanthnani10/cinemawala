import 'dart:core';

import 'package:cinemawala/projects/project.dart';
import 'package:cinemawala/schedule/schedule_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../utils.dart';
import 'schedule.dart';

class Schedules extends StatefulWidget {
  final Project project;

  const Schedules({Key key, this.project}) : super(key: key);

  @override
  _SchedulesState createState() => _SchedulesState(project);
}

class _SchedulesState extends State<Schedules>
    with SingleTickerProviderStateMixin {
  final Project project;

  _SchedulesState(this.project);

  Color background, background1, color;
  CalendarController calendarController;
  Map<String, Schedule> schedules = {};
  DateTime selectedDate;
  Map<DateTime, List<dynamic>> calenderSchedule = {};
  Schedule selectedSchedule;
  String selectedDateId;
  bool loading;
  ScrollController cardScrollController = new ScrollController();

  @override
  void initState() {
    final date = DateTime.now();
    selectedDate = date;
    loading = true;
    selectedDateId =
        "${date.year}${date.month > 9 ? date.month : "0${date.month}"}${date.day > 9 ? date.day : "0${date.day}"}";
    calendarController = new CalendarController();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getSchedules();
    });
    super.initState();
  }

  getSchedules() async {
    loading = true;
    Utils.showLoadingDialog(context, 'Getting Schedule');
    if (Utils.artists == null) {
      await Utils.getArtists(context, project.id);
    }
    if (Utils.costumes == null) {
      await Utils.getCostumes(context, project.id);
    }
    if (Utils.props == null) {
      await Utils.getProps(context, project.id);
    }
    if (Utils.locations == null) {
      await Utils.getLocations(context, project.id);
    }
    if (Utils.scenes == null) {
      await Utils.getScenes(context, project.id);
    }
    if (Utils.schedules == null) {
      await Utils.getSchedules(context, project.id);
    }
    schedules = Utils.schedulesMap ?? {};

    schedules.forEach((k, v) {
      calenderSchedule[DateTime(v.year, v.month, v.day)] = v.scenes;
    });
    selectedSchedule = schedules[selectedDateId];
    Navigator.pop(context);
    setState(() {
      loading = false;
    });
  }

  getAll() async {
    loading = true;
    Utils.showLoadingDialog(context, 'Getting Schedules');
    await Utils.getArtists(context, project.id);
    await Utils.getCostumes(context, project.id);
    await Utils.getProps(context, project.id);
    await Utils.getLocations(context, project.id);
    await Utils.getScenes(context, project.id);
    await Utils.getSchedules(context, project.id);
    schedules = Utils.schedulesMap ?? {};

    schedules.forEach((k, v) {
      calenderSchedule[DateTime(v.year, v.month, v.day)] = v.scenes;
    });
    selectedSchedule = schedules[selectedDateId];
    Navigator.pop(context);
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    background = Colors.white;
    color = Color(0xff6fd8a8);
    if (background == Colors.white) {
      background1 = Colors.black;
    } else {
      background1 = Colors.white;
    }
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: color,
        iconTheme: IconThemeData(color: background1),
        title: Text(
          "Schedule",
          style: TextStyle(color: background1),
        ),
        actions: [
          FlatButton.icon(
            onPressed: () async {
              getAll();
            },
            color: color,
            splashColor: background1.withOpacity(0.2),
            label: Text(
              "Reload",
              style: TextStyle(color: Colors.indigo),
              textAlign: TextAlign.right,
            ),
            icon: Icon(
              Icons.refresh_rounded,
              size: 16,
              color: Colors.indigo,
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          Container(
            child: TableCalendar(
              events: calenderSchedule,
              calendarController: calendarController,
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                selectedColor: color,
                todayColor: Colors.deepOrange[200],
                outsideDaysVisible: false,
              ),
              onDaySelected: (date, events, _) {
                selectedDateId =
                    "${date.year}${date.month > 9 ? date.month : "0${date.month}"}${date.day > 9 ? date.day : "0${date.day}"}";
                selectedSchedule = schedules[selectedDateId];
                selectedDate = date;
                setState(() {});
              },
              headerStyle: HeaderStyle(
                formatButtonTextStyle:
                    TextStyle().copyWith(color: Colors.white, fontSize: 15.0),
                formatButtonDecoration: BoxDecoration(
                  color: Colors.deepOrange[400],
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
            ),
          ),
          SizedBox.expand(
            child: DraggableScrollableSheet(
              initialChildSize: 310 / MediaQuery.of(context).size.height,
              minChildSize: 310 / MediaQuery.of(context).size.height,
              maxChildSize: 1,
              builder: (context, scrollController) {
                print(selectedSchedule == null
                    ? null
                    : selectedSchedule.toJson());
                return SchedulePage(
                    project: project,
                    schedule: selectedSchedule,
                    date: selectedDate,
                    id: selectedDateId);
              },
            ),
          )
        ],
      ),
    );
  }

  _showDialog() {
    var _textController = new TextEditingController();
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                controller: _textController,
              ),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      if (_textController.text.isEmpty) return;
                      setState(() {
                        if (calendarController.selectedDay != null) {
                          if (calenderSchedule[
                                  calendarController.selectedDay] ==
                              null) {
                            calenderSchedule[calendarController.selectedDay] =
                                [];
                          }
                          calenderSchedule[calendarController.selectedDay]
                              .add(_textController.text);
                        } else {
                          calenderSchedule[calendarController.selectedDay] = [
                            _textController.text
                          ];
                        }
                      });
                      Navigator.of(context).pop();
                    },
                    child: Text("Add"))
              ],
            ));
  }
}
