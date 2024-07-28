import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/managers/auth_provider.dart';
import 'package:peloton/models/PelotonUser.dart';
import 'package:peloton/models/pelotonTask.dart';

class ProgressTasksWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var myData =
        PelotonUser.fromJson(AuthProvider.of(context).auth.currentUserDoc);
    var orgIDs =
        AuthProvider.of(context).auth.currentUserDoc['organizationsID'] ?? [];

    List<PelotonTask> tasksList = [];
    return Container(
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('tasks')
            .where('patientid', isEqualTo: myData.id)
            //   .where('orginization', whereIn: orgIDs)
            .snapshots(),
        builder: (_, snap) {
          if (snap.data == null ||
              snap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          var completed = 0;
          for (var doc in snap.data.docs) {
            var task = PelotonTask.fromJson(doc.data());
            task.id = doc.id;
            tasksList.add(task);
            if (task.status == TaskStatus.done) {
              completed++;
            }
          }
          var totalTasks = snap.data.docs.length ?? 0;

          return Column(
            children: [
              Text(
                '$completed' +
                    '/' +
                    '$totalTasks' +
                    ' ' +
                    AppLocalizations.of(context)
                        .translate("MyProgressTasksTitle"),
                style: const TextStyle(
                    color: const Color(0xff3c84f2),
                    fontWeight: FontWeight.w400,
                    fontFamily: "Inter",
                    fontStyle: FontStyle.normal,
                    fontSize: 18.0),
              ),
              TasksConterWidget(
                tasks: tasksList,
              ),
            ],
          );
        },
      ),
    );
  }
}

class TasksConterWidget extends StatelessWidget {
  final List<PelotonTask> tasks;

  @override
  TasksConterWidget({this.tasks});
  @override
  Widget build(BuildContext context) {
    var completedTasks = 0;
    var deniedTasks = 0;
    var completedInDelay = 0;
    for (var task in tasks) {
      print(task.id);
      switch (task.status) {
        case TaskStatus.done:
          if (task.statusDate.toDate().isAfter(task.dueDate.toDate())) {
            completedInDelay += 1;
          } else {
            completedTasks += 1;
          }

          break;
        case TaskStatus.declined:
          deniedTasks += 1;
          break;
        case TaskStatus.notDetermined:
          print('not det');
          break;
        case TaskStatus.partialy:
          print('part');
      }
    }

    return Container(
      margin: EdgeInsets.all(15),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              color: const Color(0x29000000),
              offset: Offset(0, 0),
              blurRadius: 1,
              spreadRadius: 0)
        ],
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      height: 160,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 95,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$completedTasks',
                  style: TextStyle(
                      color: const Color(0xff3c84f2),
                      fontWeight: FontWeight.w600,
                      fontFamily: "Inter",
                      fontStyle: FontStyle.normal,
                      fontSize: 17.0),
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  AppLocalizations.of(context).translate("ProgressOnTime"),
                  style: const TextStyle(
                      color: const Color(0xff4a4a4a),
                      fontWeight: FontWeight.w400,
                      fontFamily: "Inter",
                      fontStyle: FontStyle.normal,
                      fontSize: 16.0),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          VerticalDivider(
            indent: 10,
            endIndent: 10,
            thickness: 0.4,
            color: Colors.grey.withOpacity(0.5),
          ),
          Container(
            width: 95,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$completedInDelay',
                  style: TextStyle(
                      color: const Color(0xff3c84f2),
                      fontWeight: FontWeight.w600,
                      fontFamily: "Inter",
                      fontStyle: FontStyle.normal,
                      fontSize: 17.0),
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  AppLocalizations.of(context).translate("ProgressDelay"),
                  style: const TextStyle(
                      color: const Color(0xff4a4a4a),
                      fontWeight: FontWeight.w400,
                      fontFamily: "Inter",
                      fontStyle: FontStyle.normal,
                      fontSize: 16.0),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          VerticalDivider(
            indent: 10,
            endIndent: 10,
            thickness: 0.4,
            color: Colors.grey.withOpacity(0.5),
          ),
          Container(
            width: 95,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$deniedTasks',
                  style: TextStyle(
                      color: const Color(0xff3c84f2),
                      fontWeight: FontWeight.w600,
                      fontFamily: "Inter",
                      fontStyle: FontStyle.normal,
                      fontSize: 18.0),
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  AppLocalizations.of(context).translate("ProgressDeclined"),
                  style: const TextStyle(
                      color: const Color(0xff4a4a4a),
                      fontWeight: FontWeight.w400,
                      fontFamily: "Inter",
                      fontStyle: FontStyle.normal,
                      fontSize: 16.0),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
