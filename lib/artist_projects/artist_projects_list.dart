import 'package:cinemawala/projects/project.dart';
import 'package:cinemawala/projects/project_card.dart';
import 'package:flutter/cupertino.dart';

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
    loading = true;
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
    return allProjects.length > 0
        ? SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Text(
                      "Casted In",
                      style: TextStyle(
                        fontSize: 20,
                        color: const Color(0xff309f86),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Flexible(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(allProjects.length, (i) {
                          project = allProjects[i];
                          return ProjectCard(
                            project: project,
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
                ),
              ],
            ),
          )
        : Center(
            child: Text(loading ? '' : 'No Projects.'),
          );
  }

  @override
  bool get wantKeepAlive => true;
}
