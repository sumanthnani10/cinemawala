import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinemawala/daily_budget/daily_budgets.dart';
import 'package:cinemawala/projects/projects_list.dart';
import 'package:cinemawala/props/props_list.dart';
import 'package:cinemawala/scenes/scenes_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'casting/actors_list.dart';
import 'costumes/costumes_list.dart';
import 'projects/project.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await Firebase.initializeApp();
  }
  if (!kIsWeb) {
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: 'test@gmail.com', password: 'test1234');
    }
  }
  runApp(Cinemawala());
}

class Cinemawala extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cinemawala',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ProjectsList(),
    );
  }
}

class Home extends StatefulWidget {
  Home({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Project project;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Home'),
        ),
        body: GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 0.9,
          children: [
            InkWell(
              child: Container(
                margin: EdgeInsets.all(8.0),
                child: Material(
                  color: Colors.white,
                  elevation: 18.0,
                  borderRadius: BorderRadius.circular(20.0),
                  shadowColor: Color(0x802196F3),
                  child: Column(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height / 4 - 18,
                        width: MediaQuery.of(context).size.width,
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.0),
                              topRight: Radius.circular(20.0)),
                          child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              progressIndicatorBuilder:
                                  (context, url, progress) =>
                                      CircularProgressIndicator(
                                        value: progress.progress,
                                      ),
                              errorWidget: (context, url, error) => Center(
                                      child: Text(
                                    'Image',
                                    style: const TextStyle(color: Colors.grey),
                                  )),
                              useOldImageOnUrlChange: true,
                              imageUrl:
                                  "https://i.pinimg.com/474x/20/62/69/20626905851e066e66764c3385fa4352.jpg"),
                        ),
                      ),
                      Flexible(
                          flex: 2,
                          child: Center(
                              child: Text(
                            "Casting",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                fontSize: 18),
                          ))),
                    ],
                  ),
                ),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ActorsList(
                              project: project,
                            )));
              },
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CostumesList(
                              project: project,
                            )));
              },
              child: Container(
                margin: EdgeInsets.all(8.0),
                child: Material(
                  color: Colors.white,
                  elevation: 18.0,
                  borderRadius: BorderRadius.circular(20.0),
                  shadowColor: Color(0x802196F3),
                  child: Column(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height / 4 - 18,
                        width: MediaQuery.of(context).size.width,
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.0),
                              topRight: Radius.circular(20.0)),
                          child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              progressIndicatorBuilder:
                                  (context, url, progress) =>
                                      CircularProgressIndicator(
                                        value: progress.progress,
                                      ),
                              errorWidget: (context, url, error) => Center(
                                      child: Text(
                                    'Image',
                                    style: const TextStyle(color: Colors.grey),
                                  )),
                              useOldImageOnUrlChange: true,
                              imageUrl:
                                  "https://www.spacesworks.com/wp-content/uploads/2017/10/Opposuits_836x474.png"),
                        ),
                      ),
                      Flexible(
                          flex: 2,
                          child: Center(
                              child: Text(
                            "Costumes",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                fontSize: 18),
                          ))),
                    ],
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => PropsList()));
              },
              child: Container(
                margin: EdgeInsets.all(8.0),
                child: Material(
                  color: Colors.white,
                  elevation: 18.0,
                  borderRadius: BorderRadius.circular(20.0),
                  shadowColor: Color(0x802196F3),
                  child: Column(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height / 4 - 18,
                        width: MediaQuery.of(context).size.width,
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.0),
                              topRight: Radius.circular(20.0)),
                          child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              progressIndicatorBuilder:
                                  (context, url, progress) =>
                                      CircularProgressIndicator(
                                        value: progress.progress,
                                      ),
                              errorWidget: (context, url, error) => Center(
                                      child: Text(
                                    'Image',
                                    style: const TextStyle(color: Colors.grey),
                                  )),
                              useOldImageOnUrlChange: true,
                              imageUrl:
                                  "https://kenningtonfilmstudios.com/wp-content/uploads/2014/11/IMG_0026.jpg"),
                        ),
                      ),
                      Flexible(
                          flex: 2,
                          child: Center(
                              child: Text(
                            "Art department",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                fontSize: 18),
                          ))),
                    ],
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ScenesList()));
              },
              child: Container(
                margin: EdgeInsets.all(8.0),
                child: Material(
                  color: Colors.white,
                  elevation: 18.0,
                  borderRadius: BorderRadius.circular(20.0),
                  shadowColor: Color(0x802196F3),
                  child: Column(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height / 4 - 18,
                        width: MediaQuery.of(context).size.width,
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.0),
                              topRight: Radius.circular(20.0)),
                          child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              progressIndicatorBuilder:
                                  (context, url, progress) =>
                                      CircularProgressIndicator(
                                        value: progress.progress,
                                      ),
                              errorWidget: (context, url, error) => Center(
                                      child: Text(
                                    'Image',
                                    style: const TextStyle(color: Colors.grey),
                                  )),
                              useOldImageOnUrlChange: true,
                              imageUrl:
                                  "https://images.jdmagicbox.com/quickquotes/images_main/clapper_board_clapboard_slate_for_tv_film_movie_white_black_high_quality_black_and_white_acryl_16269540_0.jpg"),
                        ),
                      ),
                      Flexible(
                          flex: 2,
                          child: Center(
                              child: Text(
                            "One line order",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                fontSize: 18),
                          ))),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(8.0),
              child: Material(
                color: Colors.white,
                elevation: 18.0,
                borderRadius: BorderRadius.circular(20.0),
                shadowColor: Color(0x802196F3),
                child: Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height / 4 - 18,
                      width: MediaQuery.of(context).size.width,
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.0),
                            topRight: Radius.circular(20.0)),
                        child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            progressIndicatorBuilder:
                                (context, url, progress) =>
                                    CircularProgressIndicator(
                                      value: progress.progress,
                                    ),
                            errorWidget: (context, url, error) => Center(
                                    child: Text(
                                  'Image',
                                  style: const TextStyle(color: Colors.grey),
                                )),
                            useOldImageOnUrlChange: true,
                            imageUrl:
                                "https://t4.ftcdn.net/jpg/02/99/36/67/360_F_299366773_uhiw0oGo6pdtp4M1JhnNEWMhHRtyPfz9.jpg"),
                      ),
                    ),
                    Flexible(
                        flex: 2,
                        child: Center(
                            child: Text(
                          "Roles",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              fontSize: 18),
                        ))),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(8.0),
              child: Material(
                color: Colors.white,
                elevation: 18.0,
                borderRadius: BorderRadius.circular(20.0),
                shadowColor: Color(0x802196F3),
                child: Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height / 4 - 18,
                      width: MediaQuery.of(context).size.width,
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.0),
                            topRight: Radius.circular(20.0)),
                        child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            progressIndicatorBuilder:
                                (context, url, progress) =>
                                    CircularProgressIndicator(
                                      value: progress.progress,
                                    ),
                            errorWidget: (context, url, error) => Center(
                                    child: Text(
                                  'Image',
                                  style: const TextStyle(color: Colors.grey),
                                )),
                            useOldImageOnUrlChange: true,
                            imageUrl:
                                "https://d3timt52sxdbq0.cloudfront.net/wp-content/uploads/2016/05/projectschedulemanagement.jpg"),
                      ),
                    ),
                    Flexible(
                        flex: 2,
                        child: Center(
                            child: Text(
                          "Schedule",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              fontSize: 18),
                        ))),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(8.0),
              child: Material(
                color: Colors.white,
                elevation: 18.0,
                borderRadius: BorderRadius.circular(20.0),
                shadowColor: Color(0x802196F3),
                child: Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height / 4 - 18,
                      width: MediaQuery.of(context).size.width,
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.0),
                            topRight: Radius.circular(20.0)),
                        child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            progressIndicatorBuilder:
                                (context, url, progress) =>
                                    CircularProgressIndicator(
                                      value: progress.progress,
                                    ),
                            errorWidget: (context, url, error) => Center(
                                    child: Text(
                                  'Image',
                                  style: const TextStyle(color: Colors.grey),
                                )),
                            useOldImageOnUrlChange: true,
                            imageUrl:
                                "https://www.lifewire.com/thmb/10fONV_vt8G_xccyGmGCjiog0_U=/1105x1105/smart/filters:no_upscale()/Maplocation_-5a492a4e482c52003601ea25.jpg"),
                      ),
                    ),
                    Flexible(
                        flex: 2,
                        child: Center(
                            child: Text(
                          "Location",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              fontSize: 18),
                        ))),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(8.0),
              child: Material(
                color: Colors.white,
                elevation: 18.0,
                borderRadius: BorderRadius.circular(20.0),
                shadowColor: Color(0x802196F3),
                child: Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height / 4 - 18,
                      width: MediaQuery.of(context).size.width,
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.0),
                            topRight: Radius.circular(20.0)),
                        child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            progressIndicatorBuilder:
                                (context, url, progress) =>
                                    CircularProgressIndicator(
                                      value: progress.progress,
                                    ),
                            errorWidget: (context, url, error) => Center(
                                    child: Text(
                                  'Image',
                                  style: const TextStyle(color: Colors.grey),
                                )),
                            useOldImageOnUrlChange: true,
                            imageUrl:
                                "https://media.istockphoto.com/vectors/daily-report-or-planning-icon-concept-vector-id1072319670"),
                      ),
                    ),
                    Flexible(
                        flex: 2,
                        child: Center(
                            child: Text(
                          "Daily Report",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              fontSize: 18),
                        ))),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DailyBudgets(
                              project: project,
                            )));
              },
              child: Container(
                margin: EdgeInsets.all(8.0),
                child: Material(
                  color: Colors.white,
                  elevation: 18.0,
                  borderRadius: BorderRadius.circular(20.0),
                  shadowColor: Color(0x802196F3),
                  child: Column(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height / 4 - 18,
                        width: MediaQuery.of(context).size.width,
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.0),
                              topRight: Radius.circular(20.0)),
                          child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              progressIndicatorBuilder:
                                  (context, url, progress) =>
                                      CircularProgressIndicator(
                                        value: progress.progress,
                                      ),
                              errorWidget: (context, url, error) => Center(
                                      child: Text(
                                    'Image',
                                    style: const TextStyle(color: Colors.grey),
                                  )),
                              useOldImageOnUrlChange: true,
                              imageUrl:
                                  "https://thumbs.dreamstime.com/b/financial-budget-recession-report-accounting-business-planning-economic-d-background-finance-marketing-195035692.jpg"),
                        ),
                      ),
                      Flexible(
                          flex: 2,
                          child: Center(
                              child: Text(
                            "Daily Budget",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                fontSize: 18),
                          ))),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(8.0),
              child: Material(
                color: Colors.white,
                elevation: 18.0,
                borderRadius: BorderRadius.circular(20.0),
                shadowColor: Color(0x802196F3),
                child: Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height / 4 - 18,
                      width: MediaQuery.of(context).size.width,
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.0),
                            topRight: Radius.circular(20.0)),
                        child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            progressIndicatorBuilder:
                                (context, url, progress) =>
                                    CircularProgressIndicator(
                                      value: progress.progress,
                                    ),
                            errorWidget: (context, url, error) => Center(
                                    child: Text(
                                  'Image',
                                  style: const TextStyle(color: Colors.grey),
                                )),
                            useOldImageOnUrlChange: true,
                            imageUrl:
                                "https://thumbs.dreamstime.com/b/financial-budget-recession-report-accounting-business-planning-economic-d-background-finance-marketing-195035692.jpg"),
                      ),
                    ),
                    Flexible(
                        flex: 2,
                        child: Center(
                            child: Text(
                          "Continuity",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              fontSize: 18),
                        ))),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
