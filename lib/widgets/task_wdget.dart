import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/models/PelotonUser.dart';
import 'package:peloton/models/pelotonTask.dart';
import 'package:intl/intl.dart' as intl;
import 'package:peloton/models/peloton_profissional.dart';
import 'package:peloton/widgets/NSbasicWidget.dart';

class TaskWidget extends StatefulWidget {
  final PelotonTask task;
  final bool shouldShowDate;
  final bool isMyTask;
  @override
  TaskWidget({this.task, this.shouldShowDate, this.isMyTask});

  @override
  _TaskWidgetState createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
  var shouldOpen = false;

  TaskStatus taskStatus;
  Image statusImage;

  _showTaskOptions() {
    setState(() {
      shouldOpen = !shouldOpen;
    });
  }

  Stream firebaseStream;
  @override
  initState() {
    if (widget.task.assignee != null && widget.task.assignee.length > 0) {
      firebaseStream = FirebaseFirestore.instance
          .doc('users/${widget.task.assignee}')
          .snapshots();
    }
    _setTaskstatus(widget.task.status);
    super.initState();
  }

  _setTaskstatus(TaskStatus newStatus) {
    widget.task.status = newStatus;
    switch (newStatus) {
      case TaskStatus.done:
        statusImage = Image.asset(
          'assets/check_task.png',
          height: 23,
          width: 23,
        );
        break;
      case TaskStatus.declined:
        statusImage = Image.asset(
          'assets/decline_task.png',
          fit: BoxFit.contain,
          height: 23,
          width: 23,
        );
        break;
      case TaskStatus.partialy:
        statusImage = Image.asset(
          'assets/task_partialy_done.png',
          height: 23,
          width: 23,
        );
        break;
      case TaskStatus.notDetermined:
        statusImage = null;
        break;
    }
    taskStatus = newStatus;
    widget.task.updateTaskStatus(newStatus);
  }

  bool isPastdue(Timestamp taskDate) {
    var taskDateTime = taskDate.toDate();
    var hoursDelta = (23 - taskDateTime.hour);
    var now = DateTime.now();
    taskDateTime = taskDateTime.add(Duration(hours: hoursDelta));

    bool result = taskDateTime.isBefore(now);

    return result;
  }

  String getTaskTime(Timestamp createdAt) {
    DateTime parseDt =
        DateTime.fromMillisecondsSinceEpoch(createdAt.millisecondsSinceEpoch);
    var newFormat = intl.DateFormat('MMM d, EEEE');
    String updatedDt = newFormat.format(parseDt);
    return updatedDt;
  }

  PelotonProfissional getUserFromJson(AsyncSnapshot<dynamic> snapshot) {
    var patient = PelotonUser.fromJson(snapshot.data.data);
    var personal = PersonalInformation(
      name: patient.firstName + ' ' + patient.lastName,
      profileImage: patient.profileImage,
    );
    return PelotonProfissional(personalInformation: personal);
  }

  String getInitials(name) {
    List<String> nameInits = name.split(' ');
    if (nameInits.length > 1) {
      return nameInits[0][0] + nameInits[1][0];
    } else {
      return nameInits[0][0];
    }
  }

