import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'models/attendance_report.dart';
import 'models/teacher_session.dart';
import 'teacher_api_service.dart';

class ClassReportPage extends StatefulWidget {
  final TeacherSession session;
  final int classId;
  final String className;
  final int subjectId;
  final String subjectName;
  final String departmentName;

  const ClassReportPage({
    super.key,
    required this.session,
    required this.classId,
    required this.className,
    required this.subjectId,
    required this.subjectName,
    required this.departmentName,
  });

  @override
  State<ClassReportPage> createState() => _ClassReportPageState();
}

class _ClassReportPageState extends State<ClassReportPage> {
  final _api = TeacherApiService();
  late Future<AttendanceReport> _future;
  String _query = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _future = _load();
    _searchController.addListener(() {
      final next = _searchController.text.trim();
      if (next != _query) {
        setState(() => _query = next);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<AttendanceReport> _load() {
    return _api.fetchReport(
      classId: widget.classId,
      subjectId: widget.subjectId,
      token: widget.session.token,
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Report'),
        centerTitle: true,
        elevation: 0,
      ),
      body: RefreshIndicator(
        color: const Color(0xFF5F61E6),
        onRefresh: _refresh,
        child: FutureBuilder<AttendanceReport>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(
                    child:
                        CircularProgressIndicator(color: Color(0xFF5F61E6)),
                  ),
                ],
              );
            }
            if (snapshot.hasError) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 80),
                  const Icon(Iconsax.warning_2,
                      size: 56, color: Color(0xFFE5484D)),
                  const SizedBox(height: 12),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF5B6167),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(Iconsax.refresh,
                          color: Color(0xFF5F61E6)),
                      label: const Text(
                        'Try again',
                        style: TextStyle(
                          color: Color(0xFF5F61E6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            final report = snapshot.data!;
            return _ReportBody(
              report: report,
              className: widget.className,
              subjectName: widget.subjectName,
              departmentName: widget.departmentName,
              searchController: _searchController,
              query: _query,
            );
          },
        ),
      ),
    );
  }
}

class _ReportBody extends StatefulWidget {
  final AttendanceReport report;
  final String className;
  final String subjectName;
  final String departmentName;
  final TextEditingController searchController;
  final String query;

  const _ReportBody({
    required this.report,
    required this.className,
    required this.subjectName,
    required this.departmentName,
    required this.searchController,
    required this.query,
  });

  @override
  State<_ReportBody> createState() => _ReportBodyState();
}

class _ReportBodyState extends State<_ReportBody> {
  bool _sessionsExpanded = false;

