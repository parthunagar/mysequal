import 'package:flutter/material.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/models/PelotonGoal.dart';
import 'package:peloton/widgets/NSbasicWidget.dart';

class SecondwelcomeScreen extends StatelessWidget {
  final Function() showNext;
  @override
  SecondwelcomeScreen({this.showNext});
  @override
  Widget build(BuildContext context) {
    return NSBaseWidget(builder: (context, sizingInformation) {
      return Container(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppLocalizations.of(context).translate('Great'),
                  style: TextStyle(
                      color: HexColor('003561'),
                      fontWeight: FontWeight.w400,
                      fontFamily: "Inter",
                      fontStyle: FontStyle.italic,
                      fontSize: sizingInformation.scaleByWidth(20)),
                ),
                SizedBox(
                  height: sizingInformation.scaleByHeight(40),
                ),
                Text(
                  AppLocalizations.of(context).translate('WelcomePage2Title'),
                  style: TextStyle(
                      color: HexColor('003561'),
                      fontWeight: FontWeight.w700,
                      fontFamily: "Inter",
                      fontStyle: FontStyle.normal,
                      fontSize: sizingInformation.scaleByWidth(20)),
                ),
                SizedBox(
                  height: sizingInformation.scaleByHeight(20),
                ),
                Container(
                  margin: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0x1a000000),
                          offset: Offset(0, 0),
                          blurRadius: 42,
                          spreadRadius: 0)
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding:
                            EdgeInsets.all(sizingInformation.scaleByWidth(15)),
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(
                                  sizingInformation.scaleByWidth(8)),
                              child: Image.asset(
                                'assets/goal_icon.png',
                                width: 35,
                                height: 42,
                              ),
                            ),
                            SizedBox(
                              width: sizingInformation.scaleByWidth(12),
                            ),
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context)
                                    .translate('WelcomeScreenPoint1'),
                                style: TextStyle(
                                    color: const Color(0xff3c84f2),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "Inter",
                                    fontStyle: FontStyle.normal,
                                    fontSize:
                                        sizingInformation.scaleByWidth(16.5)),
                              ),
                            )
                          ],
                        ),
                      ),
                      Divider(),
                      Padding(
                        padding:
                            EdgeInsets.all(sizingInformation.scaleByWidth(15)),
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(
                                  sizingInformation.scaleByWidth(8)),
                              child: Image.asset(
                                'assets/croud2.png',
                                width: 35,
                                height: 35,
                              ),
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context)
                                    .translate('WelcomeScreenPoint2'),
                                style: TextStyle(
                                    color: const Color(0xff3c84f2),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "Inter",
                                    fontStyle: FontStyle.normal,
                                    fontSize:
                                        sizingInformation.scaleByWidth(16.5)),
                              ),
                            )
                          ],
                        ),
                      ),
                      Divider(),
                      Padding(
                        padding:
                            EdgeInsets.all(sizingInformation.scaleByWidth(15)),
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(
                                  sizingInformation.scaleByWidth(8)),
                              child: Image.asset(
                                'assets/hand_raised.png',
                                width: 35,
                                height: 32,
                              ),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context)
                                    .translate('WelcomeScreenPoint3'),
                                style: const TextStyle(
                                  color: const Color(0xff3c84f2),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "Inter",
                                  fontStyle: FontStyle.normal,
                                  fontSize: 16.5,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            Positioned(
              bottom: sizingInformation.scaleByHeight(30),
              child: GestureDetector(
                onTap: showNext,
                child: Container(
                  padding: EdgeInsets.all(
                    sizingInformation.scaleByHeight(12),
                  ),
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(34)),
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0x29000000),
                          offset: Offset(0, 2),
                          blurRadius: 8,
                          spreadRadius: 0)
                    ],
                    color: const Color(0xff3c84f2),
                  ),
                  child: Center(
                    child: Padding(
                      padding:
                          const EdgeInsetsDirectional.only(start: 8.0, end: 8),
                      child: Text(
                        AppLocalizations.of(context)
                            .translate('WelcomeScreenButton2'),
                        style: TextStyle(
                            color: const Color(0xffffffff),
                            fontWeight: FontWeight.w700,
                            fontFamily: "Inter",
                            fontStyle: FontStyle.normal,
                            fontSize: sizingInformation.scaleByWidth(20)),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      );
    });
  }
}
