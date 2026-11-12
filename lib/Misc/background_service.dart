import 'dart:async';

/// Stubbed BackgroundService for Web builds where background workers are not supported.
class BackgroundService {
  static const String messageCheckTaskName = 'jupiter_periodic_message_check';
  static const String uniqueWorkName = 'jupiter_message_checker_unique';

  static Future<void> initialize() async {
    // No-op on web
  }

  static Future<void> registerPeriodicCheck({int? intervalMinutes, bool? wifiOnly}) async {
    // No-op on web
  }

  static Future<void> cancelPeriodicCheck() async {
    // No-op on web
  }

  static Future<void> performBackgroundMessageCheck() async {
    // No-op on web
  }
}
