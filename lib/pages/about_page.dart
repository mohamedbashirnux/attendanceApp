import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../theme/brand_colors.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.surface,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Hero(),
            _Stats(),
            const SizedBox(height: 8),
            _SectionCard(
              icon: Iconsax.book,
              title: 'About',
              body:
                  'After the collapse of Somalia\'s central government in 1991, more than two decades of civil war left the country a failed state and destroyed its education system.\n\nCapital University was founded on 14 May 2013 by a team of Somali professionals who had spent the previous ten years rebuilding schools — with a new goal: giving high school leavers a path to higher education.',
            ),
            _SectionCard(
              icon: Iconsax.building,
              title: 'Background',
              body:
                  'Capital University of Somalia is a non-state, non-profit institution, supported by Capital Company Ltd, built to foster knowledge through the engagement of youth in education and research.\n\nSince its founding, it has earned its place among the country\'s leading places to study, winning the support of the local community for its work establishing the Culture and Languages Institute.',
            ),
            _QuoteCard(
              label: 'Vision',
              body:
                  'To be excellent, engaged and accessible — providing quality, equitable and affordable education to every community in Somalia, in partnership with local communities, the private sector, and international organizations.',
            ),
            _QuoteCard(
              label: 'Mission',
              body:
                  'To raise awareness of the importance of education and make better use of available resources, bridging the gap of knowledge that exists within Somali society.',
            ),
            _DashListCard(
              title: 'Core Values',
              items: const [
                'Excellence centre for accessible education',
                'Devoted to professionalism',
                'Student centered quality education',
              ],
            ),
            _DashListCard(
              title: 'Objectives',
              items: const [
                'Provide quality higher learning education',
                'Integrate teaching, research and knowledge',
                'Empower students to serve the community',
                'Maintain collaborative learning standards',
                'Nurture excellence in teaching and research',
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hero
// ---------------------------------------------------------------------------

class _Hero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 36),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: BrandColors.accentGradientDiagonal,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 84,
            height: 84,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset('assets/logo1.png', fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'CAPITAL UNIVERSITY OF SOMALIA',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.4,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'About Us',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Built from the rebuilding of a country\'s schools — now a home for higher education in Somalia.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.5,
              fontStyle: FontStyle.italic,
              height: 1.5,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stats strip (founding + years + identity in three clean numbers)
// ---------------------------------------------------------------------------

class _Stats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      transform: Matrix4.translationValues(0, -20, 0),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: const [
          Expanded(
            child: _StatItem(
              value: '2013',
              label: 'Founded',
            ),
          ),
          _Divider(),
          Expanded(
            child: _StatItem(
              value: '10+',
              label: 'Years of impact',
            ),
          ),
          _Divider(),
          Expanded(
            child: _StatItem(
              value: '🇸🇴',
              label: 'In Somalia',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: BrandColors.accent,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: BrandColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: BrandColors.border,
    );
  }
}

// ---------------------------------------------------------------------------
// Section card (About / Background)
// ---------------------------------------------------------------------------

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BrandColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: BrandColors.accentSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: BrandColors.accent),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: BrandColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            body,
            style: const TextStyle(
              fontSize: 14.5,
              height: 1.7,
              color: BrandColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quote card (Vision / Mission)
// ---------------------------------------------------------------------------

class _QuoteCard extends StatelessWidget {
  final String label;
  final String body;
  const _QuoteCard({required this.label, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BrandColors.accentSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BrandColors.accentSofter),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: BrandColors.accent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Iconsax.quote_up,
              size: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.8,
                    color: BrandColors.accent,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontStyle: FontStyle.italic,
                    height: 1.7,
                    color: BrandColors.textPrimary,
                    fontWeight: FontWeight.w500,
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
// Dash list card (Core Values / Objectives)
// ---------------------------------------------------------------------------

class _DashListCard extends StatelessWidget {
  final String title;
  final List<String> items;
  const _DashListCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BrandColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: BrandColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          ...items.asMap().entries.map(
                (e) => Padding(
                  padding: EdgeInsets.only(bottom: e.key == items.length - 1 ? 0 : 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: BrandColors.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          e.value,
                          style: const TextStyle(
                            fontSize: 14.5,
                            height: 1.55,
                            color: BrandColors.textSecondary,
                          ),
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
}
