import 'dart:convert';
import 'dart:math';

import 'package:cinemawala/locations/location.dart';
import 'package:cinemawala/projects/project.dart';
import 'package:cinemawala/scenes/scene.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../utils.dart';
import 'daily_budget.dart';

class AddDailyBudget extends StatefulWidget {
  final Project project;
  final Map<dynamic, dynamic> dailyBudget;
  final bool edit;
  final bool isPopUp;
  AddDailyBudget({Key key,
    @required this.project,
    @required this.dailyBudget, this.edit,this.isPopUp})
      : super(key: key);

  @override
  _AddDailyBudget createState() =>
      _AddDailyBudget(
          this.project,
          this.dailyBudget, this.edit,this.isPopUp);
}

class _AddDailyBudget extends State<AddDailyBudget>
    with SingleTickerProviderStateMixin {
  final Project project;
  bool isPopUp;
  Map<dynamic, dynamic> dailyBudget;
  bool edit;
  String locations = "";


  _AddDailyBudget(this.project, this.dailyBudget, this.edit, this.isPopUp);

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Color background, background1, color;
  var categoryHeading = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
  var subheading = TextStyle(fontSize: 18);
  bool loading = true;
  Map<dynamic,dynamic> dynamicMapBudget;
  ScrollController scrollController = new ScrollController();

  List<dynamic> categories, subCategories, sceneKeys;

  List<TextEditingController> contactControllers,
      quantityControllers,
      rateControllers,
      callSheetControllers;

  var pickedDate, startTime, endTime;
  var formattedTimeOfDay;
  int viewCats = 3;
  DateTime selectedDate;
  List<String> weeksDays = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];
  var dialogActionHeading = TextStyle(color: Colors.indigo, fontSize: 16);

  @override
  void initState() {
    isPopUp = isPopUp ?? true;
    scrollController.addListener(() {
      if (scrollController.offset >=
          scrollController.position.maxScrollExtent &&
          !scrollController.position.outOfRange) {
        viewCats += 3;
        setState(() {});
      }
    });
    edit = edit ?? false;
    selectedDate =
        DateTime(dailyBudget['year'], dailyBudget['month'], dailyBudget['day']);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      int males=0,females=0,kids=0;
      List<String> dynamicBudget = ["Juniors","Models","Dancers","Fighters","Gang Members","Additional Artists"];
       dynamicMapBudget = {
        "Juniors": {
          "Co-ordinator": {
            "contact": "",
            "quantity": 0,
            "rate": 0,
            "subtotal": 0,
            "use": true,
            "callSheet": 0
          },
          "Male": {
            "contact": "",
            "quantity": 0,
            "rate": 0,
            "subtotal": 0,
            "use": true,
            "callSheet": 0
          },
          "Female": {
            "contact": "",
            "quantity": 0,
            "rate": 0,
            "subtotal": 0,
            "use": true,
            "callSheet": 0
          },
          "Kids": {
            "contact": "",
            "quantity": 0,
            "rate": 0,
            "subtotal": 0,
            "use": true,
            "callSheet": 0
          },
        },
        "Models": {
          "Co-ordinator": {
            "contact": "",
            "quantity": 0,
            "rate": 0,
            "subtotal": 0,
            "use": true,
            "callSheet": 0
          },
          "Male": {
            "contact": "",
            "quantity": 0,
            "rate": 0,
            "subtotal": 0,
            "use": true,
            "callSheet": 0
          },
          "Female": {
            "contact": "",
            "quantity": 0,
            "rate": 0,
            "subtotal": 0,
            "use": true,
            "callSheet": 0
          },
          "Kids": {
            "contact": "",
            "quantity": 0,
            "rate": 0,
            "subtotal": 0,
            "use": true,
            "callSheet": 0
          },
        },
        "Dancers": {
          "Co-ordinator": {
            "contact": "",
            "quantity": 0,
            "rate": 0,
            "subtotal": 0,
            "use": true,
            "callSheet": 0
          },
          "Male": {
            "contact": "",
            "quantity": 0,
            "rate": 0,
            "subtotal": 0,
            "use": true,
            "callSheet": 0
          },
          "Female": {
            "contact": "",
            "quantity": 0,
            "rate": 0,
            "subtotal": 0,
            "use": true,
            "callSheet": 0
          },
          "Kids": {
            "contact": "",
            "quantity": 0,
            "rate": 0,
            "subtotal": 0,
            "use": true,
            "callSheet": 0
          },
        },
        "Fighters": {
          "Co-ordinator": {
            "contact": "",
            "quantity": 0,
            "rate": 0,
            "subtotal": 0,
            "use": true,
            "callSheet": 0
          },
          "Male": {
            "contact": "",
            "quantity": 0,
            "rate": 0,
            "subtotal": 0,
            "use": true,
            "callSheet": 0
          },
          "Female": {
            "contact": "",
            "quantity": 0,
            "rate": 0,
            "subtotal": 0,
            "use": true,
            "callSheet": 0
          },
          "Kids": {
            "contact": "",
            "quantity": 0,
            "rate": 0,
            "subtotal": 0,
            "use": true,
            "callSheet": 0
          },
        },
         "Gang Members": {

         },
         "Additional Artists": {

         },
      };
      Utils.showLoadingDialog(context, "Loading");
      if (dailyBudget['budget'].length == 0) {
        if (Utils.schedulesMap.containsKey(dailyBudget['id'])) {
          Utils.schedulesMap[dailyBudget['id']].scenes.forEach((sid) {
            dailyBudget['scenes_budget']['special_equipment'] = {};
            Location loc = Utils.locationsMap[Utils.scenesMap[sid].location];
            Scene scene = Utils.scenesMap[sid];
            Map<dynamic,dynamic> tmpMap = scene.addlArtists;
            for(int d=0;d<dynamicBudget.length;d++){
              if(tmpMap[dynamicBudget[d]].length==0){
                break;
              }
              Map<String,dynamic> category = tmpMap[dynamicBudget[d]][0];
              if(d<4){
                dynamicMapBudget[dynamicBudget[d]]['Male']['quantity'] += category['Male'];
                dynamicMapBudget[dynamicBudget[d]]['Female']['quantity'] += category['Female'];
                dynamicMapBudget[dynamicBudget[d]]['Kids']['quantity'] += category['Kids'];
              }else{
                dynamicMapBudget[dynamicBudget[d]][category['Name']] = {};
                dynamicMapBudget[dynamicBudget[d]][category['Name']] = {
                  "contact": category['Contact'],
                  "quantity": 1,
                  "rate": 0,
                  "subtotal": 0,
                  "use": true,
                  "callSheet": 0,
                };
              }
            }
            dailyBudget["scenes_budget"].addAll(dynamicMapBudget);
            locations += "${loc.location} (${loc.shootLocation}) | ";
            Utils.scenesMap[sid].specialEquipment.split(",").forEach((e) {
              e = e.trim();
              if (e.isNotEmpty) {
                e.replaceAll(" ", "_");
                dailyBudget['scenes_budget']['special_equipment'][e] = {
                  "contact": "",
                  "quantity": 0,
                  "rate": 0,
                  "subtotal": 0,
                  "use": true,
                  "callSheet": 0,
                };
              }
            });
          });
        }
        if (Utils.dailyBudgets.isNotEmpty) {
          DateTime now = DateTime(
              dailyBudget['year'], dailyBudget['month'], dailyBudget['day']);
          String lastBudgetID = Utils.dailyBudgets[0].id;

          for (int i = 1; i < Utils.dailyBudgets.length; i++) {
            if (now.isAfter(DateTime(
                Utils.dailyBudgets[i].year, Utils.dailyBudgets[i].month,
                Utils.dailyBudgets[i].day))) {
              lastBudgetID = Utils.dailyBudgets[i].id;
            } else {
              break;
            }
          }
          dailyBudget['budget'].addAll(
              Utils.dailyBudgetsMap[lastBudgetID].budget);
        } else {
          dailyBudget['budget'] = {
            "Location_Rent": {
              "Line_Producer": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Line_Producer_Assistants": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              }
            },
            "Hero_Staff": {
              "MAKEUP_MAN": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "COSTUMER": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "ASSISTANT": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "DESIGNER": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              }
            },
            "Heroine_Staff": {
              "MAKEUP_MAN": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "COSTUMER": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "ASSISTANT": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "DESIGNER": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              }
            },
            "Company_Artists": {
              "Co-ordinator": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              }
            },
            "Juniors/Extras": {
              "Co-ordinator": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Males": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Females": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Kids-boys": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Kids-girls": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              }
            },
            "Models": {
              "Co-ordinator": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Males": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Females": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Kids-boys": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Kids-girls": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              }
            },
            "Gang_Members/Rowdies": {
              "Co-ordinator": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              }
            },
            "Art_Department": {
              "Art_Assistant": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Art_Assistant_1": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Art_Assistant_2": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              }
            },
            "Set_Assistants": {
              "Set_Assistants": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Set_Helpers": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              }
            },
            "CARPENTERS_&_PAINTER": {
              "Carpenter": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Painter": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Moulders": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Welders": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Thermocol_Artists": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              }
            },
            "COSTUMES/WARDROBE_DEPARTMENT": {
              "1st_ASSIST": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "2nd_ASSIST": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Dress Man": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              }
            },
            "MAKEUP_&_HAIR_DEPARTMENT": {
              "1st_ASSIST": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "2nd_ASSIST": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Hair_Dresser": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              }
            },
            "Camera_Department": {
              "DOP": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Operative_Cameraman": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Cameraman_1st_Assist": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Cameraman_2nd_Assist": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              }
            },
            "1st_UNIT_CAMERA": {
              "Camera_Assistant": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Focus_Puller": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "DIT": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              }
            },
            "2nd_Unit_Camera": {
              "Camera_Assistants": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Focus_Puller": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              }
            },
            "Lighting_Unit": {
              "Light_Men": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Unit_Bus_Driver": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Operator": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Electrician": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Gaffer": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Key": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Grip": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Company_Electrician": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              }
            },
            "Lights_1st_Unit": {
              "Par_Lights": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              }
            },
            "Lights_2nd_Unit": {
              "Par_Lights": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              }
            },
            "Sound": {
              "Nagara_Engineer": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Nagara_Assitant": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Sync_Sound_Engineer": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Sync_Sound_Assistant": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Walkie_Talkies": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              }
            },
            "Online_Editor": {
              " ": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              }
            },
            "Production/Spotboy": {
              "Production_Assist": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Production_Ladies": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Other_Set_Expenses": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Washing_Battas": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              }
            },
            "Direction_Department": {
              "Director": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Co-dir": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Associate_Director/1st_Assistant": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Associate_Director/2nd_Assistant": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Associate_Director/3rd_Assistant": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              }
            },
            "Caravan/Vanity_Van": {
              "Caravan_Driver_1": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Caravan_Assistant": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Caravan_Driver_2": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Caravan_Assistant_2": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Generator_Diesel": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Vehicle_Diesel": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Security_Personel/Bouncers": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Police_Personel_Permissions": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              }
            },
            "Production": {
              "Producers": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Production_Controller": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Production_Executive": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Manager 1": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Manager 2": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Manager 3": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Cashiers": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Executive_Producer_1": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Executive_Producer_2": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              }
            },
            "Steady_Cam(Special_Equipments)": {
              "Operator": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Operator_Assistant": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              }
            },
            "Helicam": {
              "Pilot": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Pilot_Assistant": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              }
            },
            "Gimble": {
              "Operator": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Assistant": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              }
            },
            "Panther_Dolly": {
              " ": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              }
            },
            "Rostrum/Truss": {
              " ": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              }
            },
            "Crane": {
              " ": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              }
            },
            "Track_&_Trolley": {
              " ": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              }
            },
            "Jimmy_Jib": {
              "Jimmy_Operator": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Jimmy_Crew": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              }
            },
            "Special_Fx(Guns,Rain)": {
              " ": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              }
            },
            "Vfx": {
              "Vfx": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              }
            },
            "Stunts/Action": {
              "Fight_Master/Stunt_Co-ordinator": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Fight_Master_Assistant": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Fighters/Stunt_Men": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              },
              "Fighters_Co-ordinator": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              }
            },
            "Making/Behind_the_Scenes": {
              " ": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              }
            },
            "Still_Photography": {
              " ": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              }
            },
            "Guests": {
              " ": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              }
            },
            "Mess/Food_Expenses": {
              " ": {
                "contact": "",
                "quantity": 0,
                "rate": 0,
                "subtotal": 0,
                "use": true,
                "callSheet": 0
              }
            },
          };
        }
        setState(() {});
      }
      Navigator.pop(context);
    });

    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  String reFormatKey(String s) {
    s = s.replaceAll("_", " ");
    s = s.toLowerCase();
    var l = s.split(" ");
    String r = "";
    l.forEach((f) {
      if (f.length > 0) {
        r += (f.substring(0, 1).toUpperCase());
        r += (f.substring(1));
        r += " ";
      }
    });
    return r;
  }

  String formatKey(String s) {
    s = s.replaceAll(" ", "_");
    s = s.toLowerCase();
    return s;
  }

  Future<String> createAlertDialog(BuildContext context, String title) {
    TextEditingController headingController = new TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Add $title"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  child: TextButton(
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

  @override
  Widget build(BuildContext context) {
    var budget = {};
    var scenesBudget = {};
    scenesBudget.addAll(dailyBudget['scenes_budget']);
    budget.addAll(dailyBudget['budget']);
    final localizations = MaterialLocalizations.of(context);
    formattedTimeOfDay = localizations.formatTimeOfDay(TimeOfDay.now());
    contactControllers = [];
    quantityControllers = [];
    callSheetControllers = [];
    rateControllers = [];
    categories = budget.keys.toList();
    sceneKeys = scenesBudget.keys.toList();
    background = Colors.white;
    color = Color(0xff6fd8a8);
    if (background == Colors.white) {
      background1 = Colors.black;
    } else {
      background1 = Colors.white;
    }
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: background,
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: Utils.linearGradient,
            ),
          ),
          backgroundColor: color,
          iconTheme: IconThemeData(color: background1),
          title: Text(
            edit ? "Edit Budget" : "Add Budget",
            style: TextStyle(color: background1),
          ),
          actions: [
            TextButton.icon(
              onPressed: () async {
                if (edit) {
                  editDailyBudget();
                } else {
                  addDailyBudget();
                }
              },
              label: Text(
                edit ? "Save" : "Add",
                style: TextStyle(color: Colors.indigo),
                textAlign: TextAlign.right,
              ),
              icon: Icon(
                edit ? Icons.done : Icons.add,
                size: 18,
                color: Colors.indigo,
              ),
            )
          ],
        ),
        body: CupertinoScrollbar(
          controller: scrollController,
          isAlwaysShown: true,
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: <Widget>[
                    Container(
                      margin: const EdgeInsets.fromLTRB(8, 16, 8, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${selectedDate.day > 9
                                ? selectedDate.day
                                : "0${selectedDate.day}"}-${selectedDate.month >
                                9 ? selectedDate.month : "0${selectedDate
                                .month}"}-${selectedDate
                                .year}, ${weeksDays[selectedDate.weekday - 1]}",
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                if(locations.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 2, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Locations: ",
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        Flexible(
                          child: Text(
                            "$locations",
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 12,),
                          ),
                        ),
                      ],
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        createAlertDialog(context, "Category").then((v) {
                          if (v == null) {} else if (budget['$v'] == null) {
                            v = formatKey(v);
                            dailyBudget['budget']['$v'] = {};
                                budget['$v'] = {};
                                setState(() {});
                              } else {
                                final snackBar = SnackBar(
                                  duration: new Duration(seconds: 3),
                                  content: Text(
                                    "$v is already used or check the name!!",
                                    style: TextStyle(color: background),
                                  ),
                                  backgroundColor: background1,
                                );
                                _scaffoldKey.currentState
                                    .showSnackBar(snackBar);
                              }
                            });
                          },
                          child: Text(
                            "+Add Category",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo),
                          ),
                        ),
                        TextButton(
                            onPressed: () async {},
                            child: Container(
                              padding: kIsWeb ? EdgeInsets.only(right: 12):EdgeInsets.only(right: 2),
                              child: Text(
                                'View Daily Budget',
                                style:
                                TextStyle(fontSize: 12, color: Colors.indigo),
                              ),
                            )),
                      ],
                    ),
              ] +
                  List<Widget>.generate(sceneKeys.length, (i) {
                    subCategories = scenesBudget[sceneKeys[i]].keys.toList();
                    if(subCategories.length!=0)
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
                                  "${sceneKeys[i]}",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: categoryHeading,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  createAlertDialog(context, "SubCategory")
                                      .then((v) {
                                    if (v == null) {} else
                                    if (scenesBudget[sceneKeys[i]]['$v'] ==
                                        null) {
                                      v = formatKey(v);
                                      scenesBudget[sceneKeys[i]]['$v'] = {
                                        'contact': '',
                                        'quantity': 0,
                                        'rate': 0,
                                        'subtotal': 0,
                                        'use': true,
                                        'callSheet': 0
                                      };
                                      setState(() {});
                                    } else {
                                      final snackBar = SnackBar(
                                        duration: new Duration(seconds: 3),
                                        content: Text(
                                          "$v is already used or check the name!!",
                                          style: TextStyle(color: background),
                                        ),
                                        backgroundColor: background1,
                                      );
                                      _scaffoldKey.currentState
                                          .showSnackBar(snackBar);
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
                          child: Wrap(
                            spacing: 8,
                              children: List<Widget>.generate(
                                  subCategories.length, (j) {
                                var subcategory =
                                scenesBudget[sceneKeys[i]][subCategories[j]];
                                contactControllers.add(
                                    new TextEditingController(
                                        text: "${subcategory["contact"]}"));
                                quantityControllers.add(
                                    new TextEditingController(
                                        text: "${subcategory["quantity"]}"));
                                rateControllers.add(new TextEditingController(
                                    text: "${subcategory["rate"]}"));
                                callSheetControllers.add(
                                    new TextEditingController(
                                        text: "${subcategory["callSheet"]}"));
                                return Container(
                                  constraints: BoxConstraints(maxWidth: 360),
                              decoration: BoxDecoration(
                                  border: Border(
                                      top: BorderSide(
                                          color: j != 0
                                              ? background1
                                              : background,
                                          width: 1))),
                              child: Column( /////..................
                                children: [
                                  Row(
                                    children: [
                                      Transform.scale(
                                        scale: 1.1,
                                        child: Checkbox(
                                            value: scenesBudget[sceneKeys[i]][scenesBudget[sceneKeys[i]].keys.elementAt(j)]["use"],
                                            activeColor: color,
                                            onChanged: (value) {
                                              setState(() {
                                                scenesBudget[sceneKeys[i]][scenesBudget[sceneKeys[i]]
                                                    .keys
                                                    .elementAt(j)]
                                                ["use"] = value;
                                                dailyBudget['scenesBudget'] =
                                                    scenesBudget;
                                              });
                                            }),
                                      ),
                                      Flexible(
                                        child: Text(
                                          "${reFormatKey(subCategories[j])}",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: subheading,
                                        ),
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
                                              scenesBudget[sceneKeys[i]][
                                              scenesBudget[sceneKeys[i]]
                                                  .keys
                                                  .elementAt(j)]
                                              ["contact"] = value;
                                              dailyBudget['scenesBudget'] =
                                                  scenesBudget;
                                            },
                                            controller:
                                            contactControllers.last,
                                            keyboardType:
                                            TextInputType.text,
                                            decoration: InputDecoration(
                                              enabledBorder:
                                              OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color:
                                                      background1)),
                                              labelText: 'Name and Contact',
                                              labelStyle: TextStyle(
                                                  color: background1,
                                                  fontSize: 14),
                                              contentPadding:
                                              EdgeInsets.all(8),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius.circular(
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
                                          width: MediaQuery.of(context)
                                              .size
                                              .width /
                                              4,
                                          padding: const EdgeInsets.all(4),
                                          child: TextField(
                                            onChanged: (value) {
                                              scenesBudget[sceneKeys[i]][
                                              scenesBudget[sceneKeys[i]]
                                                  .keys
                                                  .elementAt(j)]
                                              ["callSheet"] = value;
                                              dailyBudget['scenesBudget'] =
                                                  scenesBudget;
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
                                                BorderRadius.circular(
                                                    8),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Padding(
                                          padding:
                                          const EdgeInsets.all(8.0),
                                          child: Text(
                                            "Subtotal: ${scenesBudget[sceneKeys[i]][scenesBudget[sceneKeys[i]]
                                                .keys.elementAt(
                                                j)]["subtotal"]}",
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
                                          const EdgeInsets.symmetric(
                                              horizontal: 4,
                                              vertical: 8),
                                          child: TextField(
                                            onSubmitted: (a) {
                                              if (a.isEmpty) {
                                                a = '0';
                                              }
                                              setState(() {
                                                scenesBudget[sceneKeys[
                                                i]][scenesBudget[
                                                sceneKeys[i]]
                                                    .keys
                                                    .elementAt(
                                                    j)]["quantity"] =
                                                    int.parse(a);
                                                scenesBudget[sceneKeys[i]][
                                                scenesBudget[sceneKeys[i]]
                                                    .keys
                                                    .elementAt(j)]
                                                ["subtotal"] = int.parse(
                                                    a) *
                                                    scenesBudget[sceneKeys[i]][
                                                    scenesBudget[sceneKeys[i]]
                                                        .keys
                                                        .elementAt(j)]
                                                    ["rate"];
                                                dailyBudget['scenesBudget'] =
                                                    scenesBudget;
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
                                                BorderRadius.circular(
                                                    8),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Padding(
                                          padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 4,
                                              vertical: 8),
                                          child: TextField(
                                            onSubmitted: (a) {
                                              if (a.isEmpty) {
                                                a = '0';
                                              }
                                              setState(() {
                                                scenesBudget[sceneKeys[i]][
                                                scenesBudget[sceneKeys[
                                                i]]
                                                    .keys
                                                    .elementAt(j)]
                                                ["rate"] = int.parse(a);
                                                scenesBudget[sceneKeys[i]][
                                                scenesBudget[sceneKeys[i]]
                                                    .keys
                                                    .elementAt(j)]
                                                ["subtotal"] = int.parse(
                                                    a) *
                                                    scenesBudget[sceneKeys[i]][
                                                    scenesBudget[sceneKeys[i]]
                                                        .keys
                                                        .elementAt(j)]
                                                    ["quantity"];
                                                dailyBudget['scenesBudget'] =
                                                    scenesBudget;
                                              });
                                            },
                                            controller:
                                            rateControllers.last,
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
                                                BorderRadius.circular(
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
                                );
                              })),
                        ),
                      ],
                    );
                    else
                      return Column();
                  }) +
                  List<Widget>.generate(min<int>(viewCats, budget.length), (i) {
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
                                  "${reFormatKey(categories[i])}",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: categoryHeading,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  createAlertDialog(context, "SubCategory")
                                      .then((v) {
                                    if (v == null) {} else
                                    if (budget[categories[i]]['$v'] ==
                                        null) {
                                      v = formatKey(v);
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
                                      final snackBar = SnackBar(
                                        duration: new Duration(seconds: 3),
                                        content: Text(
                                          "$v is already used or check the name!!",
                                          style: TextStyle(color: background),
                                        ),
                                        backgroundColor: background1,
                                      );
                                      _scaffoldKey.currentState
                                          .showSnackBar(snackBar);
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
                          child: Wrap(
                              spacing: 8,
                              children: List<Widget>.generate(
                                  subCategories.length, (j) {
                                var subcategory =
                                budget[categories[i]][subCategories[j]];
                                contactControllers.add(
                                    new TextEditingController(
                                        text: "${subcategory["contact"]}"));
                                quantityControllers.add(
                                    new TextEditingController(
                                        text: "${subcategory["quantity"]}"));
                                rateControllers.add(new TextEditingController(
                                    text: "${subcategory["rate"]}"));
                                callSheetControllers.add(
                                    new TextEditingController(
                                        text: "${subcategory["callSheet"]}"));
                                return Container(
                                  constraints: BoxConstraints(maxWidth: 360),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          top: BorderSide(
                                              color: j != 0
                                                  ? background1
                                                  : background,
                                              width: 1))),
                                  child: Column( /////..................
                                    children: [
                                      Row(
                                        children: [
                                          Transform.scale(
                                            scale: 1.1,
                                            child: Checkbox(
                                                value: budget[categories[i]][
                                                budget[categories[i]]
                                                    .keys
                                                    .elementAt(j)]["use"],
                                                activeColor: color,
                                                onChanged: (value) {
                                                  setState(() {
                                                    budget[categories[i]][
                                                    budget[categories[
                                                    i]]
                                                        .keys
                                                        .elementAt(j)]
                                                    ["use"] = value;
                                                    dailyBudget['budget'] =
                                                        budget;
                                                  });
                                                }),
                                          ),
                                          Flexible(
                                            child: Text(
                                              "${reFormatKey(
                                                  subCategories[j])}",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: subheading,
                                            ),
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
                                                  budget[categories[i]][
                                                  budget[categories[i]]
                                                      .keys
                                                      .elementAt(j)]
                                                  ["contact"] = value;
                                                  dailyBudget['budget'] =
                                                      budget;
                                                },
                                                controller:
                                                contactControllers.last,
                                                keyboardType:
                                                TextInputType.text,
                                                decoration: InputDecoration(
                                                  enabledBorder:
                                                  OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color:
                                                          background1)),
                                                  labelText: 'Name and Contact',
                                                  labelStyle: TextStyle(
                                                      color: background1,
                                                      fontSize: 14),
                                                  contentPadding:
                                                  EdgeInsets.all(8),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
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
                                              width: MediaQuery
                                                  .of(context)
                                                  .size
                                                  .width /
                                                  4,
                                              padding: const EdgeInsets.all(4),
                                              child: TextField(
                                                onChanged: (value) {
                                                  budget[categories[i]][
                                                  budget[categories[i]]
                                                      .keys
                                                      .elementAt(j)]
                                                  ["callSheet"] = value;
                                                  dailyBudget['budget'] =
                                                      budget;
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
                                                    BorderRadius.circular(
                                                        8),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            child: Padding(
                                              padding:
                                              const EdgeInsets.all(8.0),
                                              child: Text(
                                                "Subtotal: ${budget[categories[i]][budget[categories[i]]
                                                    .keys.elementAt(
                                                    j)]["subtotal"]}",
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
                                              const EdgeInsets.symmetric(
                                                  horizontal: 4,
                                                  vertical: 8),
                                              child: TextField(
                                                onSubmitted: (a) {
                                                  if (a.isEmpty) {
                                                    a = '0';
                                                  }
                                                  setState(() {
                                                    budget[categories[
                                                    i]][budget[
                                                    categories[i]]
                                                        .keys
                                                        .elementAt(
                                                        j)]["quantity"] =
                                                        int.parse(a);
                                                    budget[categories[i]][
                                                    budget[categories[i]]
                                                        .keys
                                                        .elementAt(j)]
                                                    ["subtotal"] = int.parse(
                                                        a) *
                                                        budget[categories[i]][
                                                        budget[categories[i]]
                                                            .keys
                                                            .elementAt(j)]
                                                        ["rate"];
                                                    dailyBudget['budget'] =
                                                        budget;
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
                                                    BorderRadius.circular(
                                                        8),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            child: Padding(
                                              padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 4,
                                                  vertical: 8),
                                              child: TextField(
                                                onSubmitted: (a) {
                                                  if (a.isEmpty) {
                                                    a = '0';
                                                  }
                                                  setState(() {
                                                    budget[categories[i]][
                                                    budget[categories[
                                                    i]]
                                                        .keys
                                                        .elementAt(j)]
                                                    ["rate"] = int.parse(a);
                                                    budget[categories[i]][
                                                    budget[categories[i]]
                                                        .keys
                                                        .elementAt(j)]
                                                    ["subtotal"] = int.parse(
                                                        a) *
                                                        budget[categories[i]][
                                                        budget[categories[i]]
                                                            .keys
                                                            .elementAt(j)]
                                                        ["quantity"];
                                                    dailyBudget['budget'] =
                                                        budget;
                                                  });
                                                },
                                                controller:
                                                rateControllers.last,
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
                                                    BorderRadius.circular(
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
                                );
                              })),
                        ),
                      ],
                    );
                  }) +
                  <Widget>[
                    Text(
                      viewCats < budget.length ? "Loading.." : "",
                      style: TextStyle(color: color),
                    )
                  ],
            ),
          ),
        ),
      ),
    );
  }

  addDailyBudget() async {
    Utils.showLoadingDialog(context, 'Adding Daily Budget');

    try {
      var resp = await http.post(Utils.ADD_DAILY_BUDGET,
          body: jsonEncode(dailyBudget),
          headers: {"Content-Type": "application/json"});
      var r = jsonDecode(resp.body);
      Navigator.pop(context);
      if (resp.statusCode == 200) {
        if (r['status'] == 'success') {
          Utils.dailyBudgetsMap[dailyBudget['id']] =
              DailyBudget.fromJson(dailyBudget);
          Utils.dailyBudgets = Utils.dailyBudgetsMap.values.toList();

          await Utils.showSuccessDialog(
              context,
              'Daily Budget Added',
              'Daily Budget has been added successfully.',
              Colors.green,
              background, () {
            Navigator.pop(context);
          });
        } else {
          await Utils.showErrorDialog(context, 'Unsuccessful', '${r['msg']}');
        }
      } else {
        await Utils.showErrorDialog(context, 'Something went wrong.',
            'Please try again after sometime.');
      }
      setState(() {
        loading = false;
      });
    } catch (e) {
      // debugPrint(e);
      Navigator.pop(context);
      await Utils.showErrorDialog(
          context, 'Something went wrong.', 'Please try again after sometime.');
    }
    Navigator.pop(context);
  }

  editDailyBudget() async {
    Utils.showLoadingDialog(context, 'Editing Daily Budget');

    try {
      var resp = await http.post(Utils.EDIT_DAILY_BUDGET,
          body: jsonEncode(dailyBudget),
          headers: {"Content-Type": "application/json"});
      // // debugPrint(resp.body);
      var r = jsonDecode(resp.body);
      Navigator.pop(context);
      if (resp.statusCode == 200) {
        if (r['status'] == 'success') {
          Utils.dailyBudgetsMap[dailyBudget['id']] =
              DailyBudget.fromJson(dailyBudget);
          Utils.dailyBudgets = Utils.dailyBudgetsMap.values.toList();

          await Utils.showSuccessDialog(
              context,
              'Daily Budget Edited',
              'Daily Budget has been edited successfully.',
              Colors.green,
              background, () {
            Navigator.pop(context);
          });
        } else {
          await Utils.showErrorDialog(context, 'Unsuccessful', '${r['msg']}');
        }
      } else {
        await Utils.showErrorDialog(context, 'Something went wrong.',
            'Please try again after sometime.');
      }
      setState(() {
        loading = false;
      });
    } catch (e) {
      // debugPrint(e);
      Navigator.pop(context);
      await Utils.showErrorDialog(
          context, 'Something went wrong.', 'Please try again after sometime.');
    }
    Navigator.pop(context);
  }

}

/*
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
              ),*/

