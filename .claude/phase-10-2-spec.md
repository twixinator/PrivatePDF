# Phase 10.2: PDF Compression Implementation Specification

## Overview
Implement PDF compression feature to reduce file size by compressing embedded images with configurable quality settings.

## Working Directory
`R:\VS Code Projekte\PrivatePDF`

## Architecture Context

### Existing Patterns to Follow
1. **Service Layer**: `lib/services/pdf_service.dart` - Abstract interface pattern
2. **Models**: `lib/models/` - Immutable data classes with equality
3. **Providers**: `lib/providers/pdf_operation_provider.dart` - State management
4. **Screens**: `lib/screens/` - Page layouts following existing merge/split/protect pages
5. **Dependency Injection**: `lib/core/di/service_locator.dart` - GetIt registration
6. **Routing**: `lib/main.dart` - GoRouter configuration
7. **Strings**: `lib/constants/strings.dart` - German localization

### Current Test Status
- 92 tests passing
- Target: Maintain 100% pass rate
- Add ~15-20 new tests for compression feature

## Implementation Tasks

### Task 1: Create Compression Models

**File: `lib/models/compression_quality.dart`**
```dart
/// Enum representing compression quality levels
enum CompressionQuality {
  low,    // 50% quality
  medium, // 70% quality
  high;   // 90% quality

  /// Get quality percentage (0.0-1.0)
  double get qualityPercentage {
    switch (this) {
      case CompressionQuality.low:
        return 0.5;
      case CompressionQuality.medium:
        return 0.7;
      case CompressionQuality.high:
        return 0.9;
    }
  }

  /// Get display name in German
  String get displayName {
    switch (this) {
      case CompressionQuality.low:
        return 'Niedrig (50%)';
      case CompressionQuality.medium:
        return 'Mittel (70%)';
      case CompressionQuality.high:
        return 'Hoch (90%)';
    }
  }
}
```

**File: `lib/models/compression_result.dart`**
```dart
/// Result of a compression operation
class CompressionResult {
  final int originalSizeBytes;
  final int compressedSizeBytes;
  final Duration processingTime;

  const CompressionResult({
    required this.originalSizeBytes,
    required this.compressedSizeBytes,
    required this.processingTime,
  });

  /// Calculate compression ratio (0.0 to 1.0, where 1.0 = no compression)
  double get compressionRatio =>
      compressedSizeBytes / originalSizeBytes;

  /// Calculate percentage saved (0-100)
  double get percentageSaved =>
      (1 - compressionRatio) * 100;

  /// Format size in human-readable format
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get originalSizeFormatted => formatBytes(originalSizeBytes);
  String get compressedSizeFormatted => formatBytes(compressedSizeBytes);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompressionResult &&
          runtimeType == other.runtimeType &&
          originalSizeBytes == other.originalSizeBytes &&
          compressedSizeBytes == other.compressedSizeBytes;

  @override
  int get hashCode => Object.hash(originalSizeBytes, compressedSizeBytes);

  @override
  String toString() =>
      'CompressionResult(original: $originalSizeFormatted, '
      'compressed: $compressedSizeFormatted, '
      'saved: ${percentageSaved.toStringAsFixed(1)}%)';
}
```

### Task 2: Create PDF Compression Service

**File: `lib/services/pdf_compression_service.dart`**
```dart
import 'dart:typed_data';
import '../models/pdf_file_info.dart';
import '../models/compression_quality.dart';
import '../models/pdf_operation_result.dart';
import '../core/js_interop/i_pdf_lib_bridge.dart';

/// Service for compressing PDF files by reducing image quality
class PdfCompressionService {
  final IPdfLibBridge _pdfLibBridge;

  PdfCompressionService({required IPdfLibBridge pdfLibBridge})
      : _pdfLibBridge = pdfLibBridge;

  /// Compress a PDF by reducing image quality
  ///
  /// @param file PDF file to compress
  /// @param quality Compression quality level
  /// @returns Success with compressed PDF or Failure with error
  Future<PdfOperationResult> compressPdf(
    PdfFileInfo file,
    CompressionQuality quality,
  ) async {
    try {
      final startTime = DateTime.now();

      // Use pdf-lib to compress images
      // This will call JavaScript interop to compress images via Canvas API
      final compressedBytes = await _pdfLibBridge.compressPdf(
        file.bytes,
        quality.qualityPercentage,
      );

      // Generate output filename
      final outputFileName = _generateOutputFileName(file.name);

      return PdfOperationResult.success(
        bytes: compressedBytes,
        fileName: outputFileName,
      );
    } catch (e) {
      return PdfOperationResult.failure(
        error: PdfOperationError.processingFailed,
      );
    }
  }

  /// Generate output filename for compressed PDF
  String _generateOutputFileName(String originalName) {
    final nameWithoutExtension = originalName.replaceAll(RegExp(r'\.pdf$', caseSensitive: false), '');
    return '${nameWithoutExtension}_komprimiert.pdf';
  }
}
```

