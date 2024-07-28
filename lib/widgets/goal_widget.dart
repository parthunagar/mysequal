import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/models/PelotonGoal.dart';
import 'package:peloton/models/PelotonMember.dart';
import 'package:intl/intl.dart' as intl;
import 'package:peloton/widgets/peloton_profile_image.dart';
import 'NSbasicWidget.dart';

class GoalWidget extends StatelessWidget {
  final PelotonGoal goal;
  @override
  GoalWidget({this.goal});

  String getDateFrmated(Timestamp createdAt, context) {
    print(createdAt);
    DateTime parseDt =
        DateTime.fromMillisecondsSinceEpoch(createdAt.millisecondsSinceEpoch);
    print(parseDt);
    var newFormat = intl.DateFormat("MMM dd");
    return newFormat.format(parseDt);
  }

  @override
  Widget build(BuildContext context) {
    return NSBaseWidget(builder: (context, sizingInformation) {
      return Container(
        margin: EdgeInsets.fromLTRB(4, 15, 4, 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
                color: Color(0x29000000),
                offset: Offset(0, 0),
                blurRadius: 21,
                spreadRadius: 0)
          ],
          color: Color(goal.goalColor),
        ),
        //height: sizingInformation.scaleByHeight(190),
        child: Row(
          children: <Widget>[
            Container(
              width: 17,
              decoration: BoxDecoration(
                borderRadius: BorderRadiusDirectional.only(
                    topStart: Radius.circular(8),
                    bottomStart: Radius.circular(8)),
                color: Color(goal.goalColor),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadiusDirectional.only(
                      topEnd: Radius.circular(8),
                      bottomEnd: Radius.circular(8),
                    )),
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  //crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              constraints: BoxConstraints(maxWidth: 250),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: Color(goal.goalColor),
                              ),
                              padding: EdgeInsets.fromLTRB(12, 6, 12, 6),
                              child: Text(
                                goal.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Container(
                              padding: EdgeInsets.all(5),
                              height: 25,
                              child: goal.status == GoalStatus.done
                                  ? Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        Image.asset(
                                          'assets/check_task.png',
                                          height: 13.5,
                                          width: 13.5,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          'Done',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    )
                                  : Container(
                                      child: Text(
                                          AppLocalizations.of(context)
                                                  .translate('By') +
                                              ' ' +
                                              getDateFrmated(
                                                  goal.dueDate, context),
                                          style: const TextStyle(
                                              color: const Color(0xff00183c),
                                              fontWeight: FontWeight.w600,
                                              fontFamily: "Inter",
                                              fontStyle: FontStyle.normal,
                                              fontSize: 10.0),
                                          textAlign: TextAlign.center),
                                    ),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.black, width: 1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 8,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            // Text(
                            //   AppLocalizations.of(context).translate('GoalWhy'),
                            //   textAlign: TextAlign.start,
                            //   style: TextStyle(
                            //     color: const Color(0xff00183c),
                            //     fontWeight: FontWeight.w700,
                            //     fontFamily: "Inter",
                            //     fontStyle: FontStyle.normal,
                            //     fontSize: 16.5,
                            //   ),
                            // ),
                            Flexible(
                              child: Text(
                                goal.details,
                                maxLines: 2,
                                style: TextStyle(
                                  color: Color(0xff00183c),
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "Inter",
                                  fontStyle: FontStyle.normal,
                                ),
                              ),
                            ),
                            Container(
                              height: 40,
                              width: 35,
                              child:
                                  //  Image.asset(
                                  //   'assets/forwardarrow.png',
                                  //   matchTextDirection: true,
                                  //   color: Theme.of(context).accentColor,
                                  // )
                                  Icon(
                                Icons.arrow_forward_ios,
                                size: 20,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 12,
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            TasksCompletedPercentage(
                                tasksCount: goal.sharedInfo[
                                    'total_tasks'], //goal.tasks.length,
                                completedTasks:
                                    goal.sharedInfo['completed_tasks'],
                                color: Color(goal.goalColor)),
                            Container(
                              constraints: BoxConstraints(maxWidth: 80),
                              padding: const EdgeInsets.all(6.0),
                              child: Text(
                                  AppLocalizations.of(context)
                                      .translate('TasksCompleted'),
                                  maxLines: 2,
                                  style: const TextStyle(
                                      color: const Color(0xff00183c),
                                      fontWeight: FontWeight.w400,
                                      fontFamily: "Inter",
                                      fontStyle: FontStyle.normal,
                                      fontSize: 12.0)),
                            ),
                          ],
                        ),
                        PelotonsInGoal(
                          pelotons: goal.members,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      );
    });
  }
}

class PelotonsInGoal extends StatelessWidget {
  final List<dynamic> pelotons;

  Future<List<PelotonMember>> convertUserToMember(
      List<dynamic> arrrayOfUsers) async {
    List<PelotonMember> returnArray = [];

    List<dynamic> allusers = [];
    for (var element in arrrayOfUsers) {
      if (element is List) {
        for (var listitem in element) {
          allusers.add(listitem);
        }
      } else {
        allusers.add(element);
      }
    }
    for (DocumentReference item in allusers) {
      var snapshot = await item.get();
      if (snapshot.exists) {
        if (item.path.startsWith('users')) {
          returnArray.add(
              PelotonMember.fromJson(snapshot.data()['personal_information']));
        } else {
          returnArray.add(PelotonMember.fromJson(snapshot.data()));
        }
      }
    }
    return (returnArray);
  }

  @override
  PelotonsInGoal({this.pelotons});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: convertUserToMember(pelotons),
        builder: (_, data) {
          List<PelotonMember> pelotons = data.data;

          if (pelotons == null || pelotons.length == 0) {
            return Container();
          }
          List<Widget> profiles = [];
          pelotons.take(3).toList().asMap().forEach((index, element) {
            var item = Stack(
              alignment: Alignment.center,
              fit: StackFit.loose,
              children: <Widget>[
                Container(
                  height: 40,
                  width: 40,
                  padding: EdgeInsets.all(4),
                  margin: EdgeInsets.all(2),
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: index == 0
                            ? const Color(0xff3c84f2)
                            : Colors.transparent,
                        width: 2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: PelotonProfileImage(
                    member: element,
                    height: 40,
                  ),
                ),
                pelotons.length > 3 && index == 2
                    ? Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(17.5),
                        ),
                        height: 32,
                        width: 32,
                        child: Center(
                          child: Text(
                            '+${pelotons.length - 2}',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                    : Container()
              ],
            );
            profiles.add(item);
          });
          return Row(
            children: profiles,
            mainAxisAlignment: MainAxisAlignment.end,
          );
        });
  }
}

class TasksCompletedPercentage extends StatelessWidget {
  final Color color;
  final int tasksCount;
  final int completedTasks;
  @override
  TasksCompletedPercentage({this.color, this.tasksCount, this.completedTasks});
  @override
  Widget build(BuildContext context) {
    return NSBaseWidget(builder: (context, sizingInformation) {
      return Container(
        height: 50, //sizingInformation.scaleByWidth(50),
        width: 50, //sizingInformation.scaleByWidth(50),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Center(
              child: Text('$completedTasks/$tasksCount',
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontFamily: "Inter",
                      fontStyle: FontStyle.normal,
                      fontSize: 14.5)),
            ),
            CircularProgressIndicator(
              strokeWidth: 3.5,
              value: tasksCount > 0 ? completedTasks / tasksCount : 0,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ],
        ),
      );
    });
  }
}
