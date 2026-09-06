import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../theme/brand_colors.dart';
import 'class_students_page.dart';
import 'models/teacher_class.dart';
import 'models/teacher_session.dart';
import 'teacher_api_service.dart';

class ClassesPage extends StatefulWidget {
  final TeacherSession session;

  const ClassesPage({super.key, required this.session});

  @override
  State<ClassesPage> createState() => _ClassesPageState();
}

class _ClassesPageState extends State<ClassesPage> {
  final _api = TeacherApiService();
  late Future<List<TeacherClass>> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchClasses(widget.session.token);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _api.fetchClasses(widget.session.token);
    });
    await _future;
  }

  void _openClass(TeacherClass cls) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ClassStudentsPage(
          session: widget.session,
          classId: cls.classId,
          subjectId: cls.subjectId,
          className: cls.className,
          subjectName: cls.subjectName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: BrandColors.accent,
      onRefresh: _refresh,
      child: FutureBuilder<List<TeacherClass>>(
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
          final classes = snapshot.data ?? const <TeacherClass>[];
          if (classes.isEmpty) {
            return _EmptyView(onRefresh: _refresh);
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: classes.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: BrandColors.borderStrong),
            itemBuilder: (context, i) {
              final c = classes[i];
              return _ClassRow(cls: c, onTap: () => _openClass(c));
            },
          );
        },
      ),
    );
  }
}

class _ClassRow extends StatelessWidget {
  final TeacherClass cls;
  final VoidCallback onTap;

  const _ClassRow({required this.cls, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: BrandColors.accent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Iconsax.book, color: BrandColors.accent),
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              cls.subjectName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: BrandColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (cls.studyMode.isNotEmpty) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: BrandColors.accentSoft,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                cls.studyMode,
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
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${cls.className} · ${cls.departmentName}',
              style: const TextStyle(fontSize: 13, color: BrandColors.textSecondary),
            ),
            const SizedBox(height: 2),
            Text(
              '${cls.startTime} – ${cls.endTime}  ·  ${cls.semester} ${cls.academicYear}',
              style: const TextStyle(fontSize: 12, color: BrandColors.textMuted),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      trailing:
          const Icon(Iconsax.arrow_right_3, color: BrandColors.textMuted, size: 18),
    );
  }
}

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
