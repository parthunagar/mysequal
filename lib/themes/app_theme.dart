import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:ui';

ThemeData configureThemeData() {
  final _divisor = 414.0;
  var pixleRatio = window.devicePixelRatio;
  var _mediaQueryData = window.physicalSize;


  final _screenWidth = _mediaQueryData.width / pixleRatio;
  final _factorHorizontal = _screenWidth / _divisor;

  final _screenHeight = _mediaQueryData.height / pixleRatio;
  final _factorVertical = _screenHeight / _divisor;


  final _textScalingFactor = min(_factorVertical, _factorHorizontal);

  
  final _safeFactorHorizontal = _screenWidth  / _divisor;

  
  

  final _safeAreaTextScalingFactor =
      min(_safeFactorHorizontal, _textScalingFactor);

  return ThemeData(
    brightness: Brightness.light,
    appBarTheme: AppBarTheme(
      color: Color(0xff3c84f2),
      textTheme: TextTheme(
        headline1: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    backgroundColor: Color(0xFFd73e4d),
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'Inter',
    accentColor: Color(0xff3c84f2),
    primaryColor: Color(0xff003561),
//        for homepage and archive
    primaryTextTheme: TextTheme(
      headline1: TextStyle(
        fontSize: 31 * _safeAreaTextScalingFactor,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      subtitle1: TextStyle(
        fontSize: 15 * _safeAreaTextScalingFactor,
        height: 1.3,
        color: Colors.black,
      ),
      subtitle2: TextStyle(
        fontSize: 16.5 * _safeAreaTextScalingFactor,
        fontWeight: FontWeight.w600,
        height: 1.25,
        color: Color(0xff00183c),
      ),
      caption: TextStyle(
        fontSize: 13 * _safeAreaTextScalingFactor,
        fontWeight: FontWeight.w400,
        color: Color(0xff00183c),
      ),
      headline2: TextStyle(
        fontSize: 20 * _safeAreaTextScalingFactor,
        fontWeight: FontWeight.w500,
        height: 1.3,
        color: Colors.white,
      ),
      headline3: TextStyle(
        fontSize: 22 * _safeAreaTextScalingFactor,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        height: 1.3,
      ),
      headline4: TextStyle(
        fontSize: 16 * _safeAreaTextScalingFactor,
        fontWeight: FontWeight.w500,
        height: 1.0,
        color: Colors.white,
      ),
      headline5: TextStyle(
        fontSize: 40 * _safeAreaTextScalingFactor,
        fontWeight: FontWeight.w500,
        height: 1.25,
        color: Color(0xff00183c),
      ),
      headline6: TextStyle(
        fontSize: 16.5 * _safeAreaTextScalingFactor,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: Color(0xff3c84f2),
      ),
      button: TextStyle(
          fontSize: 20 * _safeAreaTextScalingFactor,
          height: 1.2,
          color: Colors.white,
          fontWeight: FontWeight.w700),
      bodyText1: TextStyle(
          fontSize: 20 * _safeAreaTextScalingFactor,
          height: 1.2,
          color: Color(0xff003561),
          fontWeight: FontWeight.w700),
      bodyText2: TextStyle(
          fontSize: 25 * _safeAreaTextScalingFactor,
          height: 1.2,
          color: Color(0xff003561),
          fontWeight: FontWeight.w700),
    ),
  );
}
