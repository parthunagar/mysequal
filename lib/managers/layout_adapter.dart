import 'package:flutter/widgets.dart';
class SizingInformation {
  final Orientation orientation;
  final Size screenSize;
  final Size localWidgetSize;
  final double initialWidth;
  final double initialHeight;

  SizingInformation({
    this.orientation,
    this.screenSize,
    this.localWidgetSize,
    this.initialWidth,
    this.initialHeight,
  });

  double scaleByWidth(double size) {
    double _widthFactor =   this.screenSize.width / this.initialWidth;
    return (size * _widthFactor);
  }

  double scaleByHeight(double size) {
    double _heightFactor =   this.screenSize.height / this.initialHeight;
    return (size * _heightFactor);
  }
  
  
  @override
  String toString() {
    return 'Orientation:$orientation ScreenSize:$screenSize LocalWidgetSize:$localWidgetSize';
  }
} 