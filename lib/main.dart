// In-Class Activity 06 — Drawing with Flutter
// Student: Adi Tauqir
// Date: September 30, 2026

import 'dart:math' show Random, min, pi;
import 'package:flutter/material.dart';

void main() => runApp(const SmileyApp());

enum FaceType { classic, sleepy, surprised, winking, robot }

/// Immutable configuration model for the drawing playground & undo stack
class FaceConfig {
  final double mood;
  final FaceType faceType;
  final Color? customColor;
  final double eyeRadius; // Base radius (default 14.0 at 300px scale)
  final double eyeGap; // Base eye center offset from middle (default 48.0 at 300px scale)
  final bool showBlush;
  final bool showHat;
  final bool showGlasses;
  final bool showMustache;

  const FaceConfig({
    required this.mood,
    required this.faceType,
    this.customColor,
    this.eyeRadius = 14.0,
    this.eyeGap = 48.0,
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
    double? eyeRadius,
    double? eyeGap,
    bool? showBlush,
    bool? showHat,
    bool? showGlasses,
    bool? showMustache,
  }) {
    return FaceConfig(
      mood: mood ?? this.mood,
      faceType: faceType ?? this.faceType,
      customColor: clearCustomColor ? null : (customColor ?? this.customColor),
      eyeRadius: eyeRadius ?? this.eyeRadius,
      eyeGap: eyeGap ?? this.eyeGap,
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
  // Current active configuration (defaults to Beaming happy face)
  FaceConfig _config = const FaceConfig(
    mood: 0.85,
    faceType: FaceType.classic,
    eyeRadius: 14.0,
    eyeGap: 48.0,
    showBlush: true,
    showHat: false,
    showGlasses: false,
    showMustache: false,
  );

  // Undo history stack
  final List<FaceConfig> _undoStack = [];

  final Random _random = Random();
  bool _showFineTuning = false;

  Color get faceColor {
    if (_config.customColor != null) {
      return _config.customColor!;
    }
    if (_config.faceType == FaceType.robot) {
      return const Color(0xFFA3E635); // Lime green for robot matching official demo
    }
    if (_config.mood < 0.35) {
      return Colors.lightBlue.shade200; // Cool color for frown
    } else if (_config.mood <= 0.70) {
      return Colors.yellow.shade600; // Classic yellow for neutral
    } else {
      return Colors.amber.shade500; // Warm beaming color for happy
    }
  }

  String get moodLabel {
    if (_config.mood >= 0.85) return 'Beaming';
    if (_config.mood > 0.55) return 'Happy';
    if (_config.mood >= 0.45) return 'Soft smile';
    if (_config.mood >= 0.35) return 'Neutral';
    return 'Sad';
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
    _showFeedback('Undo: Restored previous configuration');
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

  void _applyPreset({
    required double mood,
    required FaceType faceType,
    required bool blush,
    double? eyeRadius,
    double? eyeGap,
    Color? color,
  }) {
    _pushUndoState();
    setState(() {
      _config = _config.copyWith(
        mood: mood,
        faceType: faceType,
        showBlush: blush,
        eyeRadius: eyeRadius,
        eyeGap: eyeGap,
        customColor: color,
        clearCustomColor: color == null,
      );
    });
    _showFeedback('Preset applied: ${faceType.name.toUpperCase()} ($moodLabel)');
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

  Widget _buildCanvasWidget() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final canvasDimension = min(constraints.maxWidth, constraints.maxHeight).clamp(160.0, 320.0);
        return GestureDetector(
          onTap: _cycleFace,
          onLongPress: _randomizeMoodAndColor,
          child: Tooltip(
            message: 'Tap to cycle faces, Long-press to randomize',
            child: CustomPaint(
              size: Size.square(canvasDimension),
              painter: SmileyPainter(
                config: _config,
                faceColor: faceColor,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPresetsRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ActionChip(
            avatar: const Text('😊'),
            label: const Text('Happy'),
            onPressed: () => _applyPreset(
              mood: 0.85,
              faceType: FaceType.classic,
              blush: true,
            ),
          ),
          const SizedBox(width: 8),
          ActionChip(
            avatar: const Text('😢'),
            label: const Text('Sad'),
            onPressed: () => _applyPreset(
              mood: 0.20,
              faceType: FaceType.classic,
              blush: false,
            ),
          ),
          const SizedBox(width: 8),
          ActionChip(
            avatar: const Text('😉'),
            label: const Text('Wink vibe'),
            onPressed: () => _applyPreset(
              mood: 0.85,
              faceType: FaceType.winking,
              blush: true,
            ),
          ),
          const SizedBox(width: 8),
          ActionChip(
            avatar: const Text('🤖'),
            label: const Text('Robot'),
            onPressed: () => _applyPreset(
              mood: 0.50,
              faceType: FaceType.robot,
              blush: false,
              eyeRadius: 18.0,
              eyeGap: 48.0,
              color: const Color(0xFFA3E635),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Presets row matching web interactive demo
        _buildPresetsRow(),
        const SizedBox(height: 6),

        // Face style selector (Level 3 Multi-face gallery)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SegmentedButton<FaceType>(
            segments: const [
              ButtonSegment(
                value: FaceType.classic,
                label: Text('Classic'),
                icon: Icon(Icons.sentiment_satisfied_alt, size: 18),
              ),
              ButtonSegment(
                value: FaceType.sleepy,
                label: Text('Sleepy'),
                icon: Icon(Icons.bedtime_outlined, size: 18),
              ),
              ButtonSegment(
                value: FaceType.surprised,
                label: Text('Surprised'),
                icon: Icon(Icons.sentiment_very_satisfied, size: 18),
              ),
              ButtonSegment(
                value: FaceType.winking,
                label: Text('Wink'),
                icon: Icon(Icons.face_retouching_natural, size: 18),
              ),
              ButtonSegment(
                value: FaceType.robot,
                label: Text('Robot'),
                icon: Icon(Icons.smart_toy_outlined, size: 18),
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
        const SizedBox(height: 6),

        // Primary Mood Slider + Label
        Row(
          children: [
            Expanded(
              child: Text(
                'Mood: $moodLabel (${_config.mood.toStringAsFixed(2)})',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: Icon(_showFineTuning ? Icons.expand_less : Icons.tune, size: 20),
              tooltip: _showFineTuning ? 'Hide Details' : 'Fine-Tune',
              onPressed: () => setState(() => _showFineTuning = !_showFineTuning),
            ),
          ],
        ),
        Slider(
          value: _config.mood,
          min: 0.0,
          max: 1.0,
          onChangeStart: (_) => _pushUndoState(),
          onChanged: _updateMood,
        ),

        // Fine-tuning expandable details (Eye Radius, Eye Gap, Blush)
        if (_showFineTuning) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Eye radius', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    Text('${_config.eyeRadius.round()}', style: const TextStyle(fontSize: 13)),
                  ],
                ),
                Slider(
                  value: _config.eyeRadius,
                  min: 8.0,
                  max: 22.0,
                  onChanged: (v) => setState(() => _config = _config.copyWith(eyeRadius: v)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Eye gap', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    Text('${_config.eyeGap.round()}', style: const TextStyle(fontSize: 13)),
                  ],
                ),
                Slider(
                  value: _config.eyeGap,
                  min: 30.0,
                  max: 65.0,
                  onChanged: (v) => setState(() => _config = _config.copyWith(eyeGap: v)),
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _config.showBlush,
                      onChanged: (v) => _toggleAccessory(blush: _config.showBlush),
                    ),
                    const Text('Show blush (drawOval)', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
        ],

        // Accessories bar (Bonus)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
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
      ],
    );
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
        child: OrientationBuilder(
          builder: (context, orientation) {
            if (orientation == Orientation.landscape) {
              return Row(
                children: [
                  Expanded(
                    child: Center(child: _buildCanvasWidget()),
                  ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: _buildControls(),
                      ),
                    ),
                  ),
                ],
              );
            }
            return Column(
              children: [
                Expanded(
                  child: Center(child: _buildCanvasWidget()),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
                  child: _buildControls(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class SmileyPainter extends CustomPainter {
  SmileyPainter({
    required this.config,
    required this.faceColor,
  });

  final FaceConfig config;
  final Color faceColor;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide * 0.40;

    // Normalizing scaling factor relative to baseline 300px canvas (r = 120)
    final scale = r / 120.0;
    final eyeRadius = config.eyeRadius * scale;
    final eyeDx = config.eyeGap * scale;

    // === Layer Recipe (Painter's Algorithm) ===
    // 1) Face fill & Face Border
    final facePaint = Paint()
      ..color = faceColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(c, r, facePaint);

    final border = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.035;
    canvas.drawCircle(c, r, border);

    // 2) Eyes (Positioned symmetrically relative to center)
    final eyePaint = Paint()..color = Colors.black87;
    final eyeY = c.dy - r * 0.18;
    final leftEyeCenter = Offset(c.dx - eyeDx, eyeY);
    final rightEyeCenter = Offset(c.dx + eyeDx, eyeY);

    switch (config.faceType) {
      case FaceType.classic:
      case FaceType.robot:
        // Round eyes with cute specular catchlights
        canvas.drawCircle(leftEyeCenter, eyeRadius, eyePaint);
        canvas.drawCircle(rightEyeCenter, eyeRadius, eyePaint);

        final catchlightPaint = Paint()..color = Colors.white;
        final catchlightRadius = eyeRadius * 0.28;
        final catchlightOffset = Offset(-eyeRadius * 0.28, -eyeRadius * 0.28);
        canvas.drawCircle(leftEyeCenter + catchlightOffset, catchlightRadius, catchlightPaint);
        canvas.drawCircle(rightEyeCenter + catchlightOffset, catchlightRadius, catchlightPaint);
        break;

      case FaceType.winking:
        // Left eye open with catchlight, Right eye winking curve
        canvas.drawCircle(leftEyeCenter, eyeRadius, eyePaint);
        final catchlightPaint = Paint()..color = Colors.white;
        final catchlightRadius = eyeRadius * 0.28;
        canvas.drawCircle(leftEyeCenter + Offset(-eyeRadius * 0.28, -eyeRadius * 0.28), catchlightRadius, catchlightPaint);

        final winkPaint = Paint()
          ..color = Colors.black87
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.035
          ..strokeCap = StrokeCap.round;
        final winkRect = Rect.fromCenter(
          center: rightEyeCenter,
          width: eyeRadius * 2.2,
          height: eyeRadius * 1.4,
        );
        canvas.drawArc(winkRect, 1.15 * pi, 0.70 * pi, false, winkPaint);
        break;

      case FaceType.sleepy:
        final closedEyePaint = Paint()
          ..color = Colors.black87
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.032
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
          ..strokeWidth = r * 0.026;

        canvas.drawCircle(leftEyeCenter, surprisedEyeRadius, scleraPaint);
        canvas.drawCircle(leftEyeCenter, surprisedEyeRadius, eyeBorderPaint);
        canvas.drawCircle(rightEyeCenter, surprisedEyeRadius, scleraPaint);
        canvas.drawCircle(rightEyeCenter, surprisedEyeRadius, eyeBorderPaint);

        canvas.drawCircle(leftEyeCenter, surprisedEyeRadius * 0.5, eyePaint);
        canvas.drawCircle(rightEyeCenter, surprisedEyeRadius * 0.5, eyePaint);
        break;
    }

    // 3) Blush ovals (drawOval)
    if (config.showBlush && config.faceType != FaceType.robot) {
      final blushPaint = Paint()
        ..color = const Color(0xFFF472B6).withValues(alpha: 0.55)
        ..style = PaintingStyle.fill;
      final blushWidth = r * 0.24;
      final blushHeight = r * 0.13;
      final blushY = c.dy + r * 0.10;
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

    // 4) Mouth — dynamically configured per FaceType and mood
    final mouthPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.042
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (config.faceType) {
      case FaceType.classic:
      case FaceType.winking:
        if (config.mood > 0.70) {
          // Open-mouth beaming smile with dark cavity and tongue (matches demo screenshot!)
          final mouthWidth = r * 0.95;
          final mouthHeight = r * (0.35 + (config.mood - 0.70) * 0.65);
          final mouthTopY = c.dy + r * 0.16;
          final mouthLeftX = c.dx - mouthWidth * 0.45;
          final mouthRightX = c.dx + mouthWidth * 0.45;

          final openMouthPath = Path();
          openMouthPath.moveTo(mouthLeftX, mouthTopY);
          openMouthPath.quadraticBezierTo(c.dx, mouthTopY + r * 0.05, mouthRightX, mouthTopY);
          openMouthPath.quadraticBezierTo(c.dx, mouthTopY + mouthHeight, mouthLeftX, mouthTopY);
          openMouthPath.close();

          // Dark maroon cavity fill
          final cavityPaint = Paint()
            ..color = const Color(0xFF6B1115)
            ..style = PaintingStyle.fill;
          canvas.drawPath(openMouthPath, cavityPaint);

          // Tongue
          final tonguePaint = Paint()
            ..color = const Color(0xFFF43F5E)
            ..style = PaintingStyle.fill;
          canvas.save();
          canvas.clipPath(openMouthPath);
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset(c.dx, mouthTopY + mouthHeight * 0.85),
              width: mouthWidth * 0.50,
              height: mouthHeight * 0.55,
            ),
            tonguePaint,
          );
          canvas.restore();

          // Stroke border
          canvas.drawPath(openMouthPath, mouthPaint);
        } else if (config.mood >= 0.35) {
          // Neutral soft smile arc
          final mouthRect = Rect.fromCenter(
            center: Offset(c.dx, c.dy + r * 0.15),
            width: r * 1.0,
            height: r * (0.4 + config.mood * 0.5),
          );
          canvas.drawArc(mouthRect, 0.15 * pi, 0.70 * pi, false, mouthPaint);
        } else {
          // Frown arc
          final frownRect = Rect.fromCenter(
            center: Offset(c.dx, c.dy + r * 0.40),
            width: r * 0.9,
            height: r * 0.6,
          );
          canvas.drawArc(frownRect, 1.15 * pi, 0.70 * pi, false, mouthPaint);
        }
        break;

      case FaceType.sleepy:
        final sleepyMouthRect = Rect.fromCenter(
          center: Offset(c.dx, c.dy + r * 0.22),
          width: r * 0.6,
          height: r * 0.25,
        );
        canvas.drawArc(sleepyMouthRect, 0.1 * pi, 0.8 * pi, false, mouthPaint..strokeWidth = r * 0.03);
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

      case FaceType.robot:
        final mouthWidth = r * 0.82;
        final mouthY = c.dy + r * 0.20;
        canvas.drawLine(
          Offset(c.dx - mouthWidth * 0.5, mouthY),
          Offset(c.dx + mouthWidth * 0.5, mouthY),
          mouthPaint,
        );
        break;
    }

    // 5) Mustache accessory (Layered between nose and mouth)
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

    // 6) Glasses accessory (Layered over eyes)
    if (config.showGlasses) {
      final glassesPaint = Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.03;
      final glassesRadius = eyeRadius * 1.5;
      canvas.drawCircle(leftEyeCenter, glassesRadius, glassesPaint);
      canvas.drawCircle(rightEyeCenter, glassesRadius, glassesPaint);
      canvas.drawLine(
        Offset(leftEyeCenter.dx + glassesRadius, eyeY),
        Offset(rightEyeCenter.dx - glassesRadius, eyeY),
        glassesPaint,
      );
    }

    // 7) Hat accessory (Top layer)
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
        oldDelegate.config.eyeRadius != config.eyeRadius ||
        oldDelegate.config.eyeGap != config.eyeGap ||
        oldDelegate.config.showBlush != config.showBlush ||
        oldDelegate.config.showHat != config.showHat ||
        oldDelegate.config.showGlasses != config.showGlasses ||
        oldDelegate.config.showMustache != config.showMustache ||
        oldDelegate.faceColor != faceColor;
  }
}
