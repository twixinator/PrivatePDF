import '../models/analytics_event.dart';

/// Abstract interface for analytics providers
///
/// This interface allows for different analytics implementations:
/// - EventLoggerService (localStorage, free, privacy-first)
/// - PostHog (future, if needed for server-side analytics)
/// - Plausible (future, if needed for aggregated analytics)
///
/// The current implementation uses localStorage for 100% client-side tracking.
abstract class AnalyticsProvider {
  /// Log an analytics event
  Future<void> logEvent(AnalyticsEvent event);

  /// Get all stored events
  Future<List<AnalyticsEvent>> getStoredEvents();

  /// Clear all stored events
  Future<void> clearAllEvents();

  /// Get events by category
  Future<List<AnalyticsEvent>> getEventsByCategory(
    AnalyticsEventCategory category,
  );

  /// Get events by date range
  Future<List<AnalyticsEvent>> getEventsByDateRange(
    DateTime start,
    DateTime end,
  );

  /// Get event count
  Future<int> getEventCount();

  /// Export events as JSON (for analysis)
  Future<String> exportEventsAsJson();

  /// Get analytics summary
  Future<Map<String, dynamic>> getAnalyticsSummary();
}
