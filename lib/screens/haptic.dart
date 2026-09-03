import 'package:flutter/services.dart';

/// اهتزازات لمسية خفيفة لتحسين تجربة التفاعل
class Haptics {
  /// اهتزاز خفيف جداً — للأزرار العادية والقوائم
  static void light() {
    HapticFeedback.lightImpact();
  }

  /// اهتزاز متوسط — للحفظ والتأكيد
  static void medium() {
    HapticFeedback.mediumImpact();
  }

  /// اهتزاز نجاح — عند إتمام عملية (حجز/حفظ)
  static void success() {
    HapticFeedback.heavyImpact();
  }

  /// اهتزاز تنبيه — عند خطأ أو رفض
  static void error() {
    HapticFeedback.vibrate();
  }
}
