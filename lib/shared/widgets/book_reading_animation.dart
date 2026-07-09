import 'dart:math';
import 'package:flutter/material.dart';

/// A fully animated, high-class illustration of a girl taking a book
/// from a stack and sitting down to read it. Built entirely with
/// Flutter's painting and animation APIs — no external assets needed.
///
/// The animation runs through 4 phases:
///  1. Books stack assembles (books slide in)
///  2. Character appears and reaches for top book
///  3. Character takes the book and transitions to sitting pose
///  4. Reading loop with page-turning, floating particles, and glow
class BookReadingAnimation extends StatefulWidget {
  const BookReadingAnimation({
    super.key,
    this.size = const Size(320, 320),
    this.showParticles = true,
    this.autoStart = true,
    this.primaryColor,
    this.accentColor,
  });

  final Size size;
  final bool showParticles;
  final bool autoStart;
  final Color? primaryColor;
  final Color? accentColor;

  @override
  State<BookReadingAnimation> createState() => _BookReadingAnimationState();
}

class _BookReadingAnimationState extends State<BookReadingAnimation>
    with TickerProviderStateMixin {
  // Phase 1: Stack assembly
  late AnimationController _stackController;
  // Phase 2: Character appear + reach
  late AnimationController _reachController;
  // Phase 3: Take book + sit
  late AnimationController _sitController;
  // Phase 4: Reading loop (page turn + breathing)
  late AnimationController _readController;
  // Particle system
  late AnimationController _particleController;

  // Derived animations
  late Animation<double> _stackAnim;
  late Animation<double> _reachAnim;
  late Animation<double> _sitAnim;
  late Animation<double> _readAnim;
  late Animation<double> _particleAnim;

  final List<_Particle> _particles = [];
  final Random _rng = Random(42);

  @override
  void initState() {
    super.initState();

    _stackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _reachController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _sitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _readController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    );

    _stackAnim = CurvedAnimation(
      parent: _stackController,
      curve: Curves.easeOutBack,
    );
    _reachAnim = CurvedAnimation(
      parent: _reachController,
      curve: Curves.easeInOutCubic,
    );
    _sitAnim = CurvedAnimation(
      parent: _sitController,
      curve: Curves.easeInOutCubic,
    );
    _readAnim = CurvedAnimation(
      parent: _readController,
      curve: Curves.linear,
    );
    _particleAnim = CurvedAnimation(
      parent: _particleController,
      curve: Curves.linear,
    );

    // Generate particles
    for (int i = 0; i < 18; i++) {
      _particles.add(_Particle(
        x: _rng.nextDouble(),
        y: _rng.nextDouble(),
        size: _rng.nextDouble() * 4 + 2,
        speed: _rng.nextDouble() * 0.3 + 0.1,
        opacity: _rng.nextDouble() * 0.6 + 0.2,
        phase: _rng.nextDouble() * pi * 2,
      ));
    }

    // Chain animations
    _stackController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _reachController.forward();
      }
    });
    _reachController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _sitController.forward();
      }
    });
    _sitController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _readController.repeat();
        _particleController.repeat();
      }
    });

    if (widget.autoStart) {
      _stackController.forward();
    }
  }

  @override
  void dispose() {
    _stackController.dispose();
    _reachController.dispose();
    _sitController.dispose();
    _readController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = widget.primaryColor ?? const Color(0xFF6366F1);
    final accent = widget.accentColor ?? const Color(0xFF10B981);

    return AnimatedBuilder(
      animation: Listenable.merge([
        _stackAnim,
        _reachAnim,
        _sitAnim,
        _readAnim,
        _particleAnim,
      ]),
      builder: (context, _) {
        return CustomPaint(
          size: widget.size,
          painter: _BookReadingPainter(
            stackProgress: _stackAnim.value,
            reachProgress: _reachAnim.value,
            sitProgress: _sitAnim.value,
            readProgress: _readAnim.value,
            particleProgress: _particleAnim.value,
            particles: widget.showParticles ? _particles : [],
            primaryColor: primary,
            accentColor: accent,
          ),
        );
      },
    );
  }
}

class _Particle {
  final double x, y, size, speed, opacity, phase;
  const _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.phase,
  });
}

class _BookReadingPainter extends CustomPainter {
  final double stackProgress;
  final double reachProgress;
  final double sitProgress;
  final double readProgress;
  final double particleProgress;
  final List<_Particle> particles;
  final Color primaryColor;
  final Color accentColor;

