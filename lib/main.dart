import 'package:flutter/material.dart';
import 'package:v_crag/services/crag_ar_screen.dart';
import 'package:v_crag/services/file_path_test.dart';
import 'package:v_crag/map_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  final String filePath = 'assets/crag_data.json';
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: MapScreen(),
      home: CragsARScreen(),
    );
  }
}


