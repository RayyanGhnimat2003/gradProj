import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/AdminPage.dart';
//import 'package:flutter_application_1/pages/destination_page.dart';
//import 'package:flutter_application_1/pages/user_info_screen.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // لتحويل البيانات من وإلى JSON
import 'signup_screen.dart'; // لإضافة التنقل إلى صفحة التسجيل في حال لم يكن المستخدم مسجلًا

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers لكل حقل
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

Future<void> _login() async {
  if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Please fill in both email and password"),
        backgroundColor: const Color.fromARGB(255, 208, 55, 44),
      ),
    );
    return;
  }

  final String url = "http://localhost/FinalProject_Graduaction/Hotels/login.php";
  print("🔁 Sending login request to $url");

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": _emailController.text,
        "password": _passwordController.text,
      }),
    );

    print("✅ Response received with status code: ${response.statusCode}");
    print("📦 Raw response body: ${response.body}");

    final data = jsonDecode(response.body);
    print("🧩 Decoded JSON: $data");

    if (data["success"]) {
      print("🎉 Login success, preparing to store user info...");

Box box;
if (Hive.isBoxOpen('userBox')) {
  box = Hive.box('userBox');
} else {
  box = await Hive.openBox('userBox');
}
      box.put('user_ID', int.parse(data['user']['user_ID'].toString()));
      box.put('userName', data['user']['userName']);

      print("📦 Stored in Hive: user_ID=${box.get('user_ID')}, userName=${box.get('userName')}");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login Successful!", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
        ),
      );

      print("🔁 Navigating to UserInfoScreen...");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminDestinationPage()),
      );
    } else {
      print("❌ Login failed, message: ${data["message"]}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data["message"] ?? "An error occurred"),
          backgroundColor: const Color.fromARGB(255, 208, 55, 44),
        ),
      );
    }
  } catch (e) {
    print("🚨 Exception during login: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error: $e"),
        backgroundColor: Colors.red,
      ),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 800,
          height: 450,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Color(0xFFCFE8D5),
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset("images/p4.jpg", width: 150),
                      SizedBox(height: 20),
                      Text("Discover Palestine", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text("Explore the beauty and heritage of Palestine", textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Login", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                      SizedBox(height: 20),
                      _buildTextField(Icons.email, "Email", _emailController),
                      SizedBox(height: 15),
                      _buildTextField(Icons.lock, "Password", _passwordController, obscureText: true),
                      SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 28, 14, 14),
                          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                     onPressed: () async => await _login(),
                        child: Text("Login", style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                      SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignupScreen()),
                          );
                        },
                        child: Text("Don't have an account? Sign up", style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Color.fromARGB(255, 232, 252, 243),
    );
  }

  Widget _buildTextField(IconData icon, String hint, TextEditingController controller, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        filled: true,
        fillColor: Color.fromARGB(255, 210, 228, 210),
        hintText: hint,
        prefixIcon: Icon(icon, color: Color.fromARGB(255, 106, 164, 120)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class HotelListScreen {
}
