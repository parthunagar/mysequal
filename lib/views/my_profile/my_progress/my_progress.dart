import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/widgets/bottom_radio_picker.dart';
import 'goal_progress.dart';
import 'mood_distribution.dart';
import 'my_progress_graph.dart';
import 'task_progress.dart';

class MyProgressWidget extends StatefulWidget {
  @override
  _MyProgressWidgetState createState() => _MyProgressWidgetState();
}

class _MyProgressWidgetState extends State<MyProgressWidget> {
  Timestamp startDate;
  Timestamp endDate;
  var monthsCount = 2;
  

  void showMonthsList(value) async {
    var months1 = AppLocalizations.of(context).translate("2months");
    var months2 = AppLocalizations.of(context).translate("3months");
    var months3 = AppLocalizations.of(context).translate("4months");
    var months4 = AppLocalizations.of(context).translate("5months");
    var months5 = AppLocalizations.of(context).translate("6months");
    var monthslist = [months1, months2, months3, months4, months5];

    var result = await Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) {
          return BottomRadioListWidget(
            data: monthslist,
            title: AppLocalizations.of(context)
                .translate("ProgressSelectMonthTitle"),
            defaultValue: value,
          );
        },
      ),
    );
    var count = monthslist.indexOf(result) + 2;
    setState(() {
      monthsCount = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)
                .translate("MyProgress"),
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        color: const Color(0xfff4f5f9),
        child: ListView(
          children: [
            SizedBox(
              height: 18,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15),
              child: Text(
                AppLocalizations.of(context).translate("MyProgressGoalsTitle"),
                style: TextStyle(
                    color: Color(0xff003561),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 18),
              ),
            ),
            GoalsProgressCollection(),
            ProgressTasksWidget(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15, bottom: 12, top: 20),
                  child: Text(
                    AppLocalizations.of(context).translate("MoodsDistribution"),
                    style: TextStyle(
                        color: Color(0xff003561),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 18),
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    showMonthsList(monthsCount.toString());
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(AppLocalizations.of(context).translate("Last") +  ' $monthsCount ' + AppLocalizations.of(context).translate("Months") + ' ',),
                      Icon(Icons.filter_list)
                    ],
                  ),
                )
              ],
            ),
            MoodDistributionWidget(monthsCount),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15, bottom: 0, top: 20),
              child: Text(
                AppLocalizations.of(context).translate("ProgresschartTitle"),
                style: TextStyle(
                    color: Color(0xff003561),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 18),
              ),
            ),
            
            MyProgressGraphWidget(monthsCount-1)
          ],
        ),
      ),
    );
  }
}
