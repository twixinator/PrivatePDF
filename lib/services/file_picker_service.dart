import 'package:file_picker/file_picker.dart';
import '../models/pdf_file_info.dart';

/// Service for picking PDF files from the file system
/// Wraps file_picker package with domain-specific logic
class FilePickerService {
  /// Pick multiple PDF files
  ///
  /// @returns List of PdfFileInfo objects (empty if cancelled)
  Future<List<PdfFileInfo>> pickMultiplePdfs() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
        withData: true, // Important: Load file bytes into memory
      );

      if (result == null) {
        return [];
      }

      // Convert PlatformFiles to PdfFileInfo objects
      return result.files
          .where((file) => file.bytes != null) // Filter out files without bytes
          .map((file) => PdfFileInfo.fromPlatformFile(file))
          .toList();
    } catch (e) {
      print('[FilePickerService] Error picking multiple PDFs: $e');
      return [];
    }
  }

  /// Pick a single PDF file
  ///
  /// @returns PdfFileInfo object or null if cancelled
  Future<PdfFileInfo?> pickSinglePdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final file = result.files.first;
      if (file.bytes == null) {
        print('[FilePickerService] File bytes are null');
        return null;
      }

      return PdfFileInfo.fromPlatformFile(file);
    } catch (e) {
      print('[FilePickerService] Error picking single PDF: $e');
      return null;
    }
  }

  /// Check if file picker is available on this platform
  bool isAvailable() {
    // file_picker is available on all Flutter platforms
    return true;
  }
}
