// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'package:app/Admin/Browse_Staff.dart';
import 'package:app/Admin/Dashboard_Staff.dart';
import 'package:app/Admin/History_Staff.dart';
import 'package:app/Admin/add.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class confirm_retrun extends StatelessWidget {
  const confirm_retrun({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: confirm_retrunScreen(),
    );
  }
}

class confirm_retrunScreen extends StatefulWidget {
  const confirm_retrunScreen({super.key});

  @override
  _confirm_retrunScreen createState() => _confirm_retrunScreen();
}

class _confirm_retrunScreen extends State<confirm_retrunScreen> {
  int _selectedIndex = 3;
  List<dynamic> returnBooks = [];
  Map<String, dynamic> profileData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReturnBook();
  }

  Future<void> fetchReturnBook() async {
    const url = 'http://192.168.1.189:3000/gotback';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          returnBooks = json.decode(response.body);
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

  Future<void> confirmReturn(int borrowId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    if (token == null) {
      showError("User is not authenticated.");
      return;
    }

    final url = Uri.parse(
        'http://192.168.1.189:3000/gotback/$borrowId'); // Replace with your API URL
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
      MaterialPageRoute(builder: (context) => const confirm_retrun()),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    Widget nextPage;
    switch (_selectedIndex) {
      case 0:
        nextPage = const BrowseStaff();
        break;
      case 1:
        nextPage = AddNewBook();
        break;
      case 2:
        nextPage = const HistoryStaff();
        break;
      case 3:
        nextPage = const confirm_retrunScreen();
        break;
      case 4:
        nextPage = const StaffDashboard();
        break;
      default:
        nextPage = const confirm_retrunScreen();
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
            'Returning Request',
            style: TextStyle(
              fontSize: 30,
              color: Colors.white,
              fontFamily: 'Jua',
            ),
          ),
          Expanded(
            child: returnBooks.isEmpty
                ? Center(
                    child: Text('No returning records found',
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Jua',
                            fontSize: 20)))
                : ListView.builder(
                    itemCount: returnBooks.length,
                    itemBuilder: (context, index) {
                      final borrow = returnBooks[index];
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
                                              'Borrowed date    :${borrow['borrow_date']}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Actor',
                                              ),
                                            ),
                                            Text(
                                              'Return date          :${borrow['return_date']}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Actor',
                                              ),
                                            ),
                                            Text(
                                              'Borrower              :${borrow['username']}',
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                confirmReturn(
                                                  borrow['borrow_id'],
                                                );
                                                _reload();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xFF59F38A),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                minimumSize: const Size(30, 30),
                                              ),
                                              child: const Text(
                                                'get it back',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontFamily: 'Jua',
                                                    fontSize: 14),
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
                  ? 'assets/images/App_selected.png'
                  : 'assets/images/App.png',
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
                  ? 'assets/images/return_selected.png'
                  : 'assets/images/return.png',
              width: 24,
              height: 24,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              _selectedIndex == 4
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
