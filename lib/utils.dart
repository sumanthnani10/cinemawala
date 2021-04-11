import 'dart:convert';

import 'package:cinemawala/casting/actor.dart';
import 'package:cinemawala/costumes/costume.dart';
import 'package:cinemawala/locations/location.dart';
import 'package:cinemawala/projects/project.dart';
import 'package:cinemawala/scenes/scene.dart';
import 'package:cinemawala/schedule/schedule.dart';
import 'package:cinemawala/user/user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'daily_budget/daily_budget.dart';
import 'props/prop.dart';

class Utils {
  static String USER_ID;
  static User user;
  static Project project;
  static List<Project> projects;
  static List<Actor> artists;
  static List<Costume> costumes;
  static List<Prop> props;
  static List<Location> locations;
  static List<Scene> scenes;
  static List<Schedule> schedules;
  static List<DailyBudget> dailyBudgets;
  static Map<String, Project> projectsMap;
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

  static getProjects(context) async {
    var resp = await http
        .post(Utils.GET_PROJECTS, body: {"user_id": "${Utils.USER_ID}"});

    if (resp.statusCode == 200) {
      var r = jsonDecode(resp.body);
      if (r['status'] == 'success') {
        Utils.projects = [];
        Utils.projectsMap = {};
        r['projects'].forEach((i) {
          Utils.projects.add(Project.fromJson(i));
          Utils.projectsMap[Utils.projects.last.id] = Utils.projects.last;
        });
      } else {
        showErrorDialog(context, '', '${r['msg']}');
      }
    } else {
      showErrorDialog(context, '', 'Something went Wrong. Please try again');
    }
    return Utils.projects;
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
  static Uri EDIT_PROJECT = Uri.https('${DOMAIN}', '${URL_PATH}/editProject');

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
                  child: Text("Cancel"),
                ),
              )
            ],
          );
        });
  }

  static showLoadingDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      barrierDismissible: kDebugMode,
      builder: (BuildContext context) {
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
    // FocusScope.of(context).unfocus();
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

  static Map<String, String> codeToLanguagesInLanguage = {
        'hi': '\u0939\u093f\u0928\u094d\u0926\u0940',
        'ps': '\u067e\u069a\u062a\u0648',
        'fil': 'Filipino',
        'hmn': 'Hmong',
        'hr': 'Hrvatski',
        'ht': 'Haitian Creole',
        'hu': 'magyar',
        'yi': '\u05d9\u05d9\u05b4\u05d3\u05d9\u05e9',
        'hy': '\u0570\u0561\u0575\u0565\u0580\u0565\u0576',
        'ccp': 'Chakma',
        'zh-Hans': '\u7b80\u4f53\u4e2d\u6587\uff08\u4e2d\u56fd\uff09',
        'zh-Hant': '\u7e41\u9ad4\u4e2d\u6587\uff08\u53f0\u7063\uff09',
        'yo': '\u00c8d\u00e8 Yor\u00f9b\u00e1',
        'id': 'Indonesia',
        'af': 'Afrikaans',
        'is': '\u00edslenska',
        'it': 'Italiano',
        'am': '\u12a0\u121b\u122d\u129b',
        'iu': 'Inuktitut',
        'ar': '\u0627\u0644\u0639\u0631\u0628\u064a\u0629',
        'pt-PT': 'Portugu\u00eas (Portugal)',
        'as': '\u0985\u09b8\u09ae\u09c0\u09af\u09bc\u09be',
        'ja': '\u65e5\u672c\u8a9e',
        'az': 'az\u0259rbaycan',
        'zu': 'isiZulu',
        'ro': 'rom\u00e2n\u0103',
        'myh': 'Makah',
        'ceb': 'Binisaya',
        'ru': '\u0420\u0443\u0441\u0441\u043a\u0438\u0439',
        'be': '\u0431\u0435\u043b\u0430\u0440\u0443\u0441\u043a\u0430\u044f',
        'bg': '\u0431\u044a\u043b\u0433\u0430\u0440\u0441\u043a\u0438',
        'bn': '\u09ac\u09be\u0982\u09b2\u09be',
        'jv': 'Jawa',
        'bo': '\u0f56\u0f7c\u0f51\u0f0b\u0f66\u0f90\u0f51\u0f0b',
        'jw': 'Jawa',
        'sa':
            '\u0938\u0902\u0938\u094d\u0915\u0943\u0924 \u092d\u093e\u0937\u093e',
        'bs': 'bosanski',
        'sd': '\u0633\u0646\u068c\u064a',
        'see': 'Seneca',
        'zh-yue': '\u7cb5\u8a9e',
        'si': '\u0dc3\u0dd2\u0d82\u0dc4\u0dbd',
        'ka': '\u10e5\u10d0\u10e0\u10d7\u10e3\u10da\u10d8',
        'sk': 'Sloven\u010dina',
        'sl': 'sloven\u0161\u010dina',
        'sm': 'Samoan',
        'sn': 'chiShona',
        'so': 'Soomaali',
        'sq': 'shqip',
        'ca': 'catal\u00e0',
        'sr': '\u0441\u0440\u043f\u0441\u043a\u0438',
        'kk': '\u049b\u0430\u0437\u0430\u049b \u0442\u0456\u043b\u0456',
        'km': '\u1781\u17d2\u1798\u17c2\u179a',
        'su': 'Basa Sunda',
        'kn': '\u0c95\u0ca8\u0ccd\u0ca8\u0ca1',
        'sv': 'Svenska',
        'ko': '\ud55c\uad6d\uc5b4',
        'sw': 'Kiswahili',
        'zh-TW': '\u7e41\u9ad4\u4e2d\u6587',
        'one': 'Oneida',
        'ku': 'kurd\u00ee',
        'co': 'Corsican',
        'ta': '\u0ba4\u0bae\u0bbf\u0bb4\u0bcd',
        'ky': '\u043a\u044b\u0440\u0433\u044b\u0437\u0447\u0430',
        'uzs': 'Southern Uzbek',
        'cs': '\u010ce\u0161tina',
        'te': '\u0c24\u0c46\u0c32\u0c41\u0c17\u0c41',
        'tg': '\u0442\u043e\u04b7\u0438\u043a\u04e3',
        'th': '\u0e44\u0e17\u0e22',
        'ti': '\u1275\u130d\u122d',
        'la': 'Latin',
        'cy': 'Cymraeg',
        'lb': 'L\u00ebtzebuergesch',
        'tl': 'Filipino',
        'da': 'Dansk',
        'tr': 'T\u00fcrk\u00e7e',
        'tt': '\u0442\u0430\u0442\u0430\u0440',
        'de': 'Deutsch',
        'lo': '\u0ea5\u0eb2\u0ea7',
        'lt': 'lietuvi\u0173',
        'lv': 'latvie\u0161u',
        'zh-CN': '\u7b80\u4f53\u4e2d\u6587',
        'ug': '\u0626\u06c7\u064a\u063a\u06c7\u0631\u0686\u06d5',
        'uk': '\u0423\u043a\u0440\u0430\u0457\u043d\u0441\u044c\u043a\u0430',
        'dz': '\u0f62\u0fab\u0f7c\u0f44\u0f0b\u0f41',
        'lis': 'Lisu',
        'mg': 'Malagasy',
        'mi': 'te reo M\u0101ori',
        'ur': '\u0627\u0631\u062f\u0648',
        'mk': '\u043c\u0430\u043a\u0435\u0434\u043e\u043d\u0441\u043a\u0438',
        'ml': '\u0d2e\u0d32\u0d2f\u0d3e\u0d33\u0d02',
        'haw': '\u02bb\u014clelo Hawai\u02bbi',
        'mn': '\u043c\u043e\u043d\u0433\u043e\u043b',
        'mr': '\u092e\u0930\u093e\u0920\u0940',
        'uz': 'o\u2018zbek',
        'ms': 'Melayu',
        'el': '\u0395\u03bb\u03bb\u03b7\u03bd\u03b9\u03ba\u03ac',
        'mt': 'Malti',
        'en': 'English',
        'eo': 'esperanto',
        'chr': '\u13e3\u13b3\u13a9',
        'my': '\u1019\u103c\u1014\u103a\u1019\u102c',
        'es': 'Espa\u00f1ol',
        'et': 'eesti',
        'eu': 'euskara',
        'vi': 'Ti\u1ebfng Vi\u1ec7t',
        'nb': 'norsk',
        'ne': '\u0928\u0947\u092a\u093e\u0932\u0940',
        'fa': '\u0641\u0627\u0631\u0633\u06cc',
        'nl': 'Nederlands',
        'nn': 'norsk nynorsk',
        'ff': 'Pulaar',
        'no': 'norsk',
        'fi': 'Suomi',
        'mul': 'Multiple languages',
        'nv': 'Navajo',
        'ny': 'Nyanja',
        'fr': 'Fran\u00e7ais',
        'rom': 'Romany',
        'fy': 'Frysk',
        'ga': 'Gaeilge',
        'oj': 'Ojibwa',
        'gd': 'G\u00e0idhlig',
        'crk': 'Plains Cree',
        'or': '\u0b13\u0b21\u0b3c\u0b3f\u0b06',
        'mez': 'Menominee',
        'zh-HK': '\u4e2d\u6587\uff08\u9999\u6e2f\uff09',
        'gl': 'galego',
        'pt-BR': 'Portugu\u00eas (Brasil)',
        'mni-Mtei':
            '\u09ae\u09c8\u09a4\u09c8\u09b2\u09cb\u09a8\u09cd (\u09ae\u09c7\u0987\u099f\u09c7\u0987 \u09ae\u09be\u09af\u09bc\u09c7\u0995)',
        'gu': '\u0a97\u0ac1\u0a9c\u0ab0\u0abe\u0aa4\u0ac0',
        'xh': 'isiXhosa',
        'rhg': 'Rohingya',
        'pa': '\u0a2a\u0a70\u0a1c\u0a3e\u0a2c\u0a40',
        'ckb':
            '\u06a9\u0648\u0631\u062f\u06cc\u06cc \u0646\u0627\u0648\u06d5\u0646\u062f\u06cc',
        'pl': 'polski',
        'osa': 'Osage',
        'he': '\u05e2\u05d1\u05e8\u05d9\u05ea'
      },
      codeToLanguagesInEnglish = {
        "en": 'English',
        "hi": 'Hindi',
        "sa": 'Sanskrit',
        "te": 'Telugu',
        "mr": 'Marathi',
        "ta": 'Tamil',
        "ml": 'Malayalam',
        "kn": 'Kannada',
        "gu": 'Gujarati',
        "bn": 'Bangla',
        "as": 'Assamese',
        "af": 'Afrikaans',
        "sq": 'Albanian',
        "am": 'Amharic',
        "ar": 'Arabic',
        "hy": 'Armenian',
        "az": 'Azerbaijani',
        "eu": 'Basque',
        "be": 'Belarusian',
        "bs": 'Bosnian',
        "bg": 'Bulgarian',
        "my": 'Burmese',
        "yue": 'Cantonese:zh',
        "ca": 'Catalan',
        "ceb": 'Cebuano',
        "ckb": 'Central Kurdish',
        "ccp": 'Chakma',
        "chr": 'Cherokee',
        "zh-Hans": 'Chinese',
        "co": 'Corsican',
        "hr": 'Croatian',
        "cs": 'Czech',
        "da": 'Danish',
        "nl": 'Dutch',
        "dz": 'Dzongkha',
        "eo": 'Esperanto',
        "et": 'Estonian',
        "fil": 'Filipino',
        "tl": 'Filipino',
        "fi": 'Finnish',
        "fr": 'French',
        "ff": 'Fulah',
        "gl": 'Galician',
        "ka": 'Georgian',
        "de": 'German',
        "el": 'Greek',
        "ht": 'Haitian Creole',
        "haw": 'Hawaiian',
        "he": 'Hebrew',
        "hmn": 'Hmong',
        "hu": 'Hungarian',
        "is": 'Icelandic',
        "id": 'Indonesian',
        "iu": 'Inuktitut',
        "ga": 'Irish',
        "it": 'Italian',
        "ja": 'Japanese',
        "jv": 'Javanese',
        "jw": 'Javanese',
        "kk": 'Kazakh',
        "km": 'Khmer',
        "ko": 'Korean',
        "ku": 'Kurdish',
        "ky": 'Kyrgyz',
        "lo": 'Lao',
        "la": 'Latin',
        "lv": 'Latvian',
        "lis": 'Lisu',
        "lt": 'Lithuanian',
        "lb": 'Luxembourgish',
        "mk": 'Macedonian',
        "myh": 'Makah',
        "mg": 'Malagasy',
        "ms": 'Malay',
        "mt": 'Maltese',
        "mni-Mtei": 'Manipuri',
        "mi": 'Maori',
        "mez": 'Menominee',
        "mn": 'Mongolian',
        "mul": 'Multiple languages',
        "nv": 'Navajo',
        "ne": 'Nepali',
        "nn": 'Norwegian Nynorsk',
        "nb": 'Norwegian',
        "no": 'Norwegian',
        "ny": 'Nyanja',
        "or": 'Odia',
        "oj": 'Ojibwa',
        "one": 'Oneida',
        "osa": 'Osage',
        "ps": 'Pashto',
        "fa": 'Persian',
        "crk": 'Plains Cree',
        "pl": 'Polish',
        "pt": 'Portuguese (Portugal):',
        "pa": 'Punjabi',
        "rhg": 'Rohingya',
        "ro": 'Romanian',
        "rom": 'Romany',
        "ru": 'Russian',
        "sm": 'Samoan',
        "gd": 'Scottish Gaelic',
        "see": 'Seneca',
        "sr": 'Serbian',
        "sn": 'Shona',
        "sd": 'Sindhi',
        "si": 'Sinhala',
        "sk": 'Slovak',
        "sl": 'Slovenian',
        "so": 'Somali',
        "uzs": 'Southern Uzbek',
        "es": 'Spanish',
        "su": 'Sundanese',
        "sw": 'Swahili',
        "sv": 'Swedish',
        "tg": 'Tajik',
        "tt": 'Tatar',
        "th": 'Thai',
        "bo": 'Tibetan',
        "ti": 'Tigrinya',
        "tr": 'Turkish',
        "uk": 'Ukrainian',
        "ur": 'Urdu',
        "ug": 'Uyghur',
        "uz": 'Uzbek',
        "vi": 'Vietnamese',
        "cy": 'Welsh',
        "fy": 'Western Frisian',
        "xh": 'Xhosa',
        "yi": 'Yiddish',
        "yo": 'Yoruba',
        "zu": 'Zulu',
      };
}
