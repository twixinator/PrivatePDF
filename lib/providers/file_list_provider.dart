import 'package:flutter/foundation.dart';
import '../models/pdf_file_info.dart';

/// Provider for managing the list of selected PDF files
/// Handles file selection, reordering, and removal
class FileListProvider extends ChangeNotifier {
  List<PdfFileInfo> _files = [];

  // Constants
  static const int minFiles = 2;
  static const int maxFiles = 10;

  /// Get immutable copy of files
  List<PdfFileInfo> get files => List.unmodifiable(_files);

  /// File count
  int get fileCount => _files.length;

  /// Total size of all files in bytes
  int get totalSizeBytes => _files.fold(0, (sum, f) => sum + f.sizeBytes);

  /// Formatted total size
  String get formattedTotalSize {
    if (totalSizeBytes < 1024) {
      return '$totalSizeBytes B';
    } else if (totalSizeBytes < 1024 * 1024) {
      return '${(totalSizeBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(totalSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Check if can merge (2-10 files)
  bool get canMerge => fileCount >= minFiles && fileCount <= maxFiles;

  /// Check if has files
  bool get hasFiles => _files.isNotEmpty;

  /// Check if at max capacity
  bool get isAtMaxCapacity => fileCount >= maxFiles;

  /// Available slots for more files
  int get availableSlots => maxFiles - fileCount;

  /// Add files to the list
  void addFiles(List<PdfFileInfo> newFiles) {
    if (newFiles.isEmpty) return;

    // Only add up to max capacity
    final available = availableSlots;
    if (available > 0) {
      _files.addAll(newFiles.take(available));
      notifyListeners();
    }
  }

  /// Add a single file
  void addFile(PdfFileInfo file) {
    if (!isAtMaxCapacity) {
      _files.add(file);
      notifyListeners();
    }
  }

  /// Remove file by ID
  void removeFile(String fileId) {
    final initialLength = _files.length;
    _files.removeWhere((f) => f.id == fileId);

    if (_files.length != initialLength) {
      notifyListeners();
    }
  }

  /// Remove file by index
  void removeFileAt(int index) {
    if (index >= 0 && index < _files.length) {
      _files.removeAt(index);
      notifyListeners();
    }
  }

  /// Reorder files (for drag and drop)
  void reorderFiles(int oldIndex, int newIndex) {
    if (oldIndex < 0 ||
        oldIndex >= _files.length ||
        newIndex < 0 ||
        newIndex >= _files.length) {
      return;
    }

    // Adjust newIndex if moving down
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final file = _files.removeAt(oldIndex);
    _files.insert(newIndex, file);
    notifyListeners();
  }

  /// Clear all files
  void clear() {
    if (_files.isNotEmpty) {
      _files.clear();
      notifyListeners();
    }
  }

  /// Replace all files with new list
  void setFiles(List<PdfFileInfo> newFiles) {
    _files = newFiles.take(maxFiles).toList();
    notifyListeners();
  }

  /// Get file by ID
  PdfFileInfo? getFileById(String id) {
    try {
      return _files.firstWhere((f) => f.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get file by index
  PdfFileInfo? getFileAt(int index) {
    if (index >= 0 && index < _files.length) {
      return _files[index];
    }
    return null;
  }

  @override
  void dispose() {
    _files.clear();
    super.dispose();
  }
}
