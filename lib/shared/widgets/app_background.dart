import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_colors.dart';

/// The visual style of the background.
///
/// Each variant creates a distinct premium atmosphere:
/// - [plain] — Theme scaffold color, no decoration.
/// - [subtle] — Gentle radial glow, ideal for content-heavy screens.
/// - [gradient] — Smooth multi-stop linear gradient.
/// - [mesh] — Layered radial gradients simulating a mesh-gradient.
/// - [aurora] — Animated, multi-color organic blobs (glassmorphism hero).
/// - [grid] — Subtle dot-grid / graph-paper pattern overlay.
/// - [particles] — Floating translucent orbs with slow drift animation.
/// - [radialSpotlight] — A single large radial highlight from a corner.
/// - [editorial] — Split-tone background (top dark, bottom surface).
enum BackgroundStyle {
  plain,
  subtle,
  gradient,
  mesh,
  aurora,
  grid,
  particles,
  radialSpotlight,
  editorial,
}

/// A premium, fully-themed background wrapper used across the entire app.
///
/// ### Features
/// - **9 distinct visual styles** — from minimal `plain` to immersive `aurora`.
/// - **Full light/dark theme awareness** — every style adapts automatically.
/// - **Optional noise overlay** — adds film-grain texture for depth.
/// - **Optional vignette** — darkens edges to focus attention.
/// - **Custom color overrides** — supply your own colors per instance.
/// - **Animated variants** — `aurora` and `particles` include subtle motion.
/// - **Safe-area aware** — the child respects system insets by default.
/// - **Performance-conscious** — uses `RepaintBoundary` and avoids
///   unnecessary rebuilds via `const` constructors where possible.
///
/// ### Usage
/// ```dart
/// AppBackground(
///   style: BackgroundStyle.aurora,
///   showNoise: true,
///   child: MyPageContent(),
/// )
/// ```
class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    required this.child,
    this.style = BackgroundStyle.subtle,
    this.showNoise = false,
    this.showVignette = false,
    this.applySafeArea = true,
    this.primaryColor,
    this.secondaryColor,
    this.accentColor,
    this.opacity = 1.0,
    this.padding,
  });

  /// The content rendered on top of the background.
  final Widget child;

  /// Visual style of the background layer.
  final BackgroundStyle style;

  /// When `true`, a fine noise / grain overlay is drawn for tactile depth.
  final bool showNoise;

  /// When `true`, edges are darkened with a radial vignette.
  final bool showVignette;

  /// Wraps [child] in a [SafeArea] when `true` (default).
  final bool applySafeArea;

  /// Override the primary tint color (defaults to theme primary).
  final Color? primaryColor;

  /// Override the secondary tint color (defaults to theme secondary).
  final Color? secondaryColor;

  /// Override the accent tint color (defaults to theme tertiary/accent).
  final Color? accentColor;

  /// Master opacity applied to the decorative layer (0.0 – 1.0).
  final double opacity;

  /// Optional padding applied around [child].
  final EdgeInsetsGeometry? padding;

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Color _primary(ThemeData t) => primaryColor ?? t.colorScheme.primary;
  Color _secondary(ThemeData t) => secondaryColor ?? t.colorScheme.secondary;
  Color _accent(ThemeData t) => accentColor ?? (t.colorScheme.tertiary);
  bool _isDark(ThemeData t) => t.brightness == Brightness.dark;
  Color _bg(ThemeData t) =>
      _isDark(t) ? AppColors.backgroundDark : AppColors.backgroundLight;
  Color _surface(ThemeData t) =>
      _isDark(t) ? AppColors.surfaceDark : AppColors.surfaceLight;

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = padding != null
        ? Padding(padding: padding!, child: child)
        : child;
    final safeChild = applySafeArea ? SafeArea(child: content) : content;

    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Base color fill — always present.
          ColoredBox(color: _bg(theme)),

          // 2. Style-specific decorative layer.
          Opacity(
            opacity: opacity,
            child: _buildDecoration(theme),
          ),

          // 3. Optional noise.
          if (showNoise) const _NoiseOverlay(),

          // 4. Optional vignette.
          if (showVignette) _Vignette(isDark: _isDark(theme)),

          // 5. Foreground child.
          safeChild,
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Decoration factory
  // ---------------------------------------------------------------------------

  Widget _buildDecoration(ThemeData theme) {
    switch (style) {
      case BackgroundStyle.plain:
        return const SizedBox.shrink();

      case BackgroundStyle.subtle:
        return _SubtleGlow(
          color: _primary(theme),
          isDark: _isDark(theme),
        );

      case BackgroundStyle.gradient:
        return _LinearGradientBg(
          primary: _primary(theme),
          secondary: _secondary(theme),
          isDark: _isDark(theme),
        );

      case BackgroundStyle.mesh:
        return _MeshGradient(
          primary: _primary(theme),
          secondary: _secondary(theme),
          accent: _accent(theme),
          isDark: _isDark(theme),
        );

      case BackgroundStyle.aurora:
        return _AuroraBg(
          primary: _primary(theme),
          secondary: _secondary(theme),
          accent: _accent(theme),
          isDark: _isDark(theme),
        );

      case BackgroundStyle.grid:
        return _GridPattern(isDark: _isDark(theme));

      case BackgroundStyle.particles:
        return _FloatingParticles(
          primary: _primary(theme),
          secondary: _secondary(theme),
          accent: _accent(theme),
          isDark: _isDark(theme),
        );

      case BackgroundStyle.radialSpotlight:
        return _RadialSpotlight(
          color: _primary(theme),
          isDark: _isDark(theme),
        );

      case BackgroundStyle.editorial:
        return _EditorialSplit(
          surface: _surface(theme),
          primary: _primary(theme),
          isDark: _isDark(theme),
        );
    }
  }
}

