# UI/UX & User Flow User Stories

---

## [US-021] Landing Page Design
**As a** first-time visitor,
**I want to** immediately understand what PrivatPDF does and why it's trustworthy,
**So that** I can quickly decide if it solves my problem.

**Acceptance Criteria:**
- [ ] Hero section includes: headline, value proposition, primary CTA button
- [ ] Headline in German: "PDF bearbeiten - 100% privat & lokal"
- [ ] Value proposition highlights: "Keine Uploads. Keine Cloud. Deine Daten bleiben auf deinem Gerat."
- [ ] Primary CTA: "Jetzt kostenlos starten" linking to tool selection
- [ ] Trust indicators displayed: "Open Source" link, "DSGVO-konform" badge, "Lokal verarbeitet" icon
- [ ] Clean, pastel-colored aesthetic with soft gradients
- [ ] Responsive design works on mobile (320px) to desktop (1920px+)

**Technical Hints:**
- Use Flutter's responsive layout widgets (LayoutBuilder, MediaQuery)
- Implement custom pastel color scheme (define in theme)
- Consider using flutter_svg for icons and badges
- Test on multiple screen sizes using browser DevTools

**Story Points:** 5
**Priority:** Critical
**Dependencies:** [US-001], [US-006]
**Category:** UI/UX

---

## [US-022] Tool Selection Interface
**As a** user,
**I want to** easily select which PDF operation I want to perform,
**So that** I can quickly access the feature I need.

**Acceptance Criteria:**
- [ ] Three tool cards displayed: "PDF zusammenfuhren", "PDF aufteilen", "PDF schutzen"
- [ ] Each card shows: icon, title, brief description (1 sentence)
- [ ] Cards are clickable and navigate to respective tool pages
- [ ] Hover effect on cards (subtle shadow or scale)
- [ ] Cards use pastel colors matching brand (different color per tool)
- [ ] Grid layout: 3 columns on desktop, 1 column on mobile

**Technical Hints:**
- Create reusable ToolCard widget component
- Use go_router to navigate to /merge, /split, /protect
- Implement hover animations with Flutter AnimatedContainer
- Store tool metadata (title, description, route, icon) in constants

**Story Points:** 3
**Priority:** Critical
**Dependencies:** [US-006], [US-021]
**Category:** UI/UX

---

## [US-023] PDF Merge Page UI
**As a** user,
**I want to** access a dedicated merge page with clear instructions,
**So that** I understand how to combine my PDFs.

**Acceptance Criteria:**
- [ ] Page title: "PDF zusammenfuhren"
- [ ] Instructions: "Wahle mehrere PDF-Dateien aus (2-10), um sie zu einer Datei zu kombinieren."
- [ ] File upload area with drag-and-drop zone (dashed border)
- [ ] "Dateien auswahlen" button for file picker
- [ ] Uploaded file list with reorder functionality
- [ ] "Zusammenfuhren" button (disabled until 2+ files uploaded)
- [ ] Back button to return to tool selection
- [ ] Free tier notice: "Kostenlos bis 5MB"

**Technical Hints:**
- Use DragTarget widget for drag-and-drop zone
- Implement ReorderableListView for file list
- Disable merge button until files.length >= 2
- Show total file size indicator above merge button

**Story Points:** 5
**Priority:** Critical
**Dependencies:** [US-010], [US-017], [US-021]
**Category:** UI/UX

---

## [US-024] PDF Split Page UI
**As a** user,
**I want to** access a dedicated split page with page selection interface,
**So that** I can extract specific pages from my PDF.

**Acceptance Criteria:**
- [ ] Page title: "PDF aufteilen"
- [ ] Instructions: "Lade eine PDF-Datei hoch und wahle die Seiten aus, die du extrahieren mochtest."
- [ ] File upload area (single file only)
- [ ] After upload, display total page count
- [ ] Page range input field with placeholder: "z.B. 1-3, 5, 7-9"
- [ ] Input validation with real-time feedback (valid/invalid range)
- [ ] "Seiten extrahieren" button (disabled until valid range entered)
- [ ] Back button to return to tool selection

**Technical Hints:**
- Implement page range parser (handle comma-separated ranges)
- Validate ranges against actual page count from uploaded PDF
- Show red border on input for invalid ranges
- Display helpful error messages for common mistakes (page 0, page > total, etc.)

**Story Points:** 5
**Priority:** Critical
**Dependencies:** [US-010], [US-021]
**Category:** UI/UX

---

## [US-025] PDF Password Protection Page UI
**As a** user,
**I want to** access a dedicated password protection page with secure input,
**So that** I can encrypt my PDF with a password.

**Acceptance Criteria:**
- [ ] Page title: "PDF schutzen"
- [ ] Instructions: "Lade eine PDF-Datei hoch und vergib ein Passwort zum Schutz."
- [ ] File upload area (single file only)
- [ ] Password input field (obscured text, toggle visibility button)
- [ ] Password confirmation field
- [ ] Password strength indicator (weak/medium/strong)
- [ ] Minimum length requirement: 6 characters
- [ ] "PDF schutzen" button (disabled until passwords match and meet minimum length)
- [ ] Back button to return to tool selection

**Technical Hints:**
- Use TextField with obscureText: true
- Implement password strength algorithm (length, complexity)
- Show visual feedback when passwords don't match (red border)
- Add "eye" icon button to toggle password visibility

**Story Points:** 3
**Priority:** Critical
**Dependencies:** [US-010], [US-021]
**Category:** UI/UX

---

## [US-026] Responsive Navigation Header
**As a** user,
**I want to** navigate between pages using a consistent header,
**So that** I can easily access different sections of the application.

