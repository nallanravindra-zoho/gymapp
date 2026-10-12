import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/time/local_date.dart';
import '../../core/widgets/app_widgets.dart';
import '../../data/repositories/body_measurement_repository.dart';
import '../week/day_format.dart' show monthNames;
import 'metrics_providers.dart';

String chartDate(String localDate) {
  final d = parseLocalDate(localDate);
  return '${d.day} ${monthNames[d.month - 1]} ${d.year}';
}

String _shortDate(String localDate) {
  final d = parseLocalDate(localDate);
  return '${d.day} ${monthNames[d.month - 1]}';
}

/// A simple line with dots. Tap or drag to read the date and value of a point;
/// the latest point is selected to begin with. Fully described to screen
/// readers.
class MetricLineChart extends StatefulWidget {
  const MetricLineChart({
    super.key,
    required this.points,
    required this.unit,
    required this.name,
    this.decimals = 1,
  });

  final List<MeasurementPoint> points;
  final String unit;

  /// Plain name, e.g. "Weight".
  final String name;
  final int decimals;

  @override
  State<MetricLineChart> createState() => _MetricLineChartState();
}

class _MetricLineChartState extends State<MetricLineChart> {
  int? _selected;

  String _value(double v) =>
      '${v.toStringAsFixed(widget.decimals)} ${widget.unit}';

