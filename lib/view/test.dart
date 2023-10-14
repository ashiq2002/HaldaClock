import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'progressive.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  int volume = 0;
  bool liked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CircularSlider(onAngleChanged: (double angle) {
        volume = ((angle / (math.pi * 2)) * 100).toInt();
        setState(() {});
      },),
    );
  }
}
