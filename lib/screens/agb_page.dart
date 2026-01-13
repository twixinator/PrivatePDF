import 'package:flutter/material.dart';
import '../widgets/legal_page_scaffold.dart';
import '../constants/strings.dart';

/// Allgemeine Geschäftsbedingungen (Terms and Conditions) page
///
/// Terms of use for PrivatPDF - a free, client-side PDF tool.
/// Placeholder content with standard sections for German AGB.
class AgbPage extends StatelessWidget {
  const AgbPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalPageScaffold(
      title: Strings.footerAgb,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Introduction
          const LegalSection(
            title: 'Geltungsbereich',
            content: 'TODO: Einführung zu den AGB.\n\n'
                'Beispiel: "Diese Allgemeinen Geschäftsbedingungen (AGB) gelten für die Nutzung von PrivatPDF, '
                'einem kostenlosen, browserbasierten PDF-Werkzeug. Mit der Nutzung der Website erklären Sie sich '
                'mit diesen Bedingungen einverstanden."',
            isPlaceholder: true,
          ),

          // Service description
          const LegalSection(
            title: 'Leistungsbeschreibung',
            content: 'PrivatPDF bietet folgende kostenlose Dienste an:',
            isPlaceholder: false,
          ),
          const LegalBulletList(
            items: [
              'PDF-Dateien zusammenführen (Merge)',
              'PDF-Seiten extrahieren (Split)',
              'PDF-Dateien mit Passwort schützen (Protect)',
              '100% client-seitige Verarbeitung - keine Server-Uploads',
            ],
            isPlaceholder: false,
          ),
          const LegalSection(
            title: '',
            content: 'Alle Operationen erfolgen ausschließlich lokal in Ihrem Browser. '
                'Wir speichern keine Ihrer Dateien und sammeln keine personenbezogenen Daten.',
            isPlaceholder: false,
          ),

          // Usage limitations
          const LegalSection(
            title: 'Nutzungsbeschränkungen',
            content: 'Folgende Grenzen gelten für die kostenlose Nutzung:',
            isPlaceholder: false,
          ),
          const LegalBulletList(
            items: [
              'Maximale Dateigröße: 100 MB pro PDF-Datei',
              'Maximale Gesamtgröße für Operationen: 250 MB',
              'Maximale Anzahl Dateien beim Zusammenführen: 10 Dateien',
              'Die Nutzung erfolgt auf eigenes Risiko',
            ],
            isPlaceholder: false,
          ),

          // User obligations
          const LegalSection(
            title: 'Pflichten des Nutzers',
            content: 'TODO: Nutzerpflichten definieren.\n\n'
                'Beispiel: Der Nutzer verpflichtet sich:',
            isPlaceholder: true,
          ),
          const LegalBulletList(
            items: [
              'Die Website nicht für rechtswidrige Zwecke zu nutzen',
              'Keine urheberrechtlich geschützten Inhalte ohne Erlaubnis zu verarbeiten',
              'Die technische Infrastruktur der Website nicht zu beeinträchtigen',
              'Keine automatisierten Zugriffe (Bots, Scraper) ohne Genehmigung durchzuführen',
            ],
            isPlaceholder: true,
          ),

          // Liability
          const LegalSection(
            title: 'Haftungsbeschränkung',
            content: 'TODO: Haftungsausschluss formulieren.\n\n'
                'Beispiel: "PrivatPDF wird kostenlos und "wie besehen" bereitgestellt. '
                'Wir übernehmen keine Haftung für:"',
            isPlaceholder: true,
          ),
          const LegalBulletList(
            items: [
              'Verlust oder Beschädigung von Dateien während der Verarbeitung',
              'Unterbrechungen oder Ausfälle des Dienstes',
              'Fehler in den verarbeiteten PDF-Dateien',
              'Schäden durch fehlerhafte Nutzung',
            ],
            isPlaceholder: true,
          ),
          const LegalSection(
            title: '',
            content: 'TODO: Hinweis auf gesetzliche Haftung bei Vorsatz und grober Fahrlässigkeit.\n\n'
                'Beispiel: "Die Haftung für Schäden aus der Verletzung von Leben, Körper oder Gesundheit '
                'sowie bei Vorsatz und grober Fahrlässigkeit bleibt unberührt."',
            isPlaceholder: true,
          ),

          // Intellectual property
          const LegalSection(
            title: 'Urheberrecht',
            content: 'TODO: Urheberrechtshinweise.\n\n'
                'Beispiel: "Alle Inhalte dieser Website (Design, Code, Texte) sind urheberrechtlich geschützt. '
                'PrivatPDF ist Open Source unter [Lizenz angeben, z.B. MIT License]."',
            isPlaceholder: true,
          ),

          // Open Source
          const LegalSection(
            title: 'Open Source',
            content: 'PrivatPDF ist ein Open-Source-Projekt. Der Quellcode ist verfügbar auf GitHub.\n\n'
                'TODO: GitHub-Repository-Link und Lizenzbedingungen angeben.',
            isPlaceholder: true,
          ),

          // No warranty
          const LegalSection(
            title: 'Gewährleistungsausschluss',
            content: 'TODO: Gewährleistungsausschluss bei kostenlosem Service.\n\n'
                'Beispiel: "Da PrivatPDF kostenlos angeboten wird, sind Gewährleistungsansprüche ausgeschlossen, '
                'soweit gesetzlich zulässig. Der Service wird bereitgestellt, wie er ist (\'as is\')."',
            isPlaceholder: true,
          ),

          // Availability
          const LegalSection(
            title: 'Verfügbarkeit',
            content: 'TODO: Hinweise zur Verfügbarkeit.\n\n'
                'Beispiel: "Wir bemühen uns um eine hohe Verfügbarkeit von PrivatPDF, können jedoch keine '
                'ununterbrochene Erreichbarkeit garantieren. Wartungsarbeiten können zu vorübergehenden '
                'Unterbrechungen führen."',
            isPlaceholder: true,
          ),

          // Changes to terms
          const LegalSection(
            title: 'Änderungen der AGB',
            content: 'TODO: Regelung zu AGB-Änderungen.\n\n'
                'Beispiel: "Wir behalten uns vor, diese AGB jederzeit zu ändern. Änderungen werden auf dieser '
                'Seite veröffentlicht. Die fortgesetzte Nutzung nach Änderungen gilt als Zustimmung."',
            isPlaceholder: true,
          ),

          // Applicable law
          const LegalSection(
            title: 'Anwendbares Recht',
            content: 'TODO: Anwendbares Recht und Gerichtsstand.\n\n'
                'Beispiel: "Es gilt das Recht der Bundesrepublik Deutschland unter Ausschluss des '
                'UN-Kaufrechts. Gerichtsstand ist [Ihr Standort]."',
            isPlaceholder: true,
          ),

          // Severability clause
          const LegalSection(
            title: 'Salvatorische Klausel',
            content: 'Sollten einzelne Bestimmungen dieser AGB unwirksam sein oder werden, bleibt die Wirksamkeit '
                'der übrigen Bestimmungen hiervon unberührt.',
            isPlaceholder: false,
          ),

          // Last updated
          const LegalSection(
            title: 'Stand dieser AGB',
            content: 'TODO: Datum der letzten Aktualisierung angeben (z.B. "Stand: Januar 2026")',
            isPlaceholder: true,
          ),
        ],
      ),
    );
  }
}
