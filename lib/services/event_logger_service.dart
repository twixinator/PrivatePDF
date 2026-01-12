// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'dart:convert';
import '../models/analytics_event.dart';
import '../config/environment.dart';
import 'analytics_service.dart';

/// localStorage-based analytics implementation
///
/// This service provides 100% free, privacy-first analytics by storing
/// events in the browser's localStorage. No data leaves the device.
///
/// Features:
/// - ✅ Free (no hosting costs)
/// - ✅ Privacy-first (data never leaves browser)
/// - ✅ Offline-capable (works without internet)
/// - ✅ GDPR-compliant (no PII, anonymous only)
/// - ✅ Extensible (can export for analysis)
class EventLoggerService implements AnalyticsProvider {
  /// Get localStorage instance
  html.Storage get _storage => html.window.localStorage;

  /// Storage key for events
  String get _storageKey => Environment.analyticsStorageKey;

  @override
  Future<void> logEvent(AnalyticsEvent event) async {
    if (!Environment.enableAnalytics) {
      return; // Analytics disabled
    }

    try {
      final events = await getStoredEvents();
      events.add(event);

      // Limit stored events to prevent localStorage bloat
      if (events.length > Environment.maxStoredAnalyticsEvents) {
        // Remove oldest events
        final eventsToKeep = events.sublist(
          events.length - Environment.maxStoredAnalyticsEvents,
        );
        await _saveEvents(eventsToKeep);
      } else {
        await _saveEvents(events);
      }

      if (Environment.enableDebugLogging) {
        print('[EventLogger] Logged: ${event.eventName} (${event.category.name})');
      }
    } catch (e) {
      if (Environment.enableDebugLogging) {
        print('[EventLogger] Error logging event: $e');
      }
    }
  }

  @override
  Future<List<AnalyticsEvent>> getStoredEvents() async {
    try {
      final jsonString = _storage[_storageKey];
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => AnalyticsEvent.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (Environment.enableDebugLogging) {
        print('[EventLogger] Error reading events: $e');
      }
      return [];
    }
  }

  @override
  Future<void> clearAllEvents() async {
    try {
      _storage.remove(_storageKey);
      if (Environment.enableDebugLogging) {
        print('[EventLogger] Cleared all events');
      }
    } catch (e) {
      if (Environment.enableDebugLogging) {
        print('[EventLogger] Error clearing events: $e');
      }
    }
  }

  @override
  Future<List<AnalyticsEvent>> getEventsByCategory(
    AnalyticsEventCategory category,
  ) async {
    final events = await getStoredEvents();
    return events.where((event) => event.category == category).toList();
  }

  @override
  Future<List<AnalyticsEvent>> getEventsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final events = await getStoredEvents();
    return events.where((event) {
      return event.timestamp.isAfter(start) && event.timestamp.isBefore(end);
    }).toList();
  }

  @override
  Future<int> getEventCount() async {
    final events = await getStoredEvents();
    return events.length;
  }

  @override
  Future<String> exportEventsAsJson() async {
    final events = await getStoredEvents();
    final jsonList = events.map((e) => e.toJson()).toList();
    return jsonEncode(jsonList);
  }

  @override
  Future<Map<String, dynamic>> getAnalyticsSummary() async {
    final events = await getStoredEvents();

    if (events.isEmpty) {
      return {
        'totalEvents': 0,
        'categories': {},
        'dateRange': null,
      };
    }

    // Count by category
    final categoryCounts = <String, int>{};
    for (final event in events) {
      final categoryName = event.category.name;
      categoryCounts[categoryName] = (categoryCounts[categoryName] ?? 0) + 1;
    }

    // Count by event name
    final eventNameCounts = <String, int>{};
    for (final event in events) {
      eventNameCounts[event.eventName] =
          (eventNameCounts[event.eventName] ?? 0) + 1;
    }

    // Get date range
    final timestamps = events.map((e) => e.timestamp).toList();
    timestamps.sort();
    final earliestEvent = timestamps.first;
    final latestEvent = timestamps.last;

    // Calculate PDF operation stats
    final pdfOperations = events.where(
      (e) => e.category == AnalyticsEventCategory.pdfOperation,
    );
    final pdfSuccesses = pdfOperations.where(
      (e) => e.eventName.contains('_success'),
    ).length;
    final pdfErrors = events.where(
      (e) => e.category == AnalyticsEventCategory.error,
    ).length;

    return {
      'totalEvents': events.length,
      'categories': categoryCounts,
      'topEvents': eventNameCounts.entries
          .toList()
          ..sort((a, b) => b.value.compareTo(a.value)),
      'dateRange': {
        'earliest': earliestEvent.toIso8601String(),
        'latest': latestEvent.toIso8601String(),
        'durationDays': latestEvent.difference(earliestEvent).inDays,
      },
      'pdfOperations': {
        'total': pdfOperations.length,
        'successes': pdfSuccesses,
        'errors': pdfErrors,
        'successRate': pdfOperations.isEmpty
            ? 0.0
            : (pdfSuccesses / pdfOperations.length * 100).toStringAsFixed(1),
      },
    };
  }

  /// Save events to localStorage
  Future<void> _saveEvents(List<AnalyticsEvent> events) async {
    try {
      final jsonList = events.map((e) => e.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      _storage[_storageKey] = jsonString;
    } catch (e) {
      if (Environment.enableDebugLogging) {
        print('[EventLogger] Error saving events: $e');
      }
      rethrow;
    }
  }

  /// Print analytics summary to console (debug only)
  Future<void> printAnalyticsSummary() async {
    if (Environment.enableDebugLogging) {
      final summary = await getAnalyticsSummary();
      print('=== Analytics Summary ===');
      print('Total Events: ${summary['totalEvents']}');
      print('\nCategories:');
      (summary['categories'] as Map).forEach((category, count) {
        print('  $category: $count');
      });

      if (summary['dateRange'] != null) {
        final dateRange = summary['dateRange'] as Map;
        print('\nDate Range:');
        print('  From: ${dateRange['earliest']}');
        print('  To: ${dateRange['latest']}');
        print('  Duration: ${dateRange['durationDays']} days');
      }

      final pdfOps = summary['pdfOperations'] as Map;
      print('\nPDF Operations:');
      print('  Total: ${pdfOps['total']}');
      print('  Successes: ${pdfOps['successes']}');
      print('  Errors: ${pdfOps['errors']}');
      print('  Success Rate: ${pdfOps['successRate']}%');

      print('========================');
    }
  }
}
