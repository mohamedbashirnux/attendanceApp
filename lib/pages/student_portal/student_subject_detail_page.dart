import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'models/student_attendance.dart';
import 'models/student_session.dart';
import 'student_api_service.dart';
import 'student_session_detail_page.dart';

class StudentSubjectDetailPage extends StatefulWidget {
  final int subjectId;
  final String subjectName;
  const StudentSubjectDetailPage({
    super.key,
    required this.subjectId,
    required this.subjectName,
  });

  @override
  State<StudentSubjectDetailPage> createState() =>
      _StudentSubjectDetailPageState();
}

class _StudentSubjectDetailPageState extends State<StudentSubjectDetailPage> {
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
      final r = await _api.fetchAttendance(token);
      if (!mounted) return;
      setState(() {
        _report = r;
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

  Color _rateColor(double pct) {
    if (pct >= 85) return const Color(0xFF16A34A);
    if (pct >= 70) return const Color(0xFF22C55E);
    if (pct >= 50) return const Color(0xFFE89B2A);
    return const Color(0xFFE5484D);
  }

  @override
  Widget build(BuildContext context) {
    final report = _report;
    final subject = report?.subjects.firstWhere(
      (s) => s.subjectId == widget.subjectId,
      orElse: () => SubjectAttendance(
        subjectId: widget.subjectId,
        subjectName: widget.subjectName,
        totalSessions: 0,
        presentSessions: 0,
        absentSessions: 0,
        attendancePct: 0,
      ),
    );
    final absences = (report?.sessions ?? const [])
        .where((s) => s.subjectId == widget.subjectId && s.wasAbsent)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          widget.subjectName,
          style: const TextStyle(
            color: Color(0xFF1B1E22),
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1B1E22)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorBlock(message: _error!, onRetry: _load)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    children: [
                      if (subject != null) _Summary(subject: subject, color: _rateColor(subject.attendancePct)),
                      const SizedBox(height: 20),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          'My absences',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1B1E22),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (absences.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 28, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: const Color(0xFFEEF0EE), width: 1),
                          ),
                          child: const Column(
                            children: [
                              Icon(
                                Iconsax.tick_circle,
                                size: 28,
                                color: Color(0xFF16A34A),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'No absences recorded',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1B1E22),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'You have not missed any class for this subject.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF8A8F95),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ...absences.map(
                          (s) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _AbsenceRow(
                              session: s,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => StudentSessionDetailPage(
                                      session: s,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }
}

class _Summary extends StatelessWidget {
  final SubjectAttendance subject;
  final Color color;
  const _Summary({required this.subject, required this.color});

  @override
  Widget build(BuildContext context) {
    final pctText = subject.attendancePct.toStringAsFixed(1);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEF0EE), width: 1),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: CircularProgressIndicator(
                    value: subject.totalSessions == 0
                        ? 0
                        : subject.presentSessions / subject.totalSessions,
                    strokeWidth: 5,
                    backgroundColor: const Color(0xFFEEF0EE),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$pctText%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: color,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.subjectName,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1B1E22),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${subject.totalSessions} sessions total',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8A8F95),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _Mini(
                      label: 'Present',
                      value: '${subject.presentSessions}',
                      color: const Color(0xFF5F61E6),
                    ),
                    const SizedBox(width: 8),
                    _Mini(
                      label: 'Absent',
                      value: '${subject.absentSessions}',
                      color: const Color(0xFFE5484D),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Mini extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Mini({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _AbsenceRow extends StatelessWidget {
  final StudentAttendanceSession session;
  final VoidCallback onTap;
  const _AbsenceRow({required this.session, required this.onTap});

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    try {
      final d = DateTime.parse(iso);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${d.day} ${months[d.month - 1]} ${d.year}';
    } catch (_) {
      return iso;
    }
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

  @override
  Widget build(BuildContext context) {
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
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Iconsax.close_circle,
                  size: 20,
                  color: Color(0xFFE5484D),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(session.absenceDate),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1B1E22),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Class at ${_formatDateTime(session.sessionDatetime).split(' · ').last}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF8A8F95),
                      ),
                    ),
                    if ((session.excuse ?? '').isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3E0),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          session.excuse!,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF8B5A00),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Iconsax.arrow_right_3,
                size: 16,
                color: Color(0xFF8A8F95),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBlock extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBlock({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 60),
        const Icon(
          Iconsax.warning_2,
          size: 36,
          color: Color(0xFFE5484D),
        ),
        const SizedBox(height: 10),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF5B6167),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: OutlinedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ),
      ],
    );
  }
}
