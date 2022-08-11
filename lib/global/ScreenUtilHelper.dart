import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void initScreenUtil(BuildContext context) {
  double defaultScreenWidth = 400.0;
  double defaultScreenHeight = 810.0;
  ScreenUtil.instance = ScreenUtil(
    width: defaultScreenWidth,
    height: defaultScreenHeight,
    allowFontScaling: true,
  )..init(context);
}

//===== responsive width funcs
double respWidth(double width) {
  return ScreenUtil.instance.setWidth(width);
}

double respHeight(double height) {
  return ScreenUtil.instance.setHeight(height);
}

double respSP(double sp) {
  return ScreenUtil.instance.setSp(sp);
}

double respWidthPercent(double percent) {
  return ScreenUtil.instance.width * (percent/100);
}

double respHeightPercent(double percent) {
  return ScreenUtil.instance.height * (percent/100);
}