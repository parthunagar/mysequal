import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/managers/analytics_actions.dart';
import 'package:peloton/managers/analytics_manager.dart';
import 'package:peloton/views/add_new_ptd/add_new_point_td.dart';
import 'package:peloton/views/add_new_story/add_new_story.dart';
import 'package:peloton/views/add_new_task/add_new_task.dart';

import 'error_alert.dart';

class AddActionsWidget extends StatefulWidget {
  @override
  _AddActionsWidgetState createState() => _AddActionsWidgetState();
}

class _AddActionsWidgetState extends State<AddActionsWidget> {
  bool isLoading = true;

  showAddNewTask() {
AnalyticsManager.instance.addEvent(AnalytictsActions.menuAddNewTask, null);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (cntx) {
      return AddNewTaskWidget();
    }));
  }

  showAddNewStory() async {
    AnalyticsManager.instance.addEvent(AnalytictsActions.menuAddNewStory, null);
    var result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) {
      await showDialog(
          context: context,
          child: ErrorAlert(
            title: AppLocalizations.of(context).translate("AddStoryNoInternet"),
          ));

      return;
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (cntx) {
        return AddNewStoryWidget();
      }));
    }
  }

  showAddNewPoint() {
    AnalyticsManager.instance.addEvent(AnalytictsActions.menuAdddiscussionPoint, null);
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) {
          return AddNewPointTD();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        color: Colors.black.withOpacity(0.75),
        child: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              Positioned(
                bottom: 24,
                child: Container(
                  height: 200,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      AnimatedOpacity(
                        opacity: isLoading ? 1 : 0,
                        duration: Duration(milliseconds: 600),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              height: 50,
                            ),
                            GestureDetector(
                              onTap: showAddNewTask,
                              child: Container(
                                height: 100,
                                width: 100,
                                child: Image.asset(
                                  'assets/add_task.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            Text(
                                AppLocalizations.of(context).translate(
                                  'Task',
                                ),
                                style: const TextStyle(
                                    color: const Color(0xffffffff),
                                    fontWeight: FontWeight.w700,
                                    fontFamily: "Inter",
                                    fontStyle: FontStyle.normal,
                                    fontSize: 13.0),
                                textAlign: TextAlign.center)
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          AnimatedOpacity(
                            opacity: isLoading ? 1 : 0,
                            duration: Duration(milliseconds: 450),
                            child: Column(
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    showAddNewStory();
                                  },
                                  child: Container(
                                    height: 100,
                                    width: 100,
                                    child: Image.asset(
                                      'assets/add_story.png',
                                    ),
                                  ),
                                ),
                                Text(
                                  AppLocalizations.of(context).translate(
                                    'Story',
                                  ),
                                  style: const TextStyle(
                                      color: const Color(0xffffffff),
                                      fontWeight: FontWeight.w700,
                                      fontFamily: "Inter",
                                      fontStyle: FontStyle.normal,
                                      fontSize: 13.0),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: SafeArea(
                              child: Transform.scale(
                                scale: 1.25,
                                child: FloatingActionButton(
                                  backgroundColor: Colors.white,
                                  onPressed: () {
                                    Future.delayed(Duration(milliseconds: 600),
                                        () {
                                      Navigator.of(context).pop();
                                    });
                                    setState(() {
                                      isLoading = !isLoading;
                                    });
                                  },
                                  child: Icon(
                                    Icons.close,
                                    size: 28,
                                    color: Color(0xff3c84f2),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      AnimatedOpacity(
                        opacity: isLoading ? 1 : 0,
                        duration: Duration(milliseconds: 200),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              height: 50,
                            ),
                            GestureDetector(
                              onTap: showAddNewPoint,
                              child: Container(
                                height: 100,
                                width: 100,
                                child: Image.asset(
                                  'assets/addDP.png',
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context).translate(
                                  'DisscussionPoint',
                                ),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: const Color(0xffffffff),
                                    fontWeight: FontWeight.w700,
                                    fontFamily: "Inter",
                                    fontStyle: FontStyle.normal,
                                    fontSize: 13.0),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
