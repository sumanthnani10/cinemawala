import 'dart:convert';

import 'package:cinemawala/casting/actor.dart';
import 'package:cinemawala/costumes/costume.dart';
import 'package:cinemawala/locations/location.dart';
import 'package:cinemawala/projects/project.dart';
import 'package:cinemawala/scenes/scene.dart';
import 'package:cinemawala/schedule/schedule.dart';
import 'package:cinemawala/user/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'daily_budget/daily_budget.dart';
import 'props/prop.dart';
class Utils {
  static String USER_ID;
  static User user;
  static List<Actor> artists;
  static List<Costume> costumes;
  static List<Prop> props;
  static List<Location> locations;
  static List<Scene> scenes;
  static List<Schedule> schedules;
  static List<DailyBudget> dailyBudgets;
  static Map<String, Actor> artistsMap;
  static Map<String, Costume> costumesMap;
  static Map<String, Prop> propsMap;
  static Map<String, Location> locationsMap;
  static Map<String, Scene> scenesMap;
  static Map<String, Schedule> schedulesMap;
  static Map<String, DailyBudget> dailyBudgetsMap;

/*--------------------------------------------GET CATEGORIES---------------------------------------------------*/

  static getUser(context, userId) async {
    var resp = await http.post(Utils.GET_USER, body: {"id": "${userId}"});
    // debugPrint(resp.body);
    if (resp.statusCode == 200) {
      var r = jsonDecode(resp.body);
      if (r['status'] == 'success') {
        // print(r['user']);
        user = User.fromJson(r['user']);
        USER_ID = user.id;
        return user;
      } else {
        showErrorDialog(context, '', '${r['msg']}');
      }
    } else {
      showErrorDialog(context, '', 'Something went Wrong. Please try again');
    }
    return null;
  }

  static getProject(context, projectId) async {
    var resp = await http.post(Utils.GET_PROJECT,
        body: {"project_id": "${projectId}", "user_id": "${Utils.USER_ID}"});
    // debugPrint(resp.body);
    if (resp.statusCode == 200) {
      var r = jsonDecode(resp.body);
      if (r['status'] == 'success') {
        // print(r['project']);
        return Project.fromJson(r['project']);
      } else {
        showErrorDialog(context, '', '${r['msg']}');
      }
    } else {
      showErrorDialog(context, '', 'Something went Wrong. Please try again');
    }
    return null;
  }

  static getArtists(context, projectId) async {
    var resp = await http.post(Utils.GET_ARTISTS,
        body: {"project_id": "${projectId}", "user_id": "${Utils.USER_ID}"});
    // debugPrint(resp.body);
    if (resp.statusCode == 200) {
      var r = jsonDecode(resp.body);
      if (r['status'] == 'success') {
        Utils.artists = [];
        Utils.artistsMap = {};
        r['actors'].forEach((i) {
          Utils.artists.add(Actor.fromJson(i));
          Utils.artistsMap[Utils.artists.last.id] = Utils.artists.last;
        });
      } else {
        showErrorDialog(context, '', '${r['msg']}');
      }
    } else {
      showErrorDialog(context, '', 'Something went Wrong. Please try again');
    }
    return Utils.artists;
  }

  static getCostumes(context, projectId) async {
    var resp = await http.post(Utils.GET_COSTUMES,
        body: {"project_id": "${projectId}", "user_id": "${Utils.USER_ID}"});
    // debugPrint(resp.body);
    if (resp.statusCode == 200) {
      var r = jsonDecode(resp.body);
      if (r['status'] == 'success') {
        Utils.costumes = [];
        Utils.costumesMap = {};
        r['costumes'].forEach((i) {
          costumes.add(Costume.fromJson(i));
          costumesMap[Utils.costumes.last.id] = Utils.costumes.last;
        });
      } else {
        showErrorDialog(context, '', '${r['msg']}');
      }
    } else {
      showErrorDialog(context, '', 'Something went Wrong. Please try again');
    }
    return Utils.costumes;
  }

  static getProps(context, projectId) async {
    var resp = await http.post(Utils.GET_PROPS,
        body: {"project_id": "${projectId}", "user_id": "${Utils.USER_ID}"});
    // debugPrint(resp.body);
    if (resp.statusCode == 200) {
      var r = jsonDecode(resp.body);
      if (r['status'] == 'success') {
        Utils.props = [];
        Utils.propsMap = {};
        r['props'].forEach((i) {
          Utils.props.add(Prop.fromJson(i));
          Utils.propsMap[Utils.props.last.id] = Utils.props.last;
        });
      } else {
        showErrorDialog(context, '', '${r['msg']}');
      }
    } else {
      showErrorDialog(context, '', 'Something went Wrong. Please try again');
    }
    return Utils.props;
  }