  int _nearest(double dx, double width) {
    final xs = _xs(widget.points, width);
    var best = 0;
    for (var i = 1; i < xs.length; i++) {
      if ((xs[i] - dx).abs() < (xs[best] - dx).abs()) best = i;
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    final pts = widget.points;
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    if (pts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'No ${widget.name == 'BMI' ? 'BMI' : widget.name.toLowerCase()} entries yet. Add measurements to '
          'see a chart.',
          style: text.bodyMedium?.copyWith(color: t.textMuted),
        ),
      );
    }
    final sel = math.min(_selected ?? pts.length - 1, pts.length - 1);
    final p = pts[sel];
    final values = pts.map((e) => e.value);
    final summary =
        '${widget.name} chart, ${pts.length} '
        '${pts.length == 1 ? 'entry' : 'entries'}. '
        'Lowest ${_value(values.reduce(math.min))}, highest '
        '${_value(values.reduce(math.max))}. Latest ${_value(pts.last.value)} '
        'on ${chartDate(pts.last.localDate)}.';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          liveRegion: true,
          label: '${chartDate(p.localDate)}, ${_value(p.value)}',
          child: ExcludeSemantics(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: 10,
              children: [
                Text(_value(p.value), style: text.titleLarge),
                Text(
                  chartDate(p.localDate),
                  style: text.bodyMedium?.copyWith(color: t.textMuted),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Semantics(
          label: summary,
          child: ExcludeSemantics(
            child: LayoutBuilder(
              builder: (context, c) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (d) => setState(
                  () => _selected = _nearest(d.localPosition.dx, c.maxWidth),
                ),
                onHorizontalDragUpdate: (d) => setState(
                  () => _selected = _nearest(d.localPosition.dx, c.maxWidth),
                ),
                child: SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _LinePainter(
                      points: pts,
                      selected: sel,
                      line: t.accent,
                      grid: t.border,
                      label: t.textMuted,
                      surface: t.surface,
                      decimals: widget.decimals,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

const double _left = 40;
const double _pad = 12;

List<double> _xs(List<MeasurementPoint> pts, double width) {
  final w = width - _left - _pad;
  if (pts.length == 1) return [_left + w / 2];
  final t0 = pts.first.measuredAt.millisecondsSinceEpoch;
  final span = pts.last.measuredAt.millisecondsSinceEpoch - t0;
  return [
    for (final p in pts)
      _left +
          (span == 0
              ? w / 2
              : w * (p.measuredAt.millisecondsSinceEpoch - t0) / span),
  ];
}

class _LinePainter extends CustomPainter {
  _LinePainter({
    required this.points,
    required this.selected,
    required this.line,
    required this.grid,
    required this.label,
    required this.surface,
    required this.decimals,
  });

  final List<MeasurementPoint> points;
  final int selected;
  final Color line;
  final Color grid;
  final Color label;
  final Color surface;
  final int decimals;

  void _text(
    Canvas canvas,
    String s,
    Offset at, {
    bool right = false,
    bool center = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(fontSize: 11, color: label),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    var dx = at.dx;
    if (right) dx -= tp.width;
    if (center) dx -= tp.width / 2;
    tp.paint(canvas, Offset(dx, at.dy - tp.height / 2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    const top = 8.0;
    const bottom = 24.0;
    final h = size.height - top - bottom;
    var lo = points.map((p) => p.value).reduce(math.min);
    var hi = points.map((p) => p.value).reduce(math.max);
    if (hi - lo < 1e-9) {
      lo -= 1;
      hi += 1;
    } else {
      final m = (hi - lo) * 0.15;
      lo -= m;
      hi += m;
    }
    double y(double v) => top + h * (1 - (v - lo) / (hi - lo));
    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (var i = 0; i < 3; i++) {
      final v = lo + (hi - lo) * i / 2;
      final gy = y(v);
      canvas.drawLine(
        Offset(_left, gy),
        Offset(size.width - _pad, gy),
        gridPaint,
      );
      _text(
        canvas,
        v.toStringAsFixed(decimals),
        Offset(_left - 6, gy),
        right: true,
      );
    }
    final xs = _xs(points, size.width);
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final o = Offset(xs[i], y(points[i].value));
      i == 0 ? path.moveTo(o.dx, o.dy) : path.lineTo(o.dx, o.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
    for (var i = 0; i < points.length; i++) {
      final o = Offset(xs[i], y(points[i].value));
      if (i == selected) {
        canvas.drawLine(
          Offset(o.dx, top),
          Offset(o.dx, top + h),
          Paint()
            ..color = line.withValues(alpha: 0.35)
            ..strokeWidth = 1,
        );
        canvas.drawCircle(o, 7, Paint()..color = surface);
        canvas.drawCircle(o, 5.5, Paint()..color = line);
      } else {
        canvas.drawCircle(o, 5, Paint()..color = surface);
        canvas.drawCircle(o, 3.5, Paint()..color = line);
      }
    }
    final ly = size.height - 8;
    _text(
      canvas,
      _shortDate(points.first.localDate),
      Offset(xs.first.clamp(_left, size.width - 40), ly),
      center: true,
    );
    if (points.length > 1) {
      _text(
        canvas,
        _shortDate(points.last.localDate),
        Offset(xs.last.clamp(_left + 40, size.width - 24), ly),
        center: true,
      );
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) =>
      old.points != points || old.selected != selected || old.line != line;
}

/// The three separate charts: weight, BMI, and body measurements in inches.
class MetricsCharts extends ConsumerStatefulWidget {
  const MetricsCharts({super.key});

  @override
  ConsumerState<MetricsCharts> createState() => _MetricsChartsState();
}

const bodySeries = {
  MeasurementField.waistIn: 'Waist',
  MeasurementField.hipsIn: 'Hips',
  MeasurementField.chestIn: 'Chest',
  MeasurementField.armIn: 'Arm',
  MeasurementField.thighIn: 'Thigh',
};

class _MetricsChartsState extends ConsumerState<MetricsCharts> {
  MeasurementField _field = MeasurementField.waistIn;

  Widget _card(String title, IconData icon, Widget child, {Widget? header}) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SoftCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TintedIcon(icon: icon, cat: Cat.leaf, size: 36),
                const SizedBox(width: 10),
                Expanded(child: Text(title, style: text.titleMedium)),
              ],
            ),
            if (header != null) ...[const SizedBox(height: 10), header],
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weight = ref.watch(
      measurementSeriesProvider(MeasurementField.weightKg),
    );
    final bmi = ref.watch(measurementSeriesProvider(MeasurementField.bmi));
    final body = ref.watch(measurementSeriesProvider(_field));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _card(
          'Weight',
          Icons.monitor_weight_outlined,
          MetricLineChart(
            key: const ValueKey('weight'),
            points: weight.value ?? const [],
            unit: 'kg',
            name: 'Weight',
          ),
        ),
        _card(
          'BMI',
          Icons.speed_rounded,
          MetricLineChart(
            key: const ValueKey('bmi'),
            points: bmi.value ?? const [],
            unit: 'BMI',
            name: 'BMI',
          ),
        ),
        _card(
          'Body measurements',
          Icons.straighten_rounded,
          MetricLineChart(
            key: ValueKey('body-${_field.name}'),
            points: body.value ?? const [],
            unit: 'in',
            name: bodySeries[_field]!,
          ),
          header: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final e in bodySeries.entries)
                ChoiceChip(
                  label: Text(e.value),
                  selected: _field == e.key,
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  onSelected: (_) => setState(() => _field = e.key),
                ),
            ],
          ),
        ),
        Text(
          'Charts show your own entries only. Metrics are private and are '
          'never shared with groups.',
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: context.tokens.textMuted),
        ),
      ],
    );
  }
}

/// A screen holding [MetricsCharts].
class MetricsChartsScreen extends StatelessWidget {
  const MetricsChartsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Metric charts')),
    body: ListView(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        MediaQuery.paddingOf(context).bottom + 24,
      ),
      children: const [MetricsCharts()],
    ),
  );
}
