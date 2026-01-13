# PrivatPDF Test Suite

## Running Tests

### Standard Test Run (91 tests)
```bash
flutter test
```

This runs all VM-compatible tests. All tests should pass.

### Web-Specific Tests (Requires Chrome)

Some tests require web-specific APIs (`dart:html`, `dart:js`, `dart:js_util`) and must be run on Chrome:

```bash
# Run the web-specific validation service test
flutter test --platform chrome test/unit/services/file_validation_service_test.dart.skip
```

**Note**: The file has a `.skip` extension to prevent it from being picked up by the default test runner (which runs on VM and would fail to compile web-specific imports).

## Test Coverage

Current coverage:
- **Total**: 91 tests passing
- **Critical Components**: 100% coverage
  - PageRange parsing and validation
  - PDF operation error handling
  - Validation results

### Coverage Targets
- Overall: 80%+
- Critical components (PageRange, validation): 90-100%

## CI/CD Integration

The GitHub Actions workflow runs:
1. VM tests: `flutter test` (91 tests)
2. Code analysis: `flutter analyze`
3. Build verification: `flutter build web --release`

Web-specific tests are not run in CI by default (requires Chrome setup). They should be run manually during development.

## Test Structure

```
test/
├── fixtures/           # Test helpers and mock data
├── mocks/              # Generated mocks (Mockito)
├── unit/               # Unit tests
│   ├── models/        # Model tests (PageRange, etc.)
│   ├── services/      # Service tests
│   └── providers/     # Provider tests
└── integration/        # Integration tests (future)
```

## Writing New Tests

1. **VM-Compatible Tests**: Place in appropriate directory under `test/unit/`
2. **Web-Specific Tests**: Add `.skip` extension and document in this README
3. **Use Mocks**: Import from `../../mocks/mocks.mocks.dart`
4. **Test Helpers**: Use utilities from `../../fixtures/test_helpers.dart`

## Troubleshooting

### "dart:js not available" Error
This means the test requires web-specific APIs. Either:
- Run with `--platform chrome`, or
- Rename the file with `.skip` extension to exclude from default runs

### Tests Hang or Timeout
- Increase timeout in `dart_test.yaml`
- Check for infinite loops or unresolved futures
- Ensure mocks are properly configured

### Mock Generation
If you add new services to mock, regenerate mocks:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```
