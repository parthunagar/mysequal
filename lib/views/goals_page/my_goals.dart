import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/managers/analytics_actions.dart';
import 'package:peloton/managers/analytics_manager.dart';
import 'package:peloton/managers/auth_provider.dart';
import 'package:peloton/models/PelotonGoal.dart';
import 'package:peloton/views/goals_page/my_goals_header.dart';
import 'package:peloton/views/goals_page/selected_goal.dart';
import 'package:peloton/widgets/goal_widget.dart';

class MyGoals extends StatefulWidget {
  @override
  _MyGoalsState createState() => _MyGoalsState();
}

class _MyGoalsState extends State<MyGoals>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<MyGoals> {
  showSelectedGoal(PelotonGoal goal) {
    AnalyticsManager.instance.addEvent(AnalytictsActions.expandGoal,
        {"goal_id": goal.id, "title": goal.title});
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SelectedGoalWidget(goal: goal)),
    );
  }

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    String myId = AuthProvider.of(context).auth.currentUserId;
    var orgIDs =
        AuthProvider.of(context).auth.currentUserDoc['organizationsID'] ?? [];
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        MyGoalsHeader(),
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: Container(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('goals')
                    .where('patientid', isEqualTo: myId)
                    .where('orginization',
                        whereIn: (orgIDs.length > 0 ? orgIDs : [' ']))
                    .orderBy('due_date')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.error == null && snapshot.data == null) {
                    return Center(
                      child: Text(
                        AppLocalizations.of(context)
                            .translate("NoGoalsMessage"),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  // if (snapshot.connectionState == ConnectionState.waiting) {
                  //   return Center(
                  //     child: CircularProgressIndicator(),
                  //   );
                  // }
                  if (snapshot.data == null) {
                    return Center(
                      child: Text(
                          AppLocalizations.of(context)
                              .translate("NoGoalsMessage"),
                          textAlign: TextAlign.center),
                    );
                  }
                  if (snapshot.hasData && snapshot.data.documents.length == 0)
                    return Center(
                      child: Text(
                          AppLocalizations.of(context)
                              .translate("NoGoalsMessage"),
                          textAlign: TextAlign.center),
                    );

                  return ListView.builder(
                    itemBuilder: (cntx, index) {
                      DocumentSnapshot ds = snapshot.data.documents[index];
                      //   Map<String,dynamic> map = snapshot.data.documents[index];

                      PelotonGoal goal = PelotonGoal.fromJson(ds.data());

                      goal.id = ds.id;
                      return GestureDetector(
                        child: GoalWidget(
                          goal: goal,
                        ),
                        onTap: () {
                          showSelectedGoal(goal);
                        },
                      );
                    },
                    itemCount: snapshot.data.documents.length,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
