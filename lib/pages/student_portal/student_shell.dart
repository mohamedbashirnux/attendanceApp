import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../theme/brand_colors.dart';
import 'student_drawer.dart';
import 'student_home_page.dart';
import 'student_profile_page.dart';
import 'student_timetable_page.dart';

class StudentShell extends StatefulWidget {
  const StudentShell({super.key});

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  int _index = 0;

  static const _pages = <Widget>[
    StudentHomePage(),
    StudentTimetablePage(),
    StudentProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const StudentDrawer(),
      body: _pages[_index],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: BrandColors.accent,
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          elevation: 8,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Iconsax.chart),
              label: 'Attendance',
            ),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.calendar_1),
              label: 'Timetable',
            ),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.user),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