  void _openStudent(StudentReport s) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _StudentDetailSheet(
        student: s,
        subjectName: widget.subjectName,
        className: widget.className,
        rateColorOf: _rateColor,
        formatDate: _formatDateOnly,
      ),
    );
  }

  Color _rateColor(double rate) {
    // Green when attendance is healthy (≥70%), amber when 50–69%,
    // red when a student has missed 30%+ of sessions.
    if (rate >= 70) return const Color(0xFF16A34A);
    if (rate >= 50) return const Color(0xFFE89B2A);
    return const Color(0xFFE5484D);
  }

  String _formatDateTime(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${months[d.month - 1]} ${d.year} · $hh:$mm';
  }

  String _formatDateOnly(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    final rateColor = _rateColor(report.classAttendanceRate);

    // Filter students
    final filteredStudents = widget.query.isEmpty
        ? report.students
        : report.students.where((s) {
            final q = widget.query.toLowerCase();
            return s.fullName.toLowerCase().contains(q) ||
                s.studentId.toString().contains(widget.query);
          }).toList(growable: false);

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
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
              Text(
                widget.className,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.subjectName,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.departmentName,
                style: const TextStyle(fontSize: 12, color: Colors.white60),
              ),
            ],
          ),
        ),

        // KPIs row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: _KpiCard(
                  label: 'Attendance',
                  value: '${report.classAttendanceRate.toStringAsFixed(report.classAttendanceRate.truncateToDouble() == report.classAttendanceRate ? 0 : 1)}%',
                  color: rateColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _KpiCard(
                  label: 'Sessions',
                  value: '${report.totalSessions}',
                  color: const Color(0xFF1B1E22),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _KpiCard(
                  label: 'Students',
                  value: '${report.totalStudents}',
                  color: const Color(0xFF1B1E22),
                ),
              ),
            ],
          ),
        ),

        // Secondary stats
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: _MiniStat(
                  icon: Iconsax.close_circle,
                  label: 'Never attended',
                  value: '${report.neverAttendedCount}',
                  color: const Color(0xFFE5484D),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStat(
                  icon: Iconsax.calendar,
                  label: 'Last session',
                  value: report.lastSessionDate != null
                      ? _formatDateTime(report.lastSessionDate!)
                          .split(' · ')
                          .first
                      : '—',
                  color: const Color(0xFF5B6167),
                ),
              ),
            ],
          ),
        ),

        // Sessions section (collapsible, default closed)
        if (report.sessions.isNotEmpty) ...[
          InkWell(
            onTap: () =>
                setState(() => _sessionsExpanded = !_sessionsExpanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
              child: Row(
                children: [
                  const Text(
                    'SESSIONS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: Color(0xFF8A8F95),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEEFB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${report.totalSessions}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF5F61E6),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _sessionsExpanded ? 'Hide' : 'Show all',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF5F61E6),
                    ),
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: _sessionsExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: const Icon(
                      Iconsax.arrow_down_1,
                      size: 16,
                      color: Color(0xFF5F61E6),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            child: !_sessionsExpanded
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      children: [
                        for (final s in report.sessions)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _SessionTile(
                              session: s,
                              formatDate: _formatDateTime,
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
        ],

        // Students section
        _SectionHeader(
          title: 'Students',
          count: report.totalStudents,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: TextField(
            controller: widget.searchController,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1B1E22)),
            decoration: InputDecoration(
              hintText: 'Search by name or ID',
              hintStyle: const TextStyle(
                fontSize: 13,
                color: Color(0xFF8A8F95),
              ),
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 10, right: 6),
                child: Icon(
                  Iconsax.search_normal,
                  size: 16,
                  color: Color(0xFF8A8F95),
                ),
              ),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 0, minHeight: 0),
              suffixIcon: ValueListenableBuilder<TextEditingValue>(
                valueListenable: widget.searchController,
                builder: (context, value, _) {
                  if (value.text.isEmpty) return const SizedBox.shrink();
                  return IconButton(
                    icon: const Icon(
                      Iconsax.close_circle,
                      size: 16,
                      color: Color(0xFF8A8F95),
                    ),
                    onPressed: () => widget.searchController.clear(),
                  );
                },
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 10,
              ),
              filled: true,
              fillColor: const Color(0xFFF4F5F4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFF5F61E6),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),

        // Students table
        if (filteredStudents.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            child: Column(
              children: const [
                Icon(
                  Iconsax.search_normal,
                  size: 40,
                  color: Color(0xFFBFC2C7),
                ),
                SizedBox(height: 10),
                Text(
                  'No matching students',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF5B6167),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEEF0EE), width: 1),
              ),
              child: Column(
                children: [
                  _StudentHeader(),
                  for (int i = 0; i < filteredStudents.length; i++)
                    _StudentReportRow(
                      student: filteredStudents[i],
                      isOdd: i.isOdd,
                      colorOf: (pct) => _rateColor(pct),
                      onTap: () => _openStudent(filteredStudents[i]),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.18), width: 1),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEF0EE), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                    color: Color(0xFF8A8F95),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1B1E22),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: Color(0xFF8A8F95),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFEEEEFB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF5F61E6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final SessionRecord session;
  final String Function(DateTime) formatDate;

  const _SessionTile({required this.session, required this.formatDate});

  @override
  Widget build(BuildContext context) {
    final pct = session.attendancePercentage;
    final color = pct >= 75
        ? const Color(0xFF5F61E6)
        : pct >= 50
            ? const Color(0xFFE89B2A)
            : const Color(0xFFE5484D);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEF0EE), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '${pct.round()}%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatDate(session.sessionDatetime),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1B1E22),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${session.presentStudents} present · ${session.absentStudents} absent · ${session.totalStudents} total',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF5B6167),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFB),
        border: Border(
          bottom: BorderSide(color: Color(0xFFEEF0EE), width: 1),
        ),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 26,
            child: Text(
              '#',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: Color(0xFF8A8F95),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              'STUDENT',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: Color(0xFF8A8F95),
              ),
            ),
          ),
          SizedBox(
            width: 64,
            child: Text(
              'ABSENT',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: Color(0xFF8A8F95),
              ),
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              'RATE',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: Color(0xFF8A8F95),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentReportRow extends StatelessWidget {
  final StudentReport student;
  final bool isOdd;
  final Color Function(double) colorOf;
  final VoidCallback onTap;

  const _StudentReportRow({
    required this.student,
    required this.isOdd,
    required this.colorOf,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = colorOf(student.attendancePct);
    final pctText = student.totalSessions == 0
        ? '—'
        : '${student.attendancePct.toStringAsFixed(student.attendancePct.truncateToDouble() == student.attendancePct ? 0 : 1)}%';
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isOdd ? const Color(0xFFFAFAFB) : Colors.white,
          border: const Border(
            bottom: BorderSide(color: Color(0xFFEEF0EE), width: 1),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 26,
              child: Text(
                '${student.number}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF5F61E6),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.fullName,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B1E22),
                      height: 1.2,
                    ),
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${student.studentId}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF8A8F95),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 64,
              child: Text(
                student.totalSessions == 0
                    ? '—'
                    : '${student.absentSessions}/${student.totalSessions}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: student.absentSessions > 0
                      ? const Color(0xFFE5484D)
                      : const Color(0xFF1B1E22),
                ),
              ),
            ),
            SizedBox(
              width: 60,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  pctText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Iconsax.arrow_right_3,
              size: 14,
              color: Color(0xFFBFC2C7),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentDetailSheet extends StatelessWidget {
  final StudentReport student;
  final String subjectName;
  final String className;
  final Color Function(double) rateColorOf;
  final String Function(DateTime) formatDate;

  const _StudentDetailSheet({
    required this.student,
    required this.subjectName,
    required this.className,
    required this.rateColorOf,
    required this.formatDate,
  });

  String _excuseLabel(String excuse) {
    switch (excuse) {
      case 'Family_Emergency':
        return 'Family Emergency';
      case 'Medical_Appointment':
        return 'Medical Appointment';
      case 'Personal_Reason':
        return 'Personal Reason';
      case 'Official_Duty':
        return 'Official Duty';
      case 'Other':
        return 'Other';
      case 'No_Excuse':
      default:
        return 'No Excuse';
    }
  }

  @override
  Widget build(BuildContext context) {
    final pctText = student.totalSessions == 0
        ? '—'
        : '${student.attendancePct.toStringAsFixed(student.attendancePct.truncateToDouble() == student.attendancePct ? 0 : 1)}%';
    final hasAbsences = student.absentDates.isNotEmpty;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  // Header card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF5F61E6), Color(0xFF7B7EF1)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(
                                  '${student.number}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    student.fullName,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      height: 1.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'ID: ${student.studentId}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Attendance',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    pctText,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Sessions',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  student.totalSessions == 0
                                      ? '0'
                                      : '${student.presentSessions} / ${student.totalSessions}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Subject/class context
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFFEEF0EE), width: 1),
                    ),
                    child: Column(
                      children: [
                        _kv('Subject', subjectName),
                        const SizedBox(height: 8),
                        _kv('Class', className),
                        const SizedBox(height: 8),
                        _kv(
                          'Status',
                          student.neverAttended
                              ? 'Never attended'
                              : student.absentSessions == 0
                                  ? 'Perfect attendance'
                                  : '${student.absentSessions} absence${student.absentSessions == 1 ? '' : 's'}',
                          valueColor: student.absentSessions == 0
                              ? const Color(0xFF16A34A)
                              : student.neverAttended
                                  ? const Color(0xFFE5484D)
                                  : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Absent dates
                  Row(
                    children: [
                      const Text(
                        'ABSENT DATES',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: Color(0xFF8A8F95),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${student.absentDates.length}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFE5484D),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (!hasAbsences)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 28, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFFEEF0EE), width: 1),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Iconsax.tick_circle,
                            size: 32,
                            color: Color(0xFF16A34A),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'No absences on record',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1B1E22),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFFEEF0EE), width: 1),
                      ),
                      child: Column(
                        children: [
                          for (int i = 0; i < student.absentDates.length; i++)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: i.isOdd
                                    ? const Color(0xFFFAFAFB)
                                    : Colors.white,
                                border: i < student.absentDates.length - 1
                                    ? const Border(
                                        bottom: BorderSide(
                                            color: Color(0xFFEEF0EE),
                                            width: 1),
                                      )
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEE2E2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Iconsax.close_circle,
                                      size: 18,
                                      color: Color(0xFFE5484D),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          formatDate(
                                              student.absentDates[i].date),
                                          style: const TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF1B1E22),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _excuseLabel(student
                                              .absentDates[i].excuse),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF5B6167),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _kv(String k, String v, {Color? valueColor}) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            k,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8A8F95),
            ),
          ),
        ),
        Expanded(
          child: Text(
            v,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: valueColor ?? const Color(0xFF1B1E22),
            ),
          ),
        ),
      ],
    );
  }
}
