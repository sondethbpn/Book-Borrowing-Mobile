// ignore_for_file: non_constant_identifier_names

import 'package:app/Admin/Browse_Staff.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>?> fetchBookDetails(int bookId) async {
  print("Fetching data for bookId: $bookId");
  try {
    final url = Uri.parse('http://192.168.1.189:3000/edit/admin/$bookId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List && data.isNotEmpty) {
        return data[0] as Map<String, dynamic>;
      } else if (data is Map<String, dynamic>) {
        return data;
      } else {
        print('Unexpected data format');
        return null;
      }
    } else {
      print('Failed to load book details: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error fetching book details: $e');
    return null;
  }
}

// Update book details
Future<bool> updateBookDetails(
    int bookId, String bookName, String status) async {
  final url = Uri.parse('http://192.168.1.189:3000/edit/admin/$bookId');
  final response = await http.put(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'book_name': bookName, 'status': status}),
  );

  if (response.statusCode == 200) {
    return true;
  } else {
    print('Failed to update book');
    return false;
  }
}

class EditBookScreen extends StatelessWidget {
  final int bookId;
  const EditBookScreen({super.key, required this.bookId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: EditScreen(bookId: bookId),
    );
  }
}

class EditScreen extends StatefulWidget {
  final int bookId;
  const EditScreen({super.key, required this.bookId});

  @override
  _EditBookScreenState createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditScreen> {
  bool isAvailable = true;
  final TextEditingController bookNameController = TextEditingController();
  bool isLoading = true;
  String Image = '';

  @override
  void didUpdateWidget(covariant EditScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bookId != widget.bookId) {
      setState(() {
        isLoading = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadBookDetails();
  }

  Future<void> _loadBookDetails() async {
    final bookDetails = await fetchBookDetails(widget.bookId);
    if (bookDetails != null) {
      setState(() {
        bookNameController.text = bookDetails['book_name'];
        Image = bookDetails['image'];
        isAvailable = bookDetails['status'] == 'Available';
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    bookNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5C1F56),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 35.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const BrowseStaff()),
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
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Edit',
                      style: TextStyle(
                          fontSize: 26, color: Colors.white, fontFamily: 'Jua'),
                    ),
                    const SizedBox(height: 10),
                    // Comic Book Cover Image
                    Container(
                      height: 344,
                      width: 232,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(Image),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Name of Book',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'Karma'),
                        ),
                        const SizedBox(height: 3),
                        SizedBox(
                          width: 230,
                          height: 60,
                          child: TextField(
                            controller: bookNameController,
                            style: const TextStyle(color: Colors.white),
                            obscureText: false,
                            decoration: InputDecoration(
                              hintText: "${bookNameController.text}",
                              hintStyle:
                                  const TextStyle(color: Color(0xFF858585)),
                              filled: true,
                              fillColor: const Color(0xFF230248),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide:
                                    const BorderSide(color: Color(0xFF760000)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide:
                                    const BorderSide(color: Color(0xFF760000)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Center(
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(right: 180),
                            child: Text(
                              'Status',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Karma',
                                  fontSize: 16),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 130),
                            child: Row(
                              children: [
                                const Text('Disabled',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Karma',
                                        fontSize: 14)),
                                Radio(
                                  value: false,
                                  groupValue: isAvailable,
                                  onChanged: (value) {
                                    setState(() {
                                      isAvailable = value as bool;
                                    });
                                  },
                                ),
                                const SizedBox(width: 10),
                                const Text('Available',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Karma',
                                        fontSize: 14)),
                                Radio(
                                  value: true,
                                  groupValue: isAvailable,
                                  onChanged: (value) {
                                    setState(() {
                                      isAvailable = value as bool;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5D358D),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      onPressed: () async {
                        final updated = await updateBookDetails(
                          widget.bookId,
                          bookNameController.text,
                          isAvailable ? 'Available' : 'Disabled',
                        );

                        if (updated) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Book updated successfully')),
                          );
                          await Future.delayed(const Duration(seconds: 2));
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const BrowseStaff()),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Failed to update book')),
                          );
                        }
                      },
                      child: const Text("SUBMIT",
                          style: TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontFamily: 'Labrada')),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