  Widget getProfileImage(user) {
    return user.personalInformation.profileImage != null &&
            user.personalInformation.profileImage.length > 1
        ? Center(
            child: CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(
                user.personalInformation.profileImage,
              ),
            ),
          )
        : Container(
            height: 35,
            width: 35,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(35 / 2),
                color: Colors.grey.withOpacity(0.5)),
            child: Center(
                child: Text(
              getInitials(user.personalInformation.name),
              style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700),
            )),
          );
  }

  @override
  Widget build(BuildContext context) {
    
    return NSBaseWidget(
      builder: (context, sizingInformation) {
        double screenWidth = MediaQuery.of(context).size.width;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            widget.shouldShowDate
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                            bottom: 5, start: 15, top: 5),
                        child: Text(getTaskTime(widget.task.dueDate),
                            style: const TextStyle(
                                color: const Color(0xff00183c),
                                fontWeight: FontWeight.w700,
                                fontFamily: "Inter",
                                fontStyle: FontStyle.normal,
                                fontSize: 16.5),
                            textAlign: TextAlign.left),
                      ),
                    ],
                  )
                : Container(),
            Container(
              margin: EdgeInsetsDirectional.only(
                  start: 8, end: 8, bottom: 5, top: 8),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color: Color(0x29000000),
                      offset: Offset(0, 0),
                      blurRadius: 21,
                      spreadRadius: 0)
                ],
                borderRadius: BorderRadius.all(Radius.circular(8)),
                color: const Color(0xffffffff),
              ),
              width: screenWidth * 0.95,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xffffffff),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    height: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        GestureDetector(
                          onTap: widget.isMyTask ? _showTaskOptions : null,
                          child: Container(
                            width: 22,
                            height: 100,
                            margin: EdgeInsets.all(10),
                            key: UniqueKey(),
                            child: statusImage != null
                                ? statusImage
                                : Icon(
                                    Icons.radio_button_unchecked,
                                    size: 24,
                                  ),
                          ),
                        ),
                        Container(
                          child: VerticalDivider(
                            indent: 0,
                            endIndent: 0,
                            thickness: 1,
                            color: Color(0xff3c84f2),
                            width: 1,
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text(
                                    widget.task.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    //widget.task.title,
                                    style: TextStyle(
                                      decoration:
                                          widget.task.status == TaskStatus.done
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
                                      color: Color(0xff00183c),
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Flexible(
                                      child: Container(
                                        padding:
                                            EdgeInsets.fromLTRB(8, 4, 8, 5),
                                        child: Text(
                                          widget.task.goal,
                                          maxLines: 1,
                                          softWrap: true,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(3),
                                          ),
                                          color: Color(widget.task.taskColor),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container()
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: 90,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Expanded(
                                child: widget.isMyTask
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.blue,
                                        ),
                                      )
                                    : Container(
                                        padding:
                                            EdgeInsetsDirectional.only(end: 12),
                                        child: (widget.task.assignee != null &&
                                                widget.task.assignee.length > 1)
                                            ? StreamBuilder(
                                                stream: firebaseStream,
                                                builder: (context, snapshot) {
                                                  if (snapshot.data == null) {
                                                    return Container();
                                                  }
                                                  if (snapshot.data.data ==
                                                          null ||
                                                      snapshot.connectionState ==
                                                          ConnectionState
                                                              .waiting) {
                                                    return Container();
                                                  }
                                                  var user = PelotonProfissional
                                                      .fromJson(
                                                          snapshot.data.data());

                                                  return Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: <Widget>[
                                                      getProfileImage(user)
                                                    ],
                                                  );
                                                },
                                              )
                                            : Container(
                                                child: Text('NA'),
                                              ),
                                      ),
                              ),
                              isPastdue(widget.task.dueDate) &&
                                      taskStatus == TaskStatus.notDetermined
                                  ? Container(
                                      padding: EdgeInsets.all(6),
                                      height: 35,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[
                                          Expanded(
                                            child: Text(
                                              AppLocalizations.of(context)
                                                      .translate('PastDue') +
                                                  ' ',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                              textAlign: TextAlign.end,
                                              style: TextStyle(
                                                  color: Color(
                                                      0xffc02e2f), //const Color(0xffc02e2f),
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: "Inter",
                                                  fontStyle: FontStyle.normal,
                                                  fontSize: 13.0),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  : Container(),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: this.shouldOpen ? 0.5 : 0.0,
                    color: Colors.grey,
                  ),
                  AnimatedContainer(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    curve: Curves.easeIn,
                    duration: Duration(milliseconds: 250),
                    height: shouldOpen ? 44 : 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            margin: EdgeInsetsDirectional.only(end: 0.5),
                            decoration: BoxDecoration(
                              color: taskStatus == TaskStatus.done
                                  ? Color(0xffaaccff)
                                  : Colors.white,
                              borderRadius: BorderRadiusDirectional.only(
                                bottomStart: Radius.circular(8),
                              ),
                            ),
                            child: FlatButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                setState(() {
                                  shouldOpen = !shouldOpen;
                                });
                                Future.delayed(Duration(milliseconds: 300), () {
                                  if (widget.task.status == TaskStatus.done) {
                                    _setTaskstatus(TaskStatus.notDetermined);
                                  } else {
                                    _setTaskstatus(TaskStatus.done);
                                  }
                                });
                              },
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Image.asset(
                                    'assets/check_task.png',
                                    height: sizingInformation.scaleByWidth(18),
                                    width: sizingInformation.scaleByWidth(18),
                                  ),
                                  SizedBox(
                                    width: sizingInformation.scaleByWidth(5),
                                  ),
                                  Text(
                                    AppLocalizations.of(context)
                                        .translate('Done'),
                                    style: TextStyle(
                                        fontSize:
                                            sizingInformation.scaleByWidth(13),
                                        fontWeight: FontWeight.w700,
                                        color: taskStatus == TaskStatus.done
                                            ? Colors.white
                                            : Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            color: taskStatus == TaskStatus.partialy
                                ? Color(0xffaaccff)
                                : Colors.white,
                            child: FlatButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                setState(() {
                                  shouldOpen = !shouldOpen;
                                });
                                Future.delayed(Duration(milliseconds: 300), () {
                                  if (widget.task.status ==
                                      TaskStatus.partialy) {
                                    _setTaskstatus(TaskStatus.notDetermined);
                                  } else {
                                    _setTaskstatus(TaskStatus.partialy);
                                  }
                                });
                              },
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Image.asset(
                                    'assets/task_partialy_done.png',
                                    width: sizingInformation.scaleByWidth(18),
                                    height: sizingInformation.scaleByWidth(18),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    AppLocalizations.of(context)
                                        .translate('Partially'),
                                    style: TextStyle(
                                        fontSize:
                                            sizingInformation.scaleByWidth(13),
                                        fontWeight: FontWeight.w700,
                                        color: taskStatus == TaskStatus.partialy
                                            ? Colors.white
                                            : Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsetsDirectional.only(start: 0.5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadiusDirectional.only(
                                bottomEnd: Radius.circular(8),
                              ),
                              color: taskStatus == TaskStatus.declined
                                  ? Color(0xffaaccff)
                                  : Colors.white,
                            ),
                            child: FlatButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                setState(() {
                                  shouldOpen = !shouldOpen;
                                });
                                Future.delayed(Duration(milliseconds: 300), () {
                                  if (widget.task.status ==
                                      TaskStatus.declined) {
                                    _setTaskstatus(TaskStatus.notDetermined);
                                  } else {
                                    _setTaskstatus(TaskStatus.declined);
                                  }
                                });
                              },
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Image.asset(
                                    'assets/decline_task.png',
                                    width: sizingInformation.scaleByWidth(18),
                                    height: sizingInformation.scaleByWidth(18),
                                  ),
                                  SizedBox(
                                    width: sizingInformation.scaleByWidth(5),
                                  ),
                                  Text(
                                    AppLocalizations.of(context)
                                        .translate('Decline'),
                                    style: TextStyle(
                                        fontSize:
                                            sizingInformation.scaleByWidth(13),
                                        fontWeight: FontWeight.w700,
                                        color: taskStatus == TaskStatus.declined
                                            ? Colors.white
                                            : Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
