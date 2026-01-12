import 'package:flutter/material.dart';
import '../constants/strings.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/app_footer.dart';

class PricingPage extends StatelessWidget {
  const PricingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(),
      body: SingleChildScrollView(
        child: Column(
          children: const [
            _PricingHeroSection(),
            _PricingTiersSection(),
            _FaqSection(),
            AppFooter(),
          ],
        ),
      ),
    );
  }
}

class _PricingHeroSection extends StatelessWidget {
  const _PricingHeroSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= Breakpoints.desktop;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? Spacing.massive : Spacing.lg,
        vertical: isDesktop ? Spacing.xxxl : Spacing.xl,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Text(
                'Einfache Preise.',
                style: isDesktop
                    ? theme.textTheme.displayMedium
                    : theme.textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: Spacing.md),
              Text(
                'Wählen Sie das Modell, das zu Ihnen passt.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PricingTiersSection extends StatelessWidget {
  const _PricingTiersSection();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= Breakpoints.desktop;
    final isTablet = screenWidth >= Breakpoints.tablet;

    return Container(
      color: AppTheme.surface,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? Spacing.massive : Spacing.lg,
        vertical: isDesktop ? Spacing.massive : Spacing.xxxl,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: isDesktop || isTablet
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _PricingCard(
                        tier: Strings.pricingFreeTier,
                        price: Strings.pricingFreePrice,
                        subtitle: '',
                        features: const [
                          Strings.pricingFreeFeature1,
                          Strings.pricingFreeFeature2,
                          Strings.pricingFreeFeature3,
                        ],
                        isPro: false,
                      ),
                    ),
                    SizedBox(width: Spacing.xl),
                    Expanded(
                      child: _PricingCard(
                        tier: Strings.pricingProTier,
                        price: Strings.pricingProPrice,
                        subtitle: Strings.pricingProSubtitle,
                        features: const [
                          Strings.pricingProFeature1,
                          Strings.pricingProFeature2,
                          Strings.pricingProFeature3,
                        ],
                        isPro: true,
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _PricingCard(
                      tier: Strings.pricingFreeTier,
                      price: Strings.pricingFreePrice,
                      subtitle: '',
                      features: const [
                        Strings.pricingFreeFeature1,
                        Strings.pricingFreeFeature2,
                        Strings.pricingFreeFeature3,
                      ],
                      isPro: false,
                    ),
                    SizedBox(height: Spacing.xl),
                    _PricingCard(
                      tier: Strings.pricingProTier,
                      price: Strings.pricingProPrice,
                      subtitle: Strings.pricingProSubtitle,
                      features: const [
                        Strings.pricingProFeature1,
                        Strings.pricingProFeature2,
                        Strings.pricingProFeature3,
                      ],
                      isPro: true,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _PricingCard extends StatefulWidget {
  final String tier;
  final String price;
  final String subtitle;
  final List<String> features;
  final bool isPro;

  const _PricingCard({
    required this.tier,
    required this.price,
    required this.subtitle,
    required this.features,
    required this.isPro,
  });

  @override
  State<_PricingCard> createState() => _PricingCardState();
}

class _PricingCardState extends State<_PricingCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _isHovered ? -8 : 0, 0),
        child: Container(
          padding: const EdgeInsets.all(Spacing.xxxl),
          decoration: BoxDecoration(
            color: widget.isPro
                ? AppTheme.primary.withOpacity(0.03)
                : AppTheme.background,
            border: Border.all(
              color: _isHovered
                  ? (widget.isPro ? AppTheme.primary : AppTheme.border)
                  : AppTheme.border,
              width: widget.isPro ? 2 : 1,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.isPro
                          ? AppTheme.primary.withOpacity(0.1)
                          : Colors.black.withOpacity(0.05),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tier name
              Row(
                children: [
                  Text(
                    widget.tier,
                    style: theme.textTheme.headlineMedium,
                  ),
                  if (widget.isPro) ...[
                    SizedBox(width: Spacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                      ),
                      child: Text(
                        'BELIEBT',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              SizedBox(height: Spacing.lg),

              // Price
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.price,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              if (widget.subtitle.isNotEmpty) ...[
                SizedBox(height: Spacing.xs),
                Text(
                  widget.subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
              ],

              SizedBox(height: Spacing.xl),

              Divider(color: AppTheme.border, height: 1),

              SizedBox(height: Spacing.xl),

              // Features
              ...widget.features.map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: Spacing.md),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check,
                          size: 20,
                          color: widget.isPro ? AppTheme.primary : AppTheme.success,
                        ),
                        SizedBox(width: Spacing.sm),
                        Expanded(
                          child: Text(
                            feature,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  )),

              SizedBox(height: Spacing.xl),

              // CTA Button
              SizedBox(
                width: double.infinity,
                child: widget.isPro
                    ? ElevatedButton(
                        onPressed: () {
                          // TODO: Implement upgrade flow
                        },
                        child: const Text(Strings.pricingProCta),
                      )
                    : OutlinedButton(
                        onPressed: () {
                          // TODO: Navigate to tools
                        },
                        child: Text(Strings.buttonStartNow),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaqSection extends StatelessWidget {
  const _FaqSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= Breakpoints.desktop;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? Spacing.massive : Spacing.lg,
        vertical: isDesktop ? Spacing.massive : Spacing.xxxl,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Strings.pricingFaqTitle,
                style: isDesktop
                    ? theme.textTheme.displaySmall
                    : theme.textTheme.headlineLarge,
              ),
              SizedBox(height: Spacing.xxxl),
              _FaqItem(
                question: Strings.pricingFaqQ1,
                answer: Strings.pricingFaqA1,
              ),
              SizedBox(height: Spacing.xl),
              _FaqItem(
                question: Strings.pricingFaqQ2,
                answer: Strings.pricingFaqA2,
              ),
              SizedBox(height: Spacing.xl),
              _FaqItem(
                question: Strings.pricingFaqQ3,
                answer: Strings.pricingFaqA3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqItem({
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: theme.textTheme.headlineSmall,
        ),
        SizedBox(height: Spacing.md),
        Text(
          answer,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppTheme.textSecondary,
            height: 1.7,
          ),
        ),
      ],
    );
  }
}
