import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:peloton/managers/auth_provider.dart';
import 'package:peloton/models/PelotonGoal.dart';
import 'package:peloton/models/PelotonUser.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';

class GoalProgress extends StatefulWidget {
  final PelotonGoal goal;
  @override
  GoalProgress({this.goal});

  @override
  _GoalProgressState createState() => _GoalProgressState();
}

class _GoalProgressState extends State<GoalProgress> {
  bool isImageloaded = false;
  ui.Image image;

  void initState() {
    super.initState();
    init();
  }

  Future<Null> init() async {
    var colorname = widget.goal.goalColor.toRadixString(16).substring(2);
    final ByteData data = await rootBundle.load('assets/$colorname.png');
    image = await loadImage(new Uint8List.view(data.buffer));
  }

  Future<ui.Image> loadImage(List<int> img) async {
    final Completer<ui.Image> completer = new Completer();
    ui.decodeImageFromList(img, (ui.Image img) {
      setState(() {
        isImageloaded = true;
      });
      return completer.complete(img);
    });
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    int comletedTasks = widget.goal.sharedInfo['completed_tasks'] ?? 0.0;
    int totalTasks = widget.goal.sharedInfo['total_tasks'] ?? 0.0;

    return Container(
      child: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          SliderTheme(
            data: SliderThemeData(
              disabledActiveTrackColor:
                  Color(widget.goal.goalColor).withOpacity(0.3),
              thumbColor: Theme.of(context).accentColor,
              thumbShape: isImageloaded
                  ? SliderThumbImage(image)
                  : RoundSliderThumbShape(enabledThumbRadius: 19.0),
              disabledThumbColor: Color(widget.goal.goalColor),
              activeTrackColor: Theme.of(context).accentColor.withOpacity(0.3),
              trackHeight: 20,
              tickMarkShape: SliderTickMarkShape.noTickMark,
            ),
            child: Slider(
              inactiveColor: Colors.grey.withOpacity(0.4),
              max: totalTasks.toDouble(),
              min: 0.0,
              value: comletedTasks != null ? comletedTasks.toDouble() : 0.0,
              label: comletedTasks != null ? comletedTasks.toString() : '0',
              onChanged: null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25.0, right: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.goal.title,
                    maxLines: 2,
                    style: TextStyle(
                      color: Color(widget.goal.goalColor),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  (totalTasks > 0)
                      ? '$comletedTasks/$totalTasks (${((comletedTasks / totalTasks) * 100).round()}%) '
                      : '  (0 %) ',
                  style: TextStyle(
                    color: Color(widget.goal.goalColor),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class GoalsProgressCollection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var myData =
        PelotonUser.fromJson(AuthProvider.of(context).auth.currentUserDoc);
    var orgIDs =
        AuthProvider.of(context).auth.currentUserDoc['organizationsID'] ?? [];

    List<GoalProgress> goalsList = [];
    return Container(
      margin: EdgeInsets.all(15),
      padding: EdgeInsets.all(8),
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
            .collection('goals')
            .where('patientid', isEqualTo: myData.id)
            //  .where('orginization', whereIn: orgIDs)
            .snapshots(),
        builder: (_, snap) {
          if (snap.data == null ||
              snap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          for (var doc in snap.data.docs) {
            var goal = PelotonGoal.fromJson(doc.data());
            GoalProgress goalprog = GoalProgress(
              goal: goal,
            );
            goalsList.add(goalprog);
          }
          return Column(
            children: goalsList,
          );
        },
      ),
    );
  }
}

class SliderThumbImage extends SliderComponentShape {
  final ui.Image image;

  SliderThumbImage(this.image);

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(30, 30);
  }

  @override
  void paint(PaintingContext context, Offset center,
      {Animation<double> activationAnimation,
      Animation<double> enableAnimation,
      bool isDiscrete,
      TextPainter labelPainter,
      RenderBox parentBox,
      Size sizeWithOverflow,
      SliderThemeData sliderTheme,
      TextDirection textDirection,
      double textScaleFactor,
      double value}) {
    final canvas = context.canvas;
    final imageWidth = image?.width ?? 10;
    final imageHeight = image?.height ?? 10;

    Offset imageOffset = Offset(
      center.dx - (imageWidth / 2),
      center.dy - (imageHeight / 2),
    );

    Paint paint = Paint()..filterQuality = FilterQuality.high;

    if (image != null) {
      canvas.drawImage(image, imageOffset, paint);
    }
  }
}
