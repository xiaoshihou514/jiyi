import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:jiyi/components/spinner.dart';
import 'package:jiyi/l10n/localizations.dart';
import 'package:jiyi/pages/cosmos/nebula.dart';
import 'package:jiyi/pages/cosmos/season_nebula.dart';
import 'package:jiyi/services/io.dart';
import 'package:jiyi/utils/data/metadata.dart';
import 'package:jiyi/utils/em.dart';
import 'package:jiyi/utils/notifier.dart';
import 'package:jiyi/utils/smooth_router.dart';

/// Opt-in immersive interface: the memory universe.
/// The outermost level is a nebula whose stars are the seasons
/// that contain recordings — tap one to dive into it.
class CosmosPage extends StatefulWidget {
  const CosmosPage({super.key});

  @override
  State<CosmosPage> createState() => _CosmosPageState();
}

class _CosmosPageState extends State<CosmosPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _twinkle;

  @override
  void initState() {
    super.initState();
    _twinkle = AnimationController(vsync: this, duration: Duration(seconds: 8))
      ..repeat();
  }

  @override
  void dispose() {
    _twinkle.dispose();
    super.dispose();
  }

  void _openSeason(Season s, List<Metadata> records) {
    Navigator.push(
      context,
      SmoothRouter.builder(SeasonNebulaPage(season: s, records: records)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Color(0xFF05070C),
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 8.em,
                  ),
                ),
                Spacer(),
                Text(
                  l.cosmos_title,
                  style: TextStyle(
                    color: Color(0xFFE8D5A3).withValues(alpha: 0.8),
                    fontSize: 6.em,
                    fontFamily: "851手写杂书体",
                    decoration: TextDecoration.none,
                  ),
                ),
                Spacer(),
                SizedBox(width: 14.em),
              ],
            ),
            Expanded(
              child: Consumer<Notifier>(
                builder: (context, _, _) => FutureBuilder<List<Metadata>>(
                  future: IO.indexFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Spinner(Icons.sync, Color(0xFF8FB8D8), 30.em),
                      );
                    }
                    final records = snapshot.data ?? [];
                    if (records.isEmpty) {
                      return Center(
                        child: Text(
                          l.cosmos_empty,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 5.em,
                            fontFamily: "朱雀仿宋",
                          ),
                        ),
                      );
                    }
                    return _Universe(
                      records: records,
                      twinkle: _twinkle,
                      onSelect: _openSeason,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Spot {
  final Season season;
  final List<Metadata> records;
  final Offset pos;
  final double r;
  final double phase;

  _Spot(this.season, this.records, this.pos, this.r, this.phase);

  Color get color => season.color;
}

class _Universe extends StatelessWidget {
  final List<Metadata> records;
  final Animation<double> twinkle;
  final void Function(Season, List<Metadata>) onSelect;

  const _Universe({
    required this.records,
    required this.twinkle,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final bySeason = <Season, List<Metadata>>{};
    for (final md in records) {
      bySeason.putIfAbsent(Season.of(md.time), () => []).add(md);
    }
    final seasons = bySeason.keys.toList()
      ..sort((a, b) {
        final c = a.year.compareTo(b.year);
        return c != 0 ? c : a.index.compareTo(b.index);
      });

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final center = Offset(size.width / 2, size.height * 0.48);
        final rx = size.width * 0.34;
        final ry = size.height * 0.26;

        final maxCount = seasons
            .map((s) => bySeason[s]!.length)
            .fold(1, max);
        final spots = <_Spot>[];
        for (var i = 0; i < seasons.length; i++) {
          final s = seasons[i];
          final rng = Random(s.hashCode);
          final angle = -pi / 2 + i * 2 * pi / seasons.length;
          final pos =
              center +
              Offset(
                cos(angle) * rx * (0.92 + rng.nextDouble() * 0.16),
                sin(angle) * ry * (0.9 + rng.nextDouble() * 0.2),
              );
          final r = 6 + 6 * (bySeason[s]!.length / maxCount);
          spots.add(_Spot(s, bySeason[s]!, pos, r, rng.nextDouble()));
        }

        return GestureDetector(
          onTapUp: (d) {
            _Spot? best;
            var bestDist = 36.0;
            for (final s in spots) {
              final dist = (s.pos - d.localPosition).distance;
              if (dist < bestDist) {
                bestDist = dist;
                best = s;
              }
            }
            if (best != null) onSelect(best.season, best.records);
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _UniversePainter(center, rx, ry, spots),
                ),
              ),
              Positioned.fill(
                child: CustomPaint(
                  painter: _UniverseStarsPainter(spots, twinkle),
                ),
              ),
              for (final s in spots) _seasonLabel(l, s, size),
            ],
          ),
        );
      },
    );
  }

  Widget _seasonLabel(AppLocalizations l, _Spot s, Size size) {
    final rightSide = s.pos.dx < size.width * 0.62;
    const w = 110.0;
    return Positioned(
      left: rightSide ? s.pos.dx + s.r + 8 : s.pos.dx - s.r - 8 - w,
      top: s.pos.dy - 14,
      width: w,
      child: Column(
        crossAxisAlignment: rightSide
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          Text(
            s.season.name(l),
            style: TextStyle(
              color: s.color,
              fontSize: 5.6.em,
              fontFamily: "朱雀仿宋",
            ),
          ),
          Text(
            "${s.season.year}",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 4.em,
              fontFamily: "digital7-mono",
            ),
          ),
        ],
      ),
    );
  }

}

