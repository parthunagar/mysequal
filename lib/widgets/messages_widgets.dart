import 'package:flutter/material.dart';
import 'package:peloton/models/peloton_message.dart';

class AssesmentMessage extends StatelessWidget {
  final PelotonMessage message;

  @override
  AssesmentMessage({this.message});

  Color getColor() {
    switch (message.type) {
      case 'general':
        return Color(0x19000000);

      case 'communication':
        return Color(0xff3c84f2);
      case 'survey':
        return Color(0xff00cdc1);
      default:
        return Color(0x19000000);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      margin: EdgeInsets.fromLTRB(16, 14.5, 16, 0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            offset: Offset(0, 0),
            blurRadius: 1,
            spreadRadius: 0,
          ),
        ],
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Positioned(
            top: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                  color: getColor(),
                  borderRadius: BorderRadiusDirectional.only(
                    topStart: Radius.circular(8),
                    bottomStart: Radius.circular(8),
                  )),
              height: 95,
              width: 46.5,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(20, 0, 15, 0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26.5),
                    boxShadow: [
                      BoxShadow(
                        spreadRadius: 0.5,
                        color: Colors.grey.withOpacity(0.4),
                      ),
                    ],
                    color: Colors.white),
                width: 53,
                height: 53,
                child: Image.asset(
                  'assets/peloton_logo_small.png',
                  fit: BoxFit.contain,
                ),
              ),
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                
                  children: <Widget>[
                    Text(
                      message.title,
                      maxLines: 1,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        color: Colors.black,
                      ),
                    ),
                    Text(message.description,
                        overflow: TextOverflow.visible,
                        style: Theme.of(context).primaryTextTheme.subtitle2,
                        maxLines: 2),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26.5),
                  color: Color(0xff3c84f2),
                ),
                height: 30,
                width: 30,
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CommunicationMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class PositiveFeedback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
