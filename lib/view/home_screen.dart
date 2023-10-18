import 'dart:math';

import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double draggableButtonAngle = -pi / 2; // Initial angle (starts at 90 degrees)
  double arcAngle = 1.0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    debugPrint("rebuild");

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Circular Timer"),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      body: Center(
          child: Stack(alignment: Alignment.center, children: [
        CustomPaint(
          size: const Size(200, 200),
          painter: ProgressiveClock(arcAngle),
        ),
        const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "2",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 60,
                  color: Colors.black),
            ),
            Text(
              "Hour",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, color: Colors.black),
            ),
          ],
        ),
        Draggable(
          allowedButtonsFilter: (filter) {
            debugPrint("filter: $filter");
            return true;
          },
          onDragUpdate: (details) {
            //final newPosition = details.globalPosition;
            setState(() {
              // Calculate the angle of the draggable button based on drag movement
              final newPosition = details.localPosition;
              final centerX = size.width / 2;
              final centerY = size.height / 2;

              draggableButtonAngle =
                  atan2(newPosition.dy - centerY, newPosition.dx - centerX);

              // Ensure that the angle is within the range of -pi to pi
              draggableButtonAngle = draggableButtonAngle.clamp(-pi, pi);

              // Calculate the new arc angle based on the rotation of the draggable button
              arcAngle = (draggableButtonAngle / pi + 1.0) * 50.0;
            });

            //print("Angle : $angle");
          },
          feedback: const SizedBox(),
          child: CustomPaint(
            size: Size(size.height, size.width), // Set the desired size
            painter: ArcWithCircularDraggablePainter(draggableButtonAngle),
          ),
        ),
      ])),
    );
  }
}

//custom progressive clock
class ProgressiveClock extends CustomPainter {
  final double angle;

  Path path = Path();

  ProgressiveClock(this.angle);

  @override
  void paint(Canvas canvas, Size size) {
    //inner circle shadow list
    final List<Shadow> shadows = [
      Shadow(
        color: const Color(0xFFE8EAEF).withOpacity(0.4),
        blurRadius: 8,
        offset: const Offset(3.0, 3.0),
      ),
      Shadow(
        color: const Color(0xFFE8EAEF).withOpacity(0.3),
        blurRadius: 8,
        offset: const Offset(-3.0, 3.0),
      ),
      Shadow(
        color: const Color(0xFFE8EAEF).withOpacity(0.2),
        blurRadius: 6,
        offset: const Offset(-3.0, 3.0),
      ),
      Shadow(
        color: const Color(0xFFE8EAEF).withOpacity(0.1),
        blurRadius: 4,
        offset: const Offset(-3.0, 3.0),
      ),
    ]; //--------------------------------------------------------------------------------------------------

    //background arc paint
    var baseCirclePaint = Paint()
      ..color = const Color(0xFFE8EAEF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 55
      ..isAntiAlias = true;
    //--------------------background arc paint

    //inner circle paint
    var iPain = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..isAntiAlias = true;

    //progressive arc paint
    var arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 55
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..color = const Color(0xFF00AB82); //------progressive arc paint

    var path = Path();
    var center = Offset(
        size.height / 2, size.width / 2); // make shapes center inside screen

    double currentAngle =
        angle * (2 * pi) / 100; //progressive arc angle which is mutable

    //calculate the current arc angle
    // double currentAngle = (angle % 360 + 360) % 360;

    debugPrint("Current Angle : $angle");

    //circle
    final arcRect =
        Rect.fromCircle(center: center, radius: 130); // background arc rect

    canvas.drawCircle(
        center, 130, baseCirclePaint); //draw background arc circle

    path.addOval(Rect.fromCircle(
        center: center, radius: 105)); // add oval center into the arc

    for (var shadow in shadows) {
      //draw center oval shadow
      canvas.drawShadow(path, shadow.color, shadow.blurRadius, true);
    }
    canvas.drawPath(path, iPain); //finally draw the oval inside arc

    //draw the base or background arc
    canvas.drawArc(
        arcRect,
        0, //radians
        10, //radians
        false,
        baseCirclePaint);

    // Draw circles on the arc
    final insideDotPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 11; i++) {
      //
      final angle = -pi / 3 + (i / (3 - 1)) * (4 * pi / 11);

      final circleCenterX = size.width / 2 + 130 * cos(angle);
      final circleCenterY = size.height / 2 + 130 * sin(angle);
      const circleRadius = 3.0; // Adjust the radius as needed

      //draw n number of dots top of the background arc
      canvas.drawCircle(
          Offset(circleCenterX, circleCenterY), circleRadius, insideDotPaint);
    }

    //draw the progressive arc
    canvas.drawArc(
        arcRect,
        -pi / 2, //radians
        currentAngle, //radians
        false,
        arcPaint);
    //==============================end of the progressive clock base structure=======================
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ArcWithCircularDraggablePainter extends CustomPainter {
  double angle;

  ArcWithCircularDraggablePainter(this.angle);

  @override
  void paint(Canvas canvas, Size size) {
    double angle1 = 2 * pi * (angle / 10);

    debugPrint("Button Angle : $angle1");

    final circlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill; //draggable button paint

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    const radius = 130.0;

    final circleCenterX = centerX + radius * cos(angle);
    final circleCenterY = centerY + radius * sin(angle);

    const circleRadius = 15.0;

    //finally draw draggable button top of the progressive arc
    canvas.drawCircle(
        Offset(circleCenterX, circleCenterY), circleRadius, circlePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
