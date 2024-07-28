import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/managers/analytics_actions.dart';
import 'package:peloton/managers/analytics_manager.dart';
import 'package:peloton/models/PelotonUser.dart';
import 'package:peloton/models/pelotonTask.dart';
import 'package:intl/intl.dart' as intl;
import 'package:peloton/models/peloton_profissional.dart';
import 'package:peloton/views/add_new_ptd/add_new_point_td.dart';
import 'package:peloton/widgets/done_button.dart';
import 'package:url_launcher/url_launcher.dart';

import 'home_page/reach_for_help.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';

class SelectedTask extends StatefulWidget {
  final PelotonTask task;
  final bool isMyTask;
  @override
  SelectedTask({this.task, this.isMyTask});
  @override
  _SelectedTaskState createState() => _SelectedTaskState();
}

class _SelectedTaskState extends State<SelectedTask> {
  
  bool shouldShowMore = false;
  TapGestureRecognizer tapRecognizer;
  _setTaskstatus(TaskStatus newStatus) {
    AnalyticsManager.instance.addEvent(AnalytictsActions.updateTaskSelected, null);
    if (!widget.isMyTask) {
      return;
    }
    setState(() {
      widget.task.status = newStatus;
      widget.task.updateTaskStatus(newStatus);
    });
  }

  _launchURL() async {
    var url = widget.task.url;
    var fullUrl = '';
    if (url == null || url.length == 0 || url == 'https://') {
      return;
    }
    if (!url.startsWith('http')) {
      fullUrl = 'https://' + url;
    }else{
      fullUrl = url;
    }
    if (await canLaunch(fullUrl)) {
      await launch(fullUrl);
    } else {
      var urlnew = 'https://www.google.com/search?q=$fullUrl';
      await launch(urlnew);
      //throw 'Could not launch ${widget.task.url}';
    }
  }

  OverlayEntry overlayEntry;
  showOverlay(BuildContext context) {
    if (overlayEntry != null) return;
    OverlayState overlayState = Overlay.of(context);
    overlayEntry = OverlayEntry(builder: (context) {
      return Positioned(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          right: 0.0,
          left: 0.0,
          child: InputDoneView(
            onDone: () {
              print(_controller.text);
              widget.task.addNotes(_controller.text);
            },
          ));
    });

    overlayState.insert(overlayEntry);
  }

  removeOverlay() {
    if (overlayEntry != null) {
      overlayEntry.remove();
      overlayEntry = null;
    }
  }

  String getTaskTime(Timestamp createdAt) {
    DateTime parseDt =
        DateTime.fromMillisecondsSinceEpoch(createdAt.millisecondsSinceEpoch);
    var newFormat = intl.DateFormat('MMM d, EEEE');
    String updatedDt = newFormat.format(parseDt);
    return updatedDt;
  }

  FocusNode commentFocusNode = new FocusNode();

  TextEditingController _controller;
  @override
  void initState() {
    tapRecognizer = TapGestureRecognizer()..onTap = _handlePress;

    _controller = TextEditingController(text: widget.task.statusNotes);
    KeyboardVisibilityNotification().addNewListener(onHide: () {
      removeOverlay();
    });
    commentFocusNode.addListener(() {
      bool hasFocus = commentFocusNode.hasFocus;
      if (hasFocus) {
        showOverlay(context);
      } else {
        removeOverlay();
      }
    });

    super.initState();
  }

  String getInitials(name) {
    List<String> nameInits = name.split(' ');
    if (nameInits.length > 1) {
      return nameInits[0][0] + nameInits[1][0];
    } else {
      return nameInits[0][0];
    }
  }

  void _handlePress() {
    _launchURL();
  }

  void showReachforHelp() {
    AnalyticsManager.instance.addEvent(AnalytictsActions.selectedTaskReachForHelp, null);
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = Offset(0.0, 1.0);
          var end = Offset.zero;
          var curve = Curves.easeInBack;

          var tween = Tween(begin: begin, end: end);
          var curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: curve,
          );

