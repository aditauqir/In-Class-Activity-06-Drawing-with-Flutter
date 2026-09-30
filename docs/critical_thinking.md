# In-Class Activity 06: Drawing with Flutter - Critical Thinking & Analysis

**Student:** Adi Tauqir  
**Course:** Mobile Application Development  
**Date:** September 30, 2026  
**Track:** Undergraduate Track (with Bonus Challenges & Advanced Analysis)

---

## 1. Coordinate Choices and Geometric Formulas

To construct a balanced and expressive smiley face, I avoided hard-coding static pixel values and instead derived every position directly from the Canvas bounds:

### Mathematical Specification & Pre-Coding Sketch
Before writing the drawing code, I planned out the geometry using fractional coordinates relative to the canvas center `c` and face radius `r`:

| Visual Element | Target Geometry | Exact Mathematical Formula | Rationale |
| :--- | :--- | :--- | :--- |
| **Face Center** | Canvas midpoint | `c = Offset(size.width / 2, size.height / 2)` | Centers the face regardless of container dimensions. |
| **Face Radius** | Circular boundary | `r = size.shortestSide * 0.40` | Uses shortest side to prevent clipping or oval distortion in landscape. |
| **Eye Positions** | Symmetrical offsets | `leftEye = Offset(c.dx - eyeDx, eyeY)`<br>`rightEye = Offset(c.dx + eyeDx, eyeY)`<br>`eyeY = c.dy - r * 0.18`<br>`eyeDx = (r * 0.35) * (eyeGap / 48.0)` | Anchors eyes at natural facial proportions with dynamic gap adjustment. |
| **Pupils & Highlights** | Circles with specular dot | Pupil: radius `(r * 0.12) * (eyeRadiusSlider / 14.0)`<br>Catchlight: radius `pupilRadius * 0.28` at `Offset(-pupilRadius * 0.28, -pupilRadius * 0.28)` | Specular reflection adds visual life and depth to the eyes. |
| **Mouth Bounding Box** | Oval boundary `Rect` | `mouthRect = Rect.fromCenter(center: Offset(c.dx, c.dy + r * 0.15), width: r * 1.0, height: r * (0.40 + mood * 0.50))` | Bounding box scales its vertical height with mood (0.0 sad to 1.0 happy). |
| **Smile Arc** | Clockwise lower curve | `startAngle = 0.15 * pi`<br>`sweepAngle = 0.70 * pi` | Radians start just below 3 o'clock and sweep clockwise across 6 o'clock. |
| **Frown Arc** | Inverted upper curve | Translated by `Offset(0, r * 0.25)`<br>`startAngle = 1.15 * pi`<br>`sweepAngle = 0.70 * pi` | Sweeps across the top of the shifted oval to create an authentic sad curve. |
| **Beaming Smile** | Filled mouth cavity | `quadraticBezierTo` top & bottom curves with maroon cavity (`#6B1115`) and pink tongue (`#F43F5E`) | Provides an open-mouth beaming expression for `mood > 0.70`. |

### Pre-Coding Spatial Planning
When planning the drawing, I sketched out the facial landmarks on paper using the canvas center as my reference origin. I determined that placing the eyes at approximately 18% above the vertical center (`c.dy - r * 0.18`) and spacing them 35% of the radius horizontally (`r * 0.35`) established natural, balanced facial proportions. For the mouth, I anchored the bounding rectangle at 15% below the center (`c.dy + r * 0.15`) with a width equal to the full radius (`r * 1.0`). By setting the sweep angle to `0.70 * pi` and starting at `0.15 * pi`, the arc begins slightly below the 3 o'clock position, curves smoothly through the 6 o'clock bottom, and finishes near 9 o'clock. Planning these spatial relationships on paper before coding ensured that every feature scaled harmoniously with the face radius.

---

## 2. Why Basing Measurements on Size and Radius Makes the Drawing Responsive

