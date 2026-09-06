import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../theme/brand_colors.dart';
import '../../widgets/logout_button.dart';
import 'models/student_attendance.dart';
import 'models/student_session.dart';
import 'student_api_service.dart';
import 'student_subject_detail_page.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  final _api = StudentApiService();
  StudentAttendanceReport? _report;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final token = StudentSession.token;
      if (token == null) {
        throw const StudentApiException('Not signed in');
      }
      final report = await _api.fetchAttendance(token);
      if (!mounted) return;
      setState(() {
        _report = report;
        _loading = false;
      });
    } on StudentApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not reach the server.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final student = StudentSession.student;
    return Scaffold(
      backgroundColor: BrandColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'My Attendance',
          style: TextStyle(
            color: BrandColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(color: BrandColors.textPrimary),
        actions: [
          IconButton(
            onPressed: _loading ? null : _load,
            icon: const Icon(Iconsax.refresh, size: 20),
          ),
          const LogoutButton(),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _ErrorState(message: _error!, onRetry: _load)
                : _Body(student: student, report: _report!, onChanged: _load),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final dynamic student;
  final StudentAttendanceReport report;
  final VoidCallback onChanged;
  const _Body({
    required this.student,
    required this.report,
    required this.onChanged,
  });

  Color _rateColor(double pct) {
    if (pct >= 85) return const Color(0xFF16A34A);
    if (pct >= 70) return const Color(0xFF22C55E);
    if (pct >= 50) return const Color(0xFFE89B2A);
    return BrandColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    final report = this.report;
    final overallPct = report.attendancePct;
    final overallColor = _rateColor(overallPct);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        // Student card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: BrandColors.accentGradient,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: BrandColors.accent.withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _initials(student?.fullName as String? ?? '?'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student?.fullName as String? ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${student?.studentId ?? ''} · ${student?.className ?? ''}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if ((student?.facultyName as String?)?.isNotEmpty == true ||
                  (student?.departmentName as String?)?.isNotEmpty == true)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    children: [
                      const Icon(
                        Iconsax.buildings,
                        size: 13,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          [
                            student?.facultyName as String?,
                            student?.departmentName as String?,
                          ].whereType<String>().join(' · '),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // Overall rate row
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Overall',
                value: '${overallPct.toStringAsFixed(1)}%',
                color: overallColor,
                icon: Iconsax.chart,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: 'Present',
                value: '${report.totalPresent}',
                color: BrandColors.accent,
                icon: Iconsax.tick_circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: 'Absent',
                value: '${report.totalAbsent}',
                color: BrandColors.danger,
                icon: Iconsax.close_circle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Subjects',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: BrandColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (report.subjects.isEmpty)
          _EmptyState(
            icon: Iconsax.book,
            title: 'No subjects yet',
            message:
                'Once your teachers take attendance, your subjects will appear here.',
          )
        else
          ...report.subjects.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SubjectRow(
                subject: s,
                color: _rateColor(s.attendancePct),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StudentSubjectDetailPage(
                        subjectId: s.subjectId,
                        subjectName: s.subjectName,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEF0EE), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: BrandColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectRow extends StatelessWidget {
  final SubjectAttendance subject;
  final Color color;
  final VoidCallback onTap;
  const _SubjectRow({
    required this.subject,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // The bar fills as the student misses sessions — empty = no
    // absences yet, full = missed every session. This matches the
    // intuition that a "growing" red bar = trouble.
    final total = subject.totalSessions;
    final missed = subject.absentSessions;
    final missedPct =
        total == 0 ? 0.0 : (missed / total).clamp(0.0, 1.0);
    final missedPctText = (missedPct * 100).toStringAsFixed(1);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEEF0EE), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Iconsax.book, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.subjectName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: BrandColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$total sessions · $missed absent',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: BrandColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Bar grows as absences accumulate. 0 missed = empty
                    // bar (good); 1 of 1 missed = full red bar.
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: missedPct,
                        minHeight: 6,
                        backgroundColor: const Color(0xFFEEF0EE),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$missedPctText%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(
                    Iconsax.arrow_right_3,
                    size: 16,
                    color: BrandColors.textMuted,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEF0EE), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: const Color(0xFFB5B9BE)),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: BrandColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: BrandColors.textMuted,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 60),
        const Icon(
          Iconsax.warning_2,
          size: 36,
          color: BrandColors.danger,
        ),
        const SizedBox(height: 10),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            color: BrandColors.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: OutlinedButton(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: BrandColors.accent),
              foregroundColor: BrandColors.accent,
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Retry'),
          ),
        ),
      ],
    );
  }
}
