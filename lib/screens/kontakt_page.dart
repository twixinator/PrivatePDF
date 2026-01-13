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
            content: 'TODO: Ihre E-Mail-Adresse eintragen',
            isPlaceholder: true,
          ),
          _buildContactCard(
            context,
            icon: Icons.email_outlined,
            title: 'E-Mail-Adresse',
            content: 'ihre-email@beispiel.de',
            action: 'E-Mail senden',
            onTap: () async {
              // TODO: Replace with actual email
              final uri = Uri.parse('mailto:ihre-email@beispiel.de?subject=Kontakt%20von%20PrivatPDF');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
            isPlaceholder: true,
          ),

          const SizedBox(height: Spacing.xl),

          // GitHub Issues
          const LegalSection(
            title: 'GitHub Issues',
            content: 'Für Bug-Reports, Feature-Requests oder technische Fragen nutzen Sie gerne GitHub Issues.',
            isPlaceholder: false,
          ),
          _buildContactCard(
            context,
            icon: Icons.bug_report_outlined,
            title: 'GitHub Issues',
            content: 'Ideal für Bug-Reports und Feature-Requests',
            action: 'Zu GitHub Issues',
            onTap: () async {
              // TODO: Replace with actual GitHub repository URL
              final uri = Uri.parse('https://github.com/privatpdf/privatpdf/issues');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
            isPlaceholder: true,
          ),

          const SizedBox(height: Spacing.xl),

          // Response time
          const LegalSection(
            title: 'Antwortzeiten',
            content: 'TODO: Erwartete Antwortzeiten angeben.\n\n'
                'Beispiel: "Wir bemühen uns, alle Anfragen innerhalb von 2-3 Werktagen zu beantworten. '
                'Bei technischen Problemen nutzen Sie bitte GitHub Issues für schnellere Hilfe durch die Community."',
            isPlaceholder: true,
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

          // Social Media (optional)
          const LegalSection(
            title: 'Social Media (optional)',
            content: 'TODO: Falls Social Media Kanäle vorhanden, hier verlinken:\n'
                '• Twitter/X: @privatpdf\n'
                '• LinkedIn: PrivatPDF\n'
                '• Mastodon: @privatpdf@mastodon.social',
            isPlaceholder: true,
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
