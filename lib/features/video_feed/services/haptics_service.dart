import 'package:flutter/services.dart';

class HapticsService {
  static void like() {
    HapticFeedback.mediumImpact();
  }
}