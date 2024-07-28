import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:peloton/managers/analytics_actions.dart';
import 'package:peloton/managers/analytics_manager.dart';

class PelotonNote {
  String id;
  final String title;
  final String body;
  final Timestamp date;
  final int patientSatisfaction;
  final String owner;
  final DocumentReference ownerRef;
  final bool showToAssignee;
  NoteType type;
  final List<NoteAssignee> assignee;

  PelotonNote(
      {this.id,
      this.title,
      this.body,
      this.date,
      this.patientSatisfaction,
      this.owner,
      this.ownerRef,
      this.showToAssignee,
      this.assignee,
      this.type});

  factory PelotonNote.fromJson(Map<String, dynamic> parsedJson) {
    List<dynamic> arrayOfuser = parsedJson['assignee'] ?? [];
    List<NoteAssignee> assignnes = [];
    for (var item in arrayOfuser) {
      assignnes.add(NoteAssignee.fromJson(item));
    }

    return PelotonNote(
      id: parsedJson['id'],
      title: parsedJson['title'],
      body: parsedJson['body'],
      date: parsedJson['date'],
      patientSatisfaction: parsedJson['patient_satisfaction'],
      owner: parsedJson['owner'],
      ownerRef: parsedJson['owner_ref'],
      showToAssignee: parsedJson['show_to_assignee'],
      assignee: assignnes,
      type: NoteType.fromJson(parsedJson['note_type']),
    );
  }
  Future<void> deleteThisNote() async {
    AnalyticsManager.instance.addEvent(AnalytictsActions.deleteJournal, null);
    return await FirebaseFirestore.instance.collection('notes').doc(id).delete();
  }
}

class NoteType {
  final DocumentReference likedTo;
  final String type;

  NoteType({
    this.likedTo,
    this.type,
  });

  factory NoteType.fromJson(Map<String, dynamic> parsedJson) {
    return NoteType(
      likedTo: parsedJson['linked_to'],
      type: parsedJson['type'],
    );
  }
}

class NoteAssignee {
  final String id;
  final DocumentReference ref;
  final bool seen;

  NoteAssignee({
    this.id,
    this.ref,
    this.seen,
  });

  factory NoteAssignee.fromJson(Map<String, dynamic> parsedJson) {
    return NoteAssignee(
      id: parsedJson['id'],
      ref: parsedJson['ref'],
      seen: parsedJson['seen'],
    );
  }
}
