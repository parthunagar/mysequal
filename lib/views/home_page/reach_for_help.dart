import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/managers/auth_provider.dart';
import 'package:peloton/models/pelotonTask.dart';
import 'package:peloton/widgets/done_button.dart';
import 'package:peloton/widgets/help_on_the_way.dart';


class ReachForHelpWidget extends StatefulWidget {
  final PelotonTask task;
  @override
  ReachForHelpWidget({this.task});
  @override
  _ReachForHelpWidgetState createState() => _ReachForHelpWidgetState();
}

class _ReachForHelpWidgetState extends State<ReachForHelpWidget>
    with SingleTickerProviderStateMixin {
  TextEditingController _controller;
  String selectedAssignee;
  String selectedAssigneName;
  AnimationController expandController;
  Animation<double> animation;
  bool shouldExpand = false;
  int selectedIndex;
  String caseManager;

  FocusNode commentFocusNode = new FocusNode();

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
    var myId = AuthProvider.of(context).auth.currentUserId;
    var assignees = [];
    var assigneeIds = [];
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
      assigneeIds = [selectedAssignee,caseManager];
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
        'title': widget.task.title,
        'owner': myId,
        'owner_ref': FirebaseFirestore.instance
            .doc('patients/' + AuthProvider.of(context).auth.currentUserId),
        'note_type': {
          'linked_to':
              FirebaseFirestore.instance.doc('tasks/' + widget.task.id),
          'type': 'TASK'
        },
        'date': Timestamp.now(),
        'assignee': assignees,
        'assignee_ids': assigneeIds,
      },
    );
    setState(() {
      widget.task.isHandRaised = true;
      widget.task.updateHansRaisedStatus(true);
      widget.task.updateTaskRaisedText(_controller.text ?? '');
      //widget.task.updateHandRaisedAction();
      // Navigator.pop(context);
    });
    showCreatedalert();
  }

  showCreatedalert() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => HelpOnTheWay(
          name: selectedAssigneName,
          note: widget.task.title,
        ),
      ),
    );
  }

  var containerHeight = 0.0;

  @override
  Widget build(BuildContext context) {
    var orgIDs =
        AuthProvider.of(context).auth.currentUserDoc['organizationsID'] ?? [];
    List<dynamic> usersList = [];

    List<Map> orgsList =
        AuthProvider.of(context).auth.currentUserDoc['caseManager'] ?? [];
    print(widget.task.id + 'id');
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Builder(builder: (context) {
        return Material(
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
                                  .translate('ReachHelp'),
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
                          padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
                          child: Text(
                            AppLocalizations.of(context)
                                .translate('ReachHelpInfo'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: const Color(0xff4a4a4a),
                                fontWeight: FontWeight.w400,
                                fontFamily: "Inter",
                                fontStyle: FontStyle.normal,
                                fontSize: 18.0),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: <Widget>[
                              Text(
                                AppLocalizations.of(context)
                                    .translate('HelpFrom'),
                                style: const TextStyle(
                                    color: const Color(0xff00183c),
                                    fontWeight: FontWeight.w700,
                                    fontFamily: "Inter",
                                    fontStyle: FontStyle.normal,
                                    fontSize: 18.0),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 90,
                          child: orgIDs.length > 0
                              ? StreamBuilder(
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
                                    for (var temp in orgsList) {
                                      if (temp['org'] ==
                                          snap.data.data()['orginization']) {
                                        usersList.add(temp['casemaneger']);
                                        caseManager = temp['casemaneger'].id;
                                      }
                                    }
                                    for (var supportive
                                        in snap.data.data()['supportive'] ?? []) {
                                      if (!usersList.contains(supportive)) {
                                        usersList.add(supportive);
                                      }
                                    }
                                    var owner = snap.data.data()['owner'];
                                    if (!usersList.contains(owner)) {
                                      usersList.insert(0, owner);
                                    }

                                    return HelpAvatarWidget(
                                      selected: selectedIndex,
                                      users: usersList.toSet().toList(),
                                      userSelection: (user, name, index,org) {
                                        this.selectedAssigneName = name;
                                        this.selectedAssignee = user;
                                        this.selectedIndex = index;
                                      },
                                    );
                                  },
                                )
                              : Container(),
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.all(8.0),
                        //   child: Row(
                        //     children: <Widget>[
                        //       Text(
                        //         AppLocalizations.of(context)
                        //             .translate('MoreInfo'),
                        //         style: const TextStyle(
                        //             color: const Color(0xff00183c),
                        //             fontWeight: FontWeight.w700,
                        //             fontFamily: "Inter",
                        //             fontStyle: FontStyle.normal,
                        //             fontSize: 18.0),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        Expanded(
                          child: Container(
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
                                  hintText:
                                      'Enter text about discussion point …'),
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.newline,
                              // onChanged: (vale) {
                              //   setState(() {});
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
                            onPressed: _controller.text.length > 0
                                ? () {
                                    if (selectedAssignee != null) {
                                      didTapCreate();
                                    } else {
                                      Scaffold.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'please select a health expert'),
                                        ),
                                      );
                                    }
                                  }
                                : null,
                            child: Text(
                                AppLocalizations.of(context)
                                    .translate('Create'),
                                style: TextStyle(
                                    color: (_controller.text.length == 0)
                                        ? Color(0xffcbcbcb)
                                        : Color(0xff3c84f2),
                                    fontWeight: FontWeight.w700,
                                    fontFamily: "Inter",
                                    fontStyle: FontStyle.normal,
                                    fontSize: 22),
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
        );
      }),
    );
  }
}

