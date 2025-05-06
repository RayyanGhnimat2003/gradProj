import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/Hotel.dart';
import 'package:flutter_application_1/pages/city_list_screenUser.dart';
import 'package:flutter_application_1/pages/google_map_screen.dart';
import 'package:flutter_application_1/pages/trips_page.dart';

class DestinationPage extends StatelessWidget {
  const DestinationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 220,
            color: Colors.teal,
            child: Column(
              children: [
                const SizedBox(height: 50),
                const CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                const Text("Mona Ali", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const Text("", style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 30),

                buildSidebarItem(context, Icons.warning_amber_rounded, "Emergency"),
                buildSidebarItem(context, Icons.map, "Map"),
                buildSidebarItem(context, Icons.history, "History of Action"),
                buildSidebarItem(context, Icons.notifications, "Notification"),
                buildSidebarItem(context, Icons.favorite, "Favorites"),

                const Spacer(),
                const Divider(color: Colors.teal),
                buildSidebarItem(context, Icons.settings, "Settings"),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildTopBar(), // ✅ Top Bar
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Explore Destinations",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: GridView.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                            childAspectRatio: 1.3,
                            children: [
                              const DestinationCard(
                                title: 'Restaurant',
                                imagePath: '../assets/images/restaurant.jpg',
                                destinationPage: RestaurantPage(),
                              ),
                              DestinationCard(
                                title: 'Hotel',
                                imagePath: '../assets/images/hotel.jpg',
                                destinationPage: HotelListScreen(),
                              ),
                              const DestinationCard(
                                title: 'Tour',
                                imagePath: '../assets/images/tour.jpg',
                                destinationPage: TripsPage(),
                              ),
                               DestinationCard(
                                title: 'Historical Places',
                                imagePath: '../assets/images/historical.jpg',
                                destinationPage: CityListScreen(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

Widget buildSidebarItem(BuildContext context, IconData icon, String title) {
  return ListTile(
    leading: Icon(icon, color: Colors.white),
    title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
    onTap: () {
      Widget? page;
      switch (title) {
        case "Emergency":
          page = const EmergencyPage();
          break;
        case "Map":
           page = PlacesMapScreen();
          break;
        case "History of Action":
          page = const HistoryPage();
          break;
        case "Notification":
          page = const NotificationPage();
          break;
        case "Favorites":
          page = const FavoritesPage();
          break;
        case "Settings":
          page = const SettingsPage();
          break;
      }
      if (page != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page!),
        );
      }
    },
  );
}



  Widget buildTopBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: Colors.teal,
      alignment: Alignment.centerLeft,
      child: const Text(
        "Welcome to Discover Palestine (Olive and Stone Land)",
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class DestinationCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final Widget destinationPage;

  const DestinationCard({
    Key? key,
    required this.title,
    required this.imagePath,
    required this.destinationPage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destinationPage),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// صفحات الوجهة
class RestaurantPage extends StatelessWidget {
  const RestaurantPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Restaurant')),
      body: const Center(child: Text('Restaurant Details')),
    );
  }
}

class HotelPage extends StatelessWidget {
  const HotelPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hotels')),
      body: const Center(child: Text('Hotel List')),
    );
  }
}

class TourPage extends StatelessWidget {
  const TourPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tours')),
      body: const Center(child: Text('Trips List')),
    );
  }
}

class HistoricalPlacesPage extends StatelessWidget {
  const HistoricalPlacesPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historical Places')),
      body: const Center(child: Text('Historical Details')),
    );
  }
}

class EmergencyPage extends StatelessWidget {
  const EmergencyPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency')),
      body: const Center(child: Text('Emergency Contact Info')),
    );
  }
}

class MapPage extends StatelessWidget {
  const MapPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map')),
      body: const Center(child: Text('Map and Navigation')),
    );
  }
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History of Action')),
      body: const Center(child: Text('History of User Actions')),
    );
  }
}

class NotificationPage extends StatelessWidget {
  const NotificationPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: const Center(child: Text('All Notifications')),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: const Center(child: Text('Your Favorite Places')),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('App Settings')),
    );
  }
}
