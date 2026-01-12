# Analytics & Error Handling User Stories

---

## [US-041] Plausible Analytics Integration
**As a** product owner,
**I want to** track user behavior with privacy-focused analytics,
**So that** I can measure product success without compromising user privacy.

**Acceptance Criteria:**
- [ ] Plausible Analytics script is integrated into Flutter Web app
- [ ] Page views are automatically tracked for all routes
- [ ] No cookies or personal data are collected
- [ ] Analytics comply with GDPR (no consent banner required)
- [ ] Dashboard is accessible to product team
- [ ] Analytics script loads asynchronously (doesn't block page load)

**Technical Hints:**
- Add Plausible script to web/index.html
- Use data-domain attribute for site identification
- Consider using plausible_analytics Flutter package for easier integration
- Test with ad blockers to understand potential data gaps

**Story Points:** 2
**Priority:** High
**Dependencies:** [US-001], [US-003]
**Category:** Analytics

---

## [US-042] Custom Event Tracking for PDF Operations
**As a** product owner,
**I want to** track specific user actions (merge, split, protect),
**So that** I can understand which features are most used.

**Acceptance Criteria:**
- [ ] Custom events tracked: "PDF Merged", "PDF Split", "PDF Protected"
- [ ] Events include properties: file_count (for merge), page_count (for split), file_size_category (small/medium/large)
- [ ] Events do NOT include filenames, content, or personal data
- [ ] File size categories: small (<1MB), medium (1-5MB), large (>5MB)
- [ ] Events are sent to Plausible after successful processing
- [ ] Failed operations are NOT tracked as successful events

**Technical Hints:**
- Use Plausible custom events API: plausible('event_name', {props: {...}})
- Fire events in success callback after download completes
- Categorize file sizes for privacy (don't send exact sizes)
- Test events in Plausible dashboard

**Story Points:** 3
**Priority:** High
**Dependencies:** [US-041], [US-007], [US-008], [US-009]
**Category:** Analytics

---

## [US-043] Conversion Tracking (Free to Pro)
**As a** product owner,
**I want to** track when users upgrade to Pro tier,
**So that** I can measure conversion rate and revenue.

**Acceptance Criteria:**
- [ ] Custom event "Upgrade to Pro" is tracked when payment succeeds
- [ ] Event includes property: payment_amount (€19.00)
- [ ] Event does NOT include user email or personal information
- [ ] Event tracks payment method category (card/sepa/paypal)
- [ ] Goal is configured in Plausible dashboard for conversion tracking
- [ ] Funnel tracking: Pricing Page View → Checkout Started → Payment Success

**Technical Hints:**
- Fire event on /payment/success page load
- Use Plausible goals feature for conversion tracking
- Track "Checkout Started" event when Stripe Checkout opens
- Calculate conversion rate: (Upgrade to Pro events) / (Pricing Page Views)

**Story Points:** 2
**Priority:** Medium
**Dependencies:** [US-041], [US-037]
**Category:** Analytics

---

## [US-044] File Size Limit Hit Tracking
**As a** product owner,
**I want to** track when free users hit the 5MB file size limit,
**So that** I can measure upgrade motivation and optimize pricing.

**Acceptance Criteria:**
- [ ] Custom event "File Size Limit Hit" is tracked when user exceeds 5MB
- [ ] Event includes property: attempted_file_size_category (6-10MB, 11-50MB, 50MB+)
- [ ] Event does NOT track exact file size or filenames
- [ ] Event only fires for free tier users (not Pro users)
- [ ] Event tracks whether user clicked "Upgrade auf Pro" CTA after error

**Technical Hints:**
- Fire event in file size validation error handler
- Track CTA click with separate event: "Upgrade CTA Clicked" (source: file_size_limit)
- Use this data to optimize file size limit value
- Compare limit hit rate to upgrade conversion rate

**Story Points:** 2
**Priority:** Medium
**Dependencies:** [US-041], [US-014]
**Category:** Analytics

---

## [US-045] Error Logging and Monitoring
**As a** developer,
**I want to** log errors locally in browser console,
**So that** I can debug issues during development and user-reported bugs.

**Acceptance Criteria:**
- [ ] All caught errors are logged to browser console with context
- [ ] Error logs include: timestamp, error type, user action, file metadata (size, type - NOT filename)
- [ ] Errors are categorized: FileValidationError, PDFProcessingError, NetworkError, UnexpectedError
- [ ] No error data is sent to external services (purely local logging)
- [ ] Production builds still log errors (helps with user bug reports via screenshots)
- [ ] Error logs do NOT contain sensitive data (filenames, content, user emails)

**Technical Hints:**
- Create centralized error logging utility: logError(errorType, message, context)
- Use try-catch blocks around all PDF processing operations
- Wrap async operations in error boundaries
- Consider adding error report button (post-MVP) for users to share console logs

**Story Points:** 2
**Priority:** Medium
**Dependencies:** [US-001]
**Category:** Error Handling

---

## [US-046] User-Friendly Error Messages
**As a** user,
**I want to** see helpful German error messages when operations fail,
**So that** I understand what went wrong and how to fix it.

**Acceptance Criteria:**
- [ ] Error messages are displayed in clear German language
- [ ] Common errors have specific messages:
  - "Datei zu gros (max. 5MB). Upgrade auf Pro fur unbegrenzte Grose."
  - "Nur PDF-Dateien sind erlaubt."
  - "PDF-Datei ist beschadigt oder unlesbar."
  - "Ungultige Seitenzahlen. Bitte prufe deine Eingabe."
  - "Passworter stimmen nicht uberein."
- [ ] Generic fallback error: "Ein Fehler ist aufgetreten. Bitte versuche es erneut oder kontaktiere den Support."
- [ ] Error messages include actionable next steps when possible
- [ ] Errors are displayed prominently (banner, dialog, or inline)

**Technical Hints:**
- Create error message constants file (lib/constants/error_messages.dart)
- Map error types to user-friendly messages
- Include "Kontakt" link in generic errors pointing to support email
- Test all error scenarios to ensure messages appear correctly

**Story Points:** 2
**Priority:** High
**Dependencies:** [US-030]
**Category:** Error Handling

---

## [US-047] Graceful Degradation for Browser Compatibility
**As a** user with an older browser,
**I want to** see a warning if my browser is not fully supported,
**So that** I can upgrade or use a different browser.

**Acceptance Criteria:**
- [ ] App detects browser version on initial load
- [ ] Supported browsers: Chrome 90+, Firefox 88+, Safari 14+, Edge 90+
- [ ] Unsupported browsers show warning banner: "Dein Browser wird moglicherweise nicht vollstandig unterstutzt. Bitte aktualisiere auf die neueste Version."
- [ ] Warning is dismissible but persists across sessions
- [ ] Critical features (merge, split, protect) attempt to work even on older browsers
- [ ] PDF processing errors on old browsers show "Browser nicht unterstutzt" message

**Technical Hints:**
- Use user agent detection or feature detection (prefer feature detection)
- Test for required features: FileReader API, Blob download, required JavaScript features
- Store dismissal in localStorage
- Focus testing on Chrome (primary target), test edge cases on others

**Story Points:** 3
**Priority:** Low
**Dependencies:** [US-001]
**Category:** Error Handling

---

## [US-048] Network Error Handling (Offline Mode)
**As a** user,
**I want to** still use PDF processing features when offline,
**So that** the "100% local processing" promise is fulfilled.

**Acceptance Criteria:**
- [ ] PDF processing (merge, split, protect) works without internet connection
- [ ] Authentication and payment require internet (expected limitation)
- [ ] If user is offline, show informational message: "Keine Internetverbindung. PDF-Verarbeitung funktioniert weiterhin, aber Login und Bezahlung erfordern Internet."
- [ ] Offline status is detected and displayed in header
- [ ] When connection restored, status message disappears

**Technical Hints:**
- Listen to window.navigator.onLine event
- Test offline mode in browser DevTools (Network tab → Offline)
- All PDF processing should work offline (no external API calls)
- Analytics events queue locally and send when connection restored (Plausible handles this)

**Story Points:** 2
**Priority:** Medium
**Dependencies:** [US-007], [US-008], [US-009], [US-013]
**Category:** Error Handling

---

## [US-049] Performance Monitoring for Large Files
**As a** product owner,
**I want to** track processing time for different file sizes,
**So that** I can optimize performance and set user expectations.

**Acceptance Criteria:**
- [ ] Processing time is measured from operation start to completion
- [ ] Time is logged to console (not sent to analytics)
- [ ] For files >100MB, display estimated time before processing: "Geschatzte Dauer: ~2 Minuten"
- [ ] If processing takes >30 seconds, show progress update: "Verarbeitung lauft noch..."
- [ ] Processing times are categorized: <1s, 1-5s, 5-30s, 30s-2min, >2min

**Technical Hints:**
- Use performance.now() for precise timing
- Calculate estimates based on file size (e.g., 1MB = ~1 second heuristic)
- Store timing data locally for future estimate improvements
- Consider showing cancel button for very long operations (post-MVP)

**Story Points:** 2
**Priority:** Low
**Dependencies:** [US-011]
**Category:** Analytics
