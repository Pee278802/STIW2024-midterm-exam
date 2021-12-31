import 'package:flutter/material.dart';
import 'package:rent_a_room/splashscreen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blueGrey),
      ),
      title: 'RentARoom',
      home: const Scaffold(
        body: SplashScreen(),
      ),
    );
  }
}
