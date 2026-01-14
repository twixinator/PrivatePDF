import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/legal_page_scaffold.dart';
import '../constants/strings.dart';
import '../theme/app_theme.dart';

/// Kontakt (Contact) page
///
/// Provides contact information and links for support, feedback, and bug reports.
/// Placeholder for email - can be extended with contact form later.
class KontaktPage extends StatelessWidget {
  const KontaktPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalPageScaffold(
      title: Strings.footerKontakt,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Introduction
          const LegalSection(
            title: 'Wir freuen uns über Ihre Nachricht',
            content: 'Haben Sie Fragen, Feedback oder benötigen Sie Unterstützung? '
                'Kontaktieren Sie uns gerne über die folgenden Kanäle.',
            isPlaceholder: false,
          ),

          // Email contact
          const LegalSection(
            title: 'E-Mail',
            content: 'Die schnellste Möglichkeit, uns zu erreichen. Ideal für allgemeine Anfragen, Feedback oder geschäftliche Anliegen.',
            isPlaceholder: false,
          ),
          _buildContactCard(
            context,
            icon: Icons.email_outlined,
            title: 'E-Mail-Adresse',
            content: 'raider.o@arcor.de',
            action: 'E-Mail senden',
            onTap: () async {
              final uri = Uri.parse('mailto:raider.o@arcor.de?subject=Kontakt%20von%20PrivatPDF');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
            isPlaceholder: false,
          ),

          const SizedBox(height: Spacing.xl),

          // GitHub Issues
          const LegalSection(
            title: 'GitHub Issues',
            content: 'Für Bug-Reports, Feature-Requests oder technische Fragen nutzen Sie gerne GitHub Issues. '
                'Hier können Sie auch den Quellcode einsehen und zur Weiterentwicklung beitragen.',
            isPlaceholder: false,
          ),
          _buildContactCard(
            context,
            icon: Icons.bug_report_outlined,
            title: 'GitHub Issues',
            content: 'Ideal für Bug-Reports, Feature-Requests und technische Diskussionen',
            action: 'Zu GitHub Issues',
            onTap: () async {
              final uri = Uri.parse('https://github.com/twixinator/PrivatePDF/issues');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
            isPlaceholder: false,
          ),

          const SizedBox(height: Spacing.xl),

          // Response time
          const LegalSection(
            title: 'Antwortzeiten',
            content: 'PrivatPDF wird von einem Solo-Entwickler betrieben. Wir bemühen uns, alle Anfragen zeitnah zu beantworten:\n\n'
                '• E-Mail-Anfragen: Innerhalb von 2-5 Werktagen\n'
                '• GitHub Issues: Oft schneller durch Community-Unterstützung\n'
                '• Dringende technische Probleme: Priorisierte Bearbeitung\n\n'
                'Bitte haben Sie Verständnis, dass die Antwortzeiten je nach Aufkommen und Komplexität der Anfrage variieren können. '
                'Für technische Probleme empfehlen wir GitHub Issues, da dort auch andere Nutzer und Entwickler helfen können.',
            isPlaceholder: false,
          ),

          // Support topics
          const LegalSection(
            title: 'Wobei können wir helfen?',
            content: '',
            isPlaceholder: false,
          ),
          const LegalBulletList(
            items: [
              'Technische Probleme oder Fehler bei der PDF-Verarbeitung',
              'Fragen zur Nutzung von PrivatPDF',
              'Feedback und Verbesserungsvorschläge',
              'Anfragen zur Datenschutzerklärung',
              'Geschäftliche Anfragen (White-Label, Partnerschaften)',
              'Presseanfragen',
            ],
            isPlaceholder: false,
          ),

          // Open Source Community
          const LegalSection(
            title: 'Open-Source-Community',
            content: 'PrivatPDF ist ein Open-Source-Projekt. Wir freuen uns über Beiträge, Feedback und Diskussionen '
                'in der GitHub-Community:\n\n'
                '• GitHub Repository: https://github.com/twixinator/PrivatePDF\n'
                '• Discussions: Für allgemeine Fragen und Ideen\n'
                '• Pull Requests: Willkommen für Code-Verbesserungen\n'
                '• Issues: Für Bug-Reports und Feature-Requests\n\n'
                'Jeder kann zur Weiterentwicklung von PrivatPDF beitragen und den Quellcode einsehen.',
            isPlaceholder: false,
          ),

          // Data protection notice
          const LegalSection(
            title: 'Datenschutzhinweis',
            content: 'Ihre Kontaktanfrage wird vertraulich behandelt. Weitere Informationen finden Sie in unserer '
                'Datenschutzerklärung.',
            isPlaceholder: false,
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    required String action,
    required VoidCallback onTap,
    bool isPlaceholder = false,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: isPlaceholder ? AppTheme.surface : Colors.white,
        border: Border.all(
          color: isPlaceholder ? AppTheme.border : AppTheme.primary.withOpacity(0.3),
          width: isPlaceholder ? 1 : 2,
        ),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(Spacing.sm),
                decoration: BoxDecoration(
                  color: isPlaceholder
                      ? AppTheme.textMuted.withOpacity(0.1)
                      : AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Icon(
                  icon,
                  color: isPlaceholder ? AppTheme.textMuted : AppTheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: Spacing.md),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isPlaceholder ? AppTheme.textMuted : AppTheme.charcoal,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isPlaceholder ? AppTheme.textMuted : AppTheme.textSecondary,
              fontStyle: isPlaceholder ? FontStyle.italic : FontStyle.normal,
            ),
          ),
          const SizedBox(height: Spacing.md),
          OutlinedButton.icon(
            onPressed: onTap,
            icon: Icon(
              Icons.arrow_forward,
              size: 18,
              color: isPlaceholder ? AppTheme.textMuted : AppTheme.primary,
            ),
            label: Text(action),
            style: OutlinedButton.styleFrom(
              foregroundColor: isPlaceholder ? AppTheme.textMuted : AppTheme.primary,
              side: BorderSide(
                color: isPlaceholder ? AppTheme.border : AppTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
