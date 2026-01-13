/// German UI strings for PrivatPDF
/// All user-facing text in formal German ("Sie" form)
class Strings {
  // App
  static const String appName = 'PrivatPDF';
  static const String tagline = 'PDF bearbeiten - 100% privat & lokal';
  static const String copyright = '© 2026 PrivatPDF - Made in Germany';

  // Landing Page
  static const String heroHeadline = 'PDF bearbeiten.\nOhne Kompromisse.';
  static const String heroSubheadline =
      'Keine Uploads. Keine Cloud. Ihre Daten bleiben auf Ihrem Gerät.';
  static const String ctaPrimary = 'Jetzt kostenlos starten';
  static const String ctaSecondary = 'Mehr erfahren';

  // Trust Indicators
  static const String trustOpenSource = 'Open Source';
  static const String trustDsgvo = 'DSGVO-konform';
  static const String trustLocal = 'Lokal verarbeitet';
  static const String trustNoUpload = 'Keine Uploads';

  // Value Propositions
  static const String valuePrivacyTitle = '100% Privatsphäre';
  static const String valuePrivacyDesc =
      'Ihre Dateien verlassen niemals Ihren Computer. Alle Operationen laufen direkt in Ihrem Browser.';
  static const String valueSecurityTitle = 'Maximale Sicherheit';
  static const String valueSecurityDesc =
      'DSGVO-konform ohne Wenn und Aber. Keine Server, keine Logs, keine Tracking-Cookies.';
  static const String valueSpeedTitle = 'Blitzschnell';
  static const String valueSpeedDesc =
      'Keine Wartezeiten durch Uploads. Ihre PDFs werden sofort auf Ihrem Gerät verarbeitet.';

  // Tools
  static const String toolMergeTitle = 'PDF zusammenführen';
  static const String toolMergeDesc = 'Mehrere PDF-Dateien zu einer kombinieren';
  static const String toolSplitTitle = 'PDF aufteilen';
  static const String toolSplitDesc = 'Einzelne Seiten aus PDFs extrahieren';
  static const String toolProtectTitle = 'PDF schützen';
  static const String toolProtectDesc = 'PDF-Dateien mit Passwort verschlüsseln';

  // Navigation
  static const String navHome = 'Start';
  static const String navTools = 'Tools';
  static const String navPricing = 'Preise';
  static const String navAccount = 'Account';
  static const String navUpgrade = 'Upgrade auf Pro';

  // Footer
  static const String footerImpressum = 'Impressum';
  static const String footerDatenschutz = 'Datenschutz';
  static const String footerAgb = 'AGB';
  static const String footerKontakt = 'Kontakt';

  // Merge Page
  static const String mergePageTitle = 'PDF zusammenführen';
  static const String mergeInstructions =
      'Wählen Sie mehrere PDF-Dateien aus (2-10), um sie zu einer Datei zu kombinieren.';
  static const String mergeSelectFiles = 'Dateien auswählen';
  static const String mergeDragDrop = 'Oder ziehen Sie Dateien hierher';
  static const String mergeButton = 'Zusammenführen';
  static const String mergeFreeTierNotice = '100% kostenlos - bis 100MB pro Datei';
  static const String mergeTotalSize = 'Gesamtgröße';
  static const String mergeFileCount = 'Dateien';

  // Split Page
  static const String splitPageTitle = 'PDF aufteilen';
  static const String splitInstructions =
      'Laden Sie eine PDF-Datei hoch und wählen Sie die Seiten aus, die Sie extrahieren möchten.';
  static const String splitSelectFile = 'Datei auswählen';
  static const String splitPageRange = 'Seitenbereiche';
  static const String splitPageRangePlaceholder = 'z.B. 1-3, 5, 7-9';
  static const String splitButton = 'Seiten extrahieren';
  static const String splitTotalPages = 'Gesamtseitenzahl';

  // Protect Page
  static const String protectPageTitle = 'PDF schützen';
  static const String protectInstructions =
      'Laden Sie eine PDF-Datei hoch und vergeben Sie ein Passwort zum Schutz.';
  static const String protectSelectFile = 'Datei auswählen';
  static const String protectPassword = 'Passwort';
  static const String protectPasswordConfirm = 'Passwort wiederholen';
  static const String protectButton = 'PDF schützen';
  static const String protectMinLength = 'Mindestens 6 Zeichen';
  static const String protectStrengthWeak = 'Schwach';
  static const String protectStrengthMedium = 'Mittel';
  static const String protectStrengthStrong = 'Stark';

