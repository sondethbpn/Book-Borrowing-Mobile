import 'package:app/User/Browse_student.dart';
import 'package:app/User/RequestStatus.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HistoryStudent extends StatelessWidget {
  const HistoryStudent({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HistoryScreen(),
    );
  }
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _selectedIndex = 1;
  bool isLoading = true;
  String errorMessage = '';
  List<dynamic> borrowHistory = [];

  @override
  void initState() {
    super.initState();
    fetchBorrowHistory();
  }

  Future<void> fetchBorrowHistory() async {
    // Get the token from shared preferences or any other method
    String? token = await _getToken();

    if (token == null) {
      setState(() {
        errorMessage = 'User not authenticated';
        isLoading = false;
      });
      return;
    }

    final response = await http.get(
      Uri.parse('http://192.168.1.189:3000/history/std'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        borrowHistory = json.decode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        errorMessage = 'Error: ${response.statusCode}';
        isLoading = false;
      });
    }
  }

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');
    if (token == null) {
      _showErrorDialog("User not authenticated");
    }
    return token;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    Widget nextPage;
    switch (_selectedIndex) {
      case 0:
        nextPage = const HomeScreen();
        break;
      case 1:
        nextPage = const HistoryStudent();
        break;
      case 2:
        nextPage = const Requeststatus();
        break;
      default:
        nextPage = const HomeScreen();
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
            'History',
            style: TextStyle(
              fontSize: 30,
              color: Colors.white,
              fontFamily: 'Jua',
            ),
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            )
          else if (errorMessage.isNotEmpty)
            Center(
              child: Text(
                errorMessage,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontFamily: 'Actor',
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: borrowHistory.length,
                itemBuilder: (context, index) {
                  final book = borrowHistory[index];
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Card(
                      color: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Image.network(
                              book['image'] ?? 'assets/default_book_image.png',
                              width: 100,
                              height: 164,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        book['book_name'] ?? 'No Title',
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
                                          'Borrowed date: ${book['borrow_date'] ?? 'N/A'}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Actor',
                                          ),
                                        ),
                                        Text(
                                          'Approver: ${book['approver_username'] ?? 'N/A'}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Actor',
                                          ),
                                        ),
                                        Text(
                                          'Return date: ${book['return_date'] ?? 'N/A'}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Actor',
                                          ),
                                        ),
                                        Text(
                                          'Status: ${book['status'] ?? 'N/A'}',
                                          style: TextStyle(
                                            color: book['status'] == 'Approved'
                                                ? Colors.green
                                                : Colors.red,
                                            fontFamily: 'Actor',
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
                  ? 'assets/images/Vector_selected.png'
                  : 'assets/images/Vector.png',
              width: 24,
              height: 24,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              _selectedIndex == 2
                  ? 'assets/images/request_selected.png'
                  : 'assets/images/request.png',
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
