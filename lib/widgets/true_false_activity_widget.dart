import 'package:flutter/material.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/models/activities_types/goal_activities.dart';
import 'package:peloton/widgets/NSbasicWidget.dart';

class TrueFalseActivityWidget extends StatefulWidget {
  final GoalJournalActivity activity;
  final Function(GoalJournalActivity) addActivity;
  @override
  TrueFalseActivityWidget({this.activity, this.addActivity});
  @override
  _TrueFalseActivityWidgetState createState() =>
      _TrueFalseActivityWidgetState();
}

class _TrueFalseActivityWidgetState extends State<TrueFalseActivityWidget> {
  GoalJournalActivity activity;
  @override
  void initState() {
    this.activity = widget.activity;
    super.initState();
  }
  String getActivityName(GoalJournalActivity activity, context) {
    if (activity.id != null) {
      var name = AppLocalizations.of(context).translate('${activity.id}');

      if (name != null) {
        return name;
      } else {
        var name = AppLocalizations.of(context).translate('${activity.name}');
        if (name != null) {
          return name;
        } else {
          return '';
        }
      }
    }else{
         var name = AppLocalizations.of(context).translate('${activity.name}');
        if (name != null) {
          return name;
        } else {
          return '';
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return NSBaseWidget(builder: (context, sizingInformation) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    color: const Color(0x1a000000),
                    offset: Offset(0, 0),
                    blurRadius: 5,
                    spreadRadius: 0)
              ],
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 8),
            padding: EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      width: sizingInformation.scaleByWidth(30),
                      height: sizingInformation.scaleByWidth(40),
                      child: Image.network(activity.iconUrl ?? '',width: 40),
                    ),
                    Expanded(
                      child: Text(
                        getActivityName(activity,context),
                        
                        maxLines: 2,
                        style: TextStyle(
                            color: const Color(0xff00183c),
                            fontWeight: FontWeight.w400,
                            fontFamily: "Inter",
                            fontStyle: FontStyle.normal,
                            fontSize:
                                sizingInformation.scaleByWidth(14)),
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              activity.value = 0;
                              widget.addActivity(activity);
                            });
                          },
                          child: AnimatedContainer(
                            padding: EdgeInsets.fromLTRB(15, 8, 15, 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: activity.value == 0
                                  ? Colors.blue
                                  : Color(0xfff1f1f1),
                            ),
                            duration: Duration(milliseconds: 200),
                            child: Text(
                              AppLocalizations.of(context).translate('No'),
                              style: TextStyle(
                                  color: activity.value == 0
                                      ? Colors.white
                                      : Color(0xff00183c),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "Inter",
                                  fontStyle: FontStyle.normal,
                                  fontSize:
                                      sizingInformation.scaleByWidth(14)),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: sizingInformation.scaleByWidth(12),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              activity.value = 1;
                              widget.addActivity(activity);
                            });
                          },
                          child: AnimatedContainer(
                            padding: EdgeInsets.fromLTRB(15, 8, 15, 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: activity.value == 1
                                  ? Colors.blue
                                  : Color(0xfff1f1f1),
                            ),
                            duration: Duration(milliseconds: 200),
                            child: Text(
                              AppLocalizations.of(context).translate('Yes'),
                              style: TextStyle(
                                  color: activity.value == 1
                                      ? Colors.white
                                      : Color(0xff00183c),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "Inter",
                                  fontStyle: FontStyle.normal,
                                  fontSize:
                                      sizingInformation.scaleByWidth(14)),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
          // Container(
          //   margin: EdgeInsets.only(
          //     left: 20,
          //     right: 20,
          //   ),
          //   child: Wrap(
          //       children: widget.activity.relatedGoals
          //           .map((e) => Container(
          //                 height: 27,
          //                 decoration: BoxDecoration(
          //                   borderRadius: BorderRadius.all(
          //                     Radius.circular(5.5),
          //                   ),
          //                   color: e['color'],
          //                 ),
          //                 padding: EdgeInsets.fromLTRB(9, 5, 9, 5),
          //                 child: Text(
          //                   e['title'],
          //                   style: TextStyle(
          //                       color: Colors.white,
          //                       fontWeight: FontWeight.w700,
          //                       fontFamily: "Inter",
          //                       fontStyle: FontStyle.normal,
          //                       fontSize: 13.0),
          //                 ),
          //               ))
          //           .toList()),
          // )
        ],
      );
    });
  }
}
