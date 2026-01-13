import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../constants/strings.dart';
import 'app_footer.dart';

/// Reusable scaffold for legal/static content pages
///
/// Provides consistent layout for Impressum, Datenschutz, AGB, and Kontakt pages
/// with editorial styling, responsive design, and integrated footer.
class LegalPageScaffold extends StatelessWidget {
  final String title;
  final Widget content;
  final bool showFooter;

  const LegalPageScaffold({
    super.key,
    required this.title,
    required this.content,
    this.showFooter = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= Breakpoints.desktop;
    final isTablet = MediaQuery.of(context).size.width >= Breakpoints.tablet;

    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(
        backgroundColor: AppTheme.cream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.charcoal),
          onPressed: () => context.go('/'),
          tooltip: Strings.buttonBack,
        ),
        title: Text(
          Strings.appName,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontFamily: 'Cormorant',
            fontWeight: FontWeight.w600,
            color: AppTheme.charcoal,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Main content area
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? Spacing.huge : (isTablet ? Spacing.xxxl : Spacing.lg),
                vertical: isDesktop ? Spacing.huge : Spacing.xxxl,
              ),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Page title
                      Text(
                        title,
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontFamily: 'Cormorant',
                          fontWeight: FontWeight.w400,
                          color: AppTheme.charcoal,
                        ),
                      ),
                      SizedBox(height: Spacing.xl),

                      // Divider
                      Container(
                        height: 1,
                        width: 100,
                        color: AppTheme.primary,
                      ),
                      SizedBox(height: Spacing.xxxl),

                      // Page content
                      content,
                    ],
                  ),
                ),
              ),
            ),

            // Footer (if enabled)
            if (showFooter) const AppFooter(),
          ],
        ),
      ),
    );
  }
}

/// Reusable content section widget for legal pages
class LegalSection extends StatelessWidget {
  final String title;
  final String content;
  final bool isPlaceholder;

  const LegalSection({
    super.key,
    required this.title,
    required this.content,
    this.isPlaceholder = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.charcoal,
            ),
          ),
          SizedBox(height: Spacing.md),

          // Section content
          if (isPlaceholder)
            Container(
              padding: const EdgeInsets.all(Spacing.lg),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                border: Border.all(color: AppTheme.border),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: AppTheme.textMuted,
                  ),
                  SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Text(
                      content,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textMuted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Text(
              content,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.7,
                color: AppTheme.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

/// Bullet list widget for legal pages
class LegalBulletList extends StatelessWidget {
  final List<String> items;
  final bool isPlaceholder;

  const LegalBulletList({
    super.key,
    required this.items,
    this.isPlaceholder = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: Spacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isPlaceholder ? AppTheme.textMuted : AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                SizedBox(width: Spacing.md),
                Expanded(
                  child: Text(
                    item,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                      color: isPlaceholder ? AppTheme.textMuted : AppTheme.textSecondary,
                      fontStyle: isPlaceholder ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
