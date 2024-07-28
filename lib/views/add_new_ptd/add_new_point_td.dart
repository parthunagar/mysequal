import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/managers/auth_provider.dart';
import 'package:peloton/models/PelotonUser.dart';
import 'package:peloton/models/pelotonTask.dart';
import 'package:peloton/views/home_page/reach_for_help.dart';
import 'package:peloton/widgets/done_alert.dart';
import 'package:peloton/widgets/done_button.dart';

class AddNewPointTD extends StatefulWidget {
  final PelotonTask task;
  @override
  AddNewPointTD({this.task});
  @override
  _AddNewPointTDState createState() => _AddNewPointTDState();
}

class _AddNewPointTDState extends State<AddNewPointTD>
    with SingleTickerProviderStateMixin {
  String selectedAssignee;
  TextEditingController _controller;
  AnimationController expandController;
  Animation<double> animation;
  bool shouldExpand = false;
  int selectedIndex;
  FocusNode commentFocusNode = new FocusNode();
  String caseManager;
  String selectedorg;

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
              setState(() {});
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

  @override
  void dispose() {
    _controller.dispose();
    expandController.dispose();
    super.dispose();
  }

  @override
  void initState() {
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
    _controller = TextEditingController();
    prepareAnimations();
    Future.delayed(Duration(milliseconds: 100), () {
      shouldExpand = true;
      _runExpandCheck();
    });

    super.initState();
  }

  void prepareAnimations() {
    expandController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    animation = CurvedAnimation(
      parent: expandController,
      curve: Curves.fastOutSlowIn,
    );
  }

  void _runExpandCheck() {
    if (shouldExpand) {
      expandController.forward();
    } else {
      expandController.reverse();
    }
  }

  void didTapCreate() {
    print('add point  TD');
    var myId = AuthProvider.of(context).auth.currentUserId;
    List<Map> orgsList =
        AuthProvider.of(context).auth.currentUserDoc['caseManager'] ?? [];
    var assignees = [];
    var assigneeIds = [];
    for (var temp in orgsList) {
      if (temp['org'] == selectedorg) {
        caseManager = temp['casemaneger'].id;
      }
    }
    if (selectedAssignee == caseManager) {
      assigneeIds = [selectedAssignee];
      assignees = [
        {
          'id': selectedAssignee,
          'seen': false,
          'ref': FirebaseFirestore.instance.doc('users/' + selectedAssignee)
        }
      ];
    } else {
      assigneeIds = [selectedAssignee, caseManager];
      assignees = [
        {
          'id': selectedAssignee,
          'seen': false,
          'ref': FirebaseFirestore.instance.doc('users/' + selectedAssignee)
        },
        {
          'id': caseManager,
          'seen': false,
          'ref': FirebaseFirestore.instance.doc('users/' + caseManager)
        }
      ];
    }
    
    FirebaseFirestore.instance.collection('notes').add(
      {
        'created_at': Timestamp.fromDate(DateTime.now()),
        'creator': myId,
        'body': _controller.text,
        'title': widget.task?.title ?? '',
        'owner': myId,
        'owner_ref': FirebaseFirestore.instance
            .doc('patients/' + AuthProvider.of(context).auth.currentUserId),
        'note_type': {
          'linked_to': widget.task != null
              ? FirebaseFirestore.instance.doc('tasks/' + widget.task.id)
              : null,
          'type': 'DISCUSSION POINT'
        },
        'date': Timestamp.now(),
        'assignee': assignees,
        'assignee_ids': assigneeIds,
      },
    );
    if (widget.task != null) {
      setState(() {
        widget.task?.updateDisccusionAction();
        // Navigator.pop(context);
      });
    }
    showDonealert();
  }

  showDonealert() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => DoneAlert(
          title: AppLocalizations.of(context)
              .translate("DisscussionPoinDoneAlert"),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var myData =
        PelotonUser.fromJson(AuthProvider.of(context).auth.currentUserDoc);
    var orgIDs =
        AuthProvider.of(context).auth.currentUserDoc['organizationsID'] ?? [];
    List<Map> orgsList =
        AuthProvider.of(context).auth.currentUserDoc['caseManager'] ?? [];
    List<dynamic> usersList = [];
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      resizeToAvoidBottomPadding: true,
      body: Material(
        type: MaterialType.transparency,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              color: Colors.black.withOpacity(0.5),
            ),
            Positioned(
              bottom: 0,
              right: 1,
              left: 1,
              child: SizeTransition(
                axisAlignment: 1.0,
                sizeFactor: animation,
                child: Container(
                  padding: EdgeInsets.all(8),
                  height: 500,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                      color: Colors.white),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            width: 40,
                          ),
                          Text(
                            AppLocalizations.of(context)
                                .translate('DiscussionPoint'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: const Color(0xff00183c),
                                fontWeight: FontWeight.w700,
                                fontFamily: "Inter",
                                fontStyle: FontStyle.normal,
                                fontSize: 20.0),
                          ),
                          IconButton(
                            color: Colors.blue,
                            icon: Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                shouldExpand = false;
                                _runExpandCheck();
                              });
                              Navigator.pop(context);
                            },
                          )
                        ],
                      ),
                      Divider(
                        indent: 40,
                        endIndent: 40,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30, 5, 30, 5),
                        child: Text(
                          AppLocalizations.of(context)
                              .translate('DiscussionPointInfo'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: const Color(0xff4a4a4a),
                              fontWeight: FontWeight.w400,
                              fontFamily: "Inter",
                              fontStyle: FontStyle.normal,
                              fontSize: 17.0),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: <Widget>[
                            Text(
                              AppLocalizations.of(context)
                                      .translate('TalkWith') +
                                  ' :',
                              style: const TextStyle(
                                  color: const Color(0xff00183c),
                                  fontWeight: FontWeight.w700,
                                  fontFamily: "Inter",
                                  fontStyle: FontStyle.normal,
                                  fontSize: 17.0),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 90,
                        child: widget.task == null
                            ? StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection('goals')
                                    .where('patientid', isEqualTo: myData.id)
                                    .where('orginization', whereIn: orgIDs)
                                    .snapshots(),
                                builder: (_, snap) {
                                  if (snap.data == null ||
                                      snap.connectionState ==
                                          ConnectionState.waiting) {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  }
                                  for (var temp in orgsList) {
                                    usersList.add(temp['casemaneger']);
                                  }
                                  for (var doc in snap.data.docs) {
                                    for (var item
                                        in doc.data()['supportive'] ?? []) {
                                      var shouldAdd = true;
                                      for (var listitem in usersList) {
                                        if (listitem.id == item.id) {
                                          shouldAdd = false;
                                          continue;
                                        }
                                      }
                                      if (shouldAdd) {
                                        usersList.add(item);
                                      }

                                      print(item.id);
                                    }
                                    var ownerRef = doc.data()['owner'];
                                    var shouldAdd = true;
                                    for (var listitem in usersList) {
                                      if (listitem.id == ownerRef.id) {
                                        shouldAdd = false;
                                        continue;
                                      }
                                    }
                                    if (shouldAdd) {
                                      usersList.add(ownerRef);
                                    }
                                  }

                                  return HelpAvatarWidget(
                                    selected: selectedIndex,
                                    users: usersList.toSet().toList(),
                                    userSelection: (user, name, index, org) {
                                      this.selectedAssignee = user;
                                      this.selectedIndex = index;
                                      this.selectedorg = org;
                                    },
                                  );
                                },
                              )
                            : StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection('goals')
                                    .doc(widget.task.goalData['goal_id'])
                                    .get()
                                    .asStream(),
                                builder: (_, snap) {
                                  if (snap.data == null ||
                                      snap.connectionState ==
                                          ConnectionState.waiting) {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  }
                                  for (var supportive
                                      in snap.data.data()['supportive'] ?? []) {
                                    usersList.add(supportive);
                                  }

                                  usersList.insert(
                                      0, snap.data.data()['owner']);

                                  return HelpAvatarWidget(
                                    selected: selectedIndex,
                                    users: usersList.toSet().toList(),
                                    userSelection: (user, name, index, org) {
                                      this.selectedAssignee = user;
                                      this.selectedIndex = index;
                                      this.selectedorg = org;
                                    },
                                  );
                                },
                              ),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color(0xfff4f4f4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.all(12),
                          child: TextField(
                            focusNode: commentFocusNode,
                            maxLines: 8,
                            controller: _controller,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              hintText: AppLocalizations.of(context)
                                  .translate('EnterDPText'),
                            ),

                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,

                            // onChanged: (vale){
                            //   setState(() {

                            //   });
                            // },

                            onSubmitted: (value) {
                              print(_controller.text);
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 0, bottom: 20),
                        child: FlatButton(
                          padding: EdgeInsets.zero,
                          onPressed:
                              _controller.text.length > 0 ? didTapCreate : null,
                          child: Text(
                              AppLocalizations.of(context).translate('Create'),
                              style: TextStyle(
                                  color: (_controller.text.length == 0)
                                      ? Color(0xffcbcbcb)
                                      : Color(0xff3c84f2),
                                  fontWeight: FontWeight.w700,
                                  fontFamily: "Inter",
                                  fontStyle: FontStyle.normal,
                                  fontSize: 25),
                              textAlign: TextAlign.left),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
