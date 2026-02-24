import 'dart:async';
import 'dart:math';

import 'package:cinemawala/daily_budget/add_daily_budget.dart';
import 'package:cinemawala/daily_budget/daily_budget.dart';
import 'package:cinemawala/pdf_generator.dart';
import 'package:cinemawala/projects/project.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils.dart';

class DailyBudgetPage extends StatefulWidget {
  final Project project;
  final DailyBudget dailyBudget;
  final DateTime date;
  final Map budget;
  final Map scenesBudget;
  final String id;
  final ScrollController scrollController;
  final VoidCallback nextDate, prevDate, getDailyBudgets;
  final bool isPopUp;

  DailyBudgetPage({
    Key key,
    @required this.project,
    @required this.budget,
    @required this.scenesBudget,
    @required this.dailyBudget,
    @required this.date,
    @required this.id,
    @required this.getDailyBudgets,
    @required this.nextDate,
    @required this.prevDate,
    this.isPopUp,
    @required this.scrollController,
  }) : super(key: key);

  @override
  _DailyBudgetPage createState() => _DailyBudgetPage(
    this.project,
    this.budget,
    this.scenesBudget,
    this.dailyBudget,
    this.date,
    this.id,
    this.getDailyBudgets,
    this.nextDate,
    this.prevDate,
    this.isPopUp,
    this.scrollController,
      );
}

