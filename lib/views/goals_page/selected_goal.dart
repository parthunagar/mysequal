import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/managers/auth_provider.dart';
import 'package:peloton/models/PelotonGoal.dart';
import 'package:peloton/views/goals_page/expanded_container.dart';
import 'package:peloton/views/goals_page/grid_string.dart';
import 'package:peloton/views/goals_page/selected_goal_header.dart';
import 'package:peloton/views/goals_page/selected_goal_tasks.dart';
import 'package:peloton/models/pelotonTask.dart';
import 'package:peloton/views/selected_task_page.dart';
import 'package:peloton/widgets/pelotons_team.dart';

class SelectedGoalWidget extends StatefulWidget {
  final PelotonGoal goal;
  @override
  SelectedGoalWidget({this.goal});
  @override
  _SelectedGoalWidgetState createState() => _SelectedGoalWidgetState();
}

class _SelectedGoalWidgetState extends State<SelectedGoalWidget> {
  showSelectedTask(PelotonTask task, isMyTask) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SelectedTask(
                task: task,
                isMyTask: isMyTask,
              )),
    );
  }

  String getBottomTitle() {
    var comletedTasks = widget.goal.sharedInfo['completed_tasks'];
    var totalTasks = widget.goal.sharedInfo['total_tasks'];
    if (comletedTasks == 0) {
      return totalTasks > 0
          ? AppLocalizations.of(context).translate(
                              'StartTasks',
                            )
          : AppLocalizations.of(context).translate(
                              'NoTasksYet',
                            );
    } else if (comletedTasks == totalTasks) {
      return AppLocalizations.of(context).translate(
                              'CompleteTasks',
                            );
    } else if (comletedTasks == 1) {
      return '$comletedTasks ' + AppLocalizations.of(context).translate(
                              'TasksBehindYou',
                            );
    } else {
      return '$comletedTasks ' + AppLocalizations.of(context).translate(
                              'TaskBehindYou',
                            );
    }
  }

  @override
  Widget build(BuildContext context) {
    String _currentUserId = AuthProvider.of(context).auth.currentUserId;
    var comletedTasks = widget.goal.sharedInfo['completed_tasks'];
    var totalTasks = widget.goal.sharedInfo['total_tasks'];
    if (widget.goal.tasks == null) {
      widget.goal.tasks = [];
    }
    print('selected goal id :');
    print(widget.goal.id);
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[

        ],
        backgroundColor: Color(widget.goal.goalColor),
        elevation: 0,
      ),
      backgroundColor: Color(0xfff4f5f9),
      body: Stack(
        alignment: Alignment.topCenter,
        fit: StackFit.expand,
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                child: SelectedGoalHeader(
                  goal: widget.goal,
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.only(bottom: 80),
                  children: <Widget>[
                    //add the goal to pelotons team to add new member
                    MyPelotonsTeam(pelotons: widget.goal.members,goal: widget.goal,),
                    ExpandbleContainer(
                          answer: widget.goal.details,
                          question: AppLocalizations.of(context).translate(
                            'WhyImportant',
                          ),
                        ),
        
                    widget.goal.whatCanHelp != null &&
                            widget.goal.whatCanHelp.length > 0
                        ? ExpandbleContainer(
                            answer: widget.goal.whatCanHelp,
                            question: AppLocalizations.of(context).translate(
                              'WhatwillHelp',
                            ),
                          )
                        : Container(),
                    widget.goal.whatCanPrevent != null &&
                            widget.goal.whatCanPrevent.length > 0
                        ? ExpandbleContainer(
                            answer: widget.goal.whatCanPrevent,
                            question: AppLocalizations.of(context).translate(
                              'whatwillPrevent',
                            ),
                          )
                        : Container(),
                            widget.goal.successCriteria != null &&
                            widget.goal.successCriteria.length > 0
                        ? ExpandbleContainer(
                            answer: widget.goal.successCriteria,
                            question: AppLocalizations.of(context).translate(
                              'SuccessCriteria',
                            ),
                          )
                        : Container(),
                    GridStrings(
                      goal: widget.goal,
                    ),
                    Container(
                      margin: EdgeInsetsDirectional.only(
                        start: 20,
                      ),
                      padding: EdgeInsets.only(bottom: 8, top: 16),
                      child: Text(
                        AppLocalizations.of(context).translate(
                          'MyTasks',
                        ),
                        style: TextStyle(
                          color: Color(0xff00183c),
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('tasks')
                          .where('goal_data.goal_id', isEqualTo: widget.goal.id).orderBy('due_date')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.data == null ||
                            snapshot.data.documents.length == 0) {
                          return Container();
                        }

                        if (snapshot.hasData) {
                          return ListView.builder(
                            padding: EdgeInsets.only(bottom:40),
                            physics: NeverScrollableScrollPhysics(),
                            key: UniqueKey(),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              PelotonTask _currentTask = PelotonTask.fromJson(
                                  snapshot.data.documents[index].data());

                              _currentTask.id =
                                  snapshot.data.documents[index].id;

                              var isMyTask =
                                  _currentTask.assignee == _currentUserId ||
                            _currentTask.assignee == '';
                              return GestureDetector(
                                  onTap:  () {
                                          showSelectedTask(
                                              _currentTask, isMyTask);
                                        },
                                  child: SelectedGoalTask(task: _currentTask));
                            },
                            itemCount: snapshot.data.documents.length,
                          );
                        } else {
                          return Container();
                        }
                      },
                    )
                  ],
                ),
              ),

            ],
          ),
          Positioned(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: const Color(0x1a000000),
                      offset: Offset(0, 0),
                      blurRadius: 10,
                      spreadRadius: 0)
                ],
              ),
              height: 90,
            ),
            bottom: 0,
            right: 0,
            left: 0,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.transparent,
              child: SafeArea(
                child: Column(
                  children: <Widget>[
                    totalTasks > 0
                        ? Stack(
                            alignment: Alignment.center,
                            fit: StackFit.loose,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(14),
                                decoration: ShapeDecoration(
                                  color: Colors.white,
                                  shape: CircleBorder(),
                                ),
                                height: 100,
                                width: 100,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3.5,
                                  value: comletedTasks / totalTasks,
                                  backgroundColor:
                                      Color(widget.goal.goalColor).withOpacity(0.2),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(widget.goal.goalColor)),
                                ),
                              ),
                              Text(('$comletedTasks/$totalTasks'),
                                  style: TextStyle(
                                      color: Color(widget.goal.goalColor),
                                      fontWeight: FontWeight.w700,
                                      fontFamily: "Inter",
                                      fontStyle: FontStyle.normal,
                                      fontSize: 15)),
                            ],
                          )
                        : Container(),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0, left: 8.0),
                      child: Text(
                        getBottomTitle(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xff00183c),
                          fontWeight: FontWeight.w700,
                          fontFamily: "Inter",
                          fontStyle: FontStyle.normal,
                          fontSize: 21.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
