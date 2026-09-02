import 'package:flutter/material.dart';

import 'classes_page.dart';
import 'models/teacher_session.dart';
import 'rate_app_page.dart';
import 'report_page.dart';
import 'teacher_drawer.dart';
import 'upload_lesson_page.dart';

class TeacherShell extends StatefulWidget {
  final TeacherSession session;

  const TeacherShell({super.key, required this.session});

  @override
  State<TeacherShell> createState() => _TeacherShellState();
}

class _TeacherShellState extends State<TeacherShell> {
  int _index = 0;

  static const _titles = [
    'Classes',
    'Report',
    'Upload Lesson',
    'Rate the App',
  ];

  late final List<Widget> _pages = [
    ClassesPage(session: widget.session),
    ReportPage(session: widget.session),
    const UploadLessonPage(),
    const RateAppPage(),
  ];

  void _switch(int i) {
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        centerTitle: true,
        elevation: 0,
      ),
      drawer: TeacherDrawer(
        session: widget.session,
        currentIndex: _index,
        onSwitch: _switch,
      ),
      body: _pages[_index],
    );
  }
}
