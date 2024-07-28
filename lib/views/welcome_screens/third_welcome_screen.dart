import 'package:flutter/material.dart';
import 'package:peloton/models/PelotonGoal.dart';
import 'package:peloton/widgets/NSbasicWidget.dart';
import 'package:location/location.dart';
import 'package:peloton/localization/app_localization.dart';


import 'package:flutter/services.dart';

class ThirdWelcomeScreen extends StatelessWidget {
  static const authenticateChannel =
      const MethodChannel('com.neura.flutterApp/authenticate');
  
  
  final void Function() showNext;
  @override
  ThirdWelcomeScreen({this.showNext});
  
  showPermissions(context) async {
    
    await getLocation();
    await authenticateToNeura();
    showNext();
  }

  Future authenticateToNeura() async {
    String response = "";
    try {
      final String result =
          await authenticateChannel.invokeMethod('authenticate').then((result) {
        response = result;
      });
    } on PlatformException catch (e) {
      response = e.code;
    } finally {
      print(response);
    }
    
  }

  getLocation() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();

    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return NSBaseWidget(builder: (context, sizingInformation) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            margin: EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    AppLocalizations.of(context).translate('Page3Title'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: HexColor('003561'),
                        fontWeight: FontWeight.w400,
                        fontFamily: "Inter",
                        fontStyle: FontStyle.italic,
                        fontSize: sizingInformation.scaleByWidth(20)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    AppLocalizations.of(context).translate('Page3SubTitle'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: HexColor('003561'),
                        fontWeight: FontWeight.w400,
                        fontFamily: "Inter",
                        fontStyle: FontStyle.normal,
                        fontSize: sizingInformation.scaleByWidth(20)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    AppLocalizations.of(context).translate('MobileCan'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: HexColor('003561'),
                        fontWeight: FontWeight.w700,
                        fontFamily: "Inter",
                        fontStyle: FontStyle.normal,
                        fontSize: sizingInformation.scaleByWidth(20)),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(sizingInformation.scaleByWidth(20)),
                  padding: EdgeInsets.all(sizingInformation.scaleByWidth(12)),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0x1a000000),
                          offset: Offset(0, 0),
                          blurRadius: 1,
                          spreadRadius: 0)
                    ],
                    color: const Color(0xffffffff),
                  ),
                  height: sizingInformation.scaleByHeight(135),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image.asset(
                            'assets/freq.png',
                            width: sizingInformation.scaleByHeight(50),
                            height: sizingInformation.scaleByHeight(30),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                            AppLocalizations.of(context).translate('Frequency'),
                            style: TextStyle(
                                color: const Color(0xff3c84f2),
                                fontWeight: FontWeight.w700,
                                fontFamily: "Inter",
                                fontStyle: FontStyle.normal,
                                fontSize: sizingInformation.scaleByWidth(18)),
                          )
                        ],
                      ),
                      VerticalDivider(
                        thickness: 0.5,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image.asset(
                            'assets/duration.png',
                            width: 50,
                            height: 30,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                            AppLocalizations.of(context).translate('Duration'),
                            style: TextStyle(
                                color: const Color(0xff3c84f2),
                                fontWeight: FontWeight.w700,
                                fontFamily: "Inter",
                                fontStyle: FontStyle.normal,
                                fontSize: sizingInformation.scaleByWidth(18)),
                          )
                        ],
                      ),
                      VerticalDivider(
                        thickness: 0.5,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image.asset(
                            'assets/ampli.png',
                            width: 50,
                            height: 30,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                            AppLocalizations.of(context).translate('Amplitude'),
                            style: TextStyle(
                                color: const Color(0xff3c84f2),
                                fontWeight: FontWeight.w700,
                                fontFamily: "Inter",
                                fontStyle: FontStyle.normal,
                                fontSize: sizingInformation.scaleByWidth(18)),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                Text(
                  AppLocalizations.of(context).translate('Page3SubTitle2'),
                  style: TextStyle(
                      color: HexColor('003561'),
                      fontWeight: FontWeight.w400,
                      fontFamily: "Inter",
                      fontStyle: FontStyle.normal,
                      fontSize: sizingInformation.scaleByWidth(20)),
                ),
                SizedBox(
                  height: sizingInformation.scaleByHeight(20),
                ),
                Text(
                  AppLocalizations.of(context).translate('Page3SubTitle3'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: HexColor('003561'),
                      fontWeight: FontWeight.w400,
                      fontFamily: "Inter",
                      fontStyle: FontStyle.normal,
                      fontSize: sizingInformation.scaleByWidth(20)),
                )
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            child: Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    showPermissions(context);
                  },
                  child: Container(
                    padding: EdgeInsets.all(sizingInformation.scaleByWidth(12)),
                    height: sizingInformation.scaleByWidth(54),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(34)),
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0x29000000),
                            offset: Offset(0, 2),
                            blurRadius: 1,
                            spreadRadius: 0)
                      ],
                      color: const Color(0xff3c84f2),
                    ),
                    child: Center(
                      child: Padding(
                        padding:
                            const EdgeInsetsDirectional.only(start: 8, end: 8),
                        child: Text(
                          AppLocalizations.of(context)
                              .translate('Page3SubTitle4'),
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
                FlatButton(
                  onPressed: showNext,
                  child: Text(
                    AppLocalizations.of(context).translate('MaybeLater'),
                    style: TextStyle(
                        color: const Color(0xff3c84f2),
                        fontWeight: FontWeight.w700,
                        fontFamily: "Inter",
                        fontStyle: FontStyle.normal,
                        fontSize: sizingInformation.scaleByWidth(20)),
                  ),
                )
              ],
            ),
          )
        ],
      );
    });
  }
}
