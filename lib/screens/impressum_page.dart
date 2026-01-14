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
            content: 'Oliver Raider',
            isPlaceholder: false,
          ),

          // Address
          const LegalSection(
            title: 'Anschrift',
            content: 'Hinter den Gärten 2a\n'
                '86637 Wertingen\n'
                'Deutschland',
            isPlaceholder: false,
          ),

          // Contact
          const LegalSection(
            title: 'Kontakt',
            content: 'E-Mail: raider.o@arcor.de',
            isPlaceholder: false,
          ),

          // Responsible for content
          const LegalSection(
            title: 'Verantwortlich für den Inhalt',
            content: 'Verantwortlich für den Inhalt nach § 18 Abs. 2 MStV:\n\n'
                'Oliver Raider\n'
                'Hinter den Gärten 2a\n'
                '86637 Wertingen',
            isPlaceholder: false,
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
            content: 'Wir sind nicht bereit oder verpflichtet, an Streitbeilegungsverfahren vor einer '
                'Verbraucherschlichtungsstelle teilzunehmen.',
            isPlaceholder: false,
          ),
        ],
      ),
    );
  }
}
