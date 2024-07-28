import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'dart:ui' as ui;

import 'package:peloton/managers/auth_provider.dart';
import 'package:peloton/models/story.dart';
import 'package:peloton/views/log_book/log_book.dart';

class MoodDistributionWidget extends StatelessWidget {
  final dateLimit;

  @override
  MoodDistributionWidget(this.dateLimit);
  final List<String> titles = [
    'MoodGreat',
    'MoodGood',
    'MoodMeh',
    'MoodBad',
    'MoodAwful',
  ].reversed.toList();

  final List<Color> colorsList = [
    Color(0xff00cdc1),
    Color(0xff3c84f2),
    Color(0xffc02e2f),
    Color(0xffff9341),
    Color(0xff8d7fee),
  ].reversed.toList();

  List<Widget> getfacesList(context, moods) {
    List<Widget> result = [];
    for (var index = 0; index < 5; index++) {
      var item = Container(
        width: 60,
        child: FlatButton(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          highlightColor: Colors.transparent,
          padding: EdgeInsets.zero,
          onPressed: null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child: Image.asset('assets/bface${index + 1}.png',
                      color: colorsList[index]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                    AppLocalizations.of(context).translate(titles[index]),
                    maxLines: 1,
                    style: TextStyle(
                        color: colorsList[index],
                        fontWeight: FontWeight.w700,
                        fontFamily: "Inter",
                        fontStyle: FontStyle.normal,
                        fontSize: 14.5),
                    textAlign: TextAlign.center),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text('(${moods[index]})',
                    maxLines: 1,
                    style: TextStyle(
                        color: Colors.grey,//colorsList[index],
                        fontWeight: FontWeight.w700,
                        fontFamily: "Inter",
                        fontStyle: FontStyle.normal,
                        fontSize: 14.5),
                    textAlign: TextAlign.center),
              ),
            ],
          ),
        ),
      );
      result.add(item);
    }
    return result;
  }

  List<charts.Series<GaugeSegment, String>> _createChartData(moodsList) {
    final List<Color> colorsList = [
      Color(0xff00cdc1),
      Color(0xff3c84f2),
      Color(0xffc02e2f),
      Color(0xffff9341),
      Color(0xff8d7fee),
    ].reversed.toList();
    final data = [
      new GaugeSegment('Great', moodsList[0]),
      new GaugeSegment('Good', moodsList[1]),
      new GaugeSegment('Meh', moodsList[2]),
      new GaugeSegment('Bad', moodsList[3]),
      new GaugeSegment('Awful', moodsList[4]),
    ];

    return [
      new charts.Series<GaugeSegment, String>(
          id: 'Segments',
          domainFn: (GaugeSegment segment, _) => segment.segment,
          measureFn: (GaugeSegment segment, _) => segment.size,
          data: data,
          colorFn: (segment, index) {
            print(segment.segment);
            print(index);
            return charts.ColorUtil.fromDartColor(
                colorsList[index].withOpacity(0.5));
          })
    ];
  }

  @override
  Widget build(BuildContext context) {
    print(AuthProvider.of(context).auth.currentUserId);
    return StreamBuilder(
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
          var now = DateTime.now();
          var lastDate = new DateTime(now.year, now.month - dateLimit, now.day);

          var moodsList = [0, 0, 0, 0, 0];
          for (var story in snapshot.data.docs) {
            Story temp = Story.fromJson(story.data());
            if (temp.createAt.toDate().isAfter(lastDate))
              moodsList[temp.mood - 1] = moodsList[temp.mood - 1] + 1;
          }
          print(moodsList);
          return Container(
            width: double.infinity,
            padding: EdgeInsets.only(left: 12, right: 12),
            child: Stack(
              fit: StackFit.loose,
              alignment: Alignment.center,
              children: [
                Container(
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
                  height: 300,
                  child: GaugeChart(_createChartData(moodsList)),
                ),
                Positioned(
                  bottom: 30,
                  child: Wrap(
                    direction: Axis.horizontal,
                    spacing: 0,
                    //  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: getfacesList(context, moodsList),
                  ),
                ),
              ],
            ),
          );
        });
  }
}

class GaugeChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  GaugeChart(this.seriesList, {this.animate});

  /// Creates a [PieChart] with sample data and no transition.
  factory GaugeChart.withSampleData() {
    return new GaugeChart(
      _createSampleData(),
      // Disable animations for image tests.
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new charts.PieChart(
      seriesList,
      animate: animate,
      defaultRenderer: new charts.ArcRendererConfig(
        arcWidth: 30,
        startAngle: 5 / 5 * pi,
        arcLength: 5 / 5 * pi,
      ),
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<GaugeSegment, String>> _createSampleData() {
    final List<Color> colorsList = [
      Color(0xff00cdc1),
      Color(0xff3c84f2),
      Color(0xffc02e2f),
      Color(0xffff9341),
      Color(0xff8d7fee),
    ];
    final data = [
      new GaugeSegment('Low', 21),
      new GaugeSegment('Acceptable', 100),
      new GaugeSegment('High', 50),
      new GaugeSegment('Highly Unusual', 15),
      new GaugeSegment('super', 15),
    ];

    return [
      new charts.Series<GaugeSegment, String>(
          id: 'Segments',
          domainFn: (GaugeSegment segment, _) => segment.segment,
          measureFn: (GaugeSegment segment, _) => segment.size,
          data: data,
          colorFn: (segment, index) {
            print(segment.segment);
            print(index);
            return charts.ColorUtil.fromDartColor(
                colorsList[index].withOpacity(0.5));
          })
    ];
  }
}

/// Sample data type.
class GaugeSegment {
  final String segment;
  final int size;

  GaugeSegment(this.segment, this.size);
}
