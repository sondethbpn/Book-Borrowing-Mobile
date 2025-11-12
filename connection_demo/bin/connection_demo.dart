import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

void main() async {
  print("===== Login =====");
  // Get username and password
  stdout.write("Username: ");
  String? username = stdin.readLineSync()?.trim();
  stdout.write("Password: ");
  String? password = stdin.readLineSync()?.trim();
  if (username == null || password == null) {
    print("Incomplete input");
    return;
  }

  final body = {"username": username, "password": password};
  final url = Uri.parse('http://localhost:3000/login');
  final response = await http.post(url, body: body);
  if (response.statusCode == 200) {
    // Login successful
    final result = jsonDecode(response.body);
    final userId = result['userId'].toString(); // Convert userId to String
    print(result['message']);
    print("Logged in as User ID: $userId");

    // Show choices to the user
    while (true) {
      print("\n===== Expense Tracking App =====");
      print("1. Show all ");
      print("2. Today's expense");
      print("3. Exit");

      stdout.write("Choose.... ");
      String? choice = stdin.readLineSync()?.trim();

      if (choice == '1') {
        await showAllContent(userId);
      } else if (choice == '2') {
        await showTodaysContent(userId);
      } else if (choice == '3') {
        print("------ Bye -----");
        break;
      } else {
        print("Invalid choice, please try again.");
      }
    }
  } else {
    // Handle errors
    print(response.body);
  }
}

Future<void> showAllContent(String userId) async {
  final url = Uri.parse('http://localhost:3000/content/all?userId=$userId');
  final response = await http.get(url);
  num sum = 0;
  if (response.statusCode == 200) {
    final List<dynamic> content = jsonDecode(response.body);
    print("\n------- All expenses --------");
    for (var item in content) {
      print(
          "${item['id']}. ${item['item']} : ${item['paid']}฿ : ${item['date']}");
      sum += item['paid'];
    }
    print("Total expenses : $sum ฿");
  } else {
    print("Failed to retrieve content.");
  }
}

Future<void> showTodaysContent(String userId) async {
  final url = Uri.parse('http://localhost:3000/content/today?userId=$userId');
  final response = await http.get(url);
  num sum = 0;
  if (response.statusCode == 200) {
    final List<dynamic> content = jsonDecode(response.body);
    if (content.isEmpty) {
      print("\nNo expenses recorded for today.");
    } else {
      print("\n-------- Today's expenses --------");
      for (var item in content) {
        print(
            "${item['id']}. ${item['item']} : ${item['paid']}฿ : ${item['date']}");
        sum += item['paid'];
      }
      print("Total expenses : $sum ฿");
    }
  } else {
    print("Failed to retrieve content.");
  }
}
