import 'package:flutter/material.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/widgets/NSbasicWidget.dart';

class LogBookHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NSBaseWidget(builder: (context, sizingInformation) {
      return SafeArea(
        child: Container(
          height: sizingInformation.scaleByHeight(80),
          padding: EdgeInsetsDirectional.only(start: 25, bottom: 15),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.zero,
              topRight: Radius.zero,
              bottomLeft: Radius.circular(35),
              bottomRight: Radius.circular(35),
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
                  AppLocalizations.of(context)
                                        .translate('LogbookHeaderSubtitle'),
                  style: Theme.of(context).primaryTextTheme.headline4,
                  textAlign: TextAlign.start,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
