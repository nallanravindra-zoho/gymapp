import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// A round, softly tinted badge with an icon: the visual unit of the whole
/// app (quick log, summary rows, week strip, groups...).
class TintedIcon extends StatelessWidget {
  const TintedIcon({
    super.key,
    required this.icon,
    this.cat = Cat.neutral,
    this.size = 48,
    this.iconSize,
    this.tint,
    this.color,
    this.square = false,
  });

  final IconData icon;
  final Cat cat;
  final double size;
  final double? iconSize;

  /// Overrides for the category colours.
  final Color? tint;
  final Color? color;

  /// A rounded square instead of a circle (screen-time categories).
  final bool square;

  @override
  Widget build(BuildContext context) {
    final c = context.tokens.cat(cat);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tint ?? c.tint,
        shape: square ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: square ? BorderRadius.circular(size * 0.3) : null,
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: iconSize ?? size * 0.5, color: color ?? c.icon),
    );
  }
}

/// A card as in the reference: near-white surface, hairline border, a very
/// soft shadow and generously rounded corners.
class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.radius = 20,
    this.color,
    this.borderColor,
    this.shadow = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double radius;
  final Color? color;
  final Color? borderColor;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: BorderSide(color: borderColor ?? t.border),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadow && !dark
            ? const [
                BoxShadow(
                  color: Color(0x0D1B2B45),
                  blurRadius: 16,
                  offset: Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: Material(
        color: color ?? t.surface,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// A section heading with an optional trailing action ("View all").
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.trailing, this.onTrailing});

  final String title;
  final String? trailing;
  final VoidCallback? onTrailing;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        if (trailing != null)
          GestureDetector(
            onTap: onTrailing,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                trailing!,
                style: TextStyle(
                  color: t.accentDeep,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// The two- or three-way switch used under screen titles (Today | Setup,
/// Log | Wind down, Weekly | Trends...). [outlined] gives the selected pill a
/// green outline, as on Insights and Groups.
class PillTabs<T> extends StatelessWidget {
  const PillTabs({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.outlined = false,
    this.height = 46,
  });

  final Map<T, String> options;
  final T selected;
  final ValueChanged<T> onChanged;
  final bool outlined;
  final double height;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: t.track,
        borderRadius: BorderRadius.circular(height),
      ),
      child: Row(
        children: [
          for (final e in options.entries)
            Expanded(
              child: Semantics(
                button: true,
                selected: e.key == selected,
                label: e.value,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(e.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: e.key == selected ? t.accentSoft : null,
                      borderRadius: BorderRadius.circular(height),
                      border: e.key == selected && outlined
                          ? Border.all(color: t.accent, width: 1.4)
                          : null,
                    ),
                    child: ExcludeSemantics(
                      child: Text(
                        e.value,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: e.key == selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: e.key == selected ? t.accentDeep : t.text,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A filled green tick, or an empty ring when not done.
class DoneMark extends StatelessWidget {
  const DoneMark({super.key, required this.done, this.size = 26});

  final bool done;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? t.accent : Colors.transparent,
        border: done
            ? null
            : Border.all(
                color: t.textMuted.withValues(alpha: 0.45),
                width: 1.6,
              ),
      ),
      child: done
          ? Icon(Icons.check_rounded, size: size * 0.7, color: Colors.white)
          : null,
    );
  }
}

/// A thin line between list rows inside a card.
class RowDivider extends StatelessWidget {
  const RowDivider({super.key, this.indent = 0});

  final double indent;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(left: indent),
    child: Divider(height: 1, color: context.tokens.border),
  );
}

/// Watercolour hills under a pale sky with a small sun: the Today header and
/// the welcome screen. [warm] is the peach sunrise version.
class HillsHeader extends StatelessWidget {
  const HillsHeader({
    super.key,
    this.height = 230,
    this.warm = false,
    this.child,
  });

  final double height;
  final bool warm;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ExcludeSemantics(
            child: CustomPaint(
              painter: HillsPainter(
                dark: dark,
                warm: warm,
                fadeTo: context.tokens.bg,
              ),
            ),
          ),
          ?child,
        ],
      ),
    );
  }
}

class HillsPainter extends CustomPainter {
  HillsPainter({required this.dark, required this.warm, required this.fadeTo});

  final bool dark;
  final bool warm;
  final Color fadeTo;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;

    // Sky.
    final skyTop = dark
        ? const Color(0xFF1B2A2C)
        : warm
        ? const Color(0xFFFCEBD3)
        : const Color(0xFFE6F1F3);
    final skyBottom = dark
        ? const Color(0xFF1A2220)
        : warm
        ? const Color(0xFFFBF1E1)
        : const Color(0xFFF2F6F1);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [skyTop, skyBottom],
        ).createShader(rect),
    );

    // Sun.
    final sun = Offset(w * 0.73, h * 0.17);
    canvas.drawCircle(
      sun,
      30,
      Paint()
        ..color = (dark ? const Color(0xFFE9B567) : const Color(0xFFF8CE92))
            .withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
    canvas.drawCircle(
      sun,
      15,
      Paint()..color = dark ? const Color(0xFFD9A55A) : const Color(0xFFF9D79C),
    );

    Path ridge(List<double> pts, double base) {
      // pts: alternating x fractions and y fractions of the height.
      final p = Path()..moveTo(0, h);
      p.lineTo(0, h * pts[1]);
      for (var i = 2; i < pts.length; i += 4) {
        p.cubicTo(
          w * pts[i],
          h * pts[i + 1],
          w * pts[i + 2],
          h * pts[i + 3],
          w * pts[i + 4],
          h * pts[i + 5],
        );
        i += 2;
      }
      p
        ..lineTo(w, h)
        ..close();
      return p;
    }

    Color layer(Color light, Color deep, double a) =>
        (dark ? deep : light).withValues(alpha: a);

    final back = layer(
      warm ? const Color(0xFFC8D5DB) : const Color(0xFFBBD3D8),
      const Color(0xFF314540),
      0.75,
    );
    final mid = layer(
      warm ? const Color(0xFFAFC9CB) : const Color(0xFF9BC2BC),
      const Color(0xFF2B4A41),
      0.85,
    );
    final front = layer(
      warm ? const Color(0xFFE9D9A8) : const Color(0xFF86B8A1),
      const Color(0xFF244238),
      0.95,
    );
    final nearest = layer(
      warm ? const Color(0xFFD3C58E) : const Color(0xFF5F9C86),
      const Color(0xFF1D372F),
      1,
    );

    // Far, pale mountains.
    canvas.drawPath(
      ridge([
        0,
        0.66,
        0.08,
        0.50,
        0.14,
        0.44,
        0.24,
        0.58,
        0.34,
        0.46,
        0.42,
        0.36,
        0.52,
        0.50,
        0.62,
        0.34,
        0.74,
        0.26,
        0.84,
        0.44,
        0.92,
        0.36,
        0.97,
        0.38,
        1.0,
        0.44,
      ], 0),
      Paint()..color = back,
    );
    // Middle hills.
    canvas.drawPath(
      ridge([
        0,
        0.74,
        0.15,
        0.58,
        0.28,
        0.60,
        0.40,
        0.72,
        0.52,
        0.60,
        0.64,
        0.52,
        0.76,
        0.64,
        0.86,
        0.50,
        0.94,
        0.48,
        1.0,
        0.56,
        1.0,
        0.56,
        1.0,
        0.56,
        1.0,
        0.56,
      ], 0),
      Paint()..color = mid,
    );
    // Front slope.
    canvas.drawPath(
      ridge([
        0,
        0.82,
        0.20,
        0.74,
        0.40,
        0.84,
        0.60,
        0.80,
        0.78,
        0.70,
        0.90,
        0.66,
        1.0,
        0.72,
        1.0,
        0.72,
        1.0,
        0.72,
        1.0,
        0.72,
      ], 0),
      Paint()..color = front,
    );
    // A darker edge of trees on the right.
    final trees = Path()..moveTo(w * 0.62, h * 0.84);
    var x = w * 0.62;
    final rnd = math.Random(7);
    while (x < w) {
      final tw = 7 + rnd.nextDouble() * 7;
      final th = 10 + rnd.nextDouble() * 12;
      trees.lineTo(x + tw / 2, h * 0.80 - th);
      trees.lineTo(x + tw, h * 0.80);
      x += tw;
    }
    trees
      ..lineTo(w, h)
      ..lineTo(w * 0.62, h)
      ..close();
    canvas.drawPath(trees, Paint()..color = nearest.withValues(alpha: 0.55));

    // Fade into the page.
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.62, w, h * 0.38),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [fadeTo.withValues(alpha: 0), fadeTo],
        ).createShader(Rect.fromLTWH(0, h * 0.62, w, h * 0.38)),
    );
  }

  @override
  bool shouldRepaint(HillsPainter old) =>
      old.dark != dark || old.warm != warm || old.fadeTo != fadeTo;
}

