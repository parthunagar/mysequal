import 'package:flutter/material.dart';
import 'dart:ui';

ThemeData storyThemeData() {
  final _divisor = 414.0;
  var pixleRatio = window.devicePixelRatio;
  var _mediaQueryData = window.physicalSize;
  final _screenWidth = _mediaQueryData.width / pixleRatio;
  final _factorHorizontal = _screenWidth / _divisor;

  return ThemeData(
    brightness: Brightness.light,
    backgroundColor: Color(0xFFd73e4d),
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'Inter',
    accentColor: Color(0xff3c84f2),
    primaryColor: Color(0xff003561),
    primaryTextTheme: TextTheme(
      headline1: TextStyle(
        fontSize: 20 * _factorHorizontal,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w700,
        color: Colors.red,
      ),
      subtitle1: TextStyle(
        fontSize: 15 * _factorHorizontal,
        height: 1.3,
        color: Colors.blue,
      ),
      subtitle2: TextStyle(
        fontSize: 14 * _factorHorizontal,
        fontWeight: FontWeight.w500,
        height: 1.25,
        color: Color(0xff00183c),
      ),
      caption: TextStyle(
        fontSize: 13 * _factorHorizontal,
        color: Colors.black87,
      ),
      headline2: TextStyle(
        fontSize: 20 * _factorHorizontal,
        fontWeight: FontWeight.w500,
        height: 1.3,
        color: Colors.white,
      ),
      headline3: TextStyle(
        fontSize: 26 * _factorHorizontal,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        height: 1.3,
      ),
      headline4: TextStyle(
        fontSize: 16 * _factorHorizontal,
        fontWeight: FontWeight.w500,
        height: 1.25,
        color: Colors.white,
      ),
      headline5: TextStyle(
        fontSize: 40 * _factorHorizontal,
        fontWeight: FontWeight.w500,
        height: 1.25,
        color: Color(0xff00183c),
      ),
      headline6: TextStyle(
            fontSize: 14 * _factorHorizontal,
        fontWeight: FontWeight.w500,
        height: 1.25,
        color: Color(0xff3c84f2),
      ),
      button: TextStyle(
          fontSize: 20 * _factorHorizontal,
          height: 1.2,
          color: Colors.white,
          fontWeight: FontWeight.w700),
      bodyText1: TextStyle(
          fontSize: 20 * _factorHorizontal,
          height: 1.2,
          color: Color(0xff003561),
          fontWeight: FontWeight.w700),
      bodyText2: TextStyle(
        fontSize: 25 * _factorHorizontal,
        height: 1.2,
        color: Color(0xff003561),
        fontWeight: FontWeight.w700,
      ),
      
    ),
  );
}
