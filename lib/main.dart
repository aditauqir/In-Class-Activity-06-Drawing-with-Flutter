// In-Class Activity 06 — Drawing with Flutter
// Student: Adi Tauqir
// Date: September 30, 2026

import 'dart:math' show Random, pi;
import 'package:flutter/material.dart';

void main() => runApp(const SmileyApp());

enum FaceType { classic, sleepy, surprised }

class SmileyApp extends StatelessWidget {
  const SmileyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smiley Painter Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const DrawingPlayground(),
    );
  }
}

class DrawingPlayground extends StatefulWidget {
  const DrawingPlayground({super.key});

  @override
  State<DrawingPlayground> createState() => _DrawingPlaygroundState();
}

class _DrawingPlaygroundState extends State<DrawingPlayground> {
  // Drawing "state" — changing these + setState() triggers shouldRepaint
  double mood = 0.8; // 0.0 sad → 1.0 happy
  double eyeRadius = 14.0;
  FaceType faceType = FaceType.classic;
  Color? _customColor;
  bool showBlush = true;
  bool showHat = false;
  bool showGlasses = false;

  final Random _random = Random();

  Color get faceColor {
    if (_customColor != null) {
      return _customColor!;
    }
    if (mood < 0.35) {
      return Colors.lightBlue.shade200; // Cool color for frown
    } else if (mood <= 0.7) {
      return Colors.yellow.shade600; // Classic yellow for neutral
    } else {
      return Colors.orangeAccent.shade200; // Warm color for happy
    }
  }

