class AppBreakpoints {
  AppBreakpoints._();

  static const double tablet = 600;
}

enum DeviceType { mobile, tablet }

DeviceType deviceTypeForWidth(double width) {
  return width < AppBreakpoints.tablet ? DeviceType.mobile : DeviceType.tablet;
}