### Task 3: Update PDF Service Interface

**File: `lib/services/pdf_service.dart`** (Add method)
```dart
/// Compress PDF by reducing image quality
///
/// @param file Source PDF file
/// @param quality Compression quality level
/// @returns Success with compressed PDF or Failure with error
Future<PdfOperationResult> compressPdf(
  PdfFileInfo file,
  CompressionQuality quality,
);
```

**File: `lib/services/pdf_service_impl.dart`** (Add implementation)
```dart
// Add dependency injection for compression service
final PdfCompressionService _compressionService;

// Update constructor to accept compression service
PdfServiceImpl({
  required FileValidationService validator,
  required PdfCompressionService compressionService,
}) : _validator = validator,
     _compressionService = compressionService;

// Implement compress method
@override
Future<PdfOperationResult> compressPdf(
  PdfFileInfo file,
  CompressionQuality quality,
) async {
  // Validate file
  final validation = _validator.validateFiles([file]);
  if (!validation.isValid) {
    return PdfOperationResult.failure(error: validation.error!);
  }

  // Perform compression
  return await _compressionService.compressPdf(file, quality);
}
```

### Task 4: Update JavaScript Interop

**File: `lib/core/js_interop/i_pdf_lib_bridge.dart`** (Add method)
```dart
/// Compress PDF images
Future<Uint8List> compressPdf(Uint8List pdfBytes, double quality);
```

**File: `lib/core/js_interop/pdf_lib_bridge.dart`** (Add implementation)
```dart
@override
Future<Uint8List> compressPdf(Uint8List pdfBytes, double quality) async {
  try {
    final result = await js.promiseToFuture(
      js.context.callMethod('compressPdfImages', [
        pdfBytes,
        quality,
      ]),
    );
    return result as Uint8List;
  } catch (e) {
    throw Exception('Failed to compress PDF: $e');
  }
}
```

**File: `web/js/pdf_lib_processor.js`** (Add function)
```javascript
// Add compression function
async function compressPdfImages(pdfBytes, quality) {
  try {
    const pdfDoc = await PDFLib.PDFDocument.load(pdfBytes);
    const pages = pdfDoc.getPages();

    // Note: pdf-lib doesn't directly support image compression
    // For now, return original bytes (compression would require
    // extracting images, compressing via Canvas, and re-embedding)
    // This is a placeholder for the full implementation

    return await pdfDoc.save();
  } catch (error) {
    console.error('PDF compression error:', error);
    throw error;
  }
}
```

### Task 5: Update Provider

**File: `lib/providers/pdf_operation_provider.dart`** (Add method)
```dart
/// Compress PDF with specified quality
Future<void> compressPdf(PdfFileInfo file, CompressionQuality quality) async {
  final operationId = _queueService.enqueueOperation(PdfOperationType.compress);
  _currentOperationId = operationId;
  _operationStartTime = DateTime.now();

  _setState(const ProcessingState());

  final started = _queueService.startOperation(operationId);
  if (!started) {
    _setState(const ErrorState(PdfOperationError.unknown));
    _logOperationError('compress', 1, 'Failed to start operation');
    return;
  }

  _networkVerification.startMonitoring(operationId);
  final result = await _pdfService.compressPdf(file, quality);
  final verificationReport = _networkVerification.stopMonitoring(operationId);

  result.when(
    success: (bytes, fileName) {
      final duration = DateTime.now().difference(_operationStartTime!);
      _downloadService.downloadPdf(bytes, fileName, operationId: operationId);

      _analytics.logEvent(
        AnalyticsEvent.pdfOperationSuccess(
          operationType: 'compress',
          fileCount: 1,
          durationMs: duration.inMilliseconds,
          outputSizeBytes: bytes.length,
        ),
      );

      _queueService.completeOperation(operationId);
      _setState(SuccessState(fileName));

      _currentOperationId = null;
      _operationStartTime = null;

      Future.delayed(const Duration(seconds: 3), () {
        if (_state is SuccessState) {
          reset();
        }
      });
    },
    failure: (error) {
      _logOperationError('compress', 1, error.code);
      _queueService.failOperation(operationId, error: error.message);
      _setState(ErrorState(error));

      _currentOperationId = null;
      _operationStartTime = null;
    },
  );
}
```