**Acceptance Criteria:**
- [ ] Header displayed on all pages with: logo, navigation links, CTA button
- [ ] Navigation links: Home, Tools (dropdown: Merge, Split, Protect), Pricing
- [ ] Right-side CTA: "Upgrade auf Pro" (links to pricing) or "Account" (if logged in)
- [ ] Mobile: hamburger menu for navigation (collapsible drawer)
- [ ] Header sticks to top on scroll (fixed position)
- [ ] Current page is visually highlighted in navigation

**Technical Hints:**
- Create AppBarWidget as reusable component
- Use Drawer widget for mobile navigation
- Implement sticky header with positioned widget
- Store current route in state to highlight active nav item

**Story Points:** 3
**Priority:** High
**Dependencies:** [US-006], [US-021]
**Category:** UI/UX

---

## [US-027] Footer with Trust Signals
**As a** user,
**I want to** see trust indicators and legal information in the footer,
**So that** I feel confident using the service.

**Acceptance Criteria:**
- [ ] Footer displayed on all pages
- [ ] Links included: Impressum, Datenschutz, AGB, Kontakt
- [ ] "Open Source" link to GitHub repository (when available)
- [ ] Copyright notice: "© 2026 PrivatPDF - Made in Germany"
- [ ] Trust badges: "DSGVO-konform", "100% lokal verarbeitet"
- [ ] Footer background uses subtle pastel color

**Technical Hints:**
- Create FooterWidget as reusable component
- Legal pages (Impressum, Datenschutz, AGB) can be placeholders for MVP
- Open Source link can point to public GitHub repo
- Use Row/Column layout with responsive wrapping

**Story Points:** 2
**Priority:** Medium
**Dependencies:** [US-021]
**Category:** UI/UX

---

## [US-028] Pricing Page
**As a** potential customer,
**I want to** see clear pricing tiers and features,
**So that** I can decide if I want to upgrade to Pro.

**Acceptance Criteria:**
- [ ] Two pricing tiers displayed: Free and Pro (Business tier excluded from MVP)
- [ ] Free tier: €0.00, features listed ("Alle Tools", "Bis 5MB pro Datei", "Keine Registrierung")
- [ ] Pro tier: €19.00 einmalig (Lifetime), features listed ("Unbegrenzte Dateigrosse", "Prioritat-Support", "Alle zukunftigen Features")
- [ ] "Jetzt upgraden" CTA button for Pro tier
- [ ] Visual comparison table (checkmarks for included features)
- [ ] FAQ section: "Warum Lifetime?" "Sind meine Daten sicher?" "Kann ich testen?"

**Technical Hints:**
- Create PricingCard widget component
- Use DataTable or custom layout for feature comparison
- Link "Jetzt upgraden" to login page (authentication not implemented yet)
- Consider adding testimonials section (post-MVP)

**Story Points:** 3
**Priority:** High
**Dependencies:** [US-006], [US-021]
**Category:** UI/UX

---

## [US-029] Loading and Success States
**As a** user,
**I want to** see clear visual feedback during and after processing,
**So that** I know when my PDF is ready.

**Acceptance Criteria:**
- [ ] Loading state: full-screen overlay with spinner and text "Verarbeitung auf deinem Computer..."
- [ ] Progress indicator shows percentage if calculable
- [ ] Success state: checkmark icon with message "Fertig! Deine Datei wird heruntergeladen..."
- [ ] Success message auto-dismisses after 3 seconds
- [ ] Success message includes "Neue Datei bearbeiten" button to restart

**Technical Hints:**
- Use Stack widget for overlay
- Implement modal barrier to prevent interaction during processing
- Use AnimatedOpacity for fade-in/fade-out transitions
- Auto-dismiss with Timer after success

**Story Points:** 2
**Priority:** High
**Dependencies:** [US-011]
**Category:** UI/UX

---

## [US-030] Error State UI Components
**As a** user,
**I want to** see clear, actionable error messages when something goes wrong,
**So that** I understand what happened and how to fix it.

**Acceptance Criteria:**
- [ ] Error messages displayed in red/warning color with icon
- [ ] Errors are shown as dismissible banners or dialog boxes
- [ ] Common errors have specific German messages (file too large, invalid PDF, etc.)
- [ ] Generic error fallback: "Ein Fehler ist aufgetreten. Bitte versuche es erneut."
- [ ] Error messages include actionable next steps when possible
- [ ] Errors auto-dismiss after 10 seconds or user clicks dismiss

**Technical Hints:**
- Create ErrorBanner widget component
- Use SnackBar or custom positioned widget for errors
- Store error messages in constants file for easy translation
- Implement error boundary pattern for unexpected errors

**Story Points:** 2
**Priority:** High
**Dependencies:** [US-021]
**Category:** UI/UX

---

## [US-031] German Language Content
**As a** DACH market user,
**I want to** see all interface text in German,
**So that** I can use the application in my native language.

**Acceptance Criteria:**
- [ ] All UI text is in German (buttons, labels, instructions, errors)
- [ ] German uses formal "Sie" form (not informal "du") for professionalism
- [ ] Date formats follow German standard (DD.MM.YYYY)
- [ ] Number formats use German conventions (comma for decimal separator)
- [ ] Umlauts (a, o, u) and eszett (ss) are properly displayed
- [ ] No English text appears in user-facing UI

**Technical Hints:**
- Hardcode German strings directly in widgets (no i18n package needed for MVP)
- Use intl package for date/number formatting with German locale
- Create constants file for all user-facing strings
- Test rendering of special characters across browsers

**Story Points:** 2
**Priority:** Critical
**Dependencies:** All UI stories
**Category:** UI/UX
