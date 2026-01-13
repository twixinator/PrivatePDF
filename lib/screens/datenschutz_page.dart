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
            title: 'Allgemeine Hinweise',
            content: 'TODO: Name des Verantwortlichen gemäß Art. 13 DSGVO:\n'
                '[Ihr Name/Firmenname]\n'
                '[Ihre Adresse]\n'
                '[Ihre Kontaktdaten]',
            isPlaceholder: true,
          ),

          // Data processing overview
          const LegalSection(
            title: 'Datenverarbeitung auf dieser Website',
            content: 'Wie erfassen wir Ihre Daten?',
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
            title: 'Lokale Nutzungsstatistiken (localStorage)',
            content: 'PrivatPDF speichert anonyme Nutzungsstatistiken ausschließlich lokal in Ihrem Browser (localStorage):',
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
            title: 'Hosting',
            content: 'Diese Website wird gehostet bei:\n\n'
                'TODO: Hosting-Anbieter angeben (z.B. Vercel Inc., Name, Adresse)\n\n'
                'Beim Besuch der Website werden automatisch folgende Daten in Server-Log-Dateien gespeichert:',
            isPlaceholder: true,
          ),
          const LegalBulletList(
            items: [
              'IP-Adresse (anonymisiert)',
              'Datum und Uhrzeit des Zugriffs',
              'Aufgerufene Seite',
              'Browser-Typ und Version',
              'Betriebssystem',
            ],
            isPlaceholder: true,
          ),
          const LegalSection(
            title: '',
            content: 'TODO: Angeben, wie lange Server-Logs gespeichert werden und Rechtsgrundlage.\n\n'
                'Beispiel: "Diese Daten werden nach 30 Tagen automatisch gelöscht. '
                'Rechtsgrundlage: Art. 6 Abs. 1 lit. f DSGVO (Sicherstellung des technischen Betriebs)."',
            isPlaceholder: true,
          ),

          // CDN
          const LegalSection(
            title: 'Content Delivery Network (CDN)',
            content: 'Wir nutzen folgende CDN-Dienste zum Laden von Bibliotheken:',
            isPlaceholder: false,
          ),
          const LegalBulletList(
            items: [
              'jsDelivr (cdn.jsdelivr.net) - für pdf-lib Bibliothek',
              'Google Fonts (fonts.googleapis.com) - für Schriftarten',
              'Gstatic (www.gstatic.com) - für Flutter CanvasKit',
            ],
            isPlaceholder: false,
          ),
          const LegalSection(
            title: '',
            content: 'TODO: Datenschutzerklärungen der CDN-Anbieter verlinken und Rechtsgrundlage angeben.',
            isPlaceholder: true,
          ),

          // Your rights
          const LegalSection(
            title: 'Ihre Rechte',
            content: 'Sie haben folgende Rechte gemäß DSGVO:',
            isPlaceholder: false,
          ),
          const LegalBulletList(
            items: [
              'Recht auf Auskunft (Art. 15 DSGVO)',
              'Recht auf Berichtigung (Art. 16 DSGVO)',
              'Recht auf Löschung (Art. 17 DSGVO)',
              'Recht auf Einschränkung der Verarbeitung (Art. 18 DSGVO)',
              'Recht auf Datenübertragbarkeit (Art. 20 DSGVO)',
              'Recht auf Widerspruch (Art. 21 DSGVO)',
              'Recht auf Beschwerde bei einer Aufsichtsbehörde (Art. 77 DSGVO)',
            ],
            isPlaceholder: false,
          ),
          const LegalSection(
            title: '',
            content: 'TODO: Kontaktinformationen für Datenschutzanfragen angeben.\n\n'
                'Da PrivatPDF keine personenbezogenen Daten sammelt, fallen die meisten Rechte faktisch nicht an. '
                'Bei Fragen wenden Sie sich bitte an: [Ihre E-Mail]',
            isPlaceholder: true,
          ),

          // Data protection officer (if applicable)
          const LegalSection(
            title: 'Datenschutzbeauftragter (falls zutreffend)',
            content: 'TODO: Falls gesetzlich erforderlich, Kontaktdaten des Datenschutzbeauftragten angeben.\n\n'
                'Hinweis: Ein Datenschutzbeauftragter ist in Deutschland ab 20 Mitarbeitern verpflichtend.',
            isPlaceholder: true,
          ),

          // SSL/TLS encryption
          const LegalSection(
            title: 'SSL- bzw. TLS-Verschlüsselung',
            content: 'Diese Website nutzt aus Sicherheitsgründen und zum Schutz der Übertragung vertraulicher Inhalte '
                'eine SSL- bzw. TLS-Verschlüsselung. Eine verschlüsselte Verbindung erkennen Sie daran, dass die '
                'Adresszeile des Browsers von "http://" auf "https://" wechselt und an dem Schloss-Symbol in Ihrer Browserzeile.',
            isPlaceholder: false,
          ),

          // Last updated
          const LegalSection(
            title: 'Stand dieser Datenschutzerklärung',
            content: 'TODO: Datum der letzten Aktualisierung angeben (z.B. "Stand: Januar 2026")',
            isPlaceholder: true,
          ),
        ],
      ),
    );
  }
}
