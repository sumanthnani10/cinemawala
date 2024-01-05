import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils.dart';

class AddCompanyArtists extends StatefulWidget {
  final additionalArtists;

  AddCompanyArtists({Key key, @required this.additionalArtists})
      : super(key: key);

  @override
  _AddCompanyArtists createState() =>
      _AddCompanyArtists(this.additionalArtists);
}

class _AddCompanyArtists extends State<AddCompanyArtists>
    with SingleTickerProviderStateMixin {
  Color background, background1, color;

  List<TextEditingController> textFieldControllers = [];
  Map<dynamic, dynamic> additionalArtists;

  var categoryHeadingStyle =
      TextStyle(fontSize: 18, fontWeight: FontWeight.bold);

  var fieldStyle = TextStyle(fontSize: 16);

  _AddCompanyArtists(this.additionalArtists);

  void initState() {
    super.initState();
    if (additionalArtists == null) {
      additionalArtists = Utils.additionalArtists;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> categories = additionalArtists.keys.toList();
    textFieldControllers.clear();
    background = Colors.white;
    color = Color(0xff6fd8a8);
    if (background == Colors.white) {
      background1 = Colors.black;
    } else {
      background1 = Colors.white;
    }
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: Colors.black26,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              margin: EdgeInsets.symmetric(vertical: 48, horizontal: 24),
              constraints: BoxConstraints(maxWidth: Utils.mobileWidth),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                        icon: Icon(Icons.arrow_back_rounded),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                    Text(
                      "Additional Artists",
                      style: TextStyle(
                          fontSize: 12,
                          color: background1,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    Spacer(),
                    Material(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context, additionalArtists);
                        },
                        splashColor: background1.withOpacity(0.2),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Save",
                            style: TextStyle(color: Colors.indigo),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Flexible(
                    child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children:
                        List<Widget>.generate(additionalArtists.length, (i) {
                          Map<dynamic, dynamic> category =
                          additionalArtists[categories[i]];
                      List<String> fields = category['fields'].keys.toList();
                      return Container(
                        width: MediaQuery.of(context).size.width - (24 * 2),
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${categories[i]}",
                                        style: categoryHeadingStyle,
                                      ),
                                      if (category['addable'])
                                        InkWell(
                                            onTap: () {
                                              var map = {};
                                              category["fields"].forEach(
                                                  (k, v) => map[k] = v);
                                              map['id'] = Utils.generateId(
                                                  "${categories[i].toLowerCase().substring(0, 4)}_");
                                              setState(() {
                                                additionalArtists[
                                                            '${categories[i]}']
                                                        ['field_values']
                                                    .add(map);
                                              });
                                            },
                                            child: Icon(
                                              Icons.add_circle_outline,
                                              size: 26,
                                            )),
                                    ],
                                  ),
                                ] +
                                List<Widget>.generate(
                                    category['field_values'].length, (k) {
                                  return Container(
                                    decoration: BoxDecoration(
                                        border: Border(
                                      bottom: BorderSide(
                                        color: background1,
                                      ),
                                    )),
                                    child: Column(
                                        children: <Widget>[
                                              if (category['addable'])
                                                const SizedBox(
                                                  height: 2,
                                                ),
                                              if (category['addable'])
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                        "${categories[i]} ${k + 1}"),
                                                    Material(
                                                      color: background,
                                                      child: InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            additionalArtists[
                                                                        '${categories[i]}']
                                                                    [
                                                                    'field_values']
                                                                .removeAt(k);
                                                          });
                                                        },
                                                        splashColor: background1
                                                            .withOpacity(0.2),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(2),
                                                          child: Text(
                                                            "- Remove",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .indigo),
                                                            textAlign:
                                                                TextAlign.right,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                )
                                            ] +
                                            List<Widget>.generate(fields.length,
                                                (j) {
                                              var field =
                                                  category['field_values'][k]
                                                      ['${fields[j]}'];
                                              if (fields[j] == "id")
                                                return Container();
                                              textFieldControllers.add(
                                                  new TextEditingController(
                                                      //text: '$field'
                                                      text: field==0 ? '' : '${field}'

                                                  )
                                              );
                                              if (field.runtimeType == int) {
                                                return Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 8),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Flexible(
                                                          child: Text(
                                                              "${fields[j]}",
                                                              style:
                                                                  fieldStyle)),
                                                      Flexible(
                                                        child: TextField(
                                                          textCapitalization:
                                                              TextCapitalization
                                                                  .words,
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          controller: textFieldControllers.last,
                                                          textInputAction:
                                                              TextInputAction
                                                                  .next,
                                                          inputFormatters: [
                                                            FilteringTextInputFormatter
                                                                .allow(RegExp(
                                                                    '[0-9]')),
                                                          ],
                                                          onChanged: (v) {
                                                            if (v.isNotEmpty) {
                                                              additionalArtists[
                                                                              '${categories[i]}']
                                                                          ['field_values'][k]
                                                                      ['${fields[j]}'] =
                                                                  int.parse(v);
                                                            } else {
                                                              additionalArtists[
                                                                          '${categories[i]}']
                                                                      ['field_values'][k]
                                                                  ['${fields[j]}'] = 0;
                                                            }
                                                          },
                                                          textAlign:
                                                              TextAlign.center,
                                                          decoration:
                                                              InputDecoration(
                                                            enabledBorder:
                                                                OutlineInputBorder(
                                                                    borderSide:
                                                                        BorderSide(
                                                                            color:
                                                                                background1)),
                                                            contentPadding:
                                                                EdgeInsets.all(
                                                                    8),
                                                            border:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              } else {
                                                return Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 8.0),
                                                  child: TextField(
                                                    textCapitalization:
                                                        TextCapitalization
                                                            .words,
                                                    controller:
                                                        textFieldControllers
                                                            .last,
                                                    textInputAction:
                                                        TextInputAction.done,
                                                    onChanged: (v) {
                                                      additionalArtists[
                                                                  '${categories[i]}']
                                                              [
                                                              'field_values'][k]
                                                          ['${fields[j]}'] = v;
                                                    },
                                                    decoration: InputDecoration(
                                                      enabledBorder: OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color:
                                                                  background1)
                                                          //borderSide: const BorderSide(color: Colors.white)
                                                          ),
                                                      labelText: '${fields[j]}',
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
                                                );
                                              }
                                            })),
                                  );
                                })),
                      );
                    }),
                  ),
                ))
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class ViewCompanyArtists extends StatefulWidget {
  final additionalArtists;

  ViewCompanyArtists({Key key, @required this.additionalArtists})
      : super(key: key);

  @override
  _ViewCompanyArtists createState() =>
      _ViewCompanyArtists(this.additionalArtists);
}

