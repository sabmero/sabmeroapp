import 'package:flutter/material.dart';

class Responsive {
  Responsive._();

  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;

  static double width(BuildContext context) => MediaQuery.sizeOf(context).width;

  static bool isMobile(BuildContext context) =>
      width(context) < mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      width(context) >= mobileBreakpoint && width(context) < tabletBreakpoint;

  static bool isDesktop(BuildContext context) =>
      width(context) >= tabletBreakpoint;

  /// Max width for reading/content-heavy screens (product detail, forms).
  static double contentMaxWidth(BuildContext context) =>
      isMobile(context) ? double.infinity : 720;

  /// Max width for auth/forms so fields don't stretch on tablets/web.
  static double formMaxWidth(BuildContext context) =>
      isMobile(context) ? double.infinity : 480;

  /// Grid column count for product grids.
  static int gridColumns(BuildContext context) {
    final w = width(context);
    if (w >= 1400) return 5;
    if (w >= tabletBreakpoint) return 4;
    if (w >= mobileBreakpoint) return 3;
    return 2;
  }

  /// Horizontal page padding that scales with the screen.
  static EdgeInsets pagePadding(BuildContext context) {
    if (isDesktop(context))
      return const EdgeInsets.symmetric(horizontal: 48, vertical: 20);
    if (isTablet(context))
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 20);
    return const EdgeInsets.all(20);
  }

  /// Scales a base font size slightly up on larger screens.
  static double font(BuildContext context, double base) {
    if (isDesktop(context)) return base * 1.1;
    if (isTablet(context)) return base * 1.05;
    return base;
  }
}

class ResponsiveBody extends StatelessWidget {
  const ResponsiveBody({super.key, required this.child, this.maxWidth});

  final Widget child;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? Responsive.contentMaxWidth(context),
        ),
        child: child,
      ),
    );
  }
}
