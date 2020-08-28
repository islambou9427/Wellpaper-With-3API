import 'package:WellpaperUsing3Api/screenss/Home.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Beautiful Wallpapers",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: AppBarTheme(
          color: Colors.black87,
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: Home(),
    );
  }
}
