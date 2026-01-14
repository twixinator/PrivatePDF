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
            content: 'Diese Allgemeinen Geschäftsbedingungen (AGB) gelten für die Nutzung von PrivatPDF, '
                'einer browserbasierten Webanwendung zur Bearbeitung von PDF-Dateien. Betreiber ist Oliver Raider, '
                'Hinter den Gärten 2a, 86637 Wertingen, Deutschland.\n\n'
                'Mit der Nutzung dieser Website erklären Sie sich mit diesen Bedingungen einverstanden. '
                'Für die Nutzung von kostenpflichtigen Funktionen (Pro- und Business-Tarif) gelten ergänzend '
                'die nachfolgenden Bestimmungen.',
            isPlaceholder: false,
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
            content: 'Der Nutzer verpflichtet sich:',
            isPlaceholder: false,
          ),
          const LegalBulletList(
            items: [
              'Die Website ausschließlich für rechtmäßige Zwecke zu nutzen',
              'Keine urheberrechtlich geschützten oder anderweitig rechtswidrigen Inhalte ohne entsprechende Berechtigung zu verarbeiten',
              'Die technische Infrastruktur der Website nicht zu beeinträchtigen oder zu überlasten',
              'Keine automatisierten Zugriffe (Bots, Scraper, Crawler) ohne ausdrückliche schriftliche Genehmigung durchzuführen',
              'Keine Sicherheitsmechanismen zu umgehen oder Schwachstellen auszunutzen',
              'Die Dienste nicht für kommerzielle Zwecke zu nutzen, ohne einen entsprechenden Tarif (Pro/Business) zu erwerben',
            ],
            isPlaceholder: false,
          ),

          // Liability
          const LegalSection(
            title: 'Haftungsbeschränkung',
            content: 'Die kostenlose Nutzung von PrivatPDF erfolgt gemäß § 521 BGB (Schenkung) unentgeltlich. '
                'Soweit gesetzlich zulässig, ist die Haftung für Schäden, die nicht auf Vorsatz oder grober Fahrlässigkeit beruhen, '
                'ausgeschlossen. Dies gilt insbesondere für:',
            isPlaceholder: false,
          ),
          const LegalBulletList(
            items: [
              'Verlust oder Beschädigung von Dateien während der client-seitigen Verarbeitung',
              'Unterbrechungen oder Ausfälle des Dienstes aufgrund technischer Probleme',
              'Fehler in den verarbeiteten PDF-Dateien oder Qualitätsverluste',
              'Schäden durch fehlerhafte Nutzung oder unzureichende Browser-Kompatibilität',
              'Datenverlust durch Browser-Abstürze oder Verbindungsabbrüche',
            ],
            isPlaceholder: false,
          ),
          const LegalSection(
            title: '',
            content: 'Unberührt bleiben Haftungsansprüche:\n\n'
                '• bei Schäden aus der Verletzung von Leben, Körper oder Gesundheit,\n'
                '• bei Vorsatz und grober Fahrlässigkeit,\n'
                '• bei Verletzung wesentlicher Vertragspflichten (Kardinalpflichten), deren Erfüllung die ordnungsgemäße Durchführung des Vertrages erst ermöglicht,\n'
                '• bei Ansprüchen nach dem Produkthaftungsgesetz.\n\n'
                'Bei Verletzung wesentlicher Vertragspflichten ist die Haftung auf den vertragstypischen, vorhersehbaren Schaden beschränkt, '
                'sofern nicht Vorsatz oder grobe Fahrlässigkeit vorliegt.\n\n'
                'Für kostenpflichtige Tarife (Pro/Business): Die Haftung ist auf die Höhe der in den letzten 12 Monaten gezahlten Nutzungsgebühren beschränkt, '
                'soweit gesetzlich zulässig.',
            isPlaceholder: false,
          ),

          // Intellectual property
          const LegalSection(
            title: 'Urheberrecht und geistiges Eigentum',
            content: 'Alle Inhalte dieser Website (Design, Code, Texte, Logos, Grafiken) sind urheberrechtlich geschützt und Eigentum von Oliver Raider, '
                'soweit nicht anders gekennzeichnet.\n\n'
                'Die Vervielfältigung, Bearbeitung, Verbreitung oder jede Art der Verwertung außerhalb der Grenzen des Urheberrechts bedarf '
                'der schriftlichen Zustimmung des Betreibers.\n\n'
                'Alle verwendeten PDF-Dateien verbleiben im Eigentum des Nutzers. PrivatPDF erhebt keinerlei Ansprüche auf die verarbeiteten Inhalte.',
            isPlaceholder: false,
          ),

          // Open Source
          const LegalSection(
            title: 'Open Source',
            content: 'PrivatPDF ist ein Open-Source-Projekt. Der Quellcode ist öffentlich zugänglich unter:\n\n'
                'GitHub: https://github.com/twixinator/PrivatePDF\n\n'
                'Das Projekt wird unter der MIT-Lizenz veröffentlicht. Die MIT-Lizenz erlaubt die freie Nutzung, Modifikation und Verbreitung '
                'des Quellcodes unter Beibehaltung des Copyright-Hinweises. Der vollständige Lizenztext ist im GitHub-Repository einsehbar.\n\n'
                'Die Nutzung von PrivatPDF über diese Website unterliegt jedoch ausschließlich diesen AGB. Die Open-Source-Lizenz berechtigt '
                'nicht zur kommerziellen Nutzung dieser konkreten Instanz ohne entsprechenden Tarif.',
            isPlaceholder: false,
          ),

          // No warranty
          const LegalSection(
            title: 'Gewährleistungsausschluss',
            content: 'Da PrivatPDF im Free-Tarif unentgeltlich angeboten wird (§ 521 BGB - Schenkung), sind Gewährleistungsansprüche '
                'gemäß § 521 BGB ausgeschlossen, soweit gesetzlich zulässig.\n\n'
                'Der Service wird bereitgestellt, wie er ist ("as is"). Es wird keine Gewähr für:\n'
                '• die Verfügbarkeit, Fehlerfreiheit oder Vollständigkeit der Dienste,\n'
                '• die Eignung für einen bestimmten Zweck,\n'
                '• die Kompatibilität mit allen Browser-Versionen oder Betriebssystemen,\n'
                '• die Richtigkeit der Verarbeitungsergebnisse\n\n'
                'übernommen. Dies gilt nicht bei Vorsatz oder grober Fahrlässigkeit des Betreibers.\n\n'
                'Für kostenpflichtige Tarife (Pro/Business) gelten die gesetzlichen Gewährleistungsrechte nach BGB.',
            isPlaceholder: false,
          ),

          // Availability
          const LegalSection(
            title: 'Verfügbarkeit und Wartung',
            content: 'Wir bemühen uns um eine hohe Verfügbarkeit von PrivatPDF. Ein Anspruch auf ununterbrochene Erreichbarkeit '
                'besteht jedoch nicht, insbesondere nicht für den kostenlosen Free-Tarif.\n\n'
                'Der Betreiber behält sich vor:\n'
                '• Wartungsarbeiten durchzuführen, die zu vorübergehenden Unterbrechungen führen können,\n'
                '• den Dienst jederzeit ohne Vorankündigung einzuschränken oder einzustellen,\n'
                '• einzelne Funktionen zu ändern, zu entfernen oder hinzuzufügen,\n'
                '• technische Anforderungen (z.B. unterstützte Browser) anzupassen.\n\n'
                'Geplante Wartungsarbeiten werden nach Möglichkeit im Voraus angekündigt. Bei ungeplanten Ausfällen wird eine '
                'schnellstmögliche Wiederherstellung angestrebt.\n\n'
                'Für Business-Tarife: Es wird eine Verfügbarkeit von mindestens 95% pro Quartal angestrebt (best-effort).',
            isPlaceholder: false,
          ),

          // Changes to terms
          const LegalSection(
            title: 'Änderungen der AGB',
            content: 'Der Betreiber behält sich vor, diese AGB jederzeit zu ändern, soweit dies zur Anpassung an geänderte rechtliche '
                'oder technische Rahmenbedingungen erforderlich ist oder der Einführung neuer Funktionen dient.\n\n'
                'Änderungen werden auf dieser Seite veröffentlicht und treten mit Veröffentlichung in Kraft. '
                'Das Datum der letzten Aktualisierung wird am Ende der AGB angegeben.\n\n'
                'Bei wesentlichen Änderungen, die die Rechte der Nutzer betreffen, erfolgt nach Möglichkeit eine Information '
                'per E-Mail (bei registrierten Pro-/Business-Nutzern) oder durch deutlichen Hinweis auf der Website.\n\n'
                'Die fortgesetzte Nutzung von PrivatPDF nach Veröffentlichung der geänderten AGB gilt als Zustimmung zu den neuen Bedingungen. '
                'Nutzer, die mit den Änderungen nicht einverstanden sind, können die Nutzung einstellen.',
            isPlaceholder: false,
          ),

          // Applicable law
          const LegalSection(
            title: 'Anwendbares Recht und Gerichtsstand',
            content: 'Für diese AGB und alle Rechtsbeziehungen zwischen dem Betreiber und den Nutzern gilt ausschließlich das Recht '
                'der Bundesrepublik Deutschland unter Ausschluss des UN-Kaufrechts (CISG).\n\n'
                'Gerichtsstand für alle Streitigkeiten aus oder im Zusammenhang mit diesen AGB ist Augsburg, Deutschland, '
                'soweit der Nutzer Kaufmann, juristische Person des öffentlichen Rechts oder öffentlich-rechtliches Sondervermögen ist.\n\n'
                'Zwingende gesetzliche Bestimmungen über ausschließliche Gerichtsstände bleiben hiervon unberührt. '
                'Für Verbraucher gelten die gesetzlichen Vorschriften über Gerichtsstände.\n\n'
                'Die Bestimmungen des deutschen Datenschutzrechts (DSGVO, BDSG, TTDSG) finden uneingeschränkt Anwendung.',
            isPlaceholder: false,
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
            content: 'Stand: Januar 2026\n\nVersion 1.0',
            isPlaceholder: false,
          ),
        ],
      ),
    );
  }
}
