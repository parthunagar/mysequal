import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:peloton/models/pelotonTask.dart';

import 'activities_types/goal_activities.dart';

enum GoalStatus { done, partialy, declined, notDetermined }

class PelotonGoal {
  String id;
  final String goal;
  final String details;
  GoalStatus status = GoalStatus.notDetermined;
  final String createAt;
  final String title;
  final List<dynamic> members;
  final Timestamp dueDate;
  final int goalColor;
  List<PelotonTask> tasks;
  Map<String, dynamic> sharedInfo;
  final List<GoalJournalActivity> recoverProgram;
  final String whatCanHelp;
  final String whatCanPrevent;
  final List<dynamic> supportive;
  final String orginization;
  final String successCriteria;

  PelotonGoal(
      {this.id,
      this.createAt,
      this.title,
      this.details,
      this.goal,
      this.goalColor,
      this.tasks,
      this.status,
      this.members,
      this.dueDate,
      this.sharedInfo,
      this.recoverProgram,
      this.whatCanHelp,
      this.whatCanPrevent,
      this.supportive,
      this.orginization,
      this.successCriteria
      });

  factory PelotonGoal.fromJson(Map<String, dynamic> parsedJson) {
    List<dynamic> getMembers() {
      List<dynamic> arrayOfuser = [];
      arrayOfuser..add(parsedJson['owner'] ?? '');
      if (parsedJson['supportive'] != null) {
        arrayOfuser.add(parsedJson['supportive']);
      }
      if (parsedJson['peers'] != null) {
        arrayOfuser.add(parsedJson['peers']);
      }

      return arrayOfuser;
    }

    List<GoalJournalActivity> getActivities(activitieslist) {
      if (activitieslist == null){
        return [];
      }
      List<GoalJournalActivity> result = [];
      for (var item in activitieslist) {
        var activity = GoalJournalActivity.fromJson(item);
        result.add(activity);
      }

      return result;
    }

    return PelotonGoal(
        id: parsedJson['id'],
        tasks: parsedJson['tasks'],
        createAt: parsedJson['create_at'],
        title: parsedJson['goal_name'],
        details: parsedJson['why_important'],
        goal: parsedJson['category'],
        status: parsedJson['status'],
        goalColor: int.parse("0xFF" + parsedJson['goal_color']),
        dueDate: parsedJson['due_date'],
        members: getMembers(),
        sharedInfo: parsedJson['shared_info'],
        recoverProgram: getActivities(parsedJson['recover_program_journal']),
        whatCanHelp: parsedJson['what_can_help'],
        whatCanPrevent: parsedJson['what_can_prevent'],
        orginization: parsedJson['orginization'],
        supportive: parsedJson['supportive'] ?? [],
        successCriteria : parsedJson['success_criteria'])
        ;
  }

    addsupportive(List<DocumentReference> newMember) {
      for(var member in newMember){
        this.supportive.add(member);
      }
      
    FirebaseFirestore.instance.collection('goals').doc('${this.id}').update(
      {
        'supportive': this.supportive,
      },
    );
  }
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
