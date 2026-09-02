import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

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
                          color: Color(0xFF1B1E22),
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
                              color: Color(0xFF8A8F95),
                            ),
                          ),
                          Text(
                            s.studentId,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF5F61E6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Pick the reason for the absence',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF5B6167),
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
                                    ? const Color(0xFFEEEEFB)
                                    : const Color(0xFFFAFAFB),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selected == entry.key
                                      ? const Color(0xFF5F61E6)
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
                                        ? const Color(0xFF5F61E6)
                                        : const Color(0xFF8A8F95),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      entry.value,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: selected == entry.key
                                            ? const Color(0xFF5F61E6)
                                            : const Color(0xFF1B1E22),
                                      ),
                                    ),
                                  ),
                                  if (selected == entry.key)
                                    const Icon(
                                      Iconsax.tick_circle,
                                      size: 18,
                                      color: Color(0xFF5F61E6),
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
                                color: Color(0xFFDFE2DE), width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Color(0xFF5B6167),
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

    // Preview dialog first — let the teacher confirm before sending.
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

    setState(() => _submitting = true);
    try {
      await _api.submitAttendance(
        classId: widget.classId,
        subjectId: widget.subjectId,
        token: widget.session.token,
        absences: absentEntries,
      );
    } on TeacherApiException catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFE5484D),
          content: Text(e.message, style: const TextStyle(color: Colors.white)),
        ),
      );
      return;
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFE5484D),
          content: Text('Network error: $e',
              style: const TextStyle(color: Colors.white)),
        ),
      );
      return;
    }
    if (!mounted) return;
    setState(() => _submitting = false);

    // Success dialog → tap "Done" to go back to classes.
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
        onClose: () => Navigator.of(ctx).pop(),
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pop(); // back to classes list
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
                  child: CircularProgressIndicator(color: Color(0xFF5F61E6)),
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
                      color: Color(0xFF5B6167),
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
                      color: Color(0xFF5B6167),
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
                      color: Color(0xFF8A8F95),
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
                        color: Color(0xFF5F61E6),
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
          bottom: BorderSide(color: Color(0xFFDFE2DE), width: 1),
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
                color: Color(0xFF8A8F95),
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
                color: Color(0xFF8A8F95),
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
                color: Color(0xFF8A8F95),
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
    final accent = const Color(0xFF5F61E6);
    final danger = const Color(0xFFE5484D);
    return InkWell(
      onTap: () => onToggle(!present),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: present
              ? (index.isOdd ? const Color(0xFFFAFAFB) : Colors.white)
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
                  color: Color(0xFF5F61E6),
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
                  color: Color(0xFF5B6167),
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
                      color: const Color(0xFF1B1E22),
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
                          color: Color(0xFFE5484D),
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
                        color: const Color(0xFFE5484D),
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Iconsax.edit,
                          size: 11,
                          color: Color(0xFFE5484D),
                        ),
                        SizedBox(width: 3),
                        Text(
                          'Edit',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFE5484D),
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
                        : const Color(0xFFE5484D),
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
    final accent = const Color(0xFF5F61E6);
    final absent = total - presentCount;
    final rate = total == 0 ? 0 : ((presentCount / total) * 100).round();
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFDFE2DE), width: 1)),
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
                  _StatPill(label: 'Absent', count: absent, color: const Color(0xFFE5484D)),
                  const SizedBox(width: 6),
                  _StatPill(label: 'Rate', count: rate, color: const Color(0xFF1B1E22)),
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
                            : const Color(0xFFEEEEFB),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: allChecked
                              ? const Color(0xFFE5484D)
                              : const Color(0xFF5F61E6),
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
                                ? const Color(0xFFE5484D)
                                : const Color(0xFF5F61E6),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            allChecked ? 'Uncheck all' : 'Check all',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: allChecked
                                  ? const Color(0xFFE5484D)
                                  : const Color(0xFF5F61E6),
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

enum _SummaryMode { confirm, success }

class _AttendanceSummaryDialog extends StatelessWidget {
  final String subjectName;
  final String className;
  final DateTime date;
  final int presentCount;
  final int absentCount;
  final int rate;
  final _SummaryMode mode;
  final VoidCallback? onClose;

  const _AttendanceSummaryDialog({
    required this.subjectName,
    required this.className,
    required this.date,
    required this.presentCount,
    required this.absentCount,
    required this.rate,
    required this.mode,
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
    final accent = const Color(0xFF5F61E6);
    final danger = const Color(0xFFE5484D);
    final isConfirm = mode == _SummaryMode.confirm;
    final rateColor = rate >= 70
        ? const Color(0xFF16A34A)
        : (rate >= 50 ? const Color(0xFFE89B2A) : danger);
    final title = isConfirm ? 'Confirm Attendance' : 'Attendance Submitted';
    final iconBg = isConfirm
        ? accent.withOpacity(0.12)
        : rateColor.withOpacity(0.12);
    final iconColor = isConfirm ? accent : rateColor;
    final icon = isConfirm ? Iconsax.document_text : Iconsax.tick_circle;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconBg,
                border: Border.all(color: iconColor, width: 4),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$rate%',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: iconColor,
                      ),
                    ),
                    const Text(
                      'ATTENDANCE',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: Color(0xFF8A8F95),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1B1E22),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _formatDate(date),
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF8A8F95),
              ),
            ),
            const SizedBox(height: 20),
            _DetailRow(
                icon: Iconsax.book, label: 'Subject', value: subjectName),
            const Divider(height: 24, color: Color(0xFFEEF0EE)),
            _DetailRow(
                icon: Iconsax.people, label: 'Class', value: className),
            const Divider(height: 24, color: Color(0xFFEEF0EE)),
            Row(
              children: [
                Expanded(
                  child: _CountBox(
                    label: 'Present',
                    count: presentCount,
                    color: accent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _CountBox(
                    label: 'Absent',
                    count: absentCount,
                    color: danger,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (isConfirm)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(
                            color: Color(0xFFDFE2DE), width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF5B6167),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(true),
                      icon: Icon(icon, size: 18),
                      label: const Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: onClose,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
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


class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF5F61E6).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF5F61E6)),
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
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                  color: Color(0xFF8A8F95),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B1E22),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CountBox extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _CountBox({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
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
        style: const TextStyle(fontSize: 14, color: Color(0xFF1B1E22)),
        decoration: InputDecoration(
          hintText: hint,
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
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(
                  Iconsax.close_circle,
                  size: 16,
                  color: Color(0xFF8A8F95),
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
              color: Color(0xFF5F61E6),
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
