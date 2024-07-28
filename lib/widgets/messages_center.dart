import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:peloton/managers/auth_provider.dart';
import 'package:peloton/models/PelotonGoal.dart';
import 'package:peloton/models/peloton_message.dart';
import 'package:peloton/views/goals_page/selected_goal.dart';
import 'package:url_launcher/url_launcher.dart';

import 'messages_widgets.dart';

class MessagesCenter extends StatelessWidget {
  final Function(String) handleAction;
  @override
  MessagesCenter({this.handleAction});

  void handleTap(PelotonMessage message, context) async {
    changeMessageStatus(message);
    if (message.type == 'survey') {
      _launchURL(message.url);
      return;
    }
    if (message.callToAction == null) {
      return;
    }
    switch (message.callToAction.action) {
      case 'goals':
        print('open goals');
        handleAction('goals');
        break;
      case 'journal':
        print('open journal');
        handleAction('journal');
        break;
        break;
      case 'feed':
        print('open feed');
        handleAction('feed');
        break;
      case 'goal':
        print('open goal page');
        var userDoc = await FirebaseFirestore.instance
            .collection('goals')
            .doc(message.callToAction.actionId)
            .get();
        PelotonGoal goal = PelotonGoal.fromJson(userDoc.data());
        goal.id = userDoc.id;
        showSelectedGoal(goal, context);
        break;
      default:
        return;
    }
  }

  showSelectedGoal(PelotonGoal goal, context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SelectedGoalWidget(goal: goal)),
    );
  }

  _launchURL(url) async {
    if (url == null || url.length == 0) {
      return;
    }
    if (!url.startsWith('http')) {
      url = 'https://' + url;
    }
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      return;
    }
  }

  changeMessageStatus(message, {status = true}) {
    FirebaseFirestore.instance
        .doc('/notifications/${message.id}')
        .update({'read': status});
  }

  @override
  Widget build(BuildContext context) {
    String myId = AuthProvider.of(context).auth.currentUserId;
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('patientid', isEqualTo: myId)
            .where('read', isEqualTo: false)
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (_, snap) {
          if (snap.data == null) {
            return Container();
          }
          if (snap.data.documents.length == 0) {
            return Container();
          }

          List<PelotonMessage> messages = [];
          List<Widget> widgets = [];
          for (var mes in snap.data.documents.take(3) ?? []) {
            PelotonMessage message = PelotonMessage.fromJson(mes.data());
            message.id = mes.id;
            messages.add(message);
            widgets.add(
              Dismissible(
                onDismissed: (direction) {
                  changeMessageStatus(message);
                },
                key: UniqueKey(),
                child: GestureDetector(
                  child: AssesmentMessage(
                    message: message,
                  ),
                  onTap: () {
                    handleTap(message, context);
                  },
                ),
              ),
            );
          }
          return Column(
            children: widgets,
          );
        },
      ),
    );
  }
}
