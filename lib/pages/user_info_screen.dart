import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class UserInfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var box = Hive.box('userBox');
    String userName = box.get('userName', defaultValue: 'Unknown');
    int userId = box.get('user_ID', defaultValue: 0);

    return Scaffold(
      appBar: AppBar(
        title: Text('User Info'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Color(0xFFE6F4EA),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('👤 Username: $userName', style: TextStyle(fontSize: 20)),
              SizedBox(height: 10),
              Text('🆔 User ID: $userId', style: TextStyle(fontSize: 20)),
            ],
          ),
        ),
      ),
    );
  }
}
