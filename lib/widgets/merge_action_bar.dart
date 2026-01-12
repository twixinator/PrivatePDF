import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../constants/strings.dart';

/// Action bar for merge operations
/// Shows clear and merge buttons
class MergeActionBar extends StatelessWidget {
  final VoidCallback onMerge;
  final VoidCallback onClear;
  final bool canMerge;

  const MergeActionBar({
    super.key,
    required this.onMerge,
    required this.onClear,
    required this.canMerge,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= Breakpoints.desktop;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Clear button
        OutlinedButton(
          onPressed: onClear,
          child: const Text('Alle entfernen'),
        ),

        // Merge button
        ElevatedButton(
          onPressed: canMerge ? onMerge : null,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? Spacing.xxl : Spacing.xl,
              vertical: Spacing.md,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(Strings.mergeButton),
              if (canMerge) ...[
                SizedBox(width: Spacing.sm),
                const Icon(Icons.arrow_forward, size: 18),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
