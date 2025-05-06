import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/login_screen.dart';
import 'package:flutter_application_1/pages/signup_screen.dart';
import 'about_us_screen.dart';
import 'contact_us_screen.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool isCardHovered = false;
  bool isImageHovered = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text('Discover Palestine (Olive and Stone land)', style: TextStyle(color: Colors.white)),
        centerTitle: false,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ContactUsScreen()));
            },
            child: Text('Contact Us', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => AboutUsScreen()));
            },
            child: Text('About Us', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.green.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 100),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ✅ صورة تفاعلية
                  MouseRegion(
                    onEnter: (_) => setState(() => isImageHovered = true),
                    onExit: (_) => setState(() => isImageHovered = false),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      width: isImageHovered ? 420 : 400,
                      height: isImageHovered ? 320 : 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: isImageHovered
                                ?  Colors.teal
                                :  Colors.teal,
                            blurRadius: isImageHovered ? 25 : 15,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: 
                        Image.asset(
                               '../assets/images/welcome.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 60),

                  // ✅ كارد تفاعلي
                  MouseRegion(
                    onEnter: (_) => setState(() => isCardHovered = true),
                    onExit: (_) => setState(() => isCardHovered = false),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      transform: isCardHovered
                          ? Matrix4.translationValues(0, -6, 0)
                          : Matrix4.identity(),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: isCardHovered
                                ? Colors.teal
                                : Colors.teal,
                            blurRadius: 24,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Container(
                          width: 420,
                          height: 420,
                          padding: EdgeInsets.all(28),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Welcome to Discover Palestine (Olive and Stone land)',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal,
                                  ),
                                ),
                                SizedBox(height: 32),
                                ElevatedButton.icon(
                                  onPressed: () {
                                     Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
                                  },
                                  //                  child: Icon(Icons.person, size: 35, color: Colors.teal),

                                  icon: Icon(Icons.login,color: const Color.fromARGB(255, 236, 240, 239) ,size: 20 ),
                                  label: Text('Login'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:  Colors.teal,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 6,
                                  ),
                                ),
                                SizedBox(height: 20),
                                OutlinedButton.icon(
                                  onPressed: () {
                                Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignupScreen()),
    );

                                  },
                                  icon: Icon(Icons.person_add , color: Colors.teal ,size: 20 ),
                                  label: Text('Sign Up'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.teal,
                                    side: BorderSide(color: Colors.teal, width: 2),
                                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
