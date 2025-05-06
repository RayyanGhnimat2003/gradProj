import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/Admin_Hotel.dart';
import 'package:flutter_application_1/pages/Hotel.dart';
import 'package:flutter_application_1/pages/city_list_screen.dart';
import 'package:flutter_application_1/pages/trips_page.dart';

class AdminDestinationPage extends StatelessWidget {
  const AdminDestinationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admain Control Page'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            const DestinationCard(
              title: 'Restaurant Control',
              imagePath: '../assets/images/restaurant.jpg',
              destinationPage: RestaurantPage(),
            ),
            DestinationCard(
              title: 'Hotel Control',
              imagePath: '../assets/images/hotel.jpg',
              destinationPage: AdminHotelListScreen(),
            ),
            const DestinationCard(
              title: 'Tour Control',
              imagePath: '../assets/images/tour.jpg',
              destinationPage: TripsPage(),
            ),
            DestinationCard(
              title: 'Historical Places Control',
              imagePath: '../assets/images/historical.jpg',
              destinationPage: CityListScreen(),
            ),
          ],
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
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
            ),
            // Shadow overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            // Text
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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

// Example destination pages (create your own versions with appropriate content)
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
      appBar: AppBar(title: const Text('Hotel')),
      body: const Center(child: Text('Hotel Details')),
    );
  }
}

class TourPage extends StatelessWidget {
  const TourPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tour')),
      body: const Center(child: Text('Tour Details')),
    );
  }
}

class HistoricalPlacesPage extends StatelessWidget {
  const HistoricalPlacesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historical Places')),
      body: const Center(child: Text('Historical Places Details')),
    );
  }
}