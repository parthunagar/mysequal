import 'dart:ui';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart' as intl;

class AppLanguage extends ChangeNotifier {
  Locale _appLocale = Locale("en");

  Locale get appLocal => _appLocale ?? Locale("en");
  fetchLocale() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getString('language_code') == null) {
      print('local ' + Platform.localeName);
      String languageCode = Platform.localeName.split('_')[0];

      _appLocale = Locale(languageCode);
      //   _appLocale = Locale("en","IL");
      await prefs.setString('language_code', languageCode);
      notifyListeners();
      return;
    }
    _appLocale = Locale(prefs.getString('language_code'));
    notifyListeners();
    return;
  }

  void changeLanguage(Locale type) async {
    var prefs = await SharedPreferences.getInstance();
    if (_appLocale == type) {
      return;
    }
    intl.Intl.defaultLocale = type.languageCode;
    _appLocale = type;
    await prefs.setString('language_code', type.languageCode);
    //await prefs.setString('country_code', type.countryCode);
    notifyListeners();
  }
}