class HelpAvatarWidget extends StatefulWidget {
  final int selected;
  final List<dynamic> users;
  final Function(String, String, int,String) userSelection;
  @override
  HelpAvatarWidget({this.users, this.userSelection, this.selected});
  @override
  _HelpAvatarWidgetState createState() => _HelpAvatarWidgetState();
}

class _HelpAvatarWidgetState extends State<HelpAvatarWidget>
    with AutomaticKeepAliveClientMixin {
  int selectedIndex;
  @override
  void initState() {
    selectedIndex = widget.selected;
    super.initState();
  }

  String getInitials(member) {
    if (member == null || member == '') {
      return 'NA';
    }
    List<String> nameInits = member.split(' ');
    if (nameInits.length > 1) {
      return nameInits[0][0] + nameInits[1][0];
    } else {
      return nameInits[0][0];
    }
  }

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    // widget.userSelection(widget.users[0].documentID,
    //     widget.users[0]['personal_information']['name']);
    return Container(
      child: ListView.builder(
        itemCount: widget.users.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) {
          return FutureBuilder(
              future: widget.users[index].get(),
              builder: (_, userSnap) {
                if (userSnap.data == null) {
                  return Container();
                }
                var udata = userSnap.data.data();
                print(udata);
                var userData = udata['personal_information'];
                var image = userData['profile_image'] != null
                    ? userData['profile_image']
                    : '';
                var name = udata['personal_information']['name'];
                if (userSnap.data == null) {
                  return Container();
                }
                return Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                        widget.userSelection(
                            userSnap.data.id,
                            userSnap.data.data()['personal_information']
                                ['name'],
                            selectedIndex,
                            userSnap.data.data()['employment_details']
                                ['orginization']['id']
                            );
                      });
                    },
                    child: Column(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: selectedIndex == index
                              ? Color(0xff3c84f2)
                              : Colors.white,
                          child: image.length > 0
                              ? CircleAvatar(
                                  radius: 24,
                                  backgroundImage: NetworkImage(image),
                                )
                              : Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(26)),
                                  child: Center(
                                    child: Text(
                                      getInitials(name),
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black),
                                    ),
                                  ),
                                ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(name,
                                style: TextStyle(
                                    color: selectedIndex == index
                                        ? Color(0xff3c84f2)
                                        : Color(0xff8b8b8b),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "Inter",
                                    fontStyle: FontStyle.normal,
                                    fontSize: 12.0),
                                textAlign: TextAlign.left),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
        },
      ),
    );
  }
}
