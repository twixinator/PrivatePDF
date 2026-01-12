# Clean Architecture Implementation Plan - PrivatPDF

**Status: ✅ FULLY IMPLEMENTED (2026-01-10)**

## Overview

This document outlines the complete clean architecture implementation for PrivatPDF's PDF processing features using pdf-lib. The architecture follows SOLID principles with clear separation of concerns across multiple layers.

**Implementation completed successfully with all 10 phases done, production build ready for deployment.**

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Technology Stack](#technology-stack)
3. [Layer Structure](#layer-structure)
4. [Component Design](#component-design)
5. [Implementation Phases](#implementation-phases)
6. [File Structure](#file-structure)
7. [Data Flow](#data-flow)
8. [Testing Strategy](#testing-strategy)
9. [Timeline & Estimates](#timeline--estimates)

---

## Architecture Overview

### Design Philosophy

**Layered Clean Architecture** with Flutter Provider for dependency injection:

```
┌─────────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                       │
│  (Screens: Merge, Split, Protect)                           │
└────────────────┬────────────────────────────────────────────┘
                 │ context.watch/read
┌────────────────┴────────────────────────────────────────────┐
│                   PROVIDER LAYER                             │
│  (State Management: PdfOperationProvider, FileListProvider) │
└────────────────┬────────────────────────────────────────────┘
                 │ uses (via GetIt)
┌────────────────┴────────────────────────────────────────────┐
│                    SERVICE LAYER                             │
│  (Business Logic: PdfService, ValidationService)            │
└────────────────┬────────────────────────────────────────────┘
                 │ uses
┌────────────────┴────────────────────────────────────────────┐
│                  JS INTEROP LAYER                            │
│  (PdfLibBridge - Dart ↔ JavaScript communication)          │
└────────────────┬────────────────────────────────────────────┘
                 │ dart:js
┌────────────────┴────────────────────────────────────────────┐
│                  JAVASCRIPT LAYER                            │
│  (pdf-lib wrapper: PDFLibProcessor)                         │
└─────────────────────────────────────────────────────────────┘
```

### Key Principles

1. **Separation of Concerns**: Each layer has a single responsibility
2. **Dependency Inversion**: High-level modules don't depend on low-level modules
3. **Testability**: Every layer can be unit tested with mocks
4. **Scalability**: Easy to add authentication, payment, new features
5. **Maintainability**: Clear boundaries make changes predictable

---

## Technology Stack

### Core Dependencies

```yaml
dependencies:
  flutter: sdk

  # Existing
  go_router: ^13.0.0
  provider: ^6.1.1
  file_picker: ^6.1.1
  intl: ^0.19.0
  url_launcher: ^6.2.3

  # NEW - JavaScript Interop
  js: ^0.6.7

  # NEW - Dependency Injection
  get_it: ^7.6.4

  # NEW - Native Drag & Drop
  desktop_drop: ^0.4.4

dev_dependencies:
  flutter_test: sdk
  flutter_lints: ^3.0.1

  # NEW - Testing
  mockito: ^5.4.4
  build_runner: ^2.4.6
```

### External Libraries

- **pdf-lib** (v1.17.1) - JavaScript PDF manipulation library (loaded via CDN)

---

## Layer Structure

### Layer 1: Domain Models (`lib/models/`)

**Purpose**: Immutable data structures representing business entities

#### Files to Create:

1. **`pdf_file_info.dart`**
```dart
class PdfFileInfo {
  final String id;
  final String name;
  final int sizeBytes;
  final Uint8List bytes;
  final int? pageCount;

  // Factory constructors
  factory PdfFileInfo.fromPlatformFile(PlatformFile file);

  // Computed properties
  String get formattedSize;
  bool get isValid;
}
```

2. **`pdf_operation_result.dart`**
```dart
sealed class PdfOperationResult {
  const PdfOperationResult();

  // Pattern matching support
  T when<T>({
    required T Function(Uint8List, String) success,
    required T Function(PdfOperationError) failure,
  });
}

class PdfOperationSuccess extends PdfOperationResult {
  final Uint8List pdfBytes;
  final String suggestedFileName;
}

class PdfOperationFailure extends PdfOperationResult {
  final PdfOperationError error;
}
```

3. **`pdf_operation_error.dart`**
```dart
enum PdfOperationError {
  invalidFile,
  fileTooLarge,
  insufficientPages,
  invalidPageRange,
  encryptionFailed,
  jsInteropError,
  unknown;

  // German error messages
  String get message;
}
```

4. **`page_range.dart`**
```dart
class PageRange {
  final List<int> pages;

  // Factory from string: "1-3,5,7-9"
  factory PageRange.parse(String input, int maxPages);

  // Validation
  bool isValid(int totalPages);
  String get formatted; // "1-3, 5, 7-9"
}
```

5. **`validation_result.dart`**
```dart
class ValidationResult {
  final bool isValid;
  final PdfOperationError? error;

  factory ValidationResult.success();
  factory ValidationResult.failure(PdfOperationError error);
}
```

---

### Layer 2: JavaScript Interop Bridge (`lib/core/js_interop/`)

**Purpose**: Isolate all JavaScript interop complexity

#### Files to Create:

1. **`pdf_lib_bridge.dart`**
```dart
@JS()
library pdf_lib_bridge;

import 'dart:js_util' as js_util;
import 'package:js/js.dart';

@JS('PDFLibProcessor.mergePDFs')
external Object _mergePDFs(List<Uint8List> pdfBytes);

@JS('PDFLibProcessor.splitPDF')
external Object _splitPDF(Uint8List pdfBytes, List<int> pageNumbers);

@JS('PDFLibProcessor.protectPDF')
external Object _protectPDF(Uint8List pdfBytes, String password);

class PdfLibBridge {
  /// Merge multiple PDFs into one
  static Future<Uint8List> mergePDFs(List<Uint8List> pdfFiles) async {
    final promise = _mergePDFs(pdfFiles);
    final result = await js_util.promiseToFuture(promise);
    return Uint8List.fromList(result);
  }

  /// Split PDF by extracting specific pages
  static Future<Uint8List> splitPDF(
    Uint8List pdfBytes,
    List<int> pageNumbers,
  ) async {
    final promise = _splitPDF(pdfBytes, pageNumbers);
    final result = await js_util.promiseToFuture(promise);
    return Uint8List.fromList(result);
  }

  /// Protect PDF with password encryption
  static Future<Uint8List> protectPDF(
    Uint8List pdfBytes,
    String password,
  ) async {
    final promise = _protectPDF(pdfBytes, password);
    final result = await js_util.promiseToFuture(promise);
    return Uint8List.fromList(result);
  }
}
```

2. **`web/js/pdf_lib_processor.js`** (JavaScript file)
```javascript
import { PDFDocument } from 'https://cdn.skypack.dev/pdf-lib@1.17.1';

window.PDFLibProcessor = {
  async mergePDFs(pdfBytesArray) {
    const mergedPdf = await PDFDocument.create();

    for (const pdfBytes of pdfBytesArray) {
      const pdf = await PDFDocument.load(pdfBytes);
      const copiedPages = await mergedPdf.copyPages(pdf, pdf.getPageIndices());
      copiedPages.forEach((page) => mergedPdf.addPage(page));
    }

    return await mergedPdf.save();
  },

  async splitPDF(pdfBytes, pageNumbers) {
    const pdfDoc = await PDFDocument.load(pdfBytes);
    const newPdf = await PDFDocument.create();
    const pages = await newPdf.copyPages(pdfDoc, pageNumbers);
    pages.forEach(page => newPdf.addPage(page));
    return await newPdf.save();
  },

  async protectPDF(pdfBytes, password) {
    const pdfDoc = await PDFDocument.load(pdfBytes);
    pdfDoc.encrypt({
      userPassword: password,
      ownerPassword: password,
      permissions: {
        printing: 'highResolution',
        modifying: false,
        copying: false,
      }
    });
    return await pdfDoc.save();
  }
};
```

---

### Layer 3: Service Layer (`lib/services/`)

**Purpose**: Business logic and orchestration

#### Files to Create:

1. **`pdf_service.dart`** (Interface)
```dart
abstract class PdfService {
  Future<PdfOperationResult> mergePdfs(List<PdfFileInfo> files);
  Future<PdfOperationResult> splitPdf(PdfFileInfo file, PageRange range);
  Future<PdfOperationResult> protectPdf(PdfFileInfo file, String password);
}
```

2. **`pdf_service_impl.dart`** (Implementation)
```dart
class PdfServiceImpl implements PdfService {
  final FileValidationService _validator;
  final PdfLibBridge _bridge;

  PdfServiceImpl({
    required FileValidationService validator,
    required PdfLibBridge bridge,
  }) : _validator = validator,
       _bridge = bridge;

  @override
  Future<PdfOperationResult> mergePdfs(List<PdfFileInfo> files) async {
    try {
      // 1. Validate files
      final validation = _validator.validateMerge(files);
      if (!validation.isValid) {
        return PdfOperationFailure(validation.error!);
      }

      // 2. Extract bytes
      final bytesArray = files.map((f) => f.bytes).toList();

      // 3. Call JS bridge
      final mergedBytes = await _bridge.mergePDFs(bytesArray);

      // 4. Return result
      return PdfOperationSuccess(
        pdfBytes: mergedBytes,
        suggestedFileName: 'merged_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
    } catch (e) {
      return PdfOperationFailure(_mapError(e));
    }
  }

  // Similar implementations for split and protect

  PdfOperationError _mapError(dynamic error) {
    // Map JavaScript errors to domain errors
    if (error is JsError) {
      if (error.message.contains('Invalid PDF')) {
        return PdfOperationError.invalidFile;
      }
      return PdfOperationError.jsInteropError;
    }
    return PdfOperationError.unknown;
  }
}
```

3. **`file_validation_service.dart`**
```dart
class FileValidationService {
  final int maxFileSizeBytes;

  FileValidationService({
    this.maxFileSizeBytes = 5 * 1024 * 1024, // 5MB default
  });

  ValidationResult validateMerge(List<PdfFileInfo> files) {
    if (files.length < 2) {
      return ValidationResult.failure(PdfOperationError.insufficientFiles);
    }
    if (files.length > 10) {
      return ValidationResult.failure(PdfOperationError.tooManyFiles);
    }

    for (final file in files) {
      if (file.sizeBytes > maxFileSizeBytes) {
        return ValidationResult.failure(PdfOperationError.fileTooLarge);
      }
    }

    return ValidationResult.success();
  }

  ValidationResult validateSplit(PdfFileInfo file, PageRange range) {
    // Validation logic
  }

  ValidationResult validateProtect(PdfFileInfo file, String password) {
    if (password.length < 6) {
      return ValidationResult.failure(PdfOperationError.weakPassword);
    }
    return ValidationResult.success();
  }
}
```

4. **`file_picker_service.dart`**
```dart
class FilePickerService {
  Future<List<PdfFileInfo>> pickMultiplePdfs() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
      withData: true,
    );

    if (result == null) return [];

    return result.files
        .where((file) => file.bytes != null)
        .map((file) => PdfFileInfo.fromPlatformFile(file))
        .toList();
  }

  Future<PdfFileInfo?> pickSinglePdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return null;

    final file = result.files.first;
    return file.bytes != null
        ? PdfFileInfo.fromPlatformFile(file)
        : null;
  }
}
```

5. **`download_service.dart`**
```dart
import 'dart:html' as html;
import 'dart:typed_data';

class DownloadService {
  void downloadPdf(Uint8List bytes, String fileName) {
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();

    html.Url.revokeObjectUrl(url);
  }
}
```

---

### Layer 4: State Management (`lib/providers/`)

**Purpose**: Application state and UI reactivity

#### Files to Create:

1. **`pdf_operation_state.dart`**
```dart
sealed class PdfOperationState {
  const PdfOperationState();

  factory PdfOperationState.idle() = IdleState;
  factory PdfOperationState.processing() = ProcessingState;
  factory PdfOperationState.success(String fileName) = SuccessState;
  factory PdfOperationState.error(PdfOperationError error) = ErrorState;

  // Pattern matching
  T when<T>({
    required T Function() idle,
    required T Function() processing,
    required T Function(String fileName) success,
    required T Function(PdfOperationError error) error,
  });
}

class IdleState extends PdfOperationState {
  const IdleState();
}

class ProcessingState extends PdfOperationState {
  const ProcessingState();
}

class SuccessState extends PdfOperationState {
  final String fileName;
  const SuccessState(this.fileName);
}

class ErrorState extends PdfOperationState {
  final PdfOperationError error;
  const ErrorState(this.error);
}
```

2. **`pdf_operation_provider.dart`**
```dart
class PdfOperationProvider extends ChangeNotifier {
  final PdfService _pdfService;
  final DownloadService _downloadService;

  PdfOperationState _state = const IdleState();
  PdfOperationState get state => _state;

  PdfOperationProvider({
    required PdfService pdfService,
    required DownloadService downloadService,
  }) : _pdfService = pdfService,
       _downloadService = downloadService;

  Future<void> mergePdfs(List<PdfFileInfo> files) async {
    _setState(const ProcessingState());

    final result = await _pdfService.mergePdfs(files);

    result.when(
      success: (bytes, fileName) {
        _downloadService.downloadPdf(bytes, fileName);
        _setState(SuccessState(fileName));
      },
      failure: (error) {
        _setState(ErrorState(error));
      },
    );
  }

  Future<void> splitPdf(PdfFileInfo file, PageRange range) async {
    // Similar implementation
  }

  Future<void> protectPdf(PdfFileInfo file, String password) async {
    // Similar implementation
  }

  void reset() {
    _state = const IdleState();
    notifyListeners();
  }

  void _setState(PdfOperationState newState) {
    _state = newState;
    notifyListeners();
  }
}
```

3. **`file_list_provider.dart`**
```dart
class FileListProvider extends ChangeNotifier {
  List<PdfFileInfo> _files = [];

  List<PdfFileInfo> get files => List.unmodifiable(_files);
  int get fileCount => _files.length;
  int get totalSizeBytes => _files.fold(0, (sum, f) => sum + f.sizeBytes);
  bool get canMerge => _files.length >= 2 && _files.length <= 10;

  void addFiles(List<PdfFileInfo> newFiles) {
    final available = 10 - _files.length;
    _files.addAll(newFiles.take(available));
    notifyListeners();
  }

  void removeFile(String fileId) {
    _files.removeWhere((f) => f.id == fileId);
    notifyListeners();
  }

  void reorderFiles(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final file = _files.removeAt(oldIndex);
    _files.insert(newIndex, file);
    notifyListeners();
  }

  void clear() {
    _files.clear();
    notifyListeners();
  }
}
```

---

### Layer 5: Dependency Injection (`lib/core/di/`)

**Purpose**: Service locator and dependency management

#### Files to Create:

1. **`service_locator.dart`**
```dart
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Core Services (Singletons)
  getIt.registerLazySingleton<PdfLibBridge>(() => PdfLibBridge());

  getIt.registerLazySingleton<FileValidationService>(
    () => FileValidationService(
      maxFileSizeBytes: 5 * 1024 * 1024, // 5MB for free tier
    ),
  );

  getIt.registerLazySingleton<PdfService>(
    () => PdfServiceImpl(
      validator: getIt<FileValidationService>(),
      bridge: getIt<PdfLibBridge>(),
    ),
  );

  getIt.registerLazySingleton<FilePickerService>(
    () => FilePickerService(),
  );

  getIt.registerLazySingleton<DownloadService>(
    () => DownloadService(),
  );
}
```

---

### Layer 6: Presentation (`lib/screens/` and `lib/widgets/`)

**Purpose**: User interface and interaction

#### Widgets to Create:

1. **`lib/widgets/pdf_drop_zone.dart`**
```dart
class PdfDropZone extends StatefulWidget {
  final Function(List<PdfFileInfo>) onFilesSelected;
  final bool allowMultiple;

  const PdfDropZone({
    super.key,
    required this.onFilesSelected,
    this.allowMultiple = true,
  });

  @override
  State<PdfDropZone> createState() => _PdfDropZoneState();
}

class _PdfDropZoneState extends State<PdfDropZone> {
  bool _isDragOver = false;

  @override
  Widget build(BuildContext context) {
    final filePicker = context.read<FilePickerService>();

    return DropTarget(
      onDragEntered: (_) => setState(() => _isDragOver = true),
      onDragExited: (_) => setState(() => _isDragOver = false),
      onDragDone: (details) async {
        setState(() => _isDragOver = false);
        final files = await _processDroppedFiles(details.files);
        widget.onFilesSelected(files);
      },
      child: GestureDetector(
        onTap: () async {
          final files = widget.allowMultiple
              ? await filePicker.pickMultiplePdfs()
              : [(await filePicker.pickSinglePdf())].whereType<PdfFileInfo>().toList();
          widget.onFilesSelected(files);
        },
        child: _buildDropZoneUI(context),
      ),
    );
  }

  Widget _buildDropZoneUI(BuildContext context) {
    // Use existing design from merge_page.dart
  }
}
```

2. **`lib/widgets/reorderable_file_list.dart`**
3. **`lib/widgets/merge_action_bar.dart`**
4. **`lib/widgets/operation_overlay.dart`**

#### Screens to Create/Modify:

1. **`lib/screens/merge_page.dart`** (Refactored)
```dart
class MergePage extends StatelessWidget {
  const MergePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FileListProvider()),
        ChangeNotifierProvider(
          create: (context) => PdfOperationProvider(
            pdfService: getIt<PdfService>(),
            downloadService: getIt<DownloadService>(),
          ),
        ),
      ],
      child: const _MergePageContent(),
    );
  }
}

class _MergePageContent extends StatelessWidget {
  const _MergePageContent();

  @override
  Widget build(BuildContext context) {
    final fileList = context.watch<FileListProvider>();
    final operation = context.watch<PdfOperationProvider>();

    return Scaffold(
      appBar: const AppHeader(),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context),
                PdfDropZone(
                  onFilesSelected: (files) => fileList.addFiles(files),
                ),
                if (fileList.files.isNotEmpty)
                  ReorderableFileList(
                    files: fileList.files,
                    onRemove: fileList.removeFile,
                    onReorder: fileList.reorderFiles,
                  ),
                if (fileList.canMerge)
                  MergeActionBar(
                    onMerge: () => operation.mergePdfs(fileList.files),
                    onClear: fileList.clear,
                    canMerge: operation.state is! ProcessingState,
                  ),
              ],
            ),
          ),
          _buildOperationOverlay(context, operation.state),
        ],
      ),
    );
  }
}
```

2. **`lib/screens/split_page.dart`** (New)
3. **`lib/screens/protect_page.dart`** (New)

---

## Implementation Phases

**🎉 ALL PHASES COMPLETED - MVP PRODUCTION-READY (2026-01-10)**

All 10 implementation phases have been successfully completed. The PrivatPDF MVP is fully functional with clean architecture, all three core features (Merge, Split, Protect), and a production build ready for deployment.

**Implementation Summary:**
- ✅ 26 new files created
- ✅ 5 files modified
- ✅ ~2,500+ lines of code
- ✅ Production build successful
- ✅ All features tested and working
- ✅ App successfully running in Chrome (dev mode)
- ✅ Loading screen issue resolved (flutter_bootstrap.js integration)

**Latest Updates:**
- **2026-01-10 08:30**: Fixed web initialization issue in `web/index.html` by switching to `flutter_bootstrap.js` (modern Flutter web API)
- **2026-01-10 08:35**: Successfully tested app launch in Chrome browser - all features loading correctly

---

### Phase 1: Foundation (Day 1-2) ✅ COMPLETED

**Goal**: Setup infrastructure, no PDF processing yet

**Tasks**:
- [x] Update `pubspec.yaml` with dependencies
- [x] Run `flutter pub get`
- [x] Create directory structure
- [x] Create domain models (5 files)
- [x] Write unit tests for models
- [x] **Verification**: Models instantiate correctly, tests pass

**Files Created**:
- `lib/models/pdf_file_info.dart`
- `lib/models/pdf_operation_result.dart`
- `lib/models/pdf_operation_error.dart`
- `lib/models/page_range.dart`
- `lib/models/validation_result.dart`
- `test/models/` (test files)

---

### Phase 2: JavaScript Bridge (Day 2-3) ✅ COMPLETED

**Goal**: Establish JS interop, test with simple merge

**Tasks**:
- [x] Create `web/js/pdf_lib_processor.js`
- [x] Implement `PDFLibProcessor.mergePDFs` only
- [x] Create `lib/core/js_interop/pdf_lib_bridge.dart`
- [x] Implement `PdfLibBridge.mergePDFs`
- [x] Update `web/index.html` to include script tag
- [x] Create integration test
- [x] **Verification**: Bridge works, merged PDF downloads

**Files Created**:
- `web/js/pdf_lib_processor.js`
- `lib/core/js_interop/pdf_lib_bridge.dart`
- `test/integration/js_bridge_test.dart`

**Files Modified**:
- `web/index.html` (add script tag)

---

### Phase 3: Service Layer (Day 3-4) ✅ COMPLETED

**Goal**: Implement business logic with proper error handling

**Tasks**:
- [x] Create `file_validation_service.dart`
- [x] Create `pdf_service.dart` interface
- [x] Create `pdf_service_impl.dart`
- [x] Create `file_picker_service.dart`
- [x] Create `download_service.dart`
- [x] Write unit tests with mocks
- [x] **Verification**: Service tests pass

**Files Created**:
- `lib/services/file_validation_service.dart`
- `lib/services/pdf_service.dart`
- `lib/services/pdf_service_impl.dart`
- `lib/services/file_picker_service.dart`
- `lib/services/download_service.dart`
- `test/services/` (test files)

---

### Phase 4: State Management (Day 4-5) ✅ COMPLETED

**Goal**: Provider setup, UI state management

**Tasks**:
- [x] Create `pdf_operation_state.dart` sealed classes
- [x] Create `pdf_operation_provider.dart`
- [x] Create `file_list_provider.dart`
- [x] Setup `service_locator.dart`
- [x] Update `main.dart` with providers
- [x] **Verification**: Providers accessible via context

**Files Created**:
- `lib/providers/pdf_operation_state.dart`
- `lib/providers/pdf_operation_provider.dart`
- `lib/providers/file_list_provider.dart`
- `lib/core/di/service_locator.dart`

**Files Modified**:
- `lib/main.dart`

---

### Phase 5: UI Widgets (Day 5-6) ✅ COMPLETED

**Goal**: Refactor UI into clean, reusable components

**Tasks**:
- [x] Create `pdf_drop_zone.dart`
- [x] Create `reorderable_file_list.dart`
- [x] Create `merge_action_bar.dart`
- [x] Create `operation_overlay.dart`
- [x] **Verification**: Widgets render correctly

**Files Created**:
- `lib/widgets/pdf_drop_zone.dart`
- `lib/widgets/reorderable_file_list.dart`
- `lib/widgets/merge_action_bar.dart`
- `lib/widgets/operation_overlay.dart`

---

### Phase 6: Merge Page Integration (Day 6-7) ✅ COMPLETED

**Goal**: Complete merge feature end-to-end

**Tasks**:
- [x] Refactor `merge_page.dart`
- [x] Remove local state, use providers
- [x] Wire up all widgets
- [x] Test full merge flow
- [x] Test error cases
- [x] **Verification**: Merge works perfectly

**Files Modified**:
- `lib/screens/merge_page.dart`

---

### Phase 7: Split Page (Day 7-8) ✅ COMPLETED

**Goal**: Implement split feature

**Tasks**:
- [x] Create `page_range.dart` model
- [x] Add `splitPDF` to `pdf_lib_processor.js`
- [x] Add `splitPDF` to `pdf_lib_bridge.dart`
- [x] Update `pdf_service.dart`
- [x] Update `file_validation_service.dart`
- [x] Create `split_page.dart`
- [x] **Verification**: Can split PDF by page ranges

**Files Created**:
- `lib/screens/split_page.dart`

**Files Modified**:
- `web/js/pdf_lib_processor.js`
- `lib/core/js_interop/pdf_lib_bridge.dart`
- `lib/services/pdf_service_impl.dart`
- `lib/main.dart` (route)

---

### Phase 8: Protect Page (Day 8-9) ✅ COMPLETED

**Goal**: Implement password protection

**Tasks**:
- [x] Add `protectPDF` to `pdf_lib_processor.js`
- [x] Add `protectPDF` to `pdf_lib_bridge.dart`
- [x] Update `pdf_service.dart`
- [x] Update `file_validation_service.dart`
- [x] Create `protect_page.dart`
- [x] **Verification**: Can protect PDF with password

**Files Created**:
- `lib/screens/protect_page.dart`

**Files Modified**:
- `web/js/pdf_lib_processor.js`
- `lib/core/js_interop/pdf_lib_bridge.dart`
- `lib/services/pdf_service_impl.dart`
- `lib/main.dart` (route)

---

### Phase 9: Testing & Polish (Day 9-10) ✅ COMPLETED

**Goal**: Comprehensive testing, error handling

**Tasks**:
- [x] Write integration tests
- [x] Write widget tests
- [x] Add error handling
- [x] Add loading states
- [x] Accessibility improvements
- [x] **Verification**: All tests pass

**Files Created**:
- `test/integration/merge_flow_test.dart`
- `test/integration/split_flow_test.dart`
- `test/integration/protect_flow_test.dart`
- `test/widgets/` (multiple test files)

---

### Phase 10: Production Ready (Day 10) ✅ COMPLETED

**Goal**: Documentation, performance, deployment

**Tasks**:
- [x] Update CLAUDE.md with architecture docs
- [x] Create `docs/ARCHITECTURE.md`
- [x] Performance optimization
- [x] Update router for new pages
- [x] Build for production
- [x] Test in production
- [x] **Verification**: App ready for deployment

**Files Created**:
- `docs/ARCHITECTURE.md`

**Files Modified**:
- `CLAUDE.md`
- `lib/main.dart`

---

## File Structure

```
R:\VS Code Projekte\PrivatePDF/
├── lib/
│   ├── core/
│   │   ├── di/
│   │   │   └── service_locator.dart
│   │   └── js_interop/
│   │       └── pdf_lib_bridge.dart
│   ├── models/
│   │   ├── pdf_file_info.dart
│   │   ├── pdf_operation_result.dart
│   │   ├── pdf_operation_error.dart
│   │   ├── page_range.dart
│   │   └── validation_result.dart
│   ├── services/
│   │   ├── pdf_service.dart
│   │   ├── pdf_service_impl.dart
│   │   ├── file_validation_service.dart
│   │   ├── file_picker_service.dart
│   │   └── download_service.dart
│   ├── providers/
│   │   ├── pdf_operation_state.dart
│   │   ├── pdf_operation_provider.dart
│   │   └── file_list_provider.dart
│   ├── screens/
│   │   ├── merge_page.dart (modified)
│   │   ├── split_page.dart (new)
│   │   └── protect_page.dart (new)
│   ├── widgets/
│   │   ├── pdf_drop_zone.dart
│   │   ├── reorderable_file_list.dart
│   │   ├── merge_action_bar.dart
│   │   └── operation_overlay.dart
│   └── main.dart (modified)
├── web/
│   ├── js/
│   │   └── pdf_lib_processor.js (new)
│   └── index.html (modified)
├── test/
│   ├── models/
│   ├── services/
│   ├── integration/
│   └── widgets/
└── pubspec.yaml (modified)
```

**Summary**:
- **New Files**: 26
- **Modified Files**: 5
- **Total Lines of Code**: ~2,500+

---

## Data Flow

### Complete Merge Flow Example

```
1. USER ACTION
   User drops/clicks to select PDF files
   ↓
2. UI LAYER (PdfDropZone widget)
   Captures files, converts to PdfFileInfo objects
   ↓
3. STATE LAYER (FileListProvider)
   Adds files to list, triggers UI rebuild
   ↓
4. USER ACTION
   User clicks "Zusammenführen" button
   ↓
5. STATE LAYER (PdfOperationProvider)
   Sets state to ProcessingState
   Calls PdfService.mergePdfs()
   ↓
6. SERVICE LAYER (PdfServiceImpl)
   Validates files via FileValidationService
   Extracts Uint8List bytes
   Calls PdfLibBridge.mergePDFs()
   ↓
7. JS INTEROP LAYER (PdfLibBridge)
   Converts Dart types to JavaScript
   Calls window.PDFLibProcessor.mergePDFs()
   ↓
8. JAVASCRIPT LAYER (pdf_lib_processor.js)
   Uses pdf-lib to merge PDFs
   Returns Promise<Uint8Array>
   ↓
9. JS INTEROP LAYER (PdfLibBridge)
   Converts JavaScript Promise to Dart Future
   Converts Uint8Array to Uint8List
   ↓
10. SERVICE LAYER (PdfServiceImpl)
    Wraps result in PdfOperationSuccess
    Returns to provider
    ↓
11. STATE LAYER (PdfOperationProvider)
    Calls DownloadService.downloadPdf()
    Sets state to SuccessState
    Notifies listeners
    ↓
12. UI LAYER (MergePage)
    Rebuilds via context.watch
    Shows SuccessOverlay
    ↓
13. BROWSER
    Downloads merged PDF file
```

---

## Testing Strategy

### Unit Tests

**Models** (`test/models/`):
- Test immutability
- Test factory constructors
- Test computed properties
- Test validation logic

**Services** (`test/services/`):
- Mock dependencies (PdfLibBridge, FileValidationService)
- Test success paths
- Test error handling
- Test edge cases

**Providers** (`test/providers/`):
- Test state transitions
- Test notifyListeners calls
- Test business logic

### Integration Tests

**JS Bridge** (`test/integration/js_bridge_test.dart`):
- Test actual pdf-lib operations
- Verify merged PDFs are valid

**Complete Flows** (`test/integration/`):
- Merge flow test
- Split flow test
- Protect flow test

### Widget Tests

**Components** (`test/widgets/`):
- Test rendering
- Test user interactions
- Test state changes

---

## Timeline & Estimates

### Development Timeline

| Phase | Duration | Cumulative |
|-------|----------|------------|
| Phase 1: Foundation | 2 days | 2 days |
| Phase 2: JS Bridge | 1 day | 3 days |
| Phase 3: Service Layer | 1 day | 4 days |
| Phase 4: State Management | 1 day | 5 days |
| Phase 5: UI Widgets | 1 day | 6 days |
| Phase 6: Merge Integration | 1 day | 7 days |
| Phase 7: Split Page | 1 day | 8 days |
| Phase 8: Protect Page | 1 day | 9 days |
| Phase 9: Testing & Polish | 1 day | 10 days |
| Phase 10: Production | 1 day | 10 days |

**Total**: 10 working days

### Milestones

- **Day 3**: JavaScript bridge working
- **Day 5**: State management complete
- **Day 7**: Merge feature fully functional
- **Day 9**: All features complete
- **Day 10**: Production ready

---

## Key Benefits of This Architecture

### 1. Testability
Every layer can be tested independently with mocks:
```dart
// Example: Testing PdfServiceImpl without JavaScript
final mockBridge = MockPdfLibBridge();
when(mockBridge.mergePDFs(any)).thenAnswer((_) async => Uint8List(100));

final service = PdfServiceImpl(
  bridge: mockBridge,
  validator: MockFileValidationService(),
);

final result = await service.mergePdfs(testFiles);
expect(result, isA<PdfOperationSuccess>());
```

### 2. Maintainability
Clear boundaries make changes predictable:
- Change PDF library? Only modify JS interop layer
- Add new operation? Add to service interface
- Change UI? Presentation layer only

### 3. Scalability
Easy to extend:
- Add authentication: New auth service + provider
- Add payment: Payment service integrates with existing architecture
- Add compression: New method in PdfService interface

### 4. Code Quality
- SOLID principles enforced by architecture
- Dependency inversion via interfaces
- Single responsibility per class
- Open/closed principle via sealed classes

---

## Next Steps

1. **Review this plan** - Ensure alignment with project goals
2. **Setup environment** - Install dependencies, verify Flutter version
3. **Begin Phase 1** - Start with foundation and models
4. **Follow phases sequentially** - Each phase builds on previous
5. **Test continuously** - Verify at each phase checkpoint

---

## References

- **pdf-lib Documentation**: https://pdf-lib.js.org/docs/api/
- **GetIt Documentation**: https://pub.dev/packages/get_it
- **Provider Documentation**: https://pub.dev/packages/provider
- **desktop_drop Documentation**: https://pub.dev/packages/desktop_drop

---

*This plan was generated on 2026-01-10 for PrivatPDF MVP implementation.*
