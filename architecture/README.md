# PrivatPDF Architecture Documentation

This directory contains all architecture and implementation planning documents for PrivatPDF.

---

## Current Plans

### 📋 [MVP_COMPLETION_PLAN.md](./MVP_COMPLETION_PLAN.md)
**Status**: 🚧 In Progress
**Created**: 2026-01-10
**Target**: 2026-01-16 (6 days)

Comprehensive plan to complete the PrivatPDF MVP by implementing all remaining Critical and High Priority user stories:

- **UI Polish & Animations** - Scroll effects, transitions, micro-interactions
- **Analytics & Error Handling** - localStorage tracking, enhanced error UX
- **Infrastructure** - Vercel deployment, memory management, operation queue
- **File Management** - Advanced validation, sanitization, verification

**Remaining Work**: 38 story points
**Estimated Time**: 5-6 days

---

## Completed Plans (Archive)

### ✅ [CLEAN_ARCHITECTURE_PLAN_COMPLETED.md](./archive/CLEAN_ARCHITECTURE_PLAN_COMPLETED.md)
**Status**: ✅ Fully Implemented
**Completed**: 2026-01-10

The original clean architecture implementation that established:
- Core PDF processing (merge, split, protect)
- 6-layer architecture (UI → Provider → Service → JS Interop → JavaScript)
- pdf-lib integration via JavaScript interop
- Provider-based state management
- GetIt dependency injection
- Basic UI pages and file upload

**Completed**: 28 story points

---

## Architecture Overview

### Current Architecture (as of 2026-01-10)

```
┌─────────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                       │
│  Flutter Widgets (Screens, Pages, Components)               │
└────────────────┬────────────────────────────────────────────┘
                 │ context.watch/read
┌────────────────┴────────────────────────────────────────────┐
│                   PROVIDER LAYER                             │
│  State Management (ChangeNotifier + Provider pattern)       │
│  - PdfOperationProvider, FileListProvider                   │
└────────────────┬────────────────────────────────────────────┘
                 │ uses (via GetIt)
┌────────────────┴────────────────────────────────────────────┐
│                    SERVICE LAYER                             │
│  Business Logic & Coordination                               │
│  - PdfService, FileValidationService, DownloadService       │
└────────────────┬────────────────────────────────────────────┘
                 │ uses
┌────────────────┴────────────────────────────────────────────┐
│                  JS INTEROP LAYER                            │
│  Dart ↔ JavaScript Bridge (PdfLibBridge)                   │
│  Type conversion, promise handling                           │
└────────────────┬────────────────────────────────────────────┘
                 │ dart:js_util
┌────────────────┴────────────────────────────────────────────┐
│                  JAVASCRIPT LAYER                            │
│  web/js/pdf_lib_processor.js                                │
│  PDF manipulation using pdf-lib (v1.17.1)                   │
└─────────────────────────────────────────────────────────────┘
```

### Design Principles

1. **Separation of Concerns** - Each layer has a single responsibility
2. **Dependency Inversion** - High-level modules don't depend on low-level
3. **Testability** - Every layer can be unit tested with mocks
4. **Client-Side First** - 100% local processing, no server uploads
5. **Privacy-Focused** - GDPR-compliant, no user tracking

---

## Technology Stack

### Core Dependencies

```yaml
dependencies:
  flutter: sdk
  go_router: ^13.0.0           # Routing
  provider: ^6.1.1             # State management
  get_it: ^7.6.4               # Dependency injection
  file_picker: ^6.1.1          # File selection
  desktop_drop: ^0.4.4         # Drag & drop
  js: ^0.6.7                   # JavaScript interop
  intl: ^0.19.0                # Internationalization
  url_launcher: ^6.2.3         # External links
```

### External Libraries (JavaScript)

- **pdf-lib** (v1.17.1) - PDF manipulation (loaded via CDN)
- Loaded from: `https://cdn.skypack.dev/pdf-lib@1.17.1`

---

## Key Architectural Decisions

### 1. pdf-lib (JavaScript) over syncfusion_flutter_pdf (Dart)
- **Why**: More features, better maintained, free/open-source
- **Trade-off**: JavaScript interop complexity vs feature richness
- **Result**: Clean dart:js_util bridge, works perfectly

### 2. Provider over Riverpod/Bloc
- **Why**: Simpler for MVP, sufficient for small app
- **Trade-off**: Less powerful than Riverpod, but easier to learn
- **Result**: Clean, readable state management

### 3. GetIt over riverpod_annotation
- **Why**: Explicit service registration, no code generation
- **Trade-off**: Manual registration vs automatic
- **Result**: Clear dependency graph, easy to debug

### 4. localStorage Analytics over Plausible/PostHog
- **Why**: Free, privacy-first, offline-capable
- **Trade-off**: No server-side dashboard vs cost savings
- **Result**: Perfectly aligned with "100% local" positioning

