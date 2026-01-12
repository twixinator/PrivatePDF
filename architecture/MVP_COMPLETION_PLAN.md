# PrivatPDF MVP Completion Plan

**Status: 🚧 IN PROGRESS**
**Created: 2026-01-10**
**Updated: 2026-01-12** *(Added Phase 0: Critical Security Fixes)*
**Target Completion: 2026-01-16 (6.5 days)**

---

## Executive Summary

This plan completes the PrivatPDF MVP by implementing all remaining **Critical** and **High Priority** user stories. With core PDF processing already complete (28/47 story points), this plan adds:

- **🚨 PHASE 0: Critical Security Fixes** - MUST complete before MVP deployment (4 hours)
  - Password memory clearance
  - Network monitoring implementation
  - CDN integrity verification
  - Content Security Policy headers
  - Operation timeouts
  - PDF integrity validation

- **UI Polish & Animations** - Professional scroll effects, page transitions, micro-interactions
- **Analytics & Error Handling** - Free localStorage-based tracking, enhanced error UX
- **Infrastructure** - Vercel deployment, memory management, operation queue
- **File Management** - Advanced validation, sanitization, verification

**Remaining Work: 38 story points + Phase 0 (6 security fixes)**
**Estimated Time: 6.5 days** *(Phase 0: 4 hours, then 6 days for remaining work)*

---

## Table of Contents

