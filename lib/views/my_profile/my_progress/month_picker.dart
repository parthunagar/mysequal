import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:intl/intl.dart' as intl;
import 'package:peloton/widgets/NSbasicWidget.dart';

class MonthSelectorWidget extends StatefulWidget {
  final void Function(Timestamp, Timestamp) reloadHome;
  @override
  MonthSelectorWidget({this.reloadHome});
  @override
  _MonthSelectorWidgetState createState() => _MonthSelectorWidgetState();

  // final Function() notifyParent;
  // WeekSelectorWidget({Key key, @required this.notifyParent}) : super(key: key);
}

class _MonthSelectorWidgetState extends State<MonthSelectorWidget> {
  String strtDate;
  String endDate;
  DateTime currentMonth;
  @override
  void initState() {
    getThisMonth();
    super.initState();
  }

  getThisMonth() {
    DateTime date = DateTime.now();
    var prevMonth = new DateTime(date.year, date.month - 1, date.day);

    var newFormat = intl.DateFormat("MMM");
    String prevMonthName = newFormat.format(prevMonth);
    String thisMonth = newFormat.format(date);

    setState(() {
      currentMonth = date; //startOfWeek.add(Duration(days: startOfWeek));
      this.strtDate = prevMonthName;
      this.endDate = thisMonth;
    });

  }

  getNextMonth() {
    print('next Month');
    DateTime date = DateTime(currentMonth.year, currentMonth.month + 1, currentMonth.day) ;
    var nextMonth = new DateTime(date.year, date.month + 1, date.day);

    var newFormat = intl.DateFormat("MMM");
    String nextMonthName = newFormat.format(nextMonth);
    String thisMonth = newFormat.format(date);

    setState(() {
      currentMonth = nextMonth; //startOfWeek.add(Duration(days: startOfWeek));
      this.strtDate = thisMonth;
      this.endDate = nextMonthName;
    });
    widget.reloadHome(
      Timestamp.fromMillisecondsSinceEpoch(date.millisecondsSinceEpoch),
      Timestamp.fromMillisecondsSinceEpoch(nextMonth.millisecondsSinceEpoch),
    );
  }

  getPrevMonth() {
    print('pre month');
    DateTime date = DateTime(currentMonth.year, currentMonth.month - 1, currentMonth.day)  ;
    var prevMonth = new DateTime(date.year, date.month - 1, date.day);

    var newFormat = intl.DateFormat("MMM");
    String prevMonthNameName = newFormat.format(prevMonth);
    String thisMonth = newFormat.format(date);

    setState(() {
      currentMonth = prevMonth; //startOfWeek.add(Duration(days: startOfWeek));
      this.strtDate = prevMonthNameName;
      this.endDate = thisMonth;
    });
    widget.reloadHome(
      Timestamp.fromMillisecondsSinceEpoch(prevMonth.millisecondsSinceEpoch),
      Timestamp.fromMillisecondsSinceEpoch(date.millisecondsSinceEpoch),
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
                      getPrevMonth();
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
                      getNextMonth();
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