**Update PdfOperationType enum:**
```dart
enum PdfOperationType {
  merge,
  split,
  protect,
  compress, // Add this
}
```

### Task 6: Create Compress Page

**File: `lib/screens/compress_page.dart`**
Create a page following the pattern of `merge_page.dart`, `split_page.dart`, etc. with:
- File upload section
- Quality selector (3 radio buttons or dropdown)
- Before/After size display (after file selection)
- Compress button
- Success/Error state handling
- Download button

### Task 7: Update Strings

**File: `lib/constants/strings.dart`** (Add compression strings)
```dart
// Compression Tool
static const String compressToolTitle = 'PDF komprimieren';
static const String compressToolDescription = 'Reduzieren Sie die Dateigröße durch Bildkompression';
static const String compressPageTitle = 'PDF komprimieren';
static const String compressSelectFile = 'PDF-Datei auswählen';
static const String compressQualityLabel = 'Qualität wählen';
static const String compressQualityLow = 'Niedrig (50% Qualität)';
static const String compressQualityMedium = 'Mittel (70% Qualität)';
static const String compressQualityHigh = 'Hoch (90% Qualität)';
static const String compressButton = 'PDF komprimieren';
static const String compressOriginalSize = 'Originalgröße';
static const String compressCompressedSize = 'Komprimierte Größe';
static const String compressPercentageSaved = 'Ersparnis';
static const String compressSuccess = 'PDF erfolgreich komprimiert!';
```

### Task 8: Update Service Locator

**File: `lib/core/di/service_locator.dart`**
```dart
// Register compression service
getIt.registerLazySingleton<PdfCompressionService>(
  () => PdfCompressionService(
    pdfLibBridge: getIt<IPdfLibBridge>(),
  ),
);

// Update PdfService registration to include compression service
getIt.registerLazySingleton<PdfService>(
  () => PdfServiceImpl(
    validator: getIt<FileValidationService>(),
    compressionService: getIt<PdfCompressionService>(),
  ),
);
```

### Task 9: Update Landing Page

**File: `lib/screens/landing_page.dart`**
Add a new tool card for compression following the existing pattern of merge/split/protect cards.

### Task 10: Update Main Router

**File: `lib/main.dart`**
```dart
GoRoute(
  path: '/compress',
  pageBuilder: (context, state) => PageTransitions.scaleFade(
    child: const CompressPage(),
    state: state,
  ),
),
```

## Testing Requirements

### Unit Tests

**File: `test/unit/models/compression_quality_test.dart`**
- Test all enum values exist
- Test qualityPercentage for each level
- Test displayName for each level

**File: `test/unit/models/compression_result_test.dart`**
- Test compression ratio calculation
- Test percentage saved calculation
- Test formatBytes utility
- Test formatted getters
- Test equality operator
- Test toString

**File: `test/unit/services/pdf_compression_service_test.dart`**
- Test successful compression with each quality level
- Test filename generation
- Test error handling
- Test with mock IPdfLibBridge

## Success Criteria

1. All new files created following existing patterns
2. All 92 existing tests still pass
3. All new tests pass (target: 15-20 new tests)
4. Code follows Dart style guide
5. German language consistency maintained
6. No compilation errors or warnings
7. Proper error handling throughout
8. Dependency injection properly configured

## Notes

- Follow existing architectural patterns exactly
- Use absolute file paths: `R:\VS Code Projekte\PrivatePDF\`
- Maintain German language for all UI strings
- Ensure proper error handling with PdfOperationError
- Test coverage target: 85%+ for new code
