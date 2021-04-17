import 'package:cinemawala/projects/project.dart';
import 'package:cinemawala/props/add_prop.dart';
import 'package:cinemawala/props/prop.dart';
import 'package:cinemawala/props/prop_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../utils.dart';

class SelectProps extends StatefulWidget {
  final Project project;
  final List<Prop> selectedProps;

  const SelectProps(
      {Key key, @required this.project, @required this.selectedProps})
      : super(key: key);

  @override
  _SelectProps createState() => _SelectProps(project, selectedProps);
}

class _SelectProps extends State<SelectProps> {
  final Project project;
  Color background, background1, color;
  List<Prop> props = [], selectedProps;
  ScrollController cardScrollController = new ScrollController();

  TextEditingController searchController = new TextEditingController();
  String search = '';

  _SelectProps(this.project, this.selectedProps);

  @override
  void initState() {
    props = Utils.props.sublist(0).toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var showProps = props
        .where((e) =>
            e.title.toString().toLowerCase().contains(search.toLowerCase()))
        .toList();
    showProps.sort((a, b) {
      int x, y;
      x = selectedProps.contains(a) ? 1 : 0;
      y = selectedProps.contains(b) ? 1 : 0;
      return y - x;
    });
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
                      IconButton(
                          icon: Icon(Icons.arrow_back_rounded),
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                      Text(
                        "Properties",
                        style: TextStyle(fontSize: 20, color: background1),
                        textAlign: TextAlign.center,
                      ),
                      Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          List<dynamic> selected = [];
                          for (Prop a in selectedProps) {
                            selected.add(a.id);
                          }
                          Navigator.pop(context, [selected, selectedProps]);
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
                  TextField(
                    controller: searchController,
                    maxLines: 1,
                    textInputAction: TextInputAction.search,
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
                        labelText: 'Search Property',
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
                          children: <Widget>[
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AddProp(
                                            project: project,
                                          ),
                                        ));
                                  },
                                  splashColor: background1.withOpacity(0.2),
                                  child: Container(
                                    margin: EdgeInsets.all(2),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(300),
                                    ),
                                    child: Text('+ Add Prop'),
                                  ),
                                )
                              ] +
                              List<Widget>.generate(showProps.length, (i) {
                                Prop prop = props[i];
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (selectedProps
                                          .contains(showProps[i])) {
                                        selectedProps.remove(showProps[i]);
                                      } else {
                                        selectedProps.add(showProps[i]);
                                      }
                                    });
                                  },
                                  onLongPress: () {
                                    Navigator.push(
                                        context,
                                        Utils.createRoute(
                                            PropPage(
                                              project: project,
                                              prop: prop,
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
                                      color:
                                          selectedProps.contains(showProps[i])
                                              ? color
                                              : color.withOpacity(8 / 16),
                                      borderRadius: BorderRadius.circular(300),
                                    ),
                                    child: Text('${showProps[i].title}'),
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
    );
  }
}

class SelectedProps extends StatefulWidget {
  final Project project;
  final List<Prop> selectedProps;
  final bool isPopUp;
  SelectedProps({Key key, @required this.project, @required this.selectedProps,this.isPopUp})
      : super(key: key);

  @override
  _SelectedProps createState() =>
      _SelectedProps(this.project, this.selectedProps,this.isPopUp);
}

class _SelectedProps extends State<SelectedProps>
    with SingleTickerProviderStateMixin {
  final Project project;
  bool isPopUp;
  Color background, background1, color;
  final List<Prop> selectedProps;
  TextEditingController searchController = new TextEditingController();
  String search = '';

  _SelectedProps(this.project, this.selectedProps,this.isPopUp);
  @override
  void initState() {
    isPopUp = isPopUp ?? true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var showProps = selectedProps
        .where((e) =>
            e.title.toString().toLowerCase().contains(search.toLowerCase()))
        .toList();
    background = Colors.white;
    color = Color(0xff6fd8a8);
    if (background == Colors.white) {
      background1 = Colors.black;
    } else {
      background1 = Colors.white;
    }
    return GestureDetector(
      onTap: () {
        if(isPopUp){
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: isPopUp ? Colors.black26 : Colors.white,
        body: Center(
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 48, horizontal: 24),
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
                        "Selected Props",
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
                        labelText: 'Search Prop',
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
                              List<Widget>.generate(showProps.length, (i) {
                            Prop prop = showProps[i];
                            return InkWell(
                              onLongPress: () async {
                                await Navigator.push(
                                    context,
                                    Utils.createRoute(
                                        PropPage(
                                          prop: prop,
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
                                child: Text('${prop.title}'),
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
    );
  }
}
