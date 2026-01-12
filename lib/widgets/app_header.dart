import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/strings.dart';
import '../theme/app_theme.dart';

/// Sophisticated editorial-style header with sticky positioning
class AppHeader extends StatefulWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  bool _isToolsExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= Breakpoints.tablet;

    return Container(
      height: widget.preferredSize.height,
      decoration: BoxDecoration(
        color: AppTheme.background,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.border,
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? Spacing.xxxl : Spacing.lg,
        ),
        child: Row(
          children: [
            // Logo
            _buildLogo(theme),

            const Spacer(),

            // Desktop Navigation
            if (isDesktop) ...[
              _buildDesktopNav(context, theme),
              SizedBox(width: Spacing.xl),
              _buildCta(context, theme),
            ],

            // Mobile Menu
            if (!isDesktop)
              IconButton(
                icon: const Icon(Icons.menu, size: 28),
                onPressed: () => _showMobileMenu(context),
                color: AppTheme.textPrimary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(ThemeData theme) {
    return InkWell(
      onTap: () => context.go('/'),
      child: Row(
        children: [
          // Minimalist icon - geometric PDF symbol
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppTheme.primary,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                'P',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontFamily: 'Cormorant',
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                  height: 1.0,
                ),
              ),
            ),
          ),
          SizedBox(width: Spacing.md),
          Text(
            Strings.appName,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontFamily: 'Cormorant',
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopNav(BuildContext context, ThemeData theme) {
    final currentRoute = GoRouterState.of(context).uri.path;

    return Row(
      children: [
        _buildNavLink(context, theme, Strings.navHome, '/', currentRoute == '/'),
        SizedBox(width: Spacing.xl),
        _buildToolsDropdown(context, theme, currentRoute),
        SizedBox(width: Spacing.xl),
        _buildNavLink(context, theme, Strings.navPricing, '/pricing', currentRoute == '/pricing'),
      ],
    );
  }

  Widget _buildNavLink(
    BuildContext context,
    ThemeData theme,
    String label,
    String route,
    bool isActive,
  ) {
    return InkWell(
      onTap: () => context.go(route),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm,
          vertical: Spacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: isActive ? AppTheme.primary : AppTheme.textSecondary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (isActive) ...[
              SizedBox(height: 4),
              Container(
                width: 24,
                height: 2,
                color: AppTheme.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildToolsDropdown(BuildContext context, ThemeData theme, String currentRoute) {
    final isToolsActive = currentRoute.startsWith('/merge') ||
                          currentRoute.startsWith('/split') ||
                          currentRoute.startsWith('/protect');

    return MouseRegion(
      onEnter: (_) => setState(() => _isToolsExpanded = true),
      onExit: (_) => setState(() => _isToolsExpanded = false),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => setState(() => _isToolsExpanded = !_isToolsExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.sm,
                vertical: Spacing.sm,
              ),
              child: Row(
                children: [
                  Text(
                    Strings.navTools,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: isToolsActive ? AppTheme.primary : AppTheme.textSecondary,
                      fontWeight: isToolsActive ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    _isToolsExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: isToolsActive ? AppTheme.primary : AppTheme.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (_isToolsExpanded)
            Container(
              margin: const EdgeInsets.only(top: 16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                border: Border.all(color: AppTheme.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDropdownItem(context, theme, Strings.toolMergeTitle, '/merge'),
                  Divider(height: 1, color: AppTheme.border),
                  _buildDropdownItem(context, theme, Strings.toolSplitTitle, '/split'),
                  Divider(height: 1, color: AppTheme.border),
                  _buildDropdownItem(context, theme, Strings.toolProtectTitle, '/protect'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDropdownItem(BuildContext context, ThemeData theme, String label, String route) {
    return InkWell(
      onTap: () {
        setState(() => _isToolsExpanded = false);
        context.go(route);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.lg,
          vertical: Spacing.md,
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildCta(BuildContext context, ThemeData theme) {
    return ElevatedButton(
      onPressed: () => context.go('/pricing'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.lg,
          vertical: Spacing.md,
        ),
      ),
      child: const Text(Strings.navUpgrade),
    );
  }

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _MobileMenu(),
    );
  }
}

class _MobileMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: Spacing.xl),

            // Menu items
            _buildMobileMenuItem(context, theme, Strings.navHome, '/', Icons.home_outlined),
            SizedBox(height: Spacing.md),

            Text(
              Strings.navTools,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
            ),
            SizedBox(height: Spacing.sm),
            _buildMobileMenuItem(context, theme, Strings.toolMergeTitle, '/merge', Icons.merge_outlined),
            _buildMobileMenuItem(context, theme, Strings.toolSplitTitle, '/split', Icons.splitscreen_outlined),
            _buildMobileMenuItem(context, theme, Strings.toolProtectTitle, '/protect', Icons.lock_outlined),

            SizedBox(height: Spacing.md),
            _buildMobileMenuItem(context, theme, Strings.navPricing, '/pricing', Icons.credit_card_outlined),

            SizedBox(height: Spacing.xl),

            // CTA
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/pricing');
              },
              child: const Text(Strings.navUpgrade),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileMenuItem(
    BuildContext context,
    ThemeData theme,
    String label,
    String route,
    IconData icon,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        context.go(route);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.md),
        child: Row(
          children: [
            Icon(icon, size: 24, color: AppTheme.textSecondary),
            SizedBox(width: Spacing.md),
            Text(
              label,
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
