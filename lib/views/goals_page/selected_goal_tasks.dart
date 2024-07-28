import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/models/pelotonTask.dart';
import 'package:intl/intl.dart' as intl;

class SelectedGoalTask extends StatefulWidget {
  final PelotonTask task;
  @override
  SelectedGoalTask({this.task});
  @override
  _SelectedGoalTaskState createState() => _SelectedGoalTaskState();
}

class _SelectedGoalTaskState extends State<SelectedGoalTask> {
  String getDateFrmated(Timestamp createdAt) {
    DateTime parseDt =
        DateTime.fromMillisecondsSinceEpoch(createdAt.millisecondsSinceEpoch);
    var newFormat = intl.DateFormat("dd MMM yyyy");
    return newFormat.format(parseDt);
  }

  Widget getTaskIcon() {
    switch (widget.task.status) {
      case TaskStatus.notDetermined:
        return Icon(
          Icons.radio_button_unchecked,
        );
      case TaskStatus.declined:
        return Image.asset(
          'assets/decline_task.png',
          height: 21,
          width: 21,
        );
      case TaskStatus.partialy:
        return Image.asset(
          'assets/task_partialy_done.png',
          height: 21,
          width: 21,
        );
      case TaskStatus.done:
        return Image.asset(
          'assets/check_task.png',
          height: 21,
          width: 21,
        );
        default:
        return Container();
    }
  }

  String getTaskStatus() {
    switch (widget.task.status) {
      case TaskStatus.done:
        return AppLocalizations.of(context).translate('Completed');
      case TaskStatus.partialy:
        return AppLocalizations.of(context).translate('Partially');
      case TaskStatus.declined:
        return AppLocalizations.of(context).translate('Decline');
      case TaskStatus.notDetermined:
        return '';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              color: const Color(0x1a000000),
              offset: Offset(0, 0),
              blurRadius: 42,
              spreadRadius: 0)
        ],
      ),
      margin: EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(width: 40, child: getTaskIcon()
              //  DashedLine(
              //   dashHeight: 10,
              // ),
              ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Text(
                      widget.task.title,
                      style: TextStyle(
                          color: const Color(0xff00183c),
                          fontWeight: FontWeight.w500,
                          fontFamily: "Inter",
                          fontStyle: FontStyle.normal,
                          fontSize: 18),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Container(
                    padding: EdgeInsets.all(5),
                    child: widget.task.status != TaskStatus.notDetermined
                        ? Text(
                            getTaskStatus(),
                            style: TextStyle(
                                color: const Color(0xff00cdc1),
                                fontWeight: FontWeight.w700,
                                fontFamily: "Inter",
                                fontStyle: FontStyle.normal,
                                fontSize: 15.0),
                          )
                        : Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                                // AppLocalizations.of(context).translate('By') +
                                //     ' ' +
                                getDateFrmated(widget.task.dueDate),
                                style: const TextStyle(
                                    color: const Color(0xff00183c),
                                    fontWeight: FontWeight.w600,
                                    fontFamily: "Inter",
                                    fontStyle: FontStyle.normal,
                                    fontSize: 10.0),
                                textAlign: TextAlign.center),
                          ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class DashedLine extends StatelessWidget {
  final double dashHeight;

  const DashedLine({this.dashHeight = 5.0});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      final boxHeight = constraints.constrainHeight();

      final dashCount = (boxHeight / (2 * dashHeight)).floor();
      return Flex(
        children: List.generate(dashCount, (index) {
          return SizedBox(
            width: 0.5,
            height: dashHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(color: Colors.black),
            ),
          );
        }),
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        direction: Axis.vertical,
      );
    });
  }
}
