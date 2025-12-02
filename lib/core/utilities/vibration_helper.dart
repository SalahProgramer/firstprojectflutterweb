import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:vibration/vibration.dart';
import 'dart:io' show Platform;

/// Helper class to safely handle vibration across different platforms
/// Web platform doesn't support vibration plugin, so we need to check before calling
class VibrationHelper {
  /// Check if vibration is supported on current platform
  static bool get isSupported {
    // Web doesn't support vibration plugin
    if (kIsWeb) {
      return false;
    }
    // Only Android and iOS support vibration
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (e) {
      return false;
    }
  }

  /// Vibrate with optional duration and amplitude
  /// Returns true if vibration was triggered, false otherwise
  static Future<bool> vibrate({
    int duration = 100,
    int amplitude = 128,
  }) async {
    if (!isSupported) {
      return false;
    }

    try {
      await Vibration.vibrate(duration: duration, amplitude: amplitude);
      return true;
    } catch (e) {
      // Silently catch any errors (e.g., device doesn't have vibration hardware)
      return false;
    }
  }

  /// Check if device has vibrator
  static Future<bool> hasVibrator() async {
    if (!isSupported) {
      return false;
    }

    try {
      return await Vibration.hasVibrator();
    } catch (e) {
      return false;
    }
  }

  /// Check if device has amplitude control
  static Future<bool> hasAmplitudeControl() async {
    if (!isSupported) {
      return false;
    }

    try {
      return await Vibration.hasAmplitudeControl();
    } catch (e) {
      return false;
    }
  }
}

