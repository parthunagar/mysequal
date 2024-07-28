import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';

enum TaskStatus { done, partialy, declined, notDetermined }

class PelotonTask {
  String id;
  TaskStatus status;
  final Timestamp createAt;
  final String title;
  final String details;
  final String goal;
  bool isHandRaised;
  final int taskColor;
  final Timestamp dueDate;
  final Map<String, dynamic> goalData;
  final String url;
  final String statusNotes;
  final String assignee;
  final bool isSelfCreated;
  final String handRaisedText;
  final String patientId;
  final String orginization;
  final Timestamp statusDate;

  PelotonTask(
      {this.id,
      this.status,
      this.createAt,
      this.title,
      this.details,
      this.goal,
      this.isHandRaised,
      this.taskColor,
      this.dueDate,
      this.goalData,
      this.url,
      this.statusNotes,
      this.assignee,
      this.isSelfCreated,
      this.handRaisedText,
      this.patientId,
      this.orginization,
      this.statusDate
      });

  factory PelotonTask.fromJson(Map<String, dynamic> parsedJson) {
    TaskStatus getTaskStatus(val) {
      if (val == 3) {
        return TaskStatus.done;
      } else if (val == 2) {
        return TaskStatus.partialy;
      } else if (val == 1) {
        return TaskStatus.declined;
      } else {
        return TaskStatus.notDetermined;
      }
    }

    String getGoal(goaldata) {
      return goaldata != null ? goaldata['goal_name'] : 'My Tasks';
    }


    return PelotonTask(
        id: parsedJson['documentID'],
        status: getTaskStatus(parsedJson['status']),
        createAt: parsedJson['created_at'],
        title: parsedJson['task_title'],
        details: parsedJson['description'],
        goal: getGoal(parsedJson[
            'goal_data']), //parsedJson['goal_data']['category'] ??'',
        isHandRaised: parsedJson['hand_raised'],
        taskColor: int.parse(("0xFF"+parsedJson[
            'goal_data']['color'])), //HexColor(parsedJson['goal_data']['color'] ?? '00bcd4'),
        dueDate: parsedJson['due_date'],
        goalData: parsedJson['goal_data'],
        url: parsedJson['url'],
        statusNotes: parsedJson['status_notes'],
        assignee: parsedJson['assignee'],
        isSelfCreated: parsedJson['isSelfCreated'],
        handRaisedText: parsedJson['hand_raised_text'],
        orginization: parsedJson['orginization'],
        patientId: parsedJson['patientid'],
        statusDate: parsedJson['status_date'],
        );
  }

  updateTaskStatus(TaskStatus newStatus) {
    
    int taskVal = 0;
    if (newStatus == TaskStatus.done) {
      taskVal = 3;
    } else if (newStatus == TaskStatus.partialy) {
      taskVal = 2;
    } else if (newStatus == TaskStatus.declined) {
      taskVal = 1;
    }

    try {
      FirebaseFirestore.instance.collection('tasks').doc('${this.id}').update(
        {'status': taskVal},
      );
    } catch (error) {
      print(error);
    }
  }

  updateHansRaisedStatus(bool isRaised) {
    FirebaseFirestore.instance.collection('tasks').doc('${this.id}').update(
      {'hand_raised': isRaised},
    );
  }

  updateTaskRaisedText(String text) {
    FirebaseFirestore.instance.collection('tasks').doc('${this.id}').update(
      {'hand_raised_text': text},
    );
  }

  Future<void> updateLocation() async {
    int taskVal = 0;
    var newStatus = this.status;
    if (newStatus == TaskStatus.done) {
      taskVal = 3;
    } else if (newStatus == TaskStatus.partialy) {
      taskVal = 2;
    } else if (newStatus == TaskStatus.declined) {
      taskVal = 1;
    }
    var loc = await getLocation();
    FirebaseFirestore.instance.collection('patient_actions').add(
      {
        'patientid': this.patientId,
        'location': {'lat': loc.latitude ?? '', 'long': loc.longitude ?? ''},
        'activity':{'task_status': taskVal,},
        'task': this.id,
        'datetime': Timestamp.now(),
        'action_type': 'task_status_change'
      },
    );
  }
  Future<void> updateHandRaisedAction() async {
        var loc = await getLocation();
    FirebaseFirestore.instance.collection('patient_actions').add(
      {
        'patientid': this.patientId,
        'location': {'lat': loc.latitude ?? '', 'long': loc.longitude ?? ''},
        'activity':{'hand_raised': true,},
        'task': this.id,
        'datetime': Timestamp.now(),
        'action_type': 'hand_raised'
      },
    );
  }
    Future<void> updateDisccusionAction() async {
        var loc = await getLocation();
    FirebaseFirestore.instance.collection('patient_actions').add(
      {
        'patientid': this.patientId,
        'location': {'lat': loc.latitude ?? '', 'long': loc.longitude ?? ''},
        'activity':{'discussion_point': true,},
        'task': this.id,
        'datetime': Timestamp.now(),
        'action_type': 'discussion_point'
      },
    );
  }

  Future<LocationData> getLocation() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      if (!_serviceEnabled) {
        return null;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }
    _locationData = await location.getLocation();
    return _locationData;
  }

  addNotes(String notes) {
    FirebaseFirestore.instance.collection('tasks').doc('${this.id}').update(
      {
        'status_notes': notes,
      },
    );
  }
}
