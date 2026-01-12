# Authentication & Payment User Stories

---

## [US-032] User Registration (Email/Password)
**As a** user,
**I want to** create an account with email and password,
**So that** I can upgrade to Pro tier and access premium features.

**Acceptance Criteria:**
- [ ] Registration form includes: email, password, password confirmation fields
- [ ] Email validation: must be valid email format
- [ ] Password validation: minimum 8 characters, at least one letter and one number
- [ ] Passwords must match between password and confirmation fields
- [ ] "Konto erstellen" button triggers registration
- [ ] User receives email verification link (using Firebase Auth or similar)
- [ ] After successful registration, user is redirected to dashboard/account page
- [ ] Duplicate email shows error: "Diese E-Mail ist bereits registriert"

**Technical Hints:**
- Use Firebase Authentication or Supabase Auth for backend
- Implement email/password provider
- Store user tier (free/pro) in user metadata or separate database
- Do NOT implement social login for MVP (post-MVP feature)

**Story Points:** 5
**Priority:** High
**Dependencies:** [US-006]
**Category:** Authentication

---

## [US-033] User Login
**As a** registered user,
**I want to** log in to my account,
**So that** I can access Pro features if I've upgraded.

**Acceptance Criteria:**
- [ ] Login form includes: email, password fields
- [ ] "Anmelden" button triggers authentication
- [ ] Successful login redirects to account dashboard
- [ ] Failed login shows error: "Ungultige E-Mail oder Passwort"
- [ ] "Passwort vergessen?" link navigates to password reset page
- [ ] User session persists across page refreshes (using tokens/cookies)
- [ ] Logged-in users see "Mein Konto" in header instead of "Anmelden"

**Technical Hints:**
- Use Firebase Auth signInWithEmailAndPassword()
- Store authentication token in browser localStorage
- Implement auth state listener to maintain session
- Add navigation guard for protected routes (account page)

**Story Points:** 3
**Priority:** High
**Dependencies:** [US-032]
**Category:** Authentication

---

## [US-034] Password Reset Flow
**As a** user who forgot my password,
**I want to** reset my password via email,
**So that** I can regain access to my account.

**Acceptance Criteria:**
- [ ] Password reset page has email input field
- [ ] "Zurucksetzen-Link senden" button sends password reset email
- [ ] User receives email with password reset link
- [ ] Clicking link opens password reset page with token validation
- [ ] User enters new password (minimum 8 characters)
- [ ] Successful reset shows confirmation and redirects to login
- [ ] Invalid/expired token shows error: "Link ist abgelaufen oder ungultig"

**Technical Hints:**
- Use Firebase Auth sendPasswordResetEmail()
- Implement password reset page at route /reset-password
- Handle token validation from email link
- Add password strength indicator on reset form

**Story Points:** 3
**Priority:** Medium
**Dependencies:** [US-033]
**Category:** Authentication

---

## [US-035] User Account Dashboard
**As a** logged-in user,
**I want to** view my account information and tier status,
**So that** I can manage my subscription and settings.

**Acceptance Criteria:**
- [ ] Account page shows: email address, current tier (Free/Pro), account created date
- [ ] Pro users see: "Pro-Mitglied seit [date]", lifetime access badge
- [ ] Free users see: "Upgrade auf Pro" CTA button
- [ ] "Abmelden" (logout) button available
- [ ] Account page is only accessible when logged in
- [ ] Unauthenticated users redirected to login page

**Technical Hints:**
- Create protected route with authentication guard
- Fetch user data from authentication provider
- Display tier information from user metadata
- Implement logout functionality (clear tokens, redirect to home)

**Story Points:** 3
**Priority:** High
**Dependencies:** [US-033]
**Category:** Authentication

---

## [US-036] Stripe Payment Integration
**As a** user,
**I want to** purchase the Pro tier via Stripe,
**So that** I can unlock unlimited file size and premium features.

**Acceptance Criteria:**
- [ ] "Jetzt upgraden" button on pricing page redirects to Stripe Checkout
- [ ] Stripe Checkout shows: €19.00 one-time payment for "PrivatPDF Pro - Lifetime"
- [ ] Payment methods accepted: credit card, SEPA, PayPal (via Stripe)
- [ ] Successful payment triggers webhook to upgrade user tier
- [ ] User tier is updated in database (free → pro)
- [ ] After payment, user redirected to success page showing confirmation
- [ ] Failed payment shows error and allows retry

