import 'package:flutter/material.dart';
import 'AudioRecord/view/record_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speech Recorder',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const RecordScreen(),
    );
  }
}
