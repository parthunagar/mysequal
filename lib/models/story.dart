import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:peloton/managers/analytics_actions.dart';
import 'package:peloton/managers/analytics_manager.dart';
import 'package:peloton/models/activities_types/goal_activities.dart';

class Story {
  String id;
  final Map<String, dynamic> media;
  final Timestamp createAt;
  final int mood;
  final String title;
  final String description;
  final List<GoalJournalActivity> healthProfile;
  final String patientId;

  Story(
      {this.id,
      this.media,
      this.createAt,
      this.mood,
      this.title,
      this.description,
      this.healthProfile,
      this.patientId});

  factory Story.fromJson(Map<String, dynamic> parsedJson) {

    List<GoalJournalActivity> getActivities(activitieslist) {
      if (activitieslist == null) {
        return [];
      }
      List<GoalJournalActivity> result = [];
      for (var item in activitieslist) {
        var activity = GoalJournalActivity.fromJson(item);
        result.add(activity);
      }

      return result;
    }

    return Story(
      createAt: parsedJson['created_at'],
      media: parsedJson['media'],
      mood: parsedJson['mood'],
      title: parsedJson['title'],
      description: parsedJson['description'],
      healthProfile: getActivities(parsedJson['recover_program_journal']),
      patientId: parsedJson['patient_id'],
    );
  }
    Future<void> deleteThisStory() async {
      AnalyticsManager.instance.addEvent(AnalytictsActions.deleteJournal, {"title":this.title,"id":this.id});
    return await FirebaseFirestore.instance.collection('journal').doc(id).delete();
  }
}