  static getLocations(context, projectId) async {
    var resp = await http.post(Utils.GET_LOCATIONS,
        body: {"project_id": "${projectId}", "user_id": "${Utils.USER_ID}"});
    // debugPrint(resp.body);
    if (resp.statusCode == 200) {
      var r = jsonDecode(resp.body);
      if (r['status'] == 'success') {
        Utils.locations = [];
        Utils.locationsMap = {};
        r['locations'].forEach((i) {
          Utils.locations.add(Location.fromJson(i));
          Utils.locationsMap[Utils.locations.last.id] = Utils.locations.last;
        });
      } else {
        showErrorDialog(context, '', '${r['msg']}');
      }
    } else {
      showErrorDialog(context, '', 'Something went Wrong. Please try again');
    }
    return Utils.locations;
  }

  static getScenes(context, projectId) async {
    var resp = await http.post(Utils.GET_SCENES,
        body: {"project_id": "${projectId}", "user_id": "${Utils.USER_ID}"});
    // debugPrint(resp.body);
    if (resp.statusCode == 200) {
      var r = jsonDecode(resp.body);
      // print(r);
      if (r['status'] == 'success') {
        Utils.scenes = [];
        Utils.scenesMap = {};
        r['scenes'].forEach((i) {
          Utils.scenes.add(Scene.fromJson(i));
          Utils.scenesMap[Utils.scenes.last.id] = Utils.scenes.last;
        });
      } else {
        showErrorDialog(context, '', '${r['msg']}');
      }
    } else {
      showErrorDialog(context, '', 'Something went Wrong. Please try again');
    }
    return Utils.scenes;
  }

  static getSchedules(context, projectId) async {
    var resp = await http.post(Utils.GET_SCHEDULES,
        body: {"project_id": "${projectId}", "user_id": "${Utils.USER_ID}"});
    // debugPrint(resp.body);
    if (resp.statusCode == 200) {
      var r = jsonDecode(resp.body);
      // print(r);
      if (r['status'] == 'success') {
        Utils.schedules = [];
        Utils.schedulesMap = {};
        r['schedules'].forEach((i) {
          Utils.schedules.add(Schedule.fromJson(i));
          Utils.schedulesMap[Utils.schedules.last.id] = Utils.schedules.last;
        });
      } else {
        showErrorDialog(context, '', '${r['msg']}');
      }
    } else {
      showErrorDialog(context, '', 'Something went Wrong. Please try again');
    }
    return Utils.schedules;
  }

  static getDailyBudgets(context, projectId) async {
    var resp = await http.post(Utils.GET_DAILY_BUDGETS,
        body: {"project_id": "${projectId}", "user_id": "${Utils.USER_ID}"});
    // debugPrint(resp.body);
    if (resp.statusCode == 200) {
      var r = jsonDecode(resp.body);
      // print(r);
      if (r['status'] == 'success') {
        Utils.dailyBudgets = [];
        Utils.dailyBudgetsMap = {};
        r['daily_budgets'].forEach((i) {
          Utils.dailyBudgets.add(DailyBudget.fromJson(i));
          Utils.dailyBudgetsMap[Utils.dailyBudgets.last.id] =
              Utils.dailyBudgets.last;
        });
      } else {
        showErrorDialog(context, '', '${r['msg']}');
      }
    } else {
      showErrorDialog(context, '', 'Something went Wrong. Please try again');
    }
    return Utils.schedules;
  }

/*-------------------------------------------------------------------------------------------------------------*/

/*-------------------------------------------------LINKS-------------------------------------------------------*/

  // static const String DOMAIN = "10.0.2.2:5001";
  // static const String URL_PATH = "/cinemawala-2021b/us-central1/cinemawala";

  static const String DOMAIN =
      "us-central1-cinemawala-2021b.cloudfunctions.net";
  static const String URL_PATH = "/cinemawala";

  static Uri GET_USER = Uri.https('${DOMAIN}', '${URL_PATH}/getUser');
  static Uri ADD_USER = Uri.https('${DOMAIN}', '${URL_PATH}/addUser');
  static Uri VALIDATE_USERNAME =
      Uri.https('${DOMAIN}', '${URL_PATH}/validateUsername');