class _DailyBudgetPage extends State<DailyBudgetPage>
    with SingleTickerProviderStateMixin {
  final Project project;
  DailyBudget dailyBudget;
  DateTime date;
  Map budget;
  Map scenesBudget;
  bool isPopUp;
  String id;
  ScrollController scrollController;
  VoidCallback nextDate, prevDate, getDailyBudgets;

  _DailyBudgetPage(this.project,
      this.budget,
      this.scenesBudget,
      this.dailyBudget,
      this.date,
      this.id,
      this.getDailyBudgets,
      this.nextDate,
      this.prevDate,
      this.isPopUp,
      this.scrollController);

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Color background, background1, color;
  var categoryHeading = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
  var subheading = TextStyle(fontSize: 18);

  List<dynamic> categories, subCategories, sceneKeys;

  List<TextEditingController> contactControllers,
      quantityControllers,
      rateControllers,
      callSheetControllers;

  var pickedDate, startTime, endTime;
  int viewCats = 3;
  List<String> weeksDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  var dialogActionHeading = TextStyle(color: Colors.indigo, fontSize: 16);
  TimeOfDay _timeOfDay = TimeOfDay.now();
  List<String> callSheetType = ["Daily Report","Daily Program"];

  @override
  void initState() {
    isPopUp = isPopUp ?? true;
    // print(isPopUp);
    super.initState();
  }

  Future<String> createAlertDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Select Call Sheet"),
            content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(callSheetType.length, (i) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    child: TextButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        //Utils.showLoadingDialog(context, "Generating PDF");
                        await PdfGenerator.dailyReportCallSheet(dailyBudget,callSheetType[i]);
                        //Navigator.of(context).pop();
                        },
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text("${callSheetType[i]}"),
                      ),
                    ),
                  );
                })),
          );
        });
  }

  String reFormatKey(String s) {
    s = s.replaceAll("_", " ");
    s = s.toLowerCase();
    var l = s.split(" ");
    String r = "";
    l.forEach((f) {
      if (f.length > 0) {
        r += (f.substring(0, 1).toUpperCase());
        r += (f.substring(1));
        r += " ";
      }
    });
    return r;
  }

  String formatKey(String s) {
    s = s.replaceAll(" ", "_");
    s = s.toLowerCase();
    return s;
  }

  @override
  Widget build(BuildContext context) {
    contactControllers = [];
    quantityControllers = [];
    callSheetControllers = [];
    rateControllers = [];
    categories = budget.keys.toList();
    sceneKeys = scenesBudget.keys.toList();
    background = Colors.white;
    color = Color(0xff6fd8a8);
    if (background == Colors.white) {
      background1 = Colors.black;
    } else {
      background1 = Colors.white;
    }
    return Container(
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
      child: dailyBudget != null
          ? NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (OverscrollIndicatorNotification overscroll) {
                overscroll.disallowGlow();
                Timer(Duration(milliseconds: 100), () {
                  viewCats += 3;
                  setState(() {});
                });
                return;
              },
              child: Stack(
                children: [
                  Scrollbar(
                    thickness: 2,
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: Icon(CupertinoIcons.back),
                                      onPressed: () {},
                                    ),
                                    Text(
                                      "${date.day > 9 ? date.day : "0${date.day}"}-${date.month > 9 ? date.month : "0${date.month}"}-${date.year}, ${weeksDays[date.weekday - 1]}",
                                      style: TextStyle(fontSize: 18),
                                    ),
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
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Budget",
                                      style: categoryHeading,
                                    ),
                                    TextButton.icon(
                                      onPressed: () async {
                                        //Utils.showLoadingDialog(
                                          //  context, "Generating");
                                        createAlertDialog(context);
                                        //Navigator.pop(context);
                                      },
                                      label: Text("Generate PDF"),
                                      icon: Icon(Icons.picture_as_pdf_outlined),
                                    ),
                                    TextButton.icon(
                                      onPressed: () async {
                                        await Navigator.push(
                                            context,
                                            Utils.createRoute(
                                                AddDailyBudget(
                                                  project: project,
                                                  dailyBudget:
                                                      dailyBudget.toJson(),
                                                  edit: true,
                                                ),
                                                Utils.RTL));
                                        getDailyBudgets();
                                      },
                                      label: Text("Edit"),
                                      icon: Icon(Icons.edit, size: 16),
                                    )
                                  ],
                                ),
                              )
                            ] +
                            List<Widget>.generate(scenesBudget.length, (i) {
                              subCategories =
                                  scenesBudget[sceneKeys[i]].keys.toList();
                              return Column(
                                children: [
                                  Divider(
                                    thickness: 1,
                                    color: background1,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            "${Utils.scenesMap[sceneKeys[i]]
                                                .titles['en']}",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: categoryHeading,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16),
                                    child: Wrap(
                                        children: List<Widget>.generate(
                                            subCategories.length, (j) {
                                          var subcategory = scenesBudget[sceneKeys[i]]
                                          [subCategories[j]];

                                      contactControllers.add(
                                          new TextEditingController(
                                              text:
                                                  "${subcategory["contact"] != "" ? subcategory["contact"] : "-"}"));
                                      quantityControllers.add(
                                          new TextEditingController(
                                              text:
                                                  "${subcategory["quantity"] != "" ? subcategory["quantity"] : "-"}"));
                                      rateControllers.add(new TextEditingController(
                                          text:
                                              "${subcategory["rate"] != "" ? subcategory["rate"] : "-"}"));
                                      callSheetControllers.add(
                                          new TextEditingController(
                                              text:
                                                  "${subcategory["callSheet"] != "" ? subcategory["callSheet"] : "-"}"));
                                      // print("ispopup ${isPopUp}");
                                      return Container(
                                        constraints:
                                            BoxConstraints(maxWidth: 480),
                                        decoration: BoxDecoration(
                                            border: Border(
                                                top: BorderSide(
                                                    color: j != 0
                                                        ? background1
                                                        : background,
                                                    width: 1))),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Transform.scale(
                                                  scale: 1.1,
                                                  child: Checkbox(
                                                      value: budget[
                                                              categories[i]][
                                                          budget[categories[i]]
                                                              .keys
                                                              .elementAt(
                                                                  j)]["use"],
                                                      activeColor: color,
                                                      onChanged: (value) {}),
                                                ),
                                                Flexible(
                                                  child: Text(
                                                    "${reFormatKey(subCategories[j])}",
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: subheading,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    child: TextField(
                                                      controller:
                                                          contactControllers
                                                              .last,
                                                      keyboardType:
                                                          TextInputType.text,
                                                      decoration:
                                                          InputDecoration(
                                                        enabled: false,
                                                        disabledBorder:
                                                            OutlineInputBorder(
                                                                borderSide:
                                                                    BorderSide(
                                                                        color:
                                                                            background)),
                                                        labelText: 'Name and Contact',
                                                        labelStyle: TextStyle(
                                                            color: background1,
                                                            fontSize: 14),
                                                        contentPadding:
                                                            EdgeInsets.all(8),
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            4,
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    child: TextField(
                                                      onChanged: (value) {},
                                                      controller:
                                                          callSheetControllers
                                                              .last,
                                                      keyboardType:
                                                          TextInputType.number,
                                                      decoration:
                                                          InputDecoration(
                                                        enabled: false,
                                                        disabledBorder:
                                                            OutlineInputBorder(
                                                                borderSide:
                                                                    BorderSide(
                                                                        color:
                                                                            background)),
                                                        labelText: 'Call Sheet',
                                                        labelStyle: TextStyle(
                                                            color: background1,
                                                            fontSize: 14),
                                                        contentPadding:
                                                            EdgeInsets.all(8),
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Flexible(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      "Subtotal: ${budget[categories[i]][budget[categories[i]].keys.elementAt(j)]["subtotal"]}",
                                                      style: subheading,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 4,
                                                        vertical: 8),
                                                    child: TextField(
                                                      controller:
                                                          quantityControllers
                                                              .last,
                                                      keyboardType:
                                                          TextInputType.number,
                                                      decoration:
                                                          InputDecoration(
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                                borderSide:
                                                                    BorderSide(
                                                                        color:
                                                                            background)),
                                                        labelText: 'Quantity',
                                                        labelStyle: TextStyle(
                                                            color: background1,
                                                            fontSize: 14),
                                                        contentPadding:
                                                            EdgeInsets.all(8),
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Flexible(
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 4,
                                                        vertical: 8),
                                                    child: TextField(
                                                      controller:
                                                          rateControllers.last,
                                                      keyboardType:
                                                          TextInputType.number,
                                                      decoration:
                                                          InputDecoration(
                                                        enabled: false,
                                                        disabledBorder:
                                                            OutlineInputBorder(
                                                                borderSide:
                                                                    BorderSide(
                                                                        color:
                                                                            background)),
                                                        labelText: 'Rate',
                                                        labelStyle: TextStyle(
                                                            color: background1,
                                                            fontSize: 14),
                                                        contentPadding:
                                                            EdgeInsets.all(8),
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                        })),
                                  ),
                                ],
                              );
                            }) +
                            List<Widget>.generate(
                                min<int>(viewCats, budget.length), (i) {
                              subCategories =
                                  budget[categories[i]].keys.toList();
                              return Column(
                                children: [
                                  Divider(
                                    thickness: 1,
                                    color: background1,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            "${reFormatKey(categories[i])}",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: categoryHeading,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    EdgeInsets.symmetric(horizontal: 16),
                                    child: Wrap(
                                        children: List<Widget>.generate(
                                            subCategories.length, (j) {
                                          var subcategory = budget[categories[i]]
                                          [subCategories[j]];

                                          contactControllers.add(
                                              new TextEditingController(
                                                  text:
                                                  "${subcategory["contact"] !=
                                                      ""
                                                      ? subcategory["contact"]
                                                      : "-"}"));
                                          quantityControllers.add(
                                              new TextEditingController(
                                                  text:
                                                  "${subcategory["quantity"] !=
                                                      ""
                                                      ? subcategory["quantity"]
                                                      : "-"}"));
                                          rateControllers.add(
                                              new TextEditingController(
                                                  text:
                                                  "${subcategory["rate"] != ""
                                                      ? subcategory["rate"]
                                                      : "-"}"));
                                          callSheetControllers.add(
                                              new TextEditingController(
                                                  text:
                                                  "${subcategory["callSheet"] !=
                                                      ""
                                                      ? subcategory["callSheet"]
                                                      : "-"}"));
                                          // print("ispopup ${isPopUp}");
                                          return Container(
                                            constraints:
                                            BoxConstraints(maxWidth: 480),
                                            decoration: BoxDecoration(
                                                border: Border(
                                                    top: BorderSide(
                                                        color: j != 0
                                                            ? background1
                                                            : background,
                                                        width: 1))),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                                  children: [
                                                    Transform.scale(
                                                      scale: 1.1,
                                                      child: Checkbox(
                                                          value: budget[
                                                          categories[i]][
                                                          budget[categories[i]]
                                                              .keys
                                                              .elementAt(
                                                              j)]["use"],
                                                          activeColor: color,
                                                          onChanged: (
                                                              value) {}),
                                                    ),
                                                    Flexible(
                                                      child: Text(
                                                        "${reFormatKey(
                                                            subCategories[j])}",
                                                        maxLines: 1,
                                                        overflow:
                                                        TextOverflow.ellipsis,
                                                        style: subheading,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Flexible(
                                                      child: Padding(
                                                        padding:
                                                        const EdgeInsets.all(4),
                                                        child: TextField(
                                                          controller:
                                                          contactControllers
                                                              .last,
                                                          keyboardType:
                                                          TextInputType.text,
                                                          decoration:
                                                          InputDecoration(
                                                            enabled: false,
                                                            disabledBorder:
                                                            OutlineInputBorder(
                                                                borderSide:
                                                                BorderSide(
                                                                    color:
                                                                    background)),
                                                            labelText: 'Name and Contact',
                                                            labelStyle: TextStyle(
                                                                color: background1,
                                                                fontSize: 14),
                                                            contentPadding:
                                                            EdgeInsets.all(8),
                                                            border:
                                                            OutlineInputBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Flexible(
                                                      child: Container(
                                                        width:
                                                        MediaQuery
                                                            .of(context)
                                                            .size
                                                            .width /
                                                            4,
                                                        padding:
                                                        const EdgeInsets.all(4),
                                                        child: TextField(
                                                          onChanged: (value) {},
                                                          controller:
                                                          callSheetControllers
                                                              .last,
                                                          keyboardType:
                                                          TextInputType.number,
                                                          decoration:
                                                          InputDecoration(
                                                            enabled: false,
                                                            disabledBorder:
                                                            OutlineInputBorder(
                                                                borderSide:
                                                                BorderSide(
                                                                    color:
                                                                    background)),
                                                            labelText: 'Call Sheet',
                                                            labelStyle: TextStyle(
                                                                color: background1,
                                                                fontSize: 14),
                                                            contentPadding:
                                                            EdgeInsets.all(8),
                                                            border:
                                                            OutlineInputBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Flexible(
                                                      child: Padding(
                                                        padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                        child: Text(
                                                          "Subtotal: ${budget[categories[i]][budget[categories[i]]
                                                              .keys.elementAt(
                                                              j)]["subtotal"]}",
                                                          style: subheading,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Flexible(
                                                      child: Padding(
                                                        padding: const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 4,
                                                            vertical: 8),
                                                        child: TextField(
                                                          controller:
                                                          quantityControllers
                                                              .last,
                                                          keyboardType:
                                                          TextInputType.number,
                                                          decoration:
                                                          InputDecoration(
                                                            enabledBorder:
                                                            OutlineInputBorder(
                                                                borderSide:
                                                                BorderSide(
                                                                    color:
                                                                    background)),
                                                            labelText: 'Quantity',
                                                            labelStyle: TextStyle(
                                                                color: background1,
                                                                fontSize: 14),
                                                            contentPadding:
                                                            EdgeInsets.all(8),
                                                            border:
                                                            OutlineInputBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Flexible(
                                                      child: Padding(
                                                        padding: const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 4,
                                                            vertical: 8),
                                                        child: TextField(
                                                          controller:
                                                          rateControllers.last,
                                                          keyboardType:
                                                          TextInputType.number,
                                                          decoration:
                                                          InputDecoration(
                                                            enabled: false,
                                                            disabledBorder:
                                                            OutlineInputBorder(
                                                                borderSide:
                                                                BorderSide(
                                                                    color:
                                                                    background)),
                                                            labelText: 'Rate',
                                                            labelStyle: TextStyle(
                                                                color: background1,
                                                                fontSize: 14),
                                                            contentPadding:
                                                            EdgeInsets.all(8),
                                                            border:
                                                            OutlineInputBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        })),
                                  ),
                                ],
                              );
                            }) +
                            <Widget>[
                              Text(
                                viewCats < budget.length ? "Loading.." : "",
                                style: TextStyle(color: color),
                              )
                            ],
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    controller: scrollController,
                    child: Container(
                      color: background,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: Icon(CupertinoIcons.back),
                                  onPressed: prevDate,
                                ),
                                Text(
                                  "${date.day > 9 ? date.day : "0${date.day}"}-${date.month > 9 ? date.month : "0${date.month}"}-${date.year}, ${weeksDays[date.weekday - 1]}",
                                  style: TextStyle(fontSize: 18),
                                ),
                                IconButton(
                                  icon: Icon(CupertinoIcons.forward),
                                  onPressed: nextDate,
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            thickness: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                SizedBox(
                  height: 8,
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(CupertinoIcons.back),
                        onPressed: prevDate,
                      ),
                      Text(
                        "${date.day > 9 ? date.day : "0${date.day}"}-${date.month > 9 ? date.month : "0${date.month}"}-${date.year}, ${weeksDays[date.weekday - 1]}",
                        style: TextStyle(fontSize: 18),
                      ),
                      IconButton(
                        icon: Icon(CupertinoIcons.forward),
                        onPressed: nextDate,
                      ),
                    ],
                  ),
                ),
                Divider(
                  thickness: 2,
                ),
                SizedBox(
                  height: 50,
                ),
                Text(
                  "No Budget.",
                  style: TextStyle(fontSize: 20),
                ),
                ElevatedButton(
                  onPressed: () async {
                    var now = DateTime.now();
                    Map<dynamic, dynamic> dailyBudget = {
                      "day": date.day,
                      "project_id": project.id,
                      "month": date.month,
                      "added_by": Utils.USER_ID,
                      "budget": {},
                      "scenes_budget": {},
                      "id": id,
                      "year": date.year,
                      "last_edit_by": Utils.USER_ID,
                      "last_edit_on": now.millisecondsSinceEpoch,
                      "created": now.millisecondsSinceEpoch
                    };
                    print(dailyBudget);
                    await Navigator.push(
                        context,
                        Utils.createRoute(
                            AddDailyBudget(
                                project: project, dailyBudget: dailyBudget),
                            Utils.DTU));
                    getDailyBudgets();
                  },
                  child: Text("+ Add Budget"),
                  style: ElevatedButton.styleFrom(primary: color),
                )
              ],
            ),
    );
  }
}
/*Scaffold(
      key: _scaffoldKey,
      backgroundColor: background,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
                child: Wrap(
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  spacing: 4,
                  runSpacing: 12,
                  children: [
                    Container(
                      margin: EdgeInsets.all(2),
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(300),
                          boxShadow: [
                            BoxShadow(
                              color: color,
                              offset: Offset(0, 4),
                              blurRadius: 5,
                            ),
                          ]),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: color,
                          ),
                          pickedDate == null
                              ? Text(
                                  "${DateTime.now().toString().substring(0, 10)}",
                                  style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                )
                              : Text(
                                  "${pickedDate}",
                                  style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            PageRouteBuilder(
                                pageBuilder: (_, __, ___) => SelectLocation(),
                                opaque: false));
                      },
                      child: Container(
                        margin: EdgeInsets.all(2),
                        padding:
                            EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(300),
                            boxShadow: [
                              BoxShadow(
                                color: color,
                                offset: Offset(0, 4),
                                blurRadius: 5,
                              ),
                            ]),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on,
                              color: color,
                            ),
                            Text(
                              "Ramoji Film City",
                              style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        TimeOfDay time = await showTimePicker(
                            context: context,
                            initialTime: _timeOfDay,
                            builder: (BuildContext context, Widget child) {
                              return Theme(
                                data: ThemeData(),
                                child: child,
                              );
                            });
                        await setState(() {
                          final localizations =
                              MaterialLocalizations.of(context);
                          startTime = localizations.formatTimeOfDay(time);
                          if (time == null) {
                            formattedTimeOfDay =
                                localizations.formatTimeOfDay(TimeOfDay.now());
                          } else {
                            _timeOfDay = time;
                          }
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.all(2),
                        padding:
                            EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(300),
                            boxShadow: [
                              BoxShadow(
                                color: color,
                                offset: Offset(0, 4),
                                blurRadius: 5,
                              ),
                            ]),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.access_time_outlined,
                              color: color,
                            ),
                            startTime != null
                                ? Text(
                                    "${startTime}",
                                    //"check",
                                    //"09:00 A.M",
                                    style: TextStyle(
                                        color: color,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  )
                                : Text(
                                    "${formattedTimeOfDay}",
                                    //"text",
                                    //"09:00 A.M",
                                    style: TextStyle(
                                        color: color,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                            Text(
                              "(Start Time)",
                              style: TextStyle(color: color, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        TimeOfDay time = await showTimePicker(
                            context: context,
                            initialTime: _timeOfDay,
                            builder: (BuildContext context, Widget child) {
                              return Theme(
                                data: ThemeData(),
                                child: child,
                              );
                            });
                        setState(() {
                          final localizations =
                              MaterialLocalizations.of(context);
                          endTime = localizations.formatTimeOfDay(time);
                          if (time == null) {
                            formattedTimeOfDay =
                                localizations.formatTimeOfDay(TimeOfDay.now());
                          } else {
                            _timeOfDay = time;
                          }
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.all(2),
                        padding:
                            EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(300),
                            boxShadow: [
                              BoxShadow(
                                color: color,
                                offset: Offset(0, 4),
                                blurRadius: 5,
                              ),
                            ]),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.access_time_outlined,
                              color: color,
                            ),
                            endTime != null
                                ? Text(
                                    "${endTime}",
                                    style: TextStyle(
                                        color: color,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  )
                                : Text(
                                    "${formattedTimeOfDay}",
                                    style: TextStyle(
                                        color: color,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                            Text(
                              "(End Time)",
                              style: TextStyle(color: color, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  createAlertDialog(context, "Category").then((v) {
                    if (v == null) {
                    } else if (budget['${v}'] == null) {
                      budget['${v}'] = {};
                      setState(() {});
                    } else {
                      final snackbar = SnackBar(
                        duration: new Duration(seconds: 3),
                        content: Text(
                          "${v} is already used or check the name!!",
                          style: TextStyle(color: background),
                        ),
                        backgroundColor: background1,
                      );
                      _scaffoldKey.currentState.showSnackBar(snackbar);
                    }
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "+Add Category",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo),
                      )),
                ),
              ),
              Column(
                children: List<Widget>.generate(budget.length, (i) {
                  subCategories = budget[categories[i]].keys.toList();
                  return Column(
                    children: [
                      Divider(
                        thickness: 1,
                        color: background1,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                "${categories[i].replaceAll("_", " ")}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: categoryHeading,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                createAlertDialog(context, "SubCategory")
                                    .then((v) {
                                  if (v == null) {
                                  } else if (budget[categories[i]]['${v}'] ==
                                      null) {
                                    budget[categories[i]]['$v'] = {
                                      'contact': '',
                                      'quantity': 0,
                                      'rate': 0,
                                      'subtotal': 0,
                                      'use': true,
                                      'callSheet': 0
                                    };
                                    setState(() {});
                                  } else {
                                    final snackbar = SnackBar(
                                      duration: new Duration(seconds: 3),
                                      content: Text(
                                        "${v} is already used or check the name!!",
                                        style: TextStyle(color: background),
                                      ),
                                      backgroundColor: background1,
                                    );
                                    _scaffoldKey.currentState
                                        .showSnackBar(snackbar);
                                  }
                                });
                              },
                              child: Text(
                                "+Add Subcategory",
                                style: TextStyle(color: Colors.indigo),
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                            children: List<Widget>.generate(
                                subCategories.length, (j) {
                          var subcategory =
                              budget[categories[i]][subCategories[j]];
                          contactControllers.add(new TextEditingController(
                              text: "${subcategory["contact"]}"));
                          quantityControllers.add(new TextEditingController(
                              text: "${subcategory["quantity"]}"));
                          rateControllers.add(new TextEditingController(
                              text: "${subcategory["rate"]}"));
                          callSheetControllers.add(new TextEditingController(
                              text: "${subcategory["callSheet"]}"));
                          return Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    border: Border(
                                        top: BorderSide(
                                            color: j != 0
                                                ? background1
                                                : background,
                                            width: 1))),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Transform.scale(
                                          scale: 1.1,
                                          child: Checkbox(
                                              value: budget[categories[i]]
                                                  [subCategories[j]]["use"],
                                              activeColor: color,
                                              onChanged: (value) {
                                                setState(() {
                                                  budget[categories[i]]
                                                          [subCategories[j]]
                                                      ["use"] = value;
                                                });
                                              }),
                                        ),
                                        Text(
                                          "${subCategories[j].replaceAll("_", " ")}",
                                          style: subheading,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Padding(
                                            padding: const EdgeInsets.all(4),
                                            child: TextField(
                                              onChanged: (value) {
                                                budget[categories[i]]
                                                        [subCategories[j]]
                                                    ["contact"] = value;
                                              },
                                              controller:
                                                  contactControllers.last,
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: InputDecoration(
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                background1)),
                                                labelText: 'Contact#',
                                                labelStyle: TextStyle(
                                                    color: background1,
                                                    fontSize: 14),
                                                contentPadding:
                                                    EdgeInsets.all(8),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                4,
                                            padding: const EdgeInsets.all(4),
                                            child: TextField(
                                              onChanged: (value) {
                                                budget[categories[i]]
                                                        [subCategories[j]]
                                                    ["callSheet"] = value;
                                              },
                                              controller:
                                                  callSheetControllers.last,
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: InputDecoration(
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                background1)),
                                                labelText: 'Call Sheet',
                                                labelStyle: TextStyle(
                                                    color: background1,
                                                    fontSize: 14),
                                                contentPadding:
                                                    EdgeInsets.all(8),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "Subtotal: ${budget[categories[i]][subCategories[j]]["subtotal"]}",
                                              style: subheading,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4, vertical: 8),
                                            child: TextField(
                                              onChanged: (a) {
                                                if (a.isEmpty) {
                                                  a = '0';
                                                }
                                                setState(() {
                                                  budget[categories[i]]
                                                              [subCategories[j]]
                                                          ["quantity"] =
                                                      int.parse(a);
                                                  budget[categories[i]]
                                                          [subCategories[j]]
                                                      ["subtotal"] = int.parse(
                                                          a) *
                                                      budget[categories[i]]
                                                              [subCategories[j]]
                                                          ["rate"];
                                                });
                                              },
                                              controller:
                                                  quantityControllers.last,
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: InputDecoration(
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                background1)),
                                                labelText: 'Quantity',
                                                labelStyle: TextStyle(
                                                    color: background1,
                                                    fontSize: 14),
                                                contentPadding:
                                                    EdgeInsets.all(8),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4, vertical: 8),
                                            child: TextField(
                                              onChanged: (a) {
                                                if (a.isEmpty) {
                                                  a = '0';
                                                }
                                                setState(() {
                                                  budget[categories[i]]
                                                          [subCategories[j]]
                                                      ["rate"] = int.parse(a);
                                                  budget[categories[i]]
                                                          [subCategories[j]]
                                                      ["subtotal"] = int.parse(
                                                          a) *
                                                      budget[categories[i]]
                                                              [subCategories[j]]
                                                          ["quantity"];
                                                });
                                              },
                                              controller: rateControllers.last,
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: InputDecoration(
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                background1)),
                                                labelText: 'Rate',
                                                labelStyle: TextStyle(
                                                    color: background1,
                                                    fontSize: 14),
                                                contentPadding:
                                                    EdgeInsets.all(8),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        })),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );*/
