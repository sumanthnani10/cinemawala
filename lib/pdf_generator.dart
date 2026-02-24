import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cinemawala/daily_budget/daily_budget.dart';
import 'package:cinemawala/locations/location.dart';
import 'package:cinemawala/props/prop.dart';
import 'package:cinemawala/scenes/scene.dart';
import 'package:cinemawala/schedule/schedule.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:universal_html/html.dart' as html;

import 'artists/actor.dart';
import 'costumes/costume.dart';
import 'projects/project.dart';
import 'utils.dart';

class PdfGenerator {

  static Future<Uint8List> getImageBytes(String link) async {
    Uint8List response =
        (await NetworkAssetBundle(Uri.parse("${link}")).load("${link}"))
            .buffer
            .asUint8List();
    return response;
  }
  static Widget sceneDetails(
    Project project,
    Scene scene,
    Schedule schedule,
    String date,
  ) {
    TextStyle labelStyle = TextStyle(fontSize: 12),
        valueStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        callSheetTimeStyle =
            TextStyle(fontWeight: FontWeight.bold, fontSize: 16);
    EdgeInsets headingPadding = const EdgeInsets.all(4);
    Location location = Utils.locationsMap['${scene.location}'];

    return Table(
      border: TableBorder.all(),
      children: [
        TableRow(
            verticalAlignment: TableCellVerticalAlignment.middle,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(2),
                child: Text("Production"),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                    padding: headingPadding,
                    child: RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(text: 'Date: ', style: labelStyle),
                          TextSpan(text: '${date}', style: valueStyle),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: PdfColors.black,
                  ),
                  Padding(
                      padding: headingPadding,
                      child: RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(text: 'Working Day: ', style: labelStyle),
                            TextSpan(text: '${10}', style: valueStyle),
                          ],
                        ),
                      )),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(text: 'Project Name: ', style: labelStyle),
                          TextSpan(text: '${project.name}', style: valueStyle),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: PdfColors.black,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(text: 'Director: ', style: labelStyle),
                          TextSpan(
                              text: '${project.director}', style: valueStyle),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: PdfColors.black,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(text: 'D.O.P: ', style: labelStyle),
                          TextSpan(text: '${project.dop}', style: valueStyle),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ]),
        TableRow(
            verticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(text: 'Location: ', style: labelStyle),
                        TextSpan(
                            text: '${location.shootLocation}',
                            style: valueStyle),
                      ],
                    ),
                  )),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                                text: 'Start Time (Call Sheet): ',
                                style: labelStyle),
                            TextSpan(
                                text:
                                    '${oneDigitToTwo(schedule.callSheetTimings[scene.id]["start"][0])}:${oneDigitToTwo(schedule.callSheetTimings[scene.id]["start"][1])} ${schedule.callSheetTimings[scene.id]["start"][2] == 0 ? "AM" : "PM"}',
                                style: callSheetTimeStyle),
                          ],
                        ),
                      )),
                  Divider(
                    height: 1,
                    color: PdfColors.black,
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                                text: 'End Time (Call sheet): ',
                                style: labelStyle),
                            TextSpan(
                                text:
                                    '${oneDigitToTwo(schedule.callSheetTimings[scene.id]["end"][0])}:${oneDigitToTwo(schedule.callSheetTimings[scene.id]["end"][1])} ${schedule.callSheetTimings[scene.id]["end"][2] == 0 ? "AM" : "PM"}',
                                style: callSheetTimeStyle),
                          ],
                        ),
                      )),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text("Choreographer"),
                  ),
                  Divider(
                    height: 1,
                    color: PdfColors.black,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                              text:
                                  '${scene.interior == 0 ? "Interior" : scene.interior == 1 ? "Exterior" : "Interior & Exterior"}/${scene.day == 0 ? "Day" : ""} ${scene.day == 2 ? "&" : ""} ${scene.day == 1 ? "Night" : ""}\n',
                              style: valueStyle),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ]),
      ],
    );
  }
  static savePdf(dynamic fileName,dynamic pdf) async{
    Directory documentDirectory = await path.getExternalStorageDirectory();
    String documentPath = documentDirectory.path;
    if (kIsWeb) {
      html.AnchorElement()
        ..href = '${Uri.dataFromBytes(pdf)}'
        ..download = "$documentPath/${fileName}.pdf"
        ..style.display = 'none'
        ..click();
    } else {
      File file = File("$documentPath/${fileName}.pdf");
      file.writeAsBytesSync(await pdf.save());
    }
    return;
  }
  static dailyReportCallSheet(
      DailyBudget dailyReport,
      String callSheetType,
      ) async{
    Map dailyReportMap = dailyReport.budget;
    List<dynamic> categories,subcategories;
    Document pdf = Document();
    categories = dailyReportMap.keys.toList();
    pdf.addPage(
      Page(
        margin: const EdgeInsets.all(16),
        pageFormat: PdfPageFormat(595.2, double.infinity),
          build: (context) {
          return Container(
            child: Column(
              children: List.generate(categories.length, (i){
                subcategories = dailyReportMap[categories[i]].keys.toList();
                return Column(
                  children: [
                    Table(
                      children: [
                        TableRow(children: [
                          Text("${categories[i]}",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16)),
                        ])
                      ]
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                          children: List.generate(subcategories.length, (j){
                            return dailyReportMap[categories[i]][subcategories[j]]["use"] ? Container(
                                margin: EdgeInsets.symmetric(horizontal: 4,vertical: 10),
                                padding: EdgeInsets.symmetric(horizontal: 6,vertical: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: PdfColors.black),
                                ),
                                child: callSheetType=="Daily Program" ?
                                RichText(
                                  text: TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(text: '${subcategories[j]}\n\n',style: TextStyle(fontWeight: FontWeight.bold,decoration: TextDecoration.underline,)),
                                      TextSpan(text: 'Contact', style: TextStyle(fontWeight: FontWeight.bold)),
                                      TextSpan(text: '${dailyReportMap[categories[i]][subcategories[j]]["contact"]}\n'),
                                      TextSpan(text: 'Quantity', style: TextStyle(fontWeight: FontWeight.bold)),
                                      TextSpan(text: '${dailyReportMap[categories[i]][subcategories[j]]["quantity"]}\n'),
                                      TextSpan(text: 'CallSheet', style: TextStyle(fontWeight: FontWeight.bold)),
                                      TextSpan(text: '${dailyReportMap[categories[i]][subcategories[j]]["callSheet"]}\n'),
                                    ],
                                  ),
                                )
                                    : RichText(
                                  text: TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(text: '${subcategories[j]}\n\n',style: TextStyle(fontWeight: FontWeight.bold,decoration: TextDecoration.underline,)),
                                      TextSpan(text: 'Contact', style: TextStyle(fontWeight: FontWeight.bold)),
                                      TextSpan(text: '${dailyReportMap[categories[i]][subcategories[j]]["contact"]}\n'),
                                      TextSpan(text: 'Quantity', style: TextStyle(fontWeight: FontWeight.bold)),
                                      TextSpan(text: '${dailyReportMap[categories[i]][subcategories[j]]["quantity"]}\n'),
                                      TextSpan(text: 'Rate', style: TextStyle(fontWeight: FontWeight.bold)),
                                      TextSpan(text: '${dailyReportMap[categories[i]][subcategories[j]]["rate"]}\n'),
                                      TextSpan(text: 'Subtotal', style: TextStyle(fontWeight: FontWeight.bold)),
                                      TextSpan(text: '${dailyReportMap[categories[i]][subcategories[j]]["subtotal"]}\n'),
                                      TextSpan(text: 'CallSheet', style: TextStyle(fontWeight: FontWeight.bold)),
                                      TextSpan(text: '${dailyReportMap[categories[i]][subcategories[j]]["callSheet"]}\n'),
                                    ],
                                  ),
                                )
                            ) : Container();
                          })
                      ),
                    ),
                    Divider(height: 2,color: PdfColors.black),
                    SizedBox(height: 8),
                  ]
                );
              })
            ),
          );
          },
      )
    );
    savePdf(dailyReport.id,pdf);
  }
  static artistWise(
      Map<dynamic,Scene> scenesMap,
          Map<String,Location> locationsMap,
      List<Schedule> schedules,
      Actor artist
      ) async{
    var artistTiming;
    String workTime;
    Location stLoc;
    Scene scene;
    int hours;
    Document pdf = Document();
    pdf.addPage(
        Page(margin: const EdgeInsets.all(16),
            pageFormat: PdfPageFormat(595.2, double.infinity),
          build: (context) {
            return Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:List.generate(schedules.length, (i){
                  Schedule schedule = schedules[i];
                  return Table(
                    children: [
                      TableRow(children: [
                  Column(
                  children: List.generate(schedule.scenes.length, (j){
                    if(schedule.scenes[j]!='scene_OtudreeM' && i==0){
                      scene = scenesMap[schedule.scenes[j]];
                      print(schedule.scenes[j]);
                      print(scene);
                      stLoc = locationsMap[scene.location];
                      artistTiming = schedule.artistTimings[scene.id][artist.id];
                      print(artistTiming);
                      var startHour,endHour,startMinute,endMinute;
                      startHour = (artistTiming['start'][0]);
                      endHour = (artistTiming['end'][0]);
                      startMinute = (artistTiming['start'][1]);
                      endMinute = (artistTiming['end'][1]);
                      if(artistTiming['start'][2]==artistTiming['end'][2]){
                        workTime = "${endHour-startHour} : ${ startMinute>endMinute ? startMinute-endMinute : endMinute-startMinute } hrs";
                      }else{
                        if(startHour>endHour){
                          var diff = startHour-endHour;
                          hours = 12 - diff;
                          workTime = "$hours : ${startMinute>endMinute ? startMinute-endMinute : endMinute-startMinute} hrs";
                        }else{
                          var diff = endHour - startHour;
                          hours = 12 + diff;
                          workTime = "$hours : ${startMinute>endMinute ? startMinute-endMinute : endMinute-startMinute} hrs";
                        }
                      }
                    }
                    return Column(
                        children: [
                          Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: PdfColors.black),
                                  ),
                                  child: Text("${j+1}"),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: PdfColors.black),
                                  ),
                                  child: Text("${schedule.day} - ${schedule.month} - ${schedule.year}"),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: PdfColors.black),
                                  ),
                                  child: stLoc!=null ?  Text("${stLoc.shootLocation}") : Text(""),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: PdfColors.black),
                                  ),
                                  child: scene!=null ? Text("${scene.titles['en']}") : Text(""),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: PdfColors.black),
                                  ),
                                  child: Text(workTime),
                                ),
                              ]
                          ),
                        ]
                    );
                  })
                  ),
                      ])
                    ]
                  );

                })
              ),
            );
          })
    );
    savePdf(artist.id,pdf);
  }
  static sceneCallSheet(
      Project project,
      context,
      Scene scene,
      Schedule schedule,
      String date,
      String language,
      Set<Actor> artists) async {
    TextStyle labelStyle = TextStyle(fontSize: 12),
        valueStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        tableHeader = TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        tableRow = TextStyle(fontSize: 12),
        callSheetTimeStyle =
            TextStyle(fontWeight: FontWeight.bold, fontSize: 16);

    EdgeInsets headingPadding = const EdgeInsets.all(4),
        rowPadding = const EdgeInsets.all(2),
        gapPadding = const EdgeInsets.symmetric(vertical: 4);

    Document pdf = Document();
    Location location = Utils.locationsMap['${scene.location}'];
    Map<dynamic, dynamic> addlTimings = schedule.additionalTimings,
        vfxTimings = schedule.vfxTimings[scene.id],
        sfxTimings = schedule.sfxTimings[scene.id];
    String propsNames = "";
    for (var p in scene.props) {
      propsNames += Utils.propsMap[p].title;
      if (p != scene.props.last) propsNames += ", ";
    }
    DateTime now = DateTime.now();
    Widget footer =
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text("Cinemawala", style: TextStyle(fontSize: 10)),
      Text("Generated On ${now}", style: TextStyle(fontSize: 10))
    ]);
    pdf.addPage(
      Page(
          margin: const EdgeInsets.all(16),
          pageFormat: PdfPageFormat(595.2, double.infinity),
          build: (context) {
            return Container(
              child: Column(
                children: <Widget>[
                  sceneDetails(project, scene, schedule, date),
                  Table(
                    border: TableBorder.all(),
                    children: [
                      TableRow(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          children: [
                            Padding(
                                padding: headingPadding,
                                child: RichText(
                                  text: TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: 'Scene Title: ',
                                          style: labelStyle),
                                      TextSpan(
                                          text: '${scene.titles['$language']}',
                                          style: valueStyle),
                                    ],
                                  ),
                                )),
                          ]),
                      TableRow(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        children: [
                          Padding(
                            padding: headingPadding,
                            child: RichText(
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(text: 'Gist: ', style: labelStyle),
                                  TextSpan(
                                      text: '${scene.gists['$language']}',
                                      style: valueStyle),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  // Artists
                  Padding(
                      padding: gapPadding,
                      child: Table(
                        border: TableBorder.all(),
                        children: <TableRow>[
                              TableRow(
                                  verticalAlignment:
                                      TableCellVerticalAlignment.middle,
                                  children: [
                                    Padding(
                                      padding: headingPadding,
                                      child: Center(
                                        child:
                                            Text("Artists", style: tableHeader),
                                      ),
                                    ),
                                    Padding(
                                      padding: headingPadding,
                                      child: Center(
                                          child: Text("On Loc",
                                              style: tableHeader)),
                                    ),
                                    Padding(
                                      padding: headingPadding,
                                      child: Center(
                                          child: Text("On Set",
                                              style: tableHeader)),
                                    ),
                                  ]),
                            ] +
                            List<TableRow>.generate((artists.length), (i) {
                              Actor actor = artists.elementAt(i);
                              var timings =
                                  schedule.artistTimings[scene.id][actor.id];
                              return TableRow(children: [
                                Center(
                                  child: Padding(
                                    padding: rowPadding,
                                    child: Text("${actor.names["$language"]}",
                                        style: tableRow),
                                  ),
                                ),
                                Center(
                                  child: Padding(
                                      padding: rowPadding,
                                      child: Text(
                                          "${oneDigitToTwo(timings['start'][0])}:${timings['start'][1] == 0 ? "00" : oneDigitToTwo(timings['start'][1])} ${timings['start'][2] == 0 ? "AM" : "PM"}",
                                          style: tableRow)),
                                ),
                                Center(
                                  child: Padding(
                                      padding: rowPadding,
                                      child: Text(
                                          "${oneDigitToTwo(timings['end'][0])}:${timings['end'][1] == 0 ? "00" : oneDigitToTwo(timings['end'][1])} ${timings['end'][2] == 0 ? "AM" : "PM"}",
                                          style: tableRow)),
                                ),
                              ]);
                            }),
                      )),
                  SizedBox(height: 4),
                  // Company Artists
                  Column(
                    children:
                        List<Widget>.generate(scene.addlArtists.length, (keyj) {
                      var key = Utils.addlKeys[keyj];
                      if (!Utils.additionalArtists[key]['addable']) {
                        var artist = {
                          "Name":
                              '$key (${scene.addlArtists[key][0]['Contact']})'
                        };
                        var timings = addlTimings[scene.id][key];
                        var value = scene.addlArtists[key][0];
                        return Column(children: [
                          Table(
                            border: TableBorder.all(),
                            children: [
                              TableRow(
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                children: [
                                  Padding(
                                    padding: headingPadding,
                                    child: Text(
                                      "${artist['Name']}",
                                      style: tableHeader,
                                    ),
                                  ),
                                  Padding(
                                    padding: headingPadding,
                                    child: Text(
                                      "${oneDigitToTwo(timings['start'][0])}:${timings['start'][1] == 0 ? "00" : oneDigitToTwo(timings['start'][1])} ${timings['start'][2] == 0 ? "AM" : "PM"}",
                                      style: tableHeader,
                                    ),
                                  ),
                                  Padding(
                                    padding: headingPadding,
                                    child: Text(
                                      "${oneDigitToTwo(timings['end'][0])}:${timings['end'][1] == 0 ? "00" : oneDigitToTwo(timings['end'][1])} ${timings['end'][2] == 0 ? "AM" : "PM"}",
                                      style: tableHeader,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Table(
                            border: TableBorder.all(),
                            children: [
                              TableRow(
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                children: [
                                  Padding(
                                      padding: rowPadding,
                                      child: Text(
                                        "Males: ${value['Male']}\nFemales: ${value['Female']}\nKids: ${value['Kids']}",
                                        style: tableRow,
                                      )),
                                  Padding(
                                      padding: rowPadding,
                                      child: RichText(
                                        text: TextSpan(
                                          children: <TextSpan>[
                                            TextSpan(
                                                text: 'Note: ',
                                                style: labelStyle),
                                            TextSpan(
                                                text: '${value['Notes']}',
                                                style: tableRow),
                                          ],
                                        ),
                                      ))
                                ],
                              ),
                            ],
                          ),
                          Padding(padding: const EdgeInsets.all(4))
                        ]);
                      } else {
                        return scene.addlArtists['$key'].length == 0
                            ? Container()
                            : Column(children: [
                                Table(
                                    border: TableBorder.all(),
                                    children: [
                                          TableRow(
                                              verticalAlignment:
                                                  TableCellVerticalAlignment
                                                      .middle,
                                              children: [
                                                Padding(
                                                    padding: headingPadding,
                                                    child: Center(
                                                        child: Text(
                                                      "$key",
                                                      style: tableHeader,
                                                    ))),
                                                Padding(
                                                    padding: headingPadding,
                                                    child: Center(
                                                        child: Text(
                                                          "On Loc",
                                                      style: tableHeader,
                                                    ))),
                                                Padding(
                                                    padding: headingPadding,
                                                    child: Center(
                                                        child: Text(
                                                      "On Set",
                                                      style: tableHeader,
                                                    ))),
                                              ])
                                        ] +
                                        List<TableRow>.generate(
                                            scene.addlArtists['$key'].length,
                                            (ind) {
                                          var artist =
                                              scene.addlArtists['$key'][ind];
                                          var timings = addlTimings[scene.id]
                                              ["$key"][artist['id']];
                                          return TableRow(
                                            children: [
                                              Center(
                                                  child: Padding(
                                                      padding: rowPadding,
                                                      child: Text(
                                                        "${artist['Name']}",
                                                        style: tableRow,
                                                      ))),
                                              Center(
                                                  child: Padding(
                                                      padding: rowPadding,
                                                      child: Text(
                                                        "${oneDigitToTwo(timings['start'][0])}:${timings['start'][1] == 0 ? "00" : oneDigitToTwo(timings['start'][1])} ${timings['start'][2] == 0 ? "AM" : "PM"}",
                                                        style: tableRow,
                                                      ))),
                                              Center(
                                                  child: Padding(
                                                      padding: rowPadding,
                                                      child: Text(
                                                        "${oneDigitToTwo(timings['end'][0])}:${timings['end'][1] == 0 ? "00" : oneDigitToTwo(timings['end'][1])} ${timings['end'][2] == 0 ? "AM" : "PM"}",
                                                        style: tableRow,
                                                      )))
                                            ],
                                          );
                                        })),
                                Padding(padding: headingPadding)
                              ]);
                      }
                    }),
                  ),
                  // VFX
                  Padding(
                      padding: gapPadding,
                      child: Column(children: [
                        Table(
                          border: TableBorder.all(),
                          children: [
                            TableRow(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              children: [
                                Padding(
                                  padding: headingPadding,
                                  child: Text(
                                    "VFX:",
                                    style: tableHeader,
                                  ),
                                ),
                                Padding(
                                  padding: headingPadding,
                                  child: Text(
                                    "${oneDigitToTwo(vfxTimings['start'][0])}:${vfxTimings['start'][1] == 0 ? "00" : oneDigitToTwo(vfxTimings['start'][1])} ${vfxTimings['start'][2] == 0 ? "AM" : "PM"}",
                                    style: tableHeader,
                                  ),
                                ),
                                Padding(
                                  padding: headingPadding,
                                  child: Text(
                                    "${oneDigitToTwo(vfxTimings['end'][0])}:${vfxTimings['end'][1] == 0 ? "00" : oneDigitToTwo(vfxTimings['end'][1])} ${vfxTimings['end'][2] == 0 ? "AM" : "PM"}",
                                    style: tableHeader,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Table(
                          border: TableBorder.all(),
                          children: [
                            TableRow(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              children: [
                                Padding(
                                  padding: rowPadding,
                                  child: Text(
                                    "${scene.vfx}",
                                    style: tableRow,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      ])),
                  // SFX
                  Padding(
                      padding: gapPadding,
                      child: Column(children: [
                        Table(
                          border: TableBorder.all(),
                          children: [
                            TableRow(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              children: [
                                Padding(
                                  padding: headingPadding,
                                  child: Text(
                                    "SFX:",
                                    style: tableHeader,
                                  ),
                                ),
                                Padding(
                                  padding: headingPadding,
                                  child: Text(
                                    "${oneDigitToTwo(sfxTimings['start'][0])}:${sfxTimings['start'][1] == 0 ? "00" : oneDigitToTwo(sfxTimings['start'][1])} ${sfxTimings['start'][2] == 0 ? "AM" : "PM"}",
                                    style: tableHeader,
                                  ),
                                ),
                                Padding(
                                  padding: headingPadding,
                                  child: Text(
                                    "${oneDigitToTwo(sfxTimings['end'][0])}:${sfxTimings['end'][1] == 0 ? "00" : oneDigitToTwo(sfxTimings['end'][1])} ${sfxTimings['end'][2] == 0 ? "AM" : "PM"}",
                                    style: tableHeader,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Table(
                          border: TableBorder.all(),
                          children: [
                            TableRow(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              children: [
                                Padding(
                                  padding: rowPadding,
                                  child: Text(
                                    "${scene.sfx}",
                                    style: tableRow,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      ])),
                  // Special Equipments & Hair and Make Up
                  Padding(
                      padding: gapPadding,
                      child: Table(
                        border: TableBorder.all(),
                        children: [
                          TableRow(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            children: [
                              Padding(
                                padding: headingPadding,
                                child: Text(
                                  "Special Equipments",
                                  style: tableHeader,
                                ),
                          ),
                          Padding(
                            padding: rowPadding,
                            child: Text(
                              "${scene.specialEquipment}",
                              style: tableRow,
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        children: [
                          Padding(
                            padding: headingPadding,
                            child: Text(
                              "Hair and Make Up",
                              style: tableHeader,
                            ),
                          ),
                              Padding(
                                padding: rowPadding,
                                child: Text(
                                  "${scene.makeUp}",
                                  style: tableRow,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )),
                  // Props
                  Padding(
                      padding: gapPadding,
                      child: Table(
                        border: TableBorder.all(),
                        children: [
                          TableRow(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            children: [
                              Padding(
                                padding: headingPadding,
                                child: Text(
                                  "Properties",
                                  style: tableHeader,
                                ),
                          ),
                        ],
                      ),
                      TableRow(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        children: [
                              Padding(
                                padding: rowPadding,
                                child: Text(
                                  "$propsNames",
                                  style: tableRow,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )),
                  Padding(
                      padding: gapPadding,
                      child: Table(border: TableBorder.all(), children: [
                        TableRow(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          children: [
                            Padding(
                              padding: headingPadding,
                              child: Text(
                                "Approved By:",
                                style: tableHeader,
                              ),
                            ),
                          ],
                    ),
                    TableRow(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                          children: [
                            Padding(
                              padding: headingPadding,
                              child: Text(
                                "Ramesh Chand",
                                style: tableHeader,
                              ),
                            ),
                          ],
                        ),
                      ])),
                  footer,
                ],
              ),
            );
          }),
    );
    List actorCostumes = [];
    for (var c in scene.costumes) {
      var r = [];
      for (var d in c['costumes']) {
        Costume costume = Utils.costumesMap[d];
        r.add(await getImageBytes(costume.referenceImage));
      }
      actorCostumes.add(
          {"id": c['id'], "costumes_images": r, "costumes": c['costumes']});
    }
    pdf.addPage(
      Page(
          margin: const EdgeInsets.all(16),
          pageFormat: PdfPageFormat(595.2, double.infinity),
          build: (context) {
            return Container(
              child: Column(
                children: <Widget>[
                      Text("Costumes",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ] +
                    List.generate(actorCostumes.length, (i) {
                      Actor artist = Utils.artistsMap[actorCostumes[i]['id']];
                      var costumes = actorCostumes[i]['costumes'];
                      var costumesImages = actorCostumes[i]['costumes_images'];
                      return Padding(
                          padding: headingPadding,
                          child: Table(children: [
                            TableRow(
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                children: [
                                  Padding(
                                      padding: headingPadding,
                                      child: Text("${artist.names[language]}",
                                          style: tableHeader)),
                                ]),
                            TableRow(
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                children: List<Widget>.generate(
                                    costumesImages.length, (j) {
                                  Costume costume =
                                      Utils.costumesMap[costumes[j]];
                                  return Padding(
                                      padding: rowPadding,
                                      child: Column(children: [
                                        Image(
                                          MemoryImage(costumesImages[j]),
                                          width: 100,
                                          height: 100,
                                        ),
                                        Text('${costume.title}')
                                      ]));
                                })),
                          ]));
                    }) +
                    [
                      footer,
                    ],
              ),
            );
          }),
    );
    List propsImages = [];
    for (var c in scene.props) {
      Prop prop = Utils.propsMap[c];
      propsImages.add({
        "image": await getImageBytes(prop.referenceImage),
        "title": prop.title
      });
    }
    pdf.addPage(
      Page(
          margin: const EdgeInsets.all(16),
          pageFormat: PdfPageFormat(595.2, double.infinity),
          orientation: PageOrientation.portrait,
          build: (context) {
            return Container(
              child: Column(
                children: <Widget>[
                  Text("Properties",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  Wrap(
                      children: List.generate(
                          propsImages.length,
                          (i) => Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(children: [
                                Image(
                                  MemoryImage(propsImages[i]['image']),
                                  width: 100,
                                  height: 100,
                                ),
                                Text('${propsImages[i]['title']}')
                              ])))),
                  SizedBox(height: 16),
                  footer,
                ],
              ),
            );
          }),
    );
    savePdf(schedule.id, pdf);
  }
  static artistCallSheet(Project project, context, Scene scene,
      Schedule schedule, String date, String language, Actor artists) async {
    TextStyle labelStyle = TextStyle(fontSize: 12),
        valueStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        tableHeader = TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        tableRow = TextStyle(fontSize: 12);
    EdgeInsets headingPadding = const EdgeInsets.all(4),
        rowPadding = const EdgeInsets.all(2);
    var callSheetTimeStyle =
        TextStyle(fontWeight: FontWeight.bold, fontSize: 16);
    Document pdf = Document();
    Location location = Utils.locationsMap['${scene.location}'];
    Map<dynamic, dynamic> addlTimings = schedule.additionalTimings,
        vfxTimings = schedule.vfxTimings[scene.id],
        sfxTimings = schedule.sfxTimings[scene.id];
    String propsNames = "";
    for (var p in scene.props) {
      propsNames += Utils.propsMap[p].title;
      if (p != scene.props.last) propsNames += ", ";
    }
    DateTime now = DateTime.now();
    Widget footer =
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text("Cinemawala", style: TextStyle(fontSize: 10)),
      Text("Generated On ${now}", style: TextStyle(fontSize: 10))
    ]);
    List actorCostumes = [];
    for (var c in scene.costumes) {
      var r = [];
      if (c['id'] == artists.id) {
        for (var d in c['costumes']) {
          Costume costume = Utils.costumesMap[d];
          r.add(await getImageBytes(costume.referenceImage));
        }
        actorCostumes.add(
            {"id": c['id'], "costumes_images": r, "costumes": c['costumes']});
      }
    }
    pdf.addPage(
      Page(
          margin: const EdgeInsets.all(16),
          pageFormat: PdfPageFormat(595.2, double.infinity),
          build: (context) {
            return Container(
              child: Column(
                children: <Widget>[
                  sceneDetails(project, scene, schedule, date),
                  Table(
                    //border: TableBorder.all(),
                    border: TableBorder(
                        left: BorderSide(color: PdfColors.black),
                        right: BorderSide(color: PdfColors.black),
                        bottom: BorderSide(color: PdfColors.black)),
                    children: [
                      TableRow(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          children: [
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: RichText(
                                  text: TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: 'Scene Title: ',
                                          style: labelStyle),
                                      TextSpan(
                                          text: '${scene.titles['$language']}',
                                          style: valueStyle),
                                    ],
                                  ),
                                )),
                          ]),
                    ],
                  ),
                  Table(
                    border: TableBorder(
                      left: BorderSide(color: PdfColors.black),
                      right: BorderSide(color: PdfColors.black),
                      bottom: BorderSide(color: PdfColors.black),
                    ),
                    children: [
                      TableRow(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: RichText(
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(text: 'Gist: ', style: labelStyle),
                                  TextSpan(
                                      text: '${scene.gists['$language']}',
                                      style: valueStyle),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Padding(padding: const EdgeInsets.all(4)),
                  // Artists
                  Table(
                    border: TableBorder.all(),
                    children: <TableRow>[
                          TableRow(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              children: [
                                Padding(
                                  padding: headingPadding,
                                  child: Center(
                                    child: Text("Artists", style: tableHeader),
                                  ),
                                ),
                                Padding(
                                  padding: headingPadding,
                                  child: Center(
                                      child:
                                          Text("On Loc", style: tableHeader)),
                                ),
                                Padding(
                                  padding: headingPadding,
                                  child: Center(
                                      child:
                                          Text("On Set", style: tableHeader)),
                                ),
                              ]),
                        ] +
                        List<TableRow>.generate((1), (i) {
                          var timings =
                              schedule.artistTimings[scene.id][artists.id];
                          return TableRow(children: [
                            Center(
                              child: Padding(
                                padding: rowPadding,
                                child: Text("${artists.names["$language"]}",
                                    style: tableRow),
                              ),
                            ),
                            Center(
                              child: Padding(
                                  padding: rowPadding,
                                  child: Text(
                                      "${oneDigitToTwo(timings['start'][0])}:${timings['start'][1] == 0 ? "00" : oneDigitToTwo(timings['start'][1])} ${timings['start'][2] == 0 ? "AM" : "PM"}",
                                      style: tableRow)),
                            ),
                            Center(
                              child: Padding(
                                  padding: rowPadding,
                                  child: Text(
                                      "${oneDigitToTwo(timings['end'][0])}:${timings['end'][1] == 0 ? "00" : oneDigitToTwo(timings['end'][1])} ${timings['end'][2] == 0 ? "AM" : "PM"}",
                                      style: tableRow)),
                            ),
                          ]);
                        }),
                  ),
                  Padding(padding: const EdgeInsets.all(4)),
                  Table(border: TableBorder.all(), children: [
                    TableRow(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      children: [
                        Padding(
                          padding: headingPadding,
                          child: Text(
                            "Approved By:",
                            style: tableHeader,
                          ),
                        ),
                        Padding(
                          padding: headingPadding,
                          child: Text("Ramesh Chand"),
                        ),
                      ],
                    ),
                  ]),
                  Padding(padding: headingPadding),
                  Container(
                    child: Column(
                        children: <Widget>[
                              Text("Costumes",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            ] +
                            List.generate(actorCostumes.length, (i) {
                              Actor artist =
                                  Utils.artistsMap[actorCostumes[i]['id']];
                              var costumes = actorCostumes[i]['costumes'];
                              var costumesImages =
                                  actorCostumes[i]['costumes_images'];
                              return Padding(
                                  padding: headingPadding,
                                  child: Table(children: [
                                    TableRow(
                                        verticalAlignment:
                                            TableCellVerticalAlignment.middle,
                                        children: [
                                          Padding(
                                              padding: headingPadding,
                                              child: Text(
                                                  "${artist.names[language]}",
                                                  style: tableHeader)),
                                        ]),
                                    TableRow(
                                        verticalAlignment:
                                            TableCellVerticalAlignment.middle,
                                        children: List<Widget>.generate(
                                            costumesImages.length, (j) {
                                          Costume costume =
                                              Utils.costumesMap[costumes[j]];
                                          return Padding(
                                              padding: rowPadding,
                                              child: Column(children: [
                                                Image(
                                                  MemoryImage(
                                                      costumesImages[j]),
                                                  width: 100,
                                                  height: 100,
                                                ),
                                                Text('${costume.title}')
                                              ]));
                                        })),
                                  ]));
                            })),
                  ),
                  Padding(padding: headingPadding),
                  footer,
                ],
              ),
            );
          }),
    );
    savePdf(schedule.id, pdf);
  }
  static projectCallSheet(
      Map<DateTime, List<dynamic>> projectDates,Project project) async{
    Document pdf = Document();
    Map<dynamic,List<String>> temp = {};
    List dates = [];
    List info = [];
    projectDates.forEach((key, value) {
      dates.add(key);
    });
    List<dynamic> callme(var date){
      List scenes = projectDates[date].toList();
      for(var b=0;b<scenes.length;b++){
        Scene scene = Utils.scenesMap[scenes[b]];
        var datee = date.toString();
        datee = datee.substring(0,10);
        Location sceneLoc = Utils.locationsMap[scene.location];

      }
    }
    pdf.addPage(
        Page(
            margin: const EdgeInsets.all(16),
            pageFormat: PdfPageFormat(595.2, double.infinity),
            build: (context) {
              return Container(
                child: Column(
                  children:[
                   Column(
                     children: List.generate(dates.length, (i){
                       List scenes = projectDates[dates[i]].toList();
                       var date = dates[i].toString();
                       date = date.substring(0,10);
                       print("hello fefe ${scenes.length}");
                       print(date);
                       return Column(
                         children: [
                           Center(
                             child: Container(
                               padding : scenes.length!=0 ? EdgeInsets.all(12) : EdgeInsets.all(0),
                               child: scenes.length!=0 ? Text("${date}",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)) : Text(""),
                             ),
                           ),
                       Table(
                       border: i==0 ? TableBorder.all(color: PdfColors.black) : TableBorder.all(),
                       children: <TableRow>[
                       i==0 ? TableRow(children: [
                         Container(
                           padding: EdgeInsets.all(6),
                           child: Text("Location",style: TextStyle(fontWeight: FontWeight.bold)),
                         ),
                         Container(
                           padding: EdgeInsets.all(6),
                           child: Text("Shoot Location",style: TextStyle(fontWeight: FontWeight.bold)),
                         ),
                         Container(
                           padding: EdgeInsets.all(6),
                           child: Text("Scene No",style: TextStyle(fontWeight: FontWeight.bold)),
                         ),
                         Container(
                           padding: EdgeInsets.all(6),
                           child: Text("Scene Gist",style: TextStyle(fontWeight: FontWeight.bold)),
                         ),
                         Container(
                           padding: EdgeInsets.all(6),
                           child: Text("Artists",style: TextStyle(fontWeight: FontWeight.bold)),
                         ),
                       ]) : TableRow(children: [
                         Text(""),
                         Text(""),
                         Text(""),
                         Text(""),
                         Text(""),
                       ]),
                       ]+List<TableRow>.generate(scenes.length, (j){
                       Scene scene = Utils.scenesMap[scenes[j]];
                       Location sceneLoc = Utils.locationsMap[scene.location];
                       var artists = scene.artists;
                       return TableRow(
                       children: [
                       Container(
                       padding: EdgeInsets.all(8),
                       decoration : BoxDecoration(
                         border: Border(left: BorderSide(color: PdfColors.black),right: BorderSide(color: PdfColors.black)),
                       ),
                       child: Text(sceneLoc.location),
                       ),
                       Container(
                       padding: EdgeInsets.all(8),
                       decoration : BoxDecoration(
                       border: Border(left: BorderSide(color: PdfColors.black),right: BorderSide(color: PdfColors.black)),
                       ),
                       child: Text("${scene.titles['en']}"),
                       ),
                       Container(
                       padding: EdgeInsets.all(8),
                       decoration : BoxDecoration(
                         border: Border(left: BorderSide(color: PdfColors.black),right: BorderSide(color: PdfColors.black)),
                       ),
                       child: Text("${sceneLoc.shootLocation}"),
                       ),
                       Container(
                       padding: EdgeInsets.all(8),
                       decoration : BoxDecoration(
                         border: Border(left: BorderSide(color: PdfColors.black),right: BorderSide(color: PdfColors.black)),
                       ),
                       child: Text("${scene.gists['en']}"),
                       ),
                       Container(
                       padding: EdgeInsets.all(8),
                       decoration : BoxDecoration(
                         border: Border(left: BorderSide(color: PdfColors.black),right: BorderSide(color: PdfColors.black)),
                       ),
                       child: Wrap(
                       direction: Axis.horizontal,
                       children: List.generate(artists.length, (artist){
                       Actor actor = Utils.artistsMap[artists[artist]];
                       print(artist);
                       return Container(
                       child: artists.length-1==artist ? Text(" ${actor.names['en']}") : Text(" ${actor.names['en']}, "),
                       );
                       })
                       ),
                       ),
                       ],
                       );
                       })
                       ),
                         ],
                       );
                     })
                   ),
                  ],
                )
              );
            }
        ));
    savePdf(project.id, pdf);
  }
  static costumeCallSheet(
      Project project,
      context,
      Scene scene,
      Schedule schedule,
      String date,
      String language,
      Set<Actor> artists) async {
    TextStyle labelStyle = TextStyle(fontSize: 12),
        valueStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        tableHeader = TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        tableRow = TextStyle(fontSize: 12);
    EdgeInsets headingPadding = const EdgeInsets.all(4),
        rowPadding = const EdgeInsets.all(2);
    var callSheetTimeStyle =
        TextStyle(fontWeight: FontWeight.bold, fontSize: 16);
    Document pdf = Document();
    Location location = Utils.locationsMap['${scene.location}'];
    Map<dynamic, dynamic> addlTimings = schedule.additionalTimings;
    DateTime now = DateTime.now();
    Widget footer =
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text("Cinemawala", style: TextStyle(fontSize: 10)),
      Text("Generated On ${now}", style: TextStyle(fontSize: 10))
    ]);

    pdf.addPage(
      Page(
          margin: const EdgeInsets.all(16),
          pageFormat: PdfPageFormat(595.2, double.infinity),
          build: (context) {
            return Container(
              child: Column(
                children: <Widget>[
                  sceneDetails(project, scene, schedule, date),
                  Padding(padding: const EdgeInsets.all(4)),
                  // Artists
                  Table(
                    border: TableBorder.all(),
                    children: <TableRow>[
                          TableRow(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              children: [
                                Padding(
                                  padding: headingPadding,
                                  child: Center(
                                    child: Text("Artists", style: tableHeader),
                                  ),
                                ),
                                Padding(
                                  padding: headingPadding,
                                  child: Center(
                                      child:
                                          Text("On Loc", style: tableHeader)),
                                ),
                                Padding(
                                  padding: headingPadding,
                                  child: Center(
                                      child:
                                          Text("On Set", style: tableHeader)),
                                ),
                              ]),
                        ] +
                        List<TableRow>.generate((artists.length), (i) {
                          Actor actor = artists.elementAt(i);
                          var timings =
                              schedule.artistTimings[scene.id][actor.id];
                          return TableRow(children: [
                            Center(
                              child: Padding(
                                padding: rowPadding,
                                child: Text("${actor.names["$language"]}",
                                    style: tableRow),
                              ),
                            ),
                            Center(
                              child: Padding(
                                  padding: rowPadding,
                                  child: Text(
                                      "${oneDigitToTwo(timings['start'][0])}:${timings['start'][1] == 0 ? "00" : oneDigitToTwo(timings['start'][1])} ${timings['start'][2] == 0 ? "AM" : "PM"}",
                                      style: tableRow)),
                            ),
                            Center(
                              child: Padding(
                                  padding: rowPadding,
                                  child: Text(
                                      "${oneDigitToTwo(timings['end'][0])}:${timings['end'][1] == 0 ? "00" : oneDigitToTwo(timings['end'][1])} ${timings['end'][2] == 0 ? "AM" : "PM"}",
                                      style: tableRow)),
                            ),
                          ]);
                        }),
                  ),
                  Padding(padding: const EdgeInsets.all(4)),
                  // Company Artists
                  Column(
                    children:
                        List<Widget>.generate(scene.addlArtists.length, (keyj) {
                      var key = Utils.addlKeys[keyj];
                      if (!Utils.additionalArtists[key]['addable']) {
                        var artist = {
                          "Name":
                              '$key (${scene.addlArtists[key][0]['Contact']})'
                        };
                        var timings = addlTimings[scene.id][key];
                        var value = scene.addlArtists[key][0];
                        return Column(children: [
                          Table(
                            border: TableBorder.all(),
                            children: [
                              TableRow(
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                children: [
                                  Padding(
                                    padding: headingPadding,
                                    child: Text(
                                      "${artist['Name']} ",
                                      style: tableHeader,
                                    ),
                                  ),
                                  Padding(
                                    padding: headingPadding,
                                    child: Text(
                                      "${oneDigitToTwo(timings['start'][0])}:${timings['start'][1] == 0 ? "00" : oneDigitToTwo(timings['start'][1])} ${timings['start'][2] == 0 ? "AM" : "PM"} ",
                                      style: tableHeader,
                                    ),
                                  ),
                                  Padding(
                                    padding: headingPadding,
                                    child: Text(
                                      " ${oneDigitToTwo(timings['end'][0])}:${timings['end'][1] == 0 ? "00" : oneDigitToTwo(timings['end'][1])} ${timings['end'][2] == 0 ? "AM" : "PM"}",
                                      style: tableHeader,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Table(
                            border: TableBorder.all(),
                            children: [
                              TableRow(
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                children: [
                                  Padding(
                                      padding: rowPadding,
                                      child: Text(
                                        "Males: ${value['Male']}\nFemales: ${value['Female']}\nKids: ${value['Kids']}",
                                        style: tableRow,
                                      )),
                                  Padding(
                                      padding: rowPadding,
                                      child: RichText(
                                        text: TextSpan(
                                          children: <TextSpan>[
                                            TextSpan(
                                                text: 'Note: ',
                                                style: labelStyle),
                                            TextSpan(
                                                text: '${value['Notes']}',
                                                style: tableRow),
                                          ],
                                        ),
                                      ))
                                ],
                              ),
                            ],
                          ),
                          Padding(padding: const EdgeInsets.all(4))
                        ]);
                      } else {
                        return scene.addlArtists['$key'].length == 0
                            ? Container()
                            : Column(children: [
                                Table(
                                    border: TableBorder.all(),
                                    children: [
                                          TableRow(
                                              verticalAlignment:
                                                  TableCellVerticalAlignment
                                                      .middle,
                                              children: [
                                                Padding(
                                                    padding: headingPadding,
                                                    child: Center(
                                                        child: Text(
                                                      "$key",
                                                      style: tableHeader,
                                                    ))),
                                                Padding(
                                                    padding: headingPadding,
                                                    child: Center(
                                                        child: Text(
                                                          "On Loc",
                                                      style: tableHeader,
                                                    ))),
                                                Padding(
                                                    padding: headingPadding,
                                                    child: Center(
                                                        child: Text(
                                                      "On Set",
                                                      style: tableHeader,
                                                    ))),
                                              ])
                                        ] +
                                        List<TableRow>.generate(
                                            scene.addlArtists['$key'].length,
                                            (ind) {
                                          var artist =
                                              scene.addlArtists['$key'][ind];
                                          var timings = addlTimings[scene.id]
                                              ["$key"][artist['id']];
                                          return TableRow(
                                            children: [
                                              Center(
                                                  child: Padding(
                                                      padding: rowPadding,
                                                      child: Text(
                                                        "${artist['Name']}",
                                                        style: tableRow,
                                                      ))),
                                              Center(
                                                  child: Padding(
                                                      padding: rowPadding,
                                                      child: Text(
                                                        "${oneDigitToTwo(timings['start'][0])}:${timings['start'][1] == 0 ? "00" : oneDigitToTwo(timings['start'][1])} ${timings['start'][2] == 0 ? "AM" : "PM"}",
                                                        style: tableRow,
                                                      ))),
                                              Center(
                                                  child: Padding(
                                                      padding: rowPadding,
                                                      child: Text(
                                                        "${oneDigitToTwo(timings['end'][0])}:${timings['end'][1] == 0 ? "00" : oneDigitToTwo(timings['end'][1])} ${timings['end'][2] == 0 ? "AM" : "PM"}",
                                                        style: tableRow,
                                                      )))
                                            ],
                                          );
                                        })),
                                Padding(padding: headingPadding)
                              ]);
                      }
                    }),
                  ),
                  Padding(padding: headingPadding),
                  Table(border: TableBorder.all(), children: [
                    TableRow(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      children: [
                        Padding(
                          padding: headingPadding,
                          child: Text(
                            "Approved By:",
                            style: tableHeader,
                          ),
                        ),
                        Padding(
                          padding: headingPadding,
                          child: Text(
                            "Ramesh Chand",
                            style: tableHeader,
                          ),
                        ),
                      ],
                    ),
                  ]),
                  Padding(padding: headingPadding),
                  footer,
                ],
              ),
            );
          }),
    );

    List actorCostumes = [];
    for (var c in scene.costumes) {
      var r = [];
      for (var d in c['costumes']) {
        Costume costume = Utils.costumesMap[d];
        r.add(await getImageBytes(costume.referenceImage));
      }
      actorCostumes.add(
          {"id": c['id'], "costumes_images": r, "costumes": c['costumes']});
    }

    pdf.addPage(
      Page(
          margin: const EdgeInsets.all(16),
          pageFormat: PdfPageFormat(595.2, double.infinity),
          build: (context) {
            return Container(
              child: Column(
                children: <Widget>[
                      Text("Costumes",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ] +
                    List.generate(actorCostumes.length, (i) {
                      Actor artist = Utils.artistsMap[actorCostumes[i]['id']];
                      var costumes = actorCostumes[i]['costumes'];
                      var costumesImages = actorCostumes[i]['costumes_images'];
                      return Padding(
                          padding: headingPadding,
                          child: Table(children: [
                            TableRow(
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                children: [
                                  Padding(
                                      padding: headingPadding,
                                      child: Text("${artist.names[language]}",
                                          style: tableHeader)),
                                ]),
                            TableRow(
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                children: List<Widget>.generate(
                                    costumesImages.length, (j) {
                                  Costume costume =
                                      Utils.costumesMap[costumes[j]];
                                  return Padding(
                                      padding: rowPadding,
                                      child: Column(children: [
                                        Image(
                                          MemoryImage(costumesImages[j]),
                                          width: 100,
                                          height: 100,
                                        ),
                                        Text('${costume.title}')
                                      ]));
                                })),
                          ]));
                    }) +
                    [
                      footer,
                    ],
              ),
            );
          }),
    );
    savePdf(schedule.id, pdf);
  }
  static makeupCallSheet(
      Project project,
      context,
      Scene scene,
      Schedule schedule,
      String date,
      String language,
      Set<Actor> artists) async {
    TextStyle labelStyle = TextStyle(fontSize: 12),
        valueStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        tableHeader = TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        tableRow = TextStyle(fontSize: 12);
    EdgeInsets headingPadding = const EdgeInsets.all(4),
        rowPadding = const EdgeInsets.all(2);
    var callSheetTimeStyle =
        TextStyle(fontWeight: FontWeight.bold, fontSize: 16);
    Document pdf = Document();
    Location location = Utils.locationsMap['${scene.location}'];
    Map<dynamic, dynamic> addlTimings = schedule.additionalTimings;
    DateTime now = DateTime.now();
    Widget footer =
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text("Cinemawala", style: TextStyle(fontSize: 10)),
      Text("Generated On ${now}", style: TextStyle(fontSize: 10))
    ]);

    pdf.addPage(
      Page(
          margin: const EdgeInsets.all(16),
          pageFormat: PdfPageFormat(595.2, double.infinity),
          build: (context) {
            return Container(
              child: Column(
                children: <Widget>[
                  sceneDetails(project, scene, schedule, date),
                  Padding(padding: const EdgeInsets.all(4)),
                  // Artists
                  Table(
                    border: TableBorder.all(),
                    children: <TableRow>[
                          TableRow(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              children: [
                                Padding(
                                  padding: headingPadding,
                                  child: Center(
                                    child: Text("Artists", style: tableHeader),
                                  ),
                                ),
                                Padding(
                                  padding: headingPadding,
                                  child: Center(
                                      child:
                                          Text("On Loc", style: tableHeader)),
                                ),
                                Padding(
                                  padding: headingPadding,
                                  child: Center(
                                      child:
                                          Text("On Set", style: tableHeader)),
                                ),
                              ]),
                        ] +
                        List<TableRow>.generate((artists.length), (i) {
                          Actor actor = artists.elementAt(i);
                          var timings =
                              schedule.artistTimings[scene.id][actor.id];
                          return TableRow(children: [
                            Center(
                              child: Padding(
                                padding: rowPadding,
                                child: Text("${actor.names["$language"]}",
                                    style: tableRow),
                              ),
                            ),
                            Center(
                              child: Padding(
                                  padding: rowPadding,
                                  child: Text(
                                      "${oneDigitToTwo(timings['start'][0])}:${timings['start'][1] == 0 ? "00" : oneDigitToTwo(timings['start'][1])} ${timings['start'][2] == 0 ? "AM" : "PM"}",
                                      style: tableRow)),
                            ),
                            Center(
                              child: Padding(
                                  padding: rowPadding,
                                  child: Text(
                                      "${oneDigitToTwo(timings['end'][0])}:${timings['end'][1] == 0 ? "00" : oneDigitToTwo(timings['end'][1])} ${timings['end'][2] == 0 ? "AM" : "PM"}",
                                      style: tableRow)),
                            ),
                          ]);
                        }),
                  ),
                  Padding(padding: const EdgeInsets.all(4)),
                  // Company Artists
                  Column(
                    children:
                        List<Widget>.generate(scene.addlArtists.length, (keyj) {
                      var key = Utils.addlKeys[keyj];
                      if (!Utils.additionalArtists[key]['addable']) {
                        var artist = {
                          "Name":
                              '$key (${scene.addlArtists[key][0]['Contact']})'
                        };
                        var timings = addlTimings[scene.id][key];
                        var value = scene.addlArtists[key][0];
                        return Column(children: [
                          Table(
                            border: TableBorder.all(),
                            children: [
                              TableRow(
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                children: [
                                  Padding(
                                    padding: headingPadding,
                                    child: Text(
                                      "${artist['Name']}",
                                      style: tableHeader,
                                    ),
                                  ),
                                  Padding(
                                    padding: headingPadding,
                                    child: Text(
                                      "${oneDigitToTwo(timings['start'][0])}:${timings['start'][1] == 0 ? "00" : oneDigitToTwo(timings['start'][1])} ${timings['start'][2] == 0 ? "AM" : "PM"}",
                                      style: tableHeader,
                                    ),
                                  ),
                                  Padding(
                                    padding: headingPadding,
                                    child: Text(
                                      "${oneDigitToTwo(timings['end'][0])}:${timings['end'][1] == 0 ? "00" : oneDigitToTwo(timings['end'][1])} ${timings['end'][2] == 0 ? "AM" : "PM"}",
                                      style: tableHeader,
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                          Table(
                            border: TableBorder.all(),
                            children: [
                              TableRow(
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                children: [
                                  Padding(
                                      padding: rowPadding,
                                      child: Text(
                                        "Males: ${value['Male']}\nFemales: ${value['Female']}\nKids: ${value['Kids']}",
                                        style: tableRow,
                                      )),
                                  Padding(
                                      padding: rowPadding,
                                      child: RichText(
                                        text: TextSpan(
                                          children: <TextSpan>[
                                            TextSpan(
                                                text: 'Note: ',
                                                style: labelStyle),
                                            TextSpan(
                                                text: '${value['Notes']}',
                                                style: tableRow),
                                          ],
                                        ),
                                      ))
                                ],
                              ),
                            ],
                          ),
                          Padding(padding: const EdgeInsets.all(4))
                        ]);
                      } else {
                        return scene.addlArtists['$key'].length == 0
                            ? Container()
                            : Column(children: [
                                Table(
                                    border: TableBorder.all(),
                                    children: [
                                          TableRow(
                                              verticalAlignment:
                                                  TableCellVerticalAlignment
                                                      .middle,
                                              children: [
                                                Padding(
                                                    padding: headingPadding,
                                                    child: Center(
                                                        child: Text(
                                                      "$key",
                                                      style: tableHeader,
                                                    ))),
                                                Padding(
                                                    padding: headingPadding,
                                                    child: Center(
                                                        child: Text(
                                                          "On Loc",
                                                      style: tableHeader,
                                                    ))),
                                                Padding(
                                                    padding: headingPadding,
                                                    child: Center(
                                                        child: Text(
                                                      "On Set",
                                                      style: tableHeader,
                                                    ))),
                                              ])
                                        ] +
                                        List<TableRow>.generate(
                                            scene.addlArtists['$key'].length,
                                            (ind) {
                                          var artist =
                                              scene.addlArtists['$key'][ind];
                                          var timings = addlTimings[scene.id]
                                              ["$key"][artist['id']];
                                          return TableRow(
                                            children: [
                                              Center(
                                                  child: Padding(
                                                      padding: rowPadding,
                                                      child: Text(
                                                        "${artist['Name']}",
                                                        style: tableRow,
                                                      ))),
                                              Center(
                                                  child: Padding(
                                                      padding: rowPadding,
                                                      child: Text(
                                                        "${oneDigitToTwo(timings['start'][0])}:${timings['start'][1] == 0 ? "00" : oneDigitToTwo(timings['start'][1])} ${timings['start'][2] == 0 ? "AM" : "PM"}",
                                                        style: tableRow,
                                                      ))),
                                              Center(
                                                  child: Padding(
                                                      padding: rowPadding,
                                                      child: Text(
                                                        "${oneDigitToTwo(timings['end'][0])}:${timings['end'][1] == 0 ? "00" : oneDigitToTwo(timings['end'][1])} ${timings['end'][2] == 0 ? "AM" : "PM"}",
                                                        style: tableRow,
                                                      )))
                                            ],
                                          );
                                        })),
                                Padding(padding: headingPadding)
                              ]);
                      }
                    }),
                  ),
                  Padding(padding: headingPadding),
                  Table(
                    border: TableBorder.all(),
                    children: [
                      TableRow(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        children: [
                          Padding(
                            padding: headingPadding,
                            child: Text(
                              "Hair and Make Up",
                              style: tableHeader,
                            ),
                          ),
                          Padding(
                            padding: rowPadding,
                            child: Text(
                              "${scene.makeUp}",
                              style: tableRow,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Padding(padding: headingPadding),
                  // Special Equipments & Hair and Make Up
                  Table(border: TableBorder.all(), children: [
                    TableRow(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      children: [
                        Padding(
                          padding: headingPadding,
                          child: Text(
                            "Approved By:",
                            style: tableHeader,
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      children: [
                        Padding(
                          padding: headingPadding,
                          child: Text(
                            "Ramesh Chand",
                            style: tableHeader,
                          ),
                        ),
                      ],
                    ),
                  ]),
                  Padding(padding: headingPadding),
                  footer,
                ],
              ),
            );
          }),
    );
    savePdf(schedule.id, pdf);
  }

  static propertiesCallSheet(
      Project project,
      context,
      Scene scene,
      Schedule schedule,
      String date,
      String language,
      Set<Actor> artists) async {
    TextStyle labelStyle = TextStyle(fontSize: 12),
        valueStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        tableHeader = TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        tableRow = TextStyle(fontSize: 12);
    EdgeInsets headingPadding = const EdgeInsets.all(4),
        rowPadding = const EdgeInsets.all(2);
    var callSheetTimeStyle =
        TextStyle(fontWeight: FontWeight.bold, fontSize: 16);
    Document pdf = Document();
    Location location = Utils.locationsMap['${scene.location}'];
    Map<dynamic, dynamic> addlTimings = schedule.additionalTimings;
    String propsNames = "";
    for (var p in scene.props) {
      propsNames += Utils.propsMap[p].title;
      if (p != scene.props.last) propsNames += ", ";
    }
    DateTime now = DateTime.now();
    Widget footer =
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text("Cinemawala", style: TextStyle(fontSize: 10)),
      Text("Generated On ${now}", style: TextStyle(fontSize: 10))
    ]);

    pdf.addPage(
      Page(
          margin: const EdgeInsets.all(16),
          pageFormat: PdfPageFormat(595.2, double.infinity),
          build: (context) {
            return Container(
              child: Column(
                children: <Widget>[
                  sceneDetails(project, scene, schedule, date),
                  Table(
                    //border: TableBorder.all(),
                    border: TableBorder(
                        left: BorderSide(color: PdfColors.black),
                        right: BorderSide(color: PdfColors.black),
                        bottom: BorderSide(color: PdfColors.black)),
                    children: [
                      TableRow(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          children: [
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: RichText(
                                  text: TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: 'Scene Title: ',
                                          style: labelStyle),
                                      TextSpan(
                                          text: '${scene.titles['$language']}',
                                          style: valueStyle),
                                    ],
                                  ),
                                )),
                          ]),
                    ],
                  ),
                  Table(
                    border: TableBorder(
                      left: BorderSide(color: PdfColors.black),
                      right: BorderSide(color: PdfColors.black),
                      bottom: BorderSide(color: PdfColors.black),
                    ),
                    children: [
                      TableRow(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: RichText(
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(text: 'Gist: ', style: labelStyle),
                                  TextSpan(
                                      text: '${scene.gists['$language']}',
                                      style: valueStyle),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Padding(padding: const EdgeInsets.all(4)),
                  //Special Equipments
                  Table(
                    border: TableBorder.all(),
                    children: [
                      TableRow(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        children: [
                          Padding(
                            padding: headingPadding,
                            child: Text(
                              "Special Equipments",
                              style: tableHeader,
                            ),
                          ),
                          Padding(
                            padding: rowPadding,
                            child: Text(
                              "${scene.specialEquipment}",
                              style: tableRow,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Padding(padding: headingPadding),
                  // Props
                  Table(
                    border: TableBorder.all(),
                    children: [
                      TableRow(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        children: [
                          Padding(
                            padding: headingPadding,
                            child: Text(
                              "Properties",
                              style: tableHeader,
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        children: [
                          Padding(
                            padding: rowPadding,
                            child: Text(
                              "$propsNames",
                              style: tableRow,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Padding(padding: headingPadding),
                  Table(border: TableBorder.all(), children: [
                    TableRow(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      children: [
                        Padding(
                          padding: headingPadding,
                          child: Text(
                            "Approved By:",
                            style: tableHeader,
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      children: [
                        Padding(
                          padding: headingPadding,
                          child: Text(
                            "Ramesh Chand",
                            style: tableHeader,
                          ),
                        ),
                      ],
                    ),
                  ]),
                  Padding(padding: headingPadding),
                  footer,
                ],
              ),
            );
          }),
    );
    List propsImages = [];
    for (var c in scene.props) {
      Prop prop = Utils.propsMap[c];
      propsImages.add({
        "image": await getImageBytes(prop.referenceImage),
        "title": prop.title
      });
    }
    pdf.addPage(
      Page(
          margin: const EdgeInsets.all(16),
          pageFormat: PdfPageFormat(595.2, double.infinity),
          orientation: PageOrientation.portrait,
          build: (context) {
            return Container(
              child: Column(
                children: <Widget>[
                  Text("Properties",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  Wrap(
                      children: List.generate(
                          propsImages.length,
                          (i) => Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(children: [
                                Image(
                                  MemoryImage(propsImages[i]['image']),
                                  width: 100,
                                  height: 100,
                                ),
                                Text('${propsImages[i]['title']}')
                              ])))),
                  SizedBox(height: 16),
                  footer,
                ],
              ),
            );
          }),
    );
    savePdf(schedule.id, pdf);
  }

  static String oneDigitToTwo(int i) {
    if (i == 0) {
      return "12";
    }
    if (i > 9) {
      return "$i";
    } else {
      return "0$i";
    }
  }
}
