import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/managers/auth_provider.dart';
import 'package:peloton/models/story.dart';
import 'package:intl/intl.dart' as intl;

class MyProgressGraphWidget extends StatelessWidget {
  final int count;
  @override
  MyProgressGraphWidget(this.count);
  @override
  Widget build(BuildContext context) {
    print(AuthProvider.of(context).auth.currentUserId);
    return Container(
      height: 250,
      width: double.infinity,
      margin: EdgeInsets.only(left: 12, right: 12, top: 12),
      padding: EdgeInsets.only(left: 12, right: 12),
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
      child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('journal')
              .where('patient_id',
                  isEqualTo: AuthProvider.of(context).auth.currentUserId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return Container();
            }
            if (snapshot.data.docs == null) {
              return Container();
            }
            List<Story> storiesList = [];
            for (var story in snapshot.data.docs) {
              Story temp = Story.fromJson(story.data());
              storiesList.add(temp);
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15.0, bottom: 5),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                          child: Image.asset('assets/cface1.png'),
                          width: 40,
                          height: 35,
                        ),
                        Container(
                          child: Image.asset('assets/cface2.png'),
                          width: 40,
                          height: 35,
                        ),
                        Container(
                          child: Image.asset('assets/cface3.png'),
                          width: 40,
                          height: 35,
                        ),
                        Container(
                          child: Image.asset('assets/cface4.png'),
                          width: 40,
                          height: 35,
                        ),
                        Container(
                          child: Image.asset('assets/cface5.png'),
                          width: 40,
                          height: 35,
                        ),
                      ],
                    ),
                  ),
                ),
              storiesList.length > 0 ?  LineChartWidget(storiesList, count) : Container(),
              ],
            );
          }),
    );
  }
}

class LineChartWidget extends StatefulWidget {
  final List<Story> stories;
  final int type;
  @override
  LineChartWidget(this.stories, this.type);

  @override
  State<StatefulWidget> createState() => LineChartWidgetState();
}

class LineChartWidgetState extends State<LineChartWidget> {
  bool isShowingMainData;

  @override
  void initState() {
    super.initState();
    isShowingMainData = true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 5, right: 5),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(18)),
      ),
      child: LineChart(
        getGraphData(),
      ),
    );
  }

  String getTitle(int index) {
    var delta = widget.type - index;
    var newFormat = intl.DateFormat("MMM");
    var now = DateTime.now();
    var startDate = new DateTime(now.year, now.month - delta, now.day);
    String startDateVal = newFormat.format(startDate);
    return (startDateVal);
  }

  LineChartData getGraphData() {
    return LineChartData(
      lineTouchData: LineTouchData(
        enabled: true,
      ),
      gridData: FlGridData(
        show: false,
      ),
      titlesData: FlTitlesData(
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          textStyle: const TextStyle(
            color: Color(0xff72719b),
            fontWeight: FontWeight.normal,
            fontSize: 11,
          ),
          margin: 10,
          getTitles: (value) {
            return getTitle(value.toInt());
          },
        ),
        leftTitles: SideTitles(
          showTitles: false,
        ),
      ),
      borderData: FlBorderData(
        show: false,
        border: const Border(
          bottom: BorderSide(
            color: Color(0xff4e4965),
            width: 4,
          ),
          left: BorderSide(
            color: Colors.transparent,
          ),
          right: BorderSide(
            color: Colors.transparent,
          ),
          top: BorderSide(
            color: Colors.transparent,
          ),
        ),
      ),
      minX: 0,
      maxX: widget.type.toDouble(),
      maxY: 6,
      minY: 1,
      lineBarsData: linesBarData2(),
    );
  }

  List<LineChartBarData> linesBarData2() {
    List<FlSpot> dataList = [];

    for (var index = 0; index <= widget.type; index++) {
      var score = getScore(index);

      if (score != null) {
        print(score.x);
        print(score.y);
        dataList.add(score);
      }
    }

    return [
      LineChartBarData(
        colorStops: [3.9],
        spots: dataList,
        isCurved: true,
        curveSmoothness: 0,
        colors: const [
          Color(0xffaaccff),
        ],
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(show: true),
        belowBarData: BarAreaData(
          show: false,
        ),
      ),
    ];
  }

  FlSpot getScore(index) {
    var delta = widget.type - index;
    var score = 0;
    var count = 0;
    var now = DateTime.now();
    var newDate = new DateTime(now.year, now.month - delta, now.day);
    for (var story in widget.stories) {
      if (story.createAt == null) {
        return null;
      }
      if (story.createAt.toDate().month == newDate.month) {
        score = score + story.mood;
        count++;
      }
    }
    if (score == 0) {
      return null; //FlSpot(index.toDouble(),1);
    }
    var val = (score / count).toDouble();
    val = num.parse(val.toStringAsFixed(1));
    return FlSpot(index.toDouble(),val );
  }
}
