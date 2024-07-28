import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/managers/auth_provider.dart';
import 'package:peloton/models/peloton_profissional.dart';


class MyOrbitsWidget extends StatelessWidget {
  String getInitials(user) {
    List<String> nameInits = user.name.split(' ');
    if (nameInits.length > 1) {
      return nameInits[0][0] + nameInits[1][0];
    } else {
      return nameInits[0][0];
    }
  }
    String getRole(PelotonProfissional user,context){
        var role = AppLocalizations.of(context).translate(user.employmentDetails.roles.first);
        if(role != null){
          return role;
        }else{
          return '';
        }
        
  }

  @override
  Widget build(BuildContext context) {
    var orgIDs =
        AuthProvider.of(context).auth.currentUserDoc['organizationsID'] ?? [];
    List<Map> orgsList =
        AuthProvider.of(context).auth.currentUserDoc['caseManager'] ?? [];
    var myId = AuthProvider.of(context).auth.currentUserId;

    List<DocumentReference> usersList = [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate("MyOrbits"),
          style:
              TextStyle(fontFamily: 'Inter', fontSize: 17, color: Colors.white),
        ),
      ),
      body: StreamBuilder(
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
          for (var temp in orgsList){
            usersList.add(temp['casemaneger']);
          }
          for (var doc in snap.data.docs) {
            for (var item in doc.data()['supportive'] ?? []) {
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

          var newList = usersList.toSet().toList();

          return ListView.builder(
            itemCount: newList.length,
            itemBuilder: (_, index) {
              return FutureBuilder(
                future: newList[index].get(),
                builder: (_, userSnap) {
                  if (userSnap.data == null) {
                    return Container();
                  } else {
                    PelotonProfissional user =
                        PelotonProfissional.fromJson(userSnap.data.data());
                    return ListTile(
                      contentPadding: EdgeInsets.all(12),
                      leading: user.personalInformation.profileImage.length > 0
                          ? CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(
                                user.personalInformation.profileImage ?? '',
                              ),
                            )
                          : Column(
                              children: <Widget>[
                                Container(
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
                                ),
                              ],
                            ),
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            user.personalInformation.name,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.bold,
                                fontSize: 17),
                          ),
                          Text(
                           getRole(user, context),
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          Divider()
                        ],
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
