import 'dart:convert';

import 'package:cinemawala/projects/project.dart';
import 'package:cinemawala/projects/project_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';

import '../utils.dart';
import 'artist_project_page.dart';

class ArtistProjects extends StatefulWidget {
  final List<Project> artistProjects;

  const ArtistProjects({Key key, @required this.artistProjects})
      : super(key: key);

  @override
  _ArtistProjectsState createState() =>
      _ArtistProjectsState(this.artistProjects ?? []);
}

class _ArtistProjectsState extends State<ArtistProjects> {
  Color background, color, background1;
  List<Project> allProjects, requestProjects = [];
  bool loading = false;
  Project project;

  _ArtistProjectsState(this.allProjects);

  @override
  void initState() {
    loading = false;
    super.initState();
  }

  getArtistProject(Project proj) async {
    loading = true;
    Utils.showLoadingDialog(context, 'Getting ${proj.name}');
    Utils.artistProject = await Utils.getArtistProject(context, proj.id);
    Navigator.pop(context);
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Casted In",
                  style: TextStyle(
                    fontSize: 20,
                    color: const Color(0xff309f86),
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.left,
                ),
                TextButton(
                    onPressed: () async {
                      generateCode();
                    },
                    child: Text("Codes"))
              ],
            ),
          ),
          allProjects.length > 0
              ? Flexible(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(allProjects.length, (i) {
                          project = allProjects[i];
                          return ProjectCard(
                            project: project,
                            artist: true,
                            onTap: () async {
                              Project proj = allProjects[i];
                              if (Utils.artistProject == null ||
                                  Utils.artistProject.project.id != proj.id) {
                                await getArtistProject(proj);

                                Utils.languages = [];
                                Utils.langsInLang = [];

                                proj.languages.forEach((l) {
                                  Utils.languages
                                .add(Utils.codeToLanguagesInEnglish[l]);
                            Utils.langsInLang
                                .add(Utils.codeToLanguagesInLanguage[l]);
                          });
                        }

                        Navigator.push(
                            context,
                            Utils.createRoute(
                                      ArtistProjectPage(
                                        artistProject: Utils.artistProject,
                                      ),
                                      Utils.RTL));
                            },
                          );
                        }),
                      ),
                    ),
                  ),
                )
              : Text(loading ? '' : 'No Projects.'),
        ],
      ),
    );
  }

  generateCode() async {
    Utils.showLoadingDialog(context, "Generating Code");
    String code = "";

    try {
      var resp = await http.post(Utils.GENERATE_CAST_CODE,
          body: jsonEncode({
            "user_id": Utils.USER_ID,
          }),
          headers: {"Content-Type": "application/json"});
      // debugPrint(resp.body);
      var r = jsonDecode(resp.body);
      Navigator.pop(context);
      if (resp.statusCode == 200) {
        if (r['status'] == 'success') {
          code = r['code'];
          if (code.length != 10) {
            await Utils.showErrorDialog(
                context, 'Something went wrong.', '${r['msg'] ?? "Try Again"}');
          } else {
            showCodeShareDialog(code);
          }
        } else {
          await Utils.showErrorDialog(
              context, 'Something went wrong.', '${r['msg']}');
        }
      } else {
        await Utils.showErrorDialog(context, 'Something went wrong.',
            'Please try again after sometime.');
      }
      setState(() {
        loading = false;
      });
    } catch (e) {
      debugPrint("$e");
      Navigator.pop(context);
      await Utils.showErrorDialog(
          context, 'Something went wrong.', 'Please try again after sometime.');
    }
  }

  showCodeShareDialog(String code) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("$code"),
                    IconButton(
                        icon: Icon(Icons.copy_rounded),
                        onPressed: () async {
                          Clipboard.setData(ClipboardData(text: "$code"));
                        })
                  ],
                ),
              ),
              SizedBox(
                height: 4,
              ),
              Text(
                  "This code is valid only for 7 days and can only be used once.",
                  style: TextStyle(fontSize: 10))
            ],
          ),
          actions: [
            TextButton.icon(
                onPressed: () async {
                  await Share.share(
                      "Cinemawala \nAdd Me As Cast Using This: \n \nUsername: ${Utils.user.username} \nCode: $code");
                },
                icon: Icon(Icons.share),
                label: Text("Share"))
          ],
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