If I had used hard-coded pixel offsets (such as setting the mouth width to 150 pixels or stroke width to 5 pixels), the face would look severely distorted across different screen sizes:
* On a small phone screen (e.g. 320 logical pixels wide), a hard-coded 150-pixel mouth would take up nearly half the screen width and burst outside the face circle.
* On a large tablet screen or high-resolution display (e.g. 800 logical pixels wide), a hard-coded 150-pixel mouth would look like a tiny, detached mark in the center of a gigantic face.
* Furthermore, if I had defined the face radius using `size.width * 0.40` instead of `size.shortestSide * 0.40`, the face would severely clip when rotated to landscape mode. In landscape, width is typically 800 pixels while height is only 360 pixels. Calculating radius from width would yield `800 * 0.40 = 320` pixels, which is larger than the available vertical half-height (`180` pixels), causing the top and bottom of the head to be clipped off screen.

By calculating every single dimension as a fractional multiple of `size.shortestSide` and `r`:
1. The face always maintains an exact 1:1 circular aspect ratio regardless of container dimensions.
2. The stroke widths (`r * 0.035`), pupil sizes, blush ovals, and mouth curvatures scale in lockstep with the face circle.
3. The drawing looks identical in sharpness, balance, and proportions across low-density phones, high-density phones, and tablets.

---

## 3. Phone Emulator Observations in Portrait and Landscape

I tested the application on an Android phone emulator (`sdk gphone16k arm64`, 1080x2400 physical display) across both orientations:

### Portrait Mode Observations
In portrait orientation, the canvas has ample vertical space. The smiley face centers comfortably inside an `Expanded` widget, occupying approximately 300x300 logical pixels, while the lower half of the screen houses the preset chips, segmented buttons, sliders, and accessory toggles without any crowding.

### Landscape Mode Observations
When I rotated the phone emulator into landscape mode, the vertical screen height dropped significantly to around 360 logical pixels, while the horizontal width expanded to 800 logical pixels. Initially, a standard vertical `Column` layout caused the controls to overflow off the bottom edge, triggering Flutter's yellow-and-black striped `RenderFlex` overflow error (overflowed by approximately 180 pixels).

### The Exact Layout Change I Made to Ensure Responsiveness
To resolve this issue and keep the UI completely responsive:
1. I wrapped the root layout in an `OrientationBuilder`.
2. When `orientation == Orientation.landscape`, the layout switches dynamically from a vertical `Column` to a horizontal `Row`.
3. In this horizontal `Row`:
   * The left side displays the centered `CustomPaint` canvas. I wrapped it in a `LayoutBuilder` and clamped its dimensions using `min(constraints.maxWidth, constraints.maxHeight).clamp(160.0, 320.0)` so it scales down gracefully and never clips the screen edges.
   * The right side displays the controls panel wrapped inside an `Expanded` and a `SingleChildScrollView`.
4. I ensured all row controls (such as the mood labels, preset chips, and segmented buttons) utilize flexible wrapping so they never cause horizontal clipping.

This change completely eliminated all layout overflow errors, kept the drawing centered and sharp, and ensured that all interactive controls remain easily accessible on any phone or tablet form factor.

---

## 4. Paint Order & Layers (The Painter's Algorithm)

Canvas drawing strictly adheres to the painter's algorithm: draw calls execute sequentially onto the pixel buffer, and whatever is drawn later paints on top of whatever was drawn earlier.

### Micro-Activity Experiment: Reversing the Draw Order
During my implementation, I tested what happens when the layer order is modified:
* **Expected Order:**
  1. Face fill (`canvas.drawCircle(c, r, facePaint)`)
  2. Face border (`canvas.drawCircle(c, r, borderPaint)`)
  3. Eyes and catchlights (`canvas.drawCircle(...)`)
  4. Blush ovals (`canvas.drawOval(...)`)
  5. Mouth arc / cavity (`canvas.drawArc(...)` or `canvas.drawPath(...)`)
  6. Accessories: Hat, Glasses, Mustache (`drawRRect`, `drawLine`, `drawPath`)
