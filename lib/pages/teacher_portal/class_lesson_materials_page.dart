import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:path/path.dart' as p;

import '../../theme/brand_colors.dart';
import 'models/lesson_material.dart';
import 'models/teacher_class.dart';
import 'models/teacher_session.dart';
import 'teacher_api_service.dart';

class ClassLessonMaterialsPage extends StatefulWidget {
  final TeacherSession session;
  final TeacherClassGroup classGroup;

  const ClassLessonMaterialsPage({
    super.key,
    required this.session,
    required this.classGroup,
  });

  @override
  State<ClassLessonMaterialsPage> createState() =>
      _ClassLessonMaterialsPageState();
}

class _ClassLessonMaterialsPageState extends State<ClassLessonMaterialsPage> {
  final _api = TeacherApiService();
  late Future<List<LessonMaterial>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadMaterials();
  }

  Future<List<LessonMaterial>> _loadMaterials() async {
    final allMaterials = await _api.fetchLessonMaterials(
      token: widget.session.token,
    );

    final subjectClassIds = widget.classGroup.allocations
        .map((a) => a.subjectClassId)
        .toSet();

    // Filter materials belonging to this class
    return allMaterials.where((m) {
      if (subjectClassIds.contains(m.subjectClassId)) return true;
      if (m.className != null &&
          m.className!.trim().toLowerCase() ==
              widget.classGroup.className.trim().toLowerCase()) {
        return true;
      }
      return false;
    }).toList(growable: false);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _loadMaterials();
    });
    await _future;
  }

  void _openUploadBottomSheet() async {
    final uploaded = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _UploadLessonBottomSheet(
        session: widget.session,
        classGroup: widget.classGroup,
        api: _api,
      ),
    );

    if (uploaded == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lesson material uploaded successfully'),
          backgroundColor: BrandColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cls = widget.classGroup;

    return Scaffold(
      appBar: AppBar(
        title: Text(cls.className),
        centerTitle: true,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openUploadBottomSheet,
        backgroundColor: BrandColors.accent,
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(Iconsax.document_upload, size: 20),
        label: const Text(
          'Upload Lesson',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
      body: RefreshIndicator(
        color: BrandColors.accent,
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            // Full Class Info Header Card (No subjects displayed)
            _ClassInfoCard(classGroup: cls),
            const SizedBox(height: 24),

            // Section Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Uploaded Materials',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: BrandColors.textPrimary,
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh',
                  icon: const Icon(Iconsax.refresh,
                      size: 20, color: BrandColors.accent),
                  onPressed: _refresh,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Materials Future Builder
            FutureBuilder<List<LessonMaterial>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(48),
                    child: Center(
                      child:
                          CircularProgressIndicator(color: BrandColors.accent),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return _ErrorState(
                    message: snapshot.error.toString(),
                    onRetry: _refresh,
                  );
                }

                final materials = snapshot.data ?? const <LessonMaterial>[];

                if (materials.isEmpty) {
                  return _EmptyMaterialsState(
                    onUploadPressed: _openUploadBottomSheet,
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: materials.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final material = materials[i];
                    return _MaterialItemCard(material: material);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Class Information Card (Displays full class info, strictly NO subjects)
// ---------------------------------------------------------------------------
class _ClassInfoCard extends StatelessWidget {
  final TeacherClassGroup classGroup;

  const _ClassInfoCard({required this.classGroup});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: BrandColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BrandColors.borderStrong),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: BrandColors.accentGradient,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Iconsax.teacher, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      classGroup.className,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: BrandColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${classGroup.facultyName} · ${classGroup.departmentName}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: BrandColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (classGroup.studyMode.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: BrandColors.accentSoft,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: BrandColors.accent.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    classGroup.studyMode,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: BrandColors.accent,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: BrandColors.border),
          const SizedBox(height: 12),
          Row(
            children: [
              _InfoBadge(
                icon: Iconsax.calendar_1,
                label: classGroup.semester.isNotEmpty
                    ? classGroup.semester
                    : 'Semester N/A',
              ),
              const SizedBox(width: 12),
              _InfoBadge(
                icon: Iconsax.clock,
                label: classGroup.academicYear.isNotEmpty
                    ? classGroup.academicYear
                    : 'Academic Year',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: BrandColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: BrandColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: BrandColors.textMuted),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: BrandColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Material Item Card
// ---------------------------------------------------------------------------
class _MaterialItemCard extends StatelessWidget {
  final LessonMaterial material;

  const _MaterialItemCard({required this.material});

  IconData _fileIcon(String ext) {
    switch (ext) {
      case 'pdf':
        return Iconsax.document;
      case 'doc':
      case 'docx':
        return Iconsax.document_text;
      case 'ppt':
      case 'pptx':
        return Iconsax.gallery;
      case 'xls':
      case 'xlsx':
        return Iconsax.chart_square;
      default:
        return Iconsax.document_normal;
    }
  }

  Color _fileColor(String ext) {
    switch (ext) {
      case 'pdf':
        return const Color(0xFFEF4444);
      case 'doc':
      case 'docx':
        return const Color(0xFF2563EB);
      case 'ppt':
      case 'pptx':
        return const Color(0xFFF97316);
      case 'xls':
      case 'xlsx':
        return const Color(0xFF10B981);
      default:
        return BrandColors.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = material.fileName?.split('.').last.toLowerCase() ?? '';
    final color = _fileColor(ext);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BrandColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BrandColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_fileIcon(ext), color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: BrandColors.textPrimary,
                      ),
                    ),
                    if (material.subjectName != null &&
                        material.subjectName!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: BrandColors.accentSoft,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          material.subjectName!,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: BrandColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (material.description != null &&
              material.description!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              material.description!,
              style: const TextStyle(
                fontSize: 13,
                color: BrandColors.textSecondary,
                height: 1.3,
              ),
            ),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1, color: BrandColors.border),
          const SizedBox(height: 8),
          Row(
            children: [
              if (material.fileName != null) ...[
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Iconsax.paperclip,
                          size: 14, color: BrandColors.textMuted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          material.fileName!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: BrandColors.textMuted,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (material.fileSizeLabel.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  material.fileSizeLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: BrandColors.textSecondary,
                  ),
                ),
              ],
              if (material.createdAt != null) ...[
                const SizedBox(width: 8),
                Text(
                  '· ${_formatDate(material.createdAt!)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: BrandColors.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// ---------------------------------------------------------------------------
// Empty State
// ---------------------------------------------------------------------------
class _EmptyMaterialsState extends StatelessWidget {
  final VoidCallback onUploadPressed;

  const _EmptyMaterialsState({required this.onUploadPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: BrandColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BrandColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: BrandColors.accentSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.folder_open,
                color: BrandColors.accent, size: 30),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Lesson Materials Yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: BrandColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Upload lesson notes, slides, or documents for students in this class.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: BrandColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: onUploadPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: BrandColors.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            icon: const Icon(Iconsax.document_upload, size: 18),
            label: const Text(
              'Upload First Lesson',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error State
// ---------------------------------------------------------------------------
class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Iconsax.warning_2, size: 48, color: BrandColors.danger),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: BrandColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
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
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Upload Lesson Bottom Modal Sheet
// ---------------------------------------------------------------------------
class _UploadLessonBottomSheet extends StatefulWidget {
  final TeacherSession session;
  final TeacherClassGroup classGroup;
  final TeacherApiService api;

  const _UploadLessonBottomSheet({
    required this.session,
    required this.classGroup,
    required this.api,
  });

  @override
  State<_UploadLessonBottomSheet> createState() =>
      _UploadLessonBottomSheetState();
}

class _UploadLessonBottomSheetState extends State<_UploadLessonBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  TeacherClass? _selectedAllocation;
  File? _pickedFile;
  bool _uploading = false;
  String? _uploadError;

  @override
  void initState() {
    super.initState();
    // Default select if there's only 1 subject
    if (widget.classGroup.allocations.length == 1) {
      _selectedAllocation = widget.classGroup.allocations.first;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'ppt',
          'pptx',
          'xls',
          'xlsx',
          'txt',
        ],
      );

      if (result.isNotEmpty) {
        final path = result.first.path;
        if (path != null) {
          final file = File(path);
          final size = await file.length();
          const maxBytes = 20 * 1024 * 1024; // 20 MB

          if (size > maxBytes) {
            if (!mounted) return;
            setState(() {
              _uploadError = 'File size must be 20 MB or less.';
            });
            return;
          }

          setState(() {
            _pickedFile = file;
            _uploadError = null;
          });
        }
      }
    } catch (e) {
      setState(() {
        _uploadError = 'Could not select file: $e';
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedAllocation == null) {
      setState(() => _uploadError = 'Please select a subject first');
      return;
    }

    if (_pickedFile == null) {
      setState(() => _uploadError = 'Please choose a file to upload');
      return;
    }

    setState(() {
      _uploading = true;
      _uploadError = null;
    });

    try {
      await widget.api.uploadLessonMaterial(
        token: widget.session.token,
        subjectClassId: _selectedAllocation!.subjectClassId,
        title: _titleCtrl.text.trim(),
        description:
            _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        file: _pickedFile!,
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on TeacherApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _uploadError = e.message;
        _uploading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _uploadError = 'Upload failed: $e';
        _uploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            24 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top drag handle
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

                // Sheet Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Upload Lesson Material',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: BrandColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Class: ${widget.classGroup.className}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: BrandColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Iconsax.close_circle,
                          color: BrandColors.textMuted),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Error banner if any
                if (_uploadError != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: BrandColors.dangerSoft,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: BrandColors.danger.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Iconsax.warning_2,
                            color: BrandColors.danger, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _uploadError!,
                            style: const TextStyle(
                              color: BrandColors.dangerInk,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // -----------------------------------------------------------
                // 1. FIRST IN FORM: CHOOSE SUBJECT
                // -----------------------------------------------------------
                const Text(
                  'Choose Subject',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: BrandColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<TeacherClass>(
                  initialValue: _selectedAllocation,
                  isExpanded: true,
                  decoration: InputDecoration(
                    hintText: 'Select subject taught in this class',
                    prefixIcon:
                        const Icon(Iconsax.book, color: BrandColors.accent),
                    filled: true,
                    fillColor: BrandColors.inputFill,
                    border: OutlineInputBorder(
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
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                  ),
                  items: widget.classGroup.allocations.map((a) {
                    return DropdownMenuItem<TeacherClass>(
                      value: a,
                      child: Text(
                        a.subjectName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: BrandColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null) return 'Please choose a subject';
                    return null;
                  },
                  onChanged: (val) {
                    setState(() {
                      _selectedAllocation = val;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // -----------------------------------------------------------
                // 2. LESSON TITLE
                // -----------------------------------------------------------
                const Text(
                  'Lesson Title',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: BrandColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _titleCtrl,
                  decoration: InputDecoration(
                    hintText: 'e.g. Chapter 2 - Database Architecture',
                    prefixIcon:
                        const Icon(Iconsax.text, color: BrandColors.accent),
                    filled: true,
                    fillColor: BrandColors.inputFill,
                    border: OutlineInputBorder(
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
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // -----------------------------------------------------------
                // 3. DESCRIPTION (OPTIONAL)
                // -----------------------------------------------------------
                const Text(
                  'Description (Optional)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: BrandColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Brief instructions, notes, or chapter summary...',
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 40),
                      child: Icon(Iconsax.document_text,
                          color: BrandColors.accent),
                    ),
                    filled: true,
                    fillColor: BrandColors.inputFill,
                    border: OutlineInputBorder(
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
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                  ),
                ),
                const SizedBox(height: 16),

                // -----------------------------------------------------------
                // 4. CHOOSE FILE
                // -----------------------------------------------------------
                const Text(
                  'Lesson File',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: BrandColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: _uploading ? null : _pickFile,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: _pickedFile != null
                          ? BrandColors.accentSoft
                          : BrandColors.inputFill,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _pickedFile != null
                            ? BrandColors.accent
                            : BrandColors.borderStrong,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _pickedFile != null
                                ? BrandColors.accent
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _pickedFile != null
                                ? Iconsax.document
                                : Iconsax.document_upload,
                            color: _pickedFile != null
                                ? Colors.white
                                : BrandColors.accent,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _pickedFile != null
                                    ? p.basename(_pickedFile!.path)
                                    : 'Choose a file to upload',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: _pickedFile != null
                                      ? BrandColors.textPrimary
                                      : BrandColors.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _pickedFile != null
                                    ? '${(_pickedFile!.lengthSync() / (1024 * 1024)).toStringAsFixed(2)} MB'
                                    : 'PDF, Word, PPT, Excel, or Text (Max 20MB)',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _pickedFile != null
                                      ? BrandColors.accent
                                      : BrandColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_pickedFile != null && !_uploading)
                          IconButton(
                            icon: const Icon(Iconsax.close_circle,
                                color: BrandColors.danger, size: 20),
                            onPressed: () {
                              setState(() {
                                _pickedFile = null;
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // -----------------------------------------------------------
                // 5. UPLOAD SUBMIT BUTTON
                // -----------------------------------------------------------
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _uploading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BrandColors.accent,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          BrandColors.accent.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _uploading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Uploading...',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Iconsax.send, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Upload Lesson',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
