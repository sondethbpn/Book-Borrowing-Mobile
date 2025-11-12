import 'package:app/Admin/Browse_Staff.dart';
import 'package:app/Admin/Got_assets_back.dart';
import 'package:app/Admin/History_Staff.dart';
import 'package:app/Admin/add.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class StaffDashboard extends StatelessWidget {
  const StaffDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: StaffDashboardState(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class StaffDashboardState extends StatefulWidget {
  const StaffDashboardState({super.key});

  @override
  _StaffDashboardState createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboardState> {
  int _selectedIndex = 4;
  late String? _borrowingDate;
  Map<String, dynamic>? bookData;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _borrowingDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    // print("Borrowing Date: $_borrowingDate");
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      final response =
          await http.get(Uri.parse('http://192.168.1.189:3000/dashboard'));
      if (response.statusCode == 200) {
        setState(() {
          bookData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
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
        nextPage = const StaffDashboard();
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? const Center(child: Text('Error loading data'))
              : Padding(
                  padding: const EdgeInsets.all(35.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      const Text(
                        'Staff Dashboard',
                        style: TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                            fontFamily: 'Jua'),
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.asset(
                            'assets/images/Calendar.png',
                            width: 25,
                            height: 25,
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            'Today Date:      ${_borrowingDate ?? "Loading..."}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontFamily: 'Inknut',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      // Total Books Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF230248),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total Books',
                                  style: TextStyle(
                                    color: Color(0xFFA0AEC0),
                                    fontSize: 20,
                                    fontFamily: 'Alkalami',
                                  ),
                                ),
                                Row(
                                  children: [
                                    Image.asset(
                                      'assets/images/TotBooks.png',
                                      width: 24,
                                      height: 30,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      bookData != null
                                          ? '${bookData!['Total_Books']}'
                                          : 'Loading...',
                                      style: const TextStyle(
                                        color: Color(0xFF566D86),
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'InriaSans',
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            const Spacer(),
                            Container(
                              width: 65,
                              height: 59,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4FD1C5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: SizedBox(
                                  width: 37,
                                  height: 37,
                                  child: Image.asset(
                                    'assets/images/TotIcon.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Available Books Card
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF356A4B),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Available Books',
                                  style: TextStyle(
                                    color: Color(0xFFA0AEC0),
                                    fontSize: 20,
                                    fontFamily: 'Alkalami',
                                  ),
                                ),
                                Row(
                                  children: [
                                    Image.asset(
                                      'assets/images/AvaBooks.png',
                                      width: 24,
                                      height: 30,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      bookData != null
                                          ? '${bookData!['Available_Books']}'
                                          : 'Loading...',
                                      style: const TextStyle(
                                          color: Color(0xFF48BB78),
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'InriaSans'),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            const Spacer(),
                            Container(
                              width: 65,
                              height: 59,
                              decoration: BoxDecoration(
                                color: const Color(0xFF78FFB1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                // Centers the image within the container
                                child: SizedBox(
                                  width: 37, // Explicitly set the image width
                                  height: 37, // Explicitly set the image height
                                  child: Image.asset(
                                    'assets/images/AvaIcon.png',
                                    fit: BoxFit
                                        .contain, // Ensures the image maintains its aspect ratio
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Borrowed Books Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5E4F70),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Borrowed Books',
                                  style: TextStyle(
                                    color: Color(0xFFA0AEC0),
                                    fontSize: 20,
                                    fontFamily: 'Alkalami',
                                  ),
                                ),
                                Row(
                                  children: [
                                    Image.asset(
                                      'assets/images/BorBooks.png',
                                      width: 24,
                                      height: 30,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      bookData != null
                                          ? '${bookData!['Borrowed_Books']}'
                                          : 'Loading...',
                                      style: const TextStyle(
                                          color: Color(0xFF2D3748),
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'InriaSans'),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            const Spacer(),
                            Container(
                              width: 65,
                              height: 59,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2B635B),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: SizedBox(
                                  width: 37,
                                  height: 37,
                                  child: Image.asset(
                                    'assets/images/BorIcon.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Disabled Books Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB2534F),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Disabled Books',
                                  style: TextStyle(
                                    color: Color(0xFFA0AEC0),
                                    fontSize: 20,
                                    fontFamily: 'Alkalami',
                                  ),
                                ),
                                Row(
                                  children: [
                                    Image.asset(
                                      'assets/images/DisBooks.png',
                                      width: 24,
                                      height: 30,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      bookData != null
                                          ? '${bookData!['Disabled_Books']}'
                                          : 'Loading...',
                                      style: const TextStyle(
                                          color: Color(0xFF743B3C),
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'InriaSans'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              width: 65,
                              height: 59,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE74B4E),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: SizedBox(
                                  width: 34,
                                  height: 34,
                                  child: Image.asset(
                                    'assets/images/DisIcon.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