  static Uri GET_PROJECTS = Uri.https('${DOMAIN}', '${URL_PATH}/getProjects');
  static Uri GET_PROJECT = Uri.https('${DOMAIN}', '${URL_PATH}/getProject');
  static Uri ADD_PROJECT = Uri.https('${DOMAIN}', '${URL_PATH}/addProject');

  static Uri GET_ARTISTS = Uri.https('${DOMAIN}', '${URL_PATH}/getArtists');
  static Uri ADD_ARTIST = Uri.https('${DOMAIN}', '${URL_PATH}/addArtist');
  static Uri EDIT_ARTIST = Uri.https('${DOMAIN}', '${URL_PATH}/editArtist');
  static Uri UPLOAD_ARTIST_IMAGE =
      Uri.https('${DOMAIN}', '${URL_PATH}/uploadArtistImage');

  static Uri GET_COSTUMES = Uri.https('${DOMAIN}', '${URL_PATH}/getCostumes');
  static Uri ADD_COSTUME = Uri.https('${DOMAIN}', '${URL_PATH}/addCostume');
  static Uri EDIT_COSTUME = Uri.https('${DOMAIN}', '${URL_PATH}/editCostume');

  static Uri GET_PROPS = Uri.https('${DOMAIN}', '${URL_PATH}/getProps');
  static Uri ADD_PROP = Uri.https('${DOMAIN}', '${URL_PATH}/addProp');
  static Uri EDIT_PROP = Uri.https('${DOMAIN}', '${URL_PATH}/editProp');

  static Uri GET_LOCATIONS = Uri.https('${DOMAIN}', '${URL_PATH}/getLocations');
  static Uri ADD_LOCATION = Uri.https('${DOMAIN}', '${URL_PATH}/addLocation');
  static Uri EDIT_LOCATION = Uri.https('${DOMAIN}', '${URL_PATH}/editLocation');

  static Uri GET_SCENES = Uri.https('${DOMAIN}', '${URL_PATH}/getScenes');
  static Uri ADD_SCENE = Uri.https('${DOMAIN}', '${URL_PATH}/addScene');
  static Uri EDIT_SCENE = Uri.https('${DOMAIN}', '${URL_PATH}/editScene');

  static Uri GET_SCHEDULES = Uri.https('${DOMAIN}', '${URL_PATH}/getSchedules');
  static Uri ADD_SCHEDULE = Uri.https('${DOMAIN}', '${URL_PATH}/addSchedule');
  static Uri EDIT_SCHEDULE = Uri.https('${DOMAIN}', '${URL_PATH}/editSchedule');

  static Uri GET_DAILY_BUDGETS =
      Uri.https('${DOMAIN}', '${URL_PATH}/getDailyBudgets');
  static Uri ADD_DAILY_BUDGET =
      Uri.https('${DOMAIN}', '${URL_PATH}/addDailyBudget');
  static Uri EDIT_DAILY_BUDGET =
      Uri.https('${DOMAIN}', '${URL_PATH}/editDailyBudget');

  static Uri ADD_ROLE = Uri.https('${DOMAIN}', '${URL_PATH}/addRole');
  static Uri EDIT_ROLE = Uri.https('${DOMAIN}', '${URL_PATH}/editRole');

/*---------------------------------------------------------------------------------*/

  static const Offset RTL = Offset(1, 0);
  static const Offset LTR = Offset(-1, 0);
  static const Offset UTD = Offset(0, -1);
  static const Offset DTU = Offset(0, 1);

  static String generateId(String pref) {
    var chars =
        'zyxwvutsrqponmlkjihgfedcbaZYXWVUTSRQPONMLKJIHGFEDCBA9876543210zyxwvutsrqponmlkjihgfedcbaZYXWVUTSRQPONMLKJIHGFEDCBA9876543210';
    int char_length = chars.length;
    var t = DateTime.now();
    String id = pref;
    // id += chars[(t.year / 100).round()];
    id += chars[t.year % char_length];
    id += chars[t.month];
    id += chars[t.day];
    id += chars[t.hour];
    id += chars[t.minute];
    id += chars[t.second];
    id += chars[t.millisecond % char_length];
    id += chars[t.microsecond % char_length];
    return id;
  }

