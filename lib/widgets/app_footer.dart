import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/strings.dart';
import '../theme/app_theme.dart';

/// Editorial-style footer with trust signals
class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= Breakpoints.tablet;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(color: AppTheme.border, width: 1),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? Spacing.xxxl : Spacing.lg,
          vertical: isDesktop ? Spacing.xxxl : Spacing.xl,
        ),
        child: isDesktop
            ? _buildDesktopLayout(theme)
            : _buildMobileLayout(theme),
      ),
    );
  }

  Widget _buildDesktopLayout(ThemeData theme) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Brand column
            Expanded(
              flex: 2,
              child: _buildBrandSection(theme),
            ),

            // Links column
            Expanded(
              child: _buildLinksSection(theme, Strings.navTools, [
                Strings.toolMergeTitle,
                Strings.toolSplitTitle,
                Strings.toolProtectTitle,
              ]),
            ),

            // Legal column
            Expanded(
              child: _buildLinksSection(theme, 'Rechtliches', [
                Strings.footerImpressum,
                Strings.footerDatenschutz,
                Strings.footerAgb,
                Strings.footerKontakt,
              ]),
            ),

            // Trust column
            Expanded(
              child: _buildTrustSection(theme),
            ),
          ],
        ),

        SizedBox(height: Spacing.xxxl),
        Divider(color: AppTheme.border, height: 1),
        SizedBox(height: Spacing.lg),

        // Bottom row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              Strings.copyright,
              style: theme.textTheme.bodySmall,
            ),
            _buildOpenSourceLink(theme),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileLayout(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBrandSection(theme),
        SizedBox(height: Spacing.xl),

        _buildTrustSection(theme),
        SizedBox(height: Spacing.xl),

        _buildLinksSection(theme, Strings.navTools, [
          Strings.toolMergeTitle,
          Strings.toolSplitTitle,
          Strings.toolProtectTitle,
        ]),
        SizedBox(height: Spacing.lg),

        _buildLinksSection(theme, 'Rechtliches', [
          Strings.footerImpressum,
          Strings.footerDatenschutz,
          Strings.footerAgb,
          Strings.footerKontakt,
        ]),

        SizedBox(height: Spacing.xl),
        Divider(color: AppTheme.border, height: 1),
        SizedBox(height: Spacing.lg),

        Text(
          Strings.copyright,
          style: theme.textTheme.bodySmall,
        ),
        SizedBox(height: Spacing.sm),
        _buildOpenSourceLink(theme),
      ],
    );
  }

  Widget _buildBrandSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Strings.appName,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontFamily: 'Cormorant',
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: Spacing.sm),
        Text(
          Strings.heroSubheadline,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildLinksSection(ThemeData theme, String title, List<String> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.75,
          ),
        ),
        SizedBox(height: Spacing.md),
        ...links.map((link) => Padding(
          padding: const EdgeInsets.only(bottom: Spacing.sm),
          child: Builder(
            builder: (context) => InkWell(
              onTap: () => _navigateToLink(context, link),
              child: Text(
                link,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textMuted,
                ),
              ),
            ),
          ),
        )),
      ],
    );
  }

  /// Navigate to the appropriate route based on link text
  void _navigateToLink(BuildContext context, String link) {
    // Map link text to routes
    final routeMap = {
      // Tool pages
      Strings.toolMergeTitle: '/merge',
      Strings.toolSplitTitle: '/split',
      Strings.toolProtectTitle: '/protect',

      // Legal pages
      Strings.footerImpressum: '/impressum',
      Strings.footerDatenschutz: '/datenschutz',
      Strings.footerAgb: '/agb',
      Strings.footerKontakt: '/kontakt',
    };

    final route = routeMap[link];
    if (route != null) {
      context.go(route);
    }
  }

  Widget _buildTrustSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vertrauen',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.75,
          ),
        ),
        SizedBox(height: Spacing.md),
        _buildTrustBadge(theme, Icons.verified_outlined, Strings.trustDsgvo),
        SizedBox(height: Spacing.sm),
        _buildTrustBadge(theme, Icons.computer_outlined, Strings.trustLocal),
        SizedBox(height: Spacing.sm),
        _buildTrustBadge(theme, Icons.cloud_off_outlined, Strings.trustNoUpload),
      ],
    );
  }

  Widget _buildTrustBadge(ThemeData theme, IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppTheme.primary,
        ),
        SizedBox(width: Spacing.sm),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildOpenSourceLink(ThemeData theme) {
    return InkWell(
      onTap: () async {
        // TODO: Replace with actual GitHub URL when available
        final url = Uri.parse('https://github.com/privatpdf/privatpdf');
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.code_outlined,
            size: 18,
            color: AppTheme.textMuted,
          ),
          SizedBox(width: Spacing.xs),
          Text(
            Strings.trustOpenSource,
            style: theme.textTheme.bodySmall?.copyWith(
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }
}
