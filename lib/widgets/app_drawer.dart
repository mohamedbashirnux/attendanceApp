import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../pages/rector_message_page.dart';
import '../pages/contact_us_page.dart';
import '../pages/privacy_page.dart';
import '../pages/about_developer_page.dart';
import '../pages/teacher_portal/teacher_login_page.dart';
import '../pages/student_portal/student_login_page.dart';
import '../theme/brand_colors.dart';

class AppDrawer extends StatelessWidget {
  /// Optional callback used by the bottom-nav shell (`TabsScreen`) to
  /// jump straight to the Home tab when the user taps the Home item.
  /// When null (e.g. on the teacher/student login pages) tapping Home
  /// just pushes a fresh `TabsScreen` with the Home tab selected.
  final Function(int)? onHomePressed;

  const AppDrawer({super.key, this.onHomePressed});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: BrandColors.accentGradient,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset('assets/logo1.png', fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Capital University',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Committed to Excellence',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context: context,
            icon: Iconsax.home,
            title: 'Home',
            onTap: () {
              Navigator.pop(context);
              if (onHomePressed != null) {
                onHomePressed!(0);
              }
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Iconsax.book,
            title: 'Lectures Portal',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TeacherLoginPage(),
                ),
              );
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Iconsax.user,
            title: 'Student Portal',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StudentLoginPage(),
                ),
              );
            },
          ),
          const Divider(),
          _buildDrawerItem(
            context: context,
            icon: Iconsax.message_text,
            title: 'Rector Message',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RectorMessagePage(),
                ),
              );
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Iconsax.call,
            title: 'Contact Us',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ContactUsPage()),
              );
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Iconsax.shield_tick,
            title: 'Privacy',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrivacyPage()),
              );
            },
          ),
          const Divider(),
          _buildDrawerItem(
            context: context,
            icon: Iconsax.code,
            title: 'About Developer',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AboutDeveloperPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: BrandColors.accent),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }
}
