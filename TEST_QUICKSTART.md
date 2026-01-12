# PrivatPDF Testing Quick Start Guide

## Prerequisites

```bash
# Install dependencies
flutter pub get

# Generate mocks (required before running tests)
flutter pub run build_runner build --delete-conflicting-outputs
```

## Running Tests

### All Model Tests (91 tests) ✅ WORKING

```bash
flutter test test/unit/models/
```

**Expected Output:**
```
00:01 +91: All tests passed!
```

### Individual Model Tests

```bash
# PageRange (39 tests - CRITICAL 100% coverage)
flutter test test/unit/models/page_range_test.dart

# ValidationResult (18 tests)
flutter test test/unit/models/validation_result_test.dart

# PdfFileInfo (24 tests)
flutter test test/unit/models/pdf_file_info_test.dart

# PdfOperationError (10 tests)
flutter test test/unit/models/pdf_operation_error_test.dart
```

### Service Tests (Chrome Platform Required)

```bash
# FileValidationService (50+ tests)
flutter test --platform chrome test/unit/services/file_validation_service_test.dart

# All service tests
flutter test --platform chrome test/unit/services/
```

**Note**: Service tests require Chrome platform due to web-only dependencies (`dart:js_util`, `dart:html`).

### With Coverage

```bash
# Generate coverage report
flutter test test/unit/models/ --coverage

# View coverage HTML report
genhtml coverage/lcov.info -o coverage/html

# Open in browser (Windows)
start coverage/html/index.html

# Open in browser (macOS/Linux)
open coverage/html/index.html  # macOS
xdg-open coverage/html/index.html  # Linux
```

### Check Specific Coverage

```bash
# Install lcov (Ubuntu/Debian)
sudo apt-get install lcov

# Check PageRange coverage (should be 100%)
lcov --list coverage/lcov.info | grep page_range.dart

# Check overall coverage summary
lcov --summary coverage/lcov.info
```

## Test Structure

```
test/
├── fixtures/
│   ├── test_helpers.dart              # Reusable mock builders
│   └── sample_pdfs/                   # Test PDF files
├── mocks/
│   ├── mocks.dart                     # @GenerateMocks annotations
│   └── mocks.mocks.dart              # Generated mocks
├── unit/
│   ├── models/                        # ✅ 91 tests passing
│   │   ├── page_range_test.dart      # 39 tests
│   │   ├── validation_result_test.dart # 18 tests
│   │   ├── pdf_file_info_test.dart   # 24 tests
│   │   └── pdf_operation_error_test.dart # 10 tests
│   ├── services/                      # 🔄 In progress
│   │   └── file_validation_service_test.dart
│   └── providers/                     # ⏳ Pending
└── integration/                       # ⏳ Pending
```

## Using Test Helpers

```dart
import '../../fixtures/test_helpers.dart';

// Create a basic mock PDF
final file = TestHelpers.createMockPdfFileInfo('test.pdf');

// Create a PDF with specific size (for size validation tests)
final large = TestHelpers.createMockPdfWithSize('large.pdf', 6); // 6MB

// Create multiple files for merge tests
final files = TestHelpers.createMultipleMockPdfs(3); // 3 files

// Create a corrupted PDF (invalid magic bytes)
final bad = TestHelpers.createCorruptedPdf('bad.pdf');

// Create a PDF with all properties
final full = TestHelpers.createFullMockPdf(
  name: 'document.pdf',
  sizeBytes: 2048,
  pageCount: 10,
);
```

## Using Mocks

```dart
import '../../mocks/mocks.mocks.dart';
import 'package:mockito/mockito.dart';

void main() {
  late MockIPdfLibBridge mockBridge;

  setUp(() {
    mockBridge = MockIPdfLibBridge();
  });

  test('example test', () {
    // Setup mock behavior
    when(mockBridge.getPageCount(any)).thenAnswer((_) async => 5);

    // Use in service
    final service = FileValidationService(pdfLibBridge: mockBridge);

    // Verify calls
    verify(mockBridge.getPageCount(any)).called(1);
  });
}
```

## Common Issues & Solutions

### Issue: "Mock not generated"

**Solution**: Run mock generation:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: "dart:js_util not available"

**Problem**: Tests importing web-only code fail on VM platform.

**Solution**: Run on Chrome platform:
```bash
flutter test --platform chrome test/unit/services/
```

### Issue: Coverage report empty

**Problem**: Coverage wasn't generated.

**Solution**: Run tests with `--coverage` flag:
```bash
flutter test test/unit/models/ --coverage
```

## Coverage Targets

| Component | Target | Status |
|-----------|--------|--------|
| **PageRange** | 100% | ✅ 100% |
| **All Models** | 100% | ✅ ~100% |
| **FileValidationService** | 90%+ | 🔄 Pending |
| **Overall Project** | 80%+ | ⏳ TBD |

## CI/CD

Tests run automatically on:
- Push to `main` or `develop`
- Pull requests to `main` or `develop`

**GitHub Actions Workflow**: `.github/workflows/test.yml`

**Checks:**
- ✅ Code analysis (`flutter analyze`)
- ✅ Model tests with coverage
- ✅ PageRange 100% coverage verification
- ✅ Overall 80%+ coverage check
- ✅ Build verification
- ✅ Codecov upload
- ✅ PR coverage comments

## Test Metrics

**Current Status:**
- ✅ 91 model tests passing
- ✅ ~1 second execution time
- ✅ 100% model coverage
- ✅ Zero flaky tests
- ✅ CI/CD pipeline operational

**Test Quality:**
- Clear, descriptive test names
- Comprehensive edge case coverage
- Isolated tests (no interdependencies)
- Fast feedback loop (TDD-friendly)
- Reusable fixtures and helpers

## Next Steps

1. **Fix Service Test Platform Issue**
   ```bash
   # Update CI/CD to run service tests on Chrome
   flutter test --platform chrome test/unit/services/
   ```

2. **Complete Service Tests**
   - EventLoggerService (8 tests)
   - MemoryManagementService (8 tests)
   - OperationQueueService (15+ tests)

3. **Add Provider Tests**
   - PdfServiceImpl (10+ tests)
   - PdfOperationProvider (15+ tests)

4. **Add Integration Tests**
   - Full merge workflow
   - Full split workflow
   - Full protect workflow

## Documentation

For detailed implementation notes, see:
- `architecture/TESTING_IMPLEMENTATION_SUMMARY.md` - Full implementation details
- `architecture/MVP_COMPLETION_PLAN.md` - Original testing strategy

## Questions?

Check the implementation summary for:
- Interface extraction details
- Mock generation process
- Platform-specific testing approach
- Coverage verification steps

---

**Quick Command Reference:**

```bash
# Run all model tests
flutter test test/unit/models/

# Run with coverage
flutter test test/unit/models/ --coverage

# Run service tests (Chrome)
flutter test --platform chrome test/unit/services/

# Generate mocks
flutter pub run build_runner build --delete-conflicting-outputs

# View coverage report
genhtml coverage/lcov.info -o coverage/html && start coverage/html/index.html
```

---

**Status**: ✅ 91 model tests passing | 🔄 Service tests written | ⏳ Integration tests pending
**Updated**: 2026-01-12
