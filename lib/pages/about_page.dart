import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Design tokens
// A quiet, cool paper background with a single deep-teal accent (a nod to
// the coast, and to academic regalia) — deliberately not the usual
// purple/indigo, and not the cream+terracotta combo you see everywhere.
// Swap in a real display font (e.g. via the google_fonts package, something
// like "Fraunces" or "Newsreader") on _Type.display for even more character.
// ---------------------------------------------------------------------------
class _Palette {
  static const paper = Color(0xFFF5F6F4);
  static const ink = Color(0xFF1B1E22);
  static const muted = Color(0xFF5B6167);
  static const rule = Color(0xFFDFE2DE);
  static const accent = Color(0xFF1E5F63);
  static const accentSoft = Color(0x1A1E5F63); // accent @ ~10%
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Palette.paper,
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _hero(),
                _timeline(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 64),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _section(
                        title: 'About',
                        body: 'After the collapse of Somalia\'s central government in 1991, more than two decades of civil war left the country a failed state and destroyed its education system. Capital University was founded on 14 May 2013 by a team of Somali professionals who had spent the previous ten years rebuilding schools — with a new goal: giving high school leavers a path to higher education.',
                      ),
                      _rule(),
                      _section(
                        title: 'Background',
                        body: 'Capital University of Somalia is a non-state, non-profit institution, supported by Capital Company Ltd, built to foster knowledge through the engagement of youth in education and research.\n\nSince its founding, it has earned its place among the country\'s leading places to study, winning the support of the local community for its work establishing the Culture and Languages Institute.',
                      ),
                      _rule(),
                      _quote(
                        label: 'Vision',
                        body: 'To be excellent, engaged and accessible — providing quality, equitable and affordable education to every community in Somalia, in partnership with local communities, the private sector, and international organizations.',
                      ),
                      const SizedBox(height: 36),
                      _quote(
                        label: 'Mission',
                        body: 'To raise awareness of the importance of education and make better use of available resources, bridging the gap of knowledge that exists within Somali society.',
                      ),
                      _rule(),
                      _dashList(
                        title: 'Core Values',
                        items: const [
                          'Excellence centre for accessible education',
                          'Devoted to professionalism',
                          'Student centered quality education',
                        ],
                      ),
                      const SizedBox(height: 40),
                      _dashList(
                        title: 'Objectives',
                        items: const [
                          'Provide quality higher learning education',
                          'Integrate teaching, research and knowledge',
                          'Empower students to serve the community',
                          'Maintain collaborative learning standards',
                          'Nurture excellence in teaching and research',
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -- Hero -------------------------------------------------------------

  Widget _hero() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 40),
      child: Column(
        children: [
          const Text(
            'CAPITAL UNIVERSITY OF SOMALIA',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.4,
              color: _Palette.muted,
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'About us',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              height: 1.1,
              color: _Palette.ink,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Built from the rebuilding of a country\'s schools — '
            'now a home for higher education in Somalia.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              height: 1.5,
              color: _Palette.muted,
            ),
          ),
          const SizedBox(height: 28),
          _fadeRule(),
        ],
      ),
    );
  }

  Widget _fadeRule() {
    return Container(
      height: 2,
      width: 120,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, _Palette.accent, Colors.transparent],
        ),
      ),
    );
  }

  // -- Signature: founding timeline --------------------------------------

  Widget _timeline() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'OUR STORY',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.2,
              color: _Palette.accent,
            ),
          ),
          const SizedBox(height: 24),
          _timelineItem(
            year: '1991',
            text:
                'Somalia\'s central government collapses. Civil war follows, '
                'and the education system is destroyed.',
          ),
          _timelineItem(
            year: '2013',
            text:
                '14 May — Capital University is founded, after a decade of '
                'rebuilding Somali schools from the ground up.',
          ),
          _timelineItem(
            year: 'Today',
            text:
                'One of the country\'s leading institutions, and home to '
                'the Culture and Languages Institute.',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _timelineItem({
    required String year,
    required String text,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(
                  color: _Palette.accent,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(child: Container(width: 1.5, color: _Palette.rule)),
            ],
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    year,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: _Palette.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 14.5,
                      height: 1.6,
                      color: _Palette.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -- Content sections ---------------------------------------------------

  Widget _rule() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Divider(height: 1, thickness: 1, color: _Palette.rule),
    );
  }

  Widget _section({required String title, required String body}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _Palette.ink,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          body,
          style: const TextStyle(
            fontSize: 15,
            height: 1.75,
            color: _Palette.muted,
          ),
        ),
      ],
    );
  }

  Widget _quote({required String label, required String body}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '“',
          style: TextStyle(
            fontSize: 56,
            height: 0.9,
            fontWeight: FontWeight.w800,
            color: _Palette.accentSoft,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.8,
                    color: _Palette.accent,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontStyle: FontStyle.italic,
                    height: 1.7,
                    color: _Palette.ink,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _dashList({required String title, required List<String> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _Palette.ink,
          ),
        ),
        const SizedBox(height: 18),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '—',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _Palette.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.55,
                      color: _Palette.muted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
