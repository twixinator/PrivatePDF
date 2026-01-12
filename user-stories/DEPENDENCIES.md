# PrivatPDF User Story Dependencies - Visual Map

This document provides a visual representation of story dependencies to help with sprint planning and identifying critical paths.

---

## Dependency Layers (Bottom-Up)

```
LAYER 0: FOUNDATION (No Dependencies)
=========================================
[US-001] Flutter Web Project Init
    |
    +--- [US-004] Dev Environment Config
    |
    +--- [US-045] Error Logging & Monitoring

LAYER 1: INFRASTRUCTURE (Depends on US-001)
============================================
[US-001] -----> [US-002] Syncfusion PDF Integration ***CRITICAL***
            |
            +-> [US-003] Static Hosting Setup
            |
            +-> [US-005] State Management Setup
            |
            +-> [US-006] Routing & Navigation
            |
            +-> [US-010] File Upload Handler

LAYER 2: CORE PDF FEATURES (Depends on US-002 + US-010)
========================================================
[US-002] + [US-010] -----> [US-007] PDF Merge ***CRITICAL***
                      |
                      +---> [US-008] PDF Split ***CRITICAL***
                      |
                      +---> [US-009] PDF Password Protect ***CRITICAL***

LAYER 3: PROCESSING SUPPORT (Depends on Layer 2)
=================================================
[US-007] + [US-008] + [US-009] -----> [US-011] Progress Indicator
                                 |
                                 +---> [US-012] Download Handler
                                 |
                                 +---> [US-013] Client-Side Verification
                                 |
                                 +---> [US-018] Memory Management

LAYER 4: FILE MANAGEMENT (Depends on US-010)
=============================================
[US-010] -----> [US-014] 5MB File Size Limit ***CRITICAL***
           |
           +---> [US-016] PDF File Type Validation
           |
           +---> [US-017] Uploaded File List Management
           |
           +---> [US-019] File Name Sanitization
           |
           +---> [US-015] Large File Warning (>500MB)

LAYER 5: UI FOUNDATION (Depends on US-001 + US-006)
====================================================
[US-001] + [US-006] -----> [US-021] Landing Page Design ***CRITICAL***
                      |
                      +---> [US-031] German Language Content ***CRITICAL***

LAYER 6: UI PAGES (Depends on Layer 5)
=======================================
[US-021] -----> [US-022] Tool Selection Interface ***CRITICAL***
           |
           +---> [US-026] Navigation Header
           |
           +---> [US-027] Footer with Trust Signals
           |
           +---> [US-028] Pricing Page
           |
           +---> [US-030] Error State UI Components

[US-021] + [US-010] + [US-017] -----> [US-023] Merge Page UI ***CRITICAL***

[US-021] + [US-010] -----> [US-024] Split Page UI ***CRITICAL***
                      |
                      +---> [US-025] Password Protect Page UI ***CRITICAL***

[US-011] -----> [US-029] Loading & Success States

LAYER 7: AUTHENTICATION (Depends on US-006)
============================================
[US-006] -----> [US-032] User Registration
           |
           [US-032] -----> [US-033] User Login
                      |
                      [US-033] -----> [US-034] Password Reset
                                 |
                                 +---> [US-035] Account Dashboard
                                 |
                                 +---> [US-039] Logout

[US-014] -----> [US-038] Free Tier Anonymous Usage ***CRITICAL***

LAYER 8: PAYMENT (Depends on Authentication)
=============================================
[US-033] + [US-035] -----> [US-036] Stripe Payment Integration
                      |
                      [US-036] -----> [US-037] Payment Success & Tier Upgrade
                                 |
                                 [US-037] + [US-014] -----> [US-040] Tier Validation

LAYER 9: ANALYTICS (Depends on Infrastructure + Features)
==========================================================
[US-001] + [US-003] -----> [US-041] Plausible Analytics Integration
                      |
                      [US-041] + [US-007/008/009] -----> [US-042] Event Tracking
                                                     |
                                                     +---> [US-043] Conversion Tracking
                                                     |
                                                     +---> [US-044] File Size Limit Tracking
                                                     |
                                                     +---> [US-049] Performance Monitoring

LAYER 10: ERROR HANDLING (Depends on UI + Features)
====================================================
[US-030] -----> [US-046] User-Friendly Error Messages
           |
           +---> [US-047] Browser Compatibility Warnings
           |
           +---> [US-048] Network Error Handling

[US-011] -----> [US-020] Concurrent Processing Prevention

LAYER 11: TESTING (Depends on Everything)
==========================================
[US-007] -----> [US-050] Unit Tests: PDF Merge
[US-008] -----> [US-051] Unit Tests: PDF Split
[US-009] -----> [US-052] Unit Tests: Password Protect

[US-007/008/009] + [US-013] -----> [US-057] Security Testing

[US-007/008/009] + [US-021] -----> [US-053] Integration Tests
                              |
                              +---> [US-054] Cross-Browser Testing
                              |
                              +---> [US-055] Mobile Responsiveness Testing
                              |
                              +---> [US-056] Performance Testing

[US-001] + [US-050/051/052] -----> [US-059] CI/CD Pipeline

[ALL STORIES] -----> [US-060] User Acceptance Testing
```

---

## Critical Path Analysis

### Path 1: Core PDF Functionality (Longest Critical Path)
```
US-001 (2pts) → US-002 (3pts) → US-010 (3pts) → US-007 (5pts) → US-012 (2pts) → US-050 (5pts)
```
**Total**: 20 story points, **~4-5 days**

