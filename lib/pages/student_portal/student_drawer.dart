import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'models/student_session.dart';
import 'student_login_page.dart';

class StudentDrawer extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const StudentDrawer({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final s = StudentSession.student;
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 36, 20, 18),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF5F61E6), Color(0xFF7B7EF1)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/logo1.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Capital University',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  s?.fullName ?? 'Student',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.92),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if ((s?.studentId ?? '').isNotEmpty)
                  Text(
                    s!.studentId,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.78),
                      fontSize: 11.5,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _Item(
                  icon: Iconsax.home,
                  title: 'Home',
                  index: 0,
                  selected: selectedIndex == 0,
                  onTap: () => onSelect(0),
                ),
                _Item(
                  icon: Iconsax.people,
                  title: 'Profile',
                  index: 1,
                  selected: selectedIndex == 1,
                  onTap: () => onSelect(1),
                ),
                const Divider(),
                const ListTile(
                  leading: Icon(
                    Iconsax.info_circle,
                    color: Color(0xFF8A8F95),
                    size: 18,
                  ),
                  title: Text(
                    'Version 5.0.0',
                    style: TextStyle(
                      color: Color(0xFF8A8F95),
                      fontSize: 13,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Iconsax.logout,
                    color: Color(0xFFE5484D),
                  ),
                  title: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFE5484D),
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await StudentSession.clear();
                    if (!context.mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StudentLoginPage(),
                      ),
                      (_) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final IconData icon;
  final String title;
  final int index;
  final bool selected;
  final VoidCallback onTap;
  const _Item({
    required this.icon,
    required this.title,
    required this.index,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? const Color(0xFF5F61E6).withOpacity(0.10)
          : Colors.transparent,
      child: ListTile(
        leading: Icon(
          icon,
          color: selected ? const Color(0xFF5F61E6) : const Color(0xFF1B1E22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
            color: selected ? const Color(0xFF5F61E6) : const Color(0xFF1B1E22),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
