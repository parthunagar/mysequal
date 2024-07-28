import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/managers/analytics_actions.dart';
import 'package:peloton/managers/analytics_manager.dart';
import 'package:peloton/models/PelotonGoal.dart';
import 'package:peloton/models/PelotonMember.dart';
import 'package:peloton/widgets/invite_new_member.dart';
import 'package:peloton/widgets/peloton_profile_image.dart';

class MyPelotonsTeam extends StatelessWidget {
  final List<dynamic> pelotons;
  final PelotonGoal goal;

  showAddNewMember(context) {
    // showModalBottomSheet(
    //   context: context,
    //   builder: (BuildContext bc) {
    //     return Container(
    //       margin: EdgeInsets.only(bottom: 20),
    //       child: new Wrap(
    //         children: <Widget>[
    //           InviteNewMember()

    //         ],
    //       ),
    //     );
    //   },
    // );
    AnalyticsManager.instance.addEvent(AnalytictsActions.addMemberGoals, null);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bc) {
        return Container(
          margin: EdgeInsets.only(bottom: 0),
          child: Wrap(
            children: <Widget>[
              InviteNewMember(usersInGoal:pelotons,goal:goal),
            ],
          ),
        );
      },
    );
  }

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
      print(item.path);
      var snapshot = await item.get();
      if (snapshot.exists) {
        if (item.path.startsWith('users')){
        returnArray
            .add(PelotonMember.fromJson(snapshot.data()['personal_information']));
        }else{
          
              returnArray
            .add(PelotonMember.fromJson(snapshot.data()));

        }
      }
    }
    return (returnArray);
  }

  @override
  MyPelotonsTeam({this.pelotons,this.goal});
  @override
  Widget build(BuildContext context) {
    
    return FutureBuilder(
      future: convertUserToMember(pelotons),
      builder: (_, data) {

        List<Widget> profiles = [];
        if (data.data != null && data.data.length > 0) {
          data.data.asMap().forEach(
            (index, element) {
              var item = Container(
                height: 61,
                width: 61,
                padding: EdgeInsets.all(4.5),
                margin: EdgeInsets.all(2),
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: index == 0
                          ? const Color(0xff3c84f2)
                          : Colors.transparent,
                      width: 2),
                  borderRadius: BorderRadius.circular(30.5),
                ),
                child: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: PelotonProfileImage(member: element, height: 61)),
              );
              profiles.add(item);
            },
          );
        }
        Widget addNewMember = Container(
          height: 61,
          width: 61,
          padding: EdgeInsets.all(4.5),
          margin: EdgeInsets.all(2),
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.5),
          ),
          child: GestureDetector(
            onTap: () {
              showAddNewMember(context);
            },
            child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: Color(0xffaaccff),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(Icons.add)),
          ),
        );
        profiles.add(addNewMember);
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                  top: 20, //40.0,
                  bottom: 15,
                ),
                child: Text(
                  AppLocalizations.of(context).translate(
                    'MyPelotonTeam',
                  ),
                  style: const TextStyle(
                      color: const Color(0xff00183c),
                      fontWeight: FontWeight.w700,
                      fontFamily: "Inter",
                      fontStyle: FontStyle.normal,
                      fontSize: 18.0),
                ),
              ),
              Container(
                height: 65,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: profiles,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
