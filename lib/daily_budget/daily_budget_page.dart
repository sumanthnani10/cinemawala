import 'package:cinemawala/daily_budget/add_daily_budget.dart';
import 'package:cinemawala/daily_budget/daily_budget.dart';
import 'package:cinemawala/projects/project.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils.dart';

class DailyBudgetPage extends StatefulWidget {
  final Project project;
  final DailyBudget dailyBudget;
  final DateTime date;
  final Map budget;
  final String id;
  final VoidCallback nextDate, prevDate, getDailyBudgets;

  DailyBudgetPage(
      {Key key,
      @required this.project,
      @required this.budget,
      @required this.dailyBudget,
      @required this.date,
      @required this.id,
      @required this.getDailyBudgets,
      @required this.nextDate,
      @required this.prevDate})
      : super(key: key);

  @override
  _DailyBudgetPage createState() => _DailyBudgetPage(
      this.project,
      this.budget,
      this.dailyBudget,
      this.date,
      this.id,
      this.getDailyBudgets,
      this.nextDate,
      this.prevDate);
}

class _DailyBudgetPage extends State<DailyBudgetPage>
    with SingleTickerProviderStateMixin {
  final Project project;
  DailyBudget dailyBudget;
  DateTime date;
  Map budget;
  String id;
  VoidCallback nextDate, prevDate, getDailyBudgets;

  _DailyBudgetPage(this.project, this.budget, this.dailyBudget, this.date,
      this.id, this.getDailyBudgets, this.nextDate, this.prevDate);

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Color background, background1, color;
  var categoryHeading = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
  var subheading = TextStyle(fontSize: 18);

  List<dynamic> categories, subCategories;

  List<TextEditingController> contactControllers,
      quantityControllers,
      rateControllers,
      callSheetControllers;

  var pickedDate, startTime, endTime;
  var formattedTimeOfDay;
  List<String> weeksDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  var dialogActionHeading = TextStyle(color: Colors.indigo, fontSize: 16);
  TimeOfDay _timeOfDay = TimeOfDay.now();

  @override
  void initState() {
    budget = {
      'Location_Rent': {
        'Line_Producer': {
          'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet': 0
        },
        'Line_Producer_Assistants': {
          'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet': 0
        },
      },
      /*'Hero_Staff':{
        'MAKEUP_MAN':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'COSTUMER':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'ASSISTANT':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'DESIGNER':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
      },
      'Heroine_Staff':{
        'MAKEUP_MAN':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'COSTUMER':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'ASSISTANT':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'DESIGNER':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
      },
      'Company_Artists':{
        'Co-ordinator':{
          'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0
        },
      },
      'Juniors/Extras':{
        'Co-ordinator':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Males':{
          'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0
        },
        'Females':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Kids-boys':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Kids-girls':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
      },
      'Models':{
        'Co-ordinator':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Males':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Females':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Kids-boys':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Kids-girls':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
      },
      'Gang_Members/Rowdies':{
        'Co-ordinator':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
      },
      'Art_Department':{
        'Art_Assistant':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Art_Assistant_1':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Art_Assistant_2':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
      },
      'Set_Assistants':{
        'Set_Assistants':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Set_Helpers':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
      },
      'CARPENTERS_&_PAINTER':{
        'Carpenter':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Painter':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Moulders':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Welders':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Thermocol_Artists':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
      },
      'COSTUMES/WARDROBE_DEPARTMENT':{
        '1st_ASSIST':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        '2nd_ASSIST':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Dress Man':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
      },
      'MAKEUP_&_HAIR_DEPARTMENT':{
        '1st_ASSIST':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        '2nd_ASSIST':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Hair_Dresser':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
      },
      'Camera_Department':{
        'D.O.P':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Operative_Cameraman':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Cameraman_1st_Assist':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Cameraman_2nd_Assist':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
      },
      '1st_UNIT_CAMERA':{
        'Camera_Assistant':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Focus_Puller':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'D.I.T':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
      },
      '2nd_Unit_Camera':{
        'Camera_Assistants':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Focus_Puller':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
      },
      'Lighting_Unit':{
        'Light_Men':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Unit_Bus_Driver':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Operator':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Electrician':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Gaffer':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Key':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Grip':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Company_Electrician':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
      },
      'Lights_1st_Unit':{
        'Par_Lights':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
      },
      'Lights_2nd_Unit':{
        'Par_Lights':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
      },
      'Sound':{
        'Nagara_Engineer':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Nagara_Assitant':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Sync_Sound_Engineer':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Sync_Sound_Assistant':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Walkie_Talkies':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
      },
      'Online_Editor':{
        '':{
          'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0
        },
      },
      'Production/Spotboy':{
        'Production_Assist':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Production_Ladies':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Other_Set_Expenses':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Washing_Battas':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
      },
      'Direction_Department':{
        'Director':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Co-dir':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Associate_Director/1st_Assistant':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Associate_Director/2nd_Assistant':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Associate_Director/3rd_Assistant':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
      },
      'Caravan/Vanity_Van':{
        'Caravan_Driver_1':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Caravan_Assistant':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Caravan_Driver_2':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Caravan_Assistant_2':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Generator_Diesel':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Vehicle_Diesel':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Security_Personel/Bouncers':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Police_Personel_Permissions':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
      },
      'Production':{
        'Producers':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Production_Controller':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Production_Executive':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Manager 1':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Manager 2':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Manager 3':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Cashiers':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Executive_Producer_1':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Executive_Producer_2':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
      },
      'Steady_Cam(Special_Equipments)':{
        'Operator':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Operator_Assistant':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
      },
      'Helicam':{
        'Pilot':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Pilot_Assistant':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
      },
      'Gimble':{
        'Operator':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Assistant':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
      },
      'Panther_Dolly':{
        '':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
      },
      'Rostrum/Truss':{
        '':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
      },
      'Crane':{
        '':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
      },
      'Track_&_Trolley':{
        '':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
      },
      'Jimmy_Jib':{
        'Jimmy_Operator':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Jimmy_Crew':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
      },
      'Special_Fx(Guns,Rain)':{
        '':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
      },
      'Vfx':{
        '':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
      },
      'Stunts/Action':{
        'Fight_Master/Stunt_Co-ordinator':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Fight_Master_Assistant':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Fighters/Stunt_Men':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
        'Fighters_Co-ordinator':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
      },
      'Making/Behind_the_Scenes':{
        '':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
      },
      'Still_Photography':{
        '':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
      },
      'Guests':{
        '':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
      },
      'Mess/Food_Expenses':{
        '':{'contact': '',
          'quantity': 0,
          'rate': 0,
          'subtotal': 0,
          'use': true,
          'callSheet':0},
      },*/
    };
    super.initState();
  }

  Future<String> createAlertDialog(BuildContext context, String title) {
    TextEditingController headingController = new TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Add ${title}"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextField(
                        controller: headingController,
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                  ),
                )
              ],
            ),
            actions: <Widget>[
              MaterialButton(
                onPressed: () {
                  Navigator.of(context).pop(headingController.text.toString());
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Submit"),
                ),
              )
            ],
          );
        });
  }

  DialogAction(BuildContext context) {
    TextEditingController controller = new TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Select"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {},
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: FlatButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.done),
                      label: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Save',
                            style: dialogActionHeading,
                          )),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: FlatButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.picture_as_pdf_rounded),
                      label: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Generate Call Sheet',
                            style: dialogActionHeading,
                          )),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: FlatButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.picture_as_pdf_rounded),
                      label: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Generate Daily Report',
                            style: dialogActionHeading,
                          )),
                    ),
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

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    formattedTimeOfDay = localizations.formatTimeOfDay(TimeOfDay.now());
    contactControllers = [];
    quantityControllers = [];
    callSheetControllers = [];
    rateControllers = [];
    categories = budget.keys.toList();
    background = Colors.white;
    color = Color(0xff6fd8a8);
    if (background == Colors.white) {
      background1 = Colors.black;
    } else {
      background1 = Colors.white;
    }
    return DraggableScrollableSheet(
      initialChildSize: 300 / MediaQuery.of(context).size.height,
      minChildSize: 300 / MediaQuery.of(context).size.height,
      maxChildSize: 1,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xff6fd8a8),
                  offset: Offset(0, -0.5),
                  blurRadius: 4,
                ),
              ]),
          child: dailyBudget != null
              ? NotificationListener<OverscrollIndicatorNotification>(
                  onNotification: (OverscrollIndicatorNotification overscroll) {
                    overscroll.disallowGlow();
                    return;
                  },
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: Icon(CupertinoIcons.back),
                                    onPressed: () {},
                                  ),
                                  Text(
                                    "${date.day > 9 ? date.day : "0${date.day}"}-${date.month > 9 ? date.month : "0${date.month}"}-${date.year}, ${weeksDays[date.weekday - 1]}",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  IconButton(
                                    icon: Icon(CupertinoIcons.forward),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                            ),
                            Divider(
                              thickness: 2,
                            ),
                            InkWell(
                              onTap: () {
                                createAlertDialog(context, "Category")
                                    .then((v) {
                                  if (v == null) {
                                  } else if (budget['${v}'] == null) {
                                    budget['${v}'] = {};
                                    setState(() {});
                                  } else {
                                    final snackbar = SnackBar(
                                      duration: new Duration(seconds: 3),
                                      content: Text(
                                        "${v} is already used or check the name!!",
                                        style: TextStyle(color: background),
                                      ),
                                      backgroundColor: background1,
                                    );
                                    _scaffoldKey.currentState
                                        .showSnackBar(snackbar);
                                  }
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "+Add Category",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.indigo),
                                    )),
                              ),
                            ),
                            Column(
                              children:
                                  List<Widget>.generate(budget.length, (i) {
                                subCategories =
                                    budget[categories[i]].keys.toList();
                                return Column(
                                  children: [
                                    Divider(
                                      thickness: 1,
                                      color: background1,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              "${categories[i].replaceAll("_", " ")}",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: categoryHeading,
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              createAlertDialog(
                                                      context, "SubCategory")
                                                  .then((v) {
                                                if (v == null) {
                                                } else if (budget[categories[i]]
                                                        ['${v}'] ==
                                                    null) {
                                                  budget[categories[i]]
                                                      ['$v'] = {
                                                    'contact': '',
                                                    'quantity': 0,
                                                    'rate': 0,
                                                    'subtotal': 0,
                                                    'use': true,
                                                    'callSheet': 0
                                                  };
                                                  setState(() {});
                                                } else {
                                                  final snackbar = SnackBar(
                                                    duration: new Duration(
                                                        seconds: 3),
                                                    content: Text(
                                                      "${v} is already used or check the name!!",
                                                      style: TextStyle(
                                                          color: background),
                                                    ),
                                                    backgroundColor:
                                                        background1,
                                                  );
                                                  _scaffoldKey.currentState
                                                      .showSnackBar(snackbar);
                                                }
                                              });
                                            },
                                            child: Text(
                                              "+Add Subcategory",
                                              style: TextStyle(
                                                  color: Colors.indigo),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 16),
                                      child: Column(
                                          children: List<Widget>.generate(
                                              subCategories.length, (j) {
                                        var subcategory = budget[categories[i]]
                                            [subCategories[j]];
                                        contactControllers.add(
                                            new TextEditingController(
                                                text:
                                                    "${subcategory["contact"]}"));
                                        quantityControllers.add(
                                            new TextEditingController(
                                                text:
                                                    "${subcategory["quantity"]}"));
                                        rateControllers.add(
                                            new TextEditingController(
                                                text:
                                                    "${subcategory["rate"]}"));
                                        callSheetControllers.add(
                                            new TextEditingController(
                                                text:
                                                    "${subcategory["callSheet"]}"));
                                        return Column(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                  border: Border(
                                                      top: BorderSide(
                                                          color: j != 0
                                                              ? background1
                                                              : background,
                                                          width: 1))),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Transform.scale(
                                                        scale: 1.1,
                                                        child: Checkbox(
                                                            value: budget[
                                                                    categories[
                                                                        i]][
                                                                subCategories[
                                                                    j]]["use"],
                                                            activeColor: color,
                                                            onChanged: (value) {
                                                              setState(() {
                                                                budget[categories[
                                                                            i]][
                                                                        subCategories[
                                                                            j]][
                                                                    "use"] = value;
                                                              });
                                                            }),
                                                      ),
                                                      Text(
                                                        "${subCategories[j].replaceAll("_", " ")}",
                                                        style: subheading,
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Flexible(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(4),
                                                          child: TextField(
                                                            onChanged: (value) {
                                                              budget[categories[
                                                                          i]][
                                                                      subCategories[
                                                                          j]][
                                                                  "contact"] = value;
                                                            },
                                                            controller:
                                                                contactControllers
                                                                    .last,
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            decoration:
                                                                InputDecoration(
                                                              enabledBorder: OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                          color:
                                                                              background1)),
                                                              labelText:
                                                                  'Contact#',
                                                              labelStyle: TextStyle(
                                                                  color:
                                                                      background1,
                                                                  fontSize: 14),
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .all(8),
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
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Flexible(
                                                        child: Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              4,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(4),
                                                          child: TextField(
                                                            onChanged: (value) {
                                                              budget[categories[
                                                                          i]][
                                                                      subCategories[
                                                                          j]][
                                                                  "callSheet"] = value;
                                                            },
                                                            controller:
                                                                callSheetControllers
                                                                    .last,
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            decoration:
                                                                InputDecoration(
                                                              enabledBorder: OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                          color:
                                                                              background1)),
                                                              labelText:
                                                                  'Call Sheet',
                                                              labelStyle: TextStyle(
                                                                  color:
                                                                      background1,
                                                                  fontSize: 14),
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .all(8),
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
                                                      ),
                                                      Flexible(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                            "Subtotal: ${budget[categories[i]][subCategories[j]]["subtotal"]}",
                                                            style: subheading,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Flexible(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal: 4,
                                                                  vertical: 8),
                                                          child: TextField(
                                                            onChanged: (a) {
                                                              if (a.isEmpty) {
                                                                a = '0';
                                                              }
                                                              setState(() {
                                                                budget[categories[
                                                                        i]][
                                                                    subCategories[
                                                                        j]]["quantity"] = int
                                                                    .parse(a);
                                                                budget[categories[i]]
                                                                        [
                                                                        subCategories[
                                                                            j]][
                                                                    "subtotal"] = int
                                                                        .parse(
                                                                            a) *
                                                                    budget[categories[i]]
                                                                            [subCategories[j]]
                                                                        ["rate"];
                                                              });
                                                            },
                                                            controller:
                                                                quantityControllers
                                                                    .last,
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            decoration:
                                                                InputDecoration(
                                                              enabledBorder: OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                          color:
                                                                              background1)),
                                                              labelText:
                                                                  'Quantity',
                                                              labelStyle: TextStyle(
                                                                  color:
                                                                      background1,
                                                                  fontSize: 14),
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .all(8),
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
                                                      ),
                                                      Flexible(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal: 4,
                                                                  vertical: 8),
                                                          child: TextField(
                                                            onChanged: (a) {
                                                              if (a.isEmpty) {
                                                                a = '0';
                                                              }
                                                              setState(() {
                                                                budget[categories[
                                                                        i]][
                                                                    subCategories[
                                                                        j]]["rate"] = int
                                                                    .parse(a);
                                                                budget[categories[i]]
                                                                        [
                                                                        subCategories[
                                                                            j]][
                                                                    "subtotal"] = int
                                                                        .parse(
                                                                            a) *
                                                                    budget[categories[i]]
                                                                            [subCategories[j]]
                                                                        ["quantity"];
                                                              });
                                                            },
                                                            controller:
                                                                rateControllers
                                                                    .last,
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            decoration:
                                                                InputDecoration(
                                                              enabledBorder: OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                          color:
                                                                              background1)),
                                                              labelText: 'Rate',
                                                              labelStyle: TextStyle(
                                                                  color:
                                                                      background1,
                                                                  fontSize: 14),
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .all(8),
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
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      })),
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        controller: scrollController,
                        child: Container(
                          color: background,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: Icon(CupertinoIcons.back),
                                      onPressed: prevDate,
                                    ),
                                    Text(
                                      "${date.day > 9 ? date.day : "0${date.day}"}-${date.month > 9 ? date.month : "0${date.month}"}-${date.year}, ${weeksDays[date.weekday - 1]}",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    IconButton(
                                      icon: Icon(CupertinoIcons.forward),
                                      onPressed: nextDate,
                                    ),
                                  ],
                                ),
                              ),
                              Divider(
                                thickness: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(CupertinoIcons.back),
                            onPressed: prevDate,
                          ),
                          Text(
                            "${date.day > 9 ? date.day : "0${date.day}"}-${date.month > 9 ? date.month : "0${date.month}"}-${date.year}, ${weeksDays[date.weekday - 1]}",
                            style: TextStyle(fontSize: 18),
                          ),
                          IconButton(
                            icon: Icon(CupertinoIcons.forward),
                            onPressed: nextDate,
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      thickness: 2,
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Text(
                      "No Budget.",
                      style: TextStyle(fontSize: 20),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        var now = DateTime.now();
                        Map<String, dynamic> dailyBudget = {
                          "day": date.day,
                          "project_id": project.id,
                          "month": date.month,
                          "added_by": Utils.USER_ID,
                          "budget": {},
                          "id": id,
                          "year": date.year,
                          "last_edit_by": Utils.USER_ID,
                          "last_edit_on": now.millisecondsSinceEpoch,
                          "created": now.millisecondsSinceEpoch
                        };
                        var back = await Navigator.push(
                                context,
                                Utils.createRoute(
                                    AddDailyBudget(
                                        project: project,
                                        dailyBudget: dailyBudget),
                                    Utils.DTU)) ??
                            false;
                        if (back) {
                          getDailyBudgets();
                        }
                      },
                      child: Text("+ Add Budget"),
                      style: ElevatedButton.styleFrom(primary: color),
                    )
                  ],
                ),
        );
      },
    );
  }
}
/*Scaffold(
      key: _scaffoldKey,
      backgroundColor: background,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
                child: Wrap(
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  spacing: 4,
                  runSpacing: 12,
                  children: [
                    Container(
                      margin: EdgeInsets.all(2),
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(300),
                          boxShadow: [
                            BoxShadow(
                              color: color,
                              offset: Offset(0, 4),
                              blurRadius: 5,
                            ),
                          ]),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: color,
                          ),
                          pickedDate == null
                              ? Text(
                                  "${DateTime.now().toString().substring(0, 10)}",
                                  style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                )
                              : Text(
                                  "${pickedDate}",
                                  style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            PageRouteBuilder(
                                pageBuilder: (_, __, ___) => SelectLocation(),
                                opaque: false));
                      },
                      child: Container(
                        margin: EdgeInsets.all(2),
                        padding:
                            EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(300),
                            boxShadow: [
                              BoxShadow(
                                color: color,
                                offset: Offset(0, 4),
                                blurRadius: 5,
                              ),
                            ]),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on,
                              color: color,
                            ),
                            Text(
                              "Ramoji Film City",
                              style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        TimeOfDay time = await showTimePicker(
                            context: context,
                            initialTime: _timeOfDay,
                            builder: (BuildContext context, Widget child) {
                              return Theme(
                                data: ThemeData(),
                                child: child,
                              );
                            });
                        await setState(() {
                          final localizations =
                              MaterialLocalizations.of(context);
                          startTime = localizations.formatTimeOfDay(time);
                          if (time == null) {
                            formattedTimeOfDay =
                                localizations.formatTimeOfDay(TimeOfDay.now());
                          } else {
                            _timeOfDay = time;
                          }
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.all(2),
                        padding:
                            EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(300),
                            boxShadow: [
                              BoxShadow(
                                color: color,
                                offset: Offset(0, 4),
                                blurRadius: 5,
                              ),
                            ]),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.access_time_outlined,
                              color: color,
                            ),
                            startTime != null
                                ? Text(
                                    "${startTime}",
                                    //"check",
                                    //"09:00 A.M",
                                    style: TextStyle(
                                        color: color,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  )
                                : Text(
                                    "${formattedTimeOfDay}",
                                    //"text",
                                    //"09:00 A.M",
                                    style: TextStyle(
                                        color: color,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                            Text(
                              "(Start Time)",
                              style: TextStyle(color: color, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        TimeOfDay time = await showTimePicker(
                            context: context,
                            initialTime: _timeOfDay,
                            builder: (BuildContext context, Widget child) {
                              return Theme(
                                data: ThemeData(),
                                child: child,
                              );
                            });
                        setState(() {
                          final localizations =
                              MaterialLocalizations.of(context);
                          endTime = localizations.formatTimeOfDay(time);
                          if (time == null) {
                            formattedTimeOfDay =
                                localizations.formatTimeOfDay(TimeOfDay.now());
                          } else {
                            _timeOfDay = time;
                          }
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.all(2),
                        padding:
                            EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(300),
                            boxShadow: [
                              BoxShadow(
                                color: color,
                                offset: Offset(0, 4),
                                blurRadius: 5,
                              ),
                            ]),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.access_time_outlined,
                              color: color,
                            ),
                            endTime != null
                                ? Text(
                                    "${endTime}",
                                    style: TextStyle(
                                        color: color,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  )
                                : Text(
                                    "${formattedTimeOfDay}",
                                    style: TextStyle(
                                        color: color,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                            Text(
                              "(End Time)",
                              style: TextStyle(color: color, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  createAlertDialog(context, "Category").then((v) {
                    if (v == null) {
                    } else if (budget['${v}'] == null) {
                      budget['${v}'] = {};
                      setState(() {});
                    } else {
                      final snackbar = SnackBar(
                        duration: new Duration(seconds: 3),
                        content: Text(
                          "${v} is already used or check the name!!",
                          style: TextStyle(color: background),
                        ),
                        backgroundColor: background1,
                      );
                      _scaffoldKey.currentState.showSnackBar(snackbar);
                    }
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "+Add Category",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo),
                      )),
                ),
              ),
              Column(
                children: List<Widget>.generate(budget.length, (i) {
                  subCategories = budget[categories[i]].keys.toList();
                  return Column(
                    children: [
                      Divider(
                        thickness: 1,
                        color: background1,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                "${categories[i].replaceAll("_", " ")}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: categoryHeading,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                createAlertDialog(context, "SubCategory")
                                    .then((v) {
                                  if (v == null) {
                                  } else if (budget[categories[i]]['${v}'] ==
                                      null) {
                                    budget[categories[i]]['$v'] = {
                                      'contact': '',
                                      'quantity': 0,
                                      'rate': 0,
                                      'subtotal': 0,
                                      'use': true,
                                      'callSheet': 0
                                    };
                                    setState(() {});
                                  } else {
                                    final snackbar = SnackBar(
                                      duration: new Duration(seconds: 3),
                                      content: Text(
                                        "${v} is already used or check the name!!",
                                        style: TextStyle(color: background),
                                      ),
                                      backgroundColor: background1,
                                    );
                                    _scaffoldKey.currentState
                                        .showSnackBar(snackbar);
                                  }
                                });
                              },
                              child: Text(
                                "+Add Subcategory",
                                style: TextStyle(color: Colors.indigo),
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                            children: List<Widget>.generate(
                                subCategories.length, (j) {
                          var subcategory =
                              budget[categories[i]][subCategories[j]];
                          contactControllers.add(new TextEditingController(
                              text: "${subcategory["contact"]}"));
                          quantityControllers.add(new TextEditingController(
                              text: "${subcategory["quantity"]}"));
                          rateControllers.add(new TextEditingController(
                              text: "${subcategory["rate"]}"));
                          callSheetControllers.add(new TextEditingController(
                              text: "${subcategory["callSheet"]}"));
                          return Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    border: Border(
                                        top: BorderSide(
                                            color: j != 0
                                                ? background1
                                                : background,
                                            width: 1))),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Transform.scale(
                                          scale: 1.1,
                                          child: Checkbox(
                                              value: budget[categories[i]]
                                                  [subCategories[j]]["use"],
                                              activeColor: color,
                                              onChanged: (value) {
                                                setState(() {
                                                  budget[categories[i]]
                                                          [subCategories[j]]
                                                      ["use"] = value;
                                                });
                                              }),
                                        ),
                                        Text(
                                          "${subCategories[j].replaceAll("_", " ")}",
                                          style: subheading,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Padding(
                                            padding: const EdgeInsets.all(4),
                                            child: TextField(
                                              onChanged: (value) {
                                                budget[categories[i]]
                                                        [subCategories[j]]
                                                    ["contact"] = value;
                                              },
                                              controller:
                                                  contactControllers.last,
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: InputDecoration(
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                background1)),
                                                labelText: 'Contact#',
                                                labelStyle: TextStyle(
                                                    color: background1,
                                                    fontSize: 14),
                                                contentPadding:
                                                    EdgeInsets.all(8),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                4,
                                            padding: const EdgeInsets.all(4),
                                            child: TextField(
                                              onChanged: (value) {
                                                budget[categories[i]]
                                                        [subCategories[j]]
                                                    ["callSheet"] = value;
                                              },
                                              controller:
                                                  callSheetControllers.last,
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: InputDecoration(
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                background1)),
                                                labelText: 'Call Sheet',
                                                labelStyle: TextStyle(
                                                    color: background1,
                                                    fontSize: 14),
                                                contentPadding:
                                                    EdgeInsets.all(8),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "Subtotal: ${budget[categories[i]][subCategories[j]]["subtotal"]}",
                                              style: subheading,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4, vertical: 8),
                                            child: TextField(
                                              onChanged: (a) {
                                                if (a.isEmpty) {
                                                  a = '0';
                                                }
                                                setState(() {
                                                  budget[categories[i]]
                                                              [subCategories[j]]
                                                          ["quantity"] =
                                                      int.parse(a);
                                                  budget[categories[i]]
                                                          [subCategories[j]]
                                                      ["subtotal"] = int.parse(
                                                          a) *
                                                      budget[categories[i]]
                                                              [subCategories[j]]
                                                          ["rate"];
                                                });
                                              },
                                              controller:
                                                  quantityControllers.last,
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: InputDecoration(
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                background1)),
                                                labelText: 'Quantity',
                                                labelStyle: TextStyle(
                                                    color: background1,
                                                    fontSize: 14),
                                                contentPadding:
                                                    EdgeInsets.all(8),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4, vertical: 8),
                                            child: TextField(
                                              onChanged: (a) {
                                                if (a.isEmpty) {
                                                  a = '0';
                                                }
                                                setState(() {
                                                  budget[categories[i]]
                                                          [subCategories[j]]
                                                      ["rate"] = int.parse(a);
                                                  budget[categories[i]]
                                                          [subCategories[j]]
                                                      ["subtotal"] = int.parse(
                                                          a) *
                                                      budget[categories[i]]
                                                              [subCategories[j]]
                                                          ["quantity"];
                                                });
                                              },
                                              controller: rateControllers.last,
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: InputDecoration(
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                background1)),
                                                labelText: 'Rate',
                                                labelStyle: TextStyle(
                                                    color: background1,
                                                    fontSize: 14),
                                                contentPadding:
                                                    EdgeInsets.all(8),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        })),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );*/