* **Failure Mode (Hat drawn before Face):** When I temporarily moved the hat draw call before the face circle, the hat completely disappeared from the screen. Because the face is drawn with an opaque yellow fill (`PaintingStyle.fill`), painting the face circle at `c` with radius `r` immediately overwrote the pixels where the hat had just been rendered.
* **Key Takeaway:** If a layer disappears, it is almost always a paint-order defect rather than a coordinate error. Subordinate features (eyes, blush, mouth, accessories) must always be drawn *after* background and base container shapes.

---

## 5. The shouldRepaint Decision and Redraw Analysis

The `shouldRepaint` method acts as Flutter's performance gatekeeper for custom drawing:

### Why shouldRepaint Returns True on Input Changes
When the user drags the mood slider, toggles accessories, adjusts the eye gap or radius, or selects a preset face style, the painter receives new parameters. Returning `true` informs Flutter that the existing canvas recording is invalid. Flutter immediately schedules a new paint frame and calls `paint(Canvas, Size)` to recompute the arc geometry and repaint the canvas. This guarantees immediate, real-time 60/120 fps visual feedback.

### Why shouldRepaint Returns False on Identical State
When parent widgets rebuild due to events that do not affect the drawing (such as displaying a SnackBar notification, keyboard visibility changes, or parent state updates), the painter's inputs remain identical. Returning `false` tells Flutter to skip the `paint()` method entirely and reuse the cached raster picture from the compositing layer. This avoids unnecessary CPU and GPU calculations and conserves device battery.

### Comparison: Always Returning True vs Comparing Painter Fields
I tested both implementations on the Android phone emulator using the Flutter DevTools CPU Profiler and Performance Overlay:
* **Version A: Always Returning True (`return true;`):**
  * Every single widget rebuild (even an unrelated SnackBar update or ticker event) forced Flutter to discard the raster cache and execute every single `drawCircle`, `drawArc`, `drawOval`, and `drawPath` operation again.
  * In DevTools, this caused continuous CPU raster spikes even when the user was not interacting with the smiley face.
* **Version B: Field Comparison Pattern:**
  * I compared every configurable input field between the old and new painter:
    ```dart
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
    ```
  * In DevTools, idle frame times dropped to 0 ms because the raster cache was preserved. Redraws only occurred during active slider dragging or button taps, delivering silky-smooth 60 fps responsiveness.

**Final Recommendation:** Production Flutter apps should always use the field comparison pattern. Comparing primitive values (`double`, `bool`, `Color`, `enum`) takes negligible CPU cycles (`O(1)` comparisons) while saving hundreds of vector drawing operations per second.

---

## 6. Success Criteria Verification Checklist

| Rubric Requirement | Status | Evidence in Implementation |
| :--- | :--- | :--- |
| **Smile arc is centered and uses drawArc** | [x] PASSED | Centered on `c.dx`, bounded by `Rect.fromCenter`, using `0.15 * pi` to `0.70 * pi` radians. |
| **Mouth coordinates based on size or radius** | [x] PASSED | Bounding box width is `r * 1.0` and height is `r * (0.40 + mood * 0.50)`. No hard-coded pixel values. |
| **Portrait and landscape tested on emulator** | [x] PASSED | Tested on Android emulator; verified zero overflow errors via `OrientationBuilder`. |
| **I can explain the shouldRepaint decision** | [x] PASSED | Thoroughly analyzed in Section 5 with DevTools profiling comparison. |
| **Painter's algorithm & layering verified** | [x] PASSED | Tested hat order failure mode; verified visual stack in Section 4. |
| **Bonus accessories + undo stack implemented** | [x] PASSED | Hat, glasses, mustache toggle independently; undo stack restores previous `FaceConfig`. |

---

## 7. Phone Emulator Evidence Artifacts

The following screenshots were captured directly from the running Android emulator to document each milestone. Each image is linked directly to its high-resolution file on the GitHub repository:

