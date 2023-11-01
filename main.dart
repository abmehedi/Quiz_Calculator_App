import 'package:flutter/material.dart';
import 'quiz_screen.dart';
import 'login_screen.dart';
import 'calculator_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool userIsLoggedIn = false;

    return MaterialApp(
      title: 'Md Mehedi Hasan Topu',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: userIsLoggedIn ? '/quiz' : '/login', // Add a comma here
      routes: {
        '/login': (context) => LoginScreen(),
        '/quiz': (context) => QuizScreen(),
        '/calculator': (context) => CalculatorScreen(),
      },
    );
  }
}
