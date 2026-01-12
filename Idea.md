<IDEA_BLUEPRINT>

PrivatPDF: Die ästhetische & sichere PDF-Werkstatt
<ICP> User: Lehrer, Freelancer, Steuerberater und Home-Office-Angestellte im DACH-Raum. Buyer: Dieselben (B2C) oder kleine Kanzleien/Büros (B2B), die DSGVO-konforme Tools ohne IT-Freigabe-Hürden suchen. </ICP>

<JOB_TO_BE_DONE> "Ich möchte sensible Dokumente schnell bearbeiten (zusammenfügen/signieren), ohne sie auf einen fremden Server hochzuladen." </JOB_TO_BE_DONE>

<CORE_USER_FLOW>

Landing: Nutzer landet auf einer cleanen, pastellfarbenen Web-App.

Drag & Drop: PDF wird direkt in den Browser gezogen.

Local Processing: Ein Ladebalken zeigt "Verarbeitung auf deinem Computer..." (Psychologischer Trust-Trigger).

Action: Nutzer klickt auf "Zusammenfügen" oder "Signieren".

Instant Download: Datei wird sofort gespeichert (ohne Upload-Zeit).

Aha-Moment: "Das war schneller als SmallPDF und meine Daten sind sicher geblieben." </CORE_USER_FLOW>

<MVP_SCOPE>

Must-have: Merge (PDFs verbinden), Split (Seiten trennen), Passwort-Schutz, 100% Client-side Code.

Nice-to-have: PDF-Kompression, OCR (Texterkennung), E-Signatur (Handgezeichnet), Dark Mode. </MVP_SCOPE>

<GROWTH_LOOP> Acquisition: SEO (Keywords: "PDF zusammenfügen Datenschutz", "PDF Tool ohne Upload") & Pinterest (Infografiken: "Warum du deine PDFs nicht online hochladen solltest"). Activation: Keine Registrierung nötig. Tool funktioniert sofort im Browser ("Time-to-Value" < 10 Sek). Retention: "Add to Desktop" (PWA-Installation). Einmal genutzt, bleibt es das Standard-Tool. Referral: "Sicher für Kollegen" – Share-Button für Slack/Teams. Revenue: Kostenlos für Files bis 5MB; Einmalkauf (9,99 €) oder Abo (2,99 €/Monat) für unlimitierte File-Größe & Pro-Features. </GROWTH_LOOP>

<PRICING>

Free: Alle Basis-Tools, bis 5MB Pro Datei.

Pro (Lifetime): 19,00 € (Einmalig) – Alle Features, unlimitierte Größe.

Business: 4,00 €/Monat pro Nutzer (mit Team-Management). </PRICING>

<TECH_APPROACH>

Framework: Flutter Web (da Cross-Platform gewünscht).

Core Engine: pdf-lib (JavaScript-Library via Interop) oder syncfusion_flutter_pdf.

Deployment: Vercel oder Netlify (für maximale Geschwindigkeit).

Build-Dauer: 30 Tage absolut realistisch, da keine Backend-Logik (Datenbank/Server) für die Kernfunktion nötig ist. </TECH_APPROACH>

<VALIDATION_14_DAYS>

Day 1–3: Landingpage bauen (Pastel Design). Fokus auf die Headline: "Dein PDF verlässt nie dein Gerät". E-Mail-Sammeln für "Early Access".

Day 4–7: In deutschen Subreddits (r/de_EDV, r/selbststaendig) und LinkedIn posten: "Habe ein PDF-Tool ohne Server-Upload gebaut. Feedback gesucht."

Day 8–14: Google Search Console einrichten. Erste "How-to"-Blogposts schreiben (z.B. "Sicher PDFs unterschreiben in 3 Schritten"). Metrik: >5% Conversion von Visitor zu "Beta-Interessent". </VALIDATION_14_DAYS>

<RISKS_AND_MITIGATIONS>

Risiko: Browser-Performance bei sehr großen PDFs (>500MB). (Miti: Warnhinweis bei großen Dateien + Optimierung der Buffer-Streams).

Risiko: Vertrauen wird nicht aufgebaut. (Miti: "Open Source" Link zum GitHub-Repo prominent platzieren, damit Code geprüft werden kann).

Risiko: Konkurrenz durch Adobe/SmallPDF. (Miti: Positionierung über Design ("Soft/Aesthetic") und Datenschutz ("No-Server-Policy")). </RISKS_AND_MITIGATIONS>

<KILL_CRITERIA> Akquisekosten (CAC) via Search Ads > Lifetime Value (LTV) oder weniger als 10 wiederkehrende Nutzer nach 14 Tagen Testphase. </KILL_CRITERIA> </IDEA_BLUEPRINT>