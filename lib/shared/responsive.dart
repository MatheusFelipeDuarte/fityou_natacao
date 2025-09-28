import 'package:flutter/material.dart';

enum DeviceSize { mobile, tablet }

class Responsive {
  Responsive._();

  static const double tabletMinWidth = 720; // ajustável após testes no tablet alvo

  static DeviceSize deviceOf(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= tabletMinWidth ? DeviceSize.tablet : DeviceSize.mobile;
  }

  static bool isTablet(BuildContext context) => deviceOf(context) == DeviceSize.tablet;
  static bool isMobile(BuildContext context) => deviceOf(context) == DeviceSize.mobile;

  static double responsivePadding(BuildContext context) {
    return isTablet(context) ? 24 : 16;
  }

  static double responsiveGap(BuildContext context) {
    return isTablet(context) ? 16 : 12;
  }
}