  // Compress Page
  static const String compressToolTitle = 'PDF komprimieren';
  static const String compressToolDesc = 'Dateigröße durch Bildkompression reduzieren';
  static const String compressPageTitle = 'PDF komprimieren';
  static const String compressInstructions =
      'Laden Sie eine PDF-Datei hoch und wählen Sie die Komprimierungsqualität.';
  static const String compressSelectFile = 'Datei auswählen';
  static const String compressQualityLabel = 'Qualität wählen';
  static const String compressQualityLow = 'Niedrig (50%)';
  static const String compressQualityMedium = 'Mittel (70%)';
  static const String compressQualityHigh = 'Hoch (90%)';
  static const String compressButton = 'PDF komprimieren';
  static const String compressOriginalSize = 'Originalgröße';
  static const String compressCompressedSize = 'Komprimierte Größe';
  static const String compressPercentageSaved = 'Ersparnis';
  static const String compressSuccess = 'PDF erfolgreich komprimiert!';

  // OCR Page (Phase 10.1: Optical Character Recognition)
  static const String ocrToolTitle = 'OCR - Text erkennen';
  static const String ocrToolDesc = 'Text aus Bildern und gescannten PDFs extrahieren';
  static const String ocrPageTitle = 'OCR - Text erkennen';
  static const String ocrInstructions =
      'Laden Sie eine PDF-Datei mit gescannten Seiten hoch, um den Text zu extrahieren.';
  static const String ocrSelectFile = 'PDF auswählen';
  static const String ocrLanguageLabel = 'Sprache wählen';
  static const String ocrLanguageGerman = 'Deutsch (DEU)';
  static const String ocrLanguageEnglish = 'Englisch (ENG)';
  static const String ocrButton = 'Text erkennen';
  static const String ocrProcessing = 'Verarbeite Seite {current} von {total}...';
  static const String ocrProcessingStatus = 'Status: {status}';
  static const String ocrSuccess = 'Text erfolgreich extrahiert!';
  static const String ocrResultTitle = 'Erkannter Text:';
  static const String ocrCopyButton = 'In Zwischenablage kopieren';
  static const String ocrDownloadButton = 'Als Text-Datei herunterladen';
  static const String ocrSearchLabel = 'Suchen im Text...';
  static const String ocrSearchPlaceholder = 'Suchbegriff eingeben';
  static const String ocrNoResults = 'Kein Text gefunden';
  static const String ocrWarningTime =
      'Hinweis: Die Texterkennung kann bei großen Dokumenten einige Minuten dauern.';
  static const String ocrEstimatedTime = 'Geschätzte Zeit: ca. {seconds} Sekunden pro Seite';
  static const String ocrConfidence = 'Genauigkeit: {percent}%';
  static const String ocrPageCount = '{count} Seiten verarbeitet';
  static const String ocrProcessingTime = 'Verarbeitungszeit: {time}';
  static const String ocrCopiedToClipboard = 'Text in Zwischenablage kopiert!';
  static const String ocrLanguageHelper = 'Wählen Sie die Sprache des Dokuments für bessere Ergebnisse';
  static const String ocrQualityTip = 'Tipp: Hochauflösende Scans liefern bessere Ergebnisse';
  static const String ocrNewScan = 'Neue Datei scannen';

  // Processing States
  static const String processingTitle = 'Verarbeitung läuft...';
  static const String processingMessage = 'Verarbeitung auf Ihrem Computer...';
  static const String successTitle = 'Fertig!';
  static const String successMessage = 'Ihre Datei wird heruntergeladen...';
  static const String successNewFile = 'Neue Datei bearbeiten';

  // Errors
  static const String errorGeneric =
      'Ein Fehler ist aufgetreten. Bitte versuchen Sie es erneut.';
  static const String errorFileTooLarge =
      'Datei zu groß. Die maximale Größe beträgt 100MB pro Datei.';
  static const String errorOperationTooLarge =
      'Gesamtgröße zu groß. Die maximale kombinierte Größe beträgt 250MB.';
  static const String errorInvalidPdf =
      'Ungültige PDF-Datei. Bitte wählen Sie eine gültige PDF aus.';
  static const String errorNotEnoughFiles =
      'Bitte wählen Sie mindestens 2 Dateien zum Zusammenführen aus.';
  static const String errorTooManyFiles =
      'Maximal 10 Dateien können gleichzeitig zusammengeführt werden.';
  static const String errorInvalidPageRange =
      'Ungültiger Seitenbereich. Bitte überprüfen Sie Ihre Eingabe.';
  static const String errorPasswordMismatch = 'Passwörter stimmen nicht überein.';
  static const String errorPasswordTooShort = 'Passwort zu kurz (mindestens 6 Zeichen).';

