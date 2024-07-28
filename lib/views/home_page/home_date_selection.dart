import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:intl/intl.dart' as intl;
import 'package:peloton/widgets/NSbasicWidget.dart';

class WeekSelectorWidget extends StatefulWidget {
  final void Function(Timestamp, Timestamp) reloadHome;
  @override
  WeekSelectorWidget({this.reloadHome});
  @override
  _WeekSelectorWidgetState createState() => _WeekSelectorWidgetState();

  // final Function() notifyParent;
  // WeekSelectorWidget({Key key, @required this.notifyParent}) : super(key: key);
}

class _WeekSelectorWidgetState extends State<WeekSelectorWidget> {
  String strtDate;
  String endDate;
  DateTime currentWeekstartDate;
  @override
  void initState() {
    getThisWeek();
    super.initState();
  }

  getThisWeek() {
    DateTime date = DateTime.now();
    int today = DateTime.now().weekday + 1;
    var weekDelta = today % 7;
    var endOfweek = date.add(Duration(days: 7 - weekDelta));
    var startOfWeek = date.subtract(Duration(days: weekDelta - 1));
    var newFormat = intl.DateFormat("dd MMM");
    String endOfweekFormated = newFormat.format(endOfweek);
    String startOfWeekFormated = newFormat.format(startOfWeek);

    setState(() {
      currentWeekstartDate =
          startOfWeek; //startOfWeek.add(Duration(days: startOfWeek));
      this.strtDate = startOfWeekFormated;
      this.endDate = endOfweekFormated;
    });
  }

  getNextWeek() {
    print('next week');
    DateTime date = currentWeekstartDate.add(Duration(days: 7));
    var endOfweek = date.add(Duration(days: 6));
    var startOfWeek = date;
    var newFormat = intl.DateFormat("dd MMM");
    String endOfweekFormated = newFormat.format(endOfweek);
    String startOfWeekFormated = newFormat.format(startOfWeek);
    setState(() {
      currentWeekstartDate =
          date; //startOfWeek.add(Duration(days: startOfWeek));
      this.strtDate = startOfWeekFormated;
      this.endDate = endOfweekFormated;
    });
    widget.reloadHome(
      Timestamp.fromMillisecondsSinceEpoch(startOfWeek.millisecondsSinceEpoch),
      Timestamp.fromMillisecondsSinceEpoch(endOfweek.millisecondsSinceEpoch),
    );
  }

  getPrevWeek() {
    print('pre week');
    DateTime date = currentWeekstartDate.subtract(Duration(days: 7));
    var endOfweek = date.add(Duration(days: 6));
    var startOfWeek = date;
    var newFormat = intl.DateFormat("dd MMM");
    String endOfweekFormated = newFormat.format(endOfweek);
    String startOfWeekFormated = newFormat.format(startOfWeek);
    setState(() {
      currentWeekstartDate =
          date; //startOfWeek.add(Duration(days: startOfWeek));
      this.strtDate = startOfWeekFormated;
      this.endDate = endOfweekFormated;
    });
    widget.reloadHome(
      Timestamp.fromMillisecondsSinceEpoch(startOfWeek.millisecondsSinceEpoch),
      Timestamp.fromMillisecondsSinceEpoch(endOfweek.millisecondsSinceEpoch),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NSBaseWidget(builder: (context, sizingInformation) {
      return Container(
        margin: EdgeInsets.fromLTRB(10, 0, 10, 20),
        height: sizingInformation.scaleByWidth(44),
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(21.5),
            border: Border.all(
              style: BorderStyle.solid,
              width: 1.5,
              color: Theme.of(context).accentColor,
            )),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Container(
                decoration: BoxDecoration(),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: FlatButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Future.delayed(Duration(milliseconds: 400), () {
                      getPrevWeek();
                    });
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Image.asset(
                        'assets/backarrow.png',
                        matchTextDirection: true,
                        width: 5,
                        height: 22,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        AppLocalizations.of(context).translate('Back'),
                        style: TextStyle(
                          color: const Color(0xff111c2d),
                          fontWeight: FontWeight.w500,
                          fontFamily: "Inter",
                          fontStyle: FontStyle.normal,
                          fontSize: sizingInformation.scaleByWidth(15),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: Color(0xffd1d1d1),
            ),
            FlatButton(
              padding: EdgeInsets.zero,
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    '$strtDate - $endDate',
                    style: TextStyle(
                        color: const Color(0xff111c2d),
                        fontWeight: FontWeight.w700,
                        fontFamily: "Inter",
                        fontStyle: FontStyle.normal,
                        fontSize: sizingInformation.scaleByWidth(15)),
                  )
                ],
              ),
              onPressed: () {},
            ),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: Color(0xffd1d1d1),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Container(
                child: FlatButton(
                  padding: EdgeInsets.zero,
                  child: Container(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          AppLocalizations.of(context).translate('Next'),
                          style: TextStyle(
                              color: const Color(0xff111c2d),
                              fontWeight: FontWeight.w400,
                              fontFamily: "Inter",
                              fontStyle: FontStyle.normal,
                              fontSize: sizingInformation.scaleByWidth(15)),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Image.asset(
                          'assets/forwardarrow.png',
                          matchTextDirection: true,
                          width: 5,
                          height: 22,
                        ),
                      ],
                    ),
                  ),
                  onPressed: () {
                    Future.delayed(Duration(milliseconds: 400), () {
                      getNextWeek();
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
