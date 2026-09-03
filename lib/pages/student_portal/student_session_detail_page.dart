import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'models/student_attendance.dart';

class StudentSessionDetailPage extends StatelessWidget {
  final StudentAttendanceSession session;
  const StudentSessionDetailPage({super.key, required this.session});

  String _formatDateLong(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  String _formatTime(DateTime d) {
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    try {
      final d = DateTime.parse(iso);
      return _formatDateLong(d);
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF5F61E6);
    const danger = Color(0xFFE5484D);
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Absence Details',
          style: TextStyle(
            color: Color(0xFF1B1E22),
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1B1E22)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          // Red header card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE5484D), Color(0xFFD13136)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: danger.withOpacity(0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Iconsax.close_circle,
                    size: 26,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'You were absent',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        session.subjectName ?? 'Subject',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.92),
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Detail rows
          _Card(
            children: [
              _Row(
                icon: Iconsax.calendar,
                label: 'Absence date',
                value: _formatDate(session.absenceDate),
                color: accent,
              ),
              const _Divider(),
              _Row(
                icon: Iconsax.clock,
                label: 'Class time',
                value:
                    '${_formatDateLong(session.sessionDatetime)} · ${_formatTime(session.sessionDatetime)}',
                color: accent,
              ),
              const _Divider(),
              _Row(
                icon: Iconsax.tag,
                label: 'Excuse',
                value: (session.excuse ?? '').isEmpty
                    ? 'No Excuse'
                    : session.excuse!,
                color: const Color(0xFFE89B2A),
              ),
              if ((session.notes ?? '').isNotEmpty) ...[
                const _Divider(),
                _Row(
                  icon: Iconsax.document_text,
                  label: 'Notes',
                  value: session.notes!,
                  color: const Color(0xFF5B6167),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          // Teacher card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFEEF0EE), width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Iconsax.teacher,
                    size: 20,
                    color: accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Marked by',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF8A8F95),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        (session.teacherName ?? '').isEmpty
                            ? 'Unknown teacher'
                            : session.teacherName!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1B1E22),
                        ),
                      ),
                      if ((session.teacherCode ?? '').isNotEmpty) ...[
                        const SizedBox(height: 1),
                        Text(
                          'Teacher ID: ${session.teacherCode!}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF8A8F95),
                          ),
                        ),
                      ],
                    ],
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

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEF0EE), width: 1),
      ),
      child: Column(children: children),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _Row({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF8A8F95),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF1B1E22),
                    fontWeight: FontWeight.w600,
                    height: 1.35,
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

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Divider(height: 1, color: Color(0xFFEEF0EE)),
    );
  }
}
