// ignore_for_file: use_build_context_synchronously, avoid_print, library_private_types_in_public_api, use_super_parameters

import 'package:app/User/Browse_student.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Borrow extends StatelessWidget {
  final int bookId;

  const Borrow({Key? key, required this.bookId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BorrowRequestScreen(bookId: bookId),
    );
  }
}

class BorrowRequestScreen extends StatefulWidget {
  final int bookId;

  const BorrowRequestScreen({Key? key, required this.bookId}) : super(key: key);

  @override
  _BorrowRequestScreenState createState() => _BorrowRequestScreenState();
}

class _BorrowRequestScreenState extends State<BorrowRequestScreen> {
  late final String _borrowingDate;
  String? _returnDate;
  Map<String, dynamic>? bookData;
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    _borrowingDate = DateFormat('yyyy-MM-dd')
        .format(DateTime.now()); // Set borrowing date to today
    fetchBookData();
    fetchProfileData();
  }

  @override
  void didUpdateWidget(covariant BorrowRequestScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bookId != widget.bookId) {
      setState(() {
        isLoading = true;
        isError = false;
        bookData = null;
      });
      fetchBookData(); // Fetch new data for the updated bookId
      fetchProfileData();
    }
  }

  Future<void> fetchBookData() async {
    print("Fetching data for bookId: ${widget.bookId}"); // Debugging bookId
    final url =
        Uri.parse('http://192.168.1.189:3000/reqest/pagestd/${widget.bookId}');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          bookData = json.decode(response.body)[0];
          isLoading = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          isError = true;
          isLoading = false;
        });
        print("No records found for this book");
      } else {
        setState(() {
          isError = true;
          isLoading = false;
        });
        print("Server error");
      }
    } catch (e) {
      setState(() {
        isError = true;
        isLoading = false;
      });
      print("Failed to load book data: $e");
    }
  }

  Map<String, dynamic> profileData = {};

  Future<void> fetchProfileData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      if (token == null) {
        showErrorDialog("User not authenticated");
        return;
      }

      final response = await http.get(
        Uri.parse('http://192.168.1.189:3000/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final dataFromApi = json.decode(response.body);
        setState(() {
          profileData = {
            'user_id': dataFromApi['user_id'] ?? 'Unknown ID',
            'email': dataFromApi['email'] ?? 'Unknown Email',
            'username': dataFromApi['username'] ?? 'Unknown username',
            'role': dataFromApi['role'] ?? 'Unknown role',
            'limit': (dataFromApi['limit'] ?? 0),
          };
          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        showErrorDialog("User not authenticated or token expired");
      } else {
        showErrorDialog("Failed to retrieve data");
      }
    } catch (e) {
      showErrorDialog("Error: $e");
    }
  }

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

  Future<void> fetchBorrowData(
      int bookId, int userId, String returnDate) async {
    final url = 'http://192.168.1.189:3000/request/pagestd/$bookId';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'return_date': returnDate,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData['message'] ?? 'Request created successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'])),
        );
      } else {
        print('Server response: ${response.body}');
        throw Exception('Failed to create borrow request');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error creating borrow request')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context, bool isBorrowing) async {
    if (isBorrowing) return; // Borrowing date is always today, so do nothing

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          DateTime.now().add(const Duration(days: 1)), // Default to tomorrow
      firstDate: DateTime.now()
          .add(const Duration(days: 1)), // Allow selection from tomorrow
      lastDate: DateTime(2101),
    );

    if (picked != null && picked.isAfter(DateTime.now())) {
      DateTime borrowingDate = DateFormat('yyyy-MM-dd').parse(_borrowingDate);
      if (picked.isAfter(borrowingDate)) {
        setState(() {
          _returnDate = DateFormat('yyyy-MM-dd').format(picked);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Return date must be after borrowing date.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Return date must be after today.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5C1F56),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isError
              ? const Center(
                  child: Text("Error loading book data",
                      style: TextStyle(color: Colors.white)))
              : bookData == null
                  ? const Center(
                      child: Text("Book data is empty",
                          style: TextStyle(color: Colors.white)))
                  : buildContent(context),
    );
  }

  Widget buildContent(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 35.0),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const BrowseStudent()),
                    );
                  },
                ),
                const SizedBox(width: 3),
                const Text(
                  'Back',
                  style: TextStyle(
                      fontFamily: 'Jua', color: Colors.white, fontSize: 22),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              "Request To Borrow",
              style: TextStyle(
                  fontSize: 26, color: Colors.white, fontFamily: 'Jua'),
            ),
            const SizedBox(height: 10),
            Container(
              height: 344,
              width: 232,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(bookData!['image']),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(15.0),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              bookData?['book_name'] ?? 'Loading...',
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontFamily: 'Jua',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Your limit Today: ${profileData['limit']}",
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontFamily: 'Karma',
              ),
            ),

            const SizedBox(height: 40),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Borrowing Date Section
                      Column(
                        children: [
                          const Text(
                            "Borrowing date",
                            style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFE2BDBD),
                                fontFamily: 'Inder'),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _selectDate(context, true),
                            child: Container(
                              width: 122,
                              height: 34,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFDCDC),
                                border:
                                    Border.all(color: const Color(0xFFFFDCDC)),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _borrowingDate,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Column(
                        children: [
                          Image.asset(
                            'assets/images/Calendar.png',
                            width: 25,
                            height: 25,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "TO",
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontFamily: 'Jua'),
                          ),
                        ],
                      ),
                      const SizedBox(width: 15),
                      Column(
                        children: [
                          const Text(
                            "Return date",
                            style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFE2BDBD),
                                fontFamily: 'Inder'),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _selectDate(context, false),
                            child: Container(
                              width: 122,
                              height: 34,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFDCDC),
                                border:
                                    Border.all(color: const Color(0xFFFFDCDC)),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _returnDate ?? 'Select Date',
                                style: TextStyle(
                                  color: _returnDate == null
                                      ? Colors.grey
                                      : Colors.black,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Borrow Now Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: profileData['limit'] == "False"
                    ? const Color.fromARGB(
                        255, 89, 119, 125) // Grey if unclickable
                    : const Color(0xFFFC0771),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 7),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                if (profileData['limit'] == "True") {
                  if (_returnDate != null) {
                    try {
                      await fetchBorrowData(
                          widget.bookId, profileData['user_id'], _returnDate!);
                      print("Borrow request for book ID: ${widget.bookId}");
                      await Future.delayed(const Duration(seconds: 2));
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const BrowseStudent()),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Failed to create borrow request')),
                      );
                      print("Error: $e");
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please select a return date')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('You can borrow only 1 time per day')),
                  );
                }
              },
              child: const Text(
                "Borrow Now",
                style: TextStyle(
                    color: Colors.white, fontSize: 18, fontFamily: 'Jua'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