  // Pricing
  static const String pricingFreeTier = 'Kostenlos';
  static const String pricingFreePrice = '€0.00';
  static const String pricingFreeFeature1 = 'Alle Tools';
  static const String pricingFreeFeature2 = 'Bis 100MB pro Datei';
  static const String pricingFreeFeature3 = 'Keine Registrierung';

  static const String pricingProTier = 'Pro';
  static const String pricingProPrice = '€19.00';
  static const String pricingProSubtitle = 'Einmalig (Lifetime)';
  static const String pricingProFeature1 = 'Unbegrenzte Dateigröße';
  static const String pricingProFeature2 = 'Priorität-Support';
  static const String pricingProFeature3 = 'Alle zukünftigen Features';
  static const String pricingProCta = 'Jetzt upgraden';

  static const String pricingFaqTitle = 'Häufig gestellte Fragen';
  static const String pricingFaqQ1 = 'Warum Lifetime?';
  static const String pricingFaqA1 =
      'Wir glauben an faire Preise. Einmal zahlen, für immer nutzen - ohne versteckte Kosten oder Abos.';
  static const String pricingFaqQ2 = 'Sind meine Daten sicher?';
  static const String pricingFaqA2 =
      'Absolut. Ihre Dateien werden niemals hochgeladen. Alles passiert lokal in Ihrem Browser.';
  static const String pricingFaqQ3 = 'Kann ich testen?';
  static const String pricingFaqA3 =
      'Ja! Die kostenlose Version bietet alle Features mit einem 100MB-Limit pro Datei.';

  // Buttons
  static const String buttonBack = 'Zurück';
  static const String buttonCancel = 'Abbrechen';
  static const String buttonConfirm = 'Bestätigen';
  static const String buttonClose = 'Schließen';
  static const String buttonDismiss = 'Ausblenden';
  static const String buttonChange = 'Ändern';
  static const String buttonStartNow = 'Jetzt starten';

  // Tool Cards
  static const String toolsHeading = 'Ihre Werkzeuge';
  static const String toolCardCta = 'Jetzt nutzen';

  // Drop Zone
  static const String dropZoneTitle = 'PDF hierher ziehen';
  static const String dropZoneSubtitle = 'oder klicken zum Auswählen';
  static const String dropZoneButton = 'PDF auswählen';

  // Page Range
  static const String pageRangeLabel = 'Seitenbereich';
  static const String pageRangeHelper =
      'Gib die Seiten an, die du extrahieren möchtest (z.B. "1-3,5,7-9")';
  static const String pageRangeExample = 'z.B. 1-3,5,7-9';
  static const String pageRangeRequired = 'Bitte gib einen Seitenbereich ein';

  // Password
  static const String passwordLabel = 'Passwort';
  static const String passwordRequired = 'Mindestens 6 Zeichen erforderlich';
  static const String passwordHint = 'Passwort eingeben';
  static const String passwordConfirmHint = 'Passwort bestätigen';
  static const String passwordErrorTooShort =
      'Passwort muss mindestens 6 Zeichen haben';
  static const String passwordErrorEmpty = 'Bitte gib ein Passwort ein';
  static const String passwordErrorConfirmEmpty = 'Bitte bestätige das Passwort';
  static const String passwordLocalNotice =
      'Das Passwort wird nur lokal auf deinem Gerät verwendet. Wir speichern es nicht.';

  // Processing Overlay
  static const String processingPdf = 'PDF wird verarbeitet...';
  static const String pleaseWait = 'Bitte warten';
  static const String queuePosition = 'Position in Warteschlange:';
  static const String downloadStarted = 'Download gestartet';
  static const String errorTitle = 'Fehler';

  // Merge Specific
  static const String mergeMultipleAllowed = 'Mehrere PDFs gleichzeitig möglich';
  static const String mergeMinimumRequired = 'Mindestens 2 PDFs erforderlich';
  static const String mergeMaximumAllowed = 'Maximal 10 PDFs erlaubt';

  // File Size Warnings (Phase 7: Progressive Warning System)
  static const String warningLargeFile =
      'Große Datei erkannt (>10MB). Die Verarbeitung kann etwas länger dauern.';
  static const String warningVeryLargeFile =
      'Sehr große Datei erkannt (>50MB). Die Verarbeitung kann länger dauern.';
  static const String warningFileTooLarge =
      'Datei zu groß. Maximum: 100MB';
  static const String warningOperationTooLarge =
      'Gesamtgröße zu groß. Maximum: 250MB kombiniert';
  static const String infoProcessingLargeFile =
      'Große Datei wird verarbeitet. Bitte haben Sie Geduld...';
}
