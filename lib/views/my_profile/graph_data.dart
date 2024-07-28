import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:peloton/localization/app_localization.dart';

class ProfileGraphWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 5,
            runSpacing: 5,
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                AppLocalizations.of(context).translate("SeeProgress"),
                style: const TextStyle(
                    color: const Color(0xff00183c),
                    fontWeight: FontWeight.w700,
                    fontFamily: "Inter",
                    fontStyle: FontStyle.normal,
                    fontSize: 20.0),
              ),
              Text(
                AppLocalizations.of(context).translate("ShowMore"),
                style: const TextStyle(
                    color: const Color(0xff3c84f2),
                    fontWeight: FontWeight.w400,
                    fontFamily: "Inter",
                    fontStyle: FontStyle.normal,
                    fontSize: 16.5),
              ),
            ],
          ),
          Container(
            height: 250,
            width: double.infinity,
            margin: EdgeInsets.only(top: 15),
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    color: const Color(0x29000000),
                    offset: Offset(0, 0),
                    blurRadius: 21,
                    spreadRadius: 0)
              ],
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15.0, bottom: 5),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                LineChartSample1(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LineChartSample1 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LineChartSample1State();
}

class LineChartSample1State extends State<LineChartSample1> {
  bool isShowingMainData;

  @override
  void initState() {
    super.initState();
    isShowingMainData = true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(18)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: LineChart(
          sampleData2(),
        ),
      ),
    );
  }

  LineChartData sampleData2() {
    return LineChartData(
      lineTouchData: LineTouchData(
        enabled: true,
      ),
      gridData: FlGridData(
        show: false,
      ),
      titlesData: FlTitlesData(
        bottomTitles: SideTitles(
          showTitles: false,
          reservedSize: 22,
          textStyle: const TextStyle(
            color: Color(0xff72719b),
            fontWeight: FontWeight.normal,
            fontSize: 11,
          ),
          margin: 10,
          getTitles: (value) {
            switch (value.toInt()) {
              case 1:
                return 'Jan';
              case 2:
                return 'Feb';
              case 3:
                return 'Mar';
              case 4:
                return 'apr';
              case 5:
                return 'May';
              case 6:
                return 'Jun';

              case 7:
                return 'Jul';
              case 8:
                return 'Aug';
              case 9:
                return 'Sep';
              case 10:
                return 'Oct';
              case 11:
                return 'Nov';
              case 12:
                return 'Sep';
            }
            return '';
          },
        ),
        leftTitles: SideTitles(
          showTitles: false,
          textStyle: const TextStyle(
            color: Color(0xff75729e),
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
          getTitles: (value) {
            switch (value.toInt()) {
              case 1:
                return '1m';
              case 2:
                return '2m';
              case 3:
                return '3m';
              case 4:
                return '5m';
              case 5:
                return '6m';
            }
            return '';
          },
          margin: 8,
          reservedSize: 30,
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
          )),
      minX: 0,
      maxX: 14,
      maxY: 6,
      minY: 0,
      lineBarsData: linesBarData2(),
    );
  }

  List<LineChartBarData> linesBarData2() {
    return [
      LineChartBarData(
        colorStops: [3.9],
        spots: [
          FlSpot(1, 3.8),
          FlSpot(3, 1),
          FlSpot(6, 5),
          FlSpot(10, 3.3),
          FlSpot(12, 4.5),
        ],
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
}
