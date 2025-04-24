import 'package:flutter/material.dart';
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

  // دالة لتسجيل الدخول
 Future<void> _login() async {
  // التحقق من الحقول الفارغة
  if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Please fill in both email and password"), 
      backgroundColor: const Color.fromARGB(255, 208, 55, 44), // لون الخلفية أحمر
      ),
    );
    return; // إيقاف تنفيذ الدالة إذا كانت الحقول فارغة
  }

  final String url = "http://localhost/FinalProject_Graduaction/Hotels/login.php"; // رابط السيرفر

  // إرسال الطلب إلى السيرفر
  final response = await http.post(
    Uri.parse(url),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "email": _emailController.text,
      "password": _passwordController.text,
    }),
  );

  final data = jsonDecode(response.body);

  if (data["success"]) {
    // إذا كانت عملية تسجيل الدخول ناجحة، انتقل إلى شاشة فندق قائمة الفنادق
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Login Successful!",style: TextStyle(color: Colors.white), // لون النص أبيض
),    
    backgroundColor: Colors.green, // لون الخلفية أخضر
),
    );

    // الانتقال إلى شاشة HotelListScreen باستخدام Navigator.pushReplacement
    /*
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HotelListScreen()),
    );
    */
  } else {
    // إذا فشلت عملية تسجيل الدخول، عرض رسالة خطأ
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(data["message"] ?? "An error occurred"), backgroundColor: const Color.fromARGB(255, 208, 55, 44), // لون الخلفية أحمر
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
                        onPressed: _login,
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
