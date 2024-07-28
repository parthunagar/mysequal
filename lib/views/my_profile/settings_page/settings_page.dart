import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/localization/app_notifier.dart';
import 'package:package_info/package_info.dart';
import 'package:peloton/managers/analytics_actions.dart';
import 'package:peloton/managers/analytics_manager.dart';

import 'package:peloton/managers/auth_provider.dart';
import 'package:peloton/views/my_profile/settings_page/countries_page.dart';
import 'package:provider/provider.dart';
import 'package:quickblox_sdk/quickblox_sdk.dart';

class SettingsPageWidget extends StatefulWidget {
  @override
  _SettingsPageWidgetState createState() => _SettingsPageWidgetState();
}

class _SettingsPageWidgetState extends State<SettingsPageWidget> {
  bool sharing;

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  void showCountriesList() {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) {
          return CountriesListwidget();
        },
      ),
    );
  }

  void showLanguages() {
    AnalyticsManager.instance.addEvent(AnalytictsActions.settingsLanguage, null);
    var appLanguage = Provider.of<AppLanguage>(context, listen: false);
    showModalBottomSheet(
        context: context,
        builder: (con) {
          return Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            )),
            height: 250,
            width: double.infinity,
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    IconButton(
                      onPressed: () {
                        Navigator.pop(con);
                      },
                      icon: Icon(Icons.close),
                      color: Colors.blue,
                    )
                  ],
                ),
                Divider(),
                GestureDetector(
                  onTap: () {
                    appLanguage.changeLanguage(Locale('en'));
                    Navigator.pop(con);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      AppLocalizations.of(con).translate('English'),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
                Divider(),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(con);
                    appLanguage.changeLanguage(Locale('he'));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      AppLocalizations.of(con).translate('Hebrew'),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
                Divider(),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(con);
                    appLanguage.changeLanguage(
                      Locale('ar'),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      AppLocalizations.of(con).translate('Arabic'),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Future<void> _showLogOutDialog(context) async {
    showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xffc02e2f),
              child:
                  // Image.asset(
                  //   'assets/bin.png',
                  //   color: Colors.white,
                  //   height: 50,
                  //   width: 50,
                  // ),
                  Icon(
                Icons.exit_to_app,
                size: 40,
              )),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  AppLocalizations.of(context).translate('LogOutAlert'),
                  style: const TextStyle(
                      color: const Color(0xff4a4a4a),
                      fontWeight: FontWeight.w400,
                      fontFamily: "Inter",
                      fontStyle: FontStyle.normal,
                      fontSize: 20.0),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                AppLocalizations.of(context).translate('No'),
                style: const TextStyle(
                    color: const Color(0xffc02e2f),
                    fontWeight: FontWeight.w500,
                    fontFamily: "Inter",
                    fontStyle: FontStyle.normal,
                    fontSize: 16.5),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                AppLocalizations.of(context).translate('Yes'),
                style: const TextStyle(
                    color: const Color(0xff3c84f2),
                    fontWeight: FontWeight.w500,
                    fontFamily: "Inter",
                    fontStyle: FontStyle.normal,
                    fontSize: 16.5),
              ),
              onPressed: () {
                AnalyticsManager.instance.addEvent(AnalytictsActions.signOut, null);
                FirebaseAuth.instance.signOut();
                QB.auth.logout();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  @override
  Widget build(BuildContext context) {
    sharing =
        AuthProvider.of(context).auth.currentUserDoc['journal_sharing'] ?? true;
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          )),
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              top: 20.0,
              bottom: 20,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).translate('JornalShare'),
                      style: const TextStyle(
                          color: const Color(0xff00183c),
                          fontWeight: FontWeight.w700,
                          fontFamily: "Inter",
                          fontStyle: FontStyle.normal,
                          fontSize: 20.0),
                    ),
                    Container(
                      constraints: BoxConstraints(maxWidth: 220),
                      child: Text(
                        AppLocalizations.of(context)
                            .translate('ShareJournalSubTitle'),
                        maxLines: 2,
                        style: const TextStyle(
                            color: const Color(0xff00183c),
                            fontWeight: FontWeight.w400,
                            fontFamily: "Inter",
                            fontStyle: FontStyle.normal,
                            fontSize: 14.0),
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: sharing ?? true,
                  onChanged: (value) {
                    AnalyticsManager.instance.addEvent(AnalytictsActions.journalSharing, {"value":value});
                    AuthProvider.of(context)
                        .auth
                        .updateUserDoc('journal_sharing', value);
                    setState(() {
                      sharing = value;
                    });
                  },
                  activeColor: Colors.blue,
                )
              ],
            ),
          ),
          Divider(
            indent: 12,
            endIndent: 12,
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 20.0,
              bottom: 20,
            ),
            child: GestureDetector(
              onTap: showLanguages,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    AppLocalizations.of(context).translate('Language'),
                    style: const TextStyle(
                        color: const Color(0xff00183c),
                        fontWeight: FontWeight.w700,
                        fontFamily: "Inter",
                        fontStyle: FontStyle.normal,
                        fontSize: 20.0),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 20),
                    child: Text(
                      AppLocalizations.of(context).locale.languageCode,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        color: const Color(0xff4a4a4a),
                        fontWeight: FontWeight.w400,
                        fontFamily: "Inter",
                        fontStyle: FontStyle.normal,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(
            indent: 12,
            endIndent: 12,
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 20.0,
              bottom: 20,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  AppLocalizations.of(context).translate('AboutThisVersion'),
                  style: const TextStyle(
                      color: const Color(0xff00183c),
                      fontWeight: FontWeight.w700,
                      fontFamily: "Inter",
                      fontStyle: FontStyle.normal,
                      fontSize: 19.0),
                ),
                Text(
                    '${_packageInfo.version} (Build ${_packageInfo.buildNumber})'),
                //         Text(_packageInfo.buildNumber),
                // IconButton(
                //   onPressed: () {
                //     showAboutDialog(
                //       context: context,
                //       children: <Widget>[
                //         Text(_packageInfo.version),
                //         Text(_packageInfo.buildNumber),
                //       ],
                //     );
                //   },
                //   icon: Icon(
                //     Icons.info_outline,
                //     color: Colors.grey,
                //   ),
                // ),
              ],
            ),
          ),
          Divider(
            indent: 12,
            endIndent: 12,
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 20.0,
              bottom: 20,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  AppLocalizations.of(context).translate('LogOut'),
                  style: const TextStyle(
                      color: const Color(0xff00183c),
                      fontWeight: FontWeight.w700,
                      fontFamily: "Inter",
                      fontStyle: FontStyle.normal,
                      fontSize: 19.0),
                ),
                IconButton(
                  onPressed: () {
                    _showLogOutDialog(context);
                  },
                  icon: Icon(
                    Icons.exit_to_app,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
