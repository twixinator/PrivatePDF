import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/strings.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/app_footer.dart';
import '../animations/animated_card.dart';
import '../animations/fade_in_widget.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero section appears immediately
            const _HeroSection(),

            // Tool selection fades in with slight delay
            FadeInWidget(
              delay: const Duration(milliseconds: 150),
              child: const _ToolSelectionSection(),
            ),

            // Value proposition fades in after tools
            FadeInWidget(
              delay: const Duration(milliseconds: 300),
              child: const _ValuePropositionSection(),
            ),

            const AppFooter(),
          ],
        ),
      ),
    );
  }
}

/// Editorial hero section with bold typography
class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= Breakpoints.desktop;
    final isTablet = screenWidth >= Breakpoints.tablet;

    return Container(
      constraints: BoxConstraints(
        minHeight: isDesktop ? 600 : 500,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.background,
            AppTheme.surface,
            AppTheme.background.withOpacity(0.8),
          ],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? Spacing.massive : (isTablet ? Spacing.xxxl : Spacing.lg),
          vertical: isDesktop ? Spacing.massive : Spacing.xxxl,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Trust badge above headline
                _buildTrustIndicators(theme, isDesktop),
                SizedBox(height: isDesktop ? Spacing.xl : Spacing.lg),

                // Hero headline - Editorial style
                Text(
                  Strings.heroHeadline,
                  style: isDesktop
                      ? theme.textTheme.displayLarge
                      : theme.textTheme.displayMedium,
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: isDesktop ? Spacing.xl : Spacing.lg),

                // Subheadline
                Text(
                  Strings.heroSubheadline,
                  style: isDesktop
                      ? theme.textTheme.headlineMedium?.copyWith(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          color: AppTheme.textSecondary,
                        )
                      : theme.textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                ),

                SizedBox(height: isDesktop ? Spacing.xxxl : Spacing.xl),

                // CTA buttons
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: Spacing.md,
                  runSpacing: Spacing.md,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Scroll to tool selection
                        Scrollable.ensureVisible(
                          context,
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeInOut,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? Spacing.xxl : Spacing.xl,
                          vertical: isDesktop ? Spacing.lg : Spacing.md,
                        ),
                      ),
                      child: Text(
                        Strings.ctaPrimary,
                        style: TextStyle(fontSize: isDesktop ? 18 : 16),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () => context.go('/pricing'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? Spacing.xxl : Spacing.xl,
                          vertical: isDesktop ? Spacing.lg : Spacing.md,
                        ),
                      ),
                      child: Text(
                        Strings.ctaSecondary,
                        style: TextStyle(fontSize: isDesktop ? 18 : 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrustIndicators(ThemeData theme, bool isDesktop) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: isDesktop ? Spacing.xl : Spacing.md,
      runSpacing: Spacing.sm,
      children: [
        _buildTrustBadge(theme, Strings.trustDsgvo, Icons.verified_outlined),
        _buildTrustBadge(theme, Strings.trustLocal, Icons.computer_outlined),
        _buildTrustBadge(theme, Strings.trustOpenSource, Icons.code_outlined),
      ],
    );
  }

  Widget _buildTrustBadge(ThemeData theme, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.sm,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.border),
        color: AppTheme.surface,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.primary),
          SizedBox(width: Spacing.xs),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.75,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tool selection with sophisticated card design
class _ToolSelectionSection extends StatelessWidget {
  const _ToolSelectionSection();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= Breakpoints.desktop;
    final isTablet = screenWidth >= Breakpoints.tablet;

