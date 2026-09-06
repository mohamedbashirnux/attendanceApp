import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../theme/brand_colors.dart';
import '../../widgets/tabs_screen.dart';
import 'models/teacher_session.dart';

typedef TeacherPageSwitcher = void Function(int index);

class TeacherDrawer extends StatelessWidget {
  final TeacherSession session;
  final int currentIndex;
  final TeacherPageSwitcher onSwitch;

  const TeacherDrawer({
    super.key,
    required this.session,
    required this.currentIndex,
    required this.onSwitch,
  });

  static const _appVersion = '5.0.0';

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            _Header(session: session),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _Item(
                    icon: Iconsax.home,
                    title: 'Classes',
                    selected: currentIndex == 0,
                    onTap: () => _go(context, 0),
                  ),
                  _Item(
                    icon: Iconsax.document_text,
                    title: 'Report',
                    selected: currentIndex == 1,
                    onTap: () => _go(context, 1),
                  ),
                  _Item(
                    icon: Iconsax.document_upload,
                    title: 'Upload Lesson',
                    selected: currentIndex == 2,
                    onTap: () => _go(context, 2),
                  ),
                  _Item(
                    icon: Iconsax.star1,
                    title: 'Rate the App',
                    selected: currentIndex == 3,
                    onTap: () => _go(context, 3),
                  ),
                  const Divider(height: 24, color: BrandColors.border),
                  ListTile(
                    leading: const Icon(
                      Iconsax.info_circle,
                      color: BrandColors.textMuted,
                    ),
                    title: const Text(
                      'Version',
                      style: TextStyle(
                        fontSize: 14,
                        color: BrandColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Text(
                      _appVersion,
                      style: TextStyle(
                        fontSize: 14,
                        color: BrandColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
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

  void _go(BuildContext context, int index) {
    Navigator.pop(context);
    onSwitch(index);
  }

  Future<void> _logout(BuildContext context) async {
    Navigator.pop(context);
    await TeacherSession.clear();
    if (!context.mounted) return;
    // Logout should drop the teacher back to the main app shell
    // (the bottom-nav home), not to the login screen.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const TabsScreen()),
      (_) => false,
    );
  }
}

class _Header extends StatelessWidget {
  final TeacherSession session;
  const _Header({required this.session});

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
            session.teacher.fullName,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (session.teacher.facultyName.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              session.teacher.facultyName,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _Item({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? BrandColors.accent : BrandColors.textPrimary;
    return Material(
      color: selected ? BrandColors.accentSoft : Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            color: color,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        trailing: selected
            ? Container(
                width: 6,
                height: 24,
                decoration: BoxDecoration(
                  color: BrandColors.accent,
                  borderRadius: BorderRadius.circular(3),
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
