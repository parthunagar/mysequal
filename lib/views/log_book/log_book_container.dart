import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/managers/auth_provider.dart';
import 'package:peloton/models/story.dart';
import 'package:peloton/views/home_page/home_date_selection.dart';
import 'package:peloton/views/log_book/log_book_header.dart';
import 'package:peloton/views/my_profile/my_progress/my_progress.dart';
import 'package:peloton/widgets/no_story_widget.dart';

import 'log_book.dart';

class LogBookContainer extends StatefulWidget {
  @override
  _LogBookContainerState createState() => _LogBookContainerState();
}

class _LogBookContainerState extends State<LogBookContainer>
    with
        TickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<LogBookContainer> {
  @override
  bool get wantKeepAlive => true;
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

    print(today);
    print(startOfWeek);
    print(endOfweek);
    setState(() {
      startDate = Timestamp.fromMillisecondsSinceEpoch(
          startOfWeek.millisecondsSinceEpoch);
      endDate = Timestamp.fromMillisecondsSinceEpoch(
          endOfweek.millisecondsSinceEpoch);
    });
  }


  @override
  void initState() {
    getThisWeek();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
     super.build(context);
    return Container(
      child: Column(
        children: <Widget>[
          LogBookHeader(),
          SizedBox(
            height: 20,
          ),
          WeekSelectorWidget(
            reloadHome: reloadHome,
          ),
          MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: Expanded(
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('journal')
                      .where('patient_id',
                          isEqualTo:
                          
                              AuthProvider.of(context).auth.currentUserId)
                      .orderBy('created_at')
                      .startAt([
                    Timestamp.fromDate(
                      startDate.toDate().subtract(
                            Duration(days: 1),
                          ),
                    ),
                  ]).endAt([endDate]).snapshots(),
                  builder: (context, snapshot) {
             
                    if ((snapshot.hasData == false &&
                        snapshot.hasError == false) || snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        child: Column(
                          children: <Widget>[
                            Center(
                              child: Text(
                                AppLocalizations.of(context)
                                    .translate('NoStories'),
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            NoStoryWidget()
                          ],
                        ),
                      );
                    }
                    // if (snapshot.hasData == true &&
                    //     snapshot.hasError == false &&
                    //     snapshot.connectionState == ConnectionState.waiting) {
                    //   return Container(
                    //     child: Column(
                    //       children: <Widget>[
                    //         Center(
                    //           child: Text(
                    //             AppLocalizations.of(context)
                    //                 .translate('NoStories'),
                    //           ),
                    //         ),
                    //         SizedBox(
                    //           height: 30,
                    //         ),
                    //         NoStoryWidget()
                    //       ],
                    //     ),
                    //   );
                    // }

                    if (snapshot.data == null) {
                      return Container();
                    }
                    if (snapshot.data.documents.length == 0) {
                      return Container(
                        child: Column(
                          children: <Widget>[
                            Center(
                              child: Text(
                                AppLocalizations.of(context)
                                    .translate('NoStories'),
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            NoStoryWidget()
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (_, index) {
                        Story story =
                            Story.fromJson(snapshot.data.documents.reversed.toList()[index].data());
                        story.id = snapshot.data.documents[index].id;
                        return LogBookwidget(
                          story: story,
                        );
                      },
                    );
                  }),
            ),
          )
        ],
      ),
    );
  }
}
