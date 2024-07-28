import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/managers/analytics_actions.dart';
import 'package:peloton/managers/analytics_manager.dart';
import 'package:peloton/managers/auth_provider.dart';
import 'package:peloton/models/story.dart';
import 'package:intl/intl.dart' as intl;
import 'package:peloton/views/add_new_story/add_new_story.dart';
import 'package:peloton/views/story_page.dart';
import 'NSbasicWidget.dart';



class MyStoriesWidget extends StatelessWidget {
  final Function controller;
  @override MyStoriesWidget({this.controller});
  showStoryPage(context, Story story) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StoryPageWidget(story: story),
        ));
  }

  showAddNewStory(context) {
 AnalyticsManager.instance.addEvent(AnalytictsActions.addStoryHomePage, null);

    Navigator.push(context, MaterialPageRoute(builder: (cntx) {
      return AddNewStoryWidget();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return NSBaseWidget(builder: (context, sizingInformation) {
      /////////////////////////////////////////////
      // add 2 for first item add new story and last one for show more
      return Container(
          decoration: BoxDecoration(),
          height: sizingInformation
              .scaleByWidth(155), //sizingInformation.scaleByHeight(150.0),
          width: sizingInformation.scaleByWidth(164),
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('journal')
                .where('patient_id',
                    isEqualTo: AuthProvider.of(context).auth.currentUserId)
                .orderBy('created_at', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              // if (snapshot.data == null) {
              //       return Container();
              //     }
              // if (snapshot.connectionState == ConnectionState.waiting &&
              //     snapshot.hasData) {
              //   return Center(child: CircularProgressIndicator());
              // }

              return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: (snapshot.data?.documents?.length ?? 0) + 2,
                  itemBuilder: (_, index) {
                    if (index == 0) {
                      return GestureDetector(
                          onTap: () {
                            showAddNewStory(context);
                          },
                          child: AddNewSory());
                    } else if (index ==
                        (snapshot.data?.documents?.length ?? 0) + 1) {
                      return GestureDetector(
                           onTap:controller,
                        child: LastStoryWidget(),
                      );
                    } else {
                      Story story = Story.fromJson(
                          snapshot.data.documents[index - 1].data());
                      story.id = snapshot.data.documents[index - 1].id;
                      return GestureDetector(
                        onTap: () {
                          showStoryPage(context, story);
                        },
                        child: MyMediaStory(
                          story: story,
                        ),
                      );
                    }
                  });
            },
          )

          /*
        ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: itemsCount,
            itemBuilder: (_, index) {
              if (index == 0) {
                return GestureDetector(
                    onTap: () {
                      showAddNewStory(context);
                    },
                    child: AddNewSory());
              } else if (index == itemsCount - 1) {
                return LastStoryWidget();
              } else {
                return GestureDetector(
                  onTap: () {
                    showStoryPage(context, stories[index - 1]);
                  },
                  child: MyMediaStory(
                    story: stories[index - 1],
                  ),
                );
              }
            }),
            */
          );
    });
  }
}

class AddNewSory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NSBaseWidget(builder: (context, sizingInformation) {
      return Container(
        margin: EdgeInsetsDirectional.fromSTEB(16, 8, 8, 8),
        padding: EdgeInsets.all(
          sizingInformation.scaleByWidth(12.0),
        ),
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: Color(0x29000000),
                  offset: Offset(0, 0),
                  blurRadius: 5,
                  spreadRadius: 0)
            ],
            borderRadius: BorderRadius.all(Radius.circular(6.3)),
            color: const Color(0xffffffff)),
        height: sizingInformation.scaleByWidth(155),
        width: sizingInformation.scaleByWidth(164),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
                AuthProvider.of(context)
                    .auth
                    .currentUserDoc['gender']
                    .toString()
                    .toLowerCase() ==
                'male'
            ? 'assets/add_story_male.png'
            : 'assets/add_story_female.png',
              
              width: sizingInformation.scaleByWidth(79),
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
            ),
            SizedBox(
              height: 2,
            ),
            Text(
              AppLocalizations.of(context).translate('Add Today’s story'),
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: sizingInformation.scaleByWidth(14),
                  fontWeight: FontWeight.w700),
            )
          ],
        ),
      );
    });
  }
}

class MyMediaStory extends StatelessWidget {
  final Story story;
  @override
  MyMediaStory({this.story});

  List<String> getDateComponents(Timestamp createdAt) {
    DateTime parseDt = createdAt.toDate();
    var newFormat = intl.DateFormat("dd-MMM-yyyy");
    String updatedDt = newFormat.format(parseDt);
    return updatedDt.split('-');
  }

  String getTimeComponents(Timestamp createdAt) {
    DateTime parseDt = createdAt.toDate();
    var newFormat = intl.DateFormat.jm();
    String updatedDt = newFormat.format(parseDt);
    return updatedDt;
  }