**Technical Hints:**
- Use Stripe Checkout (hosted page) for simplicity - no custom payment form needed
- Create Stripe product: "PrivatPDF Pro Lifetime" with one-time price €19.00
- Implement webhook endpoint to handle checkout.session.completed event
- Store Stripe customer ID in user record for future reference
- Test with Stripe test mode cards

**Story Points:** 8
**Priority:** High
**Dependencies:** [US-033], [US-035]
**Category:** Payment

---

## [US-037] Payment Success and Tier Upgrade
**As a** user who completed payment,
**I want to** immediately see my Pro tier activated,
**So that** I can use unlimited file size features.

**Acceptance Criteria:**
- [ ] After Stripe payment, user redirected to /payment/success page
- [ ] Success page shows: checkmark icon, "Willkommen bei Pro!" message
- [ ] User tier is updated in real-time (no logout required)
- [ ] 5MB file size limit is removed for this user
- [ ] Account dashboard shows "Pro-Mitglied" badge
- [ ] User receives confirmation email with receipt

**Technical Hints:**
- Stripe webhook updates user tier in database
- Frontend polls user tier after payment redirect (or use WebSocket for real-time update)
- Implement tier check in file size validation logic
- Send confirmation email via Stripe (automatic receipt) or custom email service

**Story Points:** 5
**Priority:** High
**Dependencies:** [US-036]
**Category:** Payment

---

## [US-038] Free Tier Anonymous Usage
**As a** free tier user,
**I want to** use all PDF tools without creating an account,
**So that** I can quickly process files without friction.

**Acceptance Criteria:**
- [ ] All PDF tools (merge, split, protect) work without login
- [ ] 5MB file size limit is enforced for anonymous users
- [ ] No email or registration required for basic usage
- [ ] "Upgrade auf Pro" prompts shown when hitting 5MB limit
- [ ] Anonymous users do NOT have access to account dashboard
- [ ] Processing works identically for anonymous and free tier registered users

**Technical Hints:**
- This is default behavior - no authentication check needed for tools
- File size validation checks: if (user is authenticated AND user.tier == 'pro') bypass limit
- Anonymous users see limited header navigation (no "Mein Konto")

**Story Points:** 1
**Priority:** Critical
**Dependencies:** [US-014]
**Category:** Authentication

---

## [US-039] Logout Functionality
**As a** logged-in user,
**I want to** log out of my account,
**So that** I can secure my session on shared devices.

**Acceptance Criteria:**
- [ ] "Abmelden" button available in account dashboard and header dropdown
- [ ] Clicking logout clears authentication tokens
- [ ] User is redirected to home page after logout
- [ ] Attempting to access /account after logout redirects to /login
- [ ] Logout confirmation message: "Du wurdest erfolgreich abgemeldet"

**Technical Hints:**
- Clear localStorage authentication token
- Call Firebase Auth signOut() method
- Reset global authentication state
- Show brief success message before redirect

**Story Points:** 1
**Priority:** Medium
**Dependencies:** [US-033]
**Category:** Authentication

---

## [US-040] User Tier Validation in File Processing
**As a** product owner,
**I want to** enforce tier-based restrictions during PDF processing,
**So that** free users are limited to 5MB and Pro users have unlimited access.

**Acceptance Criteria:**
- [ ] Before processing, check if user is authenticated
- [ ] If authenticated, check user.tier from database
- [ ] Free tier users: enforce 5MB limit
- [ ] Pro tier users: bypass 5MB limit, allow unlimited file size
- [ ] Anonymous users: treated as free tier (5MB limit)
- [ ] Tier check happens client-side (no backend needed)

**Technical Hints:**
- Create utility function: canProcessFile(fileSize, userTier)
- Fetch user tier from authentication provider user metadata
- Cache tier information to avoid repeated API calls
- For MVP, trust client-side validation (server-side validation post-MVP)

**Story Points:** 2
**Priority:** High
**Dependencies:** [US-037], [US-014]
**Category:** Authentication
