import 'dart:core';

import 'package:cinemawala/projects/project.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../utils.dart';
import 'daily_budget.dart';
import 'daily_budget_page.dart';

class DailyBudgets extends StatefulWidget {
  final Project project;

  const DailyBudgets({Key key, this.project}) : super(key: key);

  @override
  _DailyBudgetsState createState() => _DailyBudgetsState(project);
}

class _DailyBudgetsState extends State<DailyBudgets>
    with SingleTickerProviderStateMixin {
  final Project project;

  _DailyBudgetsState(this.project);

  Color background, background1, color;
  CalendarController calendarController;
  Map<String, dynamic> dailyBudgets = {};
  DateTime selectedDate;
  Map<DateTime, List<dynamic>> calenderDailyBudget = {};
  DailyBudget selectedDailyBudget;
  String selectedDateId;
  bool loading;
  ScrollController cardScrollController = new ScrollController();

  @override
  void initState() {
    final date = DateTime.now();
    dailyBudgets = Utils.dailyBudgetsMap;
    // print(dailyBudgets);
    selectedDate = date;
    loading = true;
    selectedDateId =
        "${date.year}${date.month > 9 ? date.month : "0${date.month}"}${date.day > 9 ? date.day : "0${date.day}"}";
    selectedDailyBudget = dailyBudgets[selectedDateId];

    dailyBudgets.forEach((k, v) {
      // print(k);
      calenderDailyBudget[DateTime(v.year, v.month, v.day)] = [1];
    });

    calendarController = new CalendarController();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // getDailyBudgets();
    });
    super.initState();
  }

  getDailyBudgets() async {
    loading = true;
    Utils.showLoadingDialog(context, 'Getting Daily Budgets');
    if (Utils.dailyBudgets == null) {
      await Utils.getDailyBudgets(context, project.id);
    }
    dailyBudgets = Utils.dailyBudgetsMap ?? {};

    selectedDailyBudget = dailyBudgets[selectedDateId];
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
          "DailyBudget",
          style: TextStyle(color: background1),
        ),
        actions: [
          TextButton.icon(
            onPressed: () async {
              getDailyBudgets();
            },
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
              events: calenderDailyBudget,
              calendarController: calendarController,
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                selectedColor: color,
                highlightToday: false,
                outsideDaysVisible: false,
              ),
              onDaySelected: (date, events, _) {
                selectedDateId =
                    "${date.year}${date.month > 9 ? date.month : "0${date.month}"}${date.day > 9 ? date.day : "0${date.day}"}";
                selectedDailyBudget = dailyBudgets[selectedDateId];
                selectedDate = date;
                setState(() {});
              },
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
              ),
            ),
          ),
          SizedBox.expand(
              child: DailyBudgetPage(
                project: project,
            dailyBudget: selectedDailyBudget,
            date: selectedDate,
            id: selectedDateId,
            getDailyBudgets: () {
              getDailyBudgets();
            },
            budget:
                selectedDailyBudget != null ? selectedDailyBudget.budget : {},
            nextDate: () async {
              selectedDate = selectedDate.add(Duration(days: 1));
              selectedDateId =
                  "${selectedDate.year}${selectedDate.month > 9 ? selectedDate.month : "0${selectedDate.month}"}${selectedDate.day > 9 ? selectedDate.day : "0${selectedDate.day}"}";
              selectedDailyBudget = dailyBudgets[selectedDateId];
              calendarController.setSelectedDay(selectedDate);
              setState(() {});
            },
            prevDate: () async {
              selectedDate = selectedDate.subtract(Duration(days: 1));
              selectedDateId =
                  "${selectedDate.year}${selectedDate.month > 9 ? selectedDate.month : "0${selectedDate.month}"}${selectedDate.day > 9 ? selectedDate.day : "0${selectedDate.day}"}";
              selectedDailyBudget = dailyBudgets[selectedDateId];
              calendarController.setSelectedDay(selectedDate);
              setState(() {});
            },
            key: UniqueKey(),
          ))
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
                TextButton(
                    onPressed: () {
                      if (_textController.text.isEmpty) return;
                      setState(() {
                        if (calendarController.selectedDay != null) {
                          if (calenderDailyBudget[
                                  calendarController.selectedDay] ==
                              null) {
                            calenderDailyBudget[
                                calendarController.selectedDay] = [];
                          }
                          calenderDailyBudget[calendarController.selectedDay]
                              .add(_textController.text);
                        } else {
                          calenderDailyBudget[calendarController.selectedDay] =
                              [_textController.text];
                        }
                      });
                      Navigator.of(context).pop();
                    },
                    child: Text("Add"))
              ],
            ));
  }
}
