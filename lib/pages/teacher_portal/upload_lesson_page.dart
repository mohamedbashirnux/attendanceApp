import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../theme/brand_colors.dart';
import 'class_lesson_materials_page.dart';
import 'models/teacher_class.dart';
import 'models/teacher_session.dart';
import 'teacher_api_service.dart';

class UploadLessonPage extends StatefulWidget {
  final TeacherSession session;

  const UploadLessonPage({super.key, required this.session});

  @override
  State<UploadLessonPage> createState() => _UploadLessonPageState();
}

class _UploadLessonPageState extends State<UploadLessonPage> {
  final _api = TeacherApiService();
  final _searchCtrl = TextEditingController();

  late Future<List<TeacherClassGroup>> _future;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _future = _loadClasses();
    _searchCtrl.addListener(() {
      final text = _searchCtrl.text.trim();
      if (text != _searchQuery) {
        setState(() => _searchQuery = text);
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<List<TeacherClassGroup>> _loadClasses() async {
    final allocations = await _api.fetchClasses(widget.session.token);
    return TeacherClassGroup.fromAllocations(allocations);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _loadClasses();
    });
    await _future;
  }

  void _openClass(TeacherClassGroup classGroup) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ClassLessonMaterialsPage(
          session: widget.session,
          classGroup: classGroup,
        ),
      ),
    );
  }

  List<TeacherClassGroup> _filter(List<TeacherClassGroup> all) {
    if (_searchQuery.isEmpty) return all;
    final q = _searchQuery.toLowerCase();
    return all.where((c) {
      return c.className.toLowerCase().contains(q) ||
          c.departmentName.toLowerCase().contains(q) ||
          c.facultyName.toLowerCase().contains(q) ||
          c.semester.toLowerCase().contains(q);
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: BrandColors.accent,
      onRefresh: _refresh,
      child: FutureBuilder<List<TeacherClassGroup>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _LoadingView();
          }

          if (snapshot.hasError) {
            return _ErrorView(
              message: snapshot.error.toString(),
              onRetry: _refresh,
            );
          }

          final allClasses = snapshot.data ?? const <TeacherClassGroup>[];
          if (allClasses.isEmpty) {
            return _EmptyView(onRefresh: _refresh);
          }

          final classes = _filter(allClasses);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search & Filter header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: BrandColors.inputFill,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: BrandColors.borderStrong),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search classes or department...',
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        color: BrandColors.textMuted,
                      ),
                      prefixIcon: const Icon(
                        Iconsax.search_normal,
                        color: BrandColors.textMuted,
                        size: 20,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Iconsax.close_circle,
                                  size: 18, color: BrandColors.textMuted),
                              onPressed: () => _searchCtrl.clear(),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Text(
                  'Select a class to manage and upload lesson materials',
                  style: const TextStyle(
                    fontSize: 13,
                    color: BrandColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // Class Cards List
              Expanded(
                child: classes.isEmpty
                    ? ListView(
                        padding: const EdgeInsets.symmetric(vertical: 60),
                        children: [
                          const Icon(Iconsax.search_status,
                              size: 50, color: Color(0xFFBFC2C7)),
                          const SizedBox(height: 12),
                          Center(
                            child: Text(
                              'No classes match "$_searchQuery"',
                              style: const TextStyle(
                                fontSize: 15,
                                color: BrandColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: TextButton(
                              onPressed: () => _searchCtrl.clear(),
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
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        itemCount: classes.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final c = classes[i];
                          return _ClassCard(
                            classGroup: c,
                            onTap: () => _openClass(c),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Class Card (Displays full class info, strictly NO subjects)
// ---------------------------------------------------------------------------
class _ClassCard extends StatelessWidget {
  final TeacherClassGroup classGroup;
  final VoidCallback onTap;

  const _ClassCard({required this.classGroup, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: BrandColors.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: BrandColors.borderStrong),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Class icon badge
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: BrandColors.accentSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Iconsax.teacher,
                    color: BrandColors.accent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              classGroup.className,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: BrandColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (classGroup.studyMode.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: BrandColors.accentSoft,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                classGroup.studyMode,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: BrandColors.accent,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${classGroup.facultyName} · ${classGroup.departmentName}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: BrandColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Iconsax.arrow_right_3,
                  color: BrandColors.textMuted,
                  size: 18,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: BrandColors.border),
            const SizedBox(height: 10),
            Row(
              children: [
                if (classGroup.semester.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Iconsax.calendar_1,
                          size: 13, color: BrandColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        classGroup.semester,
                        style: const TextStyle(
                          fontSize: 12,
                          color: BrandColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                ],
                if (classGroup.academicYear.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Iconsax.clock,
                          size: 13, color: BrandColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        classGroup.academicYear,
                        style: const TextStyle(
                          fontSize: 12,
                          color: BrandColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Loading & Error & Empty States
// ---------------------------------------------------------------------------
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        SizedBox(height: 120),
        Center(
          child: CircularProgressIndicator(color: BrandColors.accent),
        ),
      ],
    );
  }
}

class _EmptyView extends StatelessWidget {
  final Future<void> Function() onRefresh;
  const _EmptyView({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 120),
        const Icon(Iconsax.box, size: 56, color: Color(0xFFBFC2C7)),
        const SizedBox(height: 12),
        const Center(
          child: Text(
            'No classes assigned yet',
            style: TextStyle(
              fontSize: 16,
              color: BrandColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 80),
        const Icon(Iconsax.warning_2, size: 56, color: BrandColors.danger),
        const SizedBox(height: 12),
        Text(
          message,
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
            onPressed: onRetry,
            icon: const Icon(Iconsax.refresh, color: BrandColors.accent),
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
}
