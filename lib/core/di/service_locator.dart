import 'package:get_it/get_it.dart';
import '../../config/environment.dart';
import '../../services/file_validation_service.dart';
import '../../services/pdf_service.dart';
import '../../services/pdf_service_impl.dart';
import '../../services/file_picker_service.dart';
import '../../services/download_service.dart';
import '../../services/memory_management_service.dart';
import '../../services/analytics_service.dart';
import '../../services/event_logger_service.dart';
import '../../services/operation_queue_service.dart';
import '../../services/network_verification_service.dart';

/// Global service locator instance
final getIt = GetIt.instance;

/// Setup dependency injection
/// Call this once during app initialization
void setupServiceLocator() {
  // Memory Management Service - Singleton
  getIt.registerLazySingleton<MemoryManagementService>(
    () => MemoryManagementService(),
  );

  // Analytics Service - Singleton
  getIt.registerLazySingleton<AnalyticsProvider>(
    () => EventLoggerService(),
  );

  // Operation Queue Service - Singleton
  getIt.registerLazySingleton<OperationQueueService>(
    () => OperationQueueService(),
  );

  // Network Verification Service - Singleton
  getIt.registerLazySingleton<NetworkVerificationService>(
    () => NetworkVerificationService(),
  );

  // Validation Service - Singleton
  getIt.registerLazySingleton<FileValidationService>(
    () => FileValidationService(
      maxFileSizeBytes: Environment.maxFileSizeFree,
      minMergeFiles: Environment.minMergeFiles,
      maxMergeFiles: Environment.maxMergeFilesFree,
      minPasswordLength: Environment.minPasswordLength,
    ),
  );

  // PDF Service - Singleton
  // Uses the validation service via dependency injection
  getIt.registerLazySingleton<PdfService>(
    () => PdfServiceImpl(
      validator: getIt<FileValidationService>(),
    ),
  );

  // File Picker Service - Singleton
  getIt.registerLazySingleton<FilePickerService>(
    () => FilePickerService(),
  );

  // Download Service - Singleton with memory tracking
  getIt.registerLazySingleton<DownloadService>(
    () => DownloadService(
      memoryService: getIt<MemoryManagementService>(),
    ),
  );

  print('[ServiceLocator] Services registered successfully');
  print('  - MemoryManagementService');
  print('  - AnalyticsProvider (EventLoggerService)');
  print('  - OperationQueueService');
  print('  - NetworkVerificationService');
  print('  - FileValidationService');
  print('  - PdfService');
  print('  - FilePickerService');
  print('  - DownloadService');
  Environment.printConfig();
}

/// Reset the service locator (useful for testing)
Future<void> resetServiceLocator() async {
  await getIt.reset();
  print('[ServiceLocator] Services reset');
}
