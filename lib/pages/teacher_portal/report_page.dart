import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'class_report_page.dart';
import 'models/teacher_class.dart';
import 'models/teacher_session.dart';
import 'teacher_api_service.dart';

class ReportPage extends StatefulWidget {
  final TeacherSession session;

  const ReportPage({super.key, required this.session});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
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

  void _open(TeacherClass cls) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ClassReportPage(
          session: widget.session,
          classId: cls.classId,
          className: cls.className,
          subjectId: cls.subjectId,
          subjectName: cls.subjectName,
          departmentName: cls.departmentName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: const Color(0xFF5F61E6),
      onRefresh: _refresh,
      child: FutureBuilder<List<TeacherClass>>(
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
          final classes = snapshot.data ?? const <TeacherClass>[];
          if (classes.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: 120),
                Icon(Iconsax.box, size: 56, color: Color(0xFFBFC2C7)),
                SizedBox(height: 12),
                Center(
                  child: Text(
                    'No classes to report on yet',
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
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: classes.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: Color(0xFFDFE2DE)),
            itemBuilder: (context, i) {
              final c = classes[i];
              return _ReportClassRow(cls: c, onTap: () => _open(c));
            },
          );
        },
      ),
    );
  }
}

class _ReportClassRow extends StatelessWidget {
  final TeacherClass cls;
  final VoidCallback onTap;

  const _ReportClassRow({required this.cls, required this.onTap});

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
          color: const Color(0xFF5F61E6).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Iconsax.document_text,
            color: Color(0xFF5F61E6)),
      ),
      title: Text(
        cls.subjectName,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1B1E22),
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          '${cls.className} · ${cls.departmentName}',
          style: const TextStyle(fontSize: 13, color: Color(0xFF5B6167)),
        ),
      ),
      trailing: const Icon(Iconsax.arrow_right_3,
          color: Color(0xFF8A8F95), size: 18),
    );
  }
}
