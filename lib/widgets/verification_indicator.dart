import 'package:flutter/material.dart';
import '../services/network_verification_service.dart';

/// Widget to display network verification status
///
/// Shows "✓ Client-seitig verarbeitet (100% lokal)" when verification passes
/// Shows "✗ Netzwerkaktivität erkannt" when suspicious activity is detected
class VerificationIndicator extends StatelessWidget {
  final NetworkVerificationReport? report;
  final bool compact;

  const VerificationIndicator({
    super.key,
    this.report,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (report == null) {
      return const SizedBox.shrink();
    }

    final passed = report!.passed;

    if (compact) {
      return _buildCompact(context, passed);
    }

    return _buildFull(context, passed);
  }

  /// Build compact indicator (icon + text)
  Widget _buildCompact(BuildContext context, bool passed) {
    final theme = Theme.of(context);
    final color = passed ? Colors.green : Colors.red;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          passed ? Icons.check_circle : Icons.error,
          color: color,
          size: 16,
        ),
        const SizedBox(width: 6),
        Text(
          passed ? '100% lokal' : 'Netzwerkaktivität',
          style: theme.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Build full indicator (with details)
  Widget _buildFull(BuildContext context, bool passed) {
    final theme = Theme.of(context);
    final color = passed ? Colors.green : Colors.red;
    final backgroundColor = passed
        ? Colors.green.withOpacity(0.1)
        : Colors.red.withOpacity(0.1);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            passed ? Icons.verified_user : Icons.warning,
            color: color,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  passed
                      ? 'Client-seitig verarbeitet'
                      : 'Netzwerkaktivität erkannt',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  passed
                      ? 'Ihre Dateien wurden zu 100% lokal auf Ihrem Computer verarbeitet. '
                          'Keine Daten wurden hochgeladen.'
                      : 'Unerwartete Netzwerkaktivität wurde während der Verarbeitung erkannt. '
                          'Bitte kontaktieren Sie den Support.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge-style verification indicator
class VerificationBadge extends StatelessWidget {
  final bool verified;

  const VerificationBadge({
    super.key,
    this.verified = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: verified
            ? Colors.green.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: verified
              ? Colors.green.withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            verified ? Icons.verified : Icons.shield,
            color: verified ? Colors.green : Colors.grey[600],
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            '100% lokal',
            style: theme.textTheme.bodySmall?.copyWith(
              color: verified ? Colors.green : Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Trust signal widget for footer/landing page
class TrustSignal extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const TrustSignal({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Predefined trust signals
  static const trustSignals = [
    TrustSignal(
      icon: Icons.shield_outlined,
      title: '100% lokal',
      description:
          'Alle Verarbeitungen finden direkt in Ihrem Browser statt. Ihre Dateien verlassen niemals Ihren Computer.',
    ),
    TrustSignal(
      icon: Icons.lock_outline,
      title: 'DSGVO-konform',
      description:
          'Keine Datenübertragung, keine Speicherung auf Servern. Ihre Privatsphäre ist garantiert.',
    ),
    TrustSignal(
      icon: Icons.code_outlined,
      title: 'Open Source',
      description:
          'Unser Code ist öffentlich einsehbar. Sie können selbst überprüfen, dass keine Daten hochgeladen werden.',
    ),
  ];
}
