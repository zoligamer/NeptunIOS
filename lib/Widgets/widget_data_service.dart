import 'dart:async';
import '../API/api_coms.dart' as api;

/// Stubbed WidgetDataService for Web builds where homescreen widgets are not supported.
class WidgetDataService {
  static void initDeepLinking(void Function(String tab) onNavigate) {
    // No-op on web
  }

  static Future<void> updateAllWidgets({
    List<api.CalendarEntry>? calendarEntries,
    List<api.PeriodEntry>? periods,
    List<api.Subject>? markbook,
  }) async {
    // No-op on web
  }

  static Future<void> clearAllWidgets() async {
    // No-op on web
  }
}
