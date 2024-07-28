import 'package:flutter/material.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/models/PelotonGoal.dart';
class GridStrings extends StatelessWidget {
  final PelotonGoal goal;
  @override
  GridStrings({this.goal});
  @override
  Widget build(BuildContext context) {
    var textStyle = TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontFamily: "Inter",
        fontStyle: FontStyle.normal,
        fontSize: 13.0);
    List<Widget> tiles = [];
    goal.recoverProgram.forEach(
      (value) {
        var item = Container(
          height: 27,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(5.5),
            ),
            color: Color(goal.goalColor),
          ),
          padding: EdgeInsets.fromLTRB(9, 5, 9, 5),
          child: Text(
            value.name,
            style: textStyle,
          ),
        );
        tiles.add(item);
      },
    );
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(12),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        boxShadow: [
          BoxShadow(
              color: const Color(0x1a000000),
              offset: Offset(0, 0),
              blurRadius: 42,
              spreadRadius: 0)
        ],
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            AppLocalizations.of(context).translate(
                  'TrackDaily',
                ),
            style: const TextStyle(
              color: const Color(0xff00183c),
              fontWeight: FontWeight.w700,
              fontFamily: "Inter",
              fontStyle: FontStyle.normal,
              fontSize: 16.0,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            direction: Axis.horizontal,
            children: tiles,
          ),
        ],
      ),
    );
  }
}
