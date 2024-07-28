
import 'package:flutter/material.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/widgets/NSbasicWidget.dart';

class ChatHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NSBaseWidget(builder: (context, sizingInformation) {
      return SafeArea(
        
        child: Container(
          color:Color(0xfff4f5f9),
                  child: Container(
            height: sizingInformation.scaleByHeight(80),
            padding: EdgeInsets.only(
                left: 25, right: 25, bottom: sizingInformation.scaleByHeight(15)),
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.zero,
                topRight: Radius.zero,
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
              color: Color(0xff3c84f2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    AppLocalizations.of(context).translate("ChatHeader"),
                    style: Theme.of(context).primaryTextTheme.headline4,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
