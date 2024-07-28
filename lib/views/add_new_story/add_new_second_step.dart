import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/managers/auth_provider.dart';
import 'package:peloton/models/PelotonGoal.dart';
import 'package:peloton/models/activities_types/goal_activities.dart';
import 'package:peloton/widgets/Activity_counter_widget.dart';
import 'package:peloton/widgets/slider_activity_widget.dart';
import 'package:peloton/widgets/true_false_activity_widget.dart';

class AddSecondStep extends StatefulWidget {
  final Function(String, dynamic) update;
  @override
  AddSecondStep({this.update});
  @override
  _AddSecondStepState createState() => _AddSecondStepState();
}

class _AddSecondStepState extends State<AddSecondStep> {
  addActivity(GoalJournalActivity newActivity) {
    widget.update('recover_program_journal', newActivity);
  }

  List<Widget> getActivities(List<PelotonGoal> goals) {
    List<Widget> result = [];
    Map<String, List<GoalJournalActivity>> filteredActivities = {};
    List<String> addedActivities = [];
    // List<GoalJournalActivity> activities = [];
    for (var goal in goals) {
      for (GoalJournalActivity item in goal.recoverProgram) {
        if (addedActivities.contains(item.name)) {
          continue;
        } else {
          item.relatedGoals = [
            {'title': '${goal.title}', 'color': goal.goalColor}
          ];
          addedActivities.add(item.name);

        }
        if (filteredActivities[goal.title] != null) {
          filteredActivities[goal.title].add(item);
        } else {
          filteredActivities[goal.title] = [item];
        }
      }

    }
    filteredActivities.forEach((key, value) {
      List<Widget> children = [];
      for (GoalJournalActivity act in value){
      if (act.type == 'yesno') {
        children.add(
          TrueFalseActivityWidget(
            activity: act,
            addActivity: addActivity,
          ),
        );
      } else if (act.type == 'stepper') {
        children.add(
          ActivityCounterWidget(
            activity: act,
            addActivity: addActivity,
          ),
        );
      } else if (act.type == 'slider') {
        children.add(
          SliderActivitywidget(
            activity: act,
            addActivity: addActivity,
          ),
        );
      }
      }
      children.insert(0, Container(
                        margin: EdgeInsetsDirectional.only(start:20,top:12),
                        height: 27,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(5.5),
                          ),
                          color: Color(
                            value.first.relatedGoals.first['color']),
                        ),
                        padding: EdgeInsets.fromLTRB(9, 5, 9, 5),
                        child: Text(
                          value.first.relatedGoals.first['title'],
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontFamily: "Inter",
                              fontStyle: FontStyle.normal,
                              fontSize: 13.0),
                        ),));
     Widget actcolumn =  Column(
       mainAxisAlignment: MainAxisAlignment.start,
       crossAxisAlignment: CrossAxisAlignment.start,
        children:children,
      );
      result.add(actcolumn);
      
    });
    

    return result.length > 0
        ? result
        : [
            Container(
              height: 200,
              child: Center(
                child: Text(
                    AppLocalizations.of(context).translate('NoActivities')),
              ),
            ),
          ];
  }

  @override
  Widget build(BuildContext context) {
    String myId = AuthProvider.of(context).auth.currentUserId;
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsetsDirectional.fromSTEB(20, 12, 12, 12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).accentColor,
              borderRadius: BorderRadiusDirectional.only(
                bottomEnd: Radius.circular(20),
                bottomStart: Radius.circular(20),
              ),
            ),
            child: Text(
              AppLocalizations.of(context)
                  .translate('AddStorySecondStepSubtitle'),
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Inter',
                  fontSize: 20,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Container(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('goals')
                    .where('patientid', isEqualTo: myId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (!snapshot.hasData)
                    return Center(
                      child: Text(
                        AppLocalizations.of(context).translate('NoData'),
                      ),
                    );
                  List<PelotonGoal> goals = [];
                  for (var goal in snapshot.data.documents) {
                    goals.add(PelotonGoal.fromJson(goal.data()));
                  }

                  return ListView(
                    
                     padding: EdgeInsets.only(bottom: 100),
                    children: getActivities(goals),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