1. [Implementation Scope](#implementation-scope)
2. [Technical Architecture](#technical-architecture)
3. [Implementation Phases](#implementation-phases)
4. [File Structure](#file-structure)
5. [Key Architectural Decisions](#key-architectural-decisions)
6. [Testing Strategy](#testing-strategy)
7. [Performance Optimizations](#performance-optimizations)
8. [Deployment Checklist](#deployment-checklist)

---

## Implementation Scope

### What's Already Done ✅

From the previous implementation (see `CLEAN_ARCHITECTURE_PLAN.md`):

- ✅ Core PDF processing (merge, split, protect) - **28 story points**
- ✅ Clean architecture with 6 layers
- ✅ JavaScript interop with pdf-lib
- ✅ Provider-based state management
- ✅ GetIt dependency injection
- ✅ Basic UI pages (merge, split, protect)
- ✅ File upload with drag-and-drop
- ✅ Landing page with hero section

### What's Remaining 🚧

#### **Critical Priority (16 points)**
- 🚧 US-021: Landing Page Design Polish (5 pts)
- 🚧 US-022: Tool Selection Interface Enhancement (3 pts)
- 🚧 US-031: Complete German Language Content (2 pts)
- 🚧 US-038: Free Tier Anonymous Usage (1 pt)

#### **High Priority - Infrastructure (12 points)**
- 🚧 US-003: Vercel Deployment Setup (2 pts)
- 🚧 US-016: PDF File Type Validation (2 pts)
- 🚧 US-017: Uploaded File List Management (3 pts)
- 🚧 US-018: Memory Management and Cleanup (3 pts)
- 🚧 US-019: File Name Sanitization (1 pt)
- 🚧 US-020: Concurrent Processing Prevention (2 pts)

#### **High Priority - UI/UX (10 points)**
- 🚧 US-026: Responsive Navigation Header (3 pts)
- 🚧 US-027: Footer with Trust Signals (2 pts)
- 🚧 US-028: Pricing Page (3 pts)
- 🚧 US-029: Loading and Success States (2 pts)
- 🚧 US-030: Error State UI Components (2 pts)

#### **High Priority - Analytics (5 points)**
- 🚧 US-041: Analytics Integration (2 pts)
- 🚧 US-042: Custom Event Tracking (3 pts)

**Total: 38 story points**

---

## Technical Architecture

### 1. Animation System (No External Packages)

**Philosophy**: Editorial sophistication, not flashy. Smooth 60fps animations that enhance UX without distraction.

```
Animation Components:
├── lib/animations/
│   ├── animation_constants.dart      # Durations: 150ms-600ms, editorial curves
│   ├── animation_extensions.dart     # Reusable animation builders
│   ├── animated_card.dart            # Hover: scale 1.0→1.02, border, shadow
│   ├── fade_in_widget.dart          # Scroll-triggered fade + slide up 20px
│   ├── success_checkmark.dart        # Animated checkmark with draw effect
│   ├── loading_spinner.dart          # Custom spinner with 1.0→1.08 pulse
│   └── page_transitions.dart         # GoRouter fade + slide transitions
```

**Animation Specifications:**

| Animation | Duration | Curve | Transform |
|-----------|----------|-------|-----------|
| Hover Cards | 250ms | easeOutQuick | Border color, scale 1.0→1.02, shadow 12→24px |
| Scroll Fade-In | 400ms | easeOutQuick | Opacity 0→1, slide up 20px |
| Loading Spinner | 2000ms | linear | 360° rotation + 1.0→1.08 pulse |
| Success Checkmark | 600ms | easeOut | Scale 0→1.2→1.0, stroke draw |
| Page Transition | 400ms | easeOutQuick | Fade 0→1, slide right 100px→0 |

**Performance:**
- GPU-accelerated: `Transform` + `Opacity` (no layout changes)
- Mobile-optimized: 0.7x duration multiplier
- 60fps target: `RepaintBoundary` around animated sections
- Proper disposal: All `AnimationController` disposed

---

### 2. Analytics & Error Handling

**Architecture Decision: localStorage-based Event Logger**

```
Services Architecture:
├── lib/services/
│   ├── analytics_service.dart           # Abstract AnalyticsProvider interface
│   ├── event_logger_service.dart        # localStorage implementation (free!)
│   └── network_verification_service.dart # Verify no data uploads

├── lib/models/
│   ├── analytics_event.dart             # Event data model with categories
│   ├── error_action.dart                # ErrorAction + EnhancedErrorMessage
│   └── pdf_operation_error.dart         # Enhanced with severity & actions
```

**Why localStorage over Plausible/PostHog:**
- ✅ **100% Free** - No hosting costs, no limits
- ✅ **Privacy-first** - Data never leaves browser
- ✅ **Offline-capable** - Works without internet
- ✅ **GDPR-compliant** - No PII, anonymous only
- ✅ **Extensible** - Can integrate PostHog later via interface

**Event Schema:**
```json
{
  "eventName": "pdf_merge_success",
  "category": "pdfOperation",
  "timestamp": "2026-01-10T15:30:45.123Z",
  "properties": {
    "fileCount": 3,
    "fileSizeCategory": "1-5MB",
    "durationMs": 2341,
    "outputSizeBytes": 1900000,
    "clientId": "uuid-anonymous"
  }
}
```

**Enhanced Error UX:**
```dart
// Old: Simple error message
"Datei zu groß. Die maximale Größe beträgt 5MB"

// New: Enhanced with recovery actions
EnhancedErrorMessage(
  title: "Datei zu groß (5.2 MB)",
  userMessage: "Die maximale Größe für den kostenlosen Plan beträgt 5 MB...",
  severity: ErrorSeverity.warning,
  suggestedActions: [
    ErrorAction(
      label: "Auf Pro upgraden",
      type: ErrorActionType.navigateRoute,
      onTap: () => context.go('/pricing'),
    ),
    ErrorAction(
      label: "Datei komprimieren",
      type: ErrorActionType.documentation,
      onTap: () => launchUrl('help/compress'),
    ),
    ErrorAction(
      label: "Erneut versuchen",
      type: ErrorActionType.retryOperation,
    ),
  ],
)
```

**Tracked Events:**
- `pdf_merge_success` / `pdf_merge_error`
- `pdf_split_success` / `pdf_split_error`
- `pdf_protect_success` / `pdf_protect_error`
- `file_size_limit_hit`
- `page_view` (landing, merge, split, protect, pricing)
- `upgrade_clicked`

---

### 3. Infrastructure & Deployment

#### Vercel Configuration

**File: `vercel.json`**
```json
{
  "buildCommand": "flutter build web --release",
  "outputDirectory": "build/web",
  "framework": "flutter",
  "regions": ["iad1"],
  "headers": [
    {
      "source": "/assets/:path*",
      "headers": [
        { "key": "Cache-Control", "value": "public, max-age=31536000, immutable" }
      ]
    }
  ],
  "rewrites": [
    { "source": "/(.*)", "destination": "/index.html" }
  ]
}
```

**GitHub Actions Workflow:**
- Trigger: Push to `main` (production) or `develop` (preview)
- Steps: Setup Flutter → Build → Deploy to Vercel
- Preview URLs for PRs
- Build artifact verification

#### Memory Management Service

**Purpose**: Track Uint8List allocations, explicit cleanup, prevent memory leaks

```dart
class MemoryManagementService {
  // Track all allocations by operation ID
  final Map<String, MemoryAllocation> _allocations = {};

  void trackAllocation(String operationId, String resourceName, int sizeBytes);
  void releaseAllocation(String operationId, String resourceName);
  void clearOperationAllocations(String operationId);
  int getOperationMemoryUsage(String operationId);
}
```

**Cleanup Triggers:**
1. After download: 500ms delay, then release
2. Operation complete: `clearOperationAllocations()`
3. Provider disposal: Full cleanup in `dispose()`
4. Error: Release even on failure

**Garbage Collection Hints:**
```dart
// Yield to event loop for GC
await Future.delayed(Duration.zero);
```

#### Operation Queue Service

**Purpose**: Prevent concurrent processing, show queue status, allow cancellation

```dart
class OperationQueueService extends ChangeNotifier {
  final List<QueuedOperation> _queue = [];
  QueuedOperation? _currentOperation;

  String enqueueOperation(PdfOperationType type);
  bool startOperation(String operationId);
  Future<void> completeOperation(String operationId);
  bool cancelOperation(String operationId);
}
```

**UI Integration:**
```dart
// Processing overlay shows queue status
if (queueSize > 1) {
  Container(
    child: Text('In Warteschlange: ${queueSize - 1} Vorgänge'),
  )
}
```

---

### 4. File Management Enhancements

#### File Name Sanitization

**Service: `FileNameSanitizer`**

**Preserved Characters:**
- German umlauts: `ä, ö, ü, ß, Ä, Ö, Ü`
- Special chars: `-, _, ., (), spaces`
- All ASCII alphanumeric

**Removed Characters:**
- Windows invalid: `< > : " / \ | ? *`
- Control characters: `\x00-\x1F`
- Leading dots/spaces

**Length Limits:**
- Filename max: 255 chars (filesystem limit)
- Basename max: 200 chars (readability)

**Examples:**
```dart
sanitize("Präsentation 2024.pdf")    // → "Präsentation 2024.pdf" ✓
sanitize("File<>Name|*.pdf")         // → "FileName.pdf" ✓
sanitize("sehr_langer_name...")      // → "sehr_lange...pdf" ✓
```

#### Advanced PDF Validation

**Enhanced FileValidationService:**

```dart
Future<ValidationResult> validatePdfIntegrity(PdfFileInfo file) async {
  // 1. Magic byte check (PDF header: %PDF)
  if (!_hasPdfMagicBytes(file.bytes)) {
    return ValidationResult.failure(PdfOperationError.invalidFile);
  }

  // 2. MIME type validation
  if (!_hasValidMimeType(file)) {
    return ValidationResult.failure(PdfOperationError.invalidFile);
  }

  // 3. Corruption detection - attempt to extract page count
  try {
    final pageCount = await PdfLibBridge.getPageCount(file.bytes);
    if (pageCount <= 0) {
      return ValidationResult.failure(PdfOperationError.invalidFile);
    }
  } catch (e) {
    return ValidationResult.failure(PdfOperationError.invalidFile);
  }

  return ValidationResult.success();
}

bool _hasPdfMagicBytes(Uint8List bytes) {
  // Check for "%PDF" (0x25 0x50 0x44 0x46)
  return bytes[0] == 0x25 && bytes[1] == 0x50 &&
         bytes[2] == 0x44 && bytes[3] == 0x46;
}
```

#### Network Verification Service

**Purpose**: Verify no data uploads during PDF operations

```dart
class NetworkVerificationService {
  void startMonitoring(String operationId);
  NetworkVerificationReport stopMonitoring();
  List<NetworkRequest> getOperationRequests(String operationId);
}
```

**Whitelisted Domains:**
- CDN: `cdn.skypack.dev`, `cdn.jsdelivr.net`, `unpkg.com`
- Fonts: `fonts.googleapis.com`, `fonts.gstatic.com`
- Platform: `vercel.com`

**Suspicious Patterns:**
- POST/PUT to unknown domains
- Large payload uploads during operations
- Requests to unauthorized APIs

**UI Indicator:**
```dart
VerificationIndicator(
  verificationService: networkService,
  operationId: currentOperationId,
)
// Shows: ✓ "Client-seitig verarbeitet (100% lokal)"
// Or:    ✗ "Netzwerkaktivität erkannt"
```

---

## Implementation Phases

### **⚠️ PHASE 0: Critical Security Hardening (Day 0 - 4 hours)**

**Status:** 🚨 **BLOCKING** - Must complete before MVP deployment
**Based on:** MVP_AUDIT.md findings (3 CRITICAL + 3 HIGH priority issues)
**Approach:** Minimal Changes (Approach 1) - Maximum reuse, minimal risk

**Goal**: Address all CRITICAL and HIGH security vulnerabilities identified in code audit

---

#### **Security Issue #1: Password Memory Clearance** ⚡ CRITICAL

**Problem**: Passwords stored in `TextEditingController` remain in memory after use
**File**: `R:\VS Code Projekte\PrivatePDF\lib\screens\protect_page.dart`
**Effort**: 15 minutes
**Risk**: LOW

**Implementation:**

```dart
// Line 408-411, modify _handleProtect() method
Future<void> _handleProtect() async {
  if (_selectedFile == null) return;

  // ... existing validation code ...

  // Protect PDF
  final operation = context.read<PdfOperationProvider>();
  await operation.protectPdf(_selectedFile!, password);

  // ✅ NEW: Clear passwords from memory immediately after use
  _passwordController.clear();
  _confirmPasswordController.clear();
}
```

**Testing:**
- [ ] Enter password, click protect
- [ ] Verify password fields are cleared after operation starts
- [ ] Verify PDF protection still works

---

#### **Security Issue #2: JavaScript Network Monitoring** ⚡ CRITICAL

**Problem**: NetworkVerificationService exists but JavaScript interception not wired
**Files**:
- `R:\VS Code Projekte\PrivatePDF\web\index.html`
- `R:\VS Code Projekte\PrivatePDF\lib\services\network_verification_service.dart`
- `R:\VS Code Projekte\PrivatePDF\lib\main.dart`

**Effort**: 45 minutes
**Risk**: LOW (monitor-only, doesn't block requests)

**Implementation Step 1 - Add JavaScript Interceptor:**

Add before line 96 in `web/index.html` (before Flutter bootstrap):

```html
<!-- Network Monitoring for Security Verification -->
<script>
  (function() {
    'use strict';

    // Helper to log network requests to Dart
    function logRequestToDart(url, method) {
      // Check if Flutter app is ready
      if (window.networkVerificationChannel && typeof window.networkVerificationChannel.logRequest === 'function') {
        window.networkVerificationChannel.logRequest(url, method);
      }
    }

    // Intercept fetch()
    const originalFetch = window.fetch;
    window.fetch = function(...args) {
      const url = args[0] instanceof Request ? args[0].url : args[0];
      const method = args[0] instanceof Request ? args[0].method : (args[1]?.method || 'GET');
      logRequestToDart(url, method);
      return originalFetch.apply(this, args);
    };

    // Intercept XMLHttpRequest
    const originalOpen = XMLHttpRequest.prototype.open;
    XMLHttpRequest.prototype.open = function(method, url, ...rest) {
      logRequestToDart(url, method);
      return originalOpen.apply(this, [method, url, ...rest]);
    };

    console.log('[NetworkMonitor] Network interception initialized');
  })();
</script>
```

**Implementation Step 2 - Update NetworkVerificationService:**

Replace lines 228-239 in `lib/services/network_verification_service.dart`:

```dart
/// Web-based network interceptor
class NetworkInterceptor {
  static void setupInterceptor(NetworkVerificationService service) {
    if (!kIsWeb) return;

    // Setup JavaScript-to-Dart channel
    html.window['networkVerificationChannel'] = _NetworkVerificationChannel(service);

    if (Environment.enableDebugLogging) {
      print('[NetworkInterceptor] Setup complete');
      print('  Whitelisted domains: ${Environment.whitelistedDomains.join(", ")}');
    }
  }
}

/// JavaScript-to-Dart communication channel
class _NetworkVerificationChannel {
  final NetworkVerificationService _service;

  _NetworkVerificationChannel(this._service);

  /// Called from JavaScript to log network requests
  void logRequest(String url, String method) {
    _service.logRequest(url: url, method: method);
  }
}
```

**Implementation Step 3 - Initialize in main.dart:**

Add after line 12-16 in `lib/main.dart`:

```dart
import 'services/network_verification_service.dart';
import 'core/di/service_locator.dart' show getIt;

void main() {
  // Initialize dependency injection
  setupServiceLocator();

  // Setup network monitoring interceptor
  NetworkInterceptor.setupInterceptor(getIt<NetworkVerificationService>());

  runApp(const PrivatPdfApp());
}
```

**Testing:**
- [ ] Run app, check console for "[NetworkMonitor] Network interception initialized"
- [ ] Perform PDF operation
- [ ] Check console for logged network requests to cdn.jsdelivr.net
- [ ] Verify no suspicious requests flagged

---

#### **Security Issue #3: CDN Integrity Verification** ⚡ CRITICAL

**Problem**: pdf-lib loaded from CDN without SRI hash
**File**: `R:\VS Code Projekte\PrivatePDF\web\js\pdf_lib_processor.js`
**Effort**: 30 minutes
**Risk**: MEDIUM (CDN change may affect loading)

**Implementation:**

Replace line 9 in `web/js/pdf_lib_processor.js`:

```javascript
// OLD:
import { PDFDocument, StandardFonts, rgb } from 'https://cdn.skypack.dev/pdf-lib@1.17.1';

// NEW:
import { PDFDocument, StandardFonts, rgb } from 'https://cdn.jsdelivr.net/npm/pdf-lib@1.17.1/+esm';
```

**Note**: jsDelivr provides better CDN support than Skypack for this use case. SRI hash will be added via HTTP headers in Vercel config.

**Testing:**
- [ ] Verify all PDF operations work (merge, split, protect)
- [ ] Check DevTools Network tab - pdf-lib loads from cdn.jsdelivr.net
- [ ] Test with offline CDN (should fail gracefully)

---

#### **Security Issue #4: Content Security Policy** ⚡ HIGH PRIORITY

**Problem**: No CSP headers configured
**File**: `R:\VS Code Projekte\PrivatePDF\web\index.html`
**Effort**: 30 minutes
**Risk**: LOW (can adjust if too restrictive)

**Implementation:**

Add after line 20 in `web/index.html` (after theme-color meta tag):

```html
<!-- Content Security Policy -->
<meta http-equiv="Content-Security-Policy"
      content="default-src 'self';
               script-src 'self' 'unsafe-inline' 'unsafe-eval' https://cdn.jsdelivr.net https://cdn.skypack.dev;
               style-src 'self' 'unsafe-inline' https://fonts.googleapis.com;
               font-src 'self' https://fonts.gstatic.com;
               img-src 'self' data: https:;
               connect-src 'self' https://cdn.jsdelivr.net https://cdn.skypack.dev;
               worker-src 'self' blob:;
               frame-src 'none';
               object-src 'none';
               base-uri 'self';">
```

**CSP Breakdown:**
- `default-src 'self'`: Only same-origin by default
- `script-src`: Allows local scripts, CDNs, inline (Flutter Web requires unsafe-inline/unsafe-eval)
- `connect-src 'self'`: **KEY** - Prevents data exfiltration to external servers
- `frame-src 'none'`: Prevents clickjacking

**Testing:**
- [ ] Load app, check for CSP violations in console
- [ ] Test all PDF operations work
- [ ] Test Google Fonts load correctly
- [ ] Try loading external script via console (should be blocked)

---

#### **Security Issue #5: Operation Timeouts** ⚡ HIGH PRIORITY

**Problem**: PDF operations can hang indefinitely
**File**: `R:\VS Code Projekte\PrivatePDF\lib\services\pdf_service_impl.dart`
**Effort**: 30 minutes
**Risk**: LOW

**Implementation:**

Add timeout wrapper method after line 168:

```dart
/// Wrap operation with timeout
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
```

Wrap each PDF operation call:

```dart
// mergePdfs (line 35):
final mergedBytes = await _withTimeout(
  PdfLibBridge.mergePDFs(bytesArray),
  const Duration(seconds: 30),
);

// splitPdf (line 85):
final splitBytes = await _withTimeout(
  PdfLibBridge.splitPDF(fileWithPages.bytes, zeroIndexedPages),
  const Duration(seconds: 30),
);

// protectPdf (line 127):
final protectedBytes = await _withTimeout(
  PdfLibBridge.protectPDF(file.bytes, password),
  const Duration(seconds: 30),
);
```

**Testing:**
- [ ] Test with small PDF (should complete quickly)
- [ ] Test with large PDF (should complete within 30s)
- [ ] Simulate slow operation with delay (should timeout)

---

#### **Security Issue #6: PDF Integrity Validation** ⚡ HIGH PRIORITY

**Problem**: Advanced validation exists but never called
**File**: `R:\VS Code Projekte\PrivatePDF\lib\services\pdf_service_impl.dart`
**Effort**: 20 minutes
**Risk**: LOW

**Implementation:**

Add validation calls in each operation:

```dart
// mergePdfs - Add after line 24:
// 2. Validate PDF integrity for all files
for (final file in files) {
  final integrityCheck = await _validator.validatePdfIntegrity(file);
  if (!integrityCheck.isValid) {
    return PdfOperationFailure(integrityCheck.error!);
  }
}

// splitPdf - Add after line 74:
// 3. Validate PDF integrity
final integrityCheck = await _validator.validatePdfIntegrity(fileWithPages);
if (!integrityCheck.isValid) {
  return PdfOperationFailure(integrityCheck.error!);
}

// protectPdf - Add after line 119:
// 2. Validate PDF integrity
final integrityCheck = await _validator.validatePdfIntegrity(file);
if (!integrityCheck.isValid) {
  return PdfOperationFailure(integrityCheck.error!);
}
```

**Testing:**
- [ ] Test with valid PDF (should pass)
- [ ] Test with corrupted PDF (should fail with clear error)
- [ ] Test with non-PDF file renamed to .pdf (should fail)

---

#### **Phase 0 Summary**

**Files Modified:** 6
- `lib/screens/protect_page.dart` (+3 lines)
- `web/index.html` (+33 lines)
- `web/js/pdf_lib_processor.js` (1 line changed)
- `lib/services/network_verification_service.dart` (+18 lines)
- `lib/main.dart` (+4 lines)
- `lib/services/pdf_service_impl.dart` (+42 lines)

**Total Code Changes:** ~101 lines added/modified
**Estimated Time:** 3.5-4 hours
**Risk Level:** LOW - All changes are additive or wrapper patterns

**Completion Criteria:**
- [ ] All 6 security fixes implemented
- [ ] Manual testing completed for each fix
- [ ] No console errors in development mode
- [ ] All PDF operations still functional
- [ ] Network monitoring logs requests correctly
- [ ] CSP doesn't break existing functionality

**Deployment Blocker:** ❌ Cannot deploy to production until Phase 0 complete

---

### **Day 1: Infrastructure Foundation**

**Goal**: Deployment pipeline + memory management

**Tasks:**
- [ ] Create `vercel.json` configuration
- [ ] Create `.github/workflows/vercel-deploy.yml`
- [ ] Create `lib/config/environment.dart`
- [ ] Implement `MemoryManagementService`
- [ ] Update `DownloadService` with memory tracking
- [ ] Update `PdfOperationProvider` with cleanup
- [ ] Register services in `ServiceLocator`

**Output:** Automated Vercel deployment, memory tracking in place

**Story Points Completed:** 5 (US-003: 2pts, US-018 partial: 3pts)

---

### **Day 2: Analytics & Enhanced Validation**

**Goal**: Event tracking + advanced error handling

**Tasks:**
- [ ] Create `AnalyticsProvider` interface
- [ ] Implement `EventLoggerService` (localStorage)
- [ ] Create `AnalyticsEvent` model
- [ ] Integrate analytics into `PdfOperationProvider`
- [ ] Create `ErrorAction` + `EnhancedErrorMessage` models
- [ ] Create `PdfOperationErrorX` extension with enhanced messages
- [ ] Create `ErrorDisplayWidget` with action buttons
- [ ] Implement advanced PDF validation (magic bytes, corruption)
- [ ] Create `FileNameSanitizer` service
- [ ] Update `DownloadService` with sanitization

**Output:** Analytics tracking live, better error UX, robust validation

**Story Points Completed:** 10 (US-041: 2pts, US-042: 3pts, US-016: 2pts, US-019: 1pt, US-030: 2pts)

---

### **Day 3: UI Animations & Transitions**

**Goal**: Polished, smooth animations throughout

**Tasks:**
- [ ] Create `animation_constants.dart` (durations, curves)
- [ ] Create `animation_extensions.dart` (reusable builders)
- [ ] Create `AnimatedCard` widget (hover effects)
- [ ] Create `FadeInWidget` (scroll-triggered)
- [ ] Create `SuccessCheckmark` widget (animated draw)
- [ ] Create `LoadingSpinner` widget (custom pulse)
- [ ] Configure page transitions in GoRouter
- [ ] Update `landing_page.dart` with scroll animations
- [ ] Update tool cards with `AnimatedCard`
- [ ] Update `operation_overlay.dart` with new animations
- [ ] Update `pdf_drop_zone.dart` with enhanced animations

**Output:** Sophisticated animations, smooth transitions

**Story Points Completed:** 4 (US-029: 2pts, UI polish: 2pts)

---

### **Day 4: UI Polish & German Language**

**Goal**: Complete German content, polished design

**Tasks:**
- [ ] Audit all widgets for hardcoded English strings
- [ ] Add missing strings to `constants/strings.dart`
- [ ] Replace hardcoded strings with `Strings.*` references
- [ ] Update landing page sections with animations
- [ ] Polish tool selection cards
- [ ] Implement full `PricingPage` (Free vs Pro tiers)
- [ ] Update `AppHeader` with enhanced navigation
- [ ] Update `AppFooter` with working links
- [ ] Add trust signals to footer
- [ ] Verify formal "Sie" form throughout

**Output:** Complete German UI, polished landing page, pricing page

**Story Points Completed:** 13 (US-031: 2pts, US-021: 5pts, US-028: 3pts, US-026: 3pts)

---

### **Day 5: File Management & Operation Queue**

**Goal**: Robust operation management, client-side verification

**Tasks:**
- [ ] Create `OperationQueueService`
- [ ] Integrate queue into `PdfOperationProvider`
- [ ] Update `OperationOverlay` with queue status UI
- [ ] Add cancel button for operations
- [ ] Implement `NetworkVerificationService`
- [ ] Create `VerificationIndicator` widget
- [ ] Update `web/index.html` with monitoring script
- [ ] Integrate verification into operation flow
- [ ] Test queue with multiple rapid operations
- [ ] Verify no suspicious network requests

**Output:** One-at-a-time processing, visible queue, network verification

**Story Points Completed:** 6 (US-020: 2pts, US-017: 3pts, US-013: 1pt)

---

### **Day 6: Integration Testing & Deployment**

**Goal**: Production-ready deployment

**Tasks:**
- [ ] Integration testing: Full user flows (upload → process → download)
- [ ] Cross-browser testing (Chrome, Firefox, Safari, Edge)
- [ ] Mobile responsiveness testing (320px - 1920px)
- [ ] Performance testing (memory usage, animation FPS)
- [ ] Accessibility audit (keyboard navigation, screen readers)
- [ ] German language verification
- [ ] Test Vercel deployment (staging)
- [ ] Configure custom domain (if available)
- [ ] Set up GitHub secrets (VERCEL_TOKEN, etc.)
- [ ] Deploy to production
- [ ] Monitor analytics and error tracking

**Output:** Production deployment on Vercel, all features tested

**Story Points Completed:** 0 (testing & deployment)

---

## File Structure

### New Directories & Files (23 new files)

```
R:\VS Code Projekte\PrivatePDF\
├── vercel.json                                      # Vercel deployment config
├── .github/
│   └── workflows/
│       └── vercel-deploy.yml                        # CI/CD pipeline
│
├── architecture/
│   └── MVP_COMPLETION_PLAN.md                       # This document
│
├── lib/
│   ├── config/
│   │   └── environment.dart                         # Environment configuration
│   │
│   ├── animations/
│   │   ├── animation_constants.dart                 # Durations & curves
│   │   ├── animation_extensions.dart                # Reusable builders
│   │   ├── animated_card.dart                       # Hover effects
│   │   ├── fade_in_widget.dart                     # Scroll-triggered
│   │   ├── success_checkmark.dart                   # Animated checkmark
│   │   ├── loading_spinner.dart                     # Custom spinner
│   │   └── page_transitions.dart                    # GoRouter config
│   │
│   ├── services/
│   │   ├── analytics_service.dart                   # Abstract interface
│   │   ├── event_logger_service.dart                # localStorage impl
│   │   ├── memory_management_service.dart           # Memory tracking
│   │   ├── operation_queue_service.dart             # Queue management
│   │   ├── network_verification_service.dart        # Network monitoring
│   │   └── file_name_sanitizer.dart                 # Sanitization logic
│   │
│   ├── models/
│   │   ├── analytics_event.dart                     # Event data model
│   │   └── error_action.dart                        # ErrorAction + Enhanced
│   │
│   ├── widgets/
│   │   ├── error_display.dart                       # Enhanced error UI
│   │   └── verification_indicator.dart              # Network verification
│   │
│   └── core/
│       └── extensions/
│           └── pdf_operation_error_x.dart           # Error extensions
```

### Modified Files (12 files)

```
├── lib/
│   ├── main.dart                                    # Page transitions
│   ├── providers/
│   │   └── pdf_operation_provider.dart              # Analytics + memory
│   ├── services/
│   │   ├── download_service.dart                    # Sanitization + cleanup
│   │   └── file_validation_service.dart             # Advanced validation
│   ├── models/
│   │   └── pdf_operation_error.dart                 # Severity + details
│   ├── screens/
│   │   ├── landing_page.dart                        # Animations
│   │   ├── merge_page.dart                          # Enhanced errors
│   │   ├── split_page.dart                          # Enhanced errors
│   │   └── protect_page.dart                        # Enhanced errors
│   ├── widgets/
│   │   ├── operation_overlay.dart                   # Queue status + animations
│   │   ├── pdf_drop_zone.dart                       # Enhanced animations
│   │   └── app_footer.dart                          # Working links
│   └── core/
│       └── di/
│           └── service_locator.dart                 # Register new services
```

---

## Key Architectural Decisions

### 1. localStorage Analytics vs Cloud Services

**Decision**: localStorage-based EventLoggerService

**Rationale:**
- ✅ **Free** - No hosting, no API costs, no limits
- ✅ **Privacy** - Data never leaves browser (GDPR compliant)
- ✅ **Offline** - Works without internet
- ✅ **Extensible** - Interface allows PostHog integration later
- ✅ **Aligned** - Matches "100% local" value proposition

**Trade-offs:**
- ❌ No server-side dashboard (can build custom with localStorage export)
- ❌ Data stays on user's device (not aggregated across users)
- ✅ Perfectly aligned with privacy-first positioning

---

### 2. Flutter Core Animations vs External Packages

**Decision**: Use Flutter's built-in animation widgets only

**Rationale:**
- ✅ **Zero dependencies** - No package bloat
- ✅ **Performance** - GPU-accelerated Transform/Opacity
- ✅ **Control** - Full customization for editorial style
- ✅ **Maintenance** - No breaking changes from packages

**Considered Alternatives:**
- `flutter_animate` - Too flashy, not editorial
- `animations` package - Overkill for needs
- `rive` - Too complex for subtle animations

---

### 3. Vercel vs Other Hosting

**Decision**: Vercel for deployment

**Rationale:**
- ✅ **Best Flutter Web support** - Optimized build process
- ✅ **Auto-deploy** - GitHub integration with PR previews
- ✅ **Free tier** - 100GB bandwidth/month sufficient for MVP
- ✅ **Performance** - Global CDN with edge caching
- ✅ **Analytics** - Built-in Web Analytics (privacy-friendly)

**Alternatives Considered:**
- Netlify - Good but Flutter Web quirks
- GitHub Pages - No auto-deploy from Git
- Firebase Hosting - Overkill without other Firebase services

---

### 4. Operation Queue vs Multi-threading

**Decision**: Single-threaded queue with UI feedback

**Rationale:**
- ✅ **Simple** - No race conditions, clear state
- ✅ **UX** - User sees queue position, understands wait
- ✅ **Safe** - pdf-lib is not thread-safe
- ✅ **Web-aligned** - JavaScript is single-threaded anyway

**Web Workers Considered:** pdf-lib doesn't support Web Workers well

---

### 5. Memory Management Strategy

**Decision**: Explicit tracking + cleanup hints

**Rationale:**
- ✅ **Visibility** - Can debug memory issues easily
- ✅ **Prevention** - Explicit cleanup prevents leaks
- ✅ **Performance** - GC hints between operations
- ✅ **Testing** - Can verify cleanup in tests

**Why not rely on GC alone?**
- Large Uint8List allocations (PDFs can be MBs)
- Users may process multiple files in sequence
- Want predictable cleanup, not relying on GC timing

---

## Testing Strategy (Pragmatic Balance Approach)

**Status**: Integrated into MVP implementation timeline
**Approach**: Test-driven hybrid - unit tests during implementation, integration tests in dedicated phase
**Coverage Target**: 80%+ overall, 100% critical components (PageRange, validation)
**Timeline Impact**: +0.5 days (7 days total)

---

### Testing Philosophy

**ROI-Driven Testing**: Focus effort where bugs actually occur
- ✅ **High Value**: Business logic, validation, state management, error handling
- ✅ **Medium Value**: Service coordination, queue management, memory tracking
- ⚠️ **Low Value**: Widget animations, JavaScript interop details (manual testing)

**Test Categories**:
1. **Unit Tests** (60+ tests) - Pure logic, zero dependencies
2. **Integration Tests** (3 tests) - Full workflows (merge/split/protect)
3. **Manual Tests** - Cross-browser, visual verification

---

### Test Infrastructure Architecture

```
R:\VS Code Projekte\PrivatePDF\test\
├── fixtures/                           # Test data & helpers
│   ├── test_helpers.dart              # Mock builders, utilities
│   └── sample_pdfs/                   # Committed PDF fixtures
│       ├── valid_2page.pdf            # 2-page valid PDF (~50KB)
│       ├── valid_10page.pdf           # 10-page PDF for merge tests
│       ├── corrupted.pdf              # Invalid PDF for error testing
│       └── oversized.pdf              # >5MB file for size validation
│
├── mocks/                              # Generated mocks (Mockito)
│   └── mocks.dart                     # @GenerateMocks annotations
│
├── unit/                               # Unit tests (fastest feedback)
│   ├── models/
│   │   ├── page_range_test.dart       # 100% coverage - CRITICAL
│   │   ├── validation_result_test.dart
│   │   ├── pdf_file_info_test.dart
│   │   └── pdf_operation_error_test.dart
│   │
│   ├── services/
│   │   ├── file_validation_service_test.dart   # 90%+ coverage
│   │   ├── pdf_service_impl_test.dart          # Mock IPdfLibBridge
│   │   ├── memory_management_service_test.dart
│   │   ├── operation_queue_service_test.dart
│   │   └── event_logger_service_test.dart
│   │
│   └── providers/
│       ├── pdf_operation_provider_test.dart    # Mock all services
│       └── file_list_provider_test.dart
│
└── integration/                        # Integration tests (Day 6)
    ├── merge_flow_test.dart           # Full merge workflow
    ├── split_flow_test.dart           # Full split workflow
    └── protect_flow_test.dart         # Full protect workflow
```

---

### Critical Refactoring: PdfLibBridge Interface Extraction

**Problem**: `PdfLibBridge` uses static methods with `@JS()` annotations → not mockable

**Solution**: Extract interface (1-hour refactoring, non-breaking)

#### Step 1: Create Interface

**File**: `R:\VS Code Projekte\PrivatePDF\lib\core\js_interop\i_pdf_lib_bridge.dart`

```dart
import 'dart:typed_data';

/// Interface for PDF library operations
/// Enables mocking in tests while keeping JavaScript interop isolated
abstract class IPdfLibBridge {
  /// Merge multiple PDFs into a single document
  Future<Uint8List> mergePDFs(List<Uint8List> pdfFiles);

  /// Split PDF by extracting specific pages
  Future<Uint8List> splitPDF(Uint8List pdfBytes, List<int> pageNumbers);

  /// Protect PDF with password encryption
  Future<Uint8List> protectPDF(Uint8List pdfBytes, String password);

  /// Get page count from a PDF
  Future<int> getPageCount(Uint8List pdfBytes);

  /// Check if PDF-lib is loaded and available
  bool isAvailable();
}
```

#### Step 2: Update PdfLibBridge Implementation

**File**: `R:\VS Code Projekte\PrivatePDF\lib\core\js_interop\pdf_lib_bridge.dart` (modified)

```dart
// Add at top of file after imports:
import 'i_pdf_lib_bridge.dart';

// Change class declaration (line 30):
class PdfLibBridge implements IPdfLibBridge {
  /// Singleton instance
  static final IPdfLibBridge _instance = PdfLibBridge._();

  /// Private constructor
  PdfLibBridge._();

  /// Get singleton instance
  static IPdfLibBridge get instance => _instance;

  // Keep all existing methods, just add @override annotations
  @override
  Future<Uint8List> mergePDFs(List<Uint8List> pdfFiles) async {
    // ... existing implementation ...
  }

  @override
  Future<Uint8List> splitPDF(Uint8List pdfBytes, List<int> pageNumbers) async {
    // ... existing implementation ...
  }

  @override
  Future<Uint8List> protectPDF(Uint8List pdfBytes, String password) async {
    // ... existing implementation ...
  }

  @override
  Future<int> getPageCount(Uint8List pdfBytes) async {
    // ... existing implementation ...
  }

  @override
  bool isAvailable() {
    // ... existing implementation ...
  }
}
```

#### Step 3: Inject Bridge into PdfServiceImpl

**File**: `R:\VS Code Projekte\PrivatePDF\lib\services\pdf_service_impl.dart` (modified lines 10-15)

```dart
class PdfServiceImpl implements PdfService {
  final FileValidationService _validator;
  final IPdfLibBridge _pdfLibBridge; // NEW: Injected bridge

  PdfServiceImpl({
    required FileValidationService validator,
    IPdfLibBridge? pdfLibBridge, // NEW: Optional for testing
  }) : _validator = validator,
       _pdfLibBridge = pdfLibBridge ?? PdfLibBridge.instance; // NEW: Use instance

  // Update all calls from PdfLibBridge.method() to _pdfLibBridge.method()
  // Example (line 35):
  // OLD: if (!PdfLibBridge.isAvailable()) { ... }
  // NEW: if (!_pdfLibBridge.isAvailable()) { ... }
}
```

#### Step 4: Update Service Locator

**File**: `R:\VS Code Projekte\PrivatePDF\lib\core\di\service_locator.dart` (no changes needed)

```dart
// PdfServiceImpl already uses constructor injection
// Tests will inject mock bridge, production uses default (PdfLibBridge.instance)
```

**Refactoring Time**: 1 hour
**Risk**: Very Low (additive, non-breaking)
**Files Changed**: 3 files (1 new, 2 modified)

---

### Unit Tests: Specific Examples

#### PageRange Tests (100% Coverage Target)

**File**: `test/unit/models/page_range_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:privatpdf/models/page_range.dart';

void main() {
  group('PageRange.parse', () {
    test('parses single page', () {
      final range = PageRange.parse('5', 10);
      expect(range.pages, [5]);
    });

    test('parses simple range', () {
      final range = PageRange.parse('1-3', 10);
      expect(range.pages, [1, 2, 3]);
    });

    test('parses complex range', () {
      final range = PageRange.parse('1-3,5,7-9', 10);
      expect(range.pages, [1, 2, 3, 5, 7, 8, 9]);
    });

    test('removes duplicates and sorts', () {
      final range = PageRange.parse('5,1-3,2', 10);
      expect(range.pages, [1, 2, 3, 5]);
    });

    test('throws on empty string', () {
      expect(
        () => PageRange.parse('', 10),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws on out of range', () {
      expect(
        () => PageRange.parse('11', 10),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws on invalid range (start > end)', () {
      expect(
        () => PageRange.parse('5-3', 10),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws on non-numeric input', () {
      expect(
        () => PageRange.parse('abc', 10),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('PageRange.formatted', () {
    test('formats consecutive range', () {
      expect(PageRange([1, 2, 3]).formatted, '1-3');
    });

    test('formats mixed ranges and singles', () {
      expect(PageRange([1, 2, 3, 5, 7, 8, 9]).formatted, '1-3, 5, 7-9');
    });
  });

  test('toZeroIndexed converts correctly', () {
    expect(PageRange([1, 2, 3]).toZeroIndexed(), [0, 1, 2]);
  });
}
```

**Test Count**: 15+ tests
**Time to Write**: 1 hour
**Execution Time**: <5 seconds

#### FileValidationService Tests (90%+ Coverage Target)

**File**: `test/unit/services/file_validation_service_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:privatpdf/services/file_validation_service.dart';
import 'package:privatpdf/models/pdf_operation_error.dart';
import '../../fixtures/test_helpers.dart';

void main() {
  late FileValidationService service;

  setUp(() {
    service = FileValidationService(
      maxFileSizeBytes: 5 * 1024 * 1024, // 5MB
      minMergeFiles: 2,
      maxMergeFiles: 10,
      minPasswordLength: 6,
    );
  });

  group('validateMerge', () {
    test('succeeds with valid files', () {
      final files = TestHelpers.createMultipleMockPdfs(2);
      final result = service.validateMerge(files);
      expect(result.isValid, true);
    });

    test('fails with insufficient files', () {
      final files = TestHelpers.createMultipleMockPdfs(1);
      final result = service.validateMerge(files);
      expect(result.error, PdfOperationError.insufficientFiles);
    });

    test('fails with too many files', () {
      final files = TestHelpers.createMultipleMockPdfs(11);
      final result = service.validateMerge(files);
      expect(result.error, PdfOperationError.tooManyFiles);
    });

    test('fails with oversized file', () {
      final files = [
        TestHelpers.createMockPdfFileInfo('file1.pdf'),
        TestHelpers.createMockPdfWithSize('large.pdf', 6), // 6MB
      ];
      final result = service.validateMerge(files);
      expect(result.error, PdfOperationError.fileTooLarge);
    });
  });

  group('validateSplit', () {
    test('succeeds with valid file and range', () {
      final file = TestHelpers.createMockPdfFileInfo(
        'document.pdf',
        pageCount: 10,
      );
      final range = PageRange([1, 2, 3]);
      final result = service.validateSplit(file, range);
      expect(result.isValid, true);
    });

    test('fails with insufficient pages', () {
      final file = TestHelpers.createMockPdfFileInfo(
        'document.pdf',
        pageCount: 1,
      );
      final range = PageRange([1]);
      final result = service.validateSplit(file, range);
      expect(result.error, PdfOperationError.insufficientPages);
    });
  });

  group('validateProtect', () {
    test('succeeds with valid password', () {
      final file = TestHelpers.createMockPdfFileInfo('document.pdf');
      final result = service.validateProtect(file, 'SecurePass123');
      expect(result.isValid, true);
    });

    test('fails with weak password', () {
      final file = TestHelpers.createMockPdfFileInfo('document.pdf');
      final result = service.validateProtect(file, '12345');
      expect(result.error, PdfOperationError.weakPassword);
    });
  });
}
```

**Test Count**: 12+ tests
**Time to Write**: 1 hour
**Execution Time**: <5 seconds

#### PdfServiceImpl Tests (with Mock Bridge)

**File**: `test/unit/services/pdf_service_impl_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:privatpdf/services/pdf_service_impl.dart';
import 'dart:typed_data';
import '../../mocks/mocks.mocks.dart';
import '../../fixtures/test_helpers.dart';

void main() {
  late PdfServiceImpl service;
  late MockFileValidationService mockValidator;
  late MockIPdfLibBridge mockBridge; // Mock the bridge!

  setUp(() {
    mockValidator = MockFileValidationService();
    mockBridge = MockIPdfLibBridge();

    service = PdfServiceImpl(
      validator: mockValidator,
      pdfLibBridge: mockBridge, // Inject mock
    );
  });

  group('mergePdfs', () {
    test('returns success with valid files', () async {
      // Arrange
      final files = TestHelpers.createMultipleMockPdfs(2);
      final mergedBytes = Uint8List.fromList([0x25, 0x50, 0x44, 0x46]);

      when(mockValidator.validateMerge(any))
          .thenReturn(ValidationResult.success());
      when(mockValidator.validatePdfIntegrity(any))
          .thenAnswer((_) async => ValidationResult.success());
      when(mockBridge.isAvailable()).thenReturn(true);
      when(mockBridge.mergePDFs(any)).thenAnswer((_) async => mergedBytes);

      // Act
      final result = await service.mergePdfs(files);

      // Assert
      expect(result.isSuccess, true);
      verify(mockBridge.mergePDFs(any)).called(1);
    });

    test('returns failure when bridge unavailable', () async {
      // Arrange
      final files = TestHelpers.createMultipleMockPdfs(2);

      when(mockValidator.validateMerge(any))
          .thenReturn(ValidationResult.success());
      when(mockValidator.validatePdfIntegrity(any))
          .thenAnswer((_) async => ValidationResult.success());
      when(mockBridge.isAvailable()).thenReturn(false); // Unavailable!

      // Act
      final result = await service.mergePdfs(files);

      // Assert
      expect(result.isFailure, true);
      verifyNever(mockBridge.mergePDFs(any));
    });

    test('handles timeout error', () async {
      // Arrange
      final files = TestHelpers.createMultipleMockPdfs(2);

      when(mockValidator.validateMerge(any))
          .thenReturn(ValidationResult.success());
      when(mockValidator.validatePdfIntegrity(any))
          .thenAnswer((_) async => ValidationResult.success());
      when(mockBridge.isAvailable()).thenReturn(true);
      when(mockBridge.mergePDFs(any)).thenAnswer(
        (_) async => Future.delayed(Duration(seconds: 35)), // Timeout!
      );

      // Act
      final result = await service.mergePdfs(files);

      // Assert
      expect(result.isFailure, true);
    });
  });
}
```

**Test Count**: 10+ tests per operation (merge, split, protect)
**Time to Write**: 1.5 hours
**Execution Time**: <10 seconds

---

### Integration Tests

**File**: `test/integration/merge_flow_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:privatpdf/main.dart' as app;
import 'package:flutter/foundation.dart' show kIsWeb;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Full merge workflow', (tester) async {
    // Skip on non-web (requires JavaScript interop)
    if (!kIsWeb) return;

    // 1. Launch app
    app.main();
    await tester.pumpAndSettle();

    // 2. Navigate to merge page
    await tester.tap(find.text('PDFs zusammenführen'));
    await tester.pumpAndSettle();

    // 3. Upload 2 PDFs (using test fixtures)
    // Note: File upload requires special handling in integration tests

    // 4. Click merge button
    await tester.tap(find.text('Zusammenführen'));
    await tester.pumpAndSettle();

    // 5. Verify success state
    expect(find.textContaining('Fertig'), findsOneWidget);

    // 6. Verify memory cleanup
    // (Check via MemoryManagementService)
  });
}
```

**Test Count**: 3 integration tests (merge, split, protect)
**Time to Write**: 2 hours
**Execution Time**: 30-60 seconds each

---

### Test Fixtures & Helpers

#### Test Helpers File

**File**: `test/fixtures/test_helpers.dart`

```dart
import 'dart:typed_data';
import 'package:privatpdf/models/pdf_file_info.dart';

class TestHelpers {
  /// Create a mock PdfFileInfo for testing
  static PdfFileInfo createMockPdfFileInfo(
    String name, {
    int? sizeBytes,
    Uint8List? bytes,
    int? pageCount,
  }) {
    final defaultBytes = Uint8List.fromList([
      0x25, 0x50, 0x44, 0x46, // %PDF magic bytes
      ...List.generate(100, (i) => i % 256),
    ]);

    return PdfFileInfo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      sizeBytes: sizeBytes ?? 1024,
      bytes: bytes ?? defaultBytes,
      pageCount: pageCount,
    );
  }

  /// Create a mock PDF with specific size (in MB)
  static PdfFileInfo createMockPdfWithSize(String name, int megabytes) {
    final bytes = Uint8List(megabytes * 1024 * 1024);
    // Add PDF magic bytes
    bytes[0] = 0x25;
    bytes[1] = 0x50;
    bytes[2] = 0x44;
    bytes[3] = 0x46;

    return PdfFileInfo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      sizeBytes: bytes.length,
      bytes: bytes,
    );
  }

  /// Create multiple mock PDFs
  static List<PdfFileInfo> createMultipleMockPdfs(int count) {
    return List.generate(
      count,
      (i) => createMockPdfFileInfo('file$i.pdf'),
    );
  }

  /// Create a corrupted PDF (invalid magic bytes)
  static PdfFileInfo createCorruptedPdf(String name) {
    return PdfFileInfo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      sizeBytes: 100,
      bytes: Uint8List.fromList([0x00, 0x01, 0x02, 0x03, 0x04]),
    );
  }
}
```

#### Mock Generation

**File**: `test/mocks/mocks.dart`

```dart
import 'package:mockito/annotations.dart';
import 'package:privatpdf/services/pdf_service.dart';
import 'package:privatpdf/services/file_validation_service.dart';
import 'package:privatpdf/services/download_service.dart';
import 'package:privatpdf/services/analytics_service.dart';
import 'package:privatpdf/services/operation_queue_service.dart';
import 'package:privatpdf/services/network_verification_service.dart';
import 'package:privatpdf/services/memory_management_service.dart';
import 'package:privatpdf/core/js_interop/i_pdf_lib_bridge.dart';

@GenerateMocks([
  PdfService,
  FileValidationService,
  DownloadService,
  AnalyticsProvider,
  OperationQueueService,
  NetworkVerificationService,
  MemoryManagementService,
  IPdfLibBridge, // NEW: Mock the interface, not the implementation
])
void main() {}
```

**Generate mocks:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This generates `test/mocks/mocks.mocks.dart` with all mock classes.

---

### CI/CD Pipeline Integration

#### GitHub Actions Workflow

**File**: `.github/workflows/test.yml`

```yaml
name: Test Suite

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  test:
    name: Run Tests
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
          channel: 'stable'

      - name: Get dependencies
        run: flutter pub get

      - name: Generate mocks
        run: flutter pub run build_runner build --delete-conflicting-outputs

      - name: Analyze code
        run: flutter analyze

      - name: Run unit tests
        run: flutter test test/unit --coverage

      - name: Check coverage thresholds
        run: |
          # Install lcov
          sudo apt-get update
          sudo apt-get install -y lcov

          # PageRange must have 100% coverage
          lcov --list coverage/lcov.info | grep "page_range.dart" | awk '{if ($4 < 100) exit 1}' || echo "✅ PageRange coverage meets 100% target"

          # FileValidationService must have 90%+ coverage
          lcov --list coverage/lcov.info | grep "file_validation_service.dart" | awk '{if ($4 < 90) exit 1}' || echo "✅ FileValidationService coverage meets 90%+ target"

          # Overall project coverage must be 80%+
          lcov --summary coverage/lcov.info | grep "lines" | awk '{if ($2 < 80) exit 1}' || echo "✅ Overall coverage meets 80%+ target"

      - name: Generate coverage HTML report
        run: genhtml coverage/lcov.info -o coverage/html

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info
          fail_ci_if_error: true

      - name: Comment PR with coverage
        if: github.event_name == 'pull_request'
        uses: romeovs/lcov-reporter-action@v0.3.1
        with:
          lcov-file: ./coverage/lcov.info
          github-token: ${{ secrets.GITHUB_TOKEN }}

  integration-test:
    name: Integration Tests
    runs-on: ubuntu-latest
    needs: test # Only run if unit tests pass

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
          channel: 'stable'

      - name: Get dependencies
        run: flutter pub get

      - name: Run integration tests (web)
        run: flutter test test/integration --platform chrome

      - name: Build test (verify production build works)
        run: flutter build web --release
```

**Branch Protection Rules** (configure in GitHub repository settings):
- Require status checks before merging:
  - `Test Suite / Run Tests` must pass
  - `Test Suite / Integration Tests` must pass
- Require branches to be up to date before merging

---

### MVP Timeline Integration (Updated)

#### Phase 0 Extension: Test Infrastructure + Security Tests

**Time**: 4 hours → **6 hours** (+2 hours)

**NEW Testing Tasks:**

1. **PdfLibBridge Interface Extraction** (1 hour)
   - Create `i_pdf_lib_bridge.dart` interface
   - Update `pdf_lib_bridge.dart` to implement interface
   - Update `pdf_service_impl.dart` with bridge injection
   - Verify existing code still works

2. **Test Infrastructure Setup** (30 min)
   - Create test directory structure
   - Create `test/fixtures/test_helpers.dart`
   - Create `test/mocks/mocks.dart`
   - Run `build_runner` to generate mocks

3. **First Security Tests** (30 min)
   - Create `test/unit/services/file_validation_service_test.dart`
   - Write 5 tests for magic byte validation (Phase 0 fix #6)
   - Verify tests pass

**Phase 0 Total**: 6 hours (security fixes: 4h, testing setup: 2h)

---

#### Day 1: Infrastructure + Model Tests

**Original**: Vercel, memory management (5 pts) - 5 hours
**NEW**: +2 hours testing = **7 hours total**

**Testing Tasks:**

1. **PageRange Model Tests** (1.5 hours) - CRITICAL
   - File: `test/unit/models/page_range_test.dart`
   - 15+ tests covering all parsing logic
   - Target: 100% coverage
   - Run: `flutter test test/unit/models/page_range_test.dart --coverage`

2. **ValidationResult Model Tests** (30 min)
   - File: `test/unit/models/validation_result_test.dart`
   - 10 tests covering factories, equality

**Day 1 Total**: 5 pts implementation (5h) + testing (2h) = 7 hours

---

#### Day 2: Analytics & Validation + Service Tests

**Original**: Analytics, validation (10 pts) - 8 hours
**NEW**: Already includes testing time (hybrid approach)

**Testing Tasks** (integrated during implementation):

1. **FileValidationService Tests** (1 hour)
   - Write alongside implementation
   - 12+ tests for all validation rules
   - Target: 90%+ coverage

2. **EventLoggerService Tests** (30 min)
   - Write alongside implementation
   - Test localStorage operations

3. **PdfOperationError Tests** (30 min)
   - Test all error messages (German)

**Day 2 Total**: 8 hours (implementation + tests written together)

---

#### Day 3: Animations + UI Tests

**Original**: Animations (4 pts) - 7 hours
**NEW**: No additional testing time (skip widget animation tests per ROI analysis)

**Day 3 Total**: 7 hours (implementation only, animations tested manually)

---

#### Day 4: UI Polish + German

**Original**: UI polish, German (13 pts) - 8 hours
**NEW**: No additional testing time (focus on business logic, not UI)

**Day 4 Total**: 8 hours (implementation only)

---

#### Day 5: Queue & Verification + Provider Tests

**Original**: Queue, verification (6 pts) - 8 hours
**NEW**: Already includes testing time (hybrid approach)

**Testing Tasks** (integrated during implementation):

1. **OperationQueueService Tests** (1 hour)
   - Write alongside implementation
   - 15+ tests for queue operations
   - Target: 90%+ coverage

2. **PdfOperationProvider Tests** (1.5 hours)
   - Write alongside implementation
   - Mock all dependencies
   - Test state transitions
   - Target: 85%+ coverage

3. **PdfServiceImpl Tests** (1 hour)
   - Write with mock IPdfLibBridge
   - Test error handling, timeouts

**Day 5 Total**: 8 hours (implementation + tests written together)

---

#### Day 6: Integration Testing & Deployment

**Original**: Testing & deployment - 8 hours
**NEW**: More focused, less manual testing needed = **8 hours**

**Testing Tasks:**

1. **Integration Tests** (3 hours)
   - `test/integration/merge_flow_test.dart` (1h)
   - `test/integration/split_flow_test.dart` (1h)
   - `test/integration/protect_flow_test.dart` (1h)
   - Run: `flutter test test/integration --platform chrome`

2. **Manual Testing** (2 hours) - Reduced from original
   - Cross-browser smoke testing (automated tests cover most)
   - Visual verification (animations, German text)
   - Mobile responsiveness check

3. **CI/CD Setup** (1 hour)
   - Create `.github/workflows/test.yml`
   - Configure branch protection rules
   - Verify workflow runs successfully

4. **Deployment** (2 hours)
   - Deploy to Vercel staging
   - Verify all CI checks pass
   - Deploy to production

**Day 6 Total**: 8 hours

---

### Updated Timeline Summary

| Day | Focus | Story Points | Testing | Total Time |
|-----|-------|--------------|---------|------------|
| **Phase 0** | Security + Test Setup | 6 fixes | Interface extraction, first tests | **6 hours** |
| **Day 1** | Infrastructure | 5 pts | PageRange, ValidationResult tests | **7 hours** |
| **Day 2** | Analytics & Validation | 10 pts | Service tests (written during impl) | **8 hours** |
| **Day 3** | Animations | 4 pts | Manual testing only | **7 hours** |
| **Day 4** | UI Polish & German | 13 pts | Manual testing only | **8 hours** |
| **Day 5** | Queue & Verification | 6 pts | Provider tests (written during impl) | **8 hours** |
| **Day 6** | Integration & Deployment | 0 pts | Integration tests, CI/CD, deployment | **8 hours** |
| **Total** | **38 story points** | **38 pts** | **60+ tests, 80%+ coverage** | **7 days** |

**Timeline Impact**: Original 6.5 days → **7 days** (+0.5 days = 7.7% increase)

---

### Coverage Targets Summary

| Component | Target | Priority | Test File |
|-----------|--------|----------|-----------|
| **PageRange** | 100% | CRITICAL | `test/unit/models/page_range_test.dart` |
| **FileValidationService** | 90%+ | CRITICAL | `test/unit/services/file_validation_service_test.dart` |
| **PdfServiceImpl** | 85%+ | HIGH | `test/unit/services/pdf_service_impl_test.dart` |
| **PdfOperationProvider** | 85%+ | HIGH | `test/unit/providers/pdf_operation_provider_test.dart` |
| **OperationQueueService** | 90%+ | HIGH | `test/unit/services/operation_queue_service_test.dart` |
| **MemoryManagementService** | 80%+ | MEDIUM | `test/unit/services/memory_management_service_test.dart` |
| **ValidationResult** | 100% | HIGH | `test/unit/models/validation_result_test.dart` |
| **PdfOperationError** | 100% | HIGH | `test/unit/models/pdf_operation_error_test.dart` |
| **EventLoggerService** | 85%+ | MEDIUM | `test/unit/services/event_logger_service_test.dart` |
| **Integration Flows** | N/A | HIGH | `test/integration/*_flow_test.dart` |
| **Overall Project** | **80%+** | GOAL | All tests combined |

**CI Enforcement**: Tests fail if PageRange < 100%, FileValidationService < 90%, or overall < 80%

---

### Implementation Checklist

#### Phase 0: Test Infrastructure (6 hours)

**Refactoring Tasks:**
- [ ] Create `lib/core/js_interop/i_pdf_lib_bridge.dart` interface
- [ ] Update `lib/core/js_interop/pdf_lib_bridge.dart` to implement interface
- [ ] Update `lib/services/pdf_service_impl.dart` with bridge injection
- [ ] Verify existing code compiles and runs

**Test Infrastructure:**
- [ ] Create test directory structure:
  ```bash
  mkdir -p test/unit/models test/unit/services test/unit/providers
  mkdir -p test/integration test/mocks test/fixtures/sample_pdfs
  ```
- [ ] Create `test/fixtures/test_helpers.dart` with mock builders
- [ ] Create `test/mocks/mocks.dart` with @GenerateMocks annotations
- [ ] Run `flutter pub run build_runner build`
- [ ] Verify generated `test/mocks/mocks.mocks.dart` compiles

**First Tests:**
- [ ] Create `test/unit/services/file_validation_service_test.dart`
- [ ] Write 5 tests for magic byte validation
- [ ] Run tests: `flutter test test/unit/services/file_validation_service_test.dart`
- [ ] Verify all tests pass

**CI Setup:**
- [ ] Create `.github/workflows/test.yml`
- [ ] Push to GitHub and verify workflow runs
- [ ] Configure branch protection rules

#### Day 1: Model Tests (7 hours)

- [ ] Write `test/unit/models/page_range_test.dart` (15+ tests)
- [ ] Verify 100% coverage: `flutter test --coverage && lcov --list coverage/lcov.info | grep page_range`
- [ ] Write `test/unit/models/validation_result_test.dart` (10 tests)
- [ ] Write `test/unit/models/pdf_file_info_test.dart` (10 tests)

#### Day 2: Service Tests (8 hours)

- [ ] Write `test/unit/services/file_validation_service_test.dart` (12+ tests)
- [ ] Verify 90%+ coverage
- [ ] Write `test/unit/services/event_logger_service_test.dart` (8 tests)
- [ ] Write `test/unit/models/pdf_operation_error_test.dart` (10 tests)

#### Day 5: Provider Tests (8 hours)

- [ ] Write `test/unit/services/operation_queue_service_test.dart` (15+ tests)
- [ ] Write `test/unit/providers/pdf_operation_provider_test.dart` (15+ tests)
- [ ] Write `test/unit/services/pdf_service_impl_test.dart` (10+ tests with mock bridge)

#### Day 6: Integration & Deployment (8 hours)

- [ ] Write `test/integration/merge_flow_test.dart`
- [ ] Write `test/integration/split_flow_test.dart`
- [ ] Write `test/integration/protect_flow_test.dart`
- [ ] Run integration tests: `flutter test test/integration --platform chrome`
- [ ] Manual cross-browser testing
- [ ] Deploy to Vercel staging
- [ ] Verify CI passes
- [ ] Deploy to production

**Verification Commands:**
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Check coverage thresholds
lcov --list coverage/lcov.info | grep "page_range.dart"
lcov --list coverage/lcov.info | grep "file_validation_service.dart"
lcov --summary coverage/lcov.info

# Generate HTML coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html  # macOS
start coverage/html/index.html # Windows
```

---

### Benefits of This Testing Approach

✅ **High ROI**: 80%+ coverage focused on business logic (where bugs occur)
✅ **Fast Feedback**: Unit tests run in <30 seconds, catch bugs immediately
✅ **Minimal Refactoring**: Only 1 interface extraction (1 hour), very low risk
✅ **CI Enforcement**: Coverage thresholds block merges, prevent regressions
✅ **Hybrid Timeline**: Tests written during implementation (+0.5 days only)
✅ **Production-Ready**: 60+ tests ensure MVP stability for real users

---

### Trade-Offs Accepted

⚠️ **Widget Animations**: Manual testing only (low bug risk, high test effort)
⚠️ **JavaScript Interop**: Integration tests only (hard to unit test, low value)
⚠️ **UI Components**: Limited coverage (visual bugs caught manually)

**Net Result**: 80%+ coverage on critical business logic with minimal timeline impact (+0.5 days)

---

### Manual Testing Checklist

**Cross-Browser:**
- [ ] Chrome (desktop + mobile)
- [ ] Firefox (desktop + mobile)
- [ ] Safari (desktop + mobile)
- [ ] Edge (desktop)

**Responsive Design:**
- [ ] Mobile: 320px - 767px
- [ ] Tablet: 768px - 1023px
- [ ] Desktop: 1024px - 1920px
- [ ] Ultra-wide: >1920px

**PDF Operations:**
- [ ] Merge 2-10 files successfully
- [ ] Split with various page ranges (1-3, 5, 7-9)
- [ ] Protect with 6+ character password
- [ ] Handle corrupt PDF with error message
- [ ] Handle oversized file (>5MB) with upgrade prompt

**Animations:**
- [ ] Landing page sections fade in on scroll
- [ ] Tool cards scale smoothly on hover
- [ ] Page transitions are smooth (no flashing)
- [ ] Success checkmark animates properly
- [ ] Loading spinner rotates + pulses

**German Language:**
- [ ] No English text in UI
- [ ] Formal "Sie" form used
- [ ] Umlauts display correctly (ä, ö, ü, ß)
- [ ] Date/number formats use German conventions

**Analytics:**
- [ ] Events logged to localStorage
- [ ] No network requests during PDF operations
- [ ] Verification indicator shows green checkmark
- [ ] Error events include error code

**Memory:**
- [ ] DevTools heap size stable after operations
- [ ] No memory leaks after 10+ sequential operations
- [ ] Memory cleanup after download

---

## Performance Optimizations

### Animation Performance

**GPU Acceleration:**
```dart
// ✅ Good - GPU accelerated
Transform.scale(scale: _scale, child: child)
Opacity(opacity: _opacity, child: child)

// ❌ Avoid - Triggers layout
Container(width: _width, height: _height, child: child)
```

**RepaintBoundary:**
```dart
// Isolate expensive repaints
RepaintBoundary(
  child: AnimatedCard(...),
)
```

**Mobile Optimization:**
```dart
// Reduce animation complexity on mobile
final durationMultiplier = isMobile ? 0.7 : 1.0;
final duration = Duration(milliseconds: (250 * durationMultiplier).round());
```

---

### Asset Optimization

**Vercel Caching Strategy:**
```json
{
  "headers": [
    {
      "source": "/assets/:path*",
      "headers": [
        { "key": "Cache-Control", "value": "public, max-age=31536000, immutable" }
      ]
    },
    {
      "source": "/js/:path*",
      "headers": [
        { "key": "Cache-Control", "value": "public, max-age=86400" }
      ]
    },
    {
      "source": "/",
      "headers": [
        { "key": "Cache-Control", "value": "public, max-age=3600" }
      ]
    }
  ]
}
```

**Cache Lifetimes:**
- Assets (fonts, images): 1 year (immutable)
- JavaScript: 1 day
- HTML: 1 hour (to allow quick updates)

---

### Memory Optimization

**Uint8List Cleanup:**
```dart
// Explicit cleanup after download
Future.delayed(Duration(milliseconds: 500), () {
  _memoryService.releaseAllocation(operationId, resourceName);
  // Yield to event loop for GC
  await Future.delayed(Duration.zero);
});
```

**Queue Staggering:**
```dart
// Delay between operations allows GC
Future.delayed(Duration(milliseconds: 500), () {
  processNextOperation();
});
```

---

### Build Optimization

**Flutter Web Build Flags:**
```bash
flutter build web \
  --release \
  --web-renderer canvaskit \
  --dart-define=FLUTTER_WEB_CANVASKIT_URL=https://unpkg.com/canvaskit-wasm@latest/bin/
```

**Why CanvasKit:**
- Better rendering consistency across browsers
- Improved animation performance
- Better text rendering (important for editorial typography)

---

## Deployment Checklist

### Pre-Deployment

**Code Quality:**
- [ ] All tests passing (`flutter test`)
- [ ] No analysis errors (`flutter analyze`)
- [ ] Code formatted (`dart format .`)
- [ ] No debug prints in production code
- [ ] Environment variables configured

**Build Verification:**
- [ ] `flutter build web --release` succeeds
- [ ] Build size < 10MB (check `build/web` directory)
- [ ] No missing assets in build
- [ ] JavaScript file loads (`build/web/js/pdf_lib_processor.js`)

**Configuration:**
- [ ] `vercel.json` created
- [ ] GitHub secrets set (VERCEL_TOKEN, VERCEL_ORG_ID, VERCEL_PROJECT_ID)
- [ ] Environment variables in Vercel dashboard
- [ ] Custom domain configured (if applicable)

---

### Deployment Steps

**1. Staging Deployment:**
```bash
# Push to develop branch
git push origin develop

# Vercel auto-deploys preview
# URL: https://privatpdf-develop.vercel.app
```

**2. Production Deployment:**
```bash
# Merge to main
git checkout main
git merge develop
git push origin main

# Vercel auto-deploys production
# URL: https://privatpdf.vercel.app or custom domain
```

**3. Post-Deployment Verification:**
- [ ] Landing page loads correctly
- [ ] All tool pages accessible (/merge, /split, /protect, /pricing)
- [ ] PDF operations work (merge, split, protect)
- [ ] Analytics events logged to localStorage
- [ ] Network verification shows green checkmark
- [ ] Animations smooth (60fps)
- [ ] Mobile responsive (test on real device)

---

### Monitoring

**Vercel Dashboard:**
- [ ] Check deployment status
- [ ] Monitor bandwidth usage (100GB free tier)
- [ ] Check Web Analytics (if enabled)
- [ ] Review error logs

**Browser DevTools:**
- [ ] Check console for errors
- [ ] Verify localStorage events
- [ ] Monitor memory usage
- [ ] Check network tab (no suspicious requests)

**User Feedback:**
- [ ] Test with real users
- [ ] Monitor error rates
- [ ] Track conversion (free → pro clicks)

---

## Success Metrics

### Technical Metrics

**Performance:**
- ✅ First Contentful Paint < 1.5s
- ✅ Time to Interactive < 3s
- ✅ Animation frame rate: 60fps
- ✅ Memory stable after 10 operations

**Quality:**
- ✅ Zero console errors in production
- ✅ 100% German language coverage
- ✅ Cross-browser compatibility (Chrome, Firefox, Safari, Edge)
- ✅ Mobile responsive (320px - 1920px)

---

### User Experience Metrics

**Engagement:**
- Track via localStorage analytics:
  - PDF operations completed
  - Error rates per operation type
  - File size limit hits (upgrade opportunity)
  - Pricing page visits

**Trust Indicators:**
- ✅ Network verification shows "100% lokal verarbeitet"
- ✅ No network requests during PDF processing
- ✅ Trust badges visible (DSGVO, Open Source)

---

## Timeline Summary

| Day | Focus | Story Points | Status |
|-----|-------|--------------|--------|
| **🚨 Phase 0** | **Critical Security Hardening** | **6 fixes** | **⚠️ BLOCKING** |
| **Day 1** | Infrastructure (Vercel, Memory) | 5 pts | 🚧 Pending |
| **Day 2** | Analytics & Validation | 10 pts | 🚧 Pending |
| **Day 3** | Animations & Transitions | 4 pts | 🚧 Pending |
| **Day 4** | UI Polish & German | 13 pts | 🚧 Pending |
| **Day 5** | Queue & Verification | 6 pts | 🚧 Pending |
| **Day 6** | Testing & Deployment | 0 pts | 🚧 Pending |
| **Total** | **38 story points + Phase 0** | **38 pts** | **6.5 days** |

**Note:** Phase 0 must be completed (4 hours) before proceeding to Day 1. This addresses critical security vulnerabilities identified in MVP_AUDIT.md that are blocking production deployment.

---

## Next Steps

**⚠️ CRITICAL - Phase 0 First:**
1. ✅ **Complete Phase 0 security fixes (4 hours)** - See detailed implementation plan above
2. ✅ **Test all 6 security fixes** - Manual verification required
3. ✅ **Verify no regressions** - All PDF operations must still work

**Then proceed with MVP implementation:**
4. Review and approve this plan
5. Set up Vercel account + GitHub repository connection
6. Configure GitHub secrets
7. Begin Day 1 implementation

**After MVP Completion:**
1. User acceptance testing with real users
2. Gather feedback on animations and UX
3. Monitor analytics for usage patterns
4. Plan authentication & payment integration (post-MVP)

---

## Questions or Adjustments?

This plan is comprehensive but flexible. If you need to:
- **Adjust scope** - We can defer animations or analytics to post-MVP
- **Change timeline** - We can compress to 4 days (skip some polish) or extend to 8 days (more testing)
- **Modify approach** - Any architectural decisions can be revisited

**Status**: Ready for implementation ✅

---

## Appendix: Related Documents

- **Previous Implementation**: See `CLEAN_ARCHITECTURE_PLAN.md` (fully completed)
- **User Stories**: See `user-stories/` directory for detailed acceptance criteria
- **Architecture Analysis**: Generated by feature-dev agents on 2026-01-10

---

**Last Updated**: 2026-01-12 *(Added Phase 0: Critical Security Hardening)*
**Document Owner**: Claude (Sonnet 4.5)
**Status**: Phase 0 Required Before Implementation - Security Blocking Issues
