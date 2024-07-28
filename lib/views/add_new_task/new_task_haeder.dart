import 'package:flutter/material.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/widgets/NSbasicWidget.dart';

class CreateTaskHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NSBaseWidget(builder: (context, sizingInformation) {
      return Container(
        //height: 90,
        padding: EdgeInsets.only(left: 25, right: 25, bottom: 20, top: 0),
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(AppLocalizations.of(context)
                                        .translate('CreateTask'),
               style: Theme.of(context).primaryTextTheme.headline3,
                textAlign: TextAlign.start)
          ],
        ),
      );
    });
  }
}
