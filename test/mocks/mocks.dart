import 'package:mockito/annotations.dart';
import 'package:privatpdf/services/pdf_service.dart';
import 'package:privatpdf/services/file_validation_service.dart';
import 'package:privatpdf/services/download_service.dart';
import 'package:privatpdf/services/analytics_service.dart';
import 'package:privatpdf/services/operation_queue_service.dart';
import 'package:privatpdf/services/network_verification_service.dart';
import 'package:privatpdf/services/memory_management_service.dart';
import 'package:privatpdf/core/js_interop/i_pdf_lib_bridge.dart';

/// Mock generation for all testable services
///
/// Run this command to generate mocks:
/// flutter pub run build_runner build --delete-conflicting-outputs
///
/// This will generate test/mocks/mocks.mocks.dart with all mock classes
@GenerateMocks([
  PdfService,
  FileValidationService,
  DownloadService,
  AnalyticsProvider,
  OperationQueueService,
  NetworkVerificationService,
  MemoryManagementService,
  IPdfLibBridge, // Mock the interface, not the implementation
])
void main() {}
