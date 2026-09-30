// In-Class Activity 06 — Drawing with Flutter
// Student: Adi Tauqir
// Date: September 30, 2026

import 'dart:math' show pi;
import 'package:flutter/material.dart';

void main() => runApp(const SmileyApp());

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
  bool showBlush = true;

  // Level 2: Mood-based dynamic color logic
  Color get faceColor {
    if (mood < 0.35) {
      return Colors.lightBlue.shade200; // Cool color for frown
    } else if (mood <= 0.7) {
      return Colors.yellow.shade600; // Classic yellow for neutral/soft smile
    } else {
      return Colors.orangeAccent.shade200; // Warm color for big smile
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CustomPainter Smiley Lab')),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: CustomPaint(
                size: const Size(300, 300),
                painter: SmileyPainter(
                  mood: mood,
                  faceColor: faceColor,
                  eyeRadius: eyeRadius,
                  showBlush: showBlush,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Mood: ${mood.toStringAsFixed(2)} (${mood < 0.35 ? "Sad" : mood <= 0.7 ? "Neutral" : "Happy"})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Slider(
                  value: mood,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (double v) => setState(() => mood = v),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Show Blush:'),
                    Checkbox(
                      value: showBlush,
                      onChanged: (bool? v) => setState(() => showBlush = v ?? false),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SmileyPainter extends CustomPainter {
  SmileyPainter({
    required this.mood,
    required this.faceColor,
    required this.eyeRadius,
    required this.showBlush,
  });

  final double mood;
  final Color faceColor;
  final double eyeRadius;
  final bool showBlush;

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

    // 3) Eyes
    final eyePaint = Paint()..color = Colors.black87;
    final eyeY = c.dy - r * 0.18;
    final eyeDx = r * 0.35;
    canvas.drawCircle(Offset(c.dx - eyeDx, eyeY), eyeRadius, eyePaint);
    canvas.drawCircle(Offset(c.dx + eyeDx, eyeY), eyeRadius, eyePaint);

    // Optional: Blush ovals
    if (showBlush) {
      final blushPaint = Paint()
        ..color = Colors.pinkAccent.withValues(alpha: 0.4)
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

    // 4) Mouth — map mood (0..1) to arc geometry
    final mouthPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final mouthRect = Rect.fromCenter(
      center: Offset(c.dx, c.dy + r * 0.15),
      width: r * 1.0,
      height: r * (0.4 + mood * 0.5),
    );

    // Happy: arc along bottom; Sad: flip with frownRect
    if (mood >= 0.5) {
      canvas.drawArc(mouthRect, 0.15 * pi, 0.70 * pi, false, mouthPaint);
    } else {
      final frownRect = mouthRect.translate(0, r * 0.25);
      canvas.drawArc(frownRect, 1.15 * pi, 0.70 * pi, false, mouthPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SmileyPainter oldDelegate) {
    return oldDelegate.mood != mood ||
        oldDelegate.faceColor != faceColor ||
        oldDelegate.eyeRadius != eyeRadius ||
        oldDelegate.showBlush != showBlush;
  }
}
