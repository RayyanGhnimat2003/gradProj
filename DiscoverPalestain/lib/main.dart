import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'pages/destination_page.dart';
import 'pages/login_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter(); // تهيئة Hive
  await Hive.openBox('userBox'); // فتح البوكس لتخزين بيانات المستخدم

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home:  LoginScreen(),
    );
  }
}

