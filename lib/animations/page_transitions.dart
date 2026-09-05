import 'package:flutter/material.dart';

/// منسق انتقالات ناعم — انزلاق + تلاشي للصفحات
/// يدعم RTL تلقائياً — ينزلق من اليسار في العربية
class SmoothPageTransitionsBuilder extends PageTransitionsBuilder {
  const SmoothPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // نحدد اتجاه اللغة — في العربية (RTL) ينزلق من اليسار
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final beginOffset = rtl ? const Offset(-0.15, 0) : const Offset(0.15, 0);

    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );

    return SlideTransition(
      position: Tween<Offset>(
        begin: beginOffset,
        end: Offset.zero,
      ).animate(curved),
      child: FadeTransition(
        opacity: curved,
        child: child,
      ),
    );
  }
}
