import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/models/PelotonGoal.dart';
import 'package:peloton/models/PelotonMember.dart';
import 'package:intl/intl.dart' as intl;
import 'package:peloton/widgets/NSbasicWidget.dart';
import 'package:peloton/widgets/peloton_profile_image.dart';

class WelcomeScreenGoalWidget extends StatelessWidget {
  final PelotonGoal goal;
  @override
  WelcomeScreenGoalWidget({this.goal});

  String getDateFrmated(Timestamp createdAt, context) {
    DateTime parseDt = DateTime.fromMillisecondsSinceEpoch(
        createdAt.millisecondsSinceEpoch);
    var newFormat = intl.DateFormat("MMM dd");
    return newFormat.format(parseDt);
  }

  @override
  Widget build(BuildContext context) {
    return NSBaseWidget(builder: (context, sizingInformation) {
      return Container(
        margin: EdgeInsets.fromLTRB(8, 12, 8, 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
                color: Color(0x29000000),
                offset: Offset(0, 0),
                blurRadius: 10,
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Color(goal.goalColor),
                          ),
                          padding: EdgeInsets.fromLTRB(12, 6, 12, 6),
                          child: Text(
                            goal.title,
                            style: TextStyle(
                                fontFamily: 'Inter',
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700),
                          ),
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
                        Text(
                          AppLocalizations.of(context).translate('GoalWhy'),
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: const Color(0xff00183c),
                            fontWeight: FontWeight.w700,
                            fontFamily: "Inter",
                            fontStyle: FontStyle.normal,
                            fontSize: 16.5,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
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
                        SizedBox(
                          height: 12,
                        )
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
    for (var element in arrrayOfUsers) {
      var snapshot = await element.get();
      if (snapshot.exists) {
        returnArray
            .add(PelotonMember.fromJson(snapshot.data['personal_information']));
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
            print(element.imageUrl);
            var item = Stack(
              alignment: Alignment.center,
              fit: StackFit.loose,
              children: <Widget>[
                Container(
                    height: 47,
                    width: 47,
                    padding: EdgeInsets.all(4.5),
                    margin: EdgeInsets.all(2),
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: index == 0
                              ? const Color(0xff3c84f2)
                              : Colors.transparent,
                          width: 2),
                      borderRadius: BorderRadius.circular(23.5),
                    ),
                    child: PelotonProfileImage(
                      member: element,
                      height: 40,
                    )),
                pelotons.length > 3 && index == 2
                    ? Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(17.5),
                        ),
                        height: 35,
                        width: 35,
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
          return Row(children: profiles);
        });
  }
}
