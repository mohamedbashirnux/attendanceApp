import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../theme/brand_colors.dart';
import '../../widgets/tabs_screen.dart';
import 'models/student_session.dart';

/// Student drawer.
///
/// Mirrors the teacher drawer's look (header + Logout at the bottom).
/// Only Logout is wired up for now — the rest of the student-side
/// navigation items will be added later.
class StudentDrawer extends StatelessWidget {
  const StudentDrawer({super.key});

  static const _appVersion = '5.0.0';

  @override
  Widget build(BuildContext context) {
    final s = StudentSession.student;
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            _Header(studentName: s?.fullName, studentId: s?.studentId),
            const Expanded(child: SizedBox.shrink()),
            const Divider(height: 1, color: BrandColors.border),
            const ListTile(
              leading: Icon(
                Iconsax.info_circle,
                color: BrandColors.textMuted,
              ),
              title: Text(
                'Version',
                style: TextStyle(
                  fontSize: 14,
                  color: BrandColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: Text(
                _appVersion,
                style: TextStyle(
                  fontSize: 14,
                  color: BrandColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Divider(height: 1, color: BrandColors.border),
            ListTile(
              leading: const Icon(Iconsax.logout, color: BrandColors.danger),
              title: const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: BrandColors.danger,
                ),
              ),
              onTap: () => _logout(context),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    Navigator.pop(context);
    await StudentSession.clear();
    if (!context.mounted) return;
    // Logout should drop the student back to the main app shell
    // (the bottom-nav home), not to the login screen.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const TabsScreen()),
      (_) => false,
    );
  }
}

class _Header extends StatelessWidget {
  final String? studentName;
  final String? studentId;
  const _Header({this.studentName, this.studentId});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: BrandColors.accentGradient,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 72,
            height: 72,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset('assets/logo1.png', fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Capital University',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            studentName ?? 'Student',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          if ((studentId ?? '').isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              studentId!,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}
