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
              constraints: BoxConstraints(maxWidth: Utils.mobileWidth),
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
