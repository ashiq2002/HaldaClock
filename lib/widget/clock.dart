import 'dart:math';

import 'package:flutter/material.dart';

class ArcPainter extends CustomPainter {
  double arcAngle;

  ArcPainter(this.arcAngle);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw the arc
    final arcPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0;

    final arcRect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: size.width,
      height: size.height,
    );

    canvas.drawArc(
      arcRect,
      -pi / 4, // Start angle
      arcAngle, // Sweep angle
      false,
      arcPaint,
    );

    // Draw the draggable button
    const buttonRadius = 10.0;
    final buttonX = size.width / 2 + (size.width / 2 - buttonRadius) * cos(arcAngle - pi / 4);
    final buttonY = size.height / 2 + (size.height / 2 - buttonRadius) * sin(arcAngle - pi / 4);

    final buttonPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(buttonX, buttonY), buttonRadius, buttonPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class ArcWithDraggableButton extends StatefulWidget {
  @override
  _ArcWithDraggableButtonState createState() => _ArcWithDraggableButtonState();
}

class _ArcWithDraggableButtonState extends State<ArcWithDraggableButton> {
  double arcAngle = pi / 2; // Initial arc angle

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: GestureDetector(
        onPanUpdate: (details) {
          // Calculate the new arc angle based on the drag
          double newAngle = atan2(details.localPosition.dy - (size.height / 2),
              details.localPosition.dx - (size.width / 2));
          setState(() {
            arcAngle = newAngle + pi / 4;
          });
        },
        child: CustomPaint(
          size: Size(200, 200), // Set the desired size
          painter: ArcPainter(arcAngle),
        ),
      ),
    );
  }
}

