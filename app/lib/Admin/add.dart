// ignore_for_file: prefer_const_declarations

import 'dart:convert';
import 'package:app/Admin/Browse_Staff.dart';
import 'package:app/Admin/Dashboard_Staff.dart';
import 'package:app/Admin/Got_assets_back.dart';
import 'package:app/Admin/History_Staff.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddNewBook extends StatelessWidget {
  const AddNewBook({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AddNewBookScreen(),
    );
  }
}

class AddNewBookScreen extends StatefulWidget {
  const AddNewBookScreen({super.key});

  @override
  _AddNewBookScreenState createState() => _AddNewBookScreenState();
}

class _AddNewBookScreenState extends State<AddNewBookScreen> {
  int _selectedIndex = 1;
  bool _isSwitchOn = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _bookNameController = TextEditingController();

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
        nextPage = const AddNewBook();
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
        nextPage = const AddNewBook();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextPage),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final fileExtension = pickedFile.path.split('.').last.toLowerCase();
      if (['jpg', 'jpeg', 'png'].contains(fileExtension)) {
        setState(() {
          _selectedImage = pickedFile;
        });
        print('Image selected: ${pickedFile.path}');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Unsupported file format. Please select a JPG or PNG image.'),
          ),
        );
      }
    } else {
      print('No image selected');
    }
  }

  Future<void> _createBook() async {
    if (_bookNameController.text.isEmpty || _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a book name and upload an image.'),
        ),
      );
      return;
    }

    try {
      const String cloudinaryUrl =
          'https://api.cloudinary.com/v1_1/dpunifgmo/image/upload';
      const String uploadPreset = 'ml_default';

      // Upload the image to Cloudinary
      final imageUploadResponse = await _uploadImageToCloudinary(
        cloudinaryUrl,
        uploadPreset,
        _selectedImage!.path,
      );

      if (imageUploadResponse == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload image.')),
        );
        return;
      }

      final String imageUrl = imageUploadResponse['secure_url'];
      final Map<String, String> bookData = {
        'book_name': _bookNameController.text,
        'status': _isSwitchOn ? 'Disabled' : 'Available',
        'image': imageUrl,
      };

      final backendResponse = await _sendBookDataToBackend(
        'http://192.168.1.189:3000/adding',
        bookData,
      );

      if (backendResponse) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book added successfully')),
        );
        _resetForm();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add book.')),
        );
      }
    } catch (e) {
      print('Error occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
  }

  Future<Map<String, dynamic>?> _uploadImageToCloudinary(
      String url, String preset, String filePath) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url))
        ..fields['upload_preset'] = preset
        ..files.add(await http.MultipartFile.fromPath('file', filePath));

      print('Uploading to Cloudinary...');
      print('URL: $url');
      print('Preset: $preset');
      print('File Path: $filePath');

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('Cloudinary Response: $responseBody');

      if (response.statusCode == 200) {
        return jsonDecode(responseBody);
      } else {
        print('Image upload failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<bool> _sendBookDataToBackend(
      String url, Map<String, String> bookData) async {
    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(bookData),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Error sending data to backend: $e');
      return false;
    }
  }

  void _resetForm() {
    _bookNameController.clear();
    setState(() {
      _selectedImage = null;
      _isSwitchOn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5C1F56),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 30),
              const Text(
                'Add New Book',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontFamily: 'Jua',
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 200,
                  height: 300,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8F7979),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: _selectedImage != null
                      ? Image.file(
                          File(_selectedImage!.path),
                          fit: BoxFit.cover,
                        )
                      : const Center(
                          child: Text(
                            'BOOK COVER',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Kaisei',
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7400F0),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                onPressed: _pickImage,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_upload, color: Colors.white, size: 18),
                    SizedBox(width: 7),
                    Text(
                      'UPLOAD IMAGE',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: 'Labrada',
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 240,
                height: 65,
                child: TextField(
                  controller: _bookNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '             Book name',
                    hintStyle: const TextStyle(
                        color: Color.fromARGB(255, 150, 124, 124)),
                    filled: true,
                    fillColor: const Color(0xFF230248),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: const BorderSide(color: Color(0xFF760000)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: const BorderSide(color: Color(0xFF760000)),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Status: Disabled',
                    style: TextStyle(
                        color: Colors.white, fontFamily: 'Karma', fontSize: 18),
                  ),
                  const SizedBox(width: 30),
                  Switch(
                    value: _isSwitchOn,
                    onChanged: (value) {
                      setState(() {
                        _isSwitchOn = value;
                      });
                    },
                    activeColor: Colors.red,
                    inactiveThumbColor: const Color(0xFFEFEFEF),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 100,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4B8C65),
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  onPressed: _createBook,
                  child: const Text(
                    'CREATE',
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Labrada',
                        fontSize: 14),
                  ),
                ),
              ),
            ],
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
