import 'package:app/User/Browse_student.dart';
import 'package:app/User/History_Student.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Request extends StatelessWidget {
  const Request({super.key});

  @override
  Widget build(BuildContext context) {
    return const Requeststatus();
  }
}

class Requeststatus extends StatefulWidget {
  const Requeststatus({super.key});

  @override
  _RequeststatusState createState() => _RequeststatusState();
}

class _RequeststatusState extends State<Requeststatus> {
  int _selectedIndex = 2;
  List<Map<String, dynamic>> borrowedBooks = [];

  Future<void> fetchBorrowedBooks() async {
    final token = await _getToken();
    if (token == null) return;

    final response = await http.get(
      Uri.parse('http://192.168.1.189:3000/display/status'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        borrowedBooks =
            List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else if (response.statusCode == 401) {
      _showErrorDialog("User not authenticated");
    } else if (response.statusCode == 403) {
      _showErrorDialog("Invalid or expired token");
    } else if (response.statusCode == 404) {
      ("No records found for this user");
    } else {
      _showErrorDialog("Error: ${response.statusCode}");
    }
  }

  Future<void> returnBook(int borrowId) async {
    final url = Uri.parse('http://192.168.1.189:3000/return/assets');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'borrow_id': borrowId,
        }),
      );
      if (response.statusCode == 200) {
        print("Record updated successfully");
      } else if (response.statusCode == 404) {
        print("No record found with this borrow_id");
      } else {
        print("Error: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
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

  Future<void> deleteBorrowRecord(int borrowId) async {
    final String url = 'http://192.168.1.189:3000/delete/borrow/$borrowId';
    try {
      final response = await http.post(
        Uri.parse(url),
      );
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        print(responseBody['message']);
      } else {
        print('Failed to delete borrow record: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchBorrowedBooks();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    Widget nextPage;
    switch (_selectedIndex) {
      case 0:
        nextPage = const BrowseStudent();
        break;
      case 1:
        nextPage = const HistoryStudent();
        break;
      case 2:
        nextPage = const Requeststatus();
        break;
      default:
        nextPage = const BrowseStudent();
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 50),
            const Text(
              'Request Status',
              style: TextStyle(
                fontSize: 30,
                fontFamily: 'Jua',
                color: Colors.white,
              ),
            ),
            Expanded(
              child: borrowedBooks.isEmpty
                  ? const Center(
                      child: Text("No borrowed books found!!",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontFamily: 'Jua')))
                  : ListView.builder(
                      itemCount: borrowedBooks.length,
                      itemBuilder: (context, index) {
                        final item = borrowedBooks[index];
                        return Column(
                          children: [
                            _buildRequestItem(
                              item['borrow_id'],
                              item['book_name'],
                              item['status'],
                              item['borrow_date'],
                              item['return_date'],
                              item['image'],
                              const Color(0XFFA50B0E),
                            ),
                            const SizedBox(height: 30),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
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

  Widget _buildRequestItem(int? borrowId, String? name, String? status,
      String? borrowDate, String? returnDate, String? imagePath, Color color) {
    String finalImagePath = imagePath ?? 'assets/default_image.png';

    // Fallback values for strings that might be null
    String finalName = name ?? "Unknown Book";
    String finalStatus = status ?? 'N/A';
    String finalBorrowDate = borrowDate ?? 'N/A';
    String finalReturnDate = returnDate ?? 'N/A';

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 130,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              image: DecorationImage(
                image: finalImagePath.startsWith('http')
                    ? NetworkImage(finalImagePath)
                    : AssetImage(finalImagePath) as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 25),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 60,
                  width: 250,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF917C93),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        finalName,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 16,
                          fontFamily: 'Jua',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9D9D9),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          finalStatus,
                          style: const TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inknit',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 3),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _buildDateInfo('Borrowing Date', finalBorrowDate),
                const SizedBox(height: 5),
                _buildDateInfo('Returning Date', finalReturnDate),
                const SizedBox(height: 30),
                _buildActionButton(finalStatus, () {
                  if (finalStatus == 'Pending') {
                    deleteBorrowRecord(borrowId!);
                  } else {
                    returnBook(borrowId!);
                    print("Return action triggered");
                  }
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Request()),
                  );
                })
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateInfo(String label, String date) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFF242424),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        '$label      $date',
        style: const TextStyle(
          color: Color(0xFF7F7F7F),
          fontSize: 12,
          fontFamily: 'Inder',
        ),
        textAlign: TextAlign.start,
      ),
    );
  }

  Widget _buildActionButton(String status, VoidCallback onPressed) {
    // Set button text and color based on status
    String buttonText = status == 'Pending' ? 'Cancel' : 'Return';
    Color buttonColor = status == 'Pending'
        ? const Color(0xFF602454)
        : const Color.fromARGB(255, 165, 134, 54);

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.all(10),
        backgroundColor: buttonColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        buttonText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontFamily: 'Jua',
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
