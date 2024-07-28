import 'package:flutter/material.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/widgets/NSbasicWidget.dart';
class MyProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NSBaseWidget(builder: (context, sizingInformation) {
      return Container(
        height: 35,
        padding: EdgeInsets.only(left: 25, right: 25, bottom: 0, top: 0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color(0xff3c84f2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
        
            // SizedBox(
            //   height: sizingInformation.scaleByHeight(10),
            // ),
            Text(
              AppLocalizations.of(context).translate("MyProfileSubtitle"),
              style: Theme.of(context).primaryTextTheme.headline4,
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: sizingInformation.scaleByHeight(10),
            ),
          ],
        ),
      );
    });
  }
}