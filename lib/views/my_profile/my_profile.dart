import 'package:flutter/material.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/managers/analytics_actions.dart';
import 'package:peloton/managers/analytics_manager.dart';
import 'package:peloton/managers/auth_provider.dart';
import 'package:peloton/models/PelotonUser.dart';
import 'package:peloton/views/my_profile/graph_data.dart';
import 'package:peloton/views/my_profile/my_progress/my_progress.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'my_progress/mood_distribution.dart';
import 'my_progress/my_progress_graph.dart';
import 'peloton_data.dart';
import 'personal_data_widget.dart';
import 'settings_page/settings_page.dart';

class MyProfileWidget extends StatefulWidget {
  @override
  _MyProfileWidgetState createState() => _MyProfileWidgetState();
}

class _MyProfileWidgetState extends State<MyProfileWidget>
    with TickerProviderStateMixin {
  TabController _tabController;
  int _selectePage = 0;
  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 2, initialIndex: 0);
    super.initState();
  }

  void onTabTapped(int index) {
    setState(() {
      _selectePage = index;
      _tabController.index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    var myData =
        PelotonUser.fromJson(AuthProvider.of(context).auth.currentUserDoc);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            Text(
              AppLocalizations.of(context).translate("MyAccount"),
              style: Theme.of(context).primaryTextTheme.headline3,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
              color: Color(0xff3c84f2),
            ),
            child: TabBar(
              indicatorPadding: EdgeInsets.only(left: 35, right: 35),
              indicatorWeight: 7,
              indicatorColor: Color(0xff00183c).withOpacity(0.7),
              controller: _tabController,
              onTap: onTabTapped,
              tabs: <Widget>[
                Tab(
                  child: Text(
                    AppLocalizations.of(context).translate("MyProfile"),
                    style: const TextStyle(
                        color: const Color(0xffffffff),
                        fontWeight: FontWeight.w500,
                        fontFamily: "Inter",
                        fontStyle: FontStyle.normal,
                        fontSize: 20.0),
                  ),
                ),
                Tab(
                  child: Text(
                    AppLocalizations.of(context).translate("Settings"),
                    style: const TextStyle(
                        color: const Color(0xffffffff),
                        fontWeight: FontWeight.w500,
                        fontFamily: "Inter",
                        fontStyle: FontStyle.normal,
                        fontSize: 20.0),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                ListView(physics: ClampingScrollPhysics(), children: <Widget>[
              //MyProfileHeader(),

              _selectePage == 0
                  ? MyProfileDataWidget(myData)
                  : SettingsPageWidget(),
            ]),
          ),
        ],
      ),
    );
  }
}

class MyProfileDataWidget extends StatefulWidget {
  final PelotonUser mydata;
  @override
  MyProfileDataWidget(this.mydata);

  @override
  _MyProfileDataWidgetState createState() => _MyProfileDataWidgetState();
}

class _MyProfileDataWidgetState extends State<MyProfileDataWidget> {
  showMyProgress() {
    AnalyticsManager.instance.addEvent(AnalytictsActions.showProgress, null);
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) {
          return MyProgressWidget();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 15,
        ),
        PersonalDataWidget(),
        MyPelotondata(),
        SizedBox(
          height: 12,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 20, end: 8),
              child: Text(
                AppLocalizations.of(context).translate("SeeProgress"),
                style: const TextStyle(
                    color: const Color(0xff00183c),
                    fontWeight: FontWeight.w700,
                    fontFamily: "Inter",
                    fontStyle: FontStyle.normal,
                    fontSize: 20.0),
              ),
            ),
            GestureDetector(
              onTap: showMyProgress,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: 18),
                child: Text(
                  AppLocalizations.of(context).translate("ShowMore"),
                  style: const TextStyle(
                      color: const Color(0xff3c84f2),
                      fontWeight: FontWeight.w400,
                      fontFamily: "Inter",
                      fontStyle: FontStyle.normal,
                      fontSize: 16.5),
                ),
              ),
            ),
          ],
        ),
        MyProgressGraphWidget(6),
      ],
    );
  }
}