  static Route createRoute(dest, Offset dir) {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500),
      opaque: false,
      pageBuilder: (context, animation, secondaryAnimation) => dest,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = dir;
        var end = Offset.zero;
        var curve = Curves.fastOutSlowIn;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  static Route createPopUpRoute(dest) {
    return PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) => dest,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          double begin = 0;
          double end = 1;
          var curve = Curves.fastOutSlowIn;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return ScaleTransition(
            scale: animation.drive(tween),
            child: child,
          );
        },
        opaque: false);
  }

  static Future<String> openGallery() async {
    var pickedFile = await ImagePicker()
        .getImage(source: ImageSource.gallery, imageQuality: 25);
    if (pickedFile != null) {
      return pickedFile.path;
    } else {
      return null;
    }
  }

  static Future<String> openCamera() async {
    var pickedFile = await ImagePicker()
        .getImage(source: ImageSource.camera, imageQuality: 25);
    if (pickedFile != null) {
      return pickedFile.path;
    } else {
      return null;
    }
  }

  static askSource(BuildContext context) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text("Select Source"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: TextButton.icon(
                    onPressed: () async {
                      String s = await openCamera();
                      Navigator.of(context).pop(s);
                    },
                    label: Text('Camera'),
                    icon: Icon(Icons.camera),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: TextButton.icon(
                    onPressed: () async {
                      String s = await openGallery();
                      Navigator.of(context).pop(s);
                    },
                    label: Text('Gallery'),
                    icon: Icon(Icons.image_outlined),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              MaterialButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("cancel"),
                ),
              )
            ],
          );
        });
  }

  static showLoadingDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context){
        return WillPopScope(
          onWillPop: () {
            return;
          },
          child: SimpleDialog(
            contentPadding: const EdgeInsets.all(8),
            children: <Widget>[
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(),
                    SizedBox(
                      width: 8,
                    ),
                    Text(title)
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<bool> showdialog(BuildContext context, String title,
      String message, onOkPressed, onCancelPressed) {
    FocusScope.of(context).unfocus();
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop(true);
                return true;
              },
            ),
          ],
        );
      },
    );
  }

  static Future<bool> showScrollingDialog(BuildContext context, String title,
      String message, onOkPressed, onCancelPressed) {
    FocusScope.of(context).unfocus();
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                child: Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                child: Text("Ok"),
                onPressed: () {
                  Navigator.of(context).pop(true);
                  return true;
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<bool> showSuccessDialog(BuildContext context, String title,
      String message, Color color, Color bg, onOkPressed) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: bg,
          title: Text(
            title,
            style: TextStyle(color: color ?? Colors.green),
          ),
          content: Text(
            message,
            style: TextStyle(fontSize: 14),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Ok"),
              onPressed: onOkPressed,
            ),
          ],
        );
      },
    );
  }

  static Future<bool> showErrorDialog(
      BuildContext context, String title, String message) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(color: Colors.red),
          ),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  static final additionalArtists = {
    'Juniors': {
      'field_values': [
        {
          'Male': 0,
          'Female': 0,
          'Kids': 0,
          'Contact': '',
          'Notes': '',
        }
      ],
      'fields': {
        'Male': 0,
        'Female': 0,
        'Kids': 0,
        'Contact': '',
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
          'Contact': '',
          'Notes': '',
        }
      ],
      'fields': {
        'Male': 0,
        'Female': 0,
        'Kids': 0,
        'Contact': '',
        'Notes': '',
      },
      'addable': false
    },
    'Dancers/Fighters': {
      'field_values': [
        {
          'Male': 0,
          'Female': 0,
          'Kids': 0,
          'Contact': '',
          'Notes': '',
        }
      ],
      'fields': {
        'Male': 0,
        'Female': 0,
        'Kids': 0,
        'Contact': '',
        'Notes': '',
      },
      'addable': false
    },
    'Gang Members': {
      'field_values': [],
      'fields': {
        'id': '',
        'Name': '',
        'Contact': '',
      },
      'addable': true
    },
    'Additional Artists': {
      'field_values': [],
      'fields': {
        'id': '',
        'Name': '',
        'Contact': '',
      },
      'addable': true
    },
  };
  static final addlKeys = [
    'Gang Members',
    'Additional Artists',
    'Juniors',
    'Models',
    'Dancers/Fighters'
  ];

  static var elevatedButtonStyle = ElevatedButton.styleFrom(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    primary: Color(0xff6fd8a8),
  );
}