class _ViewCompanyArtists extends State<ViewCompanyArtists>
    with SingleTickerProviderStateMixin {
  Color background, background1, color;

  List<TextEditingController> textFieldControllers = [];
  Map<dynamic, dynamic> additionalArtists;

  var categoryHeadingStyle =
      TextStyle(fontSize: 18, fontWeight: FontWeight.bold);

  var fieldStyle = TextStyle(fontSize: 16);

  _ViewCompanyArtists(this.additionalArtists);

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<String> categories = additionalArtists.keys.toList();
    textFieldControllers = [];
    background = Colors.white;
    color = Color(0xff6fd8a8);
    if (background == Colors.white) {
      background1 = Colors.black;
    } else {
      background1 = Colors.white;
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: Colors.black26,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              margin: EdgeInsets.symmetric(vertical: 48, horizontal: 24),
              constraints: BoxConstraints(maxWidth: Utils.mobileWidth),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                        icon: Icon(Icons.arrow_back_rounded),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                    Text(
                      "Additional Artists",
                      style: TextStyle(
                          fontSize: 14,
                          color: background1,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                Flexible(
                    child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children:
                        List<Widget>.generate(additionalArtists.length, (i) {
                          Map<dynamic, dynamic> category =
                          additionalArtists[categories[i]];
                      List<String> fields = category['fields'].keys.toList();
                      return Container(
                        width: MediaQuery.of(context).size.width - (24 * 2),
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "${categories[i]}",
                                      style: categoryHeadingStyle,
                                    ),
                                  ),
                                ] +
                                (category['field_values'].length == 0
                                    ? <Widget>[Text('\n No ${categories[i]}')]
                                    : List<Widget>.generate(
                                        category['field_values'].length, (k) {
                                        return Container(
                                          decoration: BoxDecoration(
                                              border: Border(
                                            bottom: BorderSide(
                                              color: background1,
                                            ),
                                          )),
                                          child: Column(
                                              children: <Widget>[
                                                    if (category['addable'])
                                                      const SizedBox(
                                                        height: 2,
                                                      ),
                                                    if (category['addable'])
                                                      Text(
                                                          "${categories[i]} ${k + 1}")
                                                  ] +
                                                  List<Widget>.generate(
                                                      fields.length, (j) {
                                                    var field =
                                                        category['field_values']
                                                            [k]['${fields[j]}'];

                                                    if (fields[j] == "id") {
                                                      return Container();
                                                    }

                                                    textFieldControllers.add(
                                                        new TextEditingController(
                                                            text:
                                                                '${field == "" ? " -" : field}'));

                                                    if (field.runtimeType ==
                                                        int) {
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 8),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Flexible(
                                                                child: Text(
                                                                    "${fields[j]}",
                                                                    style:
                                                                        fieldStyle)),
                                                            Flexible(
                                                              child:
                                                                  TextFormField(
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                controller:
                                                                    textFieldControllers
                                                                        .last,
                                                                textInputAction:
                                                                    TextInputAction
                                                                        .next,
                                                                inputFormatters: [
                                                                  FilteringTextInputFormatter
                                                                      .allow(RegExp('[0-9]')),
                                                  ],
                                                  textAlign: TextAlign.center,
                                                  decoration: InputDecoration(
                                                    enabled: false,
                                                    disabledBorder:
                                                        OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                                color:
                                                                    background)),
                                                    contentPadding:
                                                        EdgeInsets.all(8),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      } else {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: TextField(
                                            textCapitalization:
                                                              TextCapitalization
                                                                  .words,
                                                          controller:
                                                              textFieldControllers
                                                                  .last,
                                                          textInputAction:
                                                              TextInputAction
                                                                  .done,
                                                          decoration:
                                                              InputDecoration(
                                                            enabled: false,
                                                            disabledBorder:
                                                                OutlineInputBorder(
                                                                    borderSide:
                                                                        BorderSide(
                                                                            color:
                                                                                background)),
                                                            labelText:
                                                                '${fields[j]}',
                                                            labelStyle: TextStyle(
                                                                color:
                                                                    background1,
                                                                fontSize: 14),
                                                            contentPadding:
                                                                EdgeInsets.all(
                                                                    8),
                                                            border:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  })),
                                        );
                                      }))),
                      );
                    }),
                  ),
                ))
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

/*
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Models",
                              style: categoryHeadingStyle,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            margin: const EdgeInsets.all(16.0),
                            child: Text("Male", style: fieldStyle),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 2 - 54,
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            child: TextField(
                                                          textCapitalization: TextCapitalization.words,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: background1)
                                    //borderSide: const BorderSide(color: Colors.white)
                                    ),
                                //labelText: '0',
                                hintText: '0',
                                labelStyle:
                                    TextStyle(color: background1, fontSize: 14),
                                contentPadding: EdgeInsets.all(8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            margin: const EdgeInsets.all(16.0),
                            child: Text(
                              "Female",
                              style: fieldStyle,
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 2 - 54,
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            child: TextField(
                                                          textCapitalization: TextCapitalization.words,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: background1)
                                    //borderSide: const BorderSide(color: Colors.white)
                                    ),
                                //labelText: '0',
                                hintText: '0',
                                labelStyle:
                                    TextStyle(color: background1, fontSize: 14),
                                contentPadding: EdgeInsets.all(8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            margin: const EdgeInsets.all(16.0),
                            child: Text(
                              "Kids",
                              style: fieldStyle,
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 2 - 54,
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            child: TextField(
                                                          textCapitalization: TextCapitalization.words,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: background1)
                                    //borderSide: const BorderSide(color: Colors.white)
                                    ),
                                //labelText: '0',
                                hintText: '0',
                                labelStyle:
                                    TextStyle(color: background1, fontSize: 14),
                                contentPadding: EdgeInsets.all(8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        child: TextField(
                                                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: background1)
                                //borderSide: const BorderSide(color: Colors.white)
                                ),
                            labelText: '*Note',
                            labelStyle:
                                TextStyle(color: background1, fontSize: 14),
                            contentPadding: EdgeInsets.all(8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Gang Members", style: categoryHeadingStyle),
                            InkWell(
                                onTap: () {
                                  // debugPrint(
                                      "add another column with name and contact");
                                },
                                child: Icon(
                                  Icons.add_circle_outline,
                                  size: 26,
                                )),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        child: TextField(
                                                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: background1)
                                //borderSide: const BorderSide(color: Colors.white)
                                ),
                            labelText: 'Name',
                            labelStyle:
                                TextStyle(color: background1, fontSize: 14),
                            contentPadding: EdgeInsets.all(8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        child: TextField(
                                                          textCapitalization: TextCapitalization.words,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: background1)
                                //borderSide: const BorderSide(color: Colors.white)
                                ),
                            labelText: 'Contact Number',
                            prefixIcon: Padding(
                                padding: EdgeInsets.all(16),
                                child: Text("+91")),
                            labelStyle:
                                TextStyle(color: background1, fontSize: 14),
                            contentPadding: EdgeInsets.all(8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),*/
