import 'dart:convert';

import 'package:cinemawala/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';

import 'personal_note.dart';

class PersonalCalendar extends StatefulWidget {
  PersonalCalendar({Key key}) : super(key: key);

  @override
  _PersonalCalendar createState() => _PersonalCalendar();
}

class _PersonalCalendar extends State<PersonalCalendar> {
  CalendarController calendarController;
  List<String> weeksDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  Color background, color, background1;
  Map<dynamic, PersonalNotes> notes = {};
  Map<DateTime, List<dynamic>> calendarNotes = {};
  TextEditingController eventController;
  PersonalNotes selectedNote;
  String selectedDateId;
  DateTime selectedDate;
  bool loading;

  @override
  void initState() {
    final date = DateTime.now();
    selectedDate = date;
    loading = true;
    selectedDateId =
        "${date.year}${date.month > 9 ? date.month : "0${date.month}"}${date.day > 9 ? date.day : "0${date.day}"}";
    selectedNote = notes[selectedDateId];
    calendarController = new CalendarController();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setNotes();
    });
    super.initState();
  }

  setNotes() async {
    notes = {};

    Utils.user.notes.forEach((k, v) {
      notes[k] = PersonalNotes.fromJson(v);
      calendarNotes[DateTime(v['year'], v['month'], v['day'])] = v['notes'];
    });
    selectedNote = notes[selectedDateId];

    setState(() {});
  }

  Widget widgetTop() {
    return Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Container(
            child: TableCalendar(
              events: calendarNotes,
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
                selectedNote = notes[selectedDateId];
                selectedDate = date;
                setState(() {});
              },
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
              ),
            ),
          ),
        ));
  }

  Widget widgetBottom(scrollController, height) {
    return Container(
      padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
      height: height,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16), topRight: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff6fd8a8),
              offset: Offset(0, -0.5),
              blurRadius: 4,
            ),
          ]),
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (OverscrollIndicatorNotification overscroll) {
          overscroll.disallowGlow();
          return;
        },
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  Container(
                    color: background,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: Icon(CupertinoIcons.back),
                          onPressed: () {},
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          "${selectedDate.day > 9 ? selectedDate.day : "0${selectedDate.day}"}-${selectedDate.month > 9 ? selectedDate.month : "0${selectedDate.month}"}-${selectedDate.year}, ${weeksDays[selectedDate.weekday - 1]}",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Spacer(),
                        TextButton(onPressed: () {}, child: Text("+Add")),
                        IconButton(
                          icon: Icon(CupertinoIcons.forward),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    thickness: 2,
                  ),
                  if (selectedNote == null)
                    Container(
                      child: Text("No Notes"),
                    ),
                  if (selectedNote != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: List<Widget>.generate(selectedNote.notes.length,
                              (i) {
                            return Container(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: background,
                                border: Border(bottom: BorderSide()),
                              ),
                              alignment: Alignment.topLeft,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                      child: Text(
                                    "${selectedNote.notes[i]}",
                                    maxLines: null,
                                    textAlign: TextAlign.start,
                                  )),
                                  IconButton(
                                      icon: Icon(
                                        Icons.close,
                                        color: Colors.deepOrange,
                                        size: 18,
                                      ),
                                      onPressed: () async {
                                        await removeNote(
                                            "${selectedNote.notes[i]}");
                                        setState(() {
                                          setNotes();
                                        });
                                      })
                                ],
                              ),
                            );
                          }) +
                          <Widget>[
                            if (selectedNote.notes.length == 0)
                              Center(
                                child: Text("No Notes"),
                              )
                          ],
                    ),
                ],
              ),
            ),
            SingleChildScrollView(
              controller: scrollController,
              child: Container(
                color: background,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(CupertinoIcons.back),
                      onPressed: () {
                        selectedDate = selectedDate.subtract(Duration(days: 1));
                        selectedDateId =
                            "${selectedDate.year}${selectedDate.month > 9 ? selectedDate.month : "0${selectedDate.month}"}${selectedDate.day > 9 ? selectedDate.day : "0${selectedDate.day}"}";
                        selectedNote = notes[selectedDateId];
                        calendarController.setSelectedDay(selectedDate);
                        setState(() {});
                      },
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      "${selectedDate.day > 9 ? selectedDate.day : "0${selectedDate.day}"}-${selectedDate.month > 9 ? selectedDate.month : "0${selectedDate.month}"}-${selectedDate.year}, ${weeksDays[selectedDate.weekday - 1]}",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                    TextButton(
                        onPressed: () async {
                          await askNewNote("");
                          setState(() {
                            setNotes();
                          });
                        },
                        child: Text("+Add")),
                    IconButton(
                      icon: Icon(CupertinoIcons.forward),
                      onPressed: () {
                        selectedDate = selectedDate.add(Duration(days: 1));
                        selectedDateId =
                            "${selectedDate.year}${selectedDate.month > 9 ? selectedDate.month : "0${selectedDate.month}"}${selectedDate.day > 9 ? selectedDate.day : "0${selectedDate.day}"}";
                        selectedNote = notes[selectedDateId];
                        calendarController.setSelectedDay(selectedDate);
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    color = Color(0xff6fd8a8);
    background = Colors.white;
    if (background == Colors.white) {
      background1 = Colors.black;
    } else {
      background1 = Colors.white;
    }
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: Utils.linearGradient,
          ),
        ),
        backgroundColor: color,
        iconTheme: IconThemeData(color: background1),
        automaticallyImplyLeading: true,
        title: Text(
          "Personal Calendar",
          style: TextStyle(color: background1, fontSize: 16),
        ),
        actions: [
          TextButton.icon(
            onPressed: () async {
              Utils.showLoadingDialog(context, "Loading");
              await Utils.getUser(context, Utils.user.id);
              setNotes();
              Navigator.pop(context);
            },
            label: Text(
              "",
              style: TextStyle(color: Colors.indigo),
              textAlign: TextAlign.right,
            ),
            icon: Icon(
              Icons.refresh_rounded,
              size: 32,
              color: background1,
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth > Utils.mobileWidth) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(flex: 5, child: widgetTop()),
              Flexible(
                  flex: 5,
                  child: widgetBottom(
                      new ScrollController(), constraints.maxHeight)),
            ],
          );
        } else {
          return Stack(
            children: [
              widgetTop(),
              SizedBox.expand(
                  child: DraggableScrollableSheet(
                initialChildSize: 250 / MediaQuery.of(context).size.height,
                minChildSize: 250 / MediaQuery.of(context).size.height,
                maxChildSize: 1,
                builder: (context, scrollController) {
                  return widgetBottom(scrollController, constraints.maxHeight);
                },
              )),
            ],
          );
        }
      }),
    );
  }

  askNewNote(String note) async {
    TextEditingController noteController =
        new TextEditingController(text: note);
    GlobalKey<FormState> formKey = new GlobalKey<FormState>();
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("New Note"),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: TextFormField(
                controller: noteController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.newline,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.black)),
                    labelStyle: TextStyle(color: Colors.black),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    labelText: 'Note',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.black)),
                    fillColor: Colors.white),
                maxLines: null,
                validator: (v) {
                  if (v.length == 0) {
                    return 'Please enter note';
                  } else {
                    return null;
                  }
                },
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop([false, note]);
              },
            ),
            TextButton(
              child: Text("Add"),
              onPressed: () async {
                if (formKey.currentState.validate()) {
                  return await addNewNote(noteController.text);
                }
              },
            ),
          ],
        );
      },
    );
  }

  addNewNote(String note) async {
    Utils.showLoadingDialog(context, 'Noting');

    try {
      var resp = await http.post(Utils.ADD_NOTE,
          body: jsonEncode({
            "user_id": Utils.user.id,
            "note": {
              "day": selectedDate.day,
              "notes": note,
              "month": selectedDate.month,
              "id": selectedDateId,
              "year": selectedDate.year
            }
          }),
          headers: {"Content-Type": "application/json"});
      var r = jsonDecode(resp.body);
      if (resp.statusCode == 200) {
        if (r['status'] == 'success') {
          if (Utils.user.notes[selectedDateId] == null) {
            Utils.user.notes[selectedDateId] = {
              "day": selectedDate.day,
              "notes": [note],
              "month": selectedDate.month,
              "id": selectedDateId,
              "year": selectedDate.year
            };
          } else if (!Utils.user.notes[selectedDateId]['notes']
              .contains(note)) {
            Utils.user.notes[selectedDateId]['notes'].add(note);
          }
          Navigator.pop(context);
        } else {
          Navigator.pop(context);
          await Utils.showErrorDialog(context, 'Unsuccessful', '${r['msg']}');
        }
      } else {
        Navigator.pop(context);
        await Utils.showErrorDialog(context, 'Something went wrong.',
            'Please try again after sometime.');
      }
    } catch (e) {
      debugPrint("$e");
      Navigator.pop(context);
      await Utils.showErrorDialog(
          context, 'Something went wrong.', 'Please try again after sometime.');
    }
    Navigator.pop(context);
  }

  removeNote(String note) async {
    Utils.showLoadingDialog(context, 'Removing');

    try {
      var resp = await http.post(Utils.REMOVE_NOTE,
          body: jsonEncode({
            "user_id": Utils.user.id,
            "note": {
              "day": selectedDate.day,
              "notes": note,
              "month": selectedDate.month,
              "id": selectedDateId,
              "year": selectedDate.year
            }
          }),
          headers: {"Content-Type": "application/json"});
      var r = jsonDecode(resp.body);
      Navigator.pop(context);
      if (resp.statusCode == 200) {
        if (r['status'] == 'success') {
          Utils.user.notes[selectedDateId]['notes'].remove(note);
        } else {
          await Utils.showErrorDialog(context, 'Unsuccessful', '${r['msg']}');
        }
      } else {
        await Utils.showErrorDialog(context, 'Something went wrong.',
            'Please try again after sometime.');
      }
    } catch (e) {
      debugPrint("$e");
      Navigator.pop(context);
      await Utils.showErrorDialog(
          context, 'Something went wrong.', 'Please try again after sometime.');
    }
    // Navigator.pop(context);
  }
}
