import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../theme/brand_colors.dart';

class GraduationPage extends StatelessWidget {
  const GraduationPage({super.key});

  static const _images = <String>[
    'assets/graducations/1.jpeg',
    'assets/graducations/2.jpeg',
    'assets/graducations/3.jpeg',
    'assets/graducations/4.jpeg',
    'assets/graducations/5.jpeg',
    'assets/graducations/6.jpeg',
    'assets/graducations/7.jpeg',
    'assets/graducations/8.jpeg',
  ];

  // 2 = "big card" (full width), 1 = regular card.
  static const _pattern = <int>[2, 1, 1, 1, 2, 1, 1, 1];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.surface,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: _HeroHeader()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            sliver: SliverList.list(
              children: _buildRows(),
            ),
          ),
        ],
      ),
    );
  }

  // Build a list of [Row]s of cards. Each "big" card occupies its own
  // row; the regular cards are laid out in pairs (2 per row). This
  // gives the gallery visual rhythm without needing a full masonry
  // implementation.
  List<Widget> _buildRows() {
    final rows = <Widget>[];
    int i = 0;
    while (i < _images.length) {
      if (_pattern[i] == 2) {
        rows.add(_BigCard(index: i, path: _images[i]));
        rows.add(const SizedBox(height: 14));
        i += 1;
      } else {
        final end = (i + 2).clamp(0, _images.length);
        final pair = <Widget>[];
        for (int j = i; j < end; j++) {
          pair.add(_SmallCard(index: j, path: _images[j]));
        }
        rows.add(
          Row(
            children: [
              for (int k = 0; k < pair.length; k++) ...[
                if (k > 0) const SizedBox(width: 14),
                Expanded(child: pair[k]),
              ],
              // If the last pair is incomplete, fill the gap so the
              // grid stays balanced.
              if (pair.length == 1) const Expanded(child: SizedBox()),
            ],
          ),
        );
        rows.add(const SizedBox(height: 14));
        i = end;
      }
    }
    return rows;
  }
}

// ---------------------------------------------------------------------------
// Hero header
// ---------------------------------------------------------------------------

class _HeroHeader extends StatelessWidget {
  const _HeroHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
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
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Iconsax.medal_star,
                size: 30,
                color: BrandColors.accent,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'GRADUATION CEREMONY',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.2,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Celebrating Excellence',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Moments from the Capital University class of graduates',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: const Text(
              '8 photos',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Big card (full width)
// ---------------------------------------------------------------------------

class _BigCard extends StatelessWidget {
  final int index;
  final String path;
  const _BigCard({required this.index, required this.path});

  @override
  Widget build(BuildContext context) {
    return _PhotoCard(
      path: path,
      index: index,
      aspectRatio: 16 / 9,
      badge: 'Featured',
    );
  }
}

// ---------------------------------------------------------------------------
// Small card (half width)
// ---------------------------------------------------------------------------

class _SmallCard extends StatelessWidget {
  final int index;
  final String path;
  const _SmallCard({required this.index, required this.path});

  @override
  Widget build(BuildContext context) {
    return _PhotoCard(
      path: path,
      index: index,
      aspectRatio: 1,
      badge: null,
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable photo card
// ---------------------------------------------------------------------------

class _PhotoCard extends StatelessWidget {
  final String path;
  final int index;
  final double aspectRatio;
  final String? badge;

  const _PhotoCard({
    required this.path,
    required this.index,
    required this.aspectRatio,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openViewer(context, path, index),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: 'graduation_$index',
                child: Image.asset(
                  path,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _ImageError(
                    label: 'Photo ${index + 1}',
                  ),
                ),
              ),
              // Subtle gradient at the bottom for the index label.
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 24, 14, 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.65),
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Photo ${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_outward_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              if (badge != null)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: BrandColors.accent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      badge!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
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

class _ImageError extends StatelessWidget {
  final String label;
  const _ImageError({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: BrandColors.accentSoft,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Iconsax.image,
            color: BrandColors.accent,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: BrandColors.accent,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Fullscreen viewer
// ---------------------------------------------------------------------------

void _openViewer(BuildContext context, String path, int index) {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, animation, __) {
        return FadeTransition(
          opacity: animation,
          child: _GraduationViewer(path: path, index: index),
        );
      },
    ),
  );
}

class _GraduationViewer extends StatelessWidget {
  final String path;
  final int index;
  const _GraduationViewer({required this.path, required this.index});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Hero(
                tag: 'graduation_$index',
                child: InteractiveViewer(
                  maxScale: 4,
                  child: Image.asset(
                    path,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(
                        Iconsax.image,
                        color: Colors.white54,
                        size: 64,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Top bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Iconsax.arrow_left,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Photo ${index + 1} of 8',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Hint
            const Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: Center(
                child: Text(
                  'Pinch to zoom',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
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
