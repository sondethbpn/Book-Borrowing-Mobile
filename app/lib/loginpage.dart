import 'dart:convert';
import 'package:app/Admin/Browse_Staff.dart';
import 'package:app/Lecturer/Browse_Lec.dart';
import 'package:app/Mainpage.dart';
import 'package:app/User/Browse_student.dart';
import 'package:app/signuppage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  _Loginpage createState() => _Loginpage();
}

class _Loginpage extends State<Loginpage> {
  bool _obscureText = true;
  final TextEditingController identifierController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> login() async {
    final String identifier = identifierController.text;
    final String password = passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Please enter both email/username and password.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.189:3000/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'identifier': identifier, 'password': password}),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['token'] != null && data['role'] != null) {
          final token = data['token'];
          final role = data['role'];

          // Store token in SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('authToken', token);

          print('Token saved: $token');
          print('Parsed role: $role');

          if (role == 'student') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const BrowseStudent()),
            );
          } else if (role == 'staff') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const BrowseStaff()),
            );
          } else if (role == 'lecturer') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const BrowseLec()),
            );
          }
        } else {
          showErrorDialog('Failed to parse token or role.');
        }
      } else {
        showErrorDialog('Login failed: ${response.body}');
      }
    } catch (e) {
      showErrorDialog('Error: $e');
    }
  }

// Helper function to show an error dialog
  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/Background.jfif',
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withOpacity(0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      const SizedBox(
                        height: 50,
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Mainpage()),
                              );
                            },
                          ),
                          const SizedBox(width: 3),
                          const Text(
                            'Back',
                            style: TextStyle(
                                fontFamily: 'Jua',
                                color: Colors.white,
                                fontSize: 22),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Add a Padding to move the content down
                  const Padding(
                    padding:
                        EdgeInsets.only(top: 20.0), // 50 pixels from the top
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 50),
                        Center(
                          child: Text(
                            'Welcome Back!!!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Inknit',
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: Text(
                            'Login to your account',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontFamily: 'Inknit',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Email TextField
                  TextField(
                    controller: identifierController, // Add this line
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixIcon: Container(
                        padding: const EdgeInsets.all(8.0),
                        width: 24,
                        height: 24,
                        child: Image.asset(
                          'assets/images/Mailicon.png',
                        ),
                      ),
                      hintText: 'Student ID Or Email',
                      hintStyle: const TextStyle(color: Color(0xFF828282)),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF3949AB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF3949AB)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Password TextField
                  TextField(
                    controller: passwordController,
                    style: const TextStyle(color: Colors.white),
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      prefixIcon: Container(
                        padding: const EdgeInsets.all(8.0),
                        width: 22,
                        height: 22,
                        child: Image.asset(
                          'assets/images/Lock.png',
                        ),
                      ),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                        child: Icon(_obscureText
                            ? Icons.visibility
                            : Icons.visibility_off),
                      ),
                      hintText: 'Password',
                      hintStyle: const TextStyle(color: Color(0xFF828282)),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF3949AB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF3949AB)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 120),

                  // Login Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        await login();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF582E7F),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 100, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      child: const Text(
                        'Log in',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Sign Up Option
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account?",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontFamily: 'Inknit',
                              fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Signuppage()),
                            );
                          },
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Color(0xFF7B85C2),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class F {}
