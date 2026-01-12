import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

/// Immutable data class representing a PDF file's metadata and content
class PdfFileInfo {
  final String id;
  final String name;
  final int sizeBytes;
  final Uint8List bytes;
  final int? pageCount;

  const PdfFileInfo({
    required this.id,
    required this.name,
    required this.sizeBytes,
    required this.bytes,
    this.pageCount,
  });

  /// Create PdfFileInfo from FilePicker's PlatformFile
  factory PdfFileInfo.fromPlatformFile(PlatformFile file) {
    if (file.bytes == null) {
      throw ArgumentError('PlatformFile must have bytes loaded');
    }

    return PdfFileInfo(
      id: '${DateTime.now().millisecondsSinceEpoch}_${file.name}',
      name: file.name,
      sizeBytes: file.size,
      bytes: file.bytes!,
    );
  }

  /// Create PdfFileInfo with page count
  PdfFileInfo copyWithPageCount(int pageCount) {
    return PdfFileInfo(
      id: id,
      name: name,
      sizeBytes: sizeBytes,
      bytes: bytes,
      pageCount: pageCount,
    );
  }

  /// Human-readable file size (e.g., "2.5 MB")
  String get formattedSize {
    if (sizeBytes < 1024) {
      return '$sizeBytes B';
    } else if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Check if file has valid PDF data
  bool get isValid => bytes.isNotEmpty && name.toLowerCase().endsWith('.pdf');

  /// Check if file is within size limit
  bool isWithinSizeLimit(int maxSizeBytes) => sizeBytes <= maxSizeBytes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PdfFileInfo &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PdfFileInfo{id: $id, name: $name, size: $formattedSize, pageCount: $pageCount}';
  }
}
