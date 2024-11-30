import 'package:coding_python/homescreen.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, 
      title: 'Interactive Python Compiler',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PythonCompilerScreen()
    );
  }
}