// =============================================================================
//  BACKGROUND STYLE IMPLEMENTATIONS
// =============================================================================

/// A single, soft radial glow anchored near the top-center.
class _SubtleGlow extends StatelessWidget {
  const _SubtleGlow({required this.color, required this.isDark});
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.0, -0.6),
            radius: 1.4,
            colors: [
              color.withValues(alpha: isDark ? 0.12 : 0.06),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

/// Smooth linear gradient from top-left to bottom-right.
class _LinearGradientBg extends StatelessWidget {
  const _LinearGradientBg({
    required this.primary,
    required this.secondary,
    required this.isDark,
  });
  final Color primary;
  final Color secondary;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.5, 1.0],
          colors: [
            primary.withValues(alpha: isDark ? 0.15 : 0.06),
            Colors.transparent,
            secondary.withValues(alpha: isDark ? 0.12 : 0.05),
          ],
        ),
      ),
    );
  }
}

/// Layered radial gradients to simulate a modern mesh-gradient look.
class _MeshGradient extends StatelessWidget {
  const _MeshGradient({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.isDark,
  });
  final Color primary;
  final Color secondary;
  final Color accent;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final double a = isDark ? 0.18 : 0.08;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Top-left blob
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-1.0, -1.0),
              radius: 1.6,
              colors: [
                primary.withValues(alpha: a),
                Colors.transparent,
              ],
            ),
          ),
        ),
        // Center-right blob
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(1.2, 0.0),
              radius: 1.3,
              colors: [
                secondary.withValues(alpha: a * 0.8),
                Colors.transparent,
              ],
            ),
          ),
        ),
        // Bottom-center blob
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.0, 1.2),
              radius: 1.4,
              colors: [
                accent.withValues(alpha: a * 0.7),
                Colors.transparent,
              ],
            ),
          ),
        ),
        // Top-right accent whisper
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.8, -0.8),
              radius: 0.9,
              colors: [
                accent.withValues(alpha: a * 0.5),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Animated organic blobs that drift slowly — the signature premium look.
class _AuroraBg extends StatelessWidget {
  const _AuroraBg({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.isDark,
  });
  final Color primary;
  final Color secondary;
  final Color accent;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final double base = isDark ? 0.25 : 0.10;

    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Blob 1 — top-left, large, primary
          _AnimatedBlob(
            color: primary.withValues(alpha: base),
            alignment: const Alignment(-1.2, -1.0),
            radius: 1.8,
            durationSeconds: 18,
            endAlignment: const Alignment(-0.6, -0.3),
          ),
          // Blob 2 — center-right, secondary
          _AnimatedBlob(
            color: secondary.withValues(alpha: base * 0.8),
            alignment: const Alignment(1.0, 0.2),
            radius: 1.4,
            durationSeconds: 22,
            endAlignment: const Alignment(0.5, 0.6),
          ),
          // Blob 3 — bottom-left, accent
          _AnimatedBlob(
            color: accent.withValues(alpha: base * 0.7),
            alignment: const Alignment(-0.5, 1.2),
            radius: 1.2,
            durationSeconds: 20,
            endAlignment: const Alignment(0.2, 0.8),
          ),
          // Blob 4 — subtle top-right accent highlight
          _AnimatedBlob(
            color: accent.withValues(alpha: base * 0.4),
            alignment: const Alignment(0.9, -1.0),
            radius: 1.0,
            durationSeconds: 25,
            endAlignment: const Alignment(1.2, -0.5),
          ),
          // Frosted layer — blurs the blobs into smooth aurora
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }
}