### Path 2: UI/UX Completion
```
US-001 (2pts) → US-006 (2pts) → US-021 (5pts) → US-023 (5pts) → US-031 (2pts)
```
**Total**: 16 story points, **~3-4 days**

### Path 3: Monetization (Payment)
```
US-006 (2pts) → US-032 (5pts) → US-033 (3pts) → US-035 (3pts) → US-036 (8pts) → US-037 (5pts) → US-040 (2pts)
```
**Total**: 28 story points, **~5-6 days**

### Path 4: Analytics & Verification
```
US-001 (2pts) → US-003 (2pts) → US-041 (2pts) → US-042 (3pts)
```
**Total**: 9 story points, **~2 days**

---

## Parallel Work Streams

To maximize efficiency with 2 developers, these stories can be worked on in parallel:

### Week 1 Parallelization
**Developer 1**: US-001 → US-002 → US-007 → US-008 → US-009
**Developer 2**: US-001 → US-005 → US-006 → US-010 → US-012

### Week 2 Parallelization
**Developer 1**: US-014 → US-016 → US-017 → US-018
**Developer 2**: US-021 → US-022 → US-023 → US-024 → US-025

### Week 3 Parallelization
**Developer 1**: US-032 → US-033 → US-036 → US-037
**Developer 2**: US-029 → US-030 → US-046 → US-026 → US-028

### Week 4 Parallelization
**Developer 1**: US-050 → US-051 → US-052 → US-059
**Developer 2**: US-041 → US-042 → US-043 → US-044 → US-053

---

## Blocking Dependencies (Risk Areas)

### High-Risk Blockers
These stories, if delayed, will block multiple downstream stories:

1. **US-002 (Syncfusion Integration)** - Blocks 3 critical stories
   - Blocks: US-007, US-008, US-009
   - Mitigation: Test integration on Day 2, have pdf-lib as backup

2. **US-010 (File Upload Handler)** - Blocks all PDF operations
   - Blocks: US-007, US-008, US-009, US-014, US-016, US-017
   - Mitigation: Build simple version first, enhance later

3. **US-021 (Landing Page)** - Blocks all UI pages
   - Blocks: US-022, US-023, US-024, US-025, US-026
   - Mitigation: Designer provides mockups by Day 7

4. **US-033 (User Login)** - Blocks entire payment flow
   - Blocks: US-036, US-037, US-040
   - Mitigation: Can launch without payment, add later if needed

### Medium-Risk Blockers
5. **US-036 (Stripe Payment)** - Blocks monetization
   - Blocks: US-037, US-040
   - Mitigation: Use Stripe Checkout (hosted), test with test mode early

6. **US-011 (Progress Indicator)** - Blocks UX polish
   - Blocks: US-029, US-020
   - Mitigation: Simple spinner works, enhance later

---

## Stories with No Dependencies (Start Anytime)

These can be worked on whenever capacity is available:
- US-004 (Dev Environment Config)
- US-045 (Error Logging)
- US-031 (German Language - can be done in parallel with UI)
- US-027 (Footer - independent of other UI)
- US-034 (Password Reset - independent of other auth flows)
- US-039 (Logout - simple, can be done anytime after login)
- US-047 (Browser Compatibility Warnings - post-MVP)

---

## Testing Dependencies

Testing stories have unique dependency patterns:

```
Feature Story -----> Unit Test Story -----> Integration Test -----> CI/CD

Example:
US-007 (Merge) --> US-050 (Merge Tests) --> US-053 (Integration) --> US-059 (CI/CD)
```

**Recommendation**: Write unit tests immediately after feature completion, not in batch at the end.

---

## Sprint Dependency Planning

### Sprint 1 (Days 1-7): Foundation
**Prerequisites**: None
**Outputs**: US-001, US-002, US-005, US-006, US-007, US-008, US-009, US-010, US-012
**Enables**: All subsequent sprints

### Sprint 2 (Days 8-14): UI/UX
**Prerequisites**: Sprint 1 complete (US-001, US-006, US-010)
**Outputs**: US-021, US-022, US-023, US-024, US-025, US-031
**Enables**: Sprint 3 (authentication requires UI), Sprint 4 (testing requires UI)

### Sprint 3 (Days 15-21): Monetization
**Prerequisites**: Sprint 2 complete (US-021 for pricing page, US-006 for routing)
**Outputs**: US-032, US-033, US-035, US-036, US-037, US-040
**Enables**: Revenue generation, Pro tier features

### Sprint 4 (Days 22-30): Analytics & Testing
**Prerequisites**: All previous sprints complete
**Outputs**: US-041, US-042, US-050, US-051, US-052, US-053, US-057, US-059
**Enables**: Launch readiness

---

## Dependency Graph Legend

```
[US-XXX] Story Title
    |
    +---> Depends on this story

***CRITICAL*** = Must-have for MVP launch
```

---

## How to Use This Document

1. **For Sprint Planning**: Identify which stories can start immediately (no unmet dependencies)
2. **For Risk Management**: Monitor high-risk blockers closely
3. **For Parallelization**: Assign independent stories to different developers
4. **For Progress Tracking**: Check if blocked stories' dependencies are complete

---

## Dependency Checklist Template

When starting a new story, verify:
- [ ] All dependency stories are marked "Done"
- [ ] Required infrastructure is deployed (if applicable)
- [ ] Required UI mockups are available (if applicable)
- [ ] Required test data/fixtures are prepared (if applicable)
- [ ] No blocking bugs exist in dependency stories

---

This dependency map should be updated if:
- New stories are added to backlog
- Story scope changes significantly
- New dependencies are discovered during development
- Stories are split or merged
