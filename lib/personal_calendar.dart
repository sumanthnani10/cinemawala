import 'package:cinemawala/projects/project.dart';
import 'package:cinemawala/projects/project_card.dart';
import 'package:cinemawala/projects/project_home.dart';
import 'package:cinemawala/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:table_calendar/table_calendar.dart';

class PersonalCalendar extends StatefulWidget {
  PersonalCalendar({Key key}) : super(key: key);
  @override
  _PersonalCalendar createState() => _PersonalCalendar();
}
class _PersonalCalendar extends State<PersonalCalendar> {
  CalendarController calendarController;
  Color background, color, background1;
  TextEditingController eventController;
  Map<DateTime,List<String>> _events;
  Widget prevWorks;
  @override
  void initState() {
    calendarController = CalendarController();
    eventController = TextEditingController();
    _events = {};
    prevWorks = Container(child: Text("No Notes"),);
    super.initState();
  }
  Widget asignPrev(){
    setState(() {
      prevWorks = _events[calendarController.selectedDay].length==0 ? Container(child: Text("No Notes"),) : Wrap(
        spacing: 4,
        runSpacing: 2,
        children: List.generate(_events[calendarController.selectedDay].length, (i){
          return Container(
            padding: EdgeInsets.symmetric(vertical: 2,horizontal: 4),
            decoration: BoxDecoration(
              color: const Color(0xff6fd8a8),
              borderRadius: BorderRadius.all(Radius.circular(300)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("${_events[calendarController.selectedDay][i]} "),
                InkWell(
                    onTap: (){
                      setState(() {
                        _events[calendarController.selectedDay].removeAt(i);
                        asignPrev();
                      });
                    },
                    child: Icon(Icons.delete_forever,size: 16,))
              ],
            ),
          );
        }),
      );
    });
  }
  Widget widget1(){
    return Container(
      child: TableCalendar(
        events: _events,
        calendarController: calendarController,
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarStyle: CalendarStyle(
          selectedColor: color,
          highlightToday: false,
          outsideDaysVisible: false,
        ),
        onDaySelected: (date, events, _) {
          if(_events[calendarController.selectedDay]==null){
            setState(() {eventController.clear();
            prevWorks = Container(child: Text("No Notes"),);
            });
          }else{
            setState(() {
              print(_events[calendarController.selectedDay].length);
              /*prevWorks = _events[calendarController.selectedDay].length==0 ? Container(child: Text("No Projects"),) : Wrap(
                spacing: 4,
                runSpacing: 2,
                children: List.generate(_events[calendarController.selectedDay].length, (i){
                  return Container(
                    padding: EdgeInsets.symmetric(vertical: 2,horizontal: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xff6fd8a8),
                      borderRadius: BorderRadius.all(Radius.circular(300)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("${_events[calendarController.selectedDay][i]} "),
                        InkWell(
                            onTap: (){
                              setState(() {
                                _events[calendarController.selectedDay].removeAt(i);
                                asignPrev();
                              });
                            },
                            child: Icon(Icons.remove_circle_outline,color: Colors.red,size: 14,))
                      ],
                    ),
                  );
                }),
              );*/
              asignPrev();
            });
            print(_events[calendarController.selectedDay]);
          }

        },
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
        ),
      ),
    );
  }
  Widget widgetTop(){
    return Align(
        alignment: Alignment.topCenter,
        child: widget1());
  }
  Widget widgetBottom(){
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: EdgeInsets.only(top: 24,bottom: 24),
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
        child: Column(
          children: [
            prevWorks,
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 36,right: 36,top: 18,bottom: 12),
                  child: TextField(
                    controller: eventController,
                    maxLines: 1,
                    decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.black)),
                        labelStyle: TextStyle(color: Colors.black),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 8),
                        labelText: 'Note',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.black)),
                        fillColor: Colors.white),
                  ),
                ),
                InkWell(
                  onTap: (){
                    if(eventController.text.isEmpty) return;
                    setState(() {
                      if(_events[calendarController.selectedDay]==null){
                        _events[calendarController.selectedDay] = [];
                      }
                      _events[calendarController.selectedDay].add(eventController.text);
                      eventController.clear();
                      asignPrev();
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 56,vertical: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Text(
                      'Save',
                      style: TextStyle(
                          color: background1,
                          fontWeight: FontWeight.w800,
                          fontSize: 16),
                    ),
                  ),
                ),
              ],
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
        automaticallyImplyLeading: false,
        title: Text(
          "Personal Calendar",
          style: TextStyle(color: background1),
        ),
        actions: [
          TextButton.icon(
            onPressed: () async {
              //save _events map into database
              Navigator.pop(context);
            },
            label: Text(
              "Save",
              style: TextStyle(color: Colors.indigo),
              textAlign: TextAlign.right,
            ),
            icon: Icon(
              Icons.save,
              size: 18,
              color: Colors.indigo,
            ),
          )
        ],
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
        if(constraints.maxWidth>Utils.mobileWidth){
          return Row(
            mainAxisSize: MainAxisSize.min,
            children:[
              Flexible(
                  flex: 5,
                  child: widgetTop()),
              Flexible(flex: 5, child: widgetBottom()),
            ],);
        }else{
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:[
              widgetTop(),
              widgetBottom(),
            ],);
        }
          }),
    );
  }
}
