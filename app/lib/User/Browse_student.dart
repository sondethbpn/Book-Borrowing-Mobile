// ignore_for_file: unnecessary_null_comparison

import 'package:app/Mainpage.dart';
import 'package:app/User/History_Student.dart';
import 'package:app/User/RequestStatus.dart';
import 'package:app/User/Request_To_Borrow.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BrowseStudent extends StatelessWidget {
  const BrowseStudent({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int totalBorrowed = 0;
  int totalPending = 0;
  bool isLoading = true;
  Map<String, dynamic> profileData = {};
  List<String> data = [];

  @override
  void initState() {
    super.initState();
    fetchBorrowedData();
    fetchProfileData();
    fetchBooks();
  }

  Future<void> fetchBorrowedData() async {
    try {
      // Retrieve token from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      if (token == null) {
        showErrorDialog("User not authenticated");
        return;
      }

      final response = await http.get(
        Uri.parse('http://192.168.1.189:3000/total/borrowed'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          totalBorrowed = data['Total_Borrowed'] ?? 0;
          totalPending = data['Total_Pending'] ?? 0;
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
          data = [
            'ID ${profileData['user_id'] ?? 'Loading...'}',
            'Total Borrowed', // Add appropriate data here
            'Your Limit Today', // Add appropriate data here
            'Pending Book', // Add appropriate data here
            profileData['email'] ?? 'Loading...',
          ];
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

  List<dynamic> books = [];

  Future<void> fetchBooks() async {
    final response =
        await http.get(Uri.parse('http://192.168.1.189:3000/browses'));

    if (response.statusCode == 200) {
      setState(() {
        books = json.decode(response.body); // Convert the response to a list
      });
    } else {
      // Handle error
      print('Failed to load books');
    }
  }

  String _getImagePathForIndex(int index) {
    switch (index) {
      case 0:
        return 'assets/images/ID.png';
      case 1:
        return 'assets/images/Borrowed.png';
      case 2:
        return 'assets/images/Limit.png';
      case 3:
        return 'assets/images/Pending.png';
      default:
        return 'assets/images/Email.png';
    }
  }

  final double imageWidth = 100;
  final double imageHeight = 164;

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
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C1F56),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 65), // Move 'Browse' slightly to the right
            Spacer(),
            Text(
              'Browse',
              style: TextStyle(
                  color: Colors.white, fontFamily: 'Jua', fontSize: 24),
            ),
            Spacer(),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
                right: 25.0, top: 10.0), // Right padding set to 25
            child: Builder(
              builder: (context) => GestureDetector(
                onTap: () {
                  Scaffold.of(context).openEndDrawer();
                },
                child: const CircleAvatar(
                  backgroundImage: AssetImage('assets/images/Avatar.png'),
                  radius: 20, // Adjust size of avatar if needed
                ),
              ),
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        backgroundColor: const Color(0xFF4D3370),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 20.0),
                          child: CircleAvatar(
                            backgroundImage:
                                AssetImage('assets/images/Profile.png'),
                            radius: 30,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            profileData['username'] ?? 'Loading...',
                            style: const TextStyle(
                                color: Color(0xFF4FD1C5),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Inter'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            'Role: ${profileData['role'] ?? 'Loading...'}',
                            style: const TextStyle(
                                color: Color(0xFF4B92B6),
                                fontSize: 16,
                                fontFamily: 'Inter'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...List.generate(
                    data.length,
                    (index) => ListTile(
                      leading: Image.asset(
                        _getImagePathForIndex(index),
                        width: 25,
                        height: 25,
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              data[index],
                              style: const TextStyle(
                                color: Color(0xFF4FD1C5),
                                fontFamily: 'Inter',
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          if (index == 1 || index == 2 || index == 3) ...[
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: const Color(0xFFA0D9FF),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              alignment: Alignment.center,
                              margin: const EdgeInsets.only(left: 25),
                              child: Text(
                                index == 1
                                    ? (totalBorrowed != null
                                        ? '$totalBorrowed'
                                        : '...')
                                    : index == 2
                                        ? (profileData['limit'] != null
                                            ? '${profileData['limit']}'
                                            : '...')
                                        : (totalPending != null
                                            ? '$totalPending'
                                            : '...'),
                                style: const TextStyle(
                                  color: Color(0xFF0C7FDA),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.all(35.0), // Add padding around the button
              child: ElevatedButton(
                onPressed: () async {
                  // Remove the token from SharedPreferences
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.remove('authToken'); // Remove the token

                  // Optionally, you can clear all preferences with `prefs.clear();` if needed.

                  // Redirect the user to the login screen after logout
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const Mainpage()), // Replace with your login screen
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFFA50B0E), // Button background color
                  padding:
                      const EdgeInsets.symmetric(horizontal: 17, vertical: 5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/Logout.png',
                      width: 35,
                      height: 35,
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(width: 5),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.6,
            ),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              final int bookId = book['book_id'];
              final bool isAvailable = book['status'] == 'Available';

              return GestureDetector(
                onTap: isAvailable
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Borrow(bookId: bookId),
                          ),
                        );
                      }
                    : null,
                child: Opacity(
                  opacity: isAvailable ? 1.0 : 0.5,
                  child: Column(
                    children: [
                      Container(
                        width: imageWidth,
                        height: imageHeight,
                        margin: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.grey[300],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: book['image'] != null &&
                                  book['image']!.length > 30
                              ? Image.network(
                                  book['image']!, // Network image URL
                                  fit: BoxFit.cover,
                                  width: imageWidth,
                                  height: imageHeight,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/images/placeholder_image.png',
                                      fit: BoxFit.cover,
                                      width: imageWidth,
                                      height: imageHeight,
                                    );
                                  },
                                )
                              : Image.asset(
                                  book['image'] ??
                                      'assets/images/placeholder_image.png', // Local image path or placeholder
                                  fit: BoxFit.cover,
                                  width: imageWidth,
                                  height: imageHeight,
                                ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book['book_name'] ?? 'No Name',
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Jua',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        book['status'] ?? 'Unknown',
                        style: TextStyle(
                          color: isAvailable ? Colors.green : Colors.red,
                          fontFamily: 'jsMath-cmbx10',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
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
}