  void _showFeedback(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _cycleFace() {
    final nextIndex = (faceType.index + 1) % FaceType.values.length;
    final nextType = FaceType.values[nextIndex];
    setState(() {
      faceType = nextType;
    });
    _showFeedback('Face style cycled to: ${nextType.name.toUpperCase()}');
  }

  void _randomizeMoodAndColor() {
    final newMood = _random.nextDouble();
    final palette = [
      Colors.yellow.shade600,
      Colors.lightBlue.shade200,
      Colors.orangeAccent.shade200,
      Colors.pink.shade200,
      Colors.lightGreen.shade300,
      Colors.purple.shade200,
      Colors.teal.shade200,
    ];
    final newColor = palette[_random.nextInt(palette.length)];
    final nextType = FaceType.values[_random.nextInt(FaceType.values.length)];

    setState(() {
      mood = newMood;
      _customColor = newColor;
      faceType = nextType;
    });
    _showFeedback(
      'Randomized: ${nextType.name.toUpperCase()} (Mood: ${newMood.toStringAsFixed(2)})',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CustomPainter Smiley Lab')),
      body: SafeArea(
        child: Column(
          children: [
            // Gallery selection
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
              child: SegmentedButton<FaceType>(
                segments: const [
                  ButtonSegment(
                    value: FaceType.classic,
                    label: Text('Classic'),
                    icon: Icon(Icons.sentiment_satisfied_alt),
                  ),
                  ButtonSegment(
                    value: FaceType.sleepy,
                    label: Text('Sleepy'),
                    icon: Icon(Icons.bedtime_outlined),
                  ),
                  ButtonSegment(
                    value: FaceType.surprised,
                    label: Text('Surprised'),
                    icon: Icon(Icons.sentiment_very_satisfied),
                  ),
                ],
                selected: {faceType},
                onSelectionChanged: (Set<FaceType> newSelection) {
                  setState(() {
                    faceType = newSelection.first;
                  });
                },
              ),
            ),
            // Level 4: Interactive GestureDetector wrapping CustomPaint
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: _cycleFace,
                  onLongPress: _randomizeMoodAndColor,
                  child: Tooltip(
                    message: 'Tap to cycle faces, Long-press to randomize',
                    child: CustomPaint(
                      size: const Size(300, 300),
                      painter: SmileyPainter(
                        mood: mood,
                        faceType: faceType,
                        faceColor: faceColor,
                        eyeRadius: eyeRadius,
                        showBlush: showBlush,
                        showHat: showHat,
                        showGlasses: showGlasses,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Mood: ${mood.toStringAsFixed(2)} (${mood < 0.35 ? "Sad" : mood <= 0.7 ? "Neutral" : "Happy"})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: mood,
                    min: 0.0,
                    max: 1.0,
                    onChanged: (double v) {
                      setState(() {
                        mood = v;
                        _customColor = null; // Resume mood-band color tracking
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FilterChip(
                        label: const Text('Blush'),
                        selected: showBlush,
                        onSelected: (val) => setState(() => showBlush = val),
                      ),
                      FilterChip(
                        label: const Text('Hat'),
                        selected: showHat,
                        onSelected: (val) => setState(() => showHat = val),
                      ),
                      FilterChip(
                        label: const Text('Glasses'),
                        selected: showGlasses,
                        onSelected: (val) => setState(() => showGlasses = val),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SmileyPainter extends CustomPainter {
  SmileyPainter({
    required this.mood,
    required this.faceType,
    required this.faceColor,
    required this.eyeRadius,
    required this.showBlush,
    required this.showHat,
    required this.showGlasses,
  });

  final double mood;
  final FaceType faceType;
  final Color faceColor;
  final double eyeRadius;
  final bool showBlush;
  final bool showHat;
  final bool showGlasses;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide * 0.40;

    // 1) Face fill
    final facePaint = Paint()
      ..color = faceColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(c, r, facePaint);

    // 2) Face border
    final border = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(c, r, border);

    // 3) Eyes (Customized per FaceType)
    final eyePaint = Paint()..color = Colors.black87;
    final eyeY = c.dy - r * 0.18;
    final eyeDx = r * 0.35;
    final leftEyeCenter = Offset(c.dx - eyeDx, eyeY);
    final rightEyeCenter = Offset(c.dx + eyeDx, eyeY);

    switch (faceType) {
      case FaceType.classic:
        canvas.drawCircle(leftEyeCenter, eyeRadius, eyePaint);
        canvas.drawCircle(rightEyeCenter, eyeRadius, eyePaint);
        break;

      case FaceType.sleepy:
        final closedEyePaint = Paint()
          ..color = Colors.black87
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5
          ..strokeCap = StrokeCap.round;
        final eyeArcRectLeft = Rect.fromCenter(
          center: leftEyeCenter,
          width: eyeRadius * 2.2,
          height: eyeRadius * 1.4,
        );
        final eyeArcRectRight = Rect.fromCenter(
          center: rightEyeCenter,
          width: eyeRadius * 2.2,
          height: eyeRadius * 1.4,
        );
        canvas.drawArc(eyeArcRectLeft, 1.15 * pi, 0.70 * pi, false, closedEyePaint);
        canvas.drawArc(eyeArcRectRight, 1.15 * pi, 0.70 * pi, false, closedEyePaint);
        break;

      case FaceType.surprised:
        final surprisedEyeRadius = eyeRadius * 1.35;
        final scleraPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        final eyeBorderPaint = Paint()
          ..color = Colors.black87
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;

        canvas.drawCircle(leftEyeCenter, surprisedEyeRadius, scleraPaint);
        canvas.drawCircle(leftEyeCenter, surprisedEyeRadius, eyeBorderPaint);
        canvas.drawCircle(rightEyeCenter, surprisedEyeRadius, scleraPaint);
        canvas.drawCircle(rightEyeCenter, surprisedEyeRadius, eyeBorderPaint);

        canvas.drawCircle(leftEyeCenter, surprisedEyeRadius * 0.5, eyePaint);
        canvas.drawCircle(rightEyeCenter, surprisedEyeRadius * 0.5, eyePaint);
        break;
    }

    // 4) Blush ovals
    if (showBlush) {
      final blushPaint = Paint()
        ..color = Colors.pinkAccent.withValues(alpha: 0.45)
        ..style = PaintingStyle.fill;
      final blushWidth = r * 0.22;
      final blushHeight = r * 0.12;
      final blushY = c.dy + r * 0.08;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(c.dx - eyeDx, blushY),
          width: blushWidth,
          height: blushHeight,
        ),
        blushPaint,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(c.dx + eyeDx, blushY),
          width: blushWidth,
          height: blushHeight,
        ),
        blushPaint,
      );
    }

    // 5) Mouth — dynamically configured per FaceType
    final mouthPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    switch (faceType) {
      case FaceType.classic:
        final mouthRect = Rect.fromCenter(
          center: Offset(c.dx, c.dy + r * 0.15),
          width: r * 1.0,
          height: r * (0.4 + mood * 0.5),
        );
        if (mood >= 0.5) {
          canvas.drawArc(mouthRect, 0.15 * pi, 0.70 * pi, false, mouthPaint);
        } else {
          final frownRect = mouthRect.translate(0, r * 0.25);
          canvas.drawArc(frownRect, 1.15 * pi, 0.70 * pi, false, mouthPaint);
        }
        break;

      case FaceType.sleepy:
        final sleepyMouthRect = Rect.fromCenter(
          center: Offset(c.dx, c.dy + r * 0.22),
          width: r * 0.6,
          height: r * 0.25,
        );
        canvas.drawArc(sleepyMouthRect, 0.1 * pi, 0.8 * pi, false, mouthPaint..strokeWidth = 3.5);
        break;

      case FaceType.surprised:
        final openMouthPaint = Paint()
          ..color = Colors.black87
          ..style = PaintingStyle.fill;
        final openMouthRect = Rect.fromCenter(
          center: Offset(c.dx, c.dy + r * 0.25),
          width: r * 0.42,
          height: r * (0.50 + (mood * 0.25)),
        );
        canvas.drawOval(openMouthRect, openMouthPaint);
        break;
    }

    // 6) Glasses (Layered directly over eyes)
    if (showGlasses) {
      final glassesPaint = Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5;
      final glassesRadius = eyeRadius * 1.5;
      canvas.drawCircle(leftEyeCenter, glassesRadius, glassesPaint);
      canvas.drawCircle(rightEyeCenter, glassesRadius, glassesPaint);
      canvas.drawLine(
        Offset(leftEyeCenter.dx + glassesRadius, eyeY),
        Offset(rightEyeCenter.dx - glassesRadius, eyeY),
        glassesPaint,
      );
    }

    // 7) Hat (Layered on top of head)
    if (showHat) {
      final hatPaint = Paint()
        ..color = Colors.brown.shade800
        ..style = PaintingStyle.fill;
      final hatBrimPaint = Paint()
        ..color = Colors.brown.shade900
        ..style = PaintingStyle.fill;

      final brimRect = Rect.fromCenter(
        center: Offset(c.dx, c.dy - r * 0.85),
        width: r * 1.5,
        height: r * 0.18,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(brimRect, const Radius.circular(4)),
        hatBrimPaint,
      );

      final crownRect = Rect.fromCenter(
        center: Offset(c.dx, c.dy - r * 1.25),
        width: r * 0.9,
        height: r * 0.65,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(crownRect, const Radius.circular(6)),
        hatPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SmileyPainter oldDelegate) {
    return oldDelegate.mood != mood ||
        oldDelegate.faceType != faceType ||
        oldDelegate.faceColor != faceColor ||
        oldDelegate.eyeRadius != eyeRadius ||
        oldDelegate.showBlush != showBlush ||
        oldDelegate.showHat != showHat ||
        oldDelegate.showGlasses != showGlasses;
  }
}
