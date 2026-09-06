import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../theme/brand_colors.dart';
import '../../widgets/logout_button.dart';
import 'models/student_attendance.dart';
import 'models/student_session.dart';
import 'student_api_service.dart';

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
    return BrandColors.danger;
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
      backgroundColor: BrandColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          widget.subjectName,
          style: const TextStyle(
            color: BrandColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(
          color: BrandColors.accent,
          size: 24,
        ),
        actions: const [
          LogoutButton(),
          SizedBox(width: 4),
        ],
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
                            color: BrandColors.textPrimary,
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
                                  color: BrandColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'You have not missed any class for this subject.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: BrandColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ...absences.map(
                          (s) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _AbsenceRow(session: s),
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
                    color: BrandColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${subject.totalSessions} sessions total',
                  style: const TextStyle(
                    fontSize: 12,
                    color: BrandColors.textMuted,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _Mini(
                      label: 'Present',
                      value: '${subject.presentSessions}',
                      color: BrandColors.accent,
                    ),
                    const SizedBox(width: 8),
                    _Mini(
                      label: 'Absent',
                      value: '${subject.absentSessions}',
                      color: BrandColors.danger,
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

class _AbsenceRow extends StatefulWidget {
  final StudentAttendanceSession session;
  const _AbsenceRow({required this.session});

  @override
  State<_AbsenceRow> createState() => _AbsenceRowState();
}

class _AbsenceRowState extends State<_AbsenceRow> {
  bool _expanded = false;

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

  String _formatDateLong(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  /// 12-hour time with AM/PM, e.g. "10:23 AM" / "9:05 PM".
  static String formatTime12(DateTime d) {
    final hour24 = d.hour;
    final mm = d.minute < 10 ? '0${d.minute}' : '${d.minute}';
    final ampm = hour24 < 12 ? 'AM' : 'PM';
    var hour12 = hour24 % 12;
    if (hour12 == 0) hour12 = 12;
    return '$hour12:$mm $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.session;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEF0EE), width: 1),
      ),
      child: Column(
        children: [
          // Header row — always visible
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
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
                      color: BrandColors.danger,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDate(s.absenceDate),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: BrandColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tap to see details',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: BrandColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Iconsax.arrow_up_1
                        : Iconsax.arrow_down_1,
                    size: 16,
                    color: BrandColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
          // Expanded details
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 180),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: _ExpandedBody(
              session: s,
              formatDateLong: _formatDateLong,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandedBody extends StatelessWidget {
  final StudentAttendanceSession session;
  final String Function(DateTime) formatDateLong;
  const _ExpandedBody({
    required this.session,
    required this.formatDateLong,
  });

  @override
  Widget build(BuildContext context) {
    final s = session;
    final markedAt = s.absenceCreatedAt;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Divider(height: 1, color: Color(0xFFEEF0EE)),
          const SizedBox(height: 12),
          // When the teacher actually marked this absence — date + time
          // the row was created on the server, not the class start time.
          _DetailRow(
            icon: Iconsax.timer,
            label: 'Marked at',
            value: markedAt == null
                ? '—'
                : '${formatDateLong(markedAt)} · ${_AbsenceRowState.formatTime12(markedAt)}',
            color: BrandColors.accent,
          ),
          const SizedBox(height: 10),
          // Excuse — read-only, shown with a blue pencil so the user
          // knows the field is editable from the admin side (their
          // own portal cannot change it).
          _DetailRow(
            icon: Iconsax.edit,
            label: 'Excuse',
            value: (s.excuse ?? '').isEmpty ? 'No excuse' : s.excuse!,
            color: BrandColors.accent,
          ),
          if ((s.notes ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            _DetailRow(
              icon: Iconsax.document_text,
              label: 'Notes',
              value: s.notes!,
              color: BrandColors.textSecondary,
            ),
          ],
          const SizedBox(height: 10),
          // Marked by
          _DetailRow(
            icon: Iconsax.teacher,
            label: 'Marked by',
            value: (s.teacherName ?? '').isEmpty
                ? 'Unknown teacher'
                : '${s.teacherName}${(s.teacherCode ?? '').isNotEmpty ? "  ·  ${s.teacherCode}" : ""}',
            color: BrandColors.accent,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: BrandColors.textMuted,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  color: BrandColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
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
          color: BrandColors.danger,
        ),
        const SizedBox(height: 10),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            color: BrandColors.textSecondary,
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
