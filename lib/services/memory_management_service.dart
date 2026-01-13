import 'package:flutter/foundation.dart';
import '../config/environment.dart';

/// Represents a memory allocation with metadata
class MemoryAllocation {
  final String operationId;
  final String resourceName;
  final int sizeBytes;
  final DateTime allocatedAt;

  MemoryAllocation({
    required this.operationId,
    required this.resourceName,
    required this.sizeBytes,
    required this.allocatedAt,
  });

  /// Get human-readable size
  String get sizeMB => '${(sizeBytes / 1024 / 1024).toStringAsFixed(2)} MB';

  /// Age of this allocation
  Duration get age => DateTime.now().difference(allocatedAt);

  @override
  String toString() =>
      'MemoryAllocation($resourceName: $sizeMB, age: ${age.inSeconds}s)';
}

/// Service for tracking and managing memory allocations
///
/// Explicitly tracks Uint8List allocations to prevent memory leaks
/// and provide visibility into memory usage patterns.
class MemoryManagementService extends ChangeNotifier {
  /// Map of operation ID to list of allocations
  final Map<String, List<MemoryAllocation>> _allocationsByOperation = {};

  /// Map of resource keys to allocations for quick lookup
  final Map<String, MemoryAllocation> _allocationsByKey = {};

  /// Track a new memory allocation
  ///
  /// @param operationId Unique identifier for the PDF operation
  /// @param resourceName Name of the resource (e.g., 'input_file_1', 'output_pdf')
  /// @param sizeBytes Size of the allocation in bytes
  void trackAllocation(
    String operationId,
    String resourceName,
    int sizeBytes,
  ) {
    final allocation = MemoryAllocation(
      operationId: operationId,
      resourceName: resourceName,
      sizeBytes: sizeBytes,
      allocatedAt: DateTime.now(),
    );

    // Add to operation-based map
    _allocationsByOperation.putIfAbsent(operationId, () => []);
    _allocationsByOperation[operationId]!.add(allocation);

    // Add to key-based map for quick lookup
    final key = _makeKey(operationId, resourceName);
    _allocationsByKey[key] = allocation;

    if (Environment.enableDebugLogging) {
      print(
        '[MemoryManagement] Tracked: $operationId/$resourceName = ${allocation.sizeMB}',
      );
    }

    notifyListeners();
  }

  /// Release a specific allocation
  ///
  /// @param operationId Unique identifier for the PDF operation
  /// @param resourceName Name of the resource to release
  void releaseAllocation(String operationId, String resourceName) {
    final key = _makeKey(operationId, resourceName);
    final allocation = _allocationsByKey.remove(key);

    if (allocation != null) {
      _allocationsByOperation[operationId]?.remove(allocation);

      // Remove operation entry if empty
      if (_allocationsByOperation[operationId]?.isEmpty ?? false) {
        _allocationsByOperation.remove(operationId);
      }

      if (Environment.enableDebugLogging) {
        print(
          '[MemoryManagement] Released: $operationId/$resourceName = ${allocation.sizeMB}',
        );
      }

      notifyListeners();
    } else {
      if (Environment.enableDebugLogging) {
        print(
          '[MemoryManagement] Warning: Attempted to release non-existent allocation: $operationId/$resourceName',
        );
      }
    }
  }

  /// Clear all allocations for a specific operation
  ///
  /// Called when an operation completes (success or failure)
  void clearOperationAllocations(String operationId) {
    final allocations = _allocationsByOperation.remove(operationId);

    if (allocations != null) {
      // Remove from key-based map
      for (final allocation in allocations) {
        final key = _makeKey(operationId, allocation.resourceName);
        _allocationsByKey.remove(key);
      }

      if (Environment.enableDebugLogging) {
        final totalMB = allocations.fold<int>(
              0,
              (sum, a) => sum + a.sizeBytes,
            ) /
            1024 /
            1024;
        print(
          '[MemoryManagement] Cleared operation $operationId: ${allocations.length} allocations, ${totalMB.toStringAsFixed(2)} MB',
        );
      }

      notifyListeners();
    }
  }

  /// Get total memory usage for a specific operation
  int getOperationMemoryUsage(String operationId) {
    final allocations = _allocationsByOperation[operationId];
    if (allocations == null) return 0;

    return allocations.fold<int>(0, (sum, allocation) => sum + allocation.sizeBytes);
  }

  /// Get total tracked memory across all operations
  int get totalTrackedBytes {
    return _allocationsByKey.values
        .fold<int>(0, (sum, allocation) => sum + allocation.sizeBytes);
  }

  /// Get human-readable total memory usage
  String get totalTrackedMB =>
      '${(totalTrackedBytes / 1024 / 1024).toStringAsFixed(2)} MB';

