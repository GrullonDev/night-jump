import 'package:flutter/material.dart';

import 'package:night_jump/utils/responsive/app_breakpoints.dart';

extension ResponsiveContext on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);

  double get screenWidth => screenSize.width;

  bool get isLandscape =>
      MediaQuery.orientationOf(this) == Orientation.landscape;

  DeviceType get deviceType => deviceTypeForWidth(screenWidth);

  bool get isMobile => deviceType == DeviceType.mobile;

  bool get isTablet => deviceType == DeviceType.tablet;

  T responsive<T>({required T mobile, T? tablet}) {
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
    }
  }

  double get contentMaxWidth =>
      responsive(mobile: double.infinity, tablet: 560);
}
