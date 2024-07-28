import 'package:flutter/material.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/models/PelotonGoal.dart';
import 'package:peloton/widgets/NSbasicWidget.dart';
import 'package:peloton/widgets/addpeer.dart';

import 'add_expert.dart';

class InviteNewMember extends StatefulWidget {
  final List<dynamic> usersInGoal;
  final PelotonGoal goal;
  @override
  InviteNewMember({this.usersInGoal,this.goal});
  @override
  _InviteNewMemberState createState() => _InviteNewMemberState();
}

class _InviteNewMemberState extends State<InviteNewMember> {
  int selectedMember = 0;

  showPeers(context) {
    /*
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bc) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 0),
              child: Wrap(
                children: <Widget>[
                  AddPeerWidget(),
                ],
              ),
            ),
          ],
        );
      },
    );
    */
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) {
          return AddPeerWidget();
        },
      ),
    );
  }

  showExperts(context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bc) {
        return Container(
          margin: EdgeInsets.only(bottom: 0),
          child: Wrap(
            children: <Widget>[
              AddExpert(myTeam:widget.usersInGoal,goal:widget.goal),
            ],
          ),
        );
      },
    ).then((value){
      setState((){});
    });
  }

  @override
  Widget build(BuildContext context) {
    return NSBaseWidget(
      builder: (context, sizingInformation) {
        
        return Container(
          height: sizingInformation.scaleByWidth(581),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadiusDirectional.only(
              topEnd: Radius.circular(16),
              topStart: Radius.circular(16),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  IconButton(
                    color: Colors.blue,
                    iconSize: 25,
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
              Center(
                child: Text(
                  AppLocalizations.of(context).translate(
                    'AddMember',
                  ),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Color(0xff00183c),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.normal,
                  ),
                ),
              ),
              Divider(
                endIndent: 50,
                indent: 50,
                thickness: 1,
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  AppLocalizations.of(context).translate(
                    'ImAddingA',
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Color(0xff4a4a4a),
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                  ),
                ),
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedMember = 1;
                        Future.delayed(Duration(milliseconds: 350), () {
                          Navigator.pop(context);
                          showPeers(context);
                        });
                      });
                    },
                    child: Container(
                      height: sizingInformation.scaleByWidth(320),
                      width: sizingInformation.scaleByWidth(180),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selectedMember == 1
                                ? Color(0xff3c84f2)
                                : Colors.grey.withOpacity(0.5),
                          )),
                      child: Column(
                        children: <Widget>[
                          Image.asset(
                            'assets/addpeer.png',
                            width: sizingInformation.scaleByWidth(110),
                            height: sizingInformation.scaleByWidth(172),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              AppLocalizations.of(context).translate(
                                'MyPeer',
                              ),
                              style: TextStyle(
                                  color: selectedMember == 1
                                      ? Color(0xff3c84f2)
                                      : Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: "Inter",
                                  fontStyle: FontStyle.normal,
                                  fontSize: 18.0),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Text(
                              AppLocalizations.of(context).translate(
                                'PeerDescription',
                              ),
                              style: TextStyle(
                                  color: selectedMember == 1
                                      ? Color(0xff3c84f2)
                                      : Colors.black,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "Inter",
                                  fontStyle: FontStyle.normal,
                                  fontSize: 14.0),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedMember = 2;
                        Future.delayed(Duration(milliseconds: 350), () {
                          Navigator.pop(context);
                          showExperts(context);
                        });
                      });
                    },
                    child: Container(
                      height: sizingInformation.scaleByWidth(320),
                      width: sizingInformation.scaleByWidth(180),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selectedMember == 2
                                ? Color(0xff3c84f2)
                                : Colors.grey.withOpacity(0.5),
                          )),
                      child: Column(
                        children: <Widget>[
                          Image.asset(
                            'assets/addprofissional.png',
                            width: sizingInformation.scaleByWidth(110),
                            height: sizingInformation.scaleByWidth(172),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              AppLocalizations.of(context).translate(
                                'MyTherapist',
                              ),
                              style: TextStyle(
                                  color: selectedMember == 2
                                      ? Color(0xff3c84f2)
                                      : Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: "Inter",
                                  fontStyle: FontStyle.normal,
                                  fontSize: 18.0),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Text(
                              AppLocalizations.of(context).translate(
                                'ProffisionalDescription',
                              ),
                              style: TextStyle(
                                  color: selectedMember == 2
                                      ? Color(0xff3c84f2)
                                      : Colors.black,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "Inter",
                                  fontStyle: FontStyle.normal,
                                  fontSize: 14.0),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Spacer(),
              // Container(
              //   child: FlatButton(
              //     onPressed: () {
              //       Navigator.pop(context);

              //       if (selectedMember == 1) {
              //         showPeers(context);
              //       } else if (selectedMember == 2) {
              //         showExperts(context);
              //       }
              //     },
              //     child: Text("Done",
              //         style: const TextStyle(
              //             color: const Color(0xff3c84f2),
              //             fontWeight: FontWeight.w700,
              //             fontFamily: "Inter",
              //             fontStyle: FontStyle.normal,
              //             fontSize: 18.5),
              //         textAlign: TextAlign.left),
              //   ),
              // ),
              // Spacer(),
            ],
          ),
        );
      },
    );
  }
}
