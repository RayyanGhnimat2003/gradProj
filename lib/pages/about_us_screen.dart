import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TextStyle cardTextStyle = TextStyle(fontSize: 15, height: 1.6, color: Colors.black87);

    return Scaffold(
      appBar: AppBar(
        title: Text("About Us"),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(Icons.travel_explore, size: 60, color: Colors.teal),
              SizedBox(height: 20),

              // 🟢 البطاقة 1 - Who We Are
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, size: 40, color: Colors.teal),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Who We Are", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
                            SizedBox(height: 8),
                            Text(
                              "We are a Palestinian company dedicated to tourism and cultural exploration. We specialize in promoting Palestine’s beauty through travel, hospitality, and authentic experiences.",
                              style: cardTextStyle,
                              textAlign: TextAlign.justify,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),

              // 🟢 البطاقة 2 - Our Services
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.room_service_outlined, size: 40, color: Colors.teal),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Our Services", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
                            SizedBox(height: 8),
                            Text(
                              "- Guided tours to historical & cultural sites\n"
                              "- Hotel and guesthouse bookings\n"
                              "- Traditional food experiences and restaurants\n"
                              "- Olive field and oil production visits\n"
                              "- Full travel support and consultation",
                              style: cardTextStyle,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),

              // 🟢 البطاقة 3 - Our Vision
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.visibility_outlined, size: 40, color: Colors.teal),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Our Vision", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
                            SizedBox(height: 8),
                            Text(
                              "To build a bridge between visitors and Palestinian culture by offering experiences rooted in heritage, sustainability, and hospitality.",
                              style: cardTextStyle,
                              textAlign: TextAlign.justify,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),

              // 🟢 البطاقة 4 - App Features
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.star_border_outlined, size: 40, color: Colors.teal),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("App Features", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
                            SizedBox(height: 8),
                            Text(
                              "- Attraction Directory with images & details\n"
                              "- Hotel and Restaurant Reservations\n"
                              "- Real-time GPS Navigation\n"
                              "- Live Weather Updates\n"
                              "- Emergency Assistance Locator\n"
                              "- Multilingual Support (Arabic & English)\n"
                              "- User Ratings and Reviews",
                              style: cardTextStyle,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 30),
              Text("© 2025 | All Rights Reserved", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
