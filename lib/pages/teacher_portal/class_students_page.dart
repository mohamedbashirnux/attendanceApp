import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../theme/brand_colors.dart';
import 'models/student.dart';
import 'models/teacher_session.dart';
import 'teacher_api_service.dart';

class ClassStudentsPage extends StatefulWidget {
  final TeacherSession session;
  final int classId;
  final int subjectId;
  final String className;
  final String subjectName;

  const ClassStudentsPage({
    super.key,
    required this.session,
    required this.classId,
    required this.subjectId,
    required this.className,
    required this.subjectName,
  });

  @override
  State<ClassStudentsPage> createState() => _ClassStudentsPageState();
}

/// Excuse options we send to the backend. The DB enum `absences_excuse`
/// uses the `map` string ("Family Emergency", "Medical Appointment", …)
/// when written via Prisma, so we send those exact strings.
const Map<String, String> kExcuseLabels = {
  'Family Emergency': 'Family Emergency',
  'Medical Appointment': 'Medical Appointment',
  'Personal Reason': 'Personal Reason',
  'Official Duty': 'Official Duty',
  'Other': 'Other',
  'No Excuse': 'No Excuse',
};

class _ClassStudentsPageState extends State<ClassStudentsPage> {
  final _api = TeacherApiService();
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  late Future<List<Student>> _future;
  String? _className;
  String _query = '';

