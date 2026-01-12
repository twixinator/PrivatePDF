# Font Setup Guide

The PrivatPDF design uses two carefully selected typefaces that create a Modern Editorial aesthetic:

## 📚 Font Families

### 1. **Cormorant** (Display/Headline Font)
- **Style**: Elegant serif
- **Usage**: Headlines, page titles, hero text
- **Weights Needed**: 300, 400, 500, 600, 700
- **Download**: [Google Fonts - Cormorant](https://fonts.google.com/specimen/Cormorant)

### 2. **Inter** (Body/UI Font)
- **Style**: Refined sans-serif
- **Usage**: Body text, UI elements, labels
- **Weights Needed**: 400, 500, 600
- **Download**: [Google Fonts - Inter](https://fonts.google.com/specimen/Inter)

## 🎯 Why These Fonts?

**Cormorant** provides sophisticated, magazine-quality display text with:
- High contrast strokes for visual impact
- Elegant letterforms that convey trustworthiness
- Excellent readability at large sizes

**Inter** offers modern, clean body text with:
- Optimized for screen reading
- Professional without being generic
- Great letter spacing for German text (umlauts, ß)

## 📥 Installation Steps

### Option 1: Download from Google Fonts (Recommended)

1. **Download Cormorant**:
   - Go to https://fonts.google.com/specimen/Cormorant
   - Click "Download family"
   - Extract the ZIP file
   - Copy these files to `assets/fonts/`:
     - `Cormorant-Light.ttf` (weight 300)
     - `Cormorant-Regular.ttf` (weight 400)
     - `Cormorant-Medium.ttf` (weight 500)
     - `Cormorant-SemiBold.ttf` (weight 600)
     - `Cormorant-Bold.ttf` (weight 700)

2. **Download Inter**:
   - Go to https://fonts.google.com/specimen/Inter
   - Click "Download family"
   - Extract the ZIP file
   - Copy these files to `assets/fonts/`:
     - `Inter-Regular.ttf` (weight 400)
     - `Inter-Medium.ttf` (weight 500)
     - `Inter-SemiBold.ttf` (weight 600)

### Option 2: Use Web Fonts (Fallback)

If you want to skip local font installation during development, the fonts will load from Google Fonts CDN (already configured in `web/index.html`). However, for production builds, local fonts are recommended for:
- Better performance (no external requests)
- Offline support (PWA requirement)
- GDPR compliance (no Google tracking)

## 📁 Directory Structure

After setup, your font directory should look like:

```
assets/
└── fonts/
    ├── Cormorant-Light.ttf
    ├── Cormorant-Regular.ttf
    ├── Cormorant-Medium.ttf
    ├── Cormorant-SemiBold.ttf
    ├── Cormorant-Bold.ttf
    ├── Inter-Regular.ttf
    ├── Inter-Medium.ttf
    └── Inter-SemiBold.ttf
```

## ✅ Verification

After adding fonts, verify the setup:

```bash
# 1. Clean Flutter cache
flutter clean

# 2. Get dependencies
flutter pub get

# 3. Run the app
flutter run -d chrome

# 4. Check in browser DevTools
# - Open Chrome DevTools → Elements → Computed
# - Select any text element
# - Verify font-family shows "Cormorant" or "Inter"
```

### Visual Check

The fonts should appear like this:
- **Headlines**: Elegant serif with high contrast (Cormorant)
- **Body text**: Clean, modern sans-serif (Inter)
- **Logo "P"**: Bold serif character in square container

## 🔧 Troubleshooting

### Fonts Not Loading

**Problem**: Text appears in system default font

**Solutions**:
1. Check file names match exactly (case-sensitive)
2. Verify files are in `assets/fonts/` directory
3. Run `flutter clean && flutter pub get`
4. Check `pubspec.yaml` has correct font declarations
5. Restart the app completely

### Wrong Font Weights

**Problem**: All text appears in same weight

**Solutions**:
1. Ensure all weight files are present
2. Check font file names match pubspec.yaml
3. Verify weight numbers in theme (300, 400, 500, 600, 700)

### German Characters (ä, ö, ü, ß) Not Displaying

**Problem**: Umlauts show as boxes or fallback characters

**Solutions**:
1. Both Cormorant and Inter support German characters
2. Check you downloaded complete font families (not subsets)
3. Verify UTF-8 encoding in string files

## 🎨 Using Fonts in Code

Fonts are automatically applied via the theme system. You don't need to specify them manually:

```dart
// Headlines automatically use Cormorant
Text(
  'Überschrift',
  style: Theme.of(context).textTheme.displayLarge,
)

// Body text automatically uses Inter
Text(
  'Fließtext hier...',
  style: Theme.of(context).textTheme.bodyMedium,
)

// Override if needed
Text(
  'Custom text',
  style: TextStyle(
    fontFamily: 'Cormorant',  // or 'Inter'
    fontSize: 24,
    fontWeight: FontWeight.w600,
  ),
)
```

## 📊 Font Performance

### File Sizes (Approximate)
- Cormorant: ~150KB per weight (~750KB total)
- Inter: ~100KB per weight (~300KB total)
- **Total**: ~1.05MB

### Load Time Impact
- First load: ~0.5s additional (cached after)
- PWA: Fonts cached, instant subsequent loads

### Optimization Tips
1. **Subset fonts** for production (German characters only)
2. **Preload** critical weights in index.html
3. **Font-display: swap** in CSS (already configured)

## 🌐 Licensing

Both fonts are **Open Source** and **free for commercial use**:

- **Cormorant**: [SIL Open Font License 1.1](https://scripts.sil.org/OFL)
- **Inter**: [SIL Open Font License 1.1](https://scripts.sil.org/OFL)

You can use them freely in PrivatPDF without attribution (though appreciated).

## 💡 Alternative Fonts

If you prefer different fonts, consider these editorial-style alternatives:

### Serif Alternatives to Cormorant:
- **Lora** - Elegant, slightly calligraphic
- **Playfair Display** - High contrast, dramatic
- **Fraunces** - Variable font, modern serif

### Sans-Serif Alternatives to Inter:
- **Satoshi** - Geometric, clean
- **Cabinet Grotesk** - Sophisticated, editorial
- **Instrument Sans** - Modern, refined

To change fonts:
1. Download new font files
2. Place in `assets/fonts/`
3. Update font family names in `pubspec.yaml`
4. Update font family in `lib/theme/app_theme.dart`

---

**Questions?** Check the main FRONTEND_README.md or open an issue.
