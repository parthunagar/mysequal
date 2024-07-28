import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/managers/auth_provider.dart';

import 'discussions_widget.dart';
import 'my_orbit.dart';
import 'my_privacy.dart';

class MyPelotondata extends StatelessWidget {
  Future<int> getDescussionsCount(context) async {
    var result = await FirebaseFirestore.instance
        .collection('notes')
        .where('owner', isEqualTo: AuthProvider.of(context).auth.currentUserId)
        .where('note_type.type',isEqualTo: 'DISCUSSION POINT').get();
        print('notes count' );
        
        print(result.docs.length);
        return result.docs.length;

        
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(12),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              color: const Color(0x29000000),
              offset: Offset(0, 0),
              blurRadius: 21,
              spreadRadius: 0)
        ],
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: <Widget>[
          ListTile(
            leading: Image.asset(
              'assets/discussion.png',
              height: 20,
              width: 60,
            ),
            title: FutureBuilder<int>(
              future: getDescussionsCount(context),
              builder: (context, snapshot) {
                if(snapshot.data == null || snapshot.connectionState == ConnectionState.waiting){
                  return Text('');
                }
                return Text(
                  AppLocalizations.of(context).translate("Topics") + ' (' + snapshot.data.toString() +')',
                  style: const TextStyle(
                      color: const Color(0xff3c84f2),
                      fontWeight: FontWeight.w400,
                      fontFamily: "Inter",
                      fontStyle: FontStyle.normal,
                      fontSize: 16.5),
                );
              }
            ),
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  opaque: true,
                  pageBuilder: (BuildContext context, _, __) {
                    return DiscussionsWidget();
                  },
                ),
              );
            },
          ),
          Divider(),
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  opaque: true,
                  pageBuilder: (BuildContext context, _, __) {
                    return MyOrbitsWidget();
                  },
                ),
              );
            },
            leading: Image.asset(
              'assets/saturn.png',
              height: 20,
              width: 60,
            ),
            title: Text(
              AppLocalizations.of(context).translate("MyOrbits"),
              style: const TextStyle(
                  color: const Color(0xff3c84f2),
                  fontWeight: FontWeight.w400,
                  fontFamily: "Inter",
                  fontStyle: FontStyle.normal,
                  fontSize: 16.5),
            ),
          ),
          Divider(),
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  opaque: true,
                  pageBuilder: (BuildContext context, _, __) {
                    return MyPrivacyWidget();
                  },
                ),
              );
            },
            leading: Image.asset(
              'assets/lock.png',
              height: 20,
              width: 60,
            ),
            title: Text(
              AppLocalizations.of(context).translate("MyPrivacy"),
              style: const TextStyle(
                  color: const Color(0xff3c84f2),
                  fontWeight: FontWeight.w400,
                  fontFamily: "Inter",
                  fontStyle: FontStyle.normal,
                  fontSize: 16.5),
            ),
          ),
        ],
      ),
    );
  }
}