/// A single animated radial-gradient blob used by [_AuroraBg].
class _AnimatedBlob extends StatelessWidget {
  const _AnimatedBlob({
    required this.color,
    required this.alignment,
    required this.endAlignment,
    required this.radius,
    required this.durationSeconds,
  });
  final Color color;
  final Alignment alignment;
  final Alignment endAlignment;
  final double radius;
  final int durationSeconds;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: alignment,
            radius: radius,
            colors: [color, Colors.transparent],
          ),
        ),
      ),
    )
        .animate(
          onPlay: (c) => c.repeat(reverse: true),
        )
        .moveX(
          begin: 0,
          end: (endAlignment.x - alignment.x) * 80,
          duration: Duration(seconds: durationSeconds),
          curve: Curves.easeInOutSine,
        )
        .moveY(
          begin: 0,
          end: (endAlignment.y - alignment.y) * 80,
          duration: Duration(seconds: (durationSeconds * 1.3).round()),
          curve: Curves.easeInOutSine,
        );
  }
}

/// A subtle dot-grid or cross-hatch pattern overlay — modern editorial feel.
class _GridPattern extends StatelessWidget {
  const _GridPattern({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _GridPainter(
          color: isDark
              ? Colors.white.withValues(alpha: 0.03)
              : Colors.black.withValues(alpha: 0.03),
          spacing: 28,
          dotRadius: 1.0,
        ),
      ),
    );
  }
}

/// Custom painter that draws a regular dot grid.
class _GridPainter extends CustomPainter {
  _GridPainter({
    required this.color,
    required this.spacing,
    required this.dotRadius,
  });

  final Color color;
  final double spacing;
  final double dotRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) =>
      color != old.color || spacing != old.spacing || dotRadius != old.dotRadius;
}

/// Floating translucent orbs drifting gently across the viewport.
class _FloatingParticles extends StatelessWidget {
  const _FloatingParticles({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.isDark,
  });
  final Color primary;
  final Color secondary;
  final Color accent;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final base = isDark ? 0.12 : 0.06;
    final colors = [primary, secondary, accent];

    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: List.generate(8, (i) {
          final rng = math.Random(i * 42);
          final color = colors[i % colors.length].withValues(alpha: base + rng.nextDouble() * 0.04);
          final size = 60.0 + rng.nextDouble() * 140;
          final left = rng.nextDouble();
          final top = rng.nextDouble();
          final duration = 12 + rng.nextInt(18);

          return Positioned(
            left: left * 400 - size / 2,
            top: top * 800 - size / 2,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [color, Colors.transparent],
                ),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveX(
                  begin: 0,
                  end: (rng.nextDouble() - 0.5) * 100,
                  duration: Duration(seconds: duration),
                  curve: Curves.easeInOutSine,
                )
                .moveY(
                  begin: 0,
                  end: (rng.nextDouble() - 0.5) * 100,
                  duration: Duration(seconds: (duration * 1.2).round()),
                  curve: Curves.easeInOutSine,
                )
                .fadeIn(duration: 2.seconds),
          );
        }),
      ),
    );
  }
}

