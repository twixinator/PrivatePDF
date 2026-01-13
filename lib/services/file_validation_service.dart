import 'dart:typed_data';
import '../models/pdf_file_info.dart';
import '../models/page_range.dart';
import '../models/validation_result.dart';
import '../models/pdf_operation_error.dart';
import '../core/js_interop/i_pdf_lib_bridge.dart';
import '../core/js_interop/pdf_lib_bridge.dart';

/// Service for validating PDF files and operations
/// Encapsulates all validation business rules with advanced integrity checks
class FileValidationService {
  final int maxFileSizeBytes;
  final int maxTotalOperationSize;
  final int minMergeFiles;
  final int maxMergeFiles;
  final int minPasswordLength;
  final IPdfLibBridge _pdfLibBridge;

  FileValidationService({
    this.maxFileSizeBytes = 100 * 1024 * 1024, // 100MB default (Phase 7: Post-MVP Enhancement)
    this.maxTotalOperationSize = 250 * 1024 * 1024, // 250MB total operation limit
    this.minMergeFiles = 2,
    this.maxMergeFiles = 10,
    this.minPasswordLength = 6,
    IPdfLibBridge? pdfLibBridge,
  }) : _pdfLibBridge = pdfLibBridge ?? PdfLibBridge.instance;

  /// Validate files for merge operation
  ValidationResult validateMerge(List<PdfFileInfo> files) {
    // Check minimum files
    if (files.length < minMergeFiles) {
      return ValidationResult.failure(PdfOperationError.insufficientFiles);
    }

    // Check maximum files
    if (files.length > maxMergeFiles) {
      return ValidationResult.failure(PdfOperationError.tooManyFiles);
    }

    // Validate each file
    for (final file in files) {
      final fileValidation = _validateSingleFile(file);
      if (!fileValidation.isValid) {
        return fileValidation;
      }
    }

    // Check total operation size (Phase 7: 250MB combined limit)
    final totalSize = files.fold<int>(0, (sum, file) => sum + file.sizeBytes);
    if (totalSize > maxTotalOperationSize) {
      return ValidationResult.failure(PdfOperationError.operationTooLarge);
    }

    return ValidationResult.success();
  }

  /// Validate file for split operation
  ValidationResult validateSplit(PdfFileInfo file, PageRange range) {
    // Validate the file itself
    final fileValidation = _validateSingleFile(file);
    if (!fileValidation.isValid) {
      return fileValidation;
    }

    // Check if PDF has enough pages
    if (file.pageCount != null && file.pageCount! < 2) {
      return ValidationResult.failure(PdfOperationError.insufficientPages);
    }

    // Validate page range
    if (file.pageCount != null) {
      if (!range.isValid(file.pageCount!)) {
        return ValidationResult.failure(PdfOperationError.invalidPageRange);
      }
    }

    return ValidationResult.success();
  }

  /// Validate file for password protection
  ValidationResult validateProtect(PdfFileInfo file, String password) {
    // Validate the file itself
    final fileValidation = _validateSingleFile(file);
    if (!fileValidation.isValid) {
      return fileValidation;
    }

    // Validate password strength
    if (password.length < minPasswordLength) {
      return ValidationResult.failure(PdfOperationError.weakPassword);
    }

    return ValidationResult.success();
  }

  /// Validate a single PDF file
  ValidationResult _validateSingleFile(PdfFileInfo file) {
    // Check if file is valid PDF
    if (!file.isValid) {
      return ValidationResult.failure(PdfOperationError.invalidFile);
    }

    // Check file size
    if (!file.isWithinSizeLimit(maxFileSizeBytes)) {
      return ValidationResult.failure(PdfOperationError.fileTooLarge);
    }

    return ValidationResult.success();
  }

  /// Get formatted max file size for display
  String get formattedMaxFileSize {
    final mb = maxFileSizeBytes / (1024 * 1024);
    return '${mb.toStringAsFixed(0)} MB';
  }

  /// Check if file size is within limit (convenience method)
  bool isFileSizeValid(int sizeBytes) {
    return sizeBytes <= maxFileSizeBytes;
  }

  /// Check if merge count is valid (convenience method)
  bool isMergeCountValid(int fileCount) {
    return fileCount >= minMergeFiles && fileCount <= maxMergeFiles;
  }

  /// Check if password is valid (convenience method)
  bool isPasswordValid(String password) {
    return password.length >= minPasswordLength;
  }

  /// Get file size warning level for progressive warnings (Phase 7)
  /// Returns: 'none', 'large', 'very_large', or 'too_large'
  String getFileSizeWarningLevel(int sizeBytes) {
    if (sizeBytes > maxFileSizeBytes) {
      return 'too_large'; // Over 100MB
    } else if (sizeBytes > 50 * 1024 * 1024) {
      return 'very_large'; // 50-100MB: Warning about processing time
    } else if (sizeBytes > 10 * 1024 * 1024) {
      return 'large'; // 10-50MB: Show progress indicators
    }
    return 'none'; // Under 10MB: No warning
  }

  /// Check if operation requires progress indicator (>10MB)
  bool requiresProgressIndicator(int sizeBytes) {
    return sizeBytes > 10 * 1024 * 1024;
  }

  /// Get total size of multiple files
  int getTotalSize(List<PdfFileInfo> files) {
    return files.fold<int>(0, (sum, file) => sum + file.sizeBytes);
  }

  /// Check if total operation size is valid
  bool isTotalSizeValid(List<PdfFileInfo> files) {
    return getTotalSize(files) <= maxTotalOperationSize;
  }

  /// Advanced PDF integrity validation
  ///
  /// Performs deep validation including:
  /// 1. Magic byte check (PDF header: %PDF)
  /// 2. Corruption detection via page count extraction
  Future<ValidationResult> validatePdfIntegrity(PdfFileInfo file) async {
    // 1. Magic byte check
    if (!_hasPdfMagicBytes(file.bytes)) {
      return ValidationResult.failure(PdfOperationError.invalidFile);
    }

    // 2. Corruption detection - attempt to extract page count
    try {
      final pageCount = await _pdfLibBridge.getPageCount(file.bytes);
      if (pageCount <= 0) {
        return ValidationResult.failure(PdfOperationError.invalidFile);
      }
    } catch (e) {
      // If page count extraction fails, the PDF is likely corrupted
      return ValidationResult.failure(PdfOperationError.invalidFile);
    }

    return ValidationResult.success();
  }

  /// Check for PDF magic bytes (%PDF)
  ///
  /// All valid PDF files start with the bytes: 0x25 0x50 0x44 0x46 (%PDF)
  bool _hasPdfMagicBytes(Uint8List bytes) {
    if (bytes.length < 4) return false;

    // Check for "%PDF" (0x25 0x50 0x44 0x46)
    return bytes[0] == 0x25 && // %
        bytes[1] == 0x50 && // P
        bytes[2] == 0x44 && // D
        bytes[3] == 0x46; // F
  }

}
