import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/managers/auth_provider.dart';
import 'package:peloton/models/peloton_note.dart';
import 'package:peloton/models/peloton_profissional.dart';

import 'discussions_list_header.dart';

class DiscussionsWidget extends StatelessWidget {
  List<Widget> assigneesNotes(List<PelotonNote> notes) {
    List<Widget> result = [];
    Map<String, List<PelotonNote>> assignes = {};
    for (PelotonNote note in notes) {
      if (assignes[note.assignee.first.id.toString()] != null) {
        assignes[note.assignee.first.id.toString()].add(note);
      } else {
        assignes[note.assignee.first.id.toString()] = [note];
      }
    }
    assignes.forEach((key, value) {
      print(value.first.assignee.first.ref);
      result.add(DisscussionListTile(notes: value));
    });
    return result;
  }

  @override
  Widget build(BuildContext context) {
    print(AuthProvider.of(context).auth.currentUserId);
    print('*********');
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            Text(
              AppLocalizations.of(context).translate('DiscussionsList'),
              style: Theme.of(context).primaryTextTheme.headline3,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        elevation: 0,
      ),
      backgroundColor: Color(0xfff4f5f9),
      body: Container(
        child: Column(
          children: <Widget>[
            DiscussionHeader(),
            Expanded(
              child: StreamBuilder(
                builder: (_, snapshot) {
                  if (snapshot.data == null) {
                    return Container();
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  List<PelotonNote> notes = [];
                  snapshot.data.documents.forEach((item) {
                    PelotonNote note = PelotonNote.fromJson(item.data());
                    note.id = item.id;
                    print(note.body);
                    notes.add(note);
                    // var user = await note.ownerRef.get();
                    // print(PelotonUser.fromJson(user.data).firstName);
                  });
                  if (notes.length == 0) {
                    return Center(
                      child: Text(
                        AppLocalizations.of(context).translate('NoNotes'),
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 17,
                        ),
                      ),
                    );
                  }
                  return ListView(
                    children: assigneesNotes(notes),
                  );
                },
                stream: FirebaseFirestore.instance
                    .collection('notes')
                    .where('owner',
                        isEqualTo: AuthProvider.of(context).auth.currentUserId)
                    .where('note_type.type', isEqualTo: 'DISCUSSION POINT')
                    .orderBy('date', descending: true)
                    .snapshots(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DisscussionListTile extends StatelessWidget {
  showDeletedialog(PelotonNote note, context) {
    _showMyDialog(note, context);
    //note.deleteThisNote();
  }

  Future<void> _showMyDialog(PelotonNote note, context) async {
    showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xffc02e2f),
              child: Image.asset(
                'assets/bin.png',
                color: Colors.white,
                height: 50,
                width: 50,
              )),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  AppLocalizations.of(context)
                      .translate('DeleteDiscussionPoint'),
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
                note.deleteThisNote();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  DisscussionListTile({this.notes});
  final List<PelotonNote> notes;

  List<Widget> getNotes(context) {
    List<Widget> result = [];
    notes.asMap().forEach(
      (index, value) {
        result.add(
          Row(
            children: <Widget>[
              Text(
                "${index + 1}.",
                style: const TextStyle(
                    color: const Color(0xff00cdc1),
                    fontWeight: FontWeight.w400,
                    fontFamily: "Inter",
                    fontStyle: FontStyle.normal,
                    fontSize: 16.5),
              ),
              SizedBox(
                width: 12,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    notes[index].title.length > 0
                        ? Text(
                            notes[index].title,
                            style: const TextStyle(
                                color: const Color(0xff4a4a4a),
                                fontWeight: FontWeight.w600,
                                fontFamily: "Inter",
                                fontStyle: FontStyle.normal,
                                fontSize: 15.0),
                          )
                        : Container(),
                    Text(
                      notes[index].body,
                      style: const TextStyle(
                          color: const Color(0xff4a4a4a),
                          fontWeight: FontWeight.w400,
                          fontFamily: "Inter",
                          fontStyle: FontStyle.normal,
                          fontSize: 17.0),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12),
                child: IconButton(
                  onPressed: () {
                    showDeletedialog(value, context);
                  },
                  icon: Icon(Icons.delete),
                  color: Colors.blue,
                ),
              )
            ],
          ),
        );
        if (index != notes.length - 1) {
          result.add(Divider());
        }
      },
    );
    return result;
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
    return FutureBuilder(
      future: this.notes.first.assignee.first.ref.get(),
      builder: (_, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        }
        PelotonProfissional user =
            PelotonProfissional.fromJson(snapshot.data.data());
  
        return Container(
          margin: EdgeInsets.only(top: 15),
          child: Stack(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(color: Colors.white),
                margin: EdgeInsets.only(top: 35),
                padding: EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SizedBox(
                      height: 8,
                    ),
                    RichText(
                      maxLines: 2,
                      text: TextSpan(
                        children: [
                          TextSpan(
                              style: const TextStyle(
                                  color: const Color(0xff00183c),
                                  fontWeight: FontWeight.w700,
                                  fontFamily: "Inter",
                                  fontStyle: FontStyle.normal,
                                  fontSize: 18.0),
                              text: AppLocalizations.of(context)
                                      .translate('TalkWith') +
                                  ' '),
                          TextSpan(
                              style: TextStyle(
                                  color: Color(0xff3c84f2),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "Inter",
                                  fontStyle: FontStyle.italic,
                                  fontSize: 18.0),
                              text: user.personalInformation.name),
                          TextSpan(
                            text:  ' ' + getRole(user, context),
                            style: const TextStyle(
                                color: const Color(0xff3c84f2),
                                fontWeight: FontWeight.w400,
                                fontFamily: "Inter",
                                fontStyle: FontStyle.italic,
                                fontSize: 16.5),
                          ),
                          TextSpan(
                            style: const TextStyle(
                                color: const Color(0xff00183c),
                                fontWeight: FontWeight.w700,
                                fontFamily: "Inter",
                                fontStyle: FontStyle.normal,
                                fontSize: 18.0),
                            text: ' ' +
                                AppLocalizations.of(context)
                                    .translate('About') +
                                ' ',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Column(
                      children: getNotes(context),
                    )
                  ],
                ),
              ),
              PositionedDirectional(
                top: 0,
                end: 12,
                child: Container(
                  width: 52,
                  height: 52,
                  child: CircleAvatar(
                    minRadius: 48,
                    maxRadius: 48,
                    backgroundColor: Colors.white,
                    child: Container(
                      height: 45,
                      width: 45,
                      child: CircleAvatar(
                        radius: 45,
                        backgroundImage: NetworkImage(
                          user.personalInformation.profileImage,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
