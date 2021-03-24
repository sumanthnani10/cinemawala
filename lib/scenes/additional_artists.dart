import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  Map<String, dynamic> additionalArtists;

  var categoryHeadingStyle =
      TextStyle(fontSize: 18, fontWeight: FontWeight.bold);

  var subCategoryStyle = TextStyle(fontSize: 16);

  _AddCompanyArtists(this.additionalArtists);

  void initState() {
    super.initState();
    if (additionalArtists == null) {
      additionalArtists = {
        'Juniors': {
          'field_values': [
            {
              'Male': 0,
              'Female': 0,
              'Kids': 0,
              'Notes': '',
            }
          ],
          'fields': {
            'Male': 0,
            'Female': 0,
            'Kids': 0,
            'Notes': '',
          },
          'addable': false
        },
        'Models': {
          'field_values': [
            {
              'Male': 0,
              'Female': 0,
              'Kids': 0,
              'Notes': '',
            }
          ],
          'fields': {
            'Male': 0,
            'Female': 0,
            'Kids': 0,
            'Notes': '',
          },
          'addable': false
        },
        'Gang Members': {
          'field_values': [
            {
              'Name': '',
              'Contact': '',
            }
          ],
          'fields': {
            'Name': '',
            'Contact': '',
          },
          'addable': true
        },
        'Additional Artists': {
          'field_values': [
            {
              'Name': '',
              'Contact': '',
            }
          ],
          'fields': {
            'Name': '',
            'Contact': '',
          },
          'addable': true
        },
      };
    }
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
                      "Company/Additional Artists",
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
                      Map<String, dynamic> category =
                          additionalArtists[categories[i]];
                      List<String> subCategories =
                          category['fields'].keys.toList();
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
                                              setState(() {
                                                additionalArtists[
                                                            '${categories[i]}']
                                                        ['field_values']
                                                    .add(category['fields']);
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
                                        children: List<Widget>.generate(
                                                subCategories.length, (j) {
                                              var subCategory =
                                                  category['field_values'][k]
                                                      ['${subCategories[j]}'];

                                              textFieldControllers.add(
                                                  new TextEditingController(
                                                      text: '$subCategory'));

                                              if (subCategory.runtimeType ==
                                                  int) {
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
                                                              "${subCategories[j]}",
                                                              style:
                                                                  subCategoryStyle)),
                                                      Flexible(
                                                        child: TextFormField(
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
                                                                .allow(RegExp(
                                                                    '[0-9]')),
                                                          ],
                                                          onChanged: (v) {
                                                            if (v.isNotEmpty) {
                                                              additionalArtists[
                                                                              '${categories[i]}']
                                                                          [
                                                                          'field_values'][k]
                                                                      [
                                                                      '${subCategories[j]}'] =
                                                                  int.parse(v);
                                                            } else {
                                                              additionalArtists[
                                                                          '${categories[i]}']
                                                                      [
                                                                      'field_values'][k]
                                                                  [
                                                                  '${subCategories[j]}'] = 0;
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
                                                          [
                                                          '${subCategories[j]}'] = v;
                                                    },
                                                    decoration: InputDecoration(
                                                      enabledBorder: OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color:
                                                                  background1)
                                                          //borderSide: const BorderSide(color: Colors.white)
                                                          ),
                                                      labelText:
                                                          '${subCategories[j]}',
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
                                            }) +
                                            <Widget>[
                                              if (k != 0)
                                                Material(
                                                  color: background,
                                                  child: InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        additionalArtists[
                                                                    '${categories[i]}']
                                                                ['field_values']
                                                            .removeAt(k);
                                                      });
                                                    },
                                                    splashColor: background1
                                                        .withOpacity(0.2),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2),
                                                      child: Text(
                                                        "- Remove",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.indigo),
                                                        textAlign:
                                                            TextAlign.right,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                            ]),
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
  Map<String, dynamic> additionalArtists;

  var categoryHeadingStyle =
      TextStyle(fontSize: 18, fontWeight: FontWeight.bold);

  var subCategoryStyle = TextStyle(fontSize: 16);

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
                      "Company/Additional Artists",
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
                      Map<String, dynamic> category =
                          additionalArtists[categories[i]];
                      List<String> subCategories =
                          category['fields'].keys.toList();
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
                                        children: List<Widget>.generate(
                                            subCategories.length, (j) {
                                      var subCategory = category['field_values']
                                          [k]['${subCategories[j]}'];

                                      textFieldControllers.add(
                                          new TextEditingController(
                                              text:
                                                  '${subCategory == "" ? " -" : subCategory}'));

                                      if (subCategory.runtimeType == int) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                  child: Text(
                                                      "${subCategories[j]}",
                                                      style: subCategoryStyle)),
                                              Flexible(
                                                child: TextFormField(
                                                  keyboardType:
                                                      TextInputType.number,
                                                  controller:
                                                      textFieldControllers.last,
                                                  textInputAction:
                                                      TextInputAction.next,
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
                                            controller:
                                                textFieldControllers.last,
                                            textInputAction:
                                                TextInputAction.done,
                                            decoration: InputDecoration(
                                              enabled: false,
                                              disabledBorder:
                                                  OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: background)),
                                              labelText: '${subCategories[j]}',
                                              labelStyle: TextStyle(
                                                  color: background1,
                                                  fontSize: 14),
                                              contentPadding: EdgeInsets.all(8),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
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
                            child: Text("Male", style: subCategoryStyle),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 2 - 54,
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            child: TextField(
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
                              style: subCategoryStyle,
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 2 - 54,
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            child: TextField(
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
                              style: subCategoryStyle,
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 2 - 54,
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            child: TextField(
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
