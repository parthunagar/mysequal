import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/managers/analytics_actions.dart';
import 'package:peloton/managers/analytics_manager.dart';
import 'package:peloton/managers/auth_provider.dart';
import 'package:peloton/models/patient_program.dart';
import 'package:peloton/views/my_profile/orginization_terms.dart';

import 'my_privacy_header.dart';

class MyPrivacyWidget extends StatefulWidget {
  @override
  _MyPrivacyWidgetState createState() => _MyPrivacyWidgetState();
}

class _MyPrivacyWidgetState extends State<MyPrivacyWidget> {
  @override
  Widget build(BuildContext context) {
    var currentUserId = AuthProvider.of(context).auth.currentUserId;
    return Scaffold(
      backgroundColor: Color(0xfff4f5f9),
      appBar: AppBar(
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          MyPrivacyHeader(),
          Expanded(
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Image.asset(
                        'assets/shield.png',
                        width: 55,
                        height: 62,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          AppLocalizations.of(context)
                              .translate("MyPrivacyIntro"),
                          style: const TextStyle(
                              color: const Color(0xff3c84f2),
                              fontWeight: FontWeight.w400,
                              fontFamily: "Inter",
                              fontStyle: FontStyle.normal,
                              fontSize: 18.0),
                        ),
                      ),
                    )
                  ],
                ),
                Expanded(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('patient_program')
                        .where('patientid', isEqualTo: currentUserId)
                        .where('orginization.status',
                            whereIn: ['Active', 'Pending']).snapshots(),
                    builder: (_, snap) {
                      if (snap.data == null) {
                        return Container();
                      }
                      return ListView.builder(
                          itemCount: snap.data.documents.length,
                          itemBuilder: (_, index) {
                            var doc = snap.data.documents[index];
                            PatientProgram temp =
                                PatientProgram.fromJson(doc.data());
                            temp.id = doc.id;
                            return OrginizationWidget(
                              orginization: temp,
                            );
                          });
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class OrginizationWidget extends StatefulWidget {
  final PatientProgram orginization;
  @override
  OrginizationWidget({this.orginization});
  @override
  _OrginizationWidgetState createState() => _OrginizationWidgetState();
}

class _OrginizationWidgetState extends State<OrginizationWidget> {
  Future<void> _showDeleteDialog(context) async {
    showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: CircleAvatar(
            radius: 40,
            backgroundColor: Color(0xffc02e2f),
            child: Image.asset(
              'assets/bin.png',
              color: Colors.white,
              height: 50,
              width: 50,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  AppLocalizations.of(context).translate('DisconnectOrgAlert'),
                  style: const TextStyle(
                      color: const Color(0xff4a4a4a),
                      fontWeight: FontWeight.w400,
                      fontFamily: "Inter",
                      fontStyle: FontStyle.normal,
                      fontSize: 20.0),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                AppLocalizations.of(context).translate('No'),
                style: const TextStyle(
                    color: const Color(0xffc02e2f),
                    fontWeight: FontWeight.w500,
                    fontFamily: "Inter",
                    fontStyle: FontStyle.normal,
                    fontSize: 16.5),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                AppLocalizations.of(context).translate('Yes'),
                style: const TextStyle(
                    color: const Color(0xff3c84f2),
                    fontWeight: FontWeight.w500,
                    fontFamily: "Inter",
                    fontStyle: FontStyle.normal,
                    fontSize: 16.5),
              ),
              onPressed: () {
                 AnalyticsManager.instance.addEvent(AnalytictsActions.privacyDisconnect, null);
                widget.orginization.changeStatus('Disconnected');
                AuthProvider.of(context).auth.updatePrograms();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<dynamic> showSelectedOrg(org) async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => OrginizationTerms(
                orginization: org,
              )),
    );
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Text(
                  widget.orginization.orginization.name,
                  maxLines: 2,
                  style: const TextStyle(
                      color: const Color(0xff00183c),
                      fontWeight: FontWeight.w700,
                      fontFamily: "Inter",
                      fontStyle: FontStyle.normal,
                      fontSize: 20.0),
                ),
              ),
              Switch(
                  value: widget.orginization.orginization.status == 'Active',
                  onChanged: (val) async {
                    if (val) {
                      AnalyticsManager.instance.addEvent(AnalytictsActions.privacyConnect, null);
                      var result = await showSelectedOrg(widget.orginization);
                      if (result == null) {
                        return;
                      }
                      if (result) {
                        widget.orginization.changeStatus('Active');
                        AuthProvider.of(context).auth.updatePrograms();
                      } else {
                        return;
                      }
                    } else {
                      _showDeleteDialog(context);
                    }
                  })
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Text(
              AppLocalizations.of(context)
                  .translate("PrivacyOrganizationSubTitle"),
              textAlign: TextAlign.start,
              style: const TextStyle(
                  color: const Color(0xff4a4a4a),
                  fontWeight: FontWeight.w400,
                  fontFamily: "Inter",
                  fontStyle: FontStyle.normal,
                  fontSize: 18.0),
            ),
          ),
        ],
      ),
    );
  }
}
