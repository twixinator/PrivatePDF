# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

PrivatPDF is a privacy-focused PDF manipulation web application targeting the DACH market (Germany, Austria, Switzerland). The core value proposition is 100% client-side PDF processing - no files are uploaded to servers, ensuring GDPR compliance and data privacy.

**Status**: Pre-development/planning phase. The `Idea.md` file contains the full project blueprint.

## Technology Stack

- **Framework**: Flutter Web (cross-platform)
- **PDF Processing**: `pdf-lib` (JavaScript via interop) or `syncfusion_flutter_pdf`
- **Deployment**: Vercel or Netlify (static hosting)
- **Architecture**: Purely client-side, no backend required

## Build Commands

Once Flutter is set up:
```bash
flutter pub get          # Install dependencies
flutter run -d chrome    # Run in Chrome
flutter build web        # Build for production
flutter test             # Run tests
```

## MVP Features

Must-have:
- PDF Merge (combine multiple PDFs)
- PDF Split (separate pages)
- Password protection
- 100% client-side processing

Nice-to-have:
- PDF compression
- OCR (text recognition)
- E-signature (hand-drawn)
- Dark mode

## Architecture Notes

- All PDF operations must run in the browser using JavaScript interop or Flutter PDF libraries
- No server uploads - this is the core differentiator
- PWA support for "Add to Desktop" functionality
- File size limit: 5MB for free tier
- Performance warning needed for large files (>500MB)

## Design Direction

- Clean, pastel-colored aesthetic ("soft/aesthetic" positioning)
- German-language UI targeting DACH region
- Trust indicators: "Verarbeitung auf deinem Computer..." messaging
- Prominent "Open Source" link to build trust
