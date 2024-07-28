import 'package:flutter/material.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/managers/auth_provider.dart';
import 'package:peloton/widgets/NSbasicWidget.dart';

class NoTasksWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NSBaseWidget(builder: (context, sizingInformation) {
      return Container(
        height: sizingInformation.scaleByWidth(350),
        child: Column(
          children: <Widget>[
            Text(
              AppLocalizations.of(context).translate(
                'NoTasks',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: const Color(0xff8b8b8b),
                  fontWeight: FontWeight.w500,
                  fontFamily: "Inter",
                  fontStyle: FontStyle.normal,
                  fontSize: 16.5),
            ),
            SizedBox(height: 8,),
            Image.asset(
              AuthProvider.of(context)
                          .auth
                          .currentUserDoc['gender']
                          .toString()
                          .toLowerCase() ==
                      'male'
                  ? 'assets/noTasks.png'
                  : 'assets/no_task_female.png',
              fit: BoxFit.contain,
              height: sizingInformation.scaleByWidth(250),
            ),
          ],
        ),
      );
    });
  }
}
