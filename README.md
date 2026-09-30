# In-Class Activity 06 — Drawing with Flutter

**Student:** Adi Tauqir  
**Course:** Mobile Application Development  
**Semester:** Fall 2026  
**Track:** Undergraduate Track (with Bonus Challenges)

---

## Application Overview

A Flutter custom graphics application exploring the CustomPainter framework and the Canvas API to draw responsive, interactive, and expressive face illustrations with dynamic paint layer hierarchies, multiple facial expressions, and accessory toggles.

### Release APK
The compiled Android release APK is published and available for download under GitHub Releases:
- **GitHub Release:** [v1.0.0 Release with app-release.apk](https://github.com/aditauqir/In-Class-Activity-06-Drawing-with-Flutter/releases/tag/v1.0.0)
- **Local Artifact:** `build/app/outputs/flutter-apk/app-release.apk`

---

## Implemented Features

### Module 1: CustomPainter Basics
- Replaced starter app with CustomPaint and CustomPainter foundation.
- Configured dynamic paint(Canvas, Size) and shouldRepaint lifecycle contract.
- Connected mood state slider (0.0 sad to 1.0 happy).

### Module 2: Drawing Primitives
- Utilized drawCircle, drawRect, drawRRect, drawArc, drawOval, and drawPath.
- Integrated dart:math for radian-based angle transformations (pi).
- Configured stroke and fill Paint specifications with proper caps and joins.

### Module 3: Smiley Face Composition (Levels 1 & 2)
- Symmetrical eye placement calculated relative to center c and face radius r.
- Dynamic mouth drawArc mapping: smiling arc for happy moods, inverted/translated frown arc for sad moods.
- Dynamic color band logic: cool blue for sadness (< 0.35), classic yellow for neutral (0.35 - 0.70), and warm amber/orange for happiness (> 0.70).
- Blush ovals rendered using drawOval.

### Module 4: Paint Order & Layers
- Strictly ordered painter's algorithm recipe: Face Fill -> Border -> Eyes -> Blush -> Mouth -> Accessories.
- Eliminated layer clipping or overwrite bugs.

### Level 3: Multi-Face Gallery
- Added runtime switcher with SegmentedButton supporting 3 distinct styles:
  1. Classic: Standard filled eyes with dynamic mood smile arc.
  2. Sleepy: Closed curved eyelid arcs with soft gentle smile.
  3. Surprised: Wide-open sclera + pupil eyes with large oval open mouth.

### Level 4: Touch Interactions
- Wrapped CustomPaint in GestureDetector:
  - Single Tap: Cycles to the next face style.
  - Long Press: Randomizes face style, mood, and vibrant face colors.
- Interactive SnackBar feedback with prior messages cleared via clearSnackBars().

### Bonus: Accessories & Undo Stack
- Independent toggleable accessories via icon buttons:
  - Hat: Styled brim and crown using drawRRect.
  - Glasses: Dual circular wireframes and nasal bridge drawLine.
  - Mustache: Smooth curved mustache using drawPath and quadratic Bezier curves.
  - Blush: Toggleable cheek highlights.
- Undo History Stack: Backed by an immutable FaceConfig model with an AppBar Undo action button to revert to earlier configurations.

### Responsive Layout
- Fully responsive across phone screen sizes using OrientationBuilder.
- Seamless adaptation between portrait and landscape modes with zero RenderFlex overflow errors.

---

## Critical Thinking Gauntlet

Detailed responses to the assignment critical thinking prompts, including emulator screenshots and redraw analysis, are documented in:
- **[docs/critical_thinking.md](docs/critical_thinking.md)**
