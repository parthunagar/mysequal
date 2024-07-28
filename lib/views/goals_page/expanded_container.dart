import 'package:flutter/material.dart';

class ExpandbleContainer extends StatefulWidget {
  final String question;
  final String answer;
  @override
  ExpandbleContainer({this.question, this.answer});

  @override
  _ExpandbleContainerState createState() => _ExpandbleContainerState();
}

class _ExpandbleContainerState extends State<ExpandbleContainer>
    with SingleTickerProviderStateMixin {
  bool shouldExpand = false;
  AnimationController controller;
  bool isPlaying = false;
  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  _onpressed() {
    setState(() {
      isPlaying = !isPlaying;

      isPlaying ? controller.forward() : controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        GestureDetector(
          onTap: () {
            _onpressed();
            setState(() {
              shouldExpand = !shouldExpand;
            });
          },
          child: Container(
            margin: EdgeInsetsDirectional.only(
              start: 16,
            ),
            padding: EdgeInsets.only(
              bottom: 12,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    widget.question,
                    style: TextStyle(
                      color: Color(0xff00183c),
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
                IconButton(
                  onPressed: null,
                  iconSize: 30,
                  icon: shouldExpand
                      ? Icon(Icons.arrow_drop_up)
                      : Icon(Icons.arrow_drop_down),
                )
              ],
            ),
          ),
        ),
        AnimatedContainer(
          duration: Duration(milliseconds: 200),
          height: shouldExpand ? 70 : 0,
          margin: EdgeInsetsDirectional.only(
            start: 16,
          ),
          padding: EdgeInsets.only(
            bottom: 12,
          ),
          child: Text(
            widget.answer,
            maxLines: 3,
            style: TextStyle(
              color: Color(0xff00183c),
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
          ),
        )
      ],
    );
  }
}
