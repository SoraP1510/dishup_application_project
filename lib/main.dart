import 'package:flutter/material.dart';
import 'home_page.dart'; // We'll create this next

void main() {
  runApp(const DishUpApp());
}

class DishUpApp extends StatelessWidget {
  const DishUpApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DishUp',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[850],
        fontFamily: 'Arial',
      ),
      home: HomePage(),
    );
  }
}
