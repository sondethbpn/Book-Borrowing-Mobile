import 'dart:io';

void main() {
  // Role 1 is admin, 2 is user
  var accounts = [
    {'username': 'Lisa', 'password': '1111', 'role': 1},
    {'username': 'Tom', 'password': '2222', 'role': 2}
  ];

  print("--- Login ---");
  print("Username: ");
  String? username = stdin.readLineSync();
  print("Password: ");
  String? password = stdin.readLineSync();

  bool loginSuccess = false;
  int userRole = 0;

  // Loop to find the matching username and password
  for (var account in accounts) {
    if (account['username'] == username && account['password'] == password) {
      loginSuccess = true;
      userRole = account['role'] as int;
      break;
    }
  }

  if (loginSuccess) {
    if (userRole == 1) {
      print("Welcome $username (admin)");
    } else if (userRole == 2) {
      print("Welcome $username (user)");
    }
  } else {
    print("Wrong login");
  }
}
