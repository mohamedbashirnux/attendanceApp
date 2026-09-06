import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../theme/brand_colors.dart';
import '../../widgets/logout_button.dart';
import 'models/student_session.dart';
import 'models/student_timetable.dart';
import 'student_api_service.dart';

class StudentTimetablePage extends StatefulWidget {
  const StudentTimetablePage({super.key});

  @override
  State<StudentTimetablePage> createState() => _StudentTimetablePageState();
}

class _StudentTimetablePageState extends State<StudentTimetablePage> {
  final _api = StudentApiService();
  TimetableReport? _report;
  String? _error;
  bool _loading = true;

  // 0 = Monday ... 6 = Sunday
  int _selectedDayIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedDayIndex = DateTime.now().weekday - 1;
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final token = StudentSession.token;
      if (token == null) {
        throw const StudentApiException('Not signed in');
      }
      final r = await _api.fetchTimetable(token);
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

  @override
  Widget build(BuildContext context) {
    final selectedDay = TimetableReport.weekDays[_selectedDayIndex];
    final entries = _report?.byDay[selectedDay] ?? [];

    return Scaffold(
      backgroundColor: BrandColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Timetable',
          style: TextStyle(
            color: BrandColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(
          color: BrandColors.accent,
          size: 24,
        ),
        actions: [
          IconButton(
            onPressed: _loading ? null : _load,
            icon: const Icon(Iconsax.refresh, size: 20),
          ),
          const LogoutButton(),
          const SizedBox(width: 4),
        ],
      ),
      body: _buildBody(selectedDay, entries),
    );
  }

  Widget _buildBody(String selectedDay, List<TimetableEntry> entries) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return _ErrorView(message: _error!, onRetry: _load);
    }

    // Pull-to-refresh
    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            _buildHeader(),

            // Day chips row
            Container(
              height: 68,
              margin: const EdgeInsets.only(top: 14),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: TimetableReport.weekDays.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => _buildDayChip(i),
              ),
            ),

            // Day heading
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text(
                selectedDay,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: BrandColors.textPrimary,
                ),
              ),
            ),

            // Class cards or empty state
            if (entries.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: _EmptyView(day: selectedDay),
              )
            else
              ...entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: _ClassCard(entry: e),
                ),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final r = _report;
    final className = r?.className ?? '—';
    final dept = (r?.departmentName ?? '').isEmpty ? '—' : r!.departmentName!;
    final faculty = (r?.facultyName ?? '').isEmpty ? '—' : r!.facultyName!;
    final total = r?.totalEntries ?? 0;

    return Container(
      margin: const EdgeInsets.all(16),
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
            color: BrandColors.accent.withAlpha(64),
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
                  color: Colors.white.withAlpha(46),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Iconsax.calendar_1,
                    size: 22, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      className,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$faculty · $dept',
                      style: TextStyle(
                        color: Colors.white.withAlpha(217),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(46),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Iconsax.book, size: 13, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  '$total class${total == 1 ? '' : 'es'} per week',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayChip(int i) {
    final day = TimetableReport.weekDays[i];
    final isSelected = i == _selectedDayIndex;
    final isToday = i == DateTime.now().weekday - 1;
    final count = _report?.byDay[day]?.length ?? 0;

    Color bg;
    Color fg;
    Color border;

    if (isSelected) {
      bg = BrandColors.accent;
      fg = Colors.white;
      border = BrandColors.accent;
    } else {
      bg = Colors.white;
      fg = isToday ? BrandColors.accent : BrandColors.textPrimary;
      border = isToday ? BrandColors.accent : const Color(0xFFEEF0EE);
    }

    return GestureDetector(
      onTap: () => setState(() => _selectedDayIndex = i),
      child: Container(
        width: 60,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: 1.2),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              TimetableReport.dayShort[day] ?? day,
              style: TextStyle(
                color: fg,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              count == 0 ? '—' : '$count',
              style: TextStyle(
                color: isSelected
                    ? Colors.white.withAlpha(179)
                    : BrandColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Class card
// ---------------------------------------------------------------------------

class _ClassCard extends StatelessWidget {
  final TimetableEntry entry;
  const _ClassCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final hall = (entry.locationHall ?? '').trim();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEF0EE), width: 1),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left time strip
            Container(
              width: 80,
              decoration: const BoxDecoration(
                color: BrandColors.accentSoft,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(13),
                  bottomLeft: Radius.circular(13),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    entry.timeStart.isEmpty ? '—' : entry.timeStart,
                    style: const TextStyle(
                      color: BrandColors.accent,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 20,
                    height: 1,
                    color: BrandColors.accent.withAlpha(102),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.timeEnd.isEmpty ? '—' : entry.timeEnd,
                    style: TextStyle(
                      color: BrandColors.accent.withAlpha(217),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.subjectName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: BrandColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Iconsax.teacher,
                      text: entry.teacherName.isEmpty
                          ? 'Unknown teacher'
                          : entry.teacherName,
                    ),
                    if (hall.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      _InfoRow(
                        icon: Iconsax.location,
                        text: hall,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: BrandColors.textMuted),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              color: BrandColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyView extends StatelessWidget {
  final String day;
  const _EmptyView({required this.day});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEF0EE), width: 1),
      ),
      child: Column(
        children: [
          const Icon(
            Iconsax.calendar,
            size: 32,
            color: Color(0xFFB5B9BE),
          ),
          const SizedBox(height: 10),
          const Text(
            'No classes scheduled',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: BrandColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Nothing on the timetable for $day.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: BrandColors.textMuted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error view
// ---------------------------------------------------------------------------

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 60),
        const Icon(Iconsax.warning_2,
            size: 36, color: BrandColors.danger),
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
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
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