### Figure 1: Classic Beaming Smiley in Portrait Mode
Centered smiley face with catchlights, blush ovals, open-mouth maroon cavity fill, and mood slider at 0.85.  
[![Classic Happy Smiley in Portrait Mode](https://raw.githubusercontent.com/aditauqir/In-Class-Activity-06-Drawing-with-Flutter/main/docs/screenshot_portrait_happy.png)](https://github.com/aditauqir/In-Class-Activity-06-Drawing-with-Flutter/blob/main/docs/screenshot_portrait_happy.png)  
[View screenshot_portrait_happy.png on GitHub](https://github.com/aditauqir/In-Class-Activity-06-Drawing-with-Flutter/blob/main/docs/screenshot_portrait_happy.png)

### Figure 2: Responsive Landscape Mode (No Overflows)
Side-by-side Row layout in landscape mode with centered drawing on the left and scrollable controls on the right.  
[![Responsive Landscape Mode](https://raw.githubusercontent.com/aditauqir/In-Class-Activity-06-Drawing-with-Flutter/main/docs/screenshot_landscape.png)](https://github.com/aditauqir/In-Class-Activity-06-Drawing-with-Flutter/blob/main/docs/screenshot_landscape.png)  
[View screenshot_landscape.png on GitHub](https://github.com/aditauqir/In-Class-Activity-06-Drawing-with-Flutter/blob/main/docs/screenshot_landscape.png)

### Figure 3: Sad Mood and Color Band Logic
Sad preset applied with mood at 0.20, light blue face color, inverted frown arc, and SnackBar feedback.  
[![Mood Slider and Color Band Logic](https://raw.githubusercontent.com/aditauqir/In-Class-Activity-06-Drawing-with-Flutter/main/docs/screenshot_portrait_sad.png)](https://github.com/aditauqir/In-Class-Activity-06-Drawing-with-Flutter/blob/main/docs/screenshot_portrait_sad.png)  
[View screenshot_portrait_sad.png on GitHub](https://github.com/aditauqir/In-Class-Activity-06-Drawing-with-Flutter/blob/main/docs/screenshot_portrait_sad.png)

### Figure 4: Bonus Accessories and Stacking Order
Painter's algorithm visual stacking order: Hat (`drawRRect`), Glasses (`drawCircle` + `drawLine`), and Mustache (`drawPath`).  
[![Bonus Accessories](https://raw.githubusercontent.com/aditauqir/In-Class-Activity-06-Drawing-with-Flutter/main/docs/screenshot_bonus_accessories.png)](https://github.com/aditauqir/In-Class-Activity-06-Drawing-with-Flutter/blob/main/docs/screenshot_bonus_accessories.png)  
[View screenshot_bonus_accessories.png on GitHub](https://github.com/aditauqir/In-Class-Activity-06-Drawing-with-Flutter/blob/main/docs/screenshot_bonus_accessories.png)

### Figure 5: Module 3 Fine-Tuning Composer
Fine-tuning panel expanded showing live Eye radius slider (14), Eye gap slider (48), and blush toggle.  
[![Fine-Tuning Eye Radius and Gap](https://raw.githubusercontent.com/aditauqir/In-Class-Activity-06-Drawing-with-Flutter/main/docs/screenshot_module3_composer.png)](https://github.com/aditauqir/In-Class-Activity-06-Drawing-with-Flutter/blob/main/docs/screenshot_module3_composer.png)  
[View screenshot_module3_composer.png on GitHub](https://github.com/aditauqir/In-Class-Activity-06-Drawing-with-Flutter/blob/main/docs/screenshot_module3_composer.png)

### Figure 6: Robot Preset Matching Workshop Demo
Lime green circular face (`#A3E635`), soft smile at 0.50 with flat horizontal mouth line, 18 radius eyes with catchlights, and blush disabled.  
[![Robot Preset](https://raw.githubusercontent.com/aditauqir/In-Class-Activity-06-Drawing-with-Flutter/main/docs/screenshot_robot.png)](https://github.com/aditauqir/In-Class-Activity-06-Drawing-with-Flutter/blob/main/docs/screenshot_robot.png)  
[View screenshot_robot.png on GitHub](https://github.com/aditauqir/In-Class-Activity-06-Drawing-with-Flutter/blob/main/docs/screenshot_robot.png)


