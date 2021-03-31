import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cinemawala/locations/location.dart';
import 'package:cinemawala/props/prop.dart';
import 'package:cinemawala/scenes/scene.dart';
import 'package:cinemawala/schedule/schedule.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

import 'casting/actor.dart';
import 'costumes/costume.dart';
import 'projects/project.dart';
import 'utils.dart';

class PdfGenerator {
  static Map<String, dynamic> actorCostumes;
  static List<dynamic> actorsList,
      actorsList1,
      adltimings,
      sceneIds,
      costumeIds,
      properties,
      adltimings1,
      adtArtists1,
      actorEndTime,
      actorStartTime,
      gangMem,
      juniorsStartTime,
      juniorsEndTime,
      modelsStartTime,
      modelsEndtime,
      dancersStartTime,
      dancersEndTime;
  static Map<String, dynamic> artistCostumes = {};
  static Map<String, dynamic> sceneCostumes = {};
  static String splEquipment, makeup, vfx, specialFx;
  static Map<String, dynamic> mainmap = {
    "vfx_timings": {
      "scene_Owbkqeo0": {
        "start": [9, 30, 0],
        "end": [11, 30, 1]
      }
    },
    "addl_timings": {
      "scene_Owbkqeo0": {
        "Dancers/Fighters": {
          "start": [8, 40, 0],
          "end": [7, 0, 1]
        },
        "Models": {
          "start": [10, 55, 0],
          "end": [11, 0, 1]
        },
        "Juniors": {
          "start": [7, 35, 0],
          "end": [8, 30, 1]
        },
        "additional_artists": {
          "addi_OwYdbEIE": {
            "end": [4, 30, 1],
            "start": [0, 30, 0]
          }
        },
        "Gang Members": {
          "gang_OwYdbOWX": {
            "end": [0, 0, 1],
            "start": [5, 15, 0]
          },
          "gang_OwYdbkGJ": {
            "end": [0, 0, 1],
            "start": [11, 0, 0]
          }
        }
      }
    },
    "last_edit_on": 1616948833987,
    "last_edit_by": "kjfvnok",
    "call_timings": {
      "scene_Owbkqeo0": {
        "start": [8, 10, 0],
        "end": [10, 30, 1]
      }
    },
    "id": "20210328",
    "project_id": "jBVRGq",
    "created": 1616948833987,
    "scenes": ["scene_Owbkqeo0"],
    "sfx_timings": {
      "scene_Owbkqeo0": {
        "start": [7, 45, 0],
        "end": [11, 55, 1]
      }
    },
    "month": 3,
    "day": 28,
    "year": 2021,
    "added_by": "kjfvnok",
    "artist_timings": {
      "scene_Owbkqeo0": {
        "actor1": {
          "end": [9, 0, 1],
          "start": [8, 0, 0]
        }
      }
    }
  };

  static artistimages() async {
    List<String> imageCheck = [];
    int i, j;
    List<dynamic> imageL = [];
    for (int i = 0; i < actorsList1.length; i++) {
      artistCostumes[actorsList1[i]] = new Map();
      Actor actor = Utils.artistsMap[actorsList1[i]];
      costumeIds = actor.costumes[adltimings[0]];
      print(costumeIds.length);
      print(imageCheck.length);
      for (int k = 0; k < costumeIds.length; k++) {
        Costume costume = Utils.costumesMap[costumeIds[k]];
        imageCheck.add(costume.referenceImage);
        print(imageCheck.length);
      }
      print(imageCheck);
      print(imageCheck.length);
      for (j = 0; j < imageCheck.length; j++) {
        Uint8List response =
            (await NetworkAssetBundle(Uri.parse("${imageCheck[j]}"))
                    .load("${imageCheck[j]}"))
                .buffer
                .asUint8List();
        await imageL.add(response);
      }
      imageCheck = [];
      print(imageCheck.length);
      print(imageL.length);
      for (j = 0; j < imageL.length; j++) {
        await assignmap(i, j, imageL[j]);
      }
      imageL = [];
    }
  }

  static assignmap(int i, int j, dynamic c) async {
    artistCostumes[actorsList1[i]]["Costume${j}"] = c;
  }

  static List<dynamic> imageLink = [];

  static checkmainmap() async {
    print(mainmap.keys);
  }

  static Future<List> templatech() async {
    actorCostumes = {
      'actorName1': {
        'costume1': '',
        'costume2': '',
        'costume3': '',
        'costume4': '',
        'costume5': '',
      },
      'actorName2': {
        'costume1': '',
        'costume2': '',
        'costume3': '',
        'costume4': '',
        'costume5': '',
      },
      'actorName3': {
        'costume1': '',
        'costume2': '',
        'costume3': '',
        'costume4': '',
        'costume5': '',
      },
    };
    List<String> imageCheck = [
      "https://images.unsplash.com/photo-1503023345310-bd7c1de61c7d?ixid=MXwxMjA3fDB8MHxzZWFyY2h8MXx8aHVtYW58ZW58MHx8MHw%3D&ixlib=rb-1.2.1&w=1000&q=80",
      "https://image.shutterstock.com/image-photo/mountains-under-mist-morning-amazing-260nw-1725825019.jpg",
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRCTa4_S-VJYKdOcNJgiGklVfsP1-T12Xv0mGnb0zYEArexNJp3VXX2BgAtA5fadkjjGN8&usqp=CAU",
      "https://e2k9ube.cloudimg.io/s/cdn/x/https://edienet.s3.amazonaws.com/news/images/full_40419.jpg?v=15/06/2020%2016:52:00",
      "https://previews.123rf.com/images/alexkalina/alexkalina1507/alexkalina150700087/43561132-nature-green-forest-with-sun-and-sunlight.jpg",
    ];
    for (int i = 0; i < imageCheck.length; i++) {
      Uint8List response =
          (await NetworkAssetBundle(Uri.parse("${imageCheck[i]}"))
                  .load("${imageCheck[i]}"))
              .buffer
              .asUint8List();
      print(response);
      await imageLink.add(response);
    }
    return imageLink;
  }