/// Static layer: deep space background, nebula clouds, orbit ring
/// and the blurred light base of every season star.
class _UniversePainter extends CustomPainter {
  final Offset center;
  final double rx;
  final double ry;
  final List<_Spot> spots;

  _UniversePainter(this.center, this.rx, this.ry, this.spots);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF04060B), Color(0xFF070A11), Color(0xFF0B0E16)],
        ).createShader(rect),
    );
    Nebula.dust(canvas, rect, 7, count: 160, alpha: 0.8);
    // faint distant wisps
    Nebula.cloud(
      canvas,
      Offset(size.width * 0.12, size.height * 0.18),
      size.width * 0.28,
      [Color(0xFF22304A), Color(0xFF2A3A55)],
      31,
      intensity: 0.6,
    );
    Nebula.cloud(
      canvas,
      Offset(size.width * 0.9, size.height * 0.75),
      size.width * 0.24,
      [Color(0xFF2A2440), Color(0xFF22284A)],
      47,
      intensity: 0.5,
    );
    // main cloud hugging the orbit
    Nebula.cloud(
      canvas,
      center,
      rx * 1.35,
      [
        Color(0xFF2E3F5E),
        Color(0xFF3A4A6E),
        Color(0xFF27364F),
        Color(0xFF46587A),
      ],
      11,
      squash: 0.62,
    );
    // warm golden core
    Nebula.cloud(
      canvas,
      center + Offset(0, ry * 0.08),
      rx * 0.62,
      [Color(0xFF8A6A3A), Color(0xFFC9A86A), Color(0xFF6A5230)],
      23,
      squash: 0.66,
      intensity: 1.15,
    );
    // bright nucleus
    Nebula.cloud(
      canvas,
      center,
      rx * 0.22,
      [Color(0xFFE8D5A3), Color(0xFFC9A86A)],
      29,
      squash: 0.8,
      intensity: 0.9,
    );
    // orbit ring
    Nebula.dashedEllipse(
      canvas,
      Rect.fromCenter(center: center, width: rx * 2, height: ry * 2),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.10)
        ..strokeWidth = 1,
    );
    // blurred light bases
    for (final s in spots) {
      Nebula.glowStar(canvas, s.pos, s.r, s.color, 1, blurred: true);
    }
  }

  @override
  bool shouldRepaint(_UniversePainter old) => old.spots != spots;
}

/// Animated layer: twinkling season stars.
class _UniverseStarsPainter extends CustomPainter {
  final List<_Spot> spots;
  final Animation<double> twinkle;

  _UniverseStarsPainter(this.spots, this.twinkle) : super(repaint: twinkle);

  @override
  void paint(Canvas canvas, Size size) {
    final t = twinkle.value * 8;
    for (final s in spots) {
      final tw = 0.65 + 0.35 * sin(t * (0.7 + s.phase) + s.phase * 2 * pi);
      final hs = 1.0 + 0.3 * sin(t * 0.8 + s.phase * 2 * pi);
      Nebula.glowStar(
        canvas,
        s.pos,
        s.r,
        s.color,
        tw,
        flare: true,
        haloScale: hs,
      );
    }
  }

  @override
  bool shouldRepaint(_UniverseStarsPainter old) => old.spots != spots;
}
