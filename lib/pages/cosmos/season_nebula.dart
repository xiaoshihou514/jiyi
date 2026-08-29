import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'package:jiyi/l10n/localizations.dart';
import 'package:jiyi/pages/cosmos/cosmic_player.dart';
import 'package:jiyi/pages/cosmos/nebula.dart';
import 'package:jiyi/pages/default_colors.dart';
import 'package:jiyi/utils/data/metadata.dart';
import 'package:jiyi/utils/em.dart';
import 'package:jiyi/utils/smooth_router.dart';

/// A meteorological season of a year. December belongs to next
/// year's winter, so a season always spans a contiguous 3 months.
class Season {
  final int year;
  final int index; // 0 spring, 1 summer, 2 autumn, 3 winter

  const Season(this.year, this.index);

  static Season of(DateTime t) {
    final m = t.month;
    if (m >= 3 && m <= 5) return Season(t.year, 0);
    if (m >= 6 && m <= 8) return Season(t.year, 1);
    if (m >= 9 && m <= 11) return Season(t.year, 2);
    return Season(m == 12 ? t.year + 1 : t.year, 3);
  }

  DateTime get start => switch (index) {
    0 => DateTime(year, 3, 1),
    1 => DateTime(year, 6, 1),
    2 => DateTime(year, 9, 1),
    _ => DateTime(year - 1, 12, 1),
  };

  DateTime get end => switch (index) {
    0 => DateTime(year, 6, 1),
    1 => DateTime(year, 9, 1),
    2 => DateTime(year, 12, 1),
    _ => DateTime(year, 3, 1),
  };

  String name(AppLocalizations l) => switch (index) {
    0 => l.cosmos_season_spring,
    1 => l.cosmos_season_summer,
    2 => l.cosmos_season_autumn,
    _ => l.cosmos_season_winter,
  };

  Color get color => switch (index) {
    0 => Color(0xFF9FD8A8), // spring green
    1 => Color(0xFFE8C982), // summer gold
    2 => Color(0xFFD8925A), // autumn copper
    _ => Color(0xFF9FC8E8), // winter ice
  };

  @override
  bool operator ==(Object other) =>
      other is Season && other.year == year && other.index == index;

  @override
  int get hashCode => Object.hash(year, index);
}

double starRadius(Metadata md) =>
    2.2 + min(md.length.inSeconds, 600) / 600.0 * 3.5;

int starRings(Metadata md) {
  final s = md.length.inSeconds;
  if (s > 600) return 3;
  if (s > 300) return 2;
  if (s > 120) return 1;
  return 0;
}

enum _GroupMode { timeOfDay, weeks }

/// Level 2 of the memory universe: all recordings of one season
/// as a small nebula, grouped by time of day or by week.
class SeasonNebulaPage extends StatefulWidget {
  final Season season;
  final List<Metadata> records;

  const SeasonNebulaPage({
    super.key,
    required this.season,
    required this.records,
  });

  @override
  State<SeasonNebulaPage> createState() => _SeasonNebulaPageState();
}