### 5. Vercel over Netlify/GitHub Pages
- **Why**: Best Flutter Web support, auto-deploy, free tier
- **Trade-off**: Vendor lock-in vs convenience
- **Result**: Fast deployments, excellent performance

---

## Project Structure

```
R:\VS Code Projekte\PrivatePDF\
├── lib/
│   ├── main.dart                      # App entry point
│   ├── core/
│   │   ├── di/                        # Dependency injection
│   │   ├── js_interop/                # JavaScript bridge
│   │   └── extensions/                # Dart extensions
│   ├── models/                        # Domain models
│   ├── services/                      # Business logic
│   ├── providers/                     # State management
│   ├── screens/                       # Full page widgets
│   ├── widgets/                       # Reusable components
│   ├── theme/                         # Design system
│   ├── constants/                     # App constants
│   ├── animations/                    # Animation widgets (NEW)
│   └── config/                        # Configuration (NEW)
│
├── web/
│   ├── index.html                     # Entry point
│   └── js/
│       └── pdf_lib_processor.js       # JavaScript PDF operations
│
├── user-stories/                      # User story documentation
├── architecture/                      # Architecture docs (this dir)
│   ├── README.md                      # This file
│   ├── MVP_COMPLETION_PLAN.md         # Current plan
│   └── archive/                       # Completed plans
│
├── vercel.json                        # Vercel deployment config (NEW)
└── .github/
    └── workflows/
        └── vercel-deploy.yml          # CI/CD pipeline (NEW)
```

---

## Development Workflow

### Local Development

```bash
# Install dependencies
flutter pub get

# Run in Chrome
flutter run -d chrome

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
dart format .
```

### Building for Production

```bash
# Build release version
flutter build web --release

# Output: build/web/
```

### Deployment

**Automatic via GitHub Actions:**
- Push to `main` → Production deploy
- Push to `develop` → Preview deploy
- Open PR → Preview deploy with comment

**Manual via Vercel CLI:**
```bash
vercel --prod
```

---

## Testing Strategy

### Unit Tests
- Services: PdfService, FileValidationService, etc.
- Models: PdfFileInfo, PageRange, etc.
- Utilities: FileNameSanitizer, etc.

### Widget Tests
- Individual widgets: PdfDropZone, AnimatedCard, etc.
- Provider integration: State changes, rebuilds

### Integration Tests
- Full user flows: Upload → Process → Download
- Queue processing: Multiple rapid operations
- Memory management: No leaks after operations

### Manual Testing
- Cross-browser: Chrome, Firefox, Safari, Edge
- Responsive: 320px - 1920px
- PDF operations: Merge, split, protect with real files
- German language: No English leakage

---

## Performance Targets

- **First Contentful Paint**: < 1.5s
- **Time to Interactive**: < 3s
- **Animation Frame Rate**: 60fps
- **Memory**: Stable after 10+ operations
- **Build Size**: < 10MB

---

## Security & Privacy

### Client-Side Guarantees
- ✅ No file uploads to server
- ✅ All processing in browser (pdf-lib)
- ✅ Network verification service monitors requests
- ✅ No PII collection (analytics are anonymous)
- ✅ GDPR-compliant by design

### Content Security Policy
```html
<meta http-equiv="Content-Security-Policy"
      content="default-src 'self';
               script-src 'self' 'unsafe-inline' https://cdn.skypack.dev;
               style-src 'self' 'unsafe-inline' https://fonts.googleapis.com;
               font-src 'self' https://fonts.gstatic.com;">
```

---

## Future Enhancements (Post-MVP)

### Phase 2 (After MVP Launch)
- User authentication (email/password)
- Payment integration (Stripe)
- Pro tier features (unlimited file size)
- PDF compression
- Dark mode

### Phase 3 (3-6 months)
- OCR (text recognition)
- E-signature (hand-drawn)
- Multi-language support (English, French)
- Batch processing (>10 files)
- PWA features (offline support, add to home screen)

### Phase 4 (6-12 months)
- PDF to Word/Excel conversion
- Image to PDF conversion
- PDF editing (rotate, delete pages)
- Template library
- API access for developers

---

## Resources

### Documentation
- **Flutter**: https://flutter.dev/docs
- **pdf-lib**: https://pdf-lib.js.org/
- **Provider**: https://pub.dev/packages/provider
- **GetIt**: https://pub.dev/packages/get_it

### Design System
- **Fonts**: Cormorant (display), Inter (body)
- **Colors**: Sage green (#8B9A8A), Terracotta (#D4917B)
- **Style**: Editorial sophistication, minimal, clean

### User Stories
- See `user-stories/` directory for detailed acceptance criteria
- 60 total stories, 178 story points
- Currently: 31/47 critical points completed (66%)

---

## Questions or Issues?

For questions about the architecture or implementation:
1. Check the relevant plan document (current or archive)
2. Review user stories for detailed acceptance criteria
3. Consult this README for high-level overview

---

**Last Updated**: 2026-01-10
**Status**: MVP in progress (38 story points remaining)