    return Container(
      color: AppTheme.surface,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? Spacing.massive : (isTablet ? Spacing.xxxl : Spacing.lg),
        vertical: isDesktop ? Spacing.massive : Spacing.xxxl,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              // Section title
              Text(
                Strings.toolsHeading,
                style: isDesktop
                    ? Theme.of(context).textTheme.displaySmall
                    : Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),

              SizedBox(height: isDesktop ? Spacing.xxxl : Spacing.xl),

              // Tool cards with staggered fade-in
              LayoutBuilder(
                builder: (context, constraints) {
                  if (isDesktop) {
                    return Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: FadeInWidget(
                                delay: const Duration(milliseconds: 0),
                                child: _ToolCard(
                                  title: Strings.toolMergeTitle,
                                  description: Strings.toolMergeDesc,
                                  icon: Icons.merge_outlined,
                                  route: '/merge',
                                  accentColor: AppTheme.primary,
                                ),
                              ),
                            ),
                            SizedBox(width: Spacing.xl),
                            Expanded(
                              child: FadeInWidget(
                                delay: const Duration(milliseconds: 100),
                                child: _ToolCard(
                                  title: Strings.toolSplitTitle,
                                  description: Strings.toolSplitDesc,
                                  icon: Icons.splitscreen_outlined,
                                  route: '/split',
                                  accentColor: AppTheme.secondary,
                                ),
                              ),
                            ),
                            SizedBox(width: Spacing.xl),
                            Expanded(
                              child: FadeInWidget(
                                delay: const Duration(milliseconds: 200),
                                child: _ToolCard(
                                  title: Strings.toolProtectTitle,
                                  description: Strings.toolProtectDesc,
                                  icon: Icons.lock_outlined,
                                  route: '/protect',
                                  accentColor: Color(0xFF6B8E7F),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: Spacing.xl),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: FadeInWidget(
                                delay: const Duration(milliseconds: 300),
                                child: _ToolCard(
                                  title: Strings.compressToolTitle,
                                  description: Strings.compressToolDesc,
                                  icon: Icons.compress,
                                  route: '/compress',
                                  accentColor: Color(0xFF8E6B7F),
                                ),
                              ),
                            ),
                            SizedBox(width: Spacing.xl),
                            Expanded(
                              child: FadeInWidget(
                                delay: const Duration(milliseconds: 400),
                                child: _ToolCard(
                                  title: Strings.ocrToolTitle,
                                  description: Strings.ocrToolDesc,
                                  icon: Icons.text_fields_outlined,
                                  route: '/ocr',
                                  accentColor: Color(0xFF7F8E6B),
                                ),
                              ),
                            ),
                            SizedBox(width: Spacing.xl),
                            Expanded(child: SizedBox.shrink()),
                          ],
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        FadeInWidget(
                          delay: const Duration(milliseconds: 0),
                          child: _ToolCard(
                            title: Strings.toolMergeTitle,
                            description: Strings.toolMergeDesc,
                            icon: Icons.merge_outlined,
                            route: '/merge',
                            accentColor: AppTheme.primary,
                          ),
                        ),
                        SizedBox(height: Spacing.lg),
                        FadeInWidget(
                          delay: const Duration(milliseconds: 100),
                          child: _ToolCard(
                            title: Strings.toolSplitTitle,
                            description: Strings.toolSplitDesc,
                            icon: Icons.splitscreen_outlined,
                            route: '/split',
                            accentColor: AppTheme.secondary,
                          ),
                        ),
                        SizedBox(height: Spacing.lg),
                        FadeInWidget(
                          delay: const Duration(milliseconds: 200),
                          child: _ToolCard(
                            title: Strings.toolProtectTitle,
                            description: Strings.toolProtectDesc,
                            icon: Icons.lock_outlined,
                            route: '/protect',
                            accentColor: Color(0xFF6B8E7F),
                          ),
                        ),
                        SizedBox(height: Spacing.lg),
                        FadeInWidget(
                          delay: const Duration(milliseconds: 300),
                          child: _ToolCard(
                            title: Strings.compressToolTitle,
                            description: Strings.compressToolDesc,
                            icon: Icons.compress,
                            route: '/compress',
                            accentColor: Color(0xFF8E6B7F),
                          ),
                        ),
                        SizedBox(height: Spacing.lg),
                        FadeInWidget(
                          delay: const Duration(milliseconds: 400),
                          child: _ToolCard(
                            title: Strings.ocrToolTitle,
                            description: Strings.ocrToolDesc,
                            icon: Icons.text_fields_outlined,
                            route: '/ocr',
                            accentColor: Color(0xFF7F8E6B),
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String route;
  final Color accentColor;

  const _ToolCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedCard(
      onTap: () => context.go(route),
      borderColor: AppTheme.border,
      hoverBorderColor: accentColor,
      backgroundColor: AppTheme.background,
      borderRadius: 0,
      padding: const EdgeInsets.all(Spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              border: Border.all(
                color: accentColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              size: 32,
              color: accentColor,
            ),
          ),

          SizedBox(height: Spacing.lg),

          // Title
          Text(
            title,
            style: theme.textTheme.headlineSmall,
          ),

          SizedBox(height: Spacing.sm),

          // Description
          Text(
            description,
            style: theme.textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: Spacing.lg),

          // Arrow indicator
          Row(
            children: [
              Text(
                Strings.toolCardCta,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: Spacing.xs),
              Icon(
                Icons.arrow_forward,
                size: 18,
                color: accentColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Value proposition section with editorial layout
class _ValuePropositionSection extends StatelessWidget {
  const _ValuePropositionSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= Breakpoints.desktop;
    final isTablet = screenWidth >= Breakpoints.tablet;

    return Container(
      color: AppTheme.background,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? Spacing.massive : (isTablet ? Spacing.xxxl : Spacing.lg),
        vertical: isDesktop ? Spacing.massive : Spacing.xxxl,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: FadeInWidget(
                        delay: const Duration(milliseconds: 0),
                        child: _ValueCard(
                          title: Strings.valuePrivacyTitle,
                          description: Strings.valuePrivacyDesc,
                          icon: Icons.shield_outlined,
                        ),
                      ),
                    ),
                    SizedBox(width: Spacing.xxxl),
                    Expanded(
                      child: FadeInWidget(
                        delay: const Duration(milliseconds: 100),
                        child: _ValueCard(
                          title: Strings.valueSecurityTitle,
                          description: Strings.valueSecurityDesc,
                          icon: Icons.verified_user_outlined,
                        ),
                      ),
                    ),
                    SizedBox(width: Spacing.xxxl),
                    Expanded(
                      child: FadeInWidget(
                        delay: const Duration(milliseconds: 200),
                        child: _ValueCard(
                          title: Strings.valueSpeedTitle,
                          description: Strings.valueSpeedDesc,
                          icon: Icons.bolt_outlined,
                        ),
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    FadeInWidget(
                      delay: const Duration(milliseconds: 0),
                      child: _ValueCard(
                        title: Strings.valuePrivacyTitle,
                        description: Strings.valuePrivacyDesc,
                        icon: Icons.shield_outlined,
                      ),
                    ),
                    SizedBox(height: Spacing.xl),
                    FadeInWidget(
                      delay: const Duration(milliseconds: 100),
                      child: _ValueCard(
                        title: Strings.valueSecurityTitle,
                        description: Strings.valueSecurityDesc,
                        icon: Icons.verified_user_outlined,
                      ),
                    ),
                    SizedBox(height: Spacing.xl),
                    FadeInWidget(
                      delay: const Duration(milliseconds: 200),
                      child: _ValueCard(
                        title: Strings.valueSpeedTitle,
                        description: Strings.valueSpeedDesc,
                        icon: Icons.bolt_outlined,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ValueCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const _ValueCard({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 48,
          color: AppTheme.primary,
        ),
        SizedBox(height: Spacing.lg),
        Text(
          title,
          style: theme.textTheme.headlineMedium,
        ),
        SizedBox(height: Spacing.md),
        Text(
          description,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppTheme.textSecondary,
            height: 1.7,
          ),
        ),
      ],
    );
  }
}