  _BookReadingPainter({
    required this.stackProgress,
    required this.reachProgress,
    required this.sitProgress,
    required this.readProgress,
    required this.particleProgress,
    required this.particles,
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    // Draw ground shadow
    _drawGroundShadow(canvas, w, h);

    // Draw book stack
    _drawBookStack(canvas, w, h);

    // Draw character
    _drawCharacter(canvas, w, h, cx);

    // Draw held/reading book
    _drawHeldBook(canvas, w, h, cx);

    // Draw floating particles (sparkles)
    if (particles.isNotEmpty && sitProgress >= 1.0) {
      _drawParticles(canvas, w, h);
    }

    // Draw reading glow
    if (sitProgress >= 1.0) {
      _drawReadingGlow(canvas, w, h, cx);
    }
  }

  void _drawGroundShadow(Canvas canvas, double w, double h) {
    final groundY = h * 0.88;
    final shadowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.black.withValues(alpha: 0.12 * stackProgress),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCenter(
        center: Offset(w * 0.5, groundY),
        width: w * 0.8,
        height: h * 0.08,
      ));
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, groundY),
        width: w * 0.8 * stackProgress,
        height: h * 0.06,
      ),
      shadowPaint,
    );
  }

  void _drawBookStack(Canvas canvas, double w, double h) {
    final bookColors = [
      const Color(0xFFDC2626), // Red
      const Color(0xFFF59E0B), // Amber
      const Color(0xFF10B981), // Green
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFFEC4899), // Pink (top - the one she takes)
    ];

    final bookW = w * 0.28;
    final bookH = h * 0.055;
    final stackX = w * 0.30;
    final stackBaseY = h * 0.82;

    for (int i = 0; i < bookColors.length; i++) {
      // Stagger entry
      final entryDelay = i / bookColors.length;
      final bookProgress = ((stackProgress - entryDelay * 0.5) / 0.5).clamp(0.0, 1.0);

      if (bookProgress <= 0) continue;

      // The top book (index 5) lifts away when character takes it
      final isTopBook = i == bookColors.length - 1;
      double offsetX = 0;
      double offsetY = 0;
      double opacity = 1.0;

      if (isTopBook && reachProgress > 0.5) {
        final liftT = ((reachProgress - 0.5) / 0.5).clamp(0.0, 1.0);
        offsetY = -liftT * h * 0.15;
        offsetX = liftT * w * 0.15;
        opacity = 1.0 - sitProgress * 0.0; // stays visible until sit
      }
      if (isTopBook && sitProgress > 0) {
        opacity = 1.0 - sitProgress; // fades as character sits with it
      }

      final bx = stackX - bookW / 2 + (i % 2 == 0 ? 0 : w * 0.02) + offsetX;
      final by = stackBaseY - (i * (bookH + 3)) - bookProgress * 0 + offsetY;
      final slideFrom = (i % 2 == 0) ? -w * 0.5 : w * 0.5;
      final actualX = bx + slideFrom * (1 - bookProgress);

      // Book body
      final bookRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(actualX, by, bookW, bookH),
        const Radius.circular(3),
      );

      // Shadow
      canvas.drawRRect(
        bookRect.shift(const Offset(2, 2)),
        Paint()..color = Colors.black.withValues(alpha: 0.1 * bookProgress),
      );

      // Book fill
      canvas.drawRRect(
        bookRect,
        Paint()..color = bookColors[i].withValues(alpha: opacity * bookProgress),
      );

      // Book spine highlight
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(actualX, by, bookW * 0.08, bookH),
          const Radius.circular(3),
        ),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.3 * opacity * bookProgress),
      );

      // Book edge lines
      final linePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.15 * opacity * bookProgress)
        ..strokeWidth = 0.5;
      for (int l = 1; l < 4; l++) {
        final lx = actualX + bookW * 0.15 + (bookW * 0.7 / 4) * l;
        canvas.drawLine(
          Offset(lx, by + 3),
          Offset(lx, by + bookH - 3),
          linePaint,
        );
      }
    }
  }

  void _drawCharacter(Canvas canvas, double w, double h, double cx) {
    if (reachProgress <= 0 && stackProgress < 0.8) return;

    final charAppear = stackProgress >= 0.8
        ? ((stackProgress - 0.8) / 0.2).clamp(0.0, 1.0)
        : 0.0;
    final appear = reachProgress > 0 ? 1.0 : charAppear;
    if (appear <= 0) return;

    // Character positioning phases:
    // Phase 1 (reach=0→1): Standing next to stack, reaching up
    // Phase 2 (sit=0→1): Transition to sitting on the right side reading

    // Head position
    final standX = w * 0.52;
    final standHeadY = h * 0.38;
    final sitX = w * 0.62;
    final sitHeadY = h * 0.52;

    final headX = _lerp(standX, sitX, sitProgress);
    final headY = _lerp(standHeadY, sitHeadY, sitProgress);
    final headR = w * 0.055;

    // Hair color (dark brown/maroon like the reference)
    const hairColor = Color(0xFF6B2137);
    const skinColor = Color(0xFFF5D0B0);
    final shirtColor = primaryColor;
    const skirtColor = Color(0xFF1E3A5F);

    // -- HEAD --
    // Hair back (behind head)
    canvas.drawCircle(
      Offset(headX, headY - headR * 0.1),
      headR * 1.15,
      Paint()..color = hairColor.withValues(alpha: appear),
    );

    // Face
    canvas.drawCircle(
      Offset(headX, headY),
      headR,
      Paint()..color = skinColor.withValues(alpha: appear),
    );

    // Hair front (bangs)
    final hairPath = Path();
    hairPath.moveTo(headX - headR * 0.9, headY - headR * 0.3);
    hairPath.quadraticBezierTo(
      headX - headR * 0.5, headY - headR * 1.5,
      headX + headR * 0.1, headY - headR * 1.1,
    );
    hairPath.quadraticBezierTo(
      headX + headR * 0.7, headY - headR * 1.4,
      headX + headR * 0.9, headY - headR * 0.3,
    );
    hairPath.quadraticBezierTo(
      headX + headR * 0.6, headY - headR * 0.7,
      headX, headY - headR * 0.8,
    );
    hairPath.quadraticBezierTo(
      headX - headR * 0.6, headY - headR * 0.7,
      headX - headR * 0.9, headY - headR * 0.3,
    );
    canvas.drawPath(
      hairPath,
      Paint()..color = hairColor.withValues(alpha: appear),
    );

    // Eyes
    final eyeY = headY + headR * 0.05;
    final lookDown = sitProgress; // looks down when reading
    canvas.drawCircle(
      Offset(headX - headR * 0.3, eyeY + lookDown * headR * 0.1),
      headR * 0.1,
      Paint()..color = const Color(0xFF2D1B14).withValues(alpha: appear),
    );
    canvas.drawCircle(
      Offset(headX + headR * 0.3, eyeY + lookDown * headR * 0.1),
      headR * 0.1,
      Paint()..color = const Color(0xFF2D1B14).withValues(alpha: appear),
    );

    // Eye shine
    canvas.drawCircle(
      Offset(headX - headR * 0.25, eyeY - headR * 0.02 + lookDown * headR * 0.1),
      headR * 0.035,
      Paint()..color = Colors.white.withValues(alpha: appear * 0.8),
    );
    canvas.drawCircle(
      Offset(headX + headR * 0.35, eyeY - headR * 0.02 + lookDown * headR * 0.1),
      headR * 0.035,
      Paint()..color = Colors.white.withValues(alpha: appear * 0.8),
    );

    // Blush (cute cheeks)
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(headX - headR * 0.55, eyeY + headR * 0.25),
        width: headR * 0.35,
        height: headR * 0.2,
      ),
      Paint()..color = const Color(0xFFE8A0A0).withValues(alpha: appear * 0.5),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(headX + headR * 0.55, eyeY + headR * 0.25),
        width: headR * 0.35,
        height: headR * 0.2,
      ),
      Paint()..color = const Color(0xFFE8A0A0).withValues(alpha: appear * 0.5),
    );

    // Smile
    final smilePath = Path();
    final smileY = headY + headR * 0.35;
    smilePath.moveTo(headX - headR * 0.2, smileY);
    smilePath.quadraticBezierTo(
      headX, smileY + headR * 0.15,
      headX + headR * 0.2, smileY,
    );
    canvas.drawPath(
      smilePath,
      Paint()
        ..color = const Color(0xFF8B4513).withValues(alpha: appear)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );

    // -- BODY --
    final neckY = headY + headR;
    final bodyTopY = neckY + h * 0.01;

    // Neck
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(headX, neckY + h * 0.005),
        width: headR * 0.5,
        height: h * 0.02,
      ),
      Paint()..color = skinColor.withValues(alpha: appear),
    );

    // Torso (shirt)
    final torsoH = h * 0.12;
    final shoulderW = headR * 2.2;

    final torsoPaint = Paint()..color = shirtColor.withValues(alpha: appear);
    final torsoPath = Path();
    torsoPath.moveTo(headX - shoulderW / 2, bodyTopY);
    torsoPath.lineTo(headX + shoulderW / 2, bodyTopY);
    torsoPath.lineTo(headX + shoulderW * 0.4, bodyTopY + torsoH);
    torsoPath.lineTo(headX - shoulderW * 0.4, bodyTopY + torsoH);
    torsoPath.close();
    canvas.drawPath(torsoPath, torsoPaint);

    // -- ARMS --
    final armPaint = Paint()
      ..color = skinColor.withValues(alpha: appear)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.025
      ..strokeCap = StrokeCap.round;

    // Arm animation
    if (sitProgress < 1.0) {
      // Reaching phase: right arm reaches up
      final armReach = reachProgress;
      final rShoulderX = headX + shoulderW / 2 - w * 0.02;
      final rShoulderY = bodyTopY + h * 0.02;

      // Right arm reaching up toward top of stack
      final targetX = w * 0.36;
      final targetY = h * 0.38;
      final elbowX = _lerp(rShoulderX + w * 0.03, rShoulderX - w * 0.05, armReach);
      final elbowY = _lerp(rShoulderY + h * 0.06, rShoulderY - h * 0.02, armReach);
      final handX = _lerp(rShoulderX + w * 0.05, targetX, armReach);
      final handY = _lerp(rShoulderY + h * 0.1, targetY, armReach);

      final armPath = Path();
      armPath.moveTo(rShoulderX, rShoulderY);
      armPath.quadraticBezierTo(elbowX, elbowY, handX, handY);
      canvas.drawPath(armPath, armPaint);

      // Left arm resting
      final lShoulderX = headX - shoulderW / 2 + w * 0.02;
      final lShoulderY = bodyTopY + h * 0.02;
      final lArmPath = Path();
      lArmPath.moveTo(lShoulderX, lShoulderY);
      lArmPath.quadraticBezierTo(
        lShoulderX - w * 0.04, lShoulderY + h * 0.06,
        lShoulderX - w * 0.01, lShoulderY + h * 0.1,
      );
      canvas.drawPath(lArmPath, armPaint);

      // Hand at target (small circle)
      if (armReach > 0.5) {
        canvas.drawCircle(
          Offset(handX, handY),
          w * 0.015,
          Paint()..color = skinColor.withValues(alpha: appear),
        );
      }
    } else {
      // Reading pose: both arms holding book
      final bookCenterX = headX - w * 0.02;
      final bookCenterY = bodyTopY + torsoH * 0.6;

      // Left arm to book
      final lShoulderX = headX - shoulderW / 2 + w * 0.02;
      final lShoulderY = bodyTopY + h * 0.02;
      final lArmPath = Path();
      lArmPath.moveTo(lShoulderX, lShoulderY);
      lArmPath.quadraticBezierTo(
        lShoulderX - w * 0.03, bookCenterY - h * 0.02,
        bookCenterX - w * 0.06, bookCenterY,
      );
      canvas.drawPath(lArmPath, armPaint);

      // Right arm to book
      final rShoulderX = headX + shoulderW / 2 - w * 0.02;
      final rShoulderY = bodyTopY + h * 0.02;
      final rArmPath = Path();
      rArmPath.moveTo(rShoulderX, rShoulderY);
      rArmPath.quadraticBezierTo(
        rShoulderX + w * 0.02, bookCenterY - h * 0.02,
        bookCenterX + w * 0.06, bookCenterY,
      );
      canvas.drawPath(rArmPath, armPaint);
    }

    // -- LEGS --
    final hipY = bodyTopY + torsoH;

    if (sitProgress < 1.0) {
      // Standing legs
      final legPaint = Paint()
        ..color = skirtColor.withValues(alpha: appear)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.03
        ..strokeCap = StrokeCap.round;

      // Skirt area
      final skirtPath = Path();
      skirtPath.moveTo(headX - shoulderW * 0.4, hipY);
      skirtPath.lineTo(headX - shoulderW * 0.5, hipY + h * 0.08);
      skirtPath.lineTo(headX + shoulderW * 0.5, hipY + h * 0.08);
      skirtPath.lineTo(headX + shoulderW * 0.4, hipY);
      skirtPath.close();
      canvas.drawPath(
        skirtPath,
        Paint()..color = skirtColor.withValues(alpha: appear),
      );

      // Legs
      final footY = h * 0.85;
      canvas.drawLine(
        Offset(headX - w * 0.03, hipY + h * 0.07),
        Offset(headX - w * 0.04, footY),
        legPaint..color = skinColor.withValues(alpha: appear),
      );
      canvas.drawLine(
        Offset(headX + w * 0.03, hipY + h * 0.07),
        Offset(headX + w * 0.04, footY),
        legPaint..color = skinColor.withValues(alpha: appear),
      );

      // Shoes
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(headX - w * 0.05, footY + h * 0.01),
          width: w * 0.05,
          height: h * 0.02,
        ),
        Paint()..color = const Color(0xFF1E293B).withValues(alpha: appear),
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(headX + w * 0.05, footY + h * 0.01),
          width: w * 0.05,
          height: h * 0.02,
        ),
        Paint()..color = const Color(0xFF1E293B).withValues(alpha: appear),
      );
    } else {
      // Sitting legs (crossed or to the side)
      final legPaint = Paint()
        ..color = skinColor.withValues(alpha: appear)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.025
        ..strokeCap = StrokeCap.round;

      // Skirt while sitting
      final skirtPath = Path();
      skirtPath.moveTo(headX - shoulderW * 0.35, hipY);
      skirtPath.quadraticBezierTo(
        headX, hipY + h * 0.06,
        headX + shoulderW * 0.5, hipY + h * 0.02,
      );
      skirtPath.lineTo(headX + shoulderW * 0.35, hipY);
      skirtPath.close();
      canvas.drawPath(
        skirtPath,
        Paint()..color = skirtColor.withValues(alpha: appear),
      );

      // Left leg (bent, sitting)
      final lLegPath = Path();
      lLegPath.moveTo(headX - w * 0.02, hipY + h * 0.04);
      lLegPath.quadraticBezierTo(
        headX - w * 0.08, hipY + h * 0.08,
        headX - w * 0.12, hipY + h * 0.04,
      );
      canvas.drawPath(lLegPath, legPaint);

      // Right leg (extended)
      final rLegPath = Path();
      rLegPath.moveTo(headX + w * 0.02, hipY + h * 0.04);
      rLegPath.quadraticBezierTo(
        headX + w * 0.06, hipY + h * 0.09,
        headX + w * 0.12, hipY + h * 0.07,
      );
      canvas.drawPath(rLegPath, legPaint);

      // Shoes
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(headX - w * 0.13, hipY + h * 0.04),
          width: w * 0.04,
          height: h * 0.018,
        ),
        Paint()..color = const Color(0xFF1E293B).withValues(alpha: appear),
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(headX + w * 0.13, hipY + h * 0.07),
          width: w * 0.04,
          height: h * 0.018,
        ),
        Paint()..color = const Color(0xFF1E293B).withValues(alpha: appear),
      );
    }
  }

  void _drawHeldBook(Canvas canvas, double w, double h, double cx) {
    if (sitProgress <= 0) return;

    // The pink book she took, now held open for reading
    final headY = h * 0.52;
    final headR = w * 0.055;
    final bodyTopY = headY + headR + h * 0.01;
    final torsoH = h * 0.12;

    final bookCenterX = w * 0.62 - w * 0.02;
    final bookCenterY = bodyTopY + torsoH * 0.6;
    final bookW = w * 0.14;
    final bookH = h * 0.09;

    // Page turn animation
    final pageTurn = sin(readProgress * pi * 2) * 0.5 + 0.5;

    // Book shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(bookCenterX + 2, bookCenterY + 3),
          width: bookW,
          height: bookH,
        ),
        const Radius.circular(3),
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.15 * sitProgress),
    );

    // Open book - left page
    final leftPage = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        bookCenterX - bookW / 2,
        bookCenterY - bookH / 2,
        bookW / 2,
        bookH,
      ),
      const Radius.circular(2),
    );
    canvas.drawRRect(
      leftPage,
      Paint()..color = Colors.white.withValues(alpha: sitProgress),
    );

    // Right page (with turn effect)
    final rightPage = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        bookCenterX,
        bookCenterY - bookH / 2,
        bookW / 2,
        bookH,
      ),
      const Radius.circular(2),
    );
    canvas.drawRRect(
      rightPage,
      Paint()..color = const Color(0xFFFFF8F0).withValues(alpha: sitProgress),
    );

    // Book spine
    canvas.drawLine(
      Offset(bookCenterX, bookCenterY - bookH / 2 + 2),
      Offset(bookCenterX, bookCenterY + bookH / 2 - 2),
      Paint()
        ..color = const Color(0xFFEC4899).withValues(alpha: sitProgress)
        ..strokeWidth = 2,
    );

    // Text lines on left page
    final lineColor = const Color(0xFFD4D4D4).withValues(alpha: sitProgress * 0.6);
    for (int i = 0; i < 4; i++) {
      final ly = bookCenterY - bookH * 0.3 + i * bookH * 0.15;
      final lw = bookW * (0.3 + (i % 2) * 0.1);
      canvas.drawLine(
        Offset(bookCenterX - bookW / 2 + bookW * 0.06, ly),
        Offset(bookCenterX - bookW / 2 + bookW * 0.06 + lw, ly),
        Paint()
          ..color = lineColor
          ..strokeWidth = 1.2,
      );
    }

    // Text lines on right page (animated, appearing)
    for (int i = 0; i < 4; i++) {
      final ly = bookCenterY - bookH * 0.3 + i * bookH * 0.15;
      final lineProgress = ((readProgress * 4 - i) % 1.0).clamp(0.0, 1.0);
      final lw = bookW * (0.25 + (i % 3) * 0.05) * lineProgress;
      canvas.drawLine(
        Offset(bookCenterX + bookW * 0.06, ly),
        Offset(bookCenterX + bookW * 0.06 + lw, ly),
        Paint()
          ..color = lineColor
          ..strokeWidth = 1.2,
      );
    }

    // Page turning effect (subtle floating page)
    if (readProgress > 0) {
      final pageAngle = pageTurn * 0.3;
      canvas.save();
      canvas.translate(bookCenterX, bookCenterY);
      canvas.rotate(pageAngle * 0.1);
      canvas.translate(-bookCenterX, -bookCenterY);

      final turningPage = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          bookCenterX - bookW * 0.02,
          bookCenterY - bookH / 2 + 1,
          bookW / 2 * pageTurn,
          bookH - 2,
        ),
        const Radius.circular(1),
      );
      canvas.drawRRect(
        turningPage,
        Paint()
          ..color = const Color(0xFFFFFBF5).withValues(alpha: 0.5 * sitProgress * pageTurn),
      );
      canvas.restore();
    }
  }

  void _drawParticles(Canvas canvas, double w, double h) {
    for (final p in particles) {
      final time = particleProgress + p.phase;
      final px = p.x * w + sin(time * pi * 2 * p.speed) * w * 0.08;
      final py = p.y * h - (time * p.speed * h * 0.3) % (h * 0.5);
      final adjustedPy = py < 0 ? py + h : py;

      // Sparkle shape
      final sparkleOpacity =
          p.opacity * (0.5 + 0.5 * sin(time * pi * 4)).clamp(0.0, 1.0);

      // Star-like sparkle
      final starPath = Path();
      final sr = p.size;
      for (int i = 0; i < 4; i++) {
        final angle = i * pi / 2 + time * pi;
        starPath.moveTo(
          px + cos(angle) * sr * 0.3,
          adjustedPy + sin(angle) * sr * 0.3,
        );
        starPath.lineTo(
          px + cos(angle) * sr,
          adjustedPy + sin(angle) * sr,
        );
      }

      canvas.drawPath(
        starPath,
        Paint()
          ..color = accentColor.withValues(alpha: sparkleOpacity * 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..strokeCap = StrokeCap.round,
      );

      // Center dot
      canvas.drawCircle(
        Offset(px, adjustedPy),
        sr * 0.25,
        Paint()..color = Colors.white.withValues(alpha: sparkleOpacity * 0.8),
      );
    }
  }

  void _drawReadingGlow(Canvas canvas, double w, double h, double cx) {
    // Soft glow around the book area when reading
    final glowProgress = 0.3 + 0.2 * sin(readProgress * pi * 2);
    final glowCenter = Offset(w * 0.60, h * 0.60);

    canvas.drawCircle(
      glowCenter,
      w * 0.18,
      Paint()
        ..shader = RadialGradient(
          colors: [
            accentColor.withValues(alpha: glowProgress * 0.08),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCircle(center: glowCenter, radius: w * 0.18),
        ),
    );
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  bool shouldRepaint(covariant _BookReadingPainter oldDelegate) {
    return stackProgress != oldDelegate.stackProgress ||
        reachProgress != oldDelegate.reachProgress ||
        sitProgress != oldDelegate.sitProgress ||
        readProgress != oldDelegate.readProgress ||
        particleProgress != oldDelegate.particleProgress;
  }
}
