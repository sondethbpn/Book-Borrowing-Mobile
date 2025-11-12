import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/Mainpage.dart';
import 'package:app/loginpage.dart';
import 'package:flutter/material.dart';

class Signuppage extends StatefulWidget {
  const Signuppage({super.key});

  @override
  _Signuppage createState() => _Signuppage();
}

class _Signuppage extends State<Signuppage> {
  bool _obscureText1 = true;
  bool _obscureText2 = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final String _responseMessage = "";

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    String username = _nameController.text.trim();
    String userId = _idController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (username.isEmpty ||
        userId.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      throw 'All fields are required. Please fill out all the fields.';
    }

    // Check if passwords match
    if (password != confirmPassword) {
      throw 'Passwords do not match'; // Specific error if passwords don't match
    }

    final url = Uri.parse(
        'http://192.168.1.189:3000/register'); // Replace with your backend URL

    try {
      // Send a POST request to the server
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'userId': userId,
          'email': email,
          'password': password,
        }),
      );

      // Print the response for debugging purposes
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Check the response status
      if (response.statusCode == 200) {
        // Registration successful
        return; // Registration was successful, return to indicate success
      } else if (response.statusCode == 400) {
        // Parse the response body as JSON
        var responseBody = json.decode(response.body);

        // Ensure the responseBody is a valid map
        if (responseBody != null && responseBody is Map<String, dynamic>) {
          String errorMessage =
              responseBody['error'] ?? 'Unknown error occurred';

          // Log the error message for debugging
          print('Error message: $errorMessage');
          if (errorMessage == 'duplicate_username') {
            throw 'Username already exists.';
          } else if (errorMessage == 'duplicate_userId') {
            throw 'User ID already exists.';
          } else if (errorMessage == 'duplicate_email') {
            throw 'Email already exists.';
          } else {
            throw 'Registration failed: $errorMessage';
          }
        } else {
          // If the response doesn't have the expected format
          throw 'Unexpected response format. Please try again later.';
        }
      } else {
        // Handle other HTTP status codes (e.g., 500 for server errors)
        throw 'Server error. Please try again later.';
      }
    } catch (e) {
      // Catch network errors or other exceptions
      print('Network or other error: $e');
      throw 'Network error: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/images/Background.jfif',
            fit: BoxFit.cover,
          ),
          // Overlay with content
          Container(
            color: Colors.black.withOpacity(0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
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
                  const SizedBox(height: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment
                        .center, // Center the column vertically
                    crossAxisAlignment: CrossAxisAlignment
                        .center, // Center the column horizontally
                    children: [
                      // Sign Up Text
                      const Text(
                        'Sign Up',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontFamily: 'Alkalami'),
                      ),
                      const Text(
                        'Create an account to continue!',
                        style: TextStyle(
                            color: Color(0xFF6C7278),
                            fontSize: 14,
                            fontFamily: 'Inter'),
                      ),
                      const SizedBox(height: 30),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Full Name',
                            style: TextStyle(
                              color: Color(0xFF6C7278),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                              height: 3), // Spacing between label and TextField
                          SizedBox(
                            width: 300, // Set a custom width for the TextField
                            height: 60, // Set a custom height for the TextField
                            child: TextField(
                              controller: _nameController,
                              style: const TextStyle(color: Colors.white),
                              obscureText:
                                  false, // Change to false for a name input
                              decoration: InputDecoration(
                                hintText: 'Lois',
                                hintStyle:
                                    const TextStyle(color: Color(0xFFAAABAC)),
                                filled: true,
                                fillColor: Colors.black.withOpacity(1),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF669EBA)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF669EBA)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Student ID',
                            style: TextStyle(
                              color: Color(0xFF6C7278),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                              height: 3), // Spacing between label and TextField
                          SizedBox(
                            width: 300, // Set a custom width for the TextField
                            height: 60, // Set a custom height for the TextField
                            child: TextField(
                              controller: _idController,
                              style: const TextStyle(color: Colors.white),
                              obscureText:
                                  false, // Change to false for a student ID input
                              decoration: InputDecoration(
                                hintText: '10152135',
                                hintStyle:
                                    const TextStyle(color: Color(0xFFAAABAC)),
                                filled: true,
                                fillColor: Colors.black.withOpacity(1),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF669EBA)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF669EBA)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Email',
                            style: TextStyle(
                              color: Color(0xFF6C7278),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                              height: 3), // Spacing between label and TextField
                          SizedBox(
                            width: 300, // Set a custom width for the TextField
                            height: 60, // Set a custom height for the TextField
                            child: TextField(
                              controller: _emailController,
                              style: const TextStyle(color: Colors.white),
                              obscureText:
                                  false, // Change to false for a name input
                              decoration: InputDecoration(
                                hintText: 'Loisbecket@gmail.com',
                                hintStyle:
                                    const TextStyle(color: Color(0xFFAAABAC)),
                                filled: true,
                                fillColor: Colors.black.withOpacity(1),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF669EBA)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF669EBA)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Set Password',
                            style: TextStyle(
                              color: Color(0xFF6C7278),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                              height: 3), // Spacing between label and TextField
                          SizedBox(
                            width: 300, // Set a custom width for the TextField
                            height: 60, // Set a custom height for the TextField
                            child: TextField(
                              controller: _passwordController,
                              style: const TextStyle(color: Colors.white),
                              obscureText: _obscureText1,
                              decoration: InputDecoration(
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _obscureText1 = !_obscureText1;
                                    });
                                  },
                                  child: Icon(_obscureText1
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                ),
                                hintText: '********',
                                hintStyle:
                                    const TextStyle(color: Color(0xFFAAABAC)),
                                filled: true,
                                fillColor: Colors.black.withOpacity(1),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF669EBA)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF669EBA)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Comfirm Password',
                            style: TextStyle(
                              color: Color(0xFF6C7278),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                              height: 3), // Spacing between label and TextField
                          SizedBox(
                            width: 300, // Set a custom width for the TextField
                            height: 60, // Set a custom height for the TextField
                            child: TextField(
                              controller: _confirmPasswordController,
                              style: const TextStyle(color: Colors.white),
                              obscureText: _obscureText2,
                              decoration: InputDecoration(
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _obscureText2 = !_obscureText2;
                                    });
                                  },
                                  child: Icon(_obscureText2
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                ),
                                hintText: '********',
                                hintStyle:
                                    const TextStyle(color: Color(0xFFAAABAC)),
                                filled: true,
                                fillColor: Colors.black.withOpacity(1),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF669EBA)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF669EBA)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: Text(_responseMessage),
                  ),
                  // Register Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Registering... Please wait')),
                        );
                        try {
                          await register();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Loginpage(),
                            ),
                          );
                        } catch (error) {
                          // Handle the error if registration fails
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(error.toString()),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F367B),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 120, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(
                            color: Color.fromARGB(255, 123, 59, 233),
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ),

                  // Login Option
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account?",
                          style: TextStyle(
                              color: Color(0xFF6C7278),
                              fontSize: 14,
                              fontFamily: 'Inter'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Loginpage()),
                            );
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(
                                color: Color(0xFF286AEA),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Inter'),
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

  // Helper method to build a TextField with icon and styling
  Widget _buildTextField(BuildContext context,
      {required String hintText,
      required IconData icon,
      bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.black.withOpacity(0.7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
