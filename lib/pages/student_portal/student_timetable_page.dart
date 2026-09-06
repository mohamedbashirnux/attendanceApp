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

  // Index of the day shown in the body. 0 = Monday.
  int _selectedDayIndex = 0;

  @override
  void initState() {
    super.initState();
    // Default the body to today so the user lands on something useful.
    _selectedDayIndex = _todayIndex();
    _load();
  }

  static int _todayIndex() {
    // DateTime.weekday: 1 = Monday ... 7 = Sunday.
    return DateTime.now().weekday - 1;
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
    final entries = _report?.byDay[selectedDay] ?? const <TimetableEntry>[];

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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorBlock(message: _error!, onRetry: _load)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      _Header(report: _report),
                      const SizedBox(height: 12),
                      _DayStrip(
                        selected: _selectedDayIndex,
                        todayIndex: _todayIndex(),
                        counts: {
                          for (var i = 0; i < TimetableReport.weekDays.length; i++)
                            TimetableReport.weekDays[i]:
                                _report?.byDay[TimetableReport.weekDays[i]]?.length ?? 0,
                        },
                        onSelect: (i) =>
                            setState(() => _selectedDayIndex = i),
                      ),
                      const SizedBox(height: 8),
                      _DayBody(
                        day: selectedDay,
                        isToday: _selectedDayIndex == _todayIndex(),
                        entries: entries,
                      ),
                    ],
                  ),
                ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header: class info + total per week
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  final TimetableReport? report;
  const _Header({required this.report});

  @override
  Widget build(BuildContext context) {
    final r = report;
    final className = r?.className ?? '—';
    final dept = (r?.departmentName ?? '').isEmpty ? '—' : r!.departmentName!;
    final faculty =
        (r?.facultyName ?? '').isEmpty ? '—' : r!.facultyName!;
    final total = r?.totalEntries ?? 0;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
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
            color: BrandColors.accent.withOpacity(0.25),
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Iconsax.calendar_1,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
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
                        color: Colors.white.withOpacity(0.85),
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
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Iconsax.book,
                  size: 13,
                  color: Colors.white,
                ),
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
}

// ---------------------------------------------------------------------------
// Day strip — Mon..Sun chips
// ---------------------------------------------------------------------------

class _DayStrip extends StatelessWidget {
  final int selected;
  final int todayIndex;
  final Map<String, int> counts;
  final ValueChanged<int> onSelect;

  const _DayStrip({
    required this.selected,
    required this.todayIndex,
    required this.counts,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: TimetableReport.weekDays.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final day = TimetableReport.weekDays[i];
          final isSelected = i == selected;
          final isToday = i == todayIndex;
          final count = counts[day] ?? 0;
          return _DayChip(
            label: TimetableReport.dayShort[day] ?? day,
            count: count,
            isSelected: isSelected,
            isToday: isToday,
            onTap: () => onSelect(i),
          );
        },
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  const _DayChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final Color border;
    if (isSelected) {
      bg = BrandColors.accent;
      fg = Colors.white;
      border = BrandColors.accent;
    } else {
      bg = Colors.white;
      fg = isToday ? BrandColors.accent : BrandColors.textPrimary;
      border = isToday ? BrandColors.accent : const Color(0xFFEEF0EE);
    }
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border, width: 1),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                count == 0 ? '—' : '$count',
                style: TextStyle(
                  color: isSelected
                      ? Colors.white.withOpacity(0.85)
                      : BrandColors.textMuted,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Day body — list of class cards
// ---------------------------------------------------------------------------

class _DayBody extends StatelessWidget {
  final String day;
  final bool isToday;
  final List<TimetableEntry> entries;

  const _DayBody({
    required this.day,
    required this.isToday,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Text(
                  day,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: BrandColors.textPrimary,
                  ),
                ),
                if (isToday) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: BrandColors.accentSoft,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Today',
                      style: TextStyle(
                        color: BrandColors.accent,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (entries.isEmpty)
            _EmptyDay(day: day)
          else
            ...entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ClassCard(entry: e, isToday: isToday),
              ),
            ),
        ],
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  final TimetableEntry entry;
  final bool isToday;
  const _ClassCard({required this.entry, required this.isToday});

  String _formatRange() {
    final start = entry.timeStart;
    final end = entry.timeEnd;
    if (start.isEmpty && end.isEmpty) return '—';
    if (end.isEmpty) return start;
    return '$start – $end';
  }

  @override
  Widget build(BuildContext context) {
    final hall = (entry.locationHall ?? '').trim();
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: null, // future: open subject detail
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEEF0EE), width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left accent strip with the time range.
              Container(
                width: 78,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: BrandColors.accentSoft,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(13),
                    bottomLeft: Radius.circular(13),
                  ),
                ),
                alignment: Alignment.center,
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
                      width: 18,
                      height: 1,
                      color: BrandColors.accent.withOpacity(0.4),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.timeEnd.isEmpty ? '—' : entry.timeEnd,
                      style: TextStyle(
                        color: BrandColors.accent.withOpacity(0.85),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              // Body
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
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
                      const SizedBox(height: 6),
                      _Row(
                        icon: Iconsax.teacher,
                        text: entry.teacherName.isEmpty
                            ? 'Unknown teacher'
                            : entry.teacherName,
                      ),
                      if (hall.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        _Row(icon: Iconsax.location, text: hall),
                      ],
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: BrandColors.accentSoft,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _formatRange(),
                          style: const TextStyle(
                            color: BrandColors.accent,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                          ),
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
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Row({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12, color: BrandColors.textMuted),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
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

class _EmptyDay extends StatelessWidget {
  final String day;
  const _EmptyDay({required this.day});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEF0EE), width: 1),
      ),
      child: Column(
        children: [
          const Icon(
            Iconsax.calendar,
            size: 28,
            color: Color(0xFFB5B9BE),
          ),
          const SizedBox(height: 8),
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
              height: 1.35,
            ),
          ),
        ],
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
          color: BrandColors.danger,
        ),
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
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 10,
              ),
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
