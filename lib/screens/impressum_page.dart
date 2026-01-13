import 'package:flutter/material.dart';
import '../widgets/legal_page_scaffold.dart';
import '../constants/strings.dart';

/// Impressum (Legal Notice) page
///
/// German legal requirement (§5 TMG) for website operators.
/// Placeholder content - replace with actual company/individual information.
class ImpressumPage extends StatelessWidget {
  const ImpressumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalPageScaffold(
      title: Strings.footerImpressum,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Introduction
          const LegalSection(
            title: 'Angaben gemäß § 5 TMG',
            content: 'TODO: Vollständiger Name oder Firmenname eintragen',
            isPlaceholder: true,
          ),

          // Address
          const LegalSection(
            title: 'Anschrift',
            content: 'TODO: Vollständige Postadresse eintragen:\n'
                '• Straße und Hausnummer\n'
                '• PLZ und Ort\n'
                '• Land',
            isPlaceholder: true,
          ),

          // Contact
          const LegalSection(
            title: 'Kontakt',
            content: 'TODO: Kontaktdaten eintragen:',
            isPlaceholder: true,
          ),
          const LegalBulletList(
            items: [
              'E-Mail: ihre-email@beispiel.de',
              'Telefon: +49 (0) XXX XXXXXXXX (optional)',
            ],
            isPlaceholder: true,
          ),

          // Optional: Business registration
          const LegalSection(
            title: 'Registereintrag (falls zutreffend)',
            content: 'TODO: Falls gewerblich/Unternehmen:',
            isPlaceholder: true,
          ),
          const LegalBulletList(
            items: [
              'Registergericht: [z.B. Amtsgericht München]',
              'Registernummer: [z.B. HRB 123456]',
            ],
            isPlaceholder: true,
          ),

          // Optional: VAT ID
          const LegalSection(
            title: 'Umsatzsteuer-ID (falls zutreffend)',
            content: 'TODO: Falls USt-ID vorhanden:\n'
                'Umsatzsteuer-Identifikationsnummer gemäß §27a UStG: DE123456789',
            isPlaceholder: true,
          ),

          // Responsible for content
          const LegalSection(
            title: 'Verantwortlich für den Inhalt nach § 55 Abs. 2 RStV',
            content: 'TODO: Name und Adresse der verantwortlichen Person eintragen\n'
                '(oft identisch mit oben)',
            isPlaceholder: true,
          ),

          // Optional: Professional liability insurance
          const LegalSection(
            title: 'Berufshaftpflichtversicherung (optional)',
            content: 'TODO: Falls zutreffend:\n'
                '• Name und Sitz des Versicherers\n'
                '• Geltungsraum der Versicherung',
            isPlaceholder: true,
          ),

          // EU Dispute Resolution
          const LegalSection(
            title: 'EU-Streitschlichtung',
            content: 'Die Europäische Kommission stellt eine Plattform zur Online-Streitbeilegung (OS) bereit: '
                'https://ec.europa.eu/consumers/odr\n\n'
                'Unsere E-Mail-Adresse finden Sie oben im Impressum.',
            isPlaceholder: false,
          ),

          // Consumer dispute resolution
          const LegalSection(
            title: 'Verbraucherstreitbeilegung / Universalschlichtungsstelle',
            content: 'TODO: Position zur Teilnahme an Streitbeilegungsverfahren angeben.\n\n'
                'Beispiel: "Wir sind nicht bereit oder verpflichtet, an Streitbeilegungsverfahren '
                'vor einer Verbraucherschlichtungsstelle teilzunehmen."',
            isPlaceholder: true,
          ),
        ],
      ),
    );
  }
}
