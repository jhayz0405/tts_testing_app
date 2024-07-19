import 'package:flutter/material.dart';
import 'ui/tts_evaluation_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TTS Evaluation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TTSEvaluationScreen(),
    );
  }
}
