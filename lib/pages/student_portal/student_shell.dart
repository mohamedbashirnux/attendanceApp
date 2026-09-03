import 'package:flutter/material.dart';

import 'student_drawer.dart';
import 'student_home_page.dart';
import 'student_profile_page.dart';

class StudentShell extends StatefulWidget {
  const StudentShell({super.key});

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const [
      StudentHomePage(),
      StudentProfilePage(),
    ];
    return Scaffold(
      drawer: StudentDrawer(
        selectedIndex: _index,
        onSelect: (i) {
          setState(() => _index = i);
          Navigator.pop(context);
        },
      ),
      body: pages[_index],
    );
  }
}
