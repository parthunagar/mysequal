import 'package:flutter/material.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/models/activities_types/goal_activities.dart';

class SliderActivitywidget extends StatefulWidget {
  final GoalJournalActivity activity;
  final Function(GoalJournalActivity) addActivity;
  @override
  SliderActivitywidget({this.activity, this.addActivity});
  @override
  _SliderActivitywidgetState createState() => _SliderActivitywidgetState();
}

class _SliderActivitywidgetState extends State<SliderActivitywidget> {
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
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(2),
                    width: 30,
                    height: 30,
                    child: Image.network(activity.iconUrl ?? '', width: 40),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Text(
                      getActivityName(activity, context),
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
              Container(
                margin: EdgeInsets.only(left: 5, right: 5),
                child: SliderTheme(
                  data: SliderThemeData(
                    thumbColor: Theme.of(context).accentColor,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
                    activeTrackColor:
                        Theme.of(context).accentColor.withOpacity(0.3),
                    trackHeight: 10,
                    tickMarkShape: SliderTickMarkShape.noTickMark,
                  ),
                  child: Slider(
                    inactiveColor: Colors.grey.withOpacity(0.4),
                    max: activity.maxValue.toDouble(),
                    min: activity.minValue.toDouble(),
                    value: activity.value != null
                        ? activity.value.toDouble()
                        : activity.defaultVal.toDouble(),
                    label: activity.value != null
                        ? '${activity.value}'
                        : '${activity.defaultVal}',
                    divisions: activity.maxValue.toInt(),
                    onChanged: (value) {
                      setState(() {
                        activity.value = value.toInt();

                        widget.addActivity(activity);
                      });
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 20.0, left: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      activity.minValue.toInt().toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: const Color(0xff00183c),
                          fontWeight: FontWeight.w400,
                          fontFamily: "Inter",
                          fontStyle: FontStyle.normal,
                          fontSize: 14.0),
                    ),
                    Text(
                      activity.maxValue.toInt().toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: const Color(0xff00183c),
                          fontWeight: FontWeight.w400,
                          fontFamily: "Inter",
                          fontStyle: FontStyle.normal,
                          fontSize: 14.0),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // ),
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
        )
      ],
    );
  }
}