/// A small three-leaf sprout, the app's symbol for growth (timer card,
/// healthy-habits banner, daily summary).
class SproutIcon extends StatelessWidget {
  const SproutIcon({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(
      size: Size.square(size),
      painter: _SproutPainter(Theme.of(context).brightness == Brightness.dark),
    ),
  );
}

class _SproutPainter extends CustomPainter {
  _SproutPainter(this.dark);
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final deep = dark ? const Color(0xFF6CC3A3) : const Color(0xFF2F8467);
    final mid = dark ? const Color(0xFF58AE90) : const Color(0xFF4FA682);
    final light = dark ? const Color(0xFF4A9A80) : const Color(0xFF7CC2A3);

    // Ground shadow.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(s * 0.5, s * 0.93),
        width: s * 0.5,
        height: s * 0.09,
      ),
      Paint()..color = deep.withValues(alpha: 0.18),
    );

    // Stem.
    final stem = Path()
      ..moveTo(s * 0.5, s * 0.92)
      ..cubicTo(s * 0.5, s * 0.70, s * 0.48, s * 0.55, s * 0.5, s * 0.30);
    canvas.drawPath(
      stem,
      Paint()
        ..color = deep
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.05
        ..strokeCap = StrokeCap.round,
    );

    Path leaf(Offset base, double length, double width, double angle) {
      canvas.save();
      final p = Path()
        ..moveTo(0, 0)
        ..cubicTo(width, -length * 0.25, width, -length * 0.8, 0, -length)
        ..cubicTo(-width, -length * 0.8, -width, -length * 0.25, 0, 0);
      final m = Matrix4.identity()
        ..translateByDouble(base.dx, base.dy, 0, 1)
        ..rotateZ(angle);
      canvas.restore();
      return p.transform(m.storage);
    }

    // Left and right leaves, then the top leaf.
    canvas.drawPath(
      leaf(Offset(s * 0.49, s * 0.62), s * 0.36, s * 0.16, -1.05),
      Paint()..color = light,
    );
    canvas.drawPath(
      leaf(Offset(s * 0.5, s * 0.55), s * 0.40, s * 0.17, 1.0),
      Paint()..color = mid,
    );
    canvas.drawPath(
      leaf(Offset(s * 0.5, s * 0.36), s * 0.34, s * 0.15, 0.0),
      Paint()..color = deep,
    );
  }

  @override
  bool shouldRepaint(_SproutPainter old) => old.dark != dark;
}