class _SeasonNebulaPageState extends State<SeasonNebulaPage>
    with SingleTickerProviderStateMixin {
  _GroupMode _mode = _GroupMode.timeOfDay;
  Metadata? _selected;
  late final AnimationController _twinkle;
  late final List<Metadata> _records;

  @override
  void initState() {
    super.initState();
    _records = [...widget.records]..sort((a, b) => a.time.compareTo(b.time));
    _twinkle = AnimationController(vsync: this, duration: Duration(seconds: 8))
      ..repeat();
  }

  @override
  void dispose() {
    _twinkle.dispose();
    super.dispose();
  }

  void _onStarTap(Metadata md) {
    if (_selected?.path == md.path) {
      _open(md);
    } else {
      setState(() => _selected = md);
    }
  }

  void _open(Metadata md) {
    Navigator.push(context, SmoothRouter.builder(CosmicPlayer(md)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final season = widget.season;
    return Scaffold(
      backgroundColor: Color(0xFF05070C),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.em, vertical: 1.em),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(2.5.em),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: DefaultColors.func.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: DefaultColors.func,
                        size: 4.5.em,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          "${season.name(l)} ${season.year}",
                          style: TextStyle(
                            color: Color(0xFFE8D5A3),
                            fontSize: 8.em,
                            fontFamily: "851手写杂书体",
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l.cosmos_memories(_records.length),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.45),
                                fontSize: 4.5.em,
                                fontFamily: "朱雀仿宋",
                              ),
                            ),
                            SizedBox(width: 1.5.em),
                            Icon(
                              Icons.lock_outline,
                              color: DefaultColors.func.withValues(alpha: 0.7),
                              size: 3.8.em,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.em),
                ],
              ),
            ),
            _buildToggle(l),
            SizedBox(height: 2.em),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (_selected != null) setState(() => _selected = null);
                },
                child: _mode == _GroupMode.timeOfDay
                    ? _timeOfDayBody(l)
                    : _weeksBody(l),
              ),
            ),
            _buildLegend(l),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle(AppLocalizations l) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.em),
      decoration: BoxDecoration(
        border: Border.all(color: DefaultColors.func.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(8.em),
      ),
      child: Row(
        children: [
          Expanded(child: _toggleBtn(l.cosmos_weeks, _GroupMode.weeks)),
          Expanded(child: _toggleBtn(l.cosmos_time_of_day, _GroupMode.timeOfDay)),
        ],
      ),
    );
  }

  Widget _toggleBtn(String text, _GroupMode m) {
    final sel = _mode == m;
    return GestureDetector(
      onTap: () => setState(() {
        _mode = m;
        _selected = null;
      }),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.8.em),
        decoration: BoxDecoration(
          color: sel
              ? DefaultColors.func.withValues(alpha: 0.16)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8.em),
          border: sel
              ? Border.all(color: DefaultColors.func.withValues(alpha: 0.5))
              : null,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: sel
                  ? DefaultColors.func
                  : Colors.white.withValues(alpha: 0.5),
              fontSize: 5.em,
              fontFamily: "朱雀仿宋",
            ),
          ),
        ),
      ),
    );
  }

  double _seasonFrac(Metadata md) {
    final span = widget.season.end.difference(widget.season.start).inMinutes;
    return md.time.difference(widget.season.start).inMinutes / span;
  }

  Widget _timeOfDayBody(AppLocalizations l) {
    final bands =
        <
          (String, List<Metadata>, List<Color>, Color)
        >[
          (
            l.cosmos_morning,
            _records
                .where((m) => m.time.hour >= 5 && m.time.hour < 12)
                .toList(),
            [Color(0xFF6A4A28), Color(0xFF8A5F33), Color(0xFF4A3A28)],
            Color(0xFFE8B86A),
          ),
          (
            l.cosmos_afternoon,
            _records
                .where((m) => m.time.hour >= 12 && m.time.hour < 18)
                .toList(),
            [Color(0xFF323648), Color(0xFF3E3E52), Color(0xFF4A4038)],
            Color(0xFFD8D0B8),
          ),
          (
            l.cosmos_night,
            _records.where((m) => m.time.hour < 5 || m.time.hour >= 18).toList(),
            [Color(0xFF232F52), Color(0xFF2E3D68), Color(0xFF1A2440)],
            Color(0xFF9FB8E8),
          ),
        ];
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.em),
      decoration: BoxDecoration(
        color: Color(0xFF070A10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        borderRadius: BorderRadius.circular(3.em),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3.em),
        child: Column(
          children: [
            for (var i = 0; i < bands.length; i++) ...[
              if (i > 0)
                Container(
                  height: 0.5,
                  color: Colors.white.withValues(alpha: 0.07),
                ),
              Expanded(
                child: _NebulaBand(
                  label: bands[i].$1,
                  records: bands[i].$2,
                  hues: bands[i].$3,
                  starColor: bands[i].$4,
                  seed: widget.season.hashCode ^ (i * 7919),
                  xFrac: _seasonFrac,
                  twinkle: _twinkle,
                  selected: _selected,
                  onStarTap: _onStarTap,
                  onDismiss: () {
                    if (_selected != null) setState(() => _selected = null);
                  },
                  onOpen: _open,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _weeksBody(AppLocalizations l) {
    final weeks = <int, List<Metadata>>{};
    for (final md in _records) {
      final w = md.time.difference(widget.season.start).inDays ~/ 7;
      weeks.putIfAbsent(w, () => []).add(md);
    }
    final keys = weeks.keys.toList()..sort();
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4.em),
      itemCount: keys.length,
      itemBuilder: (context, i) {
        final k = keys[i];
        final start = widget.season.start.add(Duration(days: k * 7));
        final end = start.add(Duration(days: 7));
        return Container(
          height: 34.em,
          margin: EdgeInsets.only(bottom: 2.em),
          decoration: BoxDecoration(
            color: Color(0xFF070A10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            borderRadius: BorderRadius.circular(2.5.em),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2.5.em),
            child: _NebulaBand(
              label:
                  "${l.cosmos_week_label(k + 1)} · "
                  "${DateFormat('M/d').format(start)}–"
                  "${DateFormat('M/d').format(end)}",
              records: weeks[k]!,
              hues: [
                Color(0xFF2A3450),
                Color(0xFF3A3050),
                Color(0xFF4A3A28),
              ],
              starColor: widget.season.color,
              seed: widget.season.hashCode ^ (k * 104729),
              xFrac: (md) =>
                  md.time.difference(start).inMinutes / (7 * 1440.0),
              twinkle: _twinkle,
              selected: _selected,
              onStarTap: _onStarTap,
              onDismiss: () {
                if (_selected != null) setState(() => _selected = null);
              },
              onOpen: _open,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegend(AppLocalizations l) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(4.em, 2.em, 4.em, 1.em),
          padding: EdgeInsets.symmetric(vertical: 2.em),
          decoration: BoxDecoration(
            color: Color(0xFF070A10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            borderRadius: BorderRadius.circular(2.5.em),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                children: [
                  Text(
                    l.cosmos_legend_duration,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 4.2.em,
                      fontFamily: "朱雀仿宋",
                    ),
                  ),
                  SizedBox(width: 2.em),
                  for (final s in [2.2, 3.2, 4.4, 5.8])
                    Padding(
                      padding: EdgeInsets.only(right: 1.2.em),
                      child: Icon(
                        Icons.star_rounded,
                        color: DefaultColors.func,
                        size: s.em,
                      ),
                    ),
                ],
              ),
              Container(
                width: 0.5,
                height: 6.em,
                color: Colors.white.withValues(alpha: 0.12),
              ),
              Row(
                children: [
                  Text(
                    l.cosmos_legend_rings,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 4.2.em,
                      fontFamily: "朱雀仿宋",
                    ),
                  ),
                  SizedBox(width: 2.em),
                  for (final s in [2.2, 3.2, 4.4])
                    Padding(
                      padding: EdgeInsets.only(right: 1.2.em),
                      child: Container(
                        width: s.em,
                        height: s.em,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: DefaultColors.func.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 1.em),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                color: DefaultColors.func.withValues(alpha: 0.6),
                size: 4.em,
              ),
              SizedBox(width: 1.em),
              Text(
                l.cosmos_encrypted,
                style: TextStyle(
                  color: DefaultColors.func.withValues(alpha: 0.6),
                  fontSize: 4.4.em,
                  fontFamily: "朱雀仿宋",
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// One horizontal nebula band (a time-of-day slice or a week).
class _NebulaBand extends StatelessWidget {
  final String label;
  final List<Metadata> records;
  final List<Color> hues;
  final Color starColor;
  final int seed;
  final double Function(Metadata) xFrac;
  final Animation<double> twinkle;
  final Metadata? selected;
  final void Function(Metadata) onStarTap;
  final VoidCallback onDismiss;
  final void Function(Metadata) onOpen;

  const _NebulaBand({
    required this.label,
    required this.records,
    required this.hues,
    required this.starColor,
    required this.seed,
    required this.xFrac,
    required this.twinkle,
    required this.selected,
    required this.onStarTap,
    required this.onDismiss,
    required this.onOpen,
  });

  Offset _pos(Metadata md, Size size) {
    final rng = Random(md.path.hashCode ^ seed);
    final x = size.width * (0.08 + 0.84 * xFrac(md).clamp(0.0, 1.0));
    final y = size.height * (0.34 + rng.nextDouble() * 0.48);
    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final positions = {
          for (final md in records) md.path: _pos(md, size),
        };
        final sel = selected;
        final selPos = sel != null ? positions[sel.path] : null;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (d) {
            Metadata? best;
            var bestDist = 30.0;
            for (final md in records) {
              final dist = (positions[md.path]! - d.localPosition).distance;
              if (dist < bestDist) {
                bestDist = dist;
                best = md;
              }
            }
            if (best != null) {
              onStarTap(best);
            } else {
              onDismiss();
            }
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _BandPainter(
                    hues,
                    seed,
                    records,
                    positions,
                    starColor,
                  ),
                ),
              ),
              Positioned.fill(
                child: CustomPaint(
                  painter: _BandStarsPainter(
                    records,
                    positions,
                    starColor,
                    twinkle,
                    sel?.path,
                  ),
                ),
              ),
              Positioned(
                left: 3.em,
                top: 1.8.em,
                child: Text(
                  label,
                  style: TextStyle(
                    color: Color(0xFFE8D5A3).withValues(alpha: 0.85),
                    fontSize: 6.em,
                    fontFamily: "朱雀仿宋",
                  ),
                ),
              ),
              if (sel != null && selPos != null)
                _buildTooltip(context, sel, selPos, size),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTooltip(
    BuildContext context,
    Metadata md,
    Offset p,
    Size size,
  ) {
    const w = 150.0;
    final left = (p.dx - w / 2)
        .clamp(4.0, max(4.0, size.width - w - 4))
        .toDouble();
    final above = p.dy > 84;
    final top = above ? p.dy - 76 : p.dy + 18;
    final mins = md.length.inMinutes;
    final secs = md.length.inSeconds % 60;
    final rng = Random(md.path.hashCode);
    return Positioned(
      left: left,
      top: top,
      width: w,
      child: GestureDetector(
        onTap: () => onOpen(md),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Color(0xF2101218),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: DefaultColors.func.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateFormat('MMM d · HH:mm').format(md.time),
                style: TextStyle(
                  color: Color(0xFFE8D5A3),
                  fontSize: 14,
                  fontFamily: "digital7-mono",
                ),
              ),
              SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < 12; i++)
                    Container(
                      width: 2.5,
                      height: 4 + rng.nextDouble() * 12,
                      margin: EdgeInsets.only(right: 1.5),
                      color: Colors.white.withValues(alpha: 0.55),
                    ),
                  SizedBox(width: 4),
                  Text(
                    "$mins:${secs.toString().padLeft(2, '0')}",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                      fontFamily: "digital7-mono",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Static band layer: nebula clouds, dust, constellation lines and
/// the blurred light base of every star.
class _BandPainter extends CustomPainter {
  final List<Color> hues;
  final int seed;
  final List<Metadata> records;
  final Map<String, Offset> positions;
  final Color starColor;

  _BandPainter(
    this.hues,
    this.seed,
    this.records,
    this.positions,
    this.starColor,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF070A10),
            Color.lerp(Color(0xFF070A10), hues.first, 0.10)!,
          ],
        ).createShader(rect),
    );
    Nebula.dust(canvas, rect, seed, count: (rect.width * 0.16).round());
    Nebula.cloud(
      canvas,
      Offset(size.width * 0.72, size.height * 0.55),
      size.height * 1.05,
      hues,
      seed + 1,
      squash: 0.5,
    );
    Nebula.cloud(
      canvas,
      Offset(size.width * 0.18, size.height * 0.4),
      size.height * 0.65,
      hues.reversed.toList(),
      seed + 2,
      squash: 0.55,
      intensity: 0.7,
    );

    // constellation
    if (records.length > 1) {
      final line = Paint()
        ..color = starColor.withValues(alpha: 0.22)
        ..strokeWidth = 0.6;
      for (var i = 0; i + 1 < records.length; i++) {
        final a = positions[records[i].path]!;
        final b = positions[records[i + 1].path]!;
        Nebula.dashedLine(canvas, a, b, line);
      }
    }

    // blurred light bases
    for (final md in records) {
      Nebula.glowStar(
        canvas,
        positions[md.path]!,
        starRadius(md),
        starColor,
        1,
        blurred: true,
      );
    }
  }

  @override
  bool shouldRepaint(_BandPainter old) => false;
}

/// Animated band layer: twinkling star cores, halos and rings.
class _BandStarsPainter extends CustomPainter {
  final List<Metadata> records;
  final Map<String, Offset> positions;
  final Color starColor;
  final Animation<double> twinkle;
  final String? selectedPath;

  _BandStarsPainter(
    this.records,
    this.positions,
    this.starColor,
    this.twinkle,
    this.selectedPath,
  ) : super(repaint: twinkle);

  @override
  void paint(Canvas canvas, Size size) {
    final t = twinkle.value * 8;
    for (final md in records) {
      final phase = (md.path.hashCode % 1000) / 1000.0;
      final tw = 0.6 + 0.4 * sin(t * (0.7 + phase) + phase * 2 * pi);
      final hs = 1.0 + 0.28 * sin(t * 0.8 + phase * 2 * pi);
      final isSel = md.path == selectedPath;
      Nebula.glowStar(
        canvas,
        positions[md.path]!,
        starRadius(md) * (isSel ? 1.3 : 1),
        starColor,
        tw,
        rings: starRings(md) + (isSel ? 1 : 0),
        flare: isSel,
        haloScale: hs,
      );
    }
  }

  @override
  bool shouldRepaint(_BandStarsPainter old) =>
      old.selectedPath != selectedPath || old.records != records;
}
