import 'package:cinemawala/projects/project.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

class SelectUser extends StatefulWidget {
  final Project project;
  final Map selectedUser;
  final bool showSelf;

  SelectUser(
      {Key key,
      @required this.project,
      @required this.selectedUser,
      this.showSelf})
      : super(key: key);

  @override
  _SelectUser createState() =>
      _SelectUser(this.project, this.selectedUser, this.showSelf ?? false);
}

class _SelectUser extends State<SelectUser>
    with SingleTickerProviderStateMixin {
  Color background, background1, color;
  final Project project;
  List<dynamic> users = [];
  Map selectedUser;
  bool loading = false;
  final bool showSelf;

  TextEditingController search_controller = new TextEditingController();
  String search = '';

  _SelectUser(this.project, this.selectedUser, this.showSelf);

  @override
  void initState() {
    setUsers();
    super.initState();
  }

  setUsers() async {
    users = Utils.users ?? [];
    if (users.length == 0) {
      setState(() {
        loading = true;
      });
      users = await Utils.getUserNames(context, Utils.user.id);
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var showUsers = users
        .where((c) =>
            ((c['username'].contains(search) || c['name'].contains(search)) &&
                (c['user_id'] == Utils.USER_ID ? showSelf : true)))
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
              margin: EdgeInsets.symmetric(vertical: 48, horizontal: 24),
              constraints: BoxConstraints(maxWidth: Utils.mobileWidth),
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
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
                        "Select User",
                        style: TextStyle(fontSize: 20, color: background1),
                        textAlign: TextAlign.left,
                      ),
                      Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(context, selectedUser);
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextField(
                      controller: search_controller,
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
                                search_controller.text = '';
                                search = '';
                              });
                            },
                            child: Icon(
                              Icons.clear,
                              color: search == '' ? Colors.white : Colors.black,
                              size: 16,
                            ),
                          ),
                          labelStyle: TextStyle(color: Colors.black),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 8),
                          labelText: 'Search User',
                          prefixIcon: Icon(Icons.search),
                          fillColor: Colors.white),
                    ),
                  ),
                  if (loading) LinearProgressIndicator(),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                              Divider(
                                height: 0,
                                color: Colors.black,
                                thickness: 1,
                              )
                            ] +
                            List<Widget>.generate(showUsers.length, (i) {
                              Map user = showUsers[i];
                              return InkWell(
                                splashColor: background1.withOpacity(0.2),
                                onTap: () {
                                  Navigator.pop(context, user);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 8),
                                  decoration: BoxDecoration(
                                      color: background,
                                      border: Border(bottom: BorderSide())),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("${user['name']}",
                                          style: TextStyle(
                                              color: background1,
                                              fontSize: 14)),
                                      Text("@ ${user['username']}",
                                          style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 12)),
                                    ],
                                  ),
                                ),
                              );
                            }),
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