/// A large radial highlight from the top-right corner — dramatic, clean.
class _RadialSpotlight extends StatelessWidget {
  const _RadialSpotlight({required this.color, required this.isDark});
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(1.2, -1.0),
          radius: 2.0,
          colors: [
            color.withValues(alpha: isDark ? 0.20 : 0.08),
            color.withValues(alpha: isDark ? 0.06 : 0.02),
            Colors.transparent,
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
      ),
    );
  }
}

/// Editorial split-tone: darker top section fading into surface color.
class _EditorialSplit extends StatelessWidget {
  const _EditorialSplit({
    required this.surface,
    required this.primary,
    required this.isDark,
  });
  final Color surface;
  final Color primary;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.35, 0.65, 1.0],
          colors: [
            primary.withValues(alpha: isDark ? 0.25 : 0.08),
            primary.withValues(alpha: isDark ? 0.10 : 0.03),
            Colors.transparent,
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

// =============================================================================
//  OVERLAY EFFECTS
// =============================================================================

/// A film-grain / noise overlay for tactile depth.
///
/// Uses a [CustomPainter] to scatter micro-dots at varying opacities.
class _NoiseOverlay extends StatelessWidget {
  const _NoiseOverlay();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IgnorePointer(
      child: Opacity(
        opacity: isDark ? 0.06 : 0.04,
        child: CustomPaint(
          size: Size.infinite,
          painter: _NoisePainter(
            baseColor: isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

/// Paints random noise dots — keeps a seed so it stays stable across frames.
class _NoisePainter extends CustomPainter {
  _NoisePainter({required this.baseColor});
  final Color baseColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(12345); // fixed seed for deterministic grain
    final paint = Paint()..style = PaintingStyle.fill;
    final count = (size.width * size.height / 120).clamp(0, 8000).toInt();

    for (int i = 0; i < count; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      paint.color = baseColor.withValues(alpha: rng.nextDouble() * 0.3);
      canvas.drawCircle(Offset(x, y), 0.6 + rng.nextDouble() * 0.4, paint);
    }
  }

  @override
  bool shouldRepaint(_NoisePainter old) => baseColor != old.baseColor;
}

/// Radial vignette — darkens the edges to draw attention to the center.
class _Vignette extends StatelessWidget {
  const _Vignette({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.1,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: isDark ? 0.35 : 0.10),
            ],
            stops: const [0.55, 1.0],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
//  CONVENIENCE CONSTRUCTORS — FACTORY HELPERS
// =============================================================================

/// Pre-configured background shortcuts for common pages.
///
/// ```dart
/// AppBackgrounds.auth(child: LoginForm());
/// AppBackgrounds.dashboard(child: DashboardBody());
/// ```
abstract final class AppBackgrounds {
  /// Auth screens (login, register, forgot-password) — aurora + vignette.
  static Widget auth({required Widget child}) => AppBackground(
        style: BackgroundStyle.aurora,
        showVignette: true,
        showNoise: true,
        child: child,
      );

  /// Onboarding pages — mesh gradient with noise.
  static Widget onboarding({required Widget child}) => AppBackground(
        style: BackgroundStyle.mesh,
        showNoise: true,
        child: child,
      );

  /// Dashboard / home — subtle radial glow, unobtrusive.
  static Widget dashboard({required Widget child}) => AppBackground(
        style: BackgroundStyle.subtle,
        child: child,
      );

  /// Detail / read-heavy screens — plain with optional grid.
  static Widget detail({required Widget child, bool showGrid = false}) =>
      AppBackground(
        style: showGrid ? BackgroundStyle.grid : BackgroundStyle.plain,
        child: child,
      );

  /// Splash / hero screens — particles with vignette.
  static Widget splash({required Widget child}) => AppBackground(
        style: BackgroundStyle.particles,
        showVignette: true,
        showNoise: true,
        child: child,
      );

  /// Settings / editorial pages — editorial split-tone.
  static Widget editorial({required Widget child}) => AppBackground(
        style: BackgroundStyle.editorial,
        child: child,
      );

  /// Reports / analytics — spotlight from top-right + grid.
  static Widget reports({required Widget child}) => AppBackground(
        style: BackgroundStyle.radialSpotlight,
        showNoise: true,
        child: child,
      );
}
