import 'package:flutter/material.dart';
import '../widgets/legal_page_scaffold.dart';
import '../constants/strings.dart';

/// Datenschutzerklärung (Privacy Policy) page
///
/// GDPR-compliant privacy policy for PrivatPDF.
/// Highlights 100% local processing - no data collection or uploads.
class DatenschutzPage extends StatelessWidget {
  const DatenschutzPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalPageScaffold(
      title: Strings.footerDatenschutz,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Introduction
          const LegalSection(
            title: 'Datenschutz auf einen Blick',
            content: 'PrivatPDF wurde entwickelt, um Ihre Privatsphäre zu schützen. '
                'Alle PDF-Operationen werden zu 100% lokal in Ihrem Browser verarbeitet. '
                'Es werden keine Dateien auf Server hochgeladen und keine personenbezogenen Daten gesammelt.',
            isPlaceholder: false,
          ),

          // General information
          const LegalSection(
            title: '1. Verantwortlicher',
            content: 'Verantwortlicher im Sinne der Datenschutz-Grundverordnung (DSGVO) ist:\n\n'
                'Oliver Raider\n'
                'Hinter den Gärten 2a\n'
                '86637 Wertingen\n'
                'Deutschland\n\n'
                'E-Mail: raider.o@arcor.de',
            isPlaceholder: false,
          ),

          // Data processing overview
          const LegalSection(
            title: '2. Grundsatz: Privacy by Design',
            content: 'PrivatPDF wurde nach dem Prinzip "Privacy by Design" (Art. 25 DSGVO) entwickelt. '
                'Im Gegensatz zu anderen PDF-Tools werden Ihre Dateien NICHT auf Server hochgeladen:',
            isPlaceholder: false,
          ),
          const LegalBulletList(
            items: [
              '✅ Keine Datenübertragung: Alle hochgeladenen PDFs verbleiben ausschließlich auf Ihrem Gerät',
              '✅ Keine Server-Speicherung: Es werden keine Dateien auf unseren Servern gespeichert',
              '✅ Lokale Verarbeitung: PDF-Operationen (Zusammenführen, Aufteilen, Schützen) werden client-seitig im Browser ausgeführt',
              '✅ Keine Tracking-Cookies: Wir verwenden keine Tracking- oder Werbe-Cookies',
            ],
            isPlaceholder: false,
          ),

          // localStorage Analytics
          const LegalSection(
            title: '3. Lokale Nutzungsstatistiken (localStorage)',
            content: 'Um die Benutzerfreundlichkeit zu verbessern, speichert PrivatPDF anonyme Nutzungsstatistiken '
                'ausschließlich lokal in Ihrem Browser (localStorage):',
            isPlaceholder: false,
          ),
          const LegalBulletList(
            items: [
              'Art der durchgeführten PDF-Operation (Zusammenführen, Aufteilen, Schützen)',
              'Anzahl der verarbeiteten Dateien',
              'Zeitstempel der Operation',
              'Dateigrößenkategorie (z.B. "10-50MB", "50-100MB")',
              'Keine personenbezogenen Daten oder IP-Adressen',
            ],
            isPlaceholder: false,
          ),
          const LegalSection(
            title: '',
            content: 'Diese Daten:\n'
                '• Verbleiben ausschließlich in Ihrem Browser\n'
                '• Werden nie an Server übertragen\n'
                '• Können jederzeit durch Löschen des Browser-Cache entfernt werden\n'
                '• Dienen nur zur Verbesserung der Nutzererfahrung\n\n'
                'Rechtsgrundlage: Art. 6 Abs. 1 lit. f DSGVO (berechtigtes Interesse an der Verbesserung unserer Website)',
            isPlaceholder: false,
          ),

          // Hosting
          const LegalSection(
            title: '4. Hosting und Server-Logs',
            content: 'Diese Website wird gehostet bei:\n\n'
                'Vercel Inc.\n'
                '440 N Barranca Ave #4133\n'
                'Covina, CA 91723\n'
                'USA\n\n'
                'Beim Besuch der Website werden automatisch folgende technische Daten in Server-Log-Dateien gespeichert:',
            isPlaceholder: false,
          ),
          const LegalBulletList(
            items: [
              'Anonymisierte IP-Adresse (gekürzt auf 3 Oktette)',
              'Datum und Uhrzeit des Zugriffs',
              'Aufgerufene Seite/URL',
              'HTTP-Statuscode',
              'Übertragene Datenmenge',
              'Browser-Typ und Version (User-Agent)',
              'Referer (zuvor besuchte Seite)',
            ],
            isPlaceholder: false,
          ),
          const LegalSection(
            title: '',
            content: 'Diese Daten dienen ausschließlich der Sicherstellung der Systemstabilität, Fehleranalyse und '
                'Abwehr von Angriffen. Eine Zusammenführung mit anderen Datenquellen erfolgt nicht.\n\n'
                'Speicherdauer: Die Logs werden nach maximal 30 Tagen automatisch gelöscht.\n\n'
                'Rechtsgrundlage: Art. 6 Abs. 1 lit. f DSGVO (berechtigtes Interesse an der Sicherstellung '
                'des technischen Betriebs und der IT-Sicherheit).\n\n'
                'Datenübermittlung in Drittländer: Vercel verarbeitet Daten teilweise in den USA. Die Datenübermittlung '
                'erfolgt auf Grundlage der EU-Standardvertragsklauseln (Art. 46 Abs. 2 lit. c DSGVO). '
                'Weitere Informationen: https://vercel.com/legal/privacy-policy',
            isPlaceholder: false,
          ),

          // CDN
          const LegalSection(
            title: '5. Content Delivery Networks (CDN)',
            content: 'Zur schnelleren Auslieferung von Inhalten nutzen wir folgende CDN-Dienste:',
            isPlaceholder: false,
          ),
          const LegalSection(
            title: '5.1 jsDelivr (cdn.jsdelivr.net)',
            content: 'Wir verwenden jsDelivr zum Laden der pdf-lib JavaScript-Bibliothek. Dabei kann Ihre IP-Adresse '
                'an jsDelivr übermittelt werden.\n\n'
                'Anbieter: ProspectOne Sp. z o.o., Polen\n'
                'Datenschutzerklärung: https://www.jsdelivr.com/privacy-policy-jsdelivr-net\n'
                'Rechtsgrundlage: Art. 6 Abs. 1 lit. f DSGVO (technische Bereitstellung der Website)',
            isPlaceholder: false,
          ),
          const LegalSection(
            title: '5.2 Google Fonts',
            content: 'Diese Website nutzt Google Fonts zur einheitlichen Darstellung von Schriftarten. '
                'Beim Aufruf werden Schriftarten lokal geladen, sodass KEINE Verbindung zu Google-Servern hergestellt wird.\n\n'
                'Alternativ: Falls Google Fonts extern geladen werden:\n'
                'Anbieter: Google Ireland Limited, Gordon House, Barrow Street, Dublin 4, Irland\n'
                'Datenschutzerklärung: https://policies.google.com/privacy\n'
                'Rechtsgrundlage: Art. 6 Abs. 1 lit. f DSGVO',
            isPlaceholder: false,
          ),
          const LegalSection(
            title: '5.3 Gstatic (Flutter CanvasKit)',
            content: 'Flutter Web nutzt CanvasKit von Gstatic (Google) zur Darstellung der Benutzeroberfläche. '
                'Dabei kann Ihre IP-Adresse an Google übermittelt werden.\n\n'
                'Anbieter: Google Ireland Limited, Gordon House, Barrow Street, Dublin 4, Irland\n'
                'Datenschutzerklärung: https://policies.google.com/privacy\n'
                'Rechtsgrundlage: Art. 6 Abs. 1 lit. f DSGVO (technische Bereitstellung der Web-App)',
            isPlaceholder: false,
          ),

          // Your rights
          const LegalSection(
            title: '6. Ihre Rechte als betroffene Person',
            content: 'Sie haben folgende Rechte gemäß DSGVO:',
            isPlaceholder: false,
          ),
          const LegalBulletList(
            items: [
              'Recht auf Auskunft (Art. 15 DSGVO) über die von uns gespeicherten Daten',
              'Recht auf Berichtigung (Art. 16 DSGVO) unrichtiger Daten',
              'Recht auf Löschung (Art. 17 DSGVO) Ihrer Daten',
              'Recht auf Einschränkung der Verarbeitung (Art. 18 DSGVO)',
              'Recht auf Datenübertragbarkeit (Art. 20 DSGVO)',
              'Recht auf Widerspruch (Art. 21 DSGVO) gegen die Verarbeitung',
              'Recht auf Beschwerde bei einer Aufsichtsbehörde (Art. 77 DSGVO)',
            ],
            isPlaceholder: false,
          ),
          const LegalSection(
            title: '',
            content: 'Wichtiger Hinweis: Da PrivatPDF nach dem Prinzip "Privacy by Design" keine personenbezogenen Daten '
                'sammelt oder speichert, fallen die meisten dieser Rechte faktisch nicht an. Ihre PDF-Dateien verbleiben '
                'ausschließlich auf Ihrem Gerät.\n\n'
                'Bei Fragen zur Datenverarbeitung wenden Sie sich bitte an: raider.o@arcor.de\n\n'
                'Zuständige Aufsichtsbehörde für Deutschland:\n'
                'Die Bundesbeauftragte für den Datenschutz und die Informationsfreiheit (BfDI)\n'
                'Graurheindorfer Str. 153, 53117 Bonn\n'
                'https://www.bfdi.bund.de',
            isPlaceholder: false,
          ),

          // SSL/TLS encryption
          const LegalSection(
            title: '8. SSL- bzw. TLS-Verschlüsselung',
            content: 'Diese Website nutzt aus Sicherheitsgründen und zum Schutz der Übertragung vertraulicher Inhalte '
                'eine SSL- bzw. TLS-Verschlüsselung. Eine verschlüsselte Verbindung erkennen Sie daran, dass die '
                'Adresszeile des Browsers von "http://" auf "https://" wechselt und an dem Schloss-Symbol in Ihrer Browserzeile.\n\n'
                'Wenn die SSL- bzw. TLS-Verschlüsselung aktiviert ist, können die Daten, die Sie an uns übermitteln, '
                'nicht von Dritten mitgelesen werden.',
            isPlaceholder: false,
          ),

          // Cookies section
          const LegalSection(
            title: '9. Cookies und Browser-Speicher',
            content: 'Diese Website verwendet KEINE Tracking-Cookies. Die einzigen im Browser gespeicherten Daten sind:\n\n'
                '• localStorage-Einträge für lokale Nutzungsstatistiken (siehe Abschnitt 3)\n'
                '• Funktionale Daten zur Darstellung der Benutzeroberfläche\n\n'
                'Diese Daten dienen ausschließlich technischen Zwecken und werden niemals an Server übertragen. '
                'Sie können diese Daten jederzeit durch Löschen Ihres Browser-Cache entfernen.',
            isPlaceholder: false,
          ),

          // Widerspruchsrecht
          const LegalSection(
            title: '10. Widerspruchsrecht gegen Datenverarbeitung',
            content: 'Sofern eine Datenverarbeitung auf Grundlage von Art. 6 Abs. 1 lit. f DSGVO (berechtigtes Interesse) '
                'erfolgt, haben Sie das Recht, aus Gründen, die sich aus Ihrer besonderen Situation ergeben, jederzeit '
                'gegen diese Verarbeitung Widerspruch einzulegen.\n\n'
                'Nach einem Widerspruch werden wir die betroffenen Daten nicht mehr verarbeiten, es sei denn, wir können '
                'zwingende schutzwürdige Gründe für die Verarbeitung nachweisen.\n\n'
                'Kontakt für Widerspruch: raider.o@arcor.de',
            isPlaceholder: false,
          ),

          // Last updated
          const LegalSection(
            title: '11. Stand dieser Datenschutzerklärung',
            content: 'Stand: Januar 2026',
            isPlaceholder: false,
          ),
        ],
      ),
    );
  }
}
