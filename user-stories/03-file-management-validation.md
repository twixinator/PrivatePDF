# File Management & Validation User Stories

---

## [US-014] Free Tier 5MB File Size Enforcement
**As a** product owner,
**I want to** enforce a 5MB file size limit for free tier users before processing,
**So that** we can differentiate free and paid tiers while maintaining performance.

**Acceptance Criteria:**
- [ ] File size is checked immediately after upload
- [ ] Files exceeding 5MB show German error message: "Datei zu gros (max. 5MB). Upgrade auf Pro fur unbegrenzte Grose."
- [ ] Error message includes "Upgrade auf Pro" CTA button linking to pricing page
- [ ] For merge operations, TOTAL combined size must be under 5MB
- [ ] Pro tier users (post-authentication implementation) bypass this check
- [ ] File size is displayed in human-readable format (KB/MB)

**Technical Hints:**
- Check file size from uploaded file's bytes.length
- For merge, sum all file sizes before processing
- Store size limit as configurable constant (easy to adjust)
- Display file sizes with intl package for German number formatting

**Story Points:** 2
**Priority:** Critical
**Dependencies:** [US-010]
**Category:** File Management

---

## [US-015] Large File Warning (>500MB)
**As a** user,
**I want to** receive a warning when processing files larger than 500MB,
**So that** I can decide whether to proceed knowing it may take time or use resources.

**Acceptance Criteria:**
- [ ] Files >500MB trigger advisory warning dialog in German
- [ ] Warning message: "Diese Datei ist sehr gros (>500MB). Die Verarbeitung kann einige Minuten dauern. Fortfahren?"
- [ ] User can click "Abbrechen" to cancel or "Fortfahren" to proceed
- [ ] Warning is informational only - does not prevent processing
- [ ] Pro tier users see this warning (not bypassed)

**Technical Hints:**
- Show warning as modal dialog with two action buttons
- This applies to Pro users, so implement regardless of tier
- Consider showing estimated processing time based on file size (post-MVP enhancement)

**Story Points:** 1
**Priority:** Low
**Dependencies:** [US-010]
**Category:** File Management

---

## [US-016] PDF File Type Validation
**As a** user,
**I want to** only be able to upload valid PDF files,
**So that** I don't encounter errors from incompatible file types.

**Acceptance Criteria:**
- [ ] File MIME type is validated (must be "application/pdf")
- [ ] File extension is validated (must be .pdf, case-insensitive)
- [ ] Invalid files show German error: "Nur PDF-Dateien sind erlaubt"
- [ ] Corrupted PDFs show specific error: "PDF-Datei ist beschadigt oder unlesbar"
- [ ] Validation happens before any processing begins
- [ ] User can upload a different file after error

**Technical Hints:**
- Check MIME type from file picker metadata
- Attempt to load PDF with Syncfusion library to detect corruption
- Wrap PDF loading in try-catch for corruption detection
- Test with intentionally corrupted PDFs and non-PDF files renamed to .pdf

**Story Points:** 2
**Priority:** High
**Dependencies:** [US-010]
**Category:** File Management

---

## [US-017] Uploaded File List Management
**As a** user,
**I want to** see, reorder, and remove uploaded files before processing,
**So that** I can ensure the correct files are processed in the right order.

**Acceptance Criteria:**
- [ ] Uploaded files are displayed in a list showing: filename, size, remove button
- [ ] User can remove individual files by clicking X/trash icon
- [ ] User can clear all files with "Alle entfernen" button
- [ ] For merge operations, user can reorder files via drag-and-drop
- [ ] File order is visually indicated (numbering: 1, 2, 3...)
- [ ] Empty state shows when no files are uploaded

**Technical Hints:**
- Use Flutter ReorderableListView for drag-and-drop reordering (merge only)
- Store files in ordered list in state management
- Show file size using human-readable format (KB/MB)
- Merge order = list order (critical for correct merge output)

**Story Points:** 3
**Priority:** High
**Dependencies:** [US-010]
**Category:** File Management

---

## [US-018] Memory Management and Cleanup
**As a** developer,
**I want to** properly manage memory for uploaded and processed files,
**So that** the application doesn't crash or slow down from memory leaks.

**Acceptance Criteria:**
- [ ] Uploaded file data is cleared after processing completes
- [ ] PdfDocument objects are properly disposed after use
- [ ] Processed PDF data is cleared after download
- [ ] User can process multiple files in sequence without page reload
- [ ] Memory usage stays stable across multiple operations (verify in browser DevTools)
- [ ] No "out of memory" errors for typical use (5 merges of 5MB files)

**Technical Hints:**
- Call dispose() on all PdfDocument instances
- Clear Uint8List data from state after processing
- Test memory with Chrome DevTools Memory Profiler
- Consider implementing manual garbage collection hints if needed

**Story Points:** 3
**Priority:** High
**Dependencies:** [US-007], [US-008], [US-009], [US-012]
**Category:** File Management

---

## [US-019] File Name Sanitization
**As a** developer,
**I want to** sanitize output filenames,
**So that** downloaded files have valid names across all operating systems.

**Acceptance Criteria:**
- [ ] Output filenames remove special characters (/, \, :, *, ?, ", <>, |)
- [ ] Filenames are limited to 255 characters maximum
- [ ] Spaces are replaced with underscores or hyphens
- [ ] Umlauts (a, o, u) are preserved for German users
- [ ] Default filename pattern: [operation]_YYYY-MM-DD_HHmmss.pdf
- [ ] User cannot customize filename in MVP (post-MVP feature)

**Technical Hints:**
- Create sanitizeFilename() utility function
- Use RegExp to remove invalid characters
- Preserve Unicode characters for proper German support
- Test filenames on Windows, macOS, Linux

**Story Points:** 1
**Priority:** Medium
**Dependencies:** [US-012]
**Category:** File Management

---

## [US-020] Concurrent Processing Prevention
**As a** user,
**I want to** only process one operation at a time,
**So that** I avoid confusion and potential errors from simultaneous operations.

**Acceptance Criteria:**
- [ ] When processing starts, all action buttons are disabled
- [ ] User cannot upload new files during processing
- [ ] Processing overlay blocks interaction with underlying UI
- [ ] After processing completes, UI re-enables and is ready for next operation
- [ ] Clear visual feedback shows "processing" state

**Technical Hints:**
- Use global processing state flag (isProcessing: bool)
- Disable file picker and action buttons when isProcessing = true
- Show modal overlay or full-screen loading state
- Reset state after download completes

**Story Points:** 2
**Priority:** Medium
**Dependencies:** [US-011]
**Category:** File Management