          return SlideTransition(
            position: tween.animate(curvedAnimation),
            child: child,
          );
        },
        pageBuilder: (BuildContext context, _, __) {
          return ReachForHelpWidget(
            task: widget.task,
          );
        },
      ),
    );
  }

  PelotonProfissional getUserFromJson(AsyncSnapshot<dynamic> snapshot) {
    var patient = PelotonUser.fromJson(snapshot.data.data);
    var personal = PersonalInformation(
      name: patient.firstName + ' ' + patient.lastName,
      profileImage: patient.profileImage,
    );
    return PelotonProfissional(personalInformation: personal);
  }

  void showPointTodiscuss() {
    AnalyticsManager.instance.addEvent(AnalytictsActions.selectedTaskReachForHelp, null);
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) {
          return AddNewPointTD(
            task: widget.task,
          );
        },
      ),
    );
  }

    showDoneAlert() {
    // Navigator.of(context).pushReplacement(
    //   PageRouteBuilder(
    //     opaque: false,
    //     pageBuilder: (_, __, ___) => DoneAlert(
    //         title: widget.task.handRaisedText)),
      
    // );
      showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              
              content: new Text(widget.task.handRaisedText),
              actions: <Widget>[
                FlatButton(
                  child: Text(AppLocalizations.of(context)
                                    .translate('Close')),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    print('selected task  ${widget.task.id}');
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        brightness: Brightness.light,

        actions: <Widget>[
          widget.task.isHandRaised
              ? IconButton(
                padding: EdgeInsets.all(5),
                  onPressed: showDoneAlert,
                  tooltip: widget.task.handRaisedText,
                  iconSize: 10,
                  icon: Image.asset(
                    'assets/hand_raised2.png',
                    
                    width: 31,
                    height: 31,
                  ),
                )
              : Container(),
        ],

        backgroundColor: Colors.transparent, //Color(0xfff4f5f9),
        elevation: 0,
      ),
      backgroundColor: Color(0xfff4f5f9),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(12),
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Container(
                    constraints: BoxConstraints(
                      minHeight: 100,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffffffff),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(17, 12, 17, 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget.task.title,
                            style: TextStyle(
                              decoration: widget.task.status == TaskStatus.done
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color: Color(0xff00183c),
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Inter',
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                AppLocalizations.of(context)
                                    .translate('RelatedGoal'),
                                style: const TextStyle(
                                    color: const Color(0xff00183c),
                                    fontWeight: FontWeight.w700,
                                    fontFamily: "Inter",
                                    fontStyle: FontStyle.normal,
                                    fontSize: 13.0),
                              ),
                              Flexible(
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(8, 4, 8, 5),
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
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 0.5,
                    color: Colors.grey,
                  ),
                  AnimatedContainer(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    curve: Curves.easeIn,
                    duration: Duration(milliseconds: 250),
                    height: 44,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            margin: EdgeInsetsDirectional.only(end: 0.5),
                            decoration: BoxDecoration(
                              color: widget.task.status == TaskStatus.done
                                  ? Color(0xffaaccff)
                                  : Colors.white,
                              borderRadius: BorderRadiusDirectional.only(
                                bottomStart: Radius.circular(8),
                              ),
                            ),
                            child: FlatButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                print('done');
                                if (widget.task.status == TaskStatus.done) {
                                  _setTaskstatus(TaskStatus.notDetermined);
                                } else {
                                  _setTaskstatus(TaskStatus.done);
                                }
                                widget.task.updateLocation();
                              },
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              child: Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Image.asset(
                                      'assets/check_task.png',
                                      height: 18.5,
                                      width: 18.5,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      AppLocalizations.of(context)
                                          .translate('Done'),
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: widget.task.status ==
                                                  TaskStatus.done
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            color: widget.task.status == TaskStatus.partialy
                                ? Color(0xffaaccff)
                                : Colors.white,
                            child: FlatButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                if (widget.task.status == TaskStatus.partialy) {
                                  _setTaskstatus(TaskStatus.notDetermined);
                                } else {
                                  _setTaskstatus(TaskStatus.partialy);
                                }
                                widget.task.updateLocation();
                              },
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Image.asset(
                                    'assets/task_partialy_done.png',
                                    width: 18.5,
                                    height: 18.5,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    AppLocalizations.of(context)
                                        .translate('Partially'),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: widget.task.status ==
                                              TaskStatus.partialy
                                          ? Colors.white
                                          : Colors.black,
                                    ),
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
                              color: widget.task.status == TaskStatus.declined
                                  ? Color(0xffaaccff)
                                  : Colors.white,
                            ),
                            child: FlatButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                if (widget.task.status == TaskStatus.declined) {
                                  _setTaskstatus(TaskStatus.notDetermined);
                                } else {
                                  _setTaskstatus(TaskStatus.declined);
                                }
                                widget.task.updateLocation();
                              },
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Image.asset(
                                    'assets/decline_task.png',
                                    width: 18.5,
                                    height: 18.5,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    AppLocalizations.of(context)
                                        .translate('Decline'),
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: widget.task.status ==
                                                TaskStatus.declined
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
            SafeArea(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    )),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    widget.task.details != null &&
                            widget.task.details.length > 0
                        ? Padding(
                            padding: const EdgeInsetsDirectional.only(
                                top: 5, bottom: 11),
                            child: Text(
                              AppLocalizations.of(context)
                                      .translate('Description') +
                                  ':',
                              style: const TextStyle(
                                  color: const Color(0xff00183c),
                                  fontWeight: FontWeight.w700,
                                  fontFamily: "Inter",
                                  fontStyle: FontStyle.normal,
                                  fontSize: 17.0),
                            ),
                          )
                        : Container(),
                    widget.task.details != null &&
                            widget.task.details.length > 0
                        ? Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, bottom: 12),
                            // if the text is less than 50 assign null as target to prevent refreshing the page.
                            child: GestureDetector(
                              onTap: widget.task.details.length > 50
                                  ? () {
                                      setState(() {
                                        shouldShowMore = !shouldShowMore;
                                      });
                                    }
                                  : null,
                              child: RichText(
                                text: new TextSpan(
                                  children: [
                                    new TextSpan(
                                      text: widget.task.details.length > 50 &&
                                              !shouldShowMore
                                          ? widget.task.details
                                                  .substring(0, 50) +
                                              '...'
                                          : widget.task.details,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        color: Color(0xff00183c),
                                        fontSize: 16.5,
                                        fontWeight: FontWeight.w400,
                                        fontStyle: FontStyle.normal,
                                      ),
                                    ),
                                    widget.task.details.length > 50 &&
                                            !shouldShowMore
                                        ? TextSpan(
                                            text: AppLocalizations.of(context)
                                                .translate('More'),
                                            style: TextStyle(
                                              decoration:
                                                  TextDecoration.underline,
                                              fontFamily: 'Inter',
                                              color: Color(0xff3c84f2),
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w700,
                                              fontStyle: FontStyle.normal,
                                            ),
                                          )
                                        : TextSpan(),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : Container(),
                    widget.task.details != null &&
                            widget.task.details.length > 0
                        ? Divider()
                        : Container(),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.only(top: 10, bottom: 11),
                      child: widget.task.assignee != null &&
                              widget.task.assignee.length > 1 &&
                              !widget.isMyTask
                          ? StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .doc(widget.task.isSelfCreated != null
                                      ? 'patients/${widget.task.assignee}'
                                      : 'users/${widget.task.assignee}')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.data.data == null ||
                                    snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                  return Container();
                                }

                                var user = widget.task.isSelfCreated != null
                                    ? getUserFromJson(snapshot)
                                    : PelotonProfissional.fromJson(
                                        snapshot.data.data);
                                return Row(
                                  children: <Widget>[
                                    Text(
                                      AppLocalizations.of(context)
                                              .translate('Assign') +
                                          ':',
                                      style: const TextStyle(
                                        color: const Color(0xff00183c),
                                        fontWeight: FontWeight.w700,
                                        fontFamily: "Inter",
                                        fontStyle: FontStyle.normal,
                                        fontSize: 16.5,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    widget.isMyTask
                                        ? Text(AppLocalizations.of(context)
                                              .translate('Me'),
                                            style: const TextStyle(
                                                color: const Color(0xff4a4a4a),
                                                fontWeight: FontWeight.w500,
                                                fontFamily: "Inter",
                                                fontStyle: FontStyle.normal,
                                                fontSize: 16.5))
                                        : user.personalInformation
                                                        .profileImage !=
                                                    null &&
                                                user.personalInformation
                                                        .profileImage.length >
                                                    1
                                            ? CircleAvatar(
                                                radius: 25,
                                                backgroundImage: NetworkImage(
                                                  user.personalInformation
                                                      .profileImage,
                                                ),
                                              )
                                            : Container(
                                                height: 35,
                                                width: 35,
                                                clipBehavior: Clip.hardEdge,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            35 / 2),
                                                    color: Colors.grey
                                                        .withOpacity(0.5)),
                                                child: Center(
                                                    child: Text(
                                                  getInitials(user
                                                      .personalInformation
                                                      .name),
                                                  style: TextStyle(
                                                      fontSize: 16.5,
                                                      fontWeight:
                                                          FontWeight.w700),
                                                )),
                                              ),
                                    widget.isMyTask
                                        ? Container()
                                        : Padding(
                                            padding: const EdgeInsets.all(6.0),
                                            child: Text(
                                              user.personalInformation.name,
                                              style: const TextStyle(
                                                  color:
                                                      const Color(0xff4a4a4a),
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: "Inter",
                                                  fontStyle: FontStyle.normal,
                                                  fontSize: 16.5),
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                  ],
                                );
                              },
                            )
                          : widget.isMyTask
                              ? Row(children: <Widget>[
                                  Text(
                                    AppLocalizations.of(context)
                                            .translate('Assign') +
                                        ':',
                                    style: const TextStyle(
                                      color: const Color(0xff00183c),
                                      fontWeight: FontWeight.w700,
                                      fontFamily: "Inter",
                                      fontStyle: FontStyle.normal,
                                      fontSize: 16.5,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    AppLocalizations.of(context)
                                        .translate('Me'),
                                    style: const TextStyle(
                                        color: const Color(0xff4a4a4a),
                                        fontWeight: FontWeight.w500,
                                        fontFamily: "Inter",
                                        fontStyle: FontStyle.normal,
                                        fontSize: 16.5),
                                  )
                                ])
                              : Container(),
                    ),
                    this.widget.task.url != null &&
                            this.widget.task.url.length > 0 && widget.task.url != 'https://'
                        ? Divider()
                        : Container(),
                    this.widget.task.url != null &&
                            this.widget.task.url.length > 0 && widget.task.url != 'https://'
                        ? Padding(
                            padding: const EdgeInsetsDirectional.only(
                                top: 11, bottom: 11),
                            child: RichText(
                              text: new TextSpan(
                                children: [
                                  new TextSpan(
                                    text: AppLocalizations.of(context)
                                            .translate('Link') +
                                        ':',
                                    style: const TextStyle(
                                        color: const Color(0xff00183c),
                                        fontWeight: FontWeight.w700,
                                        fontFamily: "Inter",
                                        fontStyle: FontStyle.normal,
                                        fontSize: 15.0),
                                  ),
                                  new TextSpan(text: '  '),
                                  new TextSpan(
                                    recognizer: this.tapRecognizer,
                                    text: '${widget.task.url}',
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      fontFamily: 'Inter',
                                      color: Color(0xff3c84f2),
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      fontStyle: FontStyle.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Container(),
                    Divider(),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.only(top: 11, bottom: 11),
                      child: RichText(
                        text: new TextSpan(
                          children: [
                            new TextSpan(
                              text: AppLocalizations.of(context)
                                      .translate('DueDate') +
                                  ':',
                              style: const TextStyle(
                                  color: const Color(0xff00183c),
                                  fontWeight: FontWeight.w700,
                                  fontFamily: "Inter",
                                  fontStyle: FontStyle.normal,
                                  fontSize: 15.0),
                            ),
                            new TextSpan(
                              text: '  ',
                            ),
                            new TextSpan(
                              text: getTaskTime(widget.task.dueDate),
                              style: TextStyle(
                                fontFamily: 'Inter',
                                color: Color(0xff4a4a4a),
                                fontSize: 16.5,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.only(top: 11, bottom: 11),
                      child: RichText(
                        text: new TextSpan(
                          children: [
                            new TextSpan(
                              text: AppLocalizations.of(context)
                                      .translate('Repeat') +
                                  ':',
                              style: const TextStyle(
                                  color: const Color(0xff00183c),
                                  fontWeight: FontWeight.w700,
                                  fontFamily: "Inter",
                                  fontStyle: FontStyle.normal,
                                  fontSize: 15.0),
                            ),
                            new TextSpan(
                              text: '  ',
                            ),
                            new TextSpan(
                              text: 'Once',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                color: Color(0xff4a4a4a),
                                fontSize: 16.5,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.only(top: 5, bottom: 11),
                      child: Text(
                        AppLocalizations.of(context).translate('AddNote') + ':',
                        style: const TextStyle(
                            color: const Color(0xff00183c),
                            fontWeight: FontWeight.w700,
                            fontFamily: "Inter",
                            fontStyle: FontStyle.normal,
                            fontSize: 16.5),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xfff4f4f4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.all(12),
                      child: TextField(
                        enabled: widget.isMyTask,
                        controller: _controller,
                        focusNode: commentFocusNode,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            hintText: AppLocalizations.of(context)
                                .translate('EnterComment')),
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        onSubmitted: (value) {
                          print(_controller.text);
                          widget.task.addNotes(_controller.text);
                        },
                        maxLines: 8,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    widget.task.orginization == 'Default' ? Container() : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: GestureDetector(
                            onTap: widget.isMyTask ? showReachforHelp : null,
                            child: Container(
                              padding: EdgeInsetsDirectional.only(start: 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Image.asset(
                                    'assets/hand_raised.png',
                                    height: 25,
                                    width: 25,
                                  ),
                                  Expanded(
                                    child: Text(
                                      AppLocalizations.of(context)
                                          .translate('ReachoutForHelp'),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: const Color(0xff3c84f2),
                                          fontWeight: FontWeight.w600,
                                          fontFamily: "Inter",
                                          fontStyle: FontStyle.normal,
                                          fontSize: 14.0),
                                    ),
                                  ),
                                ],
                              ),
                              margin: EdgeInsets.all(5),
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Theme.of(context).accentColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: showPointTodiscuss,
                            child: Container(
                              padding: EdgeInsetsDirectional.only(start: 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Image.asset(
                                    'assets/bow.png',
                                    height: 25,
                                    width: 25,
                                  ),
                                  Expanded(
                                    child: Text(
                                      AppLocalizations.of(context)
                                          .translate('PointTodiscuss'),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: const Color(0xff3c84f2),
                                          fontWeight: FontWeight.w600,
                                          fontFamily: "Inter",
                                          fontStyle: FontStyle.normal,
                                          fontSize: 14.0),
                                    ),
                                  ),
                                ],
                              ),
                              margin: EdgeInsets.all(5),
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Theme.of(context).accentColor,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