  /// Get number of active operations
  int get activeOperationCount => _allocationsByOperation.length;

  /// Get number of tracked allocations
  int get allocationCount => _allocationsByKey.length;

  /// Get all allocations for an operation
  List<MemoryAllocation> getOperationAllocations(String operationId) {
    return List.unmodifiable(_allocationsByOperation[operationId] ?? []);
  }

  /// Get all active operation IDs
  List<String> get activeOperationIds =>
      List.unmodifiable(_allocationsByOperation.keys);

  /// Clear all allocations (use with caution)
  void clearAll() {
    if (Environment.enableDebugLogging) {
      print(
        '[MemoryManagement] Clearing all: ${_allocationsByKey.length} allocations, $totalTrackedMB',
      );
    }

    _allocationsByOperation.clear();
    _allocationsByKey.clear();
    notifyListeners();
  }

  /// Get memory usage report
  Map<String, dynamic> getMemoryReport() {
    return {
      'totalTrackedBytes': totalTrackedBytes,
      'totalTrackedMB': totalTrackedMB,
      'activeOperations': activeOperationCount,
      'totalAllocations': allocationCount,
      'memoryPressure': getMemoryPressureLevel(),
      'operationBreakdown': _allocationsByOperation.map(
        (operationId, allocations) => MapEntry(
          operationId,
          {
            'count': allocations.length,
            'totalBytes': allocations.fold<int>(
              0,
              (sum, a) => sum + a.sizeBytes,
            ),
            'totalMB': (allocations.fold<int>(
                      0,
                      (sum, a) => sum + a.sizeBytes,
                    ) /
                    1024 /
                    1024)
                .toStringAsFixed(2),
          },
        ),
      ),
    };
  }

  /// Get memory pressure level (Phase 7: Memory Pressure Detection)
  /// Returns: 'low', 'moderate', 'high', or 'critical'
  String getMemoryPressureLevel() {
    final trackedMB = totalTrackedBytes / 1024 / 1024;

    if (trackedMB > 500) {
      return 'critical'; // Over 500MB tracked - critical memory pressure
    } else if (trackedMB > 250) {
      return 'high'; // 250-500MB - high memory pressure
    } else if (trackedMB > 100) {
      return 'moderate'; // 100-250MB - moderate memory pressure
    }
    return 'low'; // Under 100MB - low memory pressure
  }

  /// Check if memory pressure is high (Phase 7)
  bool get isMemoryPressureHigh {
    final level = getMemoryPressureLevel();
    return level == 'high' || level == 'critical';
  }

  /// Get memory pressure warning message
  String? getMemoryPressureWarning() {
    switch (getMemoryPressureLevel()) {
      case 'critical':
        return 'Kritische Speicherauslastung. Bitte schließen Sie andere Tabs oder reduzieren Sie die Dateigröße.';
      case 'high':
        return 'Hohe Speicherauslastung. Die Verarbeitung kann langsamer sein.';
      case 'moderate':
        return 'Moderate Speicherauslastung. Überwachung aktiv.';
      default:
        return null;
    }
  }

  /// Suggest garbage collection hint for large operations (Phase 7)
  /// This doesn't actually force GC but can be used to trigger cleanup logic
  void suggestGarbageCollection() {
    if (Environment.enableDebugLogging) {
      print('[MemoryManagement] Garbage collection hint suggested (pressure: ${getMemoryPressureLevel()})');
    }
    // Note: Dart VM handles garbage collection automatically
    // This method serves as a hook for additional cleanup logic
    notifyListeners();
  }

  /// Print memory report to console (debug only)
  void printMemoryReport() {
    if (Environment.enableDebugLogging) {
      print('=== Memory Management Report ===');
      print('Total Tracked: $totalTrackedMB ($allocationCount allocations)');
      print('Active Operations: $activeOperationCount');

      if (_allocationsByOperation.isNotEmpty) {
        print('\nBreakdown by Operation:');
        _allocationsByOperation.forEach((operationId, allocations) {
          final totalBytes =
              allocations.fold<int>(0, (sum, a) => sum + a.sizeBytes);
          final totalMB = (totalBytes / 1024 / 1024).toStringAsFixed(2);
          print(
            '  $operationId: ${allocations.length} allocations, $totalMB MB',
          );

          for (final allocation in allocations) {
            print('    - ${allocation.resourceName}: ${allocation.sizeMB}');
          }
        });
      }

      print('================================');
    }
  }

  /// Create a unique key for allocation lookup
  String _makeKey(String operationId, String resourceName) =>
      '$operationId::$resourceName';

  @override
  void dispose() {
    if (Environment.enableDebugLogging) {
      print('[MemoryManagement] Service disposed');
    }
    clearAll();
    super.dispose();
  }
}
