import 'dart:typed_data';
import 'package:privatpdf/models/pdf_file_info.dart';

/// Test helper utilities for creating mock data
class TestHelpers {
  /// Create a mock PdfFileInfo for testing
  static PdfFileInfo createMockPdfFileInfo(
    String name, {
    int? sizeBytes,
    Uint8List? bytes,
    int? pageCount,
  }) {
    final defaultBytes = Uint8List.fromList([
      0x25, 0x50, 0x44, 0x46, // %PDF magic bytes
      ...List.generate(100, (i) => i % 256),
    ]);

    return PdfFileInfo(
      id: '${DateTime.now().millisecondsSinceEpoch}_$name',
      name: name,
      sizeBytes: sizeBytes ?? 1024,
      bytes: bytes ?? defaultBytes,
      pageCount: pageCount,
    );
  }

  /// Create a mock PDF with specific size (in MB)
  static PdfFileInfo createMockPdfWithSize(String name, int megabytes) {
    final bytes = Uint8List(megabytes * 1024 * 1024);
    // Add PDF magic bytes
    bytes[0] = 0x25; // %
    bytes[1] = 0x50; // P
    bytes[2] = 0x44; // D
    bytes[3] = 0x46; // F

    return PdfFileInfo(
      id: '${DateTime.now().millisecondsSinceEpoch}_$name',
      name: name,
      sizeBytes: bytes.length,
      bytes: bytes,
    );
  }

  /// Create multiple mock PDFs
  static List<PdfFileInfo> createMultipleMockPdfs(int count) {
    return List.generate(
      count,
      (i) => createMockPdfFileInfo('file$i.pdf'),
    );
  }

  /// Create a corrupted PDF (invalid magic bytes)
  static PdfFileInfo createCorruptedPdf(String name) {
    return PdfFileInfo(
      id: '${DateTime.now().millisecondsSinceEpoch}_$name',
      name: name,
      sizeBytes: 100,
      bytes: Uint8List.fromList([0x00, 0x01, 0x02, 0x03, 0x04]),
    );
  }

  /// Create a PDF with valid magic bytes but insufficient size
  static PdfFileInfo createTinyPdf(String name) {
    return PdfFileInfo(
      id: '${DateTime.now().millisecondsSinceEpoch}_$name',
      name: name,
      sizeBytes: 4,
      bytes: Uint8List.fromList([0x25, 0x50, 0x44, 0x46]), // Just %PDF
    );
  }

  /// Create a mock PDF file info with all properties
  static PdfFileInfo createFullMockPdf({
    required String name,
    required int sizeBytes,
    required int pageCount,
  }) {
    final bytes = Uint8List(sizeBytes);
    // Add PDF magic bytes
    bytes[0] = 0x25;
    bytes[1] = 0x50;
    bytes[2] = 0x44;
    bytes[3] = 0x46;

    return PdfFileInfo(
      id: '${DateTime.now().millisecondsSinceEpoch}_$name',
      name: name,
      sizeBytes: sizeBytes,
      bytes: bytes,
      pageCount: pageCount,
    );
  }

  /// Verify PDF has valid magic bytes
  static bool hasValidPdfHeader(Uint8List bytes) {
    if (bytes.length < 4) return false;
    return bytes[0] == 0x25 && // %
        bytes[1] == 0x50 && // P
        bytes[2] == 0x44 && // D
        bytes[3] == 0x46; // F
  }
}
