import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/AdminPage.dart';
import 'package:flutter_application_1/pages/destination_page.dart';
import 'package:flutter_application_1/pages/login_screen.dart';
import 'package:flutter_application_1/pages/welcome_screen.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter(); // تهيئة Hive
  await Hive.openBox('userBox'); // فتح صندوق التخزين

  final box = Hive.box('userBox');
  final int? userId = box.get('user_ID');
  final String? role = box.get('role'); // نخزن الدور أيضًا وقت تسجيل الدخول

  Widget startPage;

  if (userId != null && role != null) {
    if (role == 'admin') {
      startPage = AdminDestinationPage();
    } else {
      startPage = DestinationPage();
    }
  } else {
    startPage = WelcomeScreen();
  }

  runApp(MyApp(startPage));
}

class MyApp extends StatelessWidget {
  final Widget startPage;
  const MyApp(this.startPage, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: startPage,
    );
  }
}


