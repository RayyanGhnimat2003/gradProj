import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_application_1/pages/login_screen.dart';

class CustomDrawer extends StatelessWidget {
  final bool isAdmin;

  const CustomDrawer({Key? key, this.isAdmin = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // الحصول على اسم المستخدم من Hive
    String userName = "User";
    try {
      if (Hive.isBoxOpen('userBox')) {
        final userBox = Hive.box('userBox');
        userName = userBox.get('userName', defaultValue: isAdmin ? "Admin" : "User");
      }
    } catch (e) {
      print("Error getting userName: $e");
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(userName),
            accountEmail: const Text('user@example.com'),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                size: 35,
                color: Color(0xFF1C0E0E),
              ),
            ),
            decoration: BoxDecoration(
              color: Color(0xFF1C0E0E),
            ),
          ),
          // عناصر خاصة بالمشرف فقط
          if (isAdmin) ...[
            ListTile(
              leading: const Icon(Icons.dashboard, color: Color(0xFF4CAF50)),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                // يمكن إضافة التنقل إلى لوحة التحكم
              },
            ),
            ListTile(
              leading: const Icon(Icons.hotel, color: Color(0xFF2196F3)),
              title: const Text('Manage Hotels'),
              onTap: () {
                Navigator.pop(context);
                // التنقل إلى إدارة الفنادق
              },
            ),
            ListTile(
              leading: const Icon(Icons.restaurant, color: Color(0xFFFFC107)),
              title: const Text('Manage Restaurants'),
              onTap: () {
                Navigator.pop(context);
                // التنقل إلى إدارة المطاعم
              },
            ),
            ListTile(
              leading: const Icon(Icons.people, color: Color(0xFFE91E63)),
              title: const Text('Manage Users'),
              onTap: () {
                Navigator.pop(context);
                // التنقل إلى إدارة المستخدمين
              },
            ),
          ] else ...[
            // عناصر خاصة بالمستخدم العادي
            ListTile(
              leading: const Icon(Icons.home, color: Color(0xFF4CAF50)),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                // التنقل إلى الصفحة الرئيسية
              },
            ),
            ListTile(
              leading: const Icon(Icons.hotel, color: Color(0xFF2196F3)),
              title: const Text('Hotels'),
              onTap: () {
                Navigator.pop(context);
                // التنقل إلى صفحة الفنادق
              },
            ),
            ListTile(
              leading: const Icon(Icons.restaurant, color: Color(0xFFFFC107)),
              title: const Text('Restaurants'),
              onTap: () {
                Navigator.pop(context);
                // التنقل إلى صفحة المطاعم
              },
            ),
            ListTile(
              leading: const Icon(Icons.tour, color: Color(0xFFE91E63)),
              title: const Text('Tours'),
              onTap: () {
                Navigator.pop(context);
                // التنقل إلى صفحة الجولات
              },
            ),
          ],
          // عناصر مشتركة بين المشرف والمستخدم العادي
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.grey),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              // التنقل إلى الإعدادات
            },
          ),
          ListTile(
            leading: const Icon(Icons.help, color: Colors.grey),
            title: const Text('Help & Support'),
            onTap: () {
              Navigator.pop(context);
              // التنقل إلى المساعدة والدعم
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout'),
            onTap: () {
              // تسجيل الخروج من الحساب
              try {
                if (Hive.isBoxOpen('userBox')) {
                  final userBox = Hive.box('userBox');
                  userBox.delete('userName');
                  userBox.delete('user_ID');
                }
              } catch (e) {
                print("Error during logout: $e");
              }
              
              // العودة إلى صفحة تسجيل الدخول
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}