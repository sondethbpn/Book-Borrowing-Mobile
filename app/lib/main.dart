import 'package:app/Admin/History_Staff.dart';
import 'package:flutter/material.dart';
import 'Mainpage.dart';
import 'Loginpage.dart';
import 'Signuppage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cosmic Book Rental',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Define routes
      initialRoute: '/',
      routes: {
        '/': (context) => const Mainpage(),
        '/login': (context) => const Loginpage(),
        '/signup': (context) => const Signuppage(),
        '/History_User': (context) => const HistoryScreen(),
      },
    );
  }
}
