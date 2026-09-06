import 'package:flutter/material.dart';

import '../../../theme/brand_colors.dart';

/// Reusable "Coming soon" panel for placeholder pages.
class ComingSoon extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? subtitle;

  const ComingSoon({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72, color: BrandColors.accent),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: BrandColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle ?? 'This feature is coming soon.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: BrandColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