  /// DB primary keys of students who are PRESENT. All students are
  /// present by default; the teacher unchecks the absent ones.
  final Set<int> _present = <int>{};
  /// Excuse chosen by the teacher for each absent student (DB id).
  final Map<int, String> _excuseByStudent = <int, String>{};
  bool _submitting = false;

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
    _scrollController.dispose();
    super.dispose();
  }

  Future<List<Student>> _load() async {
    final result = await _api.fetchStudents(
      classId: widget.classId,
      token: widget.session.token,
    );
    _className = result.className;
    _present
      ..clear()
      ..addAll(result.students.map((s) => s.id));
    _excuseByStudent.clear();
    return result.students;
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  List<Student> _filter(List<Student> all) {
    if (_query.isEmpty) return all;
    final q = _query.toLowerCase();
    return all.where((s) {
      return s.fullName.toLowerCase().contains(q) ||
          s.studentId.toLowerCase().contains(q);
    }).toList(growable: false);
  }

  Future<void> _toggle(Student s, bool? value) async {
    if (value == true) {
      // Re-checked: present, clear any excuse.
      setState(() {
        _present.add(s.id);
        _excuseByStudent.remove(s.id);
      });
      return;
    }
    // Unchecked → just mark absent with default "No Excuse".
    // The teacher can later tap the edit icon to set a real excuse.
    setState(() {
      _present.remove(s.id);
      _excuseByStudent.putIfAbsent(s.id, () => 'No Excuse');
    });
  }

  Future<void> _editExcuse(Student s) async {
    final picked = await _pickExcuse(s);
    if (!mounted) return;
    if (picked == null) return;
    setState(() {
      _excuseByStudent[s.id] = picked;
    });
  }

  Future<String?> _pickExcuse(Student s) async {
    String selected = _excuseByStudent[s.id] ?? 'No Excuse';
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            return SafeArea(
              top: false,
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      20, 12, 20, 20 + MediaQuery.of(ctx).viewInsets.bottom),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5E7EB),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Text(
                        s.fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: BrandColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Text(
                            'ID: ',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: BrandColors.textMuted,
                            ),
                          ),
                          Text(
                            s.studentId,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: BrandColors.accent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Pick the reason for the absence',
                        style: TextStyle(
                          fontSize: 13,
                          color: BrandColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      for (final entry in kExcuseLabels.entries)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            onTap: () => Navigator.of(ctx).pop(entry.key),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: selected == entry.key
                                    ? BrandColors.accentSoft
                                    : BrandColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selected == entry.key
                                      ? BrandColors.accent
                                      : const Color(0xFFEEF0EE),
                                  width: 1.4,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _excuseIcon(entry.key),
                                    size: 18,
                                    color: selected == entry.key
                                        ? BrandColors.accent
                                        : BrandColors.textMuted,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      entry.value,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: selected == entry.key
                                            ? BrandColors.accent
                                            : BrandColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  if (selected == entry.key)
                                    const Icon(
                                      Iconsax.tick_circle,
                                      size: 18,
                                      color: BrandColors.accent,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          style: OutlinedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(
                                color: BrandColors.borderStrong, width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: BrandColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  IconData _excuseIcon(String excuse) {
    switch (excuse) {
      case 'Family Emergency':
        return Iconsax.people;
      case 'Medical Appointment':
        return Iconsax.health;
      case 'Personal Reason':
        return Iconsax.user;
      case 'Official Duty':
        return Iconsax.briefcase;
      case 'Other':
        return Iconsax.note;
      default:
        return Iconsax.close_circle;
    }
  }

  void _toggleAll(List<Student> visible) {
    final allChecked = visible.every((s) => _present.contains(s.id));
    if (allChecked) {
      // Bulk uncheck → wipe excuses for the visible set.
      setState(() {
        for (final s in visible) {
          _present.remove(s.id);
          _excuseByStudent.remove(s.id);
        }
      });
    } else {
      // Bulk re-check → mark every visible student as present.
      setState(() {
        for (final s in visible) {
          _present.add(s.id);
          _excuseByStudent.remove(s.id);
        }
      });
    }
  }

  Future<void> _submit(List<Student> visible) async {
    if (visible.isEmpty) return;

    // Build absences using the current visible set so a previous search
    // filter does not silently drop unchecked students.
    final absentEntries = <({int studentId, String excuse})>[];
    int presentCount = 0;
    for (final s in visible) {
      if (_present.contains(s.id)) {
        presentCount++;
      } else {
        absentEntries.add((
          studentId: s.id,
          excuse: _excuseByStudent[s.id] ?? 'No Excuse',
        ));
      }
    }
    final absentCount = visible.length - presentCount;
    final rate = visible.isEmpty
        ? 0
        : ((presentCount / visible.length) * 100).round();

    // 1. Preview / confirm dialog — let the teacher review before sending.
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _AttendanceSummaryDialog(
        subjectName: widget.subjectName,
        className: _className ?? widget.className,
        date: DateTime.now(),
        presentCount: presentCount,
        absentCount: absentCount,
        rate: rate,
        mode: _SummaryMode.confirm,
      ),
    );
    if (!mounted) return;
    if (confirmed != true) return; // user cancelled

    // 2. Send to the server.
    setState(() => _submitting = true);
    final result = await _api.submitAttendance(
      classId: widget.classId,
      subjectId: widget.subjectId,
      token: widget.session.token,
      absences: absentEntries,
    );
    if (!mounted) return;
    setState(() => _submitting = false);

    // 3. Show the right dialog for the result.
    if (result.isOk) {
      final serverMessage = result.body?['message'] as String?;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => _AttendanceSummaryDialog(
          subjectName: widget.subjectName,
          className: _className ?? widget.className,
          date: DateTime.now(),
          presentCount: presentCount,
          absentCount: absentCount,
          rate: rate,
          mode: _SummaryMode.success,
          message: serverMessage,
          onClose: () => Navigator.of(ctx).pop(),
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(); // back to classes list
      return;
    }

    if (result.isAlreadySubmitted) {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => _AttendanceSummaryDialog(
          subjectName: widget.subjectName,
          className: _className ?? widget.className,
          date: DateTime.now(),
          presentCount: presentCount,
          absentCount: absentCount,
          rate: rate,
          mode: _SummaryMode.alreadyDone,
          message: result.message,
          onClose: () => Navigator.of(ctx).pop(),
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(); // back to classes list
      return;
    }

    // Network / server error.
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: BrandColors.danger,
        content: Text(result.message ?? 'Unknown error',
            style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _className ?? widget.className,
              style: const TextStyle(fontSize: 17),
            ),
            Text(
              widget.subjectName,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        centerTitle: false,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(46),
          child: _SearchBar(
            controller: _searchController,
            hint: 'Search by name or student ID',
          ),
        ),
      ),
      body: FutureBuilder<List<Student>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView(
              children: const [
                SizedBox(height: 120),
                Center(
                  child: CircularProgressIndicator(color: BrandColors.accent),
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
                    size: 56, color: BrandColors.danger),
                const SizedBox(height: 12),
                Text(
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: BrandColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton.icon(
                    onPressed: _refresh,
                    icon: const Icon(Iconsax.refresh,
                        color: BrandColors.accent),
                    label: const Text(
                      'Try again',
                      style: TextStyle(
                        color: BrandColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          final students = snapshot.data ?? const <Student>[];
          if (students.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: 120),
                Icon(Iconsax.people, size: 56, color: Color(0xFFBFC2C7)),
                SizedBox(height: 12),
                Center(
                  child: Text(
                    'No students enrolled yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: BrandColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            );
          }
          final filtered = _filter(students);
          if (filtered.isEmpty) {
            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 80),
              children: [
                const Icon(
                  Iconsax.search_normal,
                  size: 56,
                  color: Color(0xFFBFC2C7),
                ),
                const SizedBox(height: 14),
                const Center(
                  child: Text(
                    'No matching students',
                    style: TextStyle(
                      fontSize: 16,
                      color: BrandColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    'Nothing for "$_query"',
                    style: const TextStyle(
                      fontSize: 13,
                      color: BrandColors.textMuted,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () => _searchController.clear(),
                    child: const Text(
                      'Clear search',
                      style: TextStyle(
                        color: BrandColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          return Column(
            children: [
              Expanded(
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(bottom: 8),
                    itemCount: filtered.length + 1, // +1 for header row
                    itemBuilder: (context, i) {
                      if (i == 0) return const _StudentsHeader();
                      final s = filtered[i - 1];
                      final present = _present.contains(s.id);
                      return _StudentRow(
                        index: i,
                        student: s,
                        present: present,
                        excuse: present ? null : _excuseByStudent[s.id],
                        onToggle: (v) => _toggle(s, v),
                        onEditExcuse: present ? null : () => _editExcuse(s),
                      );
                    },
                  ),
                ),
              ),
              _SubmitBar(
                presentCount: filtered
                    .where((s) => _present.contains(s.id))
                    .length,
                total: filtered.length,
                submitting: _submitting,
                allChecked: filtered.every((s) => _present.contains(s.id)),
                onToggleAll: () => _toggleAll(filtered),
                onSubmit: () => _submit(filtered),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StudentsHeader extends StatelessWidget {
  const _StudentsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: BrandColors.borderStrong, width: 1),
        ),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              'NO.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: BrandColors.textMuted,
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              'S.ID',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: BrandColors.textMuted,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              'S.NAME',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: BrandColors.textMuted,
              ),
            ),
          ),
          SizedBox(
            width: 44,
            child: Text(
              '',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentRow extends StatelessWidget {
  final int index;
  final Student student;
  final bool present;
  final String? excuse;
  final ValueChanged<bool?> onToggle;
  final VoidCallback? onEditExcuse;

  const _StudentRow({
    required this.index,
    required this.student,
    required this.present,
    required this.excuse,
    required this.onToggle,
    this.onEditExcuse,
  });

  @override
  Widget build(BuildContext context) {
    final accent = BrandColors.accent;
    final danger = BrandColors.danger;
    return InkWell(
      onTap: () => onToggle(!present),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: present
              ? (index.isOdd ? BrandColors.surface : Colors.white)
              : const Color(0xFFFFF5F5),
          border: const Border(
            bottom: BorderSide(color: Color(0xFFEEF0EE), width: 1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // NO. plain text
            SizedBox(
              width: 32,
              child: Text(
                '$index',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: BrandColors.accent,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // S.ID
            Expanded(
              flex: 2,
              child: Text(
                student.studentId,
                style: const TextStyle(
                  fontSize: 14,
                  color: BrandColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 6),
            // S.NAME + excuse text below
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.fullName,
                    style: TextStyle(
                      fontSize: 14.5,
                      color: BrandColors.textPrimary,
                      fontWeight:
                          present ? FontWeight.w500 : FontWeight.w700,
                      height: 1.15,
                    ),
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (!present && excuse != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        excuse!,
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: BrandColors.danger,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            // Edit chip + Checkbox (aligned on the same row, right side)
            if (!present && onEditExcuse != null)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: InkWell(
                  onTap: onEditExcuse,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: BrandColors.danger,
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Iconsax.edit,
                          size: 11,
                          color: BrandColors.danger,
                        ),
                        SizedBox(width: 3),
                        Text(
                          'Edit',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: BrandColors.danger,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            // Checkbox
            SizedBox(
              width: 44,
              child: Transform.scale(
                scale: 1.15,
                child: Checkbox(
                  value: present,
                  onChanged: onToggle,
                  activeColor: present ? accent : danger,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  side: BorderSide(
                    color: present
                        ? const Color(0xFFBFC2C7)
                        : BrandColors.danger,
                    width: 1.4,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatPill({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmitBar extends StatelessWidget {
  final int presentCount;
  final int total;
  final bool submitting;
  final bool allChecked;
  final VoidCallback onToggleAll;
  final VoidCallback onSubmit;

  const _SubmitBar({
    required this.presentCount,
    required this.total,
    required this.submitting,
    required this.allChecked,
    required this.onToggleAll,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final accent = BrandColors.accent;
    final absent = total - presentCount;
    final rate = total == 0 ? 0 : ((presentCount / total) * 100).round();
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: BrandColors.borderStrong, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 16,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _StatPill(label: 'Present', count: presentCount, color: accent),
                  const SizedBox(width: 6),
                  _StatPill(label: 'Absent', count: absent, color: BrandColors.danger),
                  const SizedBox(width: 6),
                  _StatPill(label: 'Rate', count: rate, color: BrandColors.textPrimary),
                  const Spacer(),
                  // Styled "Check all / Uncheck all" button with border
                  InkWell(
                    onTap: onToggleAll,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: allChecked
                            ? const Color(0xFFFEE2E2)
                            : BrandColors.accentSoft,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: allChecked
                              ? BrandColors.danger
                              : BrandColors.accent,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            allChecked
                                ? Iconsax.close_circle
                                : Iconsax.tick_circle,
                            size: 14,
                            color: allChecked
                                ? BrandColors.danger
                                : BrandColors.accent,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            allChecked ? 'Uncheck all' : 'Check all',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: allChecked
                                  ? BrandColors.danger
                                  : BrandColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: submitting ? null : onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: accent.withOpacity(0.6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (absent > 0) ...[
                              const Icon(Iconsax.tick_circle, size: 18),
                              const SizedBox(width: 8),
                            ],
                            const Text(
                              'Submit Attendance',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                            if (absent > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.22),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$absent absent',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _SummaryMode { confirm, success, alreadyDone }

class _AttendanceSummaryDialog extends StatelessWidget {
  final String subjectName;
  final String className;
  final DateTime date;
  final int presentCount;
  final int absentCount;
  final int rate;
  final _SummaryMode mode;
  final String? message;
  final VoidCallback? onClose;

  const _AttendanceSummaryDialog({
    required this.subjectName,
    required this.className,
    required this.date,
    required this.presentCount,
    required this.absentCount,
    required this.rate,
    required this.mode,
    this.message,
    this.onClose,
  });

  String _formatDate(DateTime d) {
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
    final accent = BrandColors.accent;
    final danger = BrandColors.danger;
    final isConfirm = mode == _SummaryMode.confirm;
    final isAlreadyDone = mode == _SummaryMode.alreadyDone;
    final isSuccess = mode == _SummaryMode.success;
    final rateColor = rate >= 70
        ? const Color(0xFF16A34A)
        : (rate >= 50 ? const Color(0xFFE89B2A) : danger);

    if (isSuccess) {
      return _SuccessDialog(
        subjectName: subjectName,
        className: className,
        date: date,
        presentCount: presentCount,
        absentCount: absentCount,
        rate: rate,
        rateColor: rateColor,
        message: message,
        onClose: onClose,
      );
    }
    if (isAlreadyDone) {
      return _AlreadyDoneDialog(
        subjectName: subjectName,
        className: className,
        presentCount: presentCount,
        absentCount: absentCount,
        rate: rate,
        message: message ?? 'This class is locked for today',
        onClose: onClose,
      );
    }
    return _ConfirmDialog(
      subjectName: subjectName,
      className: className,
      date: date,
      presentCount: presentCount,
      absentCount: absentCount,
      rate: rate,
      rateColor: rateColor,
    );
  }
}

/// Confirm dialog — horizontal layout: big rate ring on the left, info on the right.
class _ConfirmDialog extends StatelessWidget {
  final String subjectName;
  final String className;
  final DateTime date;
  final int presentCount;
  final int absentCount;
  final int rate;
  final Color rateColor;

  const _ConfirmDialog({
    required this.subjectName,
    required this.className,
    required this.date,
    required this.presentCount,
    required this.absentCount,
    required this.rate,
    required this.rateColor,
  });

  String _formatDate(DateTime d) {
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
    final accent = BrandColors.accent;
    final danger = BrandColors.danger;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top row: rate ring (left) + subject/class/date (right)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Big rate ring
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: rateColor.withOpacity(0.10),
                      border: Border.all(color: rateColor, width: 4),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$rate%',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: rateColor,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 1),
                        const Text(
                          'RATE',
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: BrandColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Review Attendance',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: BrandColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Please confirm before saving',
                          style: const TextStyle(
                            fontSize: 12,
                            color: BrandColors.textMuted,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Iconsax.book,
                                size: 12, color: accent),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                subjectName,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: BrandColors.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(Iconsax.people,
                                size: 12, color: BrandColors.textMuted),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                className,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: BrandColors.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '· ${_formatDate(date)}',
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: BrandColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Present/Absent as compact pill row
              Row(
                children: [
                  Expanded(
                    child: _PillStat(
                      icon: Iconsax.tick_circle,
                      count: presentCount,
                      label: 'Present',
                      color: accent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _PillStat(
                      icon: Iconsax.close_circle,
                      count: absentCount,
                      label: 'Absent',
                      color: danger,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        side: const BorderSide(
                            color: BrandColors.borderStrong, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: BrandColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(true),
                      icon: const Icon(Iconsax.tick_circle, size: 16),
                      label: const Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
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

/// Success dialog — celebratory check icon with rate-coloured gradient header.
class _SuccessDialog extends StatelessWidget {
  final String subjectName;
  final String className;
  final DateTime date;
  final int presentCount;
  final int absentCount;
  final int rate;
  final Color rateColor;
  final String? message;
  final VoidCallback? onClose;

  const _SuccessDialog({
    required this.subjectName,
    required this.className,
    required this.date,
    required this.presentCount,
    required this.absentCount,
    required this.rate,
    required this.rateColor,
    required this.message,
    required this.onClose,
  });

  String _formatDate(DateTime d) {
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
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Gradient header with big check
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    rateColor.withOpacity(0.95),
                    rateColor.withOpacity(0.7),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Icon(
                      Iconsax.tick_circle,
                      size: 38,
                      color: rateColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Attendance Saved',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    message ?? 'Saved successfully',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.white.withOpacity(0.92),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            // Body
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Subject + class + date row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subjectName,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: BrandColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              className,
                              style: const TextStyle(
                                fontSize: 12,
                                color: BrandColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: rateColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$rate%',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: rateColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _formatDate(date),
                      style: const TextStyle(
                        fontSize: 11,
                        color: BrandColors.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Stat row
                  Row(
                    children: [
                      Expanded(
                        child: _PillStat(
                          icon: Iconsax.people,
                          count: presentCount + absentCount,
                          label: 'Total',
                          color: BrandColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _PillStat(
                          icon: Iconsax.tick_circle,
                          count: presentCount,
                          label: 'Present',
                          color: BrandColors.accent,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _PillStat(
                          icon: Iconsax.close_circle,
                          count: absentCount,
                          label: 'Absent',
                          color: BrandColors.danger,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Footer
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: onClose,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: rateColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Already-submitted dialog — amber warning header with the full server message.
class _AlreadyDoneDialog extends StatelessWidget {
  final String subjectName;
  final String className;
  final int presentCount;
  final int absentCount;
  final int rate;
  final String message;
  final VoidCallback? onClose;

  const _AlreadyDoneDialog({
    required this.subjectName,
    required this.className,
    required this.presentCount,
    required this.absentCount,
    required this.rate,
    required this.message,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final amber = const Color(0xFFE89B2A);
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Amber header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE89B2A), Color(0xFFD17F1A)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: const Icon(
                      Iconsax.shield_tick,
                      size: 32,
                      color: Color(0xFFE89B2A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Already Submitted',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'This class is locked for today',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.white.withOpacity(0.92),
                    ),
                  ),
                ],
              ),
            ),
            // Body
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subjectName,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: BrandColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    className,
                    style: const TextStyle(
                      fontSize: 12,
                      color: BrandColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7EB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: amber.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Iconsax.info_circle,
                          size: 16,
                          color: Color(0xFFB57100),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            message,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8B5A00),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Footer
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: onClose,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: amber,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Got it',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact pill stat: icon + count + label, all in one horizontal row.
class _PillStat extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;
  final Color color;

  const _PillStat({
    required this.icon,
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.18), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1.0,
            ),
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 0.2,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}


class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const _SearchBar({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 14, color: BrandColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 13,
            color: BrandColors.textMuted,
          ),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 10, right: 6),
            child: Icon(
              Iconsax.search_normal,
              size: 16,
              color: BrandColors.textMuted,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(
                  Iconsax.close_circle,
                  size: 16,
                  color: BrandColors.textMuted,
                ),
                onPressed: () => controller.clear(),
              );
            },
          ),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 10,
          ),
          filled: true,
          fillColor: Colors.white,
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
              color: BrandColors.accent,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
