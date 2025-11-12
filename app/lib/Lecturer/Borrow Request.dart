// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/Lecturer/Browse_Lec.dart';
import 'package:app/Lecturer/Dashboard_Lec.dart';
import 'package:app/Lecturer/History_Lec.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Borrow_req extends StatelessWidget {
  const Borrow_req({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BorrowingScreen(),
    );
  }
}

class BorrowingScreen extends StatefulWidget {
  const BorrowingScreen({super.key});

  @override
  _BorrowingScreen createState() => _BorrowingScreen();
}

class _BorrowingScreen extends State<BorrowingScreen> {
  int _selectedIndex = 1;
  List<dynamic> pendingBorrows = [];
  Map<String, dynamic> profileData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPendingBorrows();
  }

  Future<void> fetchPendingBorrows() async {
    const url = 'http://192.168.1.189:3000/approves';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          pendingBorrows = json.decode(response.body);
        });
      } else if (response.statusCode == 404) {
        print("No pending borrow records found");
      } else {
        print("Failed to load data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

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
            'limit':
                (dataFromApi['limit'] == true || dataFromApi['limit'] == 'True')
                    ? 1
                    : 0,
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

  Future<void> approveBorrow(int borrowId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    if (token == null) {
      showError("User is not authenticated.");
      return;
    }

    final url = Uri.parse(
        'http://192.168.1.189:3000/approves/$borrowId'); // Replace with your API URL
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer $token', // Sending the token in the Authorization header
      },
      body: json.encode({
        'borrow_id': borrowId,
      }),
    );

    if (response.statusCode == 200) {
      showSuccess("The request has been approved.");
    } else if (response.statusCode == 400) {
      showError("Borrow ID is required.");
    } else if (response.statusCode == 401) {
      showError("User not authenticated.");
    } else if (response.statusCode == 403) {
      showError("Invalid or expired token.");
    } else if (response.statusCode == 404) {
      showError("No record found with this borrow_id.");
    } else {
      showError("An error occurred. Please try again.");
    }
  }

  Future<void> rejectBorrow(int borrowId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    if (token == null) {
      showError("User is not authenticated.");
      return;
    }

    final url = Uri.parse(
        'http://192.168.1.189:3000/rejects/$borrowId'); // Replace with your API URL
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'borrow_id': borrowId,
      }),
    );

    if (response.statusCode == 200) {
      showSuccess("The request has been rejected.");
    } else if (response.statusCode == 400) {
      showError("Borrow ID is required.");
    } else if (response.statusCode == 401) {
      showError("User not authenticated.");
    } else if (response.statusCode == 403) {
      showError("Invalid or expired token.");
    } else if (response.statusCode == 404) {
      showError("No record found with this borrow_id.");
    } else {
      showError("An error occurred. Please try again.");
    }
  }

  // Helper function to show success message
  void showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  // Helper function to show error message
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _reload() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Borrow_req()),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    Widget nextPage;
    switch (_selectedIndex) {
      case 0:
        nextPage = const BrowseLec();
        break;
      case 1:
        nextPage = const Borrow_req();
        break;
      case 2:
        nextPage = const HistoryLec();
        break;
      case 3:
        nextPage = const StaffDashboardState();
        break;
      default:
        nextPage = const BrowseLec();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5C1F56),
      body: Column(
        children: [
          const SizedBox(height: 50),
          const Text(
            'Borrowing Request',
            style: TextStyle(
              fontSize: 30,
              color: Colors.white,
              fontFamily: 'Jua',
            ),
          ),
          Expanded(
            child: pendingBorrows.isEmpty
                ? Center(
                    child: Text('No pending borrow records found',
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Jua',
                            fontSize: 20)))
                : ListView.builder(
                    itemCount: pendingBorrows.length,
                    itemBuilder: (context, index) {
                      final borrow = pendingBorrows[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Card(
                          color: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Row(
                              children: [
                                Image.network(
                                  borrow['image'] ?? '',
                                  width: 100,
                                  height: 164,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.book),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            borrow['book_name'] ?? 'No title',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              color: Colors.white,
                                              fontFamily: 'Jua',
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 43),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Borrowed date: ${borrow['borrow_date']}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Actor',
                                              ),
                                            ),
                                            Text(
                                              'Return date: ${borrow['return_date']}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Actor',
                                              ),
                                            ),
                                            Text(
                                              'Requested by: ${borrow['borrower_username']}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Actor',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: Row(
                                          children: [
                                            Flexible(
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  approveBorrow(
                                                    borrow['borrow_id'],
                                                  );
                                                  _reload();
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color(0xFFF9EE57),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  minimumSize:
                                                      const Size(30, 30),
                                                ),
                                                child: const Text(
                                                  'Approve',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontFamily: 'Jua',
                                                      fontSize: 14),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 25),
                                            Flexible(
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  rejectBorrow(
                                                    borrow['borrow_id'],
                                                  );
                                                  _reload();
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color(0xFFFF2525),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  minimumSize:
                                                      const Size(30, 30),
                                                ),
                                                child: const Text(
                                                  'Disapprove',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14,
                                                      fontFamily: 'Jua'),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              _selectedIndex == 0
                  ? 'assets/images/Home_selected.png'
                  : 'assets/images/Home.png',
              width: 24,
              height: 24,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              _selectedIndex == 1
                  ? 'assets/images/request_selected.png'
                  : 'assets/images/request.png',
              width: 24,
              height: 24,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              _selectedIndex == 2
                  ? 'assets/images/Vector_selected.png'
                  : 'assets/images/Vector.png',
              width: 24,
              height: 24,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              _selectedIndex == 3
                  ? 'assets/images/Das_selected.png'
                  : 'assets/images/Das.png',
              width: 24,
              height: 24,
            ),
            label: '',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF512E37),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }
}