  @override
  Widget build(BuildContext context) {
    return NSBaseWidget(builder: (context, sizingInformation) {
      var storyDate = getDateComponents(story.createAt);
      var storyTime = getTimeComponents(story.createAt);
      return Stack(
        children: <Widget>[
          Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
                borderRadius: BorderRadius.all(Radius.circular(6.3)),
                color: Color(0xffffffff),
              ),
              height: 155,
              width: 230,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  () {
                    if (story.media == null) {
                      return Container(
                        width: 152,
                        height: 138,
                        child: Center(
                          child: Image.asset(
                            'assets/placeholder.png',
                            fit: BoxFit.contain,
                            alignment: Alignment.center,
                            width: 70,
                            height: 60,
                          ),
                        ),
                      );
                    }
                    switch (story.media['type']) {
                      case 'video':
                        return Container(
                          child: Stack(
                            alignment: Alignment.center,
                            fit: StackFit.loose,
                            children: <Widget>[
                              ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topRight: Directionality.of(context) ==
                                          TextDirection.ltr
                                      ? Radius.zero
                                      : Radius.circular(6),
                                  topLeft: Directionality.of(context) ==
                                          TextDirection.ltr
                                      ? Radius.circular(6)
                                      : Radius.zero,
                                  bottomLeft: Directionality.of(context) ==
                                          TextDirection.ltr
                                      ? Radius.circular(6)
                                      : Radius.zero,
                                  bottomRight: Directionality.of(context) ==
                                          TextDirection.ltr
                                      ? Radius.zero
                                      : Radius.circular(6),
                                ),
                                child: Hero(
                                  tag: story.id,
                                  child: Image.network(
                                    story.media['thumbnail'],
                                    fit: BoxFit.cover,
                                    alignment: Alignment.bottomCenter,
                                    width:
                                        152, //sizingInformation.scaleByWidth(152),
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(8),
                                child: Image.asset(
                                  'assets/multimedia-option.png',
                                  fit: BoxFit.cover,
                                  alignment: Alignment.topLeft,
                                  width: 45,
                                ),
                              ),
                            ],
                          ),
                        );
                      case 'image':
                        return ClipRRect(
                          borderRadius: BorderRadius.only(
                            topRight:
                                Directionality.of(context) == TextDirection.ltr
                                    ? Radius.zero
                                    : Radius.circular(6),
                            topLeft:
                                Directionality.of(context) == TextDirection.ltr
                                    ? Radius.circular(6)
                                    : Radius.zero,
                            bottomLeft:
                                Directionality.of(context) == TextDirection.ltr
                                    ? Radius.circular(6)
                                    : Radius.zero,
                            bottomRight:
                                Directionality.of(context) == TextDirection.ltr
                                    ? Radius.zero
                                    : Radius.circular(6),
                          ),
                          child: Hero(
                            tag: story.id,
                            child: Image.network(
                              story.media['url'],
                              fit: BoxFit.cover,
                              alignment: Alignment.topLeft,
                              width: 145,
                              height:
                                  138, //sizingInformation.scaleByWidth(152),
                            ),
                          ),
                        );
                      default:
                        return Container(
                          width: 152,
                          height: 138,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                child: Hero(
                                  tag: story.id,
                                  child: Image.asset(
                                    'assets/placeholder.png',
                                    fit: BoxFit.contain,
                                    alignment: Alignment.center,
                                    width: 75,
                                    height: 60,
                                  ),
                                ),
                              ),
                              VerticalDivider(
                                thickness: 1,
                                width: 1,
                                color: Color(0xff3c84f2),
                              )
                            ],
                          ),
                        );
                    }
                  }(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 13, 8, 7.5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                storyDate[0],
                                style: TextStyle(
                                  color: Color(0xff00183c),
                                  fontSize: 24.5,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Inter',
                                ),
                              ),
                              Text(
                                storyDate[1].toString().toUpperCase(),
                                style: TextStyle(
                                  color: Color(0xff00183c),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Inter',
                                ),
                              ),
                              SizedBox(
                                height: 1,
                              ),
                              Text(
                                storyDate[2],
                                style: TextStyle(
                                  color: Color(0xff00183c),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          Row(
                            children: <Widget>[
                              Text(
                                storyTime,
                                style: TextStyle(
                                  color: Color(0xff3c84f2),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              )),
          Positioned(
            top: 0,
            right: Directionality.of(context) == TextDirection.rtl
                ? 106 //sizingInformation.scaleByWidth(98)
                : 0,
            left: Directionality.of(context) == TextDirection.ltr
                ? 106 //sizingInformation.scaleByWidth(98)
                : 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                    padding: EdgeInsets.all(5),
                    child: Image.asset(
                      'assets/bface${story.mood}.png',
                      fit: BoxFit.contain,
                    ),
                    width: 40,
                    height: 40,
                    decoration: new BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Color(0xffffffff),
                    )),
              ],
            ),
          )
        ],
      );
    });
  }
}

class LastStoryWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8),
      height: 138,
      width: 230,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            AppLocalizations.of(context).translate(
                'Looks like you are looking for long ago story Check out the'),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/logbook.png',
                  color: Theme.of(context).accentColor,
                  height: 20,
                  width: 16,
                ),
                SizedBox(
                  width: 5.7,
                ),
                Text(
                  AppLocalizations.of(context).translate('Logbook'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).accentColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
