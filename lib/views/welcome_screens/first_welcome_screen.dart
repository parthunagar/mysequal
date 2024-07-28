import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/managers/auth_provider.dart';
import 'package:peloton/models/PelotonGoal.dart';
import 'package:peloton/views/welcome_screens/welcome_screen_goal.dart';
import 'package:peloton/widgets/NSbasicWidget.dart';

class FirstWelcomeScreen extends StatelessWidget {
  final String name;
  final void Function() showNext;
  @override
  FirstWelcomeScreen({this.showNext, this.name});
  @override
  Widget build(BuildContext context) {
    return NSBaseWidget(builder: (context, sizingInformation) {
      String myId = AuthProvider.of(context).auth.currentUserId;
      return Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(.0),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                          style: TextStyle(
                              color: HexColor('003561'),
                              fontWeight: FontWeight.w400,
                              fontFamily: "Inter",
                              fontStyle: FontStyle.italic,
                              fontSize: sizingInformation.scaleByWidth(20)),
                          text: AppLocalizations.of(context).translate('Hi')),
                      TextSpan(
                          style:  TextStyle(
                              color: const Color(0xff00cdc1),
                              fontWeight: FontWeight.w400,
                              fontFamily: "Inter",
                              fontStyle: FontStyle.italic,
                              fontSize: sizingInformation.scaleByWidth(20)),
                          text: "$name !")
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                AppLocalizations.of(context).translate('GreetUser'),
                style: TextStyle(
                    color: HexColor('003561'),
                    fontWeight: FontWeight.w400,
                    fontFamily: "Inter",
                    fontStyle: FontStyle.normal,
                    fontSize: sizingInformation.scaleByWidth(20)),
              ),
              Text(
                AppLocalizations.of(context).translate('YourGoals'),
                style: TextStyle(
                    color: HexColor('003561'),
                    fontWeight: FontWeight.w700,
                    fontFamily: "Inter",
                    fontStyle: FontStyle.normal,
                    fontSize: sizingInformation.scaleByWidth(20)),
              ),
              Container(
                padding: EdgeInsets.all(12),
                child: Text(
                  AppLocalizations.of(context).translate('NotAlone'),
                  style: TextStyle(
                      color: HexColor('003561'),
                      fontWeight: FontWeight.w400,
                      fontFamily: "Inter",
                      fontStyle: FontStyle.normal,
                      fontSize: sizingInformation.scaleByWidth(18)),
                ),
              ),
              Container(
                child: Expanded(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('goals')
                        .where('patientid', isEqualTo: myId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (!snapshot.hasData)
                        return Center(
                          child: Text(' '),
                        );
                      return ListView.builder(
                        itemBuilder: (cntx, index) {
                          DocumentSnapshot ds = snapshot.data.documents[index];
                          PelotonGoal goal = PelotonGoal.fromJson(ds.data());
                          goal.id = ds.id;
                          return WelcomeScreenGoalWidget(
                            goal: goal,
                          );
                        },
                        itemCount: snapshot.data.documents.length,
                      );
                    },
                  ),
                ),
              ),
              SizedBox(
                height: sizingInformation.scaleByHeight(90),
              )
            ],
          ),
          Positioned(
            bottom: 10,
            child: GestureDetector(
              onTap: showNext,
              child: Container(
                padding: EdgeInsets.all(12),
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(34)),
                  boxShadow: [
                    BoxShadow(
                        color: const Color(0x29000000),
                        offset: Offset(0, 2),
                        blurRadius: 8,
                        spreadRadius: 0)
                  ],
                  color: const Color(0xff3c84f2),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    child: Text(
                      AppLocalizations.of(context).translate('YourGoals'),
                      //'Those are the goals we’ve set',
                      style:  TextStyle(
                          color: const Color(0xffffffff),
                          fontWeight: FontWeight.w700,
                          fontFamily: "Inter",
                          fontStyle: FontStyle.normal,
                          
                          fontSize: sizingInformation.scaleByWidth(20)),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      );
    });
  }
}
