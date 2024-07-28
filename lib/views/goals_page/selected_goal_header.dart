import 'package:flutter/material.dart';
import 'package:peloton/models/PelotonGoal.dart';
import 'package:peloton/widgets/NSbasicWidget.dart';

class SelectedGoalHeader extends StatelessWidget {
  final PelotonGoal goal;
  final double height;

  SelectedGoalHeader({this.goal, this.height = kToolbarHeight});

  @override
  Widget build(BuildContext context) {
    return NSBaseWidget(builder: (context, sizingInformation) {
      return Container(
        height: sizingInformation.scaleByHeight(90),
        padding: EdgeInsets.only(left: 33, right: 33, bottom: 12),
        decoration: BoxDecoration(
            color: Color(goal.goalColor),
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(25),
              bottomLeft: Radius.circular(25),
            )),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              goal.title ,
              maxLines: 2,
              style: Theme.of(context).primaryTextTheme.headline3,
              overflow: TextOverflow.ellipsis,
            ),
            // SizedBox(
            //   height: 5,
            // ),
            // Text(
            //   goal.details,
            //   style: Theme.of(context).primaryTextTheme.headline4,
            // ),
          ],
        ),
      );
    });
  }
}
