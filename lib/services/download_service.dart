// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'dart:typed_data';
import '../config/environment.dart';
import 'memory_management_service.dart';
import 'file_name_sanitizer.dart';

/// Service for downloading files in the browser
/// Uses HTML5 Blob and URL APIs for client-side downloads
class DownloadService {
  final MemoryManagementService? _memoryService;

  DownloadService({MemoryManagementService? memoryService})
      : _memoryService = memoryService;

  /// Download PDF bytes as a file
  ///
  /// @param bytes PDF file bytes
  /// @param fileName Suggested filename for download
  /// @param operationId Optional operation ID for memory tracking
  void downloadPdf(
    Uint8List bytes,
    String fileName, {
    String? operationId,
  }) {
    try {
      // Sanitize filename (preserves German umlauts, removes invalid chars)
      final sanitizedFileName = FileNameSanitizer.getSafeDownloadName(fileName);

      // Track memory allocation if service available
      if (_memoryService != null && operationId != null) {
        _memoryService!.trackAllocation(
          operationId,
          'download_blob',
          bytes.length,
        );
      }

      // Create a Blob from the bytes
      final blob = html.Blob([bytes], 'application/pdf');

      // Create a download URL
      final url = html.Url.createObjectUrlFromBlob(blob);

      // Create a temporary anchor element to trigger download
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', sanitizedFileName)
        ..style.display = 'none';

      // Add to document, click, and remove
      html.document.body?.append(anchor);
      anchor.click();
      anchor.remove();

      // Clean up the URL after a delay
      Future.delayed(Environment.downloadUrlCleanupDelay, () {
        html.Url.revokeObjectUrl(url);
      });

      // Schedule memory cleanup
      if (_memoryService != null && operationId != null) {
        Future.delayed(Environment.memoryCleanupDelay, () {
          _memoryService!.releaseAllocation(operationId, 'download_blob');
          // Yield to event loop for garbage collection
          Future.delayed(Duration.zero);
        });
      }

      print('[DownloadService] Downloaded: $sanitizedFileName (${bytes.length} bytes)');
    } catch (e) {
      print('[DownloadService] Error downloading PDF: $e');
      rethrow;
    }
  }

  /// Download multiple PDFs (batch download)
  ///
  /// @param files Map of filename to bytes
  void downloadMultiplePdfs(Map<String, Uint8List> files) {
    for (final entry in files.entries) {
      downloadPdf(entry.value, entry.key);

      // Small delay between downloads to avoid browser issues
      Future.delayed(const Duration(milliseconds: 200));
    }
  }

  /// Check if download is supported in current environment
  bool isSupported() {
    // Always supported in web environment
    return true;
  }
}
