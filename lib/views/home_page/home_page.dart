import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/managers/analytics_actions.dart';
import 'package:peloton/managers/analytics_manager.dart';
import 'package:peloton/managers/auth_provider.dart';
import 'package:peloton/models/pelotonTask.dart';
import 'package:peloton/views/home_page/home_date_selection.dart';
import 'package:peloton/views/home_page/home_page_header.dart';
import 'package:peloton/views/selected_task_page.dart';
import 'package:peloton/widgets/messages_center.dart';
import 'package:peloton/widgets/my_stories.dart';
import 'package:peloton/widgets/no_tasks_widget.dart';
import 'package:peloton/widgets/task_wdget.dart';
import 'package:sticky_headers/sticky_headers.dart';

class HomePageWidget extends StatefulWidget {
  final Function controller;
  final Function(String) handleTap;
  @override
  HomePageWidget({this.controller,this.handleTap});
  @override
  _HomePageWidgetState createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget>
    with
        TickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<HomePageWidget> {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    String _currentUserId = AuthProvider.of(context).auth.currentUserId;

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 0),
          color: Color(0xfff4f5f9),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              HomePageHeaader(),
              SizedBox(height: 10),
              Expanded(
                child: MediaQuery.removePadding(
                  removeTop: true,
                  context: context,
                  child: ListView(
                    children: <Widget>[
                      //  HomePageHeaader(),
                      // SizedBox(
                      //   height: 120,
                      //   child: AssesmentMessage(),
                      // ),
                     MessagesCenter(handleAction: widget.handleTap,),
                      MyStoriesWidget(
                        controller: widget.controller,
                      ),
                      TasksListwithPicker(currentUserId: _currentUserId),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Positioned(
        //   top: 0,
        //   child: HomePageHeaader(),
        // ),
      ],
    );
  }
}

class TasksListwithPicker extends StatefulWidget {
  final String currentUserId;
  @override
  TasksListwithPicker({this.currentUserId});
  @override
  _TasksListwithPickerState createState() => _TasksListwithPickerState();
}

class _TasksListwithPickerState extends State<TasksListwithPicker> {
  Timestamp startDate;
  Timestamp endDate;
  reloadHome(Timestamp startDate, Timestamp endDate) {
    setState(() {
      this.endDate = endDate;
      this.startDate = startDate;
    });
  }

  getThisWeek() {
    DateTime date = DateTime.now();
    int today = DateTime.now().weekday + 1;
    var weekDelta = today % 7;
    var endOfweek = date.add(Duration(days: 7 - weekDelta));
    var startOfWeek = date.subtract(Duration(days: weekDelta - 1));
    setState(() {
      startDate = Timestamp.fromMillisecondsSinceEpoch(
          startOfWeek.millisecondsSinceEpoch);
      endDate = Timestamp.fromMillisecondsSinceEpoch(
          endOfweek.millisecondsSinceEpoch);
    });
    Future.delayed(Duration(seconds: 1),(){
      setState(() {
        
      });
    });
  }

  showSelectedTask(PelotonTask task, mytask) {
     AnalyticsManager.instance.addEvent(AnalytictsActions.openTaskHomePage, null);
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SelectedTask(
                task: task,
                isMyTask: mytask,
              )),
    );
  }

  @override
  initState() {
    getThisWeek();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> orgIDs =
        AuthProvider.of(context).auth.currentUserDoc['organizationsID'] ?? [];
    if (!orgIDs.contains('Default')) {
      orgIDs.add('Default');
    }

    return StickyHeader(
      header: Container(
        color: Color(0xfff4f5f9),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(0, 15, 0, 6),
              child: Text(
                AppLocalizations.of(context).translate(
                  'My Weekly Tasks',
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Color(0xff00183c),
                    fontFamily: 'Inter',
                    fontSize: 17,
                    fontWeight: FontWeight.w700),
              ),
            ),
            WeekSelectorWidget(
              reloadHome: reloadHome,
            ),
          ],
        ),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('tasks')
                .where('patientid', isEqualTo: widget.currentUserId)
                .where('orginization',
                    whereIn: (orgIDs.length > 0 ? orgIDs : ['']))
                .orderBy('due_date')
                .startAt([
              Timestamp.fromDate(
                startDate.toDate().subtract(
                      Duration(days: 1),
                    ),
              ),
            ]).endAt(
              [endDate],
            ).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.data == null ||
                  snapshot.data.documents.length == 0) {
                return Center(child: NoTasksWidget());
              }

              if (snapshot.hasData) {
                return ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  key: UniqueKey(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    PelotonTask _currentTask = PelotonTask.fromJson(
                        snapshot.data.documents[index].data());

                    PelotonTask prevTask = index > 0
                        ? PelotonTask.fromJson(
                            snapshot.data.documents[index - 1].data())
                        : null;

                    _currentTask.id = snapshot.data.documents[index].id;
                    int currentDay = DateTime.fromMillisecondsSinceEpoch(
                            _currentTask.dueDate.millisecondsSinceEpoch)
                        .day;
                    int prevDay = prevTask != null
                        ? DateTime.fromMillisecondsSinceEpoch(
                                prevTask.dueDate.millisecondsSinceEpoch)
                            .day
                        : 0;

                    var isMyTask =
                        _currentTask.assignee == widget.currentUserId ||
                            _currentTask.assignee == '';
                    return GestureDetector(
                      onTap: () {
                        if (isMyTask) showSelectedTask(_currentTask, isMyTask);
                      },
                      child: TaskWidget(
                        task: _currentTask,
                        shouldShowDate: prevDay != currentDay,
                        isMyTask: isMyTask,
                      ),
                    );
                  },
                  itemCount: snapshot.data.documents.length,
                );
              } else {
                return Center(child: NoTasksWidget());
              }
            },
          )
        ],
      ),
    );
  }
}
