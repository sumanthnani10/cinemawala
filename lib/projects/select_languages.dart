import 'dart:math';

import 'package:flutter/material.dart';

import '../utils.dart';

class SelectLanguages extends StatefulWidget {
  final List<dynamic> selectedLanguages;

  SelectLanguages({Key key, this.selectedLanguages}) : super(key: key);

  @override
  _SelectLanguages createState() => _SelectLanguages(this.selectedLanguages);
}

class _SelectLanguages extends State<SelectLanguages>
    with SingleTickerProviderStateMixin {
  Color background, background1, color;
  List<dynamic> languages = [], selectedLanguages;

  _SelectLanguages(this.selectedLanguages);

  ScrollController scrollController = new ScrollController();
  int viewItems = 12;

  @override
  void initState() {
    languages = Utils.codeToLanguagesInEnglish.keys.toList();
    scrollController.addListener(() {
      if (scrollController.offset >=
              scrollController.position.maxScrollExtent &&
          !scrollController.position.outOfRange) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          viewItems += 12;
          setState(() {});
        });
      }
    });
    super.initState();
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
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: Colors.black26,
        body: Center(
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 48, horizontal: 24),
              constraints: BoxConstraints(maxWidth: 480),
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
              height: MediaQuery.of(context).size.height - (48 * 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
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
                        "Languages",
                        style: TextStyle(fontSize: 20, color: background1),
                        textAlign: TextAlign.center,
                      ),
                      Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(context, selectedLanguages);
                        },
                        label: Text(
                          "Done",
                          style: TextStyle(color: Colors.indigo),
                          textAlign: TextAlign.right,
                        ),
                        icon: Icon(
                          Icons.done,
                          size: 18,
                          color: Colors.indigo,
                        ),
                      ),
                    ],
                  ),
                  Flexible(
                    child:
                        NotificationListener<OverscrollIndicatorNotification>(
                      onNotification: (overScroll) {
                        overScroll.disallowGlow();
                        return;
                      },
                      child: Scrollbar(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                            child: Wrap(
                              direction: Axis.horizontal,
                              children: <Widget>[
                                    ListTile(
                                      selected: true,
                                      title: Text(
                                          "${Utils.codeToLanguagesInLanguage[selectedLanguages[0]]}"),
                                      subtitle: Text(
                                          "${Utils.codeToLanguagesInEnglish[selectedLanguages[0]]}"),
                                    )
                                  ] +
                                  List<Widget>.generate(
                                      min<int>(viewItems, languages.length - 1),
                                      (i) {
                                    return ListTile(
                                      selected: selectedLanguages
                                          .contains(languages[i + 1]),
                                      title: Text(
                                          "${Utils.codeToLanguagesInLanguage[languages[i + 1]]}"),
                                      subtitle: Text(
                                          "${Utils.codeToLanguagesInEnglish[languages[i + 1]]}"),
                                      onTap: () {
                                        setState(() {
                                          if (!selectedLanguages
                                              .contains(languages[i + 1])) {
                                            selectedLanguages
                                                .add(languages[i + 1]);
                                          } else {
                                            selectedLanguages
                                                .remove(languages[i + 1]);
                                          }
                                        });
                                      },
                                      selectedTileColor:
                                          Colors.yellowAccent.withOpacity(0.5),
                                    );
                                  }),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
/*

class SelectedActors extends StatefulWidget {
  final Project project;
  final List<Actor> selectedArtists;
  final bool isPopUp;
  SelectedActors(
      {Key key, @required this.project, @required this.selectedArtists,this.isPopUp})
      : super(key: key);

  @override
  _SelectedActors createState() =>
      _SelectedActors(this.project, this.selectedArtists,this.isPopUp);
}

class _SelectedActors extends State<SelectedActors>
    with SingleTickerProviderStateMixin {
  final Project project;
  bool isPopUp;
  Color background, background1, color;
  final List<Actor> selectedArtists;
  TextEditingController searchController = new TextEditingController();
  String search = '';

  _SelectedActors(this.project, this.selectedArtists,this.isPopUp);

  @override
  void initState() {
    isPopUp = isPopUp ?? true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var selectedLanguages = selectedArtists
        .where((e) =>
            e.names.toString().toLowerCase().contains(search.toLowerCase()))
        .toList();
    */
/*selectedLanguages.sort((a,b) {
      int x, y;
      x = count.contains(a)?1:0;
      y = count.contains(b)?1:0;
      return y-x;
    });*/ /*

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
        backgroundColor: isPopUp ? Colors.black26 : Colors.white,
        body: Container(
          decoration: BoxDecoration(border: Border(left:BorderSide(color: Colors.black))),
          child: Center(
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Container(
                margin: EdgeInsets.symmetric(vertical: isPopUp ? 48 : 8, horizontal: isPopUp ? 24 : 4),
                constraints: BoxConstraints(maxWidth: 480),
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                height: MediaQuery.of(context).size.height - (48 * 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        isPopUp ? IconButton(
                            icon: Icon(Icons.arrow_back_rounded),
                            onPressed: () {
                              Navigator.pop(context);
                            }):Container(),
                        Text(
                          "Selected Artists",
                          style: TextStyle(fontSize: 20, color: background1),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    TextField(
                      controller: searchController,
                      maxLines: 1,
                      textInputAction: TextInputAction.search,
                      onChanged: (s) {},
                      onSubmitted: (v) {
                        setState(() {
                          search = v;
                        });
                      },
                      decoration: InputDecoration(
                          suffixIcon: InkWell(
                            onTap: () {
                              setState(() {
                                searchController.text = '';
                                search = '';
                              });
                            },
                            child: Icon(
                              Icons.clear,
                              color: search == '' ? Colors.white : Colors.black,
                              size: 16,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.black)),
                          labelStyle: TextStyle(color: Colors.black),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 8),
                          labelText: 'Search Artist',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.black)),
                          fillColor: Colors.white),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                          child: Wrap(
                            direction: Axis.horizontal,
                            children:
                                */
/*<Widget>[InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => AddActor(project: project,),));
                              },
                              splashColor: background1.withOpacity(0.2),
                              child: Container(
                                //color: color,
                                margin: EdgeInsets.all(2),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(300),
                                ),
                                child: Text('+ Add Artist'),
                              ),
                            )]+*/ /*

                                List<Widget>.generate(selectedLanguages.length,
                                    (i) {
                              Actor actor = selectedLanguages[i];
                              // print("actor :: ${actor.names},${selectedLanguages[i].names['en']},${selectedLanguages[i].names['en']}");
                              return InkWell(
                                onLongPress: () {
                                  Navigator.push(
                                      context,
                                      Utils.createRoute(
                                          ActorPopUp(
                                            actor: actor,
                                            project: project,
                                          ),
                                          Utils.DTU));
                                },
                                splashColor: background1.withOpacity(0.2),
                                child: Container(
                                  //color: color,
                                  margin: EdgeInsets.all(2),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(300),
                                  ),
                                  child: selectedLanguages[i].names['en']!=null ?
                                      Text('${selectedLanguages[i].names['en']}') : Text('${selectedLanguages[i].names['en']}'),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
*/