  static Future<Uint8List> getImageBytes(String link) async {
    Uint8List response =
        (await NetworkAssetBundle(Uri.parse("${link}")).load("${link}"))
            .buffer
            .asUint8List();
    return response;
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
        tableRow = TextStyle(fontSize: 12);
    EdgeInsets headingPadding = const EdgeInsets.all(4),
        rowPadding = const EdgeInsets.all(2);
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
                  Table(
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
                                        TextSpan(
                                            text: 'Date: ', style: labelStyle),
                                        TextSpan(
                                            text: '${date}', style: valueStyle),
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
                                          TextSpan(
                                              text: 'Working Day: ',
                                              style: labelStyle),
                                          TextSpan(
                                              text: '${10}', style: valueStyle),
                                        ],
                                      ),
                                    )),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Text("Project Name: ${project.name}"),
                            ),
                            Divider(
                              height: 1,
                              color: PdfColors.black,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Text("Director"),
                            ),
                            Divider(
                                  height: 1,
                                  color: PdfColors.black,
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  child: Text("D.O.P"),
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
                                      TextSpan(
                                          text: 'Location: ',
                                          style: labelStyle),
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
                                          style: valueStyle),
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
                                          style: valueStyle),
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
                                                '${scene.interior ? "Interior" : "Exterior"}/${scene.day ? "Day\n" : "Night\n"}',
                                            style: valueStyle),
                                      ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ]),
                    ],
                  ),
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
                                          Text("On Shoot", style: tableHeader)),
                                ),
                            Padding(
                              padding: headingPadding,
                              child: Center(
                                  child: Text("On Set", style: tableHeader)),
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
                                      "${artist['Name']}: From ${oneDigitToTwo(timings['start'][0])}:${timings['start'][1] == 0 ? "00" : oneDigitToTwo(timings['start'][1])} ${timings['start'][2] == 0 ? "AM" : "PM"} to ${oneDigitToTwo(timings['end'][0])}:${timings['end'][1] == 0 ? "00" : oneDigitToTwo(timings['end'][1])} ${timings['end'][2] == 0 ? "AM" : "PM"}",
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
                                                  "From",
                                                  style: tableHeader,
                                                ))),
                                            Padding(
                                                padding: headingPadding,
                                                child: Center(
                                                    child: Text(
                                                  "To",
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
                  Table(
                    border: TableBorder.all(),
                    children: [
                      TableRow(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        children: [
                          Padding(
                            padding: headingPadding,
                            child: Text(
                              "VFX: From ${oneDigitToTwo(vfxTimings['start'][0])}:${vfxTimings['start'][1] == 0 ? "00" : oneDigitToTwo(vfxTimings['start'][1])} ${vfxTimings['start'][2] == 0 ? "AM" : "PM"} to ${oneDigitToTwo(vfxTimings['end'][0])}:${vfxTimings['end'][1] == 0 ? "00" : oneDigitToTwo(vfxTimings['end'][1])} ${vfxTimings['end'][2] == 0 ? "AM" : "PM"}",
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
                              "${scene.vfx}",
                              style: tableRow,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Padding(padding: headingPadding),
                  // SFX
                  Table(
                    border: TableBorder.all(),
                    children: [
                      TableRow(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        children: [
                          Padding(
                            padding: headingPadding,
                            child: Text(
                              "SFX: From ${oneDigitToTwo(sfxTimings['start'][0])}:${sfxTimings['start'][1] == 0 ? "00" : oneDigitToTwo(sfxTimings['start'][1])} ${sfxTimings['start'][2] == 0 ? "AM" : "PM"} to ${oneDigitToTwo(sfxTimings['end'][0])}:${sfxTimings['end'][1] == 0 ? "00" : oneDigitToTwo(sfxTimings['end'][1])} ${sfxTimings['end'][2] == 0 ? "AM" : "PM"}",
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
                              "${scene.sfx}",
                              style: tableRow,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Padding(padding: headingPadding),
                  // Special Equipments & Hair and Make Up
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

    Directory documentDirectory = await path.getExternalStorageDirectory();
    String documentPath = documentDirectory.path;
    // print(documentPath);
    // File file = File("$documentPath/${schedule.id}_${now.millisecondsSinceEpoch}.pdf");
    File file = File("$documentPath/${schedule.id}.pdf");
    file.writeAsBytesSync(await pdf.save());
    return;
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
