import 'package:flutter/material.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/models/activities_types/goal_activities.dart';
import 'package:peloton/widgets/NSbasicWidget.dart';

class ActivityCounterWidget extends StatefulWidget {
  final GoalJournalActivity activity;
  final Function(GoalJournalActivity) addActivity;
  @override
  ActivityCounterWidget({this.activity, this.addActivity});
  @override
  _ActivityCounterWidgettState createState() => _ActivityCounterWidgettState();
}

class _ActivityCounterWidgettState extends State<ActivityCounterWidget> {
  GoalJournalActivity activity;
  @override
  void initState() {
    this.activity = widget.activity;
    super.initState();
  }

  increaseCount() {
    var newVal =
        activity.value != null ? activity.value + 1 : activity.defaultVal + 1;
    if (newVal > activity.maxValue) {
      newVal = activity.maxValue;
    }
    setState(() {
      activity.value = newVal;
      widget.addActivity(activity);
    });
  }

  decreaseCount() {
    var newVal =
        activity.value != null ? activity.value - 1 : activity.defaultVal - 1;
    if (newVal < activity.minValue) {
      newVal = activity.minValue;
    }
    setState(() {
      activity.value = newVal;
      widget.addActivity(activity);
    });
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
                    Row(
                      children: <Widget>[
                        Container(
                            width: sizingInformation.scaleByWidth(30),
                            height: sizingInformation.scaleByWidth(40),
                            child: Image.network(
                              activity.iconUrl ?? '',
                              width: 40,
                            )),
                        Container(
                          padding: EdgeInsets.all(8),
                          constraints: BoxConstraints(maxWidth: 100),
                          child: Text(
                            getActivityName(activity, context),
                            maxLines: null,
                            style: TextStyle(
                                color: const Color(0xff00183c),
                                fontWeight: FontWeight.w400,
                                fontFamily: "Inter",
                                fontStyle: FontStyle.normal,
                                fontSize: 14.0),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        GestureDetector(
                          onTap: decreaseCount,
                          child: AnimatedContainer(
                            width: sizingInformation.scaleByWidth(40),
                            height: sizingInformation.scaleByWidth(40),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.blue,
                            ),
                            duration: Duration(milliseconds: 200),
                            child: Center(
                              child: Text(
                                "-",
                                style: TextStyle(
                                    color: Color(0xffffffff),
                                    fontWeight: FontWeight.w700,
                                    fontFamily: "Inter",
                                    fontStyle: FontStyle.normal,
                                    fontSize: 22.0),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Container(
                          constraints: BoxConstraints(
                              minWidth: sizingInformation.scaleByWidth(55)),
                          padding: EdgeInsets.fromLTRB(12, 12, 12, 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(33)),
                            color: const Color(0xfff1f1f1),
                          ),
                          child: Text(
                              activity.value != null
                                  ? activity.value?.toInt().toString()
                                  : activity.defaultVal.toInt().toString(),
                              style: TextStyle(
                                  color: const Color(0xff00183c),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "Inter",
                                  fontStyle: FontStyle.normal,
                                  fontSize: sizingInformation.scaleByWidth(14)),
                              textAlign: TextAlign.center),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        GestureDetector(
                          onTap: increaseCount,
                          child: AnimatedContainer(
                            width: sizingInformation.scaleByWidth(40),
                            height: sizingInformation.scaleByWidth(40),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.blue),
                            duration: Duration(milliseconds: 200),
                            child: Center(
                              child: Text(
                                "+",
                                style: TextStyle(
                                    color: Color(0xffffffff),
                                    fontWeight: FontWeight.w700,
                                    fontFamily: "Inter",
                                    fontStyle: FontStyle.normal,
                                    fontSize:
                                        sizingInformation.scaleByWidth(22)),
                              ),
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
