import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/managers/auth_provider.dart';
import 'package:peloton/models/PelotonGoal.dart';
import 'package:peloton/models/peloton_profissional.dart';

import 'done_alert.dart';

class AddExpert extends StatefulWidget {
  final List<dynamic> myTeam;
  final PelotonGoal goal;
  @override
  AddExpert({this.myTeam, this.goal});
  @override
  _AddExpertState createState() => _AddExpertState();
}

class _AddExpertState extends State<AddExpert> {
  List<dynamic> usersList = [];
  showDoneMessage() async {
    await Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => DoneAlert(
            title: AppLocalizations.of(context).translate("ExpertAdded")),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var myId = AuthProvider.of(context).auth.currentUserId;
    var orgIDs =
        AuthProvider.of(context).auth.currentUserDoc['organizationsID'] ?? [];
    return Container(
      height: 600,
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
              AppLocalizations.of(context).translate("AddExpert"),
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
          Expanded(
            child: Container(
              color: Colors.white,
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('goals')
                      .where('patientid', isEqualTo: myId)
                      .where('orginization', whereIn: orgIDs)
                      .snapshots(),
                  builder: (_, snap) {
                    if (snap.data == null ||
                        snap.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    for (var doc in snap.data.docs) {
                      usersList = usersList + (doc.data()['supportive'] ?? []);
                    }
                    List<String> goalusers = [];
                    for (var item in widget.myTeam) {
                      if (item is List) {
                        item.forEach((element) {
                          goalusers.add(element.id);
                        });
                      } else {
                        goalusers.add(item.id);
                      }
                    }

                    return ProffisionalsList(
                      users: usersList.toSet().toList(),
                      alreadySelected: goalusers.toSet().toList(),
                      adduser: addNewUser,
                    );

                    // stream: Firestore.instance.collection('users').snapshots(),
                    // builder: (_, snap) {
                    //   if (snap.data == null ||
                    //       snap.connectionState == ConnectionState.waiting) {
                    //     print('loading');
                    //     return Center(child: CircularProgressIndicator());
                    //   }
                    //   return ProffisionalsList(
                    //     users: snap.data.documents,
                    //   );
                    // },
                  }),
            ),
          ),
          Container(
            child: FlatButton(
              onPressed: () {
                print(newUsers);
                print(newUsers.length);
                List<DocumentReference> newList = [];
                for (var ref in newUsers) {
                  var newRef = FirebaseFirestore.instance.doc('users/' + ref);
                  print(newRef);
                  newList.add(newRef);
                }
                widget.goal.addsupportive(newList);
                showDoneMessage();
              },
              child: Text(AppLocalizations.of(context).translate("Done"),
                  style: const TextStyle(
                      color: const Color(0xff3c84f2),
                      fontWeight: FontWeight.w700,
                      fontFamily: "Inter",
                      fontStyle: FontStyle.normal,
                      fontSize: 18.5),
                  textAlign: TextAlign.left),
            ),
          ),
          SizedBox(
            height: 25,
          )
        ],
      ),
    );
  }

  List<dynamic> newUsers = [];
  addNewUser(user) {
    if (newUsers.contains(user)) {
      newUsers.remove(user);
    } else {
      newUsers.add(user);
    }
    print(newUsers);
  }
}

class ProffisionalsList extends StatefulWidget {
  final List<dynamic> users;
  final List<String> alreadySelected;
  final Function(dynamic) adduser;
  @override
  ProffisionalsList({this.users, this.alreadySelected, this.adduser});
  @override
  _ProffisionalsListState createState() => _ProffisionalsListState();
}

class _ProffisionalsListState extends State<ProffisionalsList> {
  @override
  initState() {
    this.selectedUsers = [];
    super.initState();
  }

  List<String> selectedUsers = [];
  String getInitials(user) {
    List<String> nameInits = user.name.split(' ');
    if (nameInits.length > 1) {
      return nameInits[0][0] + nameInits[1][0];
    } else {
      return nameInits[0][0];
    }
  }
  String getRole(PelotonProfissional user){
        var role = AppLocalizations.of(context).translate(user.employmentDetails.roles.first);
        if(role != null){
          return role;
        }else{
          return '';
        }
        
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        itemCount: widget.users.length,
        itemBuilder: (_, index) {
          return FutureBuilder(
            future: widget.users[index].get(),
            builder: (_, userSnap) {
              if (userSnap.data == null) {
                return Container();
              } else {
                PelotonProfissional user =
                    PelotonProfissional.fromJson(userSnap.data.data());

                user.id = widget.users[index].documentID;
                return (ListTileTheme(
                  iconColor: Colors.green,
                  selectedColor: Colors.green,
                  child: CheckboxListTile(
                    selected: selectedUsers.contains(user.id) ||
                        widget.alreadySelected.contains(user.id),
                    onChanged: widget.alreadySelected.contains(user.id)
                        ? null
                        : (selected) {
                            if (widget.alreadySelected.contains(user.id)) {
                              return;
                            }
                            setState(() {
                              if (selected) {
                                selectedUsers.add(user.id);
                              } else {
                                selectedUsers.remove(user.id);
                              }
                            });
                            print(selectedUsers.contains(user.id));
                            print(widget.alreadySelected.contains(user.id));
                            widget.adduser(user.id);
                          },
                    controlAffinity: ListTileControlAffinity.leading,
                    value: selectedUsers.contains(user.id) ||
                        widget.alreadySelected.contains(user.id),
                    secondary: Container(
                        constraints: BoxConstraints(maxWidth: 50),
                        child: user.personalInformation.profileImage.length > 0
                            ? CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage(
                                  user.personalInformation.profileImage ?? '',
                                ),
                              )
                            : Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.grey.withOpacity(0.5)),
                                child: Center(
                                    child: Text(
                                  getInitials(user.personalInformation),
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700),
                                )),
                              )),
                    title: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            user.personalInformation.name,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.bold,
                                fontSize: 17),
                          ),
                          Text(
                            getRole(user),
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          Divider()
                        ],
                      ),
                    ),
                  ),
                ));
              }
            },
          );
        },
      ),
    );
  }
}
