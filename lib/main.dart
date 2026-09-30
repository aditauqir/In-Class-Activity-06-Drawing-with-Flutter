// In-Class Activity 06 — Drawing with Flutter
// Student: Adi Tauqir
// Date: September 30, 2026

import 'dart:math' show Random, pi;
import 'package:flutter/material.dart';

void main() => runApp(const SmileyApp());

enum FaceType { classic, sleepy, surprised }

/// Immutable configuration representation for undo stack tracking
class FaceConfig {
  final double mood;
  final FaceType faceType;
  final Color? customColor;
  final bool showBlush;
  final bool showHat;
  final bool showGlasses;
  final bool showMustache;

  const FaceConfig({
    required this.mood,
    required this.faceType,
    this.customColor,
    required this.showBlush,
    required this.showHat,
    required this.showGlasses,
    required this.showMustache,
  });

  FaceConfig copyWith({
    double? mood,
    FaceType? faceType,
    Color? customColor,
    bool clearCustomColor = false,
    bool? showBlush,
    bool? showHat,
    bool? showGlasses,
    bool? showMustache,
  }) {
    return FaceConfig(
      mood: mood ?? this.mood,
      faceType: faceType ?? this.faceType,
      customColor: clearCustomColor ? null : (customColor ?? this.customColor),
      showBlush: showBlush ?? this.showBlush,
      showHat: showHat ?? this.showHat,
      showGlasses: showGlasses ?? this.showGlasses,
      showMustache: showMustache ?? this.showMustache,
    );
  }
}

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
  // Current active configuration
  FaceConfig _config = const FaceConfig(
    mood: 0.8,
    faceType: FaceType.classic,
    showBlush: true,
    showHat: false,
    showGlasses: false,
    showMustache: false,
  );

  // Undo history stack
  final List<FaceConfig> _undoStack = [];

  final double eyeRadius = 14.0;
  final Random _random = Random();

  Color get faceColor {
    if (_config.customColor != null) {
      return _config.customColor!;
    }
    if (_config.mood < 0.35) {
      return Colors.lightBlue.shade200; // Cool color for frown
    } else if (_config.mood <= 0.7) {
      return Colors.yellow.shade600; // Classic yellow for neutral
    } else {
      return Colors.orangeAccent.shade200; // Warm color for happy
    }
  }

  void _pushUndoState() {
    _undoStack.add(_config);
    if (_undoStack.length > 50) {
      _undoStack.removeAt(0);
    }
  }

  void _undo() {
    if (_undoStack.isEmpty) return;
    final previous = _undoStack.removeLast();
    setState(() {
      _config = previous;
    });
    _showFeedback('Undo: Restored previous face configuration');
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
    _pushUndoState();
    final nextIndex = (_config.faceType.index + 1) % FaceType.values.length;
    final nextType = FaceType.values[nextIndex];
    setState(() {
      _config = _config.copyWith(faceType: nextType);
    });
    _showFeedback('Face style cycled to: ${nextType.name.toUpperCase()}');
  }

  void _randomizeMoodAndColor() {
    _pushUndoState();
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
      _config = _config.copyWith(
        mood: newMood,
        customColor: newColor,
        faceType: nextType,
      );
    });
    _showFeedback(
      'Randomized: ${nextType.name.toUpperCase()} (Mood: ${newMood.toStringAsFixed(2)})',
    );
  }

  void _updateMood(double newMood) {
    setState(() {
      _config = _config.copyWith(
        mood: newMood,
        clearCustomColor: true,
      );
    });
  }

  void _toggleAccessory({bool? hat, bool? glasses, bool? mustache, bool? blush}) {
    _pushUndoState();
    setState(() {
      _config = _config.copyWith(
        showHat: hat != null ? !hat : null,
        showGlasses: glasses != null ? !glasses : null,
        showMustache: mustache != null ? !mustache : null,
        showBlush: blush != null ? !blush : null,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CustomPainter Smiley Lab'),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            tooltip: 'Undo last change',
            onPressed: _undoStack.isNotEmpty ? _undo : null,
          ),
          IconButton(
            icon: const Icon(Icons.shuffle),
            tooltip: 'Randomize',
            onPressed: _randomizeMoodAndColor,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Gallery selection
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
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
                selected: {_config.faceType},
                onSelectionChanged: (Set<FaceType> newSelection) {
                  _pushUndoState();
                  setState(() {
                    _config = _config.copyWith(faceType: newSelection.first);
                  });
                },
              ),
            ),
            // Interactive touch canvas
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
                        config: _config,
                        faceColor: faceColor,
                        eyeRadius: eyeRadius,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Accessory IconButtons (Bonus)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton.filledTonal(
                      isSelected: _config.showHat,
                      icon: const Icon(Icons.pan_tool_alt_outlined),
                      selectedIcon: const Icon(Icons.pan_tool_alt),
                      tooltip: 'Toggle Hat',
                      onPressed: () => _toggleAccessory(hat: _config.showHat),
                    ),
                    IconButton.filledTonal(
                      isSelected: _config.showGlasses,
                      icon: const Icon(Icons.visibility_outlined),
                      selectedIcon: const Icon(Icons.visibility),
                      tooltip: 'Toggle Glasses',
                      onPressed: () => _toggleAccessory(glasses: _config.showGlasses),
                    ),
                    IconButton.filledTonal(
                      isSelected: _config.showMustache,
                      icon: const Icon(Icons.face_outlined),
                      selectedIcon: const Icon(Icons.face),
                      tooltip: 'Toggle Mustache',
                      onPressed: () => _toggleAccessory(mustache: _config.showMustache),
                    ),
                    IconButton.filledTonal(
                      isSelected: _config.showBlush,
                      icon: const Icon(Icons.favorite_border),
                      selectedIcon: const Icon(Icons.favorite),
                      tooltip: 'Toggle Blush',
                      onPressed: () => _toggleAccessory(blush: _config.showBlush),
                    ),
                  ],
                ),
              ),
            ),
            // Slider and Mood display
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Mood: ${_config.mood.toStringAsFixed(2)} (${_config.mood < 0.35 ? "Sad" : _config.mood <= 0.7 ? "Neutral" : "Happy"})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: _config.mood,
                    min: 0.0,
                    max: 1.0,
                    onChangeStart: (_) => _pushUndoState(),
                    onChanged: _updateMood,
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
    required this.config,
    required this.faceColor,
    required this.eyeRadius,
  });

  final FaceConfig config;
  final Color faceColor;
  final double eyeRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide * 0.40;

    // === Layer Recipe (Painter's Algorithm) ===
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

    switch (config.faceType) {
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
    if (config.showBlush) {
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

    // 5) Mouth — dynamically configured per FaceType and mood
    final mouthPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    switch (config.faceType) {
      case FaceType.classic:
        final mouthRect = Rect.fromCenter(
          center: Offset(c.dx, c.dy + r * 0.15),
          width: r * 1.0,
          height: r * (0.4 + config.mood * 0.5),
        );
        if (config.mood >= 0.5) {
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
          height: r * (0.50 + (config.mood * 0.25)),
        );
        canvas.drawOval(openMouthRect, openMouthPaint);
        break;
    }

    // 6) Mustache accessory (Layered between nose and mouth)
    if (config.showMustache) {
      final mustachePaint = Paint()
        ..color = Colors.brown.shade900
        ..style = PaintingStyle.fill;
      final mustacheCenterY = c.dy + r * 0.08;
      final mustachePath = Path();
      // Left curl
      mustachePath.moveTo(c.dx, mustacheCenterY);
      mustachePath.quadraticBezierTo(
        c.dx - r * 0.22,
        mustacheCenterY - r * 0.08,
        c.dx - r * 0.48,
        mustacheCenterY + r * 0.10,
      );
      mustachePath.quadraticBezierTo(
        c.dx - r * 0.20,
        mustacheCenterY + r * 0.05,
        c.dx,
        mustacheCenterY + r * 0.02,
      );
      // Right curl
      mustachePath.quadraticBezierTo(
        c.dx + r * 0.20,
        mustacheCenterY + r * 0.05,
        c.dx + r * 0.48,
        mustacheCenterY + r * 0.10,
      );
      mustachePath.quadraticBezierTo(
        c.dx + r * 0.22,
        mustacheCenterY - r * 0.08,
        c.dx,
        mustacheCenterY,
      );
      mustachePath.close();
      canvas.drawPath(mustachePath, mustachePaint);
    }

    // 7) Glasses accessory (Layered over eyes)
    if (config.showGlasses) {
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

    // 8) Hat accessory (Top layer)
    if (config.showHat) {
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
    return oldDelegate.config.mood != config.mood ||
        oldDelegate.config.faceType != config.faceType ||
        oldDelegate.config.showBlush != config.showBlush ||
        oldDelegate.config.showHat != config.showHat ||
        oldDelegate.config.showGlasses != config.showGlasses ||
        oldDelegate.config.showMustache != config.showMustache ||
        oldDelegate.faceColor != faceColor ||
        oldDelegate.eyeRadius != eyeRadius;
  }
}
