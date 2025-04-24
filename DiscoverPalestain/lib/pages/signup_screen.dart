import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_screen.dart'; // لاستدعاء شاشة تسجيل الدخول

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  DateTime? _selectedDate;

  // Controllers لكل حقل
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  // دالة اختيار التاريخ
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _signup() async {
    if (_usernameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter your username", style: TextStyle(color: Colors.white)),
          backgroundColor: const Color.fromARGB(255, 208, 55, 44), // لون الخلفية أحمر
        ),
      );
      return;
    }
    if (_emailController.text.isEmpty || !RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter a valid email", style: TextStyle(color: Colors.white)),
          backgroundColor: const Color.fromARGB(255, 208, 55, 44),
        ),
      );
      return;
    }
    if (_passwordController.text.isEmpty || _passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Password must be at least 6 characters", style: TextStyle(color: Colors.white)),
          backgroundColor: const Color.fromARGB(255, 208, 55, 44),
        ),
      );
      return;
    }
    if (_firstNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter your first name", style: TextStyle(color: Colors.white)),
          backgroundColor: const Color.fromARGB(255, 208, 55, 44),
        ),
      );
      return;
    }
    if (_lastNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter your last name", style: TextStyle(color: Colors.white)),
          backgroundColor: const Color.fromARGB(255, 208, 55, 44),
        ),
      );
      return;
    }
    if (_phoneNumberController.text.isEmpty || _phoneNumberController.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter a valid phone number", style: TextStyle(color: Colors.white)),
          backgroundColor: const Color.fromARGB(255, 208, 55, 44),
        ),
      );
      return;
    }
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please select your date of birth", style: TextStyle(color: Colors.white)),
          backgroundColor: const Color.fromARGB(255, 208, 55, 44),
        ),
      );
      return;
    }
    if (_countryController.text.isEmpty || !RegExp(r"^[a-zA-Z\s]+$").hasMatch(_countryController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter a valid country name", style: TextStyle(color: Colors.white)),
          backgroundColor: const Color.fromARGB(255, 208, 55, 44),
        ),
      );
      return;
    }

    // إرسال البيانات إلى السيرفر
    final String url = "http://localhost/GraduationProject/signUp.php";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userName": _usernameController.text,
          "email": _emailController.text,
          "password": _passwordController.text,
          "firstName": _firstNameController.text,
          "lastName": _lastNameController.text,
          "phoneNumber": _phoneNumberController.text,
          "dateOfBirth": "${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day}",
          "country": _countryController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (data["success"]) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Registration successful. Please check your email to verify your account", style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => LoginScreen()),
);

      
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["message"]),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An error occurred. Please try again."),
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
          height: 700,
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
              // القسم الأيسر (الصورة + النصوص)
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Color(0xFFCFE8D5),
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("images/p4.jpg", width: 150),
                      SizedBox(height: 20),
                      Text("Discover Palestine", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text("Join us and explore the beauty and heritage of Palestine", textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
              // القسم الأيمن (الفورم)
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text("Sign Up", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                        SizedBox(height: 20),
                        _buildTextField(Icons.person, "Username", _usernameController),
                        SizedBox(height: 15),
                        _buildTextField(Icons.email, "Email", _emailController),
                        SizedBox(height: 15),
                        _buildTextField(Icons.lock, "Password", _passwordController, obscureText: true),
                        SizedBox(height: 15),
                        _buildTextField(Icons.account_box, "First Name", _firstNameController),
                        SizedBox(height: 15),
                        _buildTextField(Icons.account_box, "Last Name", _lastNameController),
                        SizedBox(height: 15),
                        _buildTextField(Icons.phone, "Phone Number", _phoneNumberController, isNumeric: true),
                        SizedBox(height: 15),
                        _buildDatePicker(context),
                        SizedBox(height: 15),
                        _buildTextField(Icons.location_on, "Country", _countryController),
                        SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: _signup,
                          child: Text("Sign Up", style: TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                        SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                          },
                          child: Text("Already have an account? Login",style: TextStyle(color: Colors.black)),
                        ),
                      ],
                    ),
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

  Widget _buildTextField(IconData icon, String hint, TextEditingController controller, {bool obscureText = false, bool isNumeric = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumeric ? [FilteringTextInputFormatter.digitsOnly] : [],
      decoration: InputDecoration(
        filled: true,
        fillColor: Color.fromARGB(255, 210, 228, 210),
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.green.shade700),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: IgnorePointer(
        child: TextField(
          controller: TextEditingController(
            text: _selectedDate == null ? '' : "${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day}",
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Color.fromARGB(255, 210, 228, 210),
            hintText: 'Date of Birth',
            prefixIcon: Icon(Icons.calendar_today, color: Colors.green.shade700),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
          ),
        ),
      ),
    );
  }
}
