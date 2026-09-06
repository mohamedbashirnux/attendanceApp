import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../pages/student_portal/models/student_session.dart';
import '../theme/brand_colors.dart';
import 'tabs_screen.dart';

/// AppBar action that logs the current student out. Shows a
/// confirmation dialog so a stray tap doesn't drop the user out of
/// their session. After confirming, clears the persisted student
/// session and pops back to the main app shell (`TabsScreen`).
class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Logout',
      onPressed: () => _confirmAndLogout(context),
      icon: const Icon(
        Iconsax.logout,
        size: 20,
        color: BrandColors.danger,
      ),
    );
  }

  Future<void> _confirmAndLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Iconsax.logout, color: BrandColors.danger, size: 22),
            SizedBox(width: 10),
            Text('Logout'),
          ],
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontSize: 15, color: BrandColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: BrandColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Logout',
              style: TextStyle(
                color: BrandColors.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (shouldLogout != true) return;
    if (!context.mounted) return;
    await StudentSession.clear();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const TabsScreen()),
      (_) => false,
    );
  }
}
