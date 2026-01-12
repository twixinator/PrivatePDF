import '../models/pdf_file_info.dart';
import '../models/page_range.dart';
import '../models/pdf_operation_result.dart';
import '../models/pdf_operation_error.dart';
import '../core/js_interop/i_pdf_lib_bridge.dart';
import '../core/js_interop/pdf_lib_bridge.dart';
import 'file_validation_service.dart';
import 'pdf_service.dart';

/// Implementation of PdfService using pdf-lib via JavaScript interop
class PdfServiceImpl implements PdfService {
  final FileValidationService _validator;
  final IPdfLibBridge _pdfLibBridge;

  PdfServiceImpl({
    required FileValidationService validator,
    IPdfLibBridge? pdfLibBridge,
  })  : _validator = validator,
        _pdfLibBridge = pdfLibBridge ?? PdfLibBridge.instance;

  @override
  Future<PdfOperationResult> mergePdfs(List<PdfFileInfo> files) async {
    try {
      // 1. Validate files
      final validation = _validator.validateMerge(files);
      if (!validation.isValid) {
        return PdfOperationFailure(validation.error!);
      }

      // 2. Validate PDF integrity for all files
      for (final file in files) {
        final integrityCheck = await _validator.validatePdfIntegrity(file);
        if (!integrityCheck.isValid) {
          return PdfOperationFailure(integrityCheck.error!);
        }
      }

      // 3. Check if PDF-lib is available
      if (!_pdfLibBridge.isAvailable()) {
        return const PdfOperationFailure(PdfOperationError.jsInteropError);
      }

      // 4. Extract bytes from all files
      final bytesArray = files.map((f) => f.bytes).toList();

      // 5. Call JS bridge to merge PDFs with timeout
      final mergedBytes = await _withTimeout(
        _pdfLibBridge.mergePDFs(bytesArray),
        const Duration(seconds: 30),
      );

      // 6. Generate suggested filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final suggestedFileName = 'zusammengefuegt_$timestamp.pdf';

      // 7. Return success result
      return PdfOperationSuccess(
        pdfBytes: mergedBytes,
        suggestedFileName: suggestedFileName,
      );
    } on Exception catch (e) {
      // Map exception to domain error
      final error = _mapExceptionToError(e);
      return PdfOperationFailure(error);
    } catch (e) {
      // Catch-all for unexpected errors
      print('[PdfServiceImpl] Unexpected error in mergePdfs: $e');
      return const PdfOperationFailure(PdfOperationError.unknown);
    }
  }

  @override
  Future<PdfOperationResult> splitPdf(
    PdfFileInfo file,
    PageRange range,
  ) async {
    try {
      // 1. Get page count first if not available
      PdfFileInfo fileWithPages = file;
      if (file.pageCount == null) {
        final pageCount = await _pdfLibBridge.getPageCount(file.bytes);
        fileWithPages = file.copyWithPageCount(pageCount);
      }

      // 2. Validate file and range
      final validation = _validator.validateSplit(fileWithPages, range);
      if (!validation.isValid) {
        return PdfOperationFailure(validation.error!);
      }

      // 3. Validate PDF integrity
      final integrityCheck = await _validator.validatePdfIntegrity(fileWithPages);
      if (!integrityCheck.isValid) {
        return PdfOperationFailure(integrityCheck.error!);
      }

      // 4. Check if PDF-lib is available
      if (!_pdfLibBridge.isAvailable()) {
        return const PdfOperationFailure(PdfOperationError.jsInteropError);
      }

      // 5. Convert page range to 0-indexed for pdf-lib
      final zeroIndexedPages = range.toZeroIndexed();

      // 6. Call JS bridge to split PDF with timeout
      final splitBytes = await _withTimeout(
        _pdfLibBridge.splitPDF(fileWithPages.bytes, zeroIndexedPages),
        const Duration(seconds: 30),
      );

      // 7. Generate suggested filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final baseName = file.name.replaceAll('.pdf', '');
      final suggestedFileName = '${baseName}_seiten_${range.formatted}_$timestamp.pdf';

      // 8. Return success result
      return PdfOperationSuccess(
        pdfBytes: splitBytes,
        suggestedFileName: suggestedFileName,
      );
    } on Exception catch (e) {
      final error = _mapExceptionToError(e);
      return PdfOperationFailure(error);
    } catch (e) {
      print('[PdfServiceImpl] Unexpected error in splitPdf: $e');
      return const PdfOperationFailure(PdfOperationError.unknown);
    }
  }

  @override
  Future<PdfOperationResult> protectPdf(
    PdfFileInfo file,
    String password,
  ) async {
    try {
      // 1. Validate file and password
      final validation = _validator.validateProtect(file, password);
      if (!validation.isValid) {
        return PdfOperationFailure(validation.error!);
      }

      // 2. Validate PDF integrity
      final integrityCheck = await _validator.validatePdfIntegrity(file);
      if (!integrityCheck.isValid) {
        return PdfOperationFailure(integrityCheck.error!);
      }

      // 3. Check if PDF-lib is available
      if (!_pdfLibBridge.isAvailable()) {
        return const PdfOperationFailure(PdfOperationError.jsInteropError);
      }

      // 4. Call JS bridge to protect PDF with timeout
      final protectedBytes = await _withTimeout(
        _pdfLibBridge.protectPDF(file.bytes, password),
        const Duration(seconds: 30),
      );

      // 5. Generate suggested filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final baseName = file.name.replaceAll('.pdf', '');
      final suggestedFileName = '${baseName}_geschuetzt_$timestamp.pdf';

      // 6. Return success result
      return PdfOperationSuccess(
        pdfBytes: protectedBytes,
        suggestedFileName: suggestedFileName,
      );
    } on Exception catch (e) {
      final error = _mapExceptionToError(e);
      return PdfOperationFailure(error);
    } catch (e) {
      print('[PdfServiceImpl] Unexpected error in protectPdf: $e');
      return const PdfOperationFailure(PdfOperationError.unknown);
    }
  }

  /// Map JavaScript/Exception to domain error
  PdfOperationError _mapExceptionToError(Exception exception) {
    final message = exception.toString().toLowerCase();

    if (message.contains('invalid pdf') || message.contains('failed to load')) {
      return PdfOperationError.invalidFile;
    } else if (message.contains('password')) {
      return PdfOperationError.weakPassword;
    } else if (message.contains('page number') || message.contains('page range')) {
      return PdfOperationError.invalidPageRange;
    } else if (message.contains('not loaded') || message.contains('undefined')) {
      return PdfOperationError.jsInteropError;
    } else if (message.contains('save') || message.contains('saving')) {
      return PdfOperationError.savingFailed;
    }

    return PdfOperationError.unknown;
  }

  /// 🔒 SECURITY: Wrap operation with timeout to prevent hanging
  Future<T> _withTimeout<T>(
    Future<T> operation,
    Duration timeout,
  ) async {
    try {
      return await operation.timeout(
        timeout,
        onTimeout: () {
          throw Exception('Operation timed out after ${timeout.inSeconds} seconds');
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